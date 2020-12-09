% Generate nucleus shape
function nuc_shape = generate_nucleus_shape(RESOLUTION,size_offset,malignant)

%% Set paths and load reference data

% addpath ../../General_functions/
if ~malignant
    load nucleus_shapes.mat % Assumes ../../Data has been added to path
else
    load malignant_nucleus_shapes.mat
end

%% Set parameters

image_size = round(sqrt(max(1.5*scalings*size_offset)/pi)*[2 2]);
scale = mean(scalings);

%% Generate the shape

% Calculate the means and std of the shapes in the repository
real_mean = mean(real(shapes));
imag_mean = mean(imag(shapes));
real_std = 1.0*std(real(shapes));
imag_std = 1.0*std(imag(shapes));

% Generate a new shape
nuc_shape = (real_mean + real_std.*randn(size(real_std)))+1j*(imag_mean + imag_std.*randn(size(imag_std)));
nuc_shape(5:end-4) = 0;

% Return to spacial domain
nuc_shape = ifft(nuc_shape);
nuc_shape = [real(nuc_shape)' imag(nuc_shape)'];

% Scale the coordinates
nuc_shape = nuc_shape.*scale*size_offset;
c = coord2image(round(nuc_shape+(image_size(1)-1)/2),image_size);
nuc_shape = fillholes(bskeleton(bdilation(c,2)));
