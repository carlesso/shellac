function [ssdmean, ssdstd_dev] = find_stats(wavemat1, wavemat2, numgrooves, numsamples, ...
                                             groovejump, samplejump, numwindows)

% find_stats(wave_matrix_1, wave_matrix_2, #_of_grooves, #_of_samples, num_windows)
% finds the mean and standard deviation of the sum of squared differences
% over num_windows pairs of windows from wave_matrix_1 and wave_matrix_2
% which theoretically are matches

global Gdebug

[h1,w1] = size(wavemat1);
[h2,w2] = size(wavemat2);

ssd = zeros(1, numwindows);
A   = zeros(numgrooves, numsamples);
B   = zeros(numgrooves, numsamples);

%calculate the valid overlap region for wavemat 1
if groovejump >= 0
    lowestvalidgroove  = 1;
else
    lowestvalidgroove  = 1-groovejump;
end
highestvalidgroove = min(h1-numgrooves, h2-groovejump-numgrooves);

samplejump         = -samplejump; % easier if it's positive
%lowestvalidsample  = w1 - samplejump;
lowestvalidsample  = samplejump + 1;
highestvalidsample = w1 - numsamples;

grange = highestvalidgroove - lowestvalidgroove;
srange = highestvalidsample - lowestvalidsample;

for i = 1:numwindows
   %pick a random start groove and sample in the first wave matrix
   startgroove1 = lowestvalidgroove + floor( grange*rand(1));
   startgroove2 = startgroove1 + groovejump;
   endgroove1   = startgroove1+numgrooves-1;
   endgroove2   = startgroove2+numgrooves-1;
   startsamp1   = lowestvalidsample + floor( srange*rand(1));
   startsamp2   = startsamp1 - samplejump;
   endsamp1     = startsamp1+numsamples-1;
   endsamp2     = startsamp2+numsamples-1;
   
   if startgroove1 < 1 || startgroove2 < 1 || startsamp1 < 1 || startsamp2 < 1 || ...
           endgroove1 > h1 || endgroove2 > h2 || endsamp1 > w1 || endsamp2 > w2     
       disp('An error is about to occur. Quitting...');
       disp(['h1           = ' num2str(h1)]);
       disp(['h2           = ' num2str(h2)]);
       disp(['w1           = ' num2str(w1)]);
       disp(['w2           = ' num2str(w2)]);
       disp(['numgrooves   = ' num2str(numgrooves)]);
       disp(['startgroove1 = ' num2str(startgroove1)]);
       disp(['startgroove2 = ' num2str(startgroove2)]);
       disp(['endgroove1   = ' num2str(endgroove1)]);
       disp(['endgroove2   = ' num2str(endgroove2)]);
       disp(['startsamp1   = ' num2str(startsamp1)]);
       disp(['startsamp2   = ' num2str(startsamp2)]);
       disp(['endsamp1     = ' num2str(endsamp1)]);
       disp(['endsamp2     = ' num2str(endsamp2)]);
       disp(['lowestvalidgroove  = ' num2str(lowestvalidgroove)]);
       disp(['highestvalidgroove = ' num2str(highestvalidgroove)]);
       disp(['groovejump         = ' num2str(groovejump)]);
       disp(['lowestvalidsample  = ' num2str(lowestvalidsample)]);
       disp(['highestvalidsample = ' num2str(highestvalidsample)]);
       disp(['samplejump         = ' num2str(samplejump)]);
       return;
   end       
   
   %compute ssd over the ith window
   A = wavemat1(startgroove1:endgroove1, startsamp1:endsamp1);
   B = wavemat2(startgroove2:endgroove2, startsamp2:endsamp2);
   ssd(i) = sum(sum( (A-B).^2));    
end

ssdmean    = mean(ssd);
ssdstd_dev = std(ssd);
