function Simulation3D_standalone(N, zrange, radius, prune, dna_mat, psf_mat, output_mat, img_tif)
% Calls Simulation3D and store outputs in a .mat file. Also allow saving of
% resulting image as a .tif file.
% This is meant to be packaged as a standalone application
% INPUTS:
% N - Points to use in FFT
% zrange - distance either side of focus to calculate (micrometers)
% radius - Radius of the cell (micrometers)
% prune - If true, fluorophores with a distance from center greater than
% radius will not appear in final image. If false they will, but for
% scaling purposes radius is still considered to be the size of the cell
% dna_mat - .mat file containing at least 'ADN', a matrix of fluorophores 
%coordinates (output of chain_chrom_standalone)
% psf_mat - .mat file containing at least 'psf', 'dxn' and 'Nz' (output of
% model_PSF_standalone)
% output_mat - path to the output .mat file to save variables
% img_tif (optional) - path to the output .tif generated image

% When calling standalone application, all parameters will be strings.
% Here we convert them
if isstring(N) || ischar(N)
    N = str2double(N);
end
if isstring(zrange) || ischar(zrange)
    zrange = str2double(zrange);
end
if isstring(radius) || ischar(radius)
    radius = str2double(radius);
end
if isstring(prune) || ischar(prune)
    prune = logical(str2double(prune));
end
load(dna_mat, 'ADN')
load(psf_mat, 'psf', 'dxn', 'Nz')

% Run application
[img,ADN]=Simulation3D(ADN,N,zrange, radius, prune, psf,dxn,Nz);
save(output_mat, 'img', 'ADN')

% Optional image saving
if nargin > 7
    if isfile(img_tif)
        % Overwrite image
        delete(img_tif);
    end
    for ii=1:size(img,3)
        imwrite(uint8(255* mat2gray(img(:,:,ii))),img_tif,'WriteMode','append');
    end 
end
