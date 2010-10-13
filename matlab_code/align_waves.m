function alignStruct = align_waves(waves1,waves2,gstart,gend,offset)
%alignStruct = align_waves(waves1,waves2,gstart,gend,offset) - 
%  performs alignment on small subregion of right side of matrix
%  waves1 with all of waves2.  gstart and gend are optional
%  parameters to specify the starting and ending grooves of waves1
%  to try allignment.  offset is and optional parameter specifying
%  how many samples from the end of waves1 to try alignment on.
%  The results are stored in the struct alignStruct with fields as
%  follows (eg.):
%     first: [1 3] - says that the end of groove 1 of waves1 lines
%                    up with the beginning of groove 3 on waves2.
%     last: [41 43] - says the the end of groove 41 of waves1 lines
%                     up with the beginning of groove 3 on waves2.
%     sample: [13001 7065] - says the end sample of waves1 lines up
%                     with sample 7065 of waves2
%PTC 8 May 2004: Added code to check validity of the alignment
t0 = clock;
global Gdebug

[rows1 cols1] = size(waves1);
[rows2 cols2] = size(waves2);

if nargin < 5
  offset = min(150,cols1);
end
%if nargin < 4
%  gend = min(round(min(rows1,40)/2)+10,rows1-10);
%end
%if nargin < 3
%  gstart = max(gend-10,10);
%end
%gstart = 13;
%gend = 23;

if Gdebug
  mode = 0; %Fix this (should be 1) when done debugging 
else
  mode = 0;
end

gstart = [13 18 23];
gend   = [23 28 33];

% find_stats(wave_matrix_1, wave_matrix_2, #_of_grooves, #_of_samples, num_windows)
% finds the mean and standard deviation of the sum of squared differences
% over num_windows random pairs of windows from wave_matrix_1 and wave_matrix_2

% find the mean and standard deviation of the ssd over N random window
% pairs
[randmean, randstd_dev] = find_stats_rand(waves1, waves2, (gend(1)-gstart(1)), offset, 1000);
disp(['     mean ssd over random windows = ' num2str(randmean)]);
disp(['     std dev. over random windows = ' num2str(randstd_dev)]);

% Initialize L
L    = zeros(1, 3);

%try three times to get a good match
matchmean = randmean;
count = 1;
while (count < 4) && (matchmean > (randmean - randstd_dev))

   % find the best match 
   L = find_diffs(waves1(gstart(count):gend(count),end-offset:end),waves2(1:40,:),mode);
   disp(['     Try ' num2str(count) ': L = ' num2str(L(1,:))]);

   % Establish the correspondences
   [rows1 cols1] = size(waves1);
   [rows2 cols2] = size(waves2);
   sample = [cols1 L(1,3)+offset];
   diff = abs(L(1,2)-gstart(count));
   if L(1,2) > gstart(count)
     first = [1, 1 + diff];
     if ((rows1 + diff) < rows2)
       last = [rows1 , (rows1 + diff)];
     else
       last = [(rows2 - diff) , rows2];
     end
   else
     first = [1 + diff, 1];
     if ((rows2 + diff) < rows1)
       last = [(rows2 + diff), rows2];
     else
       last = [rows1, (rows1 - diff)];
     end
   end

   %Validate the alignment results
   [matchmean, matchsdev] = find_stats(waves1, waves2, (gend(count)-gstart(count)), offset, ...
                                  (first(2)-first(1)), (sample(2)-sample(1)), 1000);
   disp(['     mean ssd over matches = ' num2str(matchmean)]);
   disp(['     std dev. over matches = ' num2str(matchsdev)]);
   count = count + 1;
end

if matchmean > (randmean - randstd_dev)
    disp('Failed to align three times...');
end

alignStruct.first  = first;
alignStruct.last   = last;
alignStruct.sample = sample;

%format = '    first = [%d,%d], last = [%d,%d], sample = [%d,%d], time = %d\n';
format = '     groove %3d sample %6d';
time = round(etime(clock,t0));
%disp(sprintf(format, first(1),first(2),last(1),last(2),sample(1),sample(2),time));
disp(sprintf(format, first(1), sample(1)));
disp(sprintf(format, first(2), sample(2)));
disp(['     alignment in ' num2str(time) ' seconds']);

disp(' ');

