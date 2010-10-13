function get_waves
%get_waves - runs get_wav for all the .trk.mat files in the directory,
%   and stores the Gwave's in #.waves.mat, where # is the image number.

global Grecord
global Gdelta
global track_piece
global Gdir
global Gnum_scans
global Gwave

colormap(gray);

dr = dir(sprintf('%s/*.trk.mat', Gdir));
[num_files dummy] = size(dr);
num_bundles = num_files/Gnum_scans;

for sect=1:Gnum_scans
  for bun=1:num_bundles
    load(sprintf('%s/%d.%d.trk.mat',Gdir,sect,bun));
    [angles, sums, track_starts] = get_wav;
    waves = Gwave;
    save(sprintf('%s/%d.%d.waves.mat', Gdir, sect, bun),'waves');
  end
end


% for num_img=1:num_files
% 	raw_filename = dr(num_img).name;
% 	load(sprintf('%s/%s',Gdir, raw_filename));

% 	[angles, sums, track_starts] = get_wav;

% 	waves = Gwave;
% 	save(sprintf('%s/%s.waves.mat', Gdir, raw_filename(1:end-8)), 'waves');
% end
