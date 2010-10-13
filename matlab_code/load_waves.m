function load_waves(bundle)
% $Revision: 1.3 $ $Author: mmccann $ $Date: 2004/05/05 16:49:00 $
%load_waves - loads all files 1.waves.mat, 2.waves.mat, ... into
%  global structure array Gall_waves.  Looks at Gdir and Gnum_scans.
global Gdir Gnum_scans Gall_waves

for i=1:Gnum_scans
  S = load(sprintf('%s/%d.%d.waves.mat',Gdir,i,bundle));
  Gall_waves(i).waves = S.waves;
end
