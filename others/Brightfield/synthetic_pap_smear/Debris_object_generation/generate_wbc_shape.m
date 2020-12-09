function [wbc,wbc_size] = generate_wbc_shape(WBC_diam,resolution)

% WBC diameter ~3 um measured from image
s = 0.15; % Magic number used to scale randomness in size
diameter = WBC_diam/resolution;

% Create the shape
base_shape = rr([diameter diameter]*2)<=diameter/2;
image_size = size(base_shape);
[signal,scale] = fsd_special(base_shape,inf);

% Distort the shape

re = real(signal);
im = imag(signal);
w = exp(rr(size(re)));
w(0) = 0;
w = double(w/max(w))';
% s = std([re(3:end);im(3:end)]);

new_shape = (re+s*w.*randn(size(re)))+1j*(im+s*w.*randn(size(im)));
new_shape = new_shape ./ abs(new_shape(2));

% Reconstruct the shape
new_shape = ifft(new_shape);
new_shape = [real(new_shape) imag(new_shape)];
new_shape = new_shape.*scale;
c = coord2image(round(new_shape+(image_size(1)-1)/2),image_size);
wbc = fillholes(bskeleton(bdilation(c,2)));

% Crop the image
C = findcoord(wbc);
wbc = wbc(min(C(:,1)):max(C(:,1)),min(C(:,2)):max(C(:,2)));
wbc_size = size(wbc);

