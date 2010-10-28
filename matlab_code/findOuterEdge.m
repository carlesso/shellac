function pts = findOuterEdge(n)
% pts = findOuterEdge(n): returns a list of n points corresponding
% to the outer edge of the record.  Input image files are assumed
% to be in a standard orientation.  By default n is 1/3 of pixels
global Grecord

[rows cols] = size(Grecord);
if nargin < 1
  n = ceil(cols/3);
end
pts = zeros(n,2);

white = 255;
done = 0;
j = 1;
i = 1;
pts_cnt = 1;
for j = 1:floor(cols/n):cols
  while ~done
    if Grecord(i,j)<white
      pts(pts_cnt,:) = [i,j];
      pts_cnt = pts_cnt+1;
      done = 1;
    end
    if i==rows
      done = 1;
    end
    i = i+1;
  end
  done = 0;
  i = 1;
end


    