function [img,aotf,psf,ADN]=Simulation3D(ADN,lambda,n,NA,pixelsize,magnification,N,zrange,dz,show)

%% sim_img : image simulée
% %% Refine cell size as cercle of  radius
radius=300; 
D = sqrt(sum((ADN - [0,0,0]).^2, 2));
p1=ADN(:,1);
p11=p1(D<radius);
p2=ADN(:,2);
p22=p2(D<radius);
p3=ADN(:,3);
p33=p3(D<radius);
clear ADN
ADN=[p11 p22 p33]; 


%% cell rotation : rotation de la nuage 3D autour x, y ou z aléatoirement choisi avec une angle qui est aléatoirment choisi
 angle=randi([0 360]);
% axis=randi([1 3]);
 
 [XYZnewx, R, t] = AxelRot(ADN', randi([0 360]), [1 0 0],[]); 
 [XYZnewy, R, t] = AxelRot(XYZnewx, randi([0 360]), [0 1 0],[]); 
 [XYZnewxyz, R, t] = AxelRot(XYZnewy, randi([0 360]), [0 0 1],[]); 

     
pts=XYZnewxyz'; %% rotated 3D point cloud




%% %% max interpolation
%en x
xmax=max(pts(:,1)); 
ptsx=(pts(:,1)./xmax).*(5); 
ptsx=(ptsx);
% interpolation en y
ymax=max(pts(:,2)); 
ptsy=(pts(:,2)./ymax).*(5); 
ptsy=(ptsy);

% interpolation en z
zmax=max(pts(:,3)); 
ptsz=(pts(:,3)./zmax).*5; 
ptsz=(ptsz);
clear ADN
ADN=[ptsx ptsy ptsz]; 
clear ptsx ptsy ptsz
%% min interpolation
% en x
xmin=min(pts(:,1)); 
ptsx=(pts(:,1)./xmin).*(-5); 
ptsx=(ptsx);
% interpolation en y
ymin=min(pts(:,2)); 
ptsy=(pts(:,2)./ymin).*(-5); 
ptsy=(ptsy);

%% interpolation en z
zmin=min(pts(:,3)); 
ptsz=(pts(:,3)./zmin).*(-5); 
ptsz=(ptsz);

clear ADN
ADN=[ptsx ptsy ptsz];


%% modélisation de PSF
[aotf,otf,psf,Nn,dxn,Nz,Nzn]=model_PSF(lambda,n,NA,pixelsize,magnification,N,zrange,dz,show);

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

 %% Création de l'image microscopique finale: 
disp('Creating 3D microscopy image');
img = zeros(N,N,Nz,'single'); 
ootf = fftshift(otf) .*points2img;
img = abs(ifftn(ootf,[N N Nz]));  
        
end