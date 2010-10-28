function load_aligns(bundle)
% $Revision: 1.3 $ $Author: mmccann $ $Date: 2004/05/02 21:13:49 $
% load_aligns - loads alignment data stored in files 1.1.align.mat,
% 2.1.align.mat, ... into global structure array Galigns.
global Gdir Gnum_scans Galigns

for i=1:Gnum_scans
  S = load(sprintf('%s/%d.%d.align.mat',Gdir,i,bundle));
  Galigns(i).first = S.first;
  Galigns(i).last = S.last;
  Galigns(i).sample = S.sample;
end
