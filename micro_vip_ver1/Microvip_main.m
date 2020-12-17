clc; close all; clear all;

%% Module 1: simulation nuage des points   
% Param�tre � changer par l'utlisateur
% type : type de distribution, typ=1 uniform, type=2 gaussienne
% m et sig : param�tre des distributions pour g�n�rer al�atoirement les
% distances entre les marqueurs : si uniform : m=param, set sig=0,si gaussienne: param�tres (m,sig);
% param�tre � fixer par nous:
% DC is the number of chromatin chain
DC=46; %% max 100 , nb of chromatin chains
m=50;
sig=50; 
type=1; 
if type~=1 && type~=2
    disp('Type should be only:  1 for uniform , 2 for gaussian'); 
    return    
elseif type==1
    sig=0;
   [Chromatine,ADN]=chain_chrom(m,sig,DC,type); % Chromatine des cellules de coordonn�e x,y et z de chaque chaine de chromatine 
else 
  [Chromatine,ADN]=chain_chrom(m,sig,DC,type); % Chromatine des cellules de coordonn�e x,y et z de chaque chaine de chromatine 
end
% interpolate points : rotation and interpolation to FOV.
ADN=inter_inFOV(ADN);

%% Module 2: Simulation de la microscope : Approximation paraxial (without lambda of exitation)
% simulation de l'image microscopique avec tous les noises 
% tous les para�mtre sont � changer par l'utilisateur
%ADN : 3D point cloud
% lambda: longeurd'onde d'emission (um)
% n : refractive index (immersion medium of the objective)
% NA : numerical apperture
% pixelsize: camera pixel size en um
% magnification: objective magnification
% N: ouput image xy dimensions
% zrange: distance either side of focus to calculate 
% dz : step size in axial direction of PSF (um)
% tau : bleaching time constant, photobealching (1/tau en ms) , characteristic of fluofore
% nphot : expected number of photons at brightest points in image (param of poisson noise):shot noise
% Var_GN:  values of STD  of additive gaussian noise,% thermal and read background noise)
% Mean_GN; values of Meanof additive gaussian noise,% thermal and read background noise) should be of low values
% Cell_speed: % cell speed inside microfluidic system um/s
% shutter_speed:  % caracteristic of camera (1/shutter_spee en s)
% microscope: for microscopy type:
%microscope=1 : widefield (WF) (Fast),
% microscope=2 confocal (CF) (a litle bit slow: nyquest samplate rate is smaller then the case of WF
% microscope=3 LSF avec 2 beam  ( 3 phase shift) (Fast)
% microscope=4 LSF avec 3 beam (very slow due to 7 phase shift) 
%
% Sortie: img :image synth�tique 3D , VT: ground truth, PSF : point spread function

% parameters
N=256;          % Points to use in FFT
pixelsize = 6.5;    % Camera pixel size
magnification = 60; % Objective magnification  %60
NA=1.25;         % Numerical aperture at sample
n=1.33;         % Refractive index at sample        % Refractive index at sample (water immersion n=1.33, dry n=1, oil n =1.51)
lambda=0.5;   % Wavelength in um
zrange=5;          % distance either side of focus to calculate  
dz=0.3;             % step size in axial direction of PSF (um)
tau=100;       %% Average time before bleaching (tau) (in frames)
nphot = 100; % expected number of photons at brightest points in image (param of poisson noise):shot noise
Var_GN=0.5; % values of STD of additive gaussian noise,% thermal and read background noise)
Mean_GN=0; %values of Meanof additive gaussian noise,% thermal and read background noise)
Cell_speed=20; % cell speed inside microfluidic system um/s
shutter_speed=200;  % caracteristic of camera (frames/s)
microscope=3;
[img,VT,psf]=Micro_img_simulation(ADN,lambda,n,NA,pixelsize,magnification,N,zrange,dz,tau,nphot,Var_GN,Mean_GN,Cell_speed,shutter_speed,microscope);

%% XY , XZ : visualization

figure;
imshow(sum(img,3),[]);
title('Simulated image:XY plane projection');
figure;
imshow(squeeze(sum(img,2)),[]);
title('Simulated image: XZ plane projection');





%% saving simulated stack
name = ["WF","CF","LSF_2_beam","LSF_3_beam"];
disp('saving simulated image stack')
 filename=(['simulated_image_' ,name(microscope),' .tif']); 
 filename=strcat(filename(1),filename(2),filename(3));
 delete(filename);
 for ii=1:size(img,3)
 imwrite(uint16(65535* mat2gray(img(:,:,ii))),filename,'WriteMode','append'); 
 %imwrite(uint8(255* mat2gray(img(:,:,ii))),filename,'WriteMode','append');
 end 

%% saving psf
disp('saving PSF image stack')
 filename=(['PSF_', name(microscope), '.tif']); 
 filename=strcat(filename(1),filename(2),filename(3));
 delete(filename);
 for ii=1:size(psf,3)
  imwrite(uint16(65535* mat2gray(psf(:,:,ii))),filename,'WriteMode','append'); 
 %imwrite(uint8(255*  mat2gray(psf(:,:,ii))),filename,'WriteMode','append');
 end 
 
 
%%  saving GT
disp('saving Ground truth image stack')
 filename=(['GT_' ,name(microscope), '.tif']); 
 filename=strcat(filename(1),filename(2),filename(3));
 delete(filename);
 for ii=1:size(VT,3)
  imwrite(uint16(65535* mat2gray(VT(:,:,ii))),filename,'WriteMode','append'); 
 %imwrite(uint8(255*  mat2gray(VT(:,:,ii))),filename,'WriteMode','append');
 end 
 