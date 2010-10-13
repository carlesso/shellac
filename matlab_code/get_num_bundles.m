function num_bundles = get_num_bundles
% $Revision: 1.2 $ $Author: mmccann $ $Date: 2004/05/09 22:16:14 $
% num_bundles = get_num_bundles() - calculates the number of
%   bundles per sector in directory Gdir. 
global Gdir
S = load(sprintf('%s/song_struct.mat',Gdir));
num_bundles = length(S.song_struct);
