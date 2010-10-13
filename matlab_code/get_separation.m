% $Revision: 1.5 $ $Author: nailon $ $Date: 2004/05/09 03:18:48 $
function [sep_list,mn,st, section,f,kernel,section_conv_kernel] = get_separation(y,x,r1,r2)
% Returns a vector of song separators.  Each separator
% is specified as its distance from the center.
% y,x - The record center.
% r1,r2 - upper,lower limit of search
% Assumes that the part above the record and the area of
% the center of the record are not between r1 and r2

global Grecord
global section
global Gdebug
global Gstart_end_thresh
global Gend_panic_skip

sep_list = [];
mn=0;
st=0;

if (Gdebug == 1)
	y
	x
	r1
	r2
	y-r1
	y-r2
	x
end


section = transpose(Grecord(floor(y-r1):floor(y-r2),floor(x)-50:floor(x)+50));
f=0;
[h w] = size(section);
for i=1:h
	for j=1:3
		rndm=floor(rand*(w-w/3)+1);
		f=f+abs(fft(section(i,rndm:floor(rndm+w/3))));
	end
end
f(1:30) = 0;
f(floor(w/6):end) = 0;
[maxval maxind] = max(abs(f));
track_width = floor((w/3)/maxind);
if (Gdebug==1)
	track_width
end

%%%%% Find top point and low point of the record inside
%%%%% the given interval

kernel = 1:floor(track_width*30);
kernel = exp(2i*pi*kernel/track_width);
section_sum = sum(section);
section_conv_kernel = abs(filter2(kernel,section_sum,'same'));
section_conv_kernel = section_conv_kernel .* 2;
mx = max(section_conv_kernel);

%for i=1:w
%  if (section_conv_kernel(i) > Gstart_end_thresh * mx)
%    effective_start = i;
%    break;
%  end
%end
for i=w:-1:1
  if (section_conv_kernel(i) > Gstart_end_thresh * mx)
    effective_end = i
    break;
  end
end

section = mean(section);
section = do_gaussian1d(section, floor(track_width));

%effective_start = max(1, effective_start - track_width*15);
%while(section(effective_start) > 100)
%  effective_start = effective_start + 1;
%end
effective_start = 2;
effective_end = min(w, effective_end + track_width*Gend_panic_skip);
if (Gdebug)
  effective_start
  effective_end
end
sep_list = [floor(r1-effective_start)];
nseps=1;
%%%% Find the song separations between the top and low points.

mid_mean=mean(section);
if (Gdebug)
	mid_mean
end
minima=zeros(1,w);
maxima=zeros(1,w);
nminima = 0;
nmaxima = 0;
for i=effective_start:effective_end-1
	if (section(i) <= min(section(i-1), section(i+1)))
		nminima=nminima+1;
		minima(nminima) = section(i);
	end
	if (section(i) >= max(section(i-1), section(i+1)))
		nmaxima=nmaxima+1;
		maxima(nmaxima) = section(i);
	end
end
low_mean=mean(minima(1:nminima));
high_mean = mean(maxima(1:nmaxima));
if (Gdebug)
	low_mean
	high_mean
end

% look for strong minima in intervals of 3 times track width
threshold = min(high_mean - (high_mean - low_mean) * 5, 35);

for i=effective_start+floor(3*track_width+1):effective_end-floor(3*track_width+1)
	if (section(i) < threshold && section(i) <= min(section(floor(i-3*track_width):floor(i+3*track_width))))
%               
%               Make sure it's not too close to previous separation.
%
		radius = floor(r1-i);
		if (nseps > 0 && i > sep_list(nseps) - 30 * track_width)
		  continue;
		end
		sep_list = [sep_list; radius];
		nseps=nseps+1;
	end
end

effective_end_radius = floor(r1-effective_end);
if (effective_end_radius < sep_list(nseps) - 30 * track_width)
  sep_list = [sep_list; effective_end_radius];
end


return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% old subroutine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
section = mean(transpose(Grecord(floor(y-r1):floor(y-r2),floor(x)-5:floor(x)+5)));
section = do_gaussian1d(section,30);
%mn = mean(section);
%st = std(section);
%if (Gdebug)
%	figure; plot(section);
%end
[dummy len] = size(section);

%get vector of local minima
minima = zeros(1,len);
nminima = 0;
for i=2:len-1
	if (section(i) < section(i-1) && section(i) < section(i+1))
		nminima=nminima+1;
		minima(nminima) = section(i);
	end
end
mn = mean(minima(1:nminima));
st = std(minima(1:nminima));
if (Gdebug == 1)
	mn
	st
end

% find intervals that are less than the mean intensity
section2 = (section < mn-1.3*st) .* (section < 40);

in_interval = 0;
for i=1:len+1
	if (in_interval)
		% interval stops
		if (i==len+1 || section2(i) == 0)
			in_interval = 0;
			% count number of points with intensity less than
			% 3 std's under mean
			if (i-start_int > 10)
				min_j = start_int;
				for j=start_int:i-1
					if (section(j) < section(min_j))
						min_j = j;
					end
				end
				sep_list = [sep_list; floor(r1-min_j)];
			end
		end
	else
		if (i <= len && section2(i) == 1)
			start_int = i;
			in_interval = 1;
		end
	end

end

