function model_PSF_standalone(lambda,n,NA,pixelsize,magnification,N,zrange,dz, mat_file, img_psf)
% Calls model_PSF and store outputs in a .mat file. Also allow saving of
% PSF under .tif image.
% This is meant to be packaged as a standalone application
% INPUTS:
% lambda - Wavelength in micrometers.
% n - Refractive index at sample (water immersion n=1.33, dry n=1, oil n =1.51)
% NA - Numerical aperture at sample
% pixelsize - Camera pixel size
% magnification - Objective magnification
% N - Points to use in FFT
% zrange - distance either side of focus to calculate
% dz - step size in axial direction of PSF (micrometers)
% mat_file - path to the output .mat file to save variables
% img_psf (optional) - path to the output .tif image to save psf

rng('shuffle')
% When calling standalone application, all parameters will be strings.
% Here we convert them
if isstring(lambda) || ischar(lambda)
    lambda = str2double(lambda);
end
if isstring(n) || ischar(n)
    n = str2double(n);
end
if isstring(NA) || ischar(NA)
    NA = str2double(NA);
end
if isstring(pixelsize) || ischar(pixelsize)
    pixelsize = str2double(pixelsize);
end
if isstring(magnification) || ischar(magnification)
    magnification = str2double(magnification);
end
if isstring(N) || ischar(N)
    N = str2double(N);
end
if isstring(zrange) || ischar(zrange)
    zrange = str2double(zrange);
end
if isstring(dz) || ischar(dz)
    dz = str2double(dz);
end

% Run application
[psf,dxn,Nz]=model_PSF(lambda,n,NA,pixelsize,magnification,N,zrange,dz);
save(mat_file, 'psf', 'dxn', 'Nz')

% Optional image saving
if nargin > 9
    if isfile(img_psf)
        % Overwrite image
        delete(img_psf);
    end
    for ii=1:size(psf,3)
        imwrite(uint8(255* mat2gray(psf(:,:,ii))),img_psf,'WriteMode','append');
    end 
end


