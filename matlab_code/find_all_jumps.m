function time = find_all_jumps(bundle_vec)
%$Revision: 1.1 $ $Author: mmccann $ $Date: 2004/05/08 21:20:23 $
t0 = clock;
global Gdir
num_bundles = get_num_bundles;
S = load(sprintf('%s/song_struct.mat',Gdir));
song_struct = S.song_struct;
if nargin < 1
  bundle_vec = 1:num_bundles-1;
end

count = 0;
t = zeros(1,num_bundles-1);
for i=bundle_vec
  if count < num_bundles & i < num_bundles
    if song_struct(i) == song_struct(i+1)
      count = count+1;
      t(count) = i;
    end
  end
end

t = t(1:count);  % t contains a list of all bundles we should do
                 % alignment on.
		
disp(sprintf('bundle alignment (for sector 1):\n'));
for j=t
  t1 = clock;
  disp(sprintf('  alignment for bundle %d with %d:',j,j+1));
  j_struct = find_jump(j);
  groove = j_struct.groove;
  sample = j_struct.sample;
  filename = sprintf('%s/%d.jump.mat',Gdir,j);
  save(filename ,'groove','sample');
  format = '    groove = [%d,%d], sample = [%d,%d], time = %d\n';
  disp(sprintf(format, groove(1), groove(2), sample(1), sample(2), ...
	       round(etime(clock,t1))));
end

time = round(etime(clock,t0));


  

