function [ssdmean, ssdstd_dev] = find_stats_rand(wavemat1, wavemat2, numgrooves, numsamples, numwindows)
%$Revision: 1.2 $ $Author: pcalamia $ $Date: 2004/05/09 22:48:21 $
% find_stats_rand(wave_matrix_1, wave_matrix_2, #_of_grooves, #_of_samples, num_windows)
% finds the mean and standard deviation of the sum of squared differences
% over num_windows random pairs of windows from wave_matrix_1 and wave_matrix_2 

global Gdebug

[h1,w1] = size(wavemat1);
[h2,w2] = size(wavemat2);

ssd = zeros(1, numwindows);
A   = zeros(numgrooves, numsamples);
B   = zeros(numgrooves, numsamples);

for i = 1:numwindows
   %pick a random start groove in each wave matrix(skip the first and last 5)
   startgroove1 = 5 + floor((h1-(numgrooves+10))*rand(1));
   startgroove2 = 5 + floor((h2-(numgrooves+10))*rand(1));
   
   %pick a random start sample in each wave matrix
   startsamp1   = ceil((w1-numsamples+1)*rand(1));
   startsamp2   = ceil((w2-numsamples+1)*rand(1));
    
   %compute ssd over the ith window
   A = wavemat1(startgroove1:startgroove1+numgrooves-1, startsamp1:startsamp1+numsamples-1);
   B = wavemat2(startgroove2:startgroove2+numgrooves-1, startsamp2:startsamp2+numsamples-1);
   ssd(i) = sum(sum( (A-B).^2));    
end

ssdmean    = mean(ssd);
ssdstd_dev = std(ssd);
