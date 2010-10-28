function do_everything(dirname, nscans, rpm)
%$Revision: 1.2 $ $Author: mmccann $ $Date: 2004/05/09 23:47:27 $
set_dir(dirname, nscans, rpm);
get_track;
get_waves;
align_all;
find_all_jumps;
create_all_songs;
