function c = calcCenter(pts)
% $Revision: 1.2 $ $Author: mmccann $
% c = calcCenter(pts): given a list of points in pts, calculate the
%                      center of the circle and the radius.
%                      c = [i j radius]
[rows cols] = size(pts);
if rows < 3
  error('must have at least 3 points to determine center of circle')
end
H = ones(rows,3);
H(:,2:3) = pts;
h = pts(:,1).^2 + pts(:,2).^2;
a = inv(H'*H)*H'*h;
c = zeros(3,1);
c(1) = a(2)/2;
c(2) = a(3)/2;
c(3) = sqrt(a(1)+c(1)^2+c(2)^2);
