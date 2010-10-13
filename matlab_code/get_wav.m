function [angles,sums,track_starts,fout] = get_wav
%$Revision: 1.9 $ $Author: nailon $ $Date: 2004/05/09 20:17:32 $
%[angles,sums,track_starts] = get_wav - creates a wave matrix from
%   the track_piece image, and stores it in the global variable Gwave.
%   The current algorithm I use finds the peak intensity pixel, then
%   fits a parabola to that pixel and its two neighbors, then returns
%   the center of the parabola.
global Gwave
global track_piece
global track_piece_debug
global Gdebug
global Grpm
global Gsmooth_wave

sums=0;
track_starts=0;
angles=0;
fout=0;

if (~exist('Gdebug', 'var') || length(Gdebug) == 0)
	Gdebug = 0;
end

[height width] = size(track_piece);

if (height < 100 || width < 400)
	Gwave = zeros(1,width);
	return
end



f=0;
for i=1:40:width-40
	tmp_f=0;
	for i1=0:39
		tmp_f= tmp_f + fft(track_piece(:,i+i1));
	end
	f = f+ abs(tmp_f);
end
f(1:60)=0;
f(floor(height/2):height) = 0;
[m max_freq] = max(abs(f));
fout=f;


Gwave = zeros(max_freq, width);
angles = zeros(1,width);
for i=1:width
	f=fft(track_piece(:,i));
	angles(i) = angle(f(max_freq));
end

track_width = height/max_freq;
angles = angles/(2*pi)*track_width;

%if (Grpm < 35)
%	angles = do_gaussian1d(angles, 10);
%	angles = mod(angles, track_width);
%	
%end

%
% make the angles contiguous
%
for time=1:width-1

	del = round((angles(time+1)-angles(time))/track_width);
	angles(time+1) = angles(time+1) - del*track_width;
end	

%
% smooth the angles vector
%
%angles = do_gaussian1d(angles, 400);
angles = do_gaussian1d(angles, 40);
%for i=1:width-4
%	angles(i) = (angles(i)+angles(i+1)+angles(i+2)+angles(i+3)+angles(i+4))/5.0;
%end


%%%%%%%%%%%%%%%%%%%%%%%

min_angle=min(angles);
% make the whole thing positive
if (min_angle < 0)
	angles = angles - track_width * floor(min_angle/track_width);
end
max_angle=max(angles);
skip = track_width * ceil((max_angle+track_width/2+1)/track_width);

% discover the exact number of tracks
%sums = zeros(height-ceil(skip)+1,1);
sums = zeros(height,1);
for i= ceil(skip):height
	tmpsum=0;
	for j=1:10:width
		tmpsum=tmpsum+double(track_piece(floor(i-angles(j)), j));
	end
	sums(i) = tmpsum;
end

half_track = floor(track_width/2);

% track_starts are found by finding peeks.
track_starts = [];
for i=ceil(skip):height-half_track
	tmpmax = -1;
	for j=-half_track:half_track	
		if (sums(i+j) > tmpmax)
			tmpmax = sums(i+j);
			max_index = j;
		end
	end
	if (max_index == 0)
		track_starts = [track_starts i];
	end
end

[dummy num_tracks] = size(track_starts);

% Get rid of outlying track starts - with distance of more than 
% 2*track_width from neighbouring tracks.
%
if (Grpm < 35)
	track_starts_filter = [];
	if (num_tracks > 1 && track_starts(2) - track_starts(1) < track_width*2)
		track_starts_filter = [track_starts(1)];
	end
	for i=2:num_tracks-1
		if (track_starts(i)-track_starts(i-1) < track_width*2 && ...
			track_starts(i+1)-track_starts(i) < track_width*2)
			track_starts_filter = [track_starts_filter track_starts(i)];
		end
	end
	if (track_starts(num_tracks) - track_starts(num_tracks-1) < track_width*2)
		track_starts_filter = [track_starts_filter track_starts(num_tracks)];
	end
	track_starts = track_starts_filter;
	[dummy num_tracks] = size(track_starts);
end



Gwave = zeros(num_tracks, width);	
first_time_compute_H = 1;
for time=1:width
	if (mod(time,1000) == 0 && Gdebug==1)
		time
	end
	for track = 1:num_tracks
		center = track_starts(track)-angles(time);
%		center = skip-angles(time)+track*track_width;

		err = center - floor(center);
		center = floor(center);
		sum1=0; 
		sum2=0;
		
		% find the peak intensity
		tmpmax = -1;

		[dummy maxind] = max(track_piece(center-half_track:center+half_track,time));
		maxind = maxind - half_track - 1;
		
%		Problem: sometimes next track "steals" from this track
%		This fixes that problem:  In case the max index is the
%               extreme end, replace it with the maximal LOCAL maximum.
%               This is important for the 33 records.
%
		if (maxind == half_track || maxind == -half_track)
			maxint = -1;
			for i=-half_track+1:half_track-1
				if (track_piece(center+i,time) >= max(track_piece(center+i-1,time), track_piece(center+i+1,time)))
					if (track_piece(center+i) > maxint)
						maxint = track_piece(center+i);
						maxind = i;
					end
				end
			end
		end



		%
		% find the center of mass 2 pixels above/below max intensity
		%
%		for i=-1:1
%			sum1=sum1 + (maxind+i)*track_piece(center+maxind+i,time);
%			sum2=sum2 + track_piece(center+maxind+i,time);	
%		end

%		Fit a paraboloid around the max intensity
		alpha = 2;
		if (maxind > half_track-alpha || maxind < -half_track+alpha)
			result = 0;
		else
			zerox = center+maxind;
			if (first_time_compute_H)
				H=zeros(2*alpha+1,3);
				for i=-alpha:alpha
					H(i+alpha+1,:) = [i*i i 1.0];
				end
				invtrHHtrH = inv(transpose(H)*H)*transpose(H);
				first_time_compute_H = 0;
			end
			h = double(track_piece(zerox-alpha:zerox+alpha,time));
			res1 = invtrHHtrH(1,:)*h;
			if (res1 ~= 0)				
				result = (-(invtrHHtrH(2,:)*h)/(2*res1));

%				Due to inaccuracies, sometimes res1 is almost 0
%				and then the result becomes almost infinity.
				if (abs(result) > half_track)
					result = 0;
				end
			else
				result = 0;
			end
		end
%		if (Gdebug==1) % plot wave in track_piece
%		  tmp = floor(center+(maxind+result)*4);
%		  if (tmp < 1)
%		    tmp = 1;
%		  end
%		  if (tmp > height)
%		    tmp=height;
%		  end
%		  track_piece_debug(tmp,time,:) = [3000 0 0 ];
%		  track_piece_debug(center, time,:) = [0 3000 0];		  
%		end

%		track_piece(center,time) = 255;
		Gwave(track,time) = (maxind+result-err)/track_width;
%
%		if (sum2==0)
%			'warning'
%			time
%			track
%		else
%			Gwave(track,time) = ((sum1-err)/sum2)/track_width;
%			if (time >= 6000 && time < 6500)
%				line([time time], [center+(sum1-err)/sum2  center+(sum1-err)/sum2]);
%			end
%		end
	end
end


% make sure average is 0 and get rid of outliers
if (Gdebug==1)
	disp('huh');
end
for i=1:num_tracks
	% errors in rectification
	Gwave(i,:) = Gwave(i,:) - do_gaussian1d(Gwave(i,:), floor(width/25));

	% dust

	mn = mean(Gwave(i,:)); % should be 0 but let's calculate anyway
	st = std(Gwave(i,:));
	Gwave(i,:) = Gwave(i,:) .* (Gwave(i,:) > mn-st*4) .* (Gwave(i,:) < mn+st*4);

	% a bit more smoothing
	Gwave(i,:) = do_gaussian1d(Gwave(i,:), Gsmooth_wave);

end

if (Gdebug==1)
	disp('haha');
end
%	Gwave(i,:) = Gwave(i,:) - mean(Gwave(i,:));
%	stddev = std(Gwave(i,:));
%	Gwave(i,:) = Gwave(i,:) / max( max(Gwave(i,:)), -min(Gwave(i,:)));
%	for j=1:width
%		if (Gwave(i,j) > 4*stddev || Gwave(i,j) < 4*stddev)
%			lft = max(1,j-5);
%			rgt = min(width,j+5);
%			Gwave(i,j) = sum(Gwave(i,lft:rgt))/(rgt-lft+1.0);
%		end
%	end
%	Gwave(i,:) = Gwave(i,:) .* double((Gwave(i,:) < 5*stddev) & (Gwave(i,:) > -5*stddev));
%end

