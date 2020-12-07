

 

%% Module 1: simulation nuage des points 

%% � la base le g�n�re que 16 chaines diff�rentes avec 100 configuration chacune,
% nous g�n�rons  des chaines  tel que plusieurs fois 16 avec diff�rentes config.  
%% d est le param�tre de la distribution uniform pour g�n�rer al�atoirement les distances entre les marqueurs
clc; close all; clear all;
distribfun = @() 100*rand(1,1);  % uniform : d*rand(1,1)
%distribfun = @() 50 + 25*randn(1,1);  % gaussian : mu + sigma*randn(1,1)
DC=46; %% max 100
[Chromatine,ADN]=chain_chrom(distribfun,DC); % Chromatine des cellules de coordonn�e x,y et z de chaque chaine de chromatine 
% Uncomment to visualize chaine de chromatine
figure;
for i=1:length(Chromatine) 
  ch=Chromatine{i};
  plot3(ch(:,1),ch(:,2),ch(:,3),'-k');
  xlabel('x');
  ylabel('y');
  zlabel('z');
 hold on 
end 
plot3(ADN(:,1),ADN(:,2),ADN(:,3),'.g','MarkerSize',7); % plot ADN sur chaine de chromatine

%% Module 2: Simulation de la microscope (cas widefield, sans bruit de poisson et flou de mouvement)
% Entr�e nuage de point 3D ADN +  param�tre d'objective 
% Sortie: image synth�tique 3D 


N=256;          % Points to use in FFT
pixelsize = 6.5;    % Camera pixel size
magnification = 60; % Objective magnification  %60
NA=1.1;         % Numerical aperture at sample
n=1.33;         % Refractive index at sample        % Refractive index at sample (water immersion n=1.33, dry n=1, oil n =1.51)
lambda=0.525;   % Wavelength in um
zrange=7;          % distance either side of focus to calculate  
dz=0.2;             % step size in axial direction of PSF (um)
radius=300;
prune=true;
[psf,dxn,Nz]=model_PSF(lambda,n,NA,pixelsize,magnification,N,zrange,dz);
[img,ADN]=Simulation3D(ADN,N,zrange, radius, prune, psf,dxn,Nz);

figure;
plot3(ADN(:,1),ADN(:,2),ADN(:,3),'.g','MarkerSize',7); % plot ADN sur chaine de chromatine
  xlabel('x');
  ylabel('y');
  zlabel('z');
disp(['DNA number is : ', num2str(size(ADN,1))]);

%% visualization

figure;
imshow(sum(img,3),[]);
figure;
imshow(squeeze(sum(img,2)),[]);

%% saving image stack
disp('saving image stack')
 filename=('simulated_stack.tif'); 
 delete(filename);
 for ii=1:size(img,3)
 % imwrite(uint16(65535* mat2gray(img(:,:,ii))),filename,'WriteMode','append'); 
 imwrite(uint8(255* mat2gray(img(:,:,ii))),filename,'WriteMode','append');
 end 

%% %% saving psf
disp('saving image PSF')
 filename=('PSF.tif'); 
 delete(filename);
 for ii=1:size(psf,3)
 % imwrite(uint16(65535* mat2gray(img(:,:,ii))),filename,'WriteMode','append'); 
 imwrite(uint8(255*  mat2gray(psf(:,:,ii))),filename,'WriteMode','append');
 end 