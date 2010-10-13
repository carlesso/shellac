function rate = rate_from_align(bundle)
%$Revision: 1.1 $ $Author: mmccann $ $Date: 2004/05/07 03:17:42 $
%rate = rate_from_align([bundle]) - returns the sample rate in samples
%  per second based on the alignment data for the given bundle (1 by
%  default) and Grpm as was set by set_dir.  This should be the
%  correct number to pass to wavwrite as the sample rate.  This
%  rate should agree relatively closely with the value returned
%  from rate_from_track.
global Gnum_scans Galigns Grpm
if nargin < 1
  bundle = 1;
end
load_aligns(bundle);
total = 0;
for i=1:Gnum_scans
  cur = i;
  pre = mod(i-2,Gnum_scans)+1;
  diff = Galigns(cur).sample(1) - Galigns(pre).sample(2);
  total = total + diff;
end

rate = round(total*Grpm/60);

