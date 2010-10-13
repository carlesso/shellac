
function power = process_song(filename)

% Usage: process_song( song_file_name )
% This function does a segmented resampling of a song array, 1000000
% samples at a time, and then applies various filters.

[song, fs] = wavread(filename);

% NOTE: There's a bug in Matlab's resample.m which we can avoif by setting
% the sampling frequency to 64 kHz (which is roughly correct).
fs = 64000;

% we want a row vector not a column vector 
[h w] = size(song);

if h ~= 1
    song = song';
end
len = length(song);
numblocks = ceil(len/1000000);

disp(['Breaking the song into ' num2str(numblocks) ' blocks.']);

for i =1:numblocks
    disp(['Resampling block ' num2str(i) ' of ' num2str(numblocks) '...']);
    start_index = ((i-1)*1000000) + 1;
    end_index   = start_index + 999999;
    if end_index > len
        end_index = len;
    end
    temp1 = song(start_index:end_index);
    temp2 = resample(temp1, 44100, fs);
    if ~exist('newsong')
        newsong = temp2;
    else
        newsong = [newsong temp2];
    end
end

newsong = 0.99*newsong/max(abs(newsong));

% now some basic filtering

len = length(newsong);

% first a low-pass filter at 8 kHz which is roughly the upper limit of a
% record's bandwidth (this is really true only for 78s)
% NOTE: this may not be necessary given the specs of the next filter
[B,A] = butter(4, [40 8000]/22050);

disp('Applying bandpass filter...');
filtsong = filter(B,A,newsong);

%now the "anti-recording" filter per the LightBlue report
% we need roughly a 12db gain at low frequencies (below 63 Hz),
% then a 6dB per octave fall-off through 250 Hz, no gain between
% 250 and 3100 Hz, and a 6 dB per octave fall off above 3100 Hz

F = [0  10  20  40  63.5  125  250  3100  6200  12400 22050]/22050;
A = [1   1   1   1     1   .5  .25   .25  .125  .0625     0];
%A = [4  4  4   4    4   2    1   1  .5    .25    0];

B = fir2(1024, F, A);
disp('Applying recording compensation filter...');
filtsong = filter(B,1,filtsong);

% normalize
filtsong = 0.99*filtsong/max(abs(filtsong));
 
% HACK: remove the noise bursts at the beginning and end of the song by
% throwing away the first and last second and a half.

filtsong = filtsong((44100*1.5)+1:end);
filtsong = filtsong(1:end - (44100*1.5) + 1);

% normalize
filtsong = 0.99*filtsong/max(abs(filtsong));

% save with a new name

dotpos = findstr(filename, '.');
if isempty(dotpos) % .wav was not included in the filename
    newname = [filename '_44100_filt.wav'];
else
    dotpos = dotpos(end); % find the last . in the file name 
    newname = [filename(1:dotpos-1) '_44100_filt.wav'];
end

disp(['Saving processed wav file as ' newname]);
wavwrite(filtsong, 44100, newname);

