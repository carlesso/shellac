% Does a piecemeal Gaussian of the track_piece matrix
% $Revision: 1.4 $ $Author: nailon $
function do_gaussian(delta)

global track_piece;
global Gaussian

sz=floor(delta*2.5);
gaussian = [-sz:sz];
gaussian = exp(-gaussian.^2/(delta^2));
Gaussian = transpose(gaussian) * gaussian;
nrm = sum(sum(Gaussian))+.0;
Gaussian = Gaussian / nrm;

[h w] = size(track_piece);

for i=1:ceil((w-(2*sz))/1000)
	start = (i-1)* 1000+1;
	finish = i*1000;
	if (finish > w-2*sz)
		finish = w-(2*sz);
	end

	tmp_piece = uint8(filter2(Gaussian, track_piece(:,start:finish+2*sz), 'valid'));
	track_piece(1:end-2*sz,start:finish) = tmp_piece;
end
track_piece = uint8(track_piece(1:end-2*sz,1:end-2*sz));



