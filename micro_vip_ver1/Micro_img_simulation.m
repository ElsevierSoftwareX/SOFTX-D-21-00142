function [img,VT,psf]=Micro_img_simulation(ADN,lambda,n,NA,pixelsize,magnification,N,zrange,dz,tau,nphot,Var_GN,Mean_GN,Cell_speed,shutter_speed,microscope)


%% modélisation de PSF
if microscope~=4
if microscope==1
    disp('Simulating WF PSF model');
[otf,psf,Nn,dxn,Nz,Nzn]=model_PSF_WF(lambda,n,NA,pixelsize,magnification,N,zrange,dz);
elseif microscope==2
    disp('Simulating CF PSF model');
[otf,psf,Nn,dxn,Nz,Nzn]=model_PSF_CF(lambda,n,NA,pixelsize,magnification,N,zrange,dz);
elseif microscope==3
       disp('Simulating LSF 2 beam PSF model');
[otf,psf,Nn,dxn,Nz,Nzn]=model_PSF_2B_LSF(lambda,n,NA,pixelsize,magnification,N,zrange,dz);
end 
%% conversion de  la nuages do point dans une image en espace de fourier
disp('Creating image of 3D point cloud');
xyrange = Nn/2*dxn;
dkxy = pi/xyrange;
kxy = -Nn/2*dkxy:dkxy:(Nn/2-1)*dkxy;
dkz = pi/zrange;
kz = -Nzn/2*dkz:dkz:(Nzn/2-1)*dkz;

points2img=complex(single(zeros(Nn,Nn,Nzn))); % images des points en espace de fourrier
pxyz = complex(single(zeros(Nn,Nn,Nzn)));     
for it = 1:size(ADN,1)
     x=ADN(it,1);
     y=ADN(it,2);
     z=ADN(it,3); 
        
     px = exp(1i*single(x*kxy));
     py = exp(1i*single(y*kxy));
     pz = exp(1i*single(z*kz)); 
     pxy = px.'*py;
        
        for ii = 1:length(kz)
            pxyz(:,:,ii) = pxy.*pz(ii); 
        end
        points2img = points2img+pxyz;      
 end
%% GT
VT=fftshift(abs(ifftn(points2img,[N N Nz])));
 %% Création de l'image microscopique finale: 
disp('Creating 3D microscopy image');
img = zeros(N,N,Nz,'single'); 
ootf = fftshift(otf) .*points2img;
img = abs(ifftn(ootf,[N N Nz]));  
%%
end 
if microscope==4
     disp('Simulating LSF 3 beam PSF model');
    [img,VT,psf,dxn]=model_LSF_3beam(ADN,lambda,n,NA,pixelsize,magnification,N,zrange,dz);
end 

%% photobleaching
disp('Adding photo bleaching...');
parfor it=1:size(img,3)
    img(:,:,it) =img(:,:,it)*exp(-(it-1)/tau);
end 


%% adding motion blur effect % always before poisson and gaussian noise addition

shutter_speed=1/shutter_speed; 
mbz_um=Cell_speed*shutter_speed; % motion blur size 

mbz_px=ceil(mbz_um/dxn);  
orient=randi([0 180],1); % orientation de motion blur 
MB=fspecial('motion',mbz_px,130); 
disp(['Adding motion blur. Pixel length is ',num2str(mbz_px),' pixels']);% and orientation is ',num2str(orient)]);
parfor it=1:size(img,1)
    img(it,:,:)=conv2(squeeze(img(it,:,:)),MB,'same');  
end 
 
%% Add poisson noise and recalculate, uncomment to simulate noisy data % always before gaussian noise
disp('Adding poisson noise...');
img = poissrnd(img*nphot);
 
 %%   add gaussian noise (thermal and read noise) 
 disp('Adding thermal and read noise...');
 parfor it=1:size(img,3)
     img(:,:,it) = img(:,:,it)+abs(normrnd(Mean_GN,Var_GN,N,N));
 end 



end