function out = do_gaussian1d(in, del)
global g

[dummy width] = size(in);

sz = floor(del*2.5);

g = [-sz:sz];
g = exp(-g.^2/del^2);
g = g/sum(g);

out = zeros(1,2*sz + width);
out(sz+1:sz+width) = in;

% flip the edges
for i=1:sz
	out(i) = out(2*sz-i+2);
	out(2*sz+width+1-i) = out(width+i-1);
end

out = filter2(g, out, 'valid');


