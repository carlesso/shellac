function L = find_diffs(A,B,mode)
%$Revision: 1.3 $ $Author: mmccann $ $Date: 2004/05/09 22:16:14 $
% L = find_diffs(A,B [,mode]) - returns an array of vectors of the small
% matrix A and a larger matrix B that represents the differences
% between the matrix A and all subregions of B that overlap with A.
% Each position in L contains the difference when the upper left-hand
% corner of A is aligned at that position in B.  Thus the dimensions
% of L will be (rows(A)-rows(B)+1) by (cols(A)-cols(B)+1) rows by 3
% columns in debugging mode.  In non debugging mode, there will be
% just one entry corresponding to the smallest returned.
%   mode = 0 - return the smallest difference postion only (default)
%   mode = 1 - return a sorted list of differences in ascending order

global GL

if nargin < 3
  mode = 0;
end

% calculate B2
[rows cols] = size(A);
S = ones(rows,cols);
B2 = filter2(S,B.^2,'valid');

% calculate sum over A squared
sumA2 = sum(sum(A.^2));

% calculate A conv B
AB = filter2(A,B,'valid');

% calculate D
D = (-2*(AB)+B2)+sumA2;

[rows cols] = size(D);
if mode
  tL = zeros(rows*cols,3);
  L = zeros(rows*cols,3);
  count = 0;
else
  L = [D(1,1) 1 1];
end
for i=1:rows
  for j=1:cols
    if mode
      count=count+1;
      tL(count,1:3) = [D(i,j) i j];
    else
      if D(i,j) < L(1,1)
	L = [D(i,j) i j];
      end
    end    
  end
end
if mode
  [Y I] = sort(tL(:,1));
  for i = 1:count
    L(i,1:3) = tL(I(i),1:3);
  end
end

if mode > 0
  GL = L;
end
