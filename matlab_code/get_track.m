function get_track(max_mem,arg)
% $Revision: 1.12 $ $Author: nailon $ $Date: 2004/05/09 03:18:48 $
global track_piece
global Gdir
global Gdebug
global Gsmooth_image

if (nargin == 0)
	max_mem = 10000000;
end
if (max_mem < 10000000)
	error('max_mem must be at least 10000000');
end
patch_flag=0;
if (nargin==2)
  if (strcmp(arg,'center-from-first'))
    patch_flag=1;
  end
end


%get_track(dirname, num_scans) - asks user to click on start/stop,
%   then creates the .trk.mat files from the .png files.
global Grecord
global delta
global track_piece
global Gdir
global Gnum_scans

colormap(gray);

Gnum_scans = eval(Gnum_scans)

for num_img=1:Gnum_scans
	Grecord = imread(sprintf('%s/%d.png',Gdir,num_img));
	sz = size(Grecord);
	figure(1);
%	imagesc(Grecord);
%	drawnow;

	if ((patch_flag && num_img==1) || ~patch_flag)
	  c = calcCenter(findOuterEdge);
	  y=c(1);
	  x=c(2);
	  r=c(3);
	end
  %ec
  disp(sprintf('Center detected at(%d, %d). Radius is %s', x, y, r))

  if size(Grecord) != 2
    error('The image must be in grayscale!')
  end

	[h w] = size(Grecord);
	if (Gdebug)
	  colormap(gray);
	  imagesc(Grecord);
	  drawnow;
	end
	
%	line([x 1], [y 1]);

	% get first,last track
	if (num_img==1)
		%[x1,y1] = ginput(1);
		%[x2,y2] = ginput(1);
		%x1=x1 + x-100;
		%x2=x2 + x-100;
		%r1 = floor(sqrt((x1-x)^2 + (y1-y)^2));
		%r2 = floor(sqrt((x2-x)^2 + (y2-y)^2));
		
		r1 = r;
		r2 = 100;
		
		% the steps we take in the angle
		delta = 1/r;

		% get separations list

		sep_list = get_separation(y, x, r1, r2);
		% add sentinels to separation list
		siz = length(sep_list);
		r1 = sep_list(1);
		r2 = sep_list(siz);
%		sep_list = [r1; sep_list; r2];
		if (Gdebug == 1)
			disp('sep_list:');			
			sep_list
			for i=1:siz
			  line([x-1000 x+1000],[y-sep_list(i) y-sep_list(i)]);
			end
			drawnow;
		end
	end
	
	% get intersection of record with left boundary
	y_left= y-sqrt(r^2-(x-1)^2);

	% get intersection of record with right boundary
	y_right = y-sqrt(r^2-(x-sz(2))^2);
  %ec
  % Nel caso l'immagine non sia in grayscale y_left risulta essere un numero complesso

	if (Gdebug==1)
	  line([1 x], [y_left y]);
	  line([sz(2) x], [y_right y]);
	  drawnow;
	 end

	theta_left = atan((2-x)/(y_left-y));
	theta_right = atan((sz(2)-1-x)/(y_right-y));
	
	width = floor((theta_left-theta_right)/delta);
	if (num_img == 1)
		height = floor(r1-r2+1);
		height_per_file = floor(max_mem/width);
	end
	overlap = floor(height_per_file/5);

%       Loop on the file numbers

	i_sep = 1;
	num_file = 1;
	r_big = r1;
	r_small = floor(0.3*r1)

	% a vector which tells, for each bundle, what song it belongs to.
	song_struct = [i_sep];

	while(1)
		num_file;
		track_piece = zeros(1726, 5129);
		for i=1:width
			tmpcos = cos(theta_right + i*delta);
			tmpsin = sin(theta_right + i*delta);
			for r0 = r_big:-1:r_small

				% warping: get a weighted sum of 4 neighboring pixels
				y0=min(max(y-r0*tmpcos,1), sz(1)-1);
				x0=min(max(x-r0*tmpsin,1), sz(2)-1);
				y0_int = floor(y0);
				y0_frac = y0-y0_int;
				x0_int = floor(x0);
				x0_frac = x0-x0_int;
			
%				if (patch_flag && mod(i,20) == 0 && r0==r1)
%				  line([x0_int x0_int], [y0_int y0_int]);
%				end
				tmp = double(Grecord(y0_int,x0_int))*(1-y0_frac)*(1-x0_frac)+double(Grecord(y0_int+1,x0_int))*(y0_frac)*(1-x0_frac)+double(Grecord(y0_int,x0_int+1))*(1-y0_frac)*(x0_frac)+double(Grecord(y0_int+1,x0_int+1))*y0_frac*x0_frac;
        track_piece(r_big-r0+1,i) = uint8(tmp);
			end		
		end
		outfile = sprintf('%s/%d.%d.trk.mat', Gdir, num_img, num_file)
		center_x = x;
		center_y = y;
		radius = r;


		do_gaussian(Gsmooth_image);	
	
		save(outfile, 'track_piece', 'theta_right', 'theta_left', ...
		     'delta', 'r_big', 'r_small', 'radius', 'center_x', 'center_y');

%               check if this is the last file
		if (r_small == r2)
			break;
		end

%		otherwise prepare next file
		num_file = num_file + 1;

		if (r_small == sep_list(i_sep+1))
			i_sep = i_sep + 1;
			r_big = sep_list(i_sep);
			r_small = max(r_big - height_per_file + 1, sep_list(i_sep+1));
		else
			r_big  = r_small + overlap;
			r_small = r_big - height_per_file + 1;
			if (r_small < sep_list(i_sep+1))
				r_small = sep_list(i_sep+1);
				r_big = min(r_small + height_per_file - 1, sep_list(i_sep));
			end
		end
		song_struct = [song_struct i_sep];

	end
%	imagesc(track_piece);

%	Save the song structure to a file.
	if (num_img == 1)
		save(sprintf('%s/song_struct.mat', Gdir), 'song_struct');
	end
end
