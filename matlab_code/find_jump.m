function j_struct = find_jump(bundle)
%$Revision: 1.1 $ $Author: mmccann $ $Date: 2004/05/08 20:44:20 $
global Gdir
% load top bundle and bottom bundle into waves1 and waves2
S = load(sprintf('%s/%d.%d.waves.mat',Gdir,1,bundle));
waves1 = S.waves(:,1:round(end/2));
S = load(sprintf('%s/%d.%d.waves.mat',Gdir,1,bundle+1));
waves2 = S.waves(:,1:round(end/2));

[rows1 cols1] = size(waves1);
samp_start = round(cols1/2);
samp_end = samp_start+99;
L = find_diffs(waves1(rows1-2:rows1,samp_start:samp_end), waves2(:,:));

j_struct.groove(1) = rows1-2;
j_struct.groove(2) = L(1,2);
j_struct.sample(1) = samp_start;
j_struct.sample(2) = L(1,3);
