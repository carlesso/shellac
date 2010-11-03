function create_song(first_bun,last_bun)
% $Revision: 1.3 $ $Date: 2004/05/10 02:13:50 $ $Author: mmccann $
global Gmaster Galigns Gall_waves Gdir Gnum_scans

buns = first_bun:last_bun;
num_buns = length(buns);
samples = 0;
for i=buns
  samples = samples + max_bundle_size(i);
end
Gmaster = zeros(1,samples);  % pre-allocate Gmaster
mwLast = 0; % the last position written to. 

% find first sector and groove
[secCur grCur] = find_bundle_begin(buns(1));
% Initialize Gmaster with this sector and groove
load_aligns(buns(1));
load_waves(buns(1));
len = length(Gall_waves(secCur).waves);  % length of wave block
Gmaster(mwLast+1:mwLast+len) = Gall_waves(secCur).waves(grCur,:);
mwLast = mwLast+len;
[secPre grPre secCur grCur] = incSecGr(secCur, grCur);

for i=buns
  % we assume that Gmaster has been initialized.
  load_aligns(i);
  load_waves(i);

  % Calculate the Starting Point
  if (i == buns(1))
    % We are first and therefore the starting point is already initialized
  else
    % We are not first so we can use secNextOne and grNextOne as a starting
    % point.  We must also calculate secPre and grPre
    [secPre grPre secCur grCur] = incSecGr(secNextOne,grNextOne);
  end
  
  % Calculate the Stopping Point
  if (i ~= buns(end))
    % we know that we are not the end and we should therefore use the jump
    % alignment information for the stopping point.
    S = load(sprintf('%s/%d.jump.mat',Gdir,i));
    secLastT = 1;
    grLastT = S.groove(1);
    secNextOne = 1;
    grNextOne = S.groove(2);
    % we must also make sure that we can get to this position.  We might have
    % to subtract a bit from these values.
    [tempSec tempGr] = find_bundle_end(i);
    while tempSec ~= 1
      [blah blah tempSec tempGr] = incSecGr(tempSec, tempGr);
    end
    tempGr = tempGr - 1; % max acceptable last groove
    if tempGr < grLastT
      %disp(sprintf('need to modify last groove and first groove...'));
      delta = grLastT - tempGr;
      grLastT = grLastT - delta;
      grNextOne = grNextOne - delta;
    end
  else
    % we are last and should therefore terminate at the very end of the
    % bundle.
    [secLastT grLastT] = find_bundle_end(i);
  end
  % Calculate stopping condition (we stop before this point)
  [blah blah secLast grLast] = incSecGr(secLastT, grLastT);
  %disp(sprintf('bun %d stoping point: secLast %d grLast %d',i,secLast,grLast));

  done = 0;
  while ~done
    if (secCur == secLast) & (grCur == grLast)
      done = 1;
    else
      % we are not done so copy next chunk
      % disp(sprintf('bun %d, secCur %d, grCur %d',i,secCur,grCur));
      mwLast = copyChunk(secPre,grPre,secCur,grCur,mwLast);
      % increment sector and groove counters
      [secPre grPre secCur grCur] = incSecGr(secCur,grCur);
    end
  end
end
% trim Gmaster
Gmaster = Gmaster(1:mwLast);


function [secPreN,grPreN,secCurN,grCurN] = incSecGr(secCur,grCur)
% increment the current sector and groove
global Gnum_scans Galigns
secPreN = secCur;
grPreN = grCur;
secCurN = mod(secCur,Gnum_scans)+1;
grCurN = grCur + (Galigns(secCur).first(2) - Galigns(secCur).first(1));

function mwLastNext = copyChunk(secPre,grPre,secCur,grCur,mwLast)
global Galigns Gall_waves Gmaster
wavePre = Gall_waves(secPre).waves(grPre,:);
waveCur = Gall_waves(secCur).waves(grCur,:);
alignPre = Galigns(secPre);
alignCur = Galigns(secCur);

% perform crossfading in the overlap region
overPre = wavePre(end-alignPre.sample(2)+1:end);
overPre = overPre - mean(overPre);
%powPre = sum(overPre.^2);
overCur = waveCur(1:alignPre.sample(2));
overCur = overCur - mean(overCur);
%powCur = sum(overCur.^2);
n = 200; % cross-fade region
window = (0:n-1)/(n-1);
crossFade = (window.*overCur(end-n+1:end)...
	     + fliplr(window).*overPre(end-n+1:end));
% apply cross-fade to Gmaster
Gmaster(mwLast-n+1:mwLast) = crossFade;

chunk = waveCur(alignPre.sample(2):alignCur.sample(1));
% copy chunk to Gmaster
Gmaster(mwLast+1:mwLast+length(chunk)) = chunk;
mwLastNext = mwLast+length(chunk);


function [sec, gr] = find_bundle_begin(bundle)
% [sec groove] = find_bundle_begin(bundle) - returns the first
%   sector and groove of the bundle.
global Gdir Galigns Gall_waves
load_aligns(bundle)
load_waves(bundle)

G = Galigns; % shorter name for convenience

num_sectors = length(G);
sec_cur = 1;
sec_pre = num_sectors;
gr_cur = round(G(sec_cur).last(1)/2);
delta_pre = G(sec_pre).first(2) - G(sec_pre).first(1);
gr_pre = gr_cur - delta_pre;

done = 0;
while ~done
  [rows cols] = size(Gall_waves(sec_cur).waves);
  if gr_pre < 1
    done = 1;
    sec = sec_cur;
    gr = gr_cur;
  else
    test = Gall_waves(sec_pre).waves(gr_pre,1);
    gr_cur = gr_pre;
    sec_cur = sec_pre;
    delta = G(mod(sec_pre-2,num_sectors)+1).first(2)...
	    - G(mod(sec_pre-2,num_sectors)+1).first(1);
    gr_pre = gr_pre - delta;
    sec_pre = mod(sec_pre-2,num_sectors) + 1;
  end
end


function [sec, gr] = find_bundle_end(bundle)
% [sec groove] = find_bundle_end(bundle) - returns the last
%   sector and groove of the bundle.
global Gdir Galigns Gall_waves
load_aligns(bundle)
load_waves(bundle)

G = Galigns; % shorter name for convenience

num_sectors = length(G);
sec_cur = 1;
sec_pre = num_sectors;
gr_cur = round(G(sec_cur).last(1)/2);
delta_pre = G(sec_pre).first(2) - G(sec_pre).first(1);
gr_pre = gr_cur - delta_pre;

done = 0;
while ~done
  [rows cols] = size(Gall_waves(sec_cur).waves);
  if gr_cur > rows
    done = 1;
    sec = sec_pre;
    gr = gr_pre;
  else
    gr_pre = gr_cur;
    sec_pre = sec_cur;
    delta = G(sec_cur).first(2) - G(sec_cur).first(1);
    gr_cur = gr_cur + delta;
    sec_cur = mod(sec_cur,num_sectors) + 1;
  end
end


function samples = max_bundle_size(bundle)
% samples = max_bundle_size(bundle):
%   gives the maximum possible size of samples contained
%   in the entire bundle.
global Gnum_scans Gall_waves
load_waves(bundle);
samples = 0;
for i=1:Gnum_scans
  samples = samples + size(Gall_waves(i).waves,1)* ...
	    size(Gall_waves(i).waves,2);
end
