function create_all_songs
%$Revision: 1.2 $ $Author: mmccann $ $Date: 2004/05/09 23:27:37 $
% create_all_songs - Creates a list of all songs.
global Gdir Gnum_scans Gall_waves

S = load(sprintf('%s/song_struct.mat',Gdir));
song_struct = S.song_struct;
num_bundles = length(song_struct);

cur_song = 1;
bun_str(1).first = 1;
if (num_bundles == 1) | ((num_bundles > 1) & song_struct(2) > 1)
    bun_str(1).last = 1;
end
for i=2:num_bundles-1;
  if (song_struct(i-1) < song_struct(i))
    cur_song = cur_song+1;  % a new song beginning
    bun_str(cur_song).first = i;
  end
  if (song_struct(i) < song_struct(i+1))
    bun_str(cur_song).last = i;  % the end of a song
  end
end
if (num_bundles > 1) & (song_struct(num_bundles) > song_struct(num_bundles-1))
  cur_song = cur_song+1;
  bun_str(cur_song).first = num_bundles;
end
bun_str(cur_song).last = num_bundles;

% throw out songs with bad bundles
valid_count = 0;
for i=1:length(bun_str)
  valid = 1;
  for bun = bun_str(i).first:bun_str(i).last
    load_waves(bun);
    for sector=1:Gnum_scans
      valid = size(Gall_waves(sector).waves,1) >= 40;
    end
  end
  if valid
    valid_count = valid_count+1;
    valid_bun_str(valid_count) = bun_str(i);
  else
    disp(sprintf('there are problems in song %d. skipping...',i));
  end
end

for i=1:size(valid_bun_str,2)
  format = 'creating song %d from bundles %d to %d...\n';
  disp(sprintf(format, i, valid_bun_str(i).first, valid_bun_str(i).last));
  create_song(valid_bun_str(i).first, valid_bun_str(i).last);
  save_audio(sprintf('song%d',i),rate_from_align(valid_bun_str(i).first));
end


function save_audio(name, rate)
global Gdir Gmaster
filename = sprintf('%s/%s.wav',Gdir,name);
wavwrite(Gmaster,rate,filename);
disp(sprintf('\nwrote %s with sample rate %d\n', filename, rate));
