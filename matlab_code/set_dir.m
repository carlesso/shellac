function set_dir(dir_name, num_scans, rpm, smooth_image, smooth_wave)
%$Revision: 1.7 $ $Author: nailon $ $Date: 2004/05/09 03:18:48 $
%set_dir(dir_name [, num_scans] [,rpm] [,smooth_image] [,smooth_wave]) - sets a global variables for the
%  directory path of the record images (and all intermediate files),
%  as well as the number of scanned images and the rpm of the record,
%  and some smoothing parameters.
%  If num_scans not specified, then the number of scanned images will
%  be set according to the number of .png files in dir_name. rpm will
%  be 78 by default.  Typlical values are 100/33 for LPs and 78 for
%  SPs.  If rpm is not specified it will first look for a file
%  plain-text file called rpm that contains the rpm value.  If this
%  is not found, then the default will be 78.  The rpm setting will
%  be written to the file rpm.
%  smooth_image - default 2.  The higher it is, the more smoothing it 
%  does on the image.
%  smooth_wave  - default 5.  The higher it is, the more smoothing
%  done on wave.
global Gdir Gnum_scans Grpm Gdebug Gsmooth_image Gsmooth_wave
global Gstart_end_thresh
global Gend_panic_skip

filename =  sprintf('%s/rpm',dir_name);

if nargin < 3
  result = exist(filename);
  if result == 0
    rpm = 78;
  else
    rpm = load(filename);
  end
end


if (nargin < 4)
	smooth_image = 2;
end

if (nargin < 5)
	smooth_wave = 5;
end		
Gsmooth_wave = smooth_wave;
Gsmooth_image = smooth_image;

% Update rpm value regardless
fid = fopen(filename, 'w');
fprintf(fid,'%f',rpm);
fclose(fid);

if nargin < 2
  s = dir(sprintf('%s/*.png',dir_name));
  num_scans = length(s);
end

Gdir = dir_name;
Gnum_scans = num_scans;
Grpm = rpm;

if Gdebug
  temp = '\nworking directory: %s,  num_scans: %d,  rpm: %f\n';
  disp(sprintf(temp, Gdir, Gnum_scans, Grpm));
end

Gstart_end_thresh = 0.3;
if (Grpm==33)
  Gend_panic_skip=35;
else
  Gend_panic_skip=10;
end
