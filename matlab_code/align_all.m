function time = align_all(bundle)
%$Revision: 1.5 $ $Author: mmccann $ $Date: 2004/05/09 23:29:26 $
%align_all([bundle]) - runs align_waves on all waves files in directory
%  Gdir for each set of bundles.  Can bun run on a specific bundle
%  if specified.  Results are saved in global variable Galigns.  Results
%  are written to disk with function save_aligns.  Use compare_aligns
%  to visually verify the alignment results between waves.
global Galigns Gdir Gnum_scans
t0 = clock;

if nargin < 1
  bundles = 1:get_num_bundles;
else
  bundles = [bundle];
end

for bun=bundles
  skip_bun = 0;
  disp(sprintf('alignment for all sectors in bundle %d\n',bun));
  diff = 0;
  for i=1:Gnum_scans
    a = i;
    b = mod(i,Gnum_scans)+1;
    S = load(sprintf('%s/%d.%d.waves.mat',Gdir,a,bun));
    waves1 = S.waves;
    S = load(sprintf('%s/%d.%d.waves.mat',Gdir,b,bun));
    waves2 = S.waves;
    if skip_bun == 0
      if (size(waves1,1) < 40) | (size(waves2,1) < 40)
	disp(sprintf('    waves block for sector %d or %d too small', ...
		     a,b));
	disp(sprintf('    aborting alignment for bun %d\n', bun)); 
	skip_bun = 1;
      else
	disp(sprintf('  alignment for sector %d with %d:',a,b));
	al = align_waves(waves1,waves2);
	Galigns(i).first = al.first;
	diff = diff + (al.first(2) - al.first(1));
	Galigns(i).last = al.last;
	Galigns(i).sample = al.sample;
      end
    end
  end
  if skip_bun == 0
    save_aligns(bun);
    disp(sprintf('total delta for bundle %d is %d\n',bun,diff));
  end
end

time = round(etime(clock,t0));

function save_aligns(bundle)
% save_aligns - saves each of the alignment structures in global
%   struct array Galigns into individual files of the form
%   1.1.align.mat, 2.1.align.mat in the directory specifed by Gdir.
global Gdir Gnum_scans Galigns
for i=1:Gnum_scans
  first = Galigns(i).first;
  last = Galigns(i).last;
  sample = Galigns(i).sample;
  save(sprintf('%s/%d.%d.align.mat',Gdir,i,bundle),'first','last','sample');
end
