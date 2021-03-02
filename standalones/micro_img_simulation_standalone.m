function micro_img_simulation_standalone(dna_csv,lambda,n,NA,pixelsize, ...
    magnification,N,zrange,dz,tau,nphot,Var_GN,Mean_GN,Cell_speed, ...
    shutter_speed, frame_rate, fwhmz, microscope, output_files_prefix, seed, ...
    streamIndex, numStreams)
% Calls Micro_img_simulation and store outputs in a .mat and three .tif files
% This is meant to be packaged as a standalone application
% INPUTS:
% dna_csv : a .csv file containing coordinates of the 3D
% point cloud (interpolated to fit between -5 and 5 in X and Y). This can
% be produced by chain_chrom_standalone.
% lambda: emission wavelength (um)
% n : refractive index (immersion medium of the objective)
% NA : numerical apperture
% pixelsize: camera pixel size (um)
% magnification: objective magnification
% N: ouput image xy dimensions
% zrange: distance either side of focus to calculate 
% dz : step size in axial direction of PSF (um)
% tau : Average bleaching time (s) ,
% characteristic of fluofore. If 0, no photobleaching.
% nphot : expected number of photons at brightest points in image (param of
% poisson noise): shot noise. If 0, no Poisson noise
% Var_GN:  values of STD  of additive gaussian noise (thermal and read background noise)
% Mean_GN; values of Meanof additive gaussian noise (thermal and read background noise) should be of low values
% If Mean_GN AND Var_GN are 0, no Gaussian noise.
% Cell_speed: % cell speed inside microfluidic system um/s. If 0, no motion
% blur
% shutter_speed:  % caracteristic of camera (1/shutter_spee en s). Not used
% if Cell_speed is 0.
% microscope: for microscopy type:
%   microscope=1 : widefield (WF) (Fast),
%   microscope=2 confocal (CF) (a litle bit slow: nyquest samplate rate is smaller then the case of WF
%   microscope=3 2 beam SIM  ( 3 phase shift) (Fast)
%   microscope=4 3 beam SIM (very slow due to 7 phase shift) 
% fwhmz: Full width half maximum of PSF in z for light sheet microscopy.
% Should be 0 if light-sheet is not used. Available only for widefield and
% SIM
% output_files_prefix - path to the output files to save will be of the
% form: output_files_prefix + ".mat" for the .mat file containing 'img' ,'
% GT' and 'psf' the matrices of microscopy image stack, ground truth image
% stack (no nise or diffraction) and PSF image stack respectively;
% output_files_prefix + "img.tif", output_files_prefix + "GT.tif" and
% output_files_prefix + "psf.tif" for the correspoding images exported in
% TIF file format.


if nargin < 18
    rng('shuffle')
else
    if isstring(seed) || ischar(seed)
        seed = str2double(seed);
    end
    if isstring(streamIndex) || ischar(streamIndex)
        streamIndex = str2double(streamIndex);
    end
    if isstring(numStreams) || ischar(numStreams)
        numStreams = str2double(numStreams);
    end
    randStr = RandStream.create('mlfg6331_64','NumStreams',numStreams, ...
        'Seed', seed, 'StreamIndices', streamIndex);
    RandStream.setGlobalStream(randStr)
end

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
if isstring(tau) || ischar(tau)
    tau = str2double(tau);
end
if isstring(nphot) || ischar(nphot)
    nphot = str2double(nphot);
end
if isstring(Var_GN) || ischar(Var_GN)
    Var_GN = str2double(Var_GN);
end
if isstring(Mean_GN) || ischar(Mean_GN)
    Mean_GN = str2double(Mean_GN);
end
if isstring(Cell_speed) || ischar(Cell_speed)
    Cell_speed = str2double(Cell_speed);
end
if isstring(shutter_speed) || ischar(shutter_speed)
    shutter_speed = str2double(shutter_speed);
end
if isstring(frame_rate) || ischar(frame_rate)
    frame_rate = str2double(frame_rate);
end
if isstring(microscope) || ischar(microscope)
    microscope = str2double(microscope);
end
if isstring(fwhmz) || ischar(fwhmz)
    fwhmz = str2double(fwhmz);
end
% Convert tau in frames
tau = tau * shutter_speed;
markers_scaled = csvread(dna_csv);
% Run application
[img,GT,psf] = Micro_img_simulation(markers_scaled, lambda, n, NA, ...
    pixelsize, magnification, N, zrange, dz, tau, nphot, Var_GN, ...
    Mean_GN, Cell_speed, shutter_speed, frame_rate, microscope, fwhmz);
save(output_files_prefix + ".mat", 'img', 'GT', 'psf')
%% saving simulated image stacks
disp('saving simulated microscope image')
mat2tif(output_files_prefix + "img.tif", img)
%% saving psf
disp('saving PSF image stack')
mat2tif(output_files_prefix + "psf.tif", psf)
%%  saving GT
disp('saving Ground truth image stack')
mat2tif(output_files_prefix + "GT.tif", GT)