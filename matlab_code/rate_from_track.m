function rate = rate_from_track
%$Revision: 1.1 $ $Author: mmccann $ $Date: 2004/05/07 03:15:20 $
%rate = rate_from_track - returns the sample rate in samples per
%  second based on the data found in file 1.1.trk.mat and global
%  variable Grpm.  The rate returned will be the same give or take 2
%  samples for all possible track files.  This value should agree
%  relatively closely with value returned from rate_from_align.
global Gdir Grpm
S = load(sprintf('%s/%d.%d.trk.mat', Gdir, 7, 3));
samp = 2*pi*length(S.track_piece)/(S.theta_left-S.theta_right);
rate = round(samp*Grpm/60);