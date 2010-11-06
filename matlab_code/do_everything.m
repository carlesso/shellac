function do_everything(dirname, nscans, rpm)
%$Revision: 1.2 $ $Author: mmccann $ $Date: 2004/05/09 23:47:27 $
disp('set_dir called')
set_dir(dirname, nscans, rpm);
disp('set_dir ended. Calling get_track')
get_track;
disp('get_track ended. Calling get_waves')
get_waves;
disp('get_waves ended. Calling align_all')
align_all;
disp('align_all ended. Calling find_all_jumps')
find_all_jumps;
disp('find_all_jumps ended. Calling create_all_song')
create_all_songs;
disp('create_all_song ended')
