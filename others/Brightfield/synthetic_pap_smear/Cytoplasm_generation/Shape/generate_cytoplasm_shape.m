function created = generate_cytoplasm_shape(RESOLUTION,size_offset)

% RESOLUTION remains unincorporated yet but it is a simple matter to relate
% to the resolution of the source data with a simple fraction

% Set paths and load 
% addpath ../../General_functions/
load cytoplasm_shapes % Assumes ../../Data in path

% Parameters
image_size = ceil(sqrt(max(scalings*size_offset)/pi)*[3 3]);
scale = mean(scalings);

% Calculate the means and std of the shapes in the repository
real_mean = mean(real(shapes));
imag_mean = mean(imag(shapes));
real_std = std(real(shapes));
imag_std = std(imag(shapes));

% Prepare the new shape

% Generate a new shape
new_shape = (real_mean + real_std.*randn(size(real_std)))+1j*(imag_mean + imag_std.*randn(size(imag_std)));

% % Test of new way to generate shape
% real_min = min(real(shapes));
% real_max = max(real(shapes));
% imag_min = min(imag(shapes));
% imag_max = max(imag(shapes));
% 
% new_shape = (real_min +(real_max-real_min).*rand(size(real_min)))+1j*(imag_min+(imag_max-imag_min).*rand(size(imag_min)));

% Return to spacial domain
new_shape = ifft(new_shape);
new_shape = [real(new_shape)' imag(new_shape)'];

% Now scale the coordinates
new_shape = new_shape.*scale*size_offset;
c = coord2image(round(new_shape+(image_size(1)-1)/2),image_size);

dilation_rate = 2;
created = fillholes(bskeleton(bdilation(c,dilation_rate)));

% while ~created(round(image_size(1)/2),round(image_size(2)/2))
%     dilation_rate = dilation_rate + 1;
%     created = fillholes(bskeleton(bdilation(c,2)));
% end
% shape_image = generate_boundary(round(new_shape+(image_size(1)-1)/2),image_size)
% arrangeslices(created,3)
