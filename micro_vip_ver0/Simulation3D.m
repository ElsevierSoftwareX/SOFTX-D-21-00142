function [img,ADN]=Simulation3D(ADN,N,zrange, radius, prune, psf,dxn,Nz)
% prune - logical : if true, we will cut everything further from the center
% than radius before min and max interpolation. Else we will kep it but
% still interpolate as if mins were -300 and max were 300
% psf,dxn,Nz: outputs of model_PSF)
%% sim_img : image simul�e
% %% Refine cell size as cercle of  radius
if prune
    D = sqrt(sum((ADN - [0,0,0]).^2, 2));
    p1=ADN(:,1);
    p11=p1(D<radius);
    p2=ADN(:,2);
    p22=p2(D<radius);
    p3=ADN(:,3);
    p33=p3(D<radius);
    clear ADN
    ADN=[p11 p22 p33]; 
end

%% cell rotation : rotation de la nuage 3D autour x, y ou z al�atoirement choisi avec une angle qui est al�atoirment choisi
% axis=randi([1 3]);
 
 [XYZnewx, ~, ~] = AxelRot(ADN', randi([0 360]), [1 0 0],[]); 
 [XYZnewy, ~, ~] = AxelRot(XYZnewx, randi([0 360]), [0 1 0],[]); 
 [XYZnewxyz, ~, ~] = AxelRot(XYZnewy, randi([0 360]), [0 0 1],[]); 

     
pts=XYZnewxyz'; %% rotated 3D point cloud




%% %% max interpolation (map sphere to a a sphere of radius 5)
if prune
    maxes = max(abs(pts));
else
    maxes = [300,300,300];
end
ADN = pts./maxes.*5;


%% mod�lisation de PSF
Nn=size(psf,1);
Nzn=size(psf,3);
%% Calculate 3D-OTF
disp('Creating 3D OTF');
otf = fftn(psf);

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

 %% Cr�ation de l'image microscopique finale: 
disp('Creating 3D microscopy image');
ootf = fftshift(otf) .*points2img;
img = abs(ifftn(ootf,[N N Nz]));  
   
end