function [PSF,sim_img,ADN]=Simulation3D_simple(ADN,NA,n,lambda,Nxy,Nz,radius)

%% sim_img : image simulée
%% Refine cell size as cercle of  radius
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
 axis=randi([1 3]);
 if axis==1 
 [XYZnew, R, t] = AxelRot(ADN', angle, [1 0 0],[]); 
 end
 if axis==2
     [XYZnew, R, t] = AxelRot(ADN', angle, [0 1 0],[]); 
 end 
 if axis==3
    [XYZnew, R, t] = AxelRot(ADN', angle, [0 0 1],[]); 
 end 
     
pts=XYZnew';

%% positive 3D PC
a=min(pts(:,1)); 
pts(:,1)=pts(:,1)+abs(a)+1; 

a=min(pts(:,2));
pts(:,2)=pts(:,2)+abs(a)+1;

a=min(pts(:,3));
pts(:,3)=pts(:,3)+abs(a)+1;
pts=floor(pts);



%% interpolation en x
xmax=max(pts(:,1)); 
ptsx=(pts(:,1)./xmax).*(floor(Nxy/2)); 
ptsx=ceil(ptsx);
%% interpolation en y
ymax=max(pts(:,2)); 
ptsy=(pts(:,2)./ymax).*(floor(Nxy/2)); 
ptsy=ceil(ptsy);

%% interpolation en z
zmax=max(pts(:,3)); 
ptsz=(pts(:,3)./zmax).*Nz; 
ptsz=ceil(ptsz);
%% 
clear ADN
ADN=[ptsx ptsy ptsz]; 

disp(['ADN number is: ', num2str(size(ADN,1))]);
%% 
Ib=zeros(Nxy,Nxy,Nz); 
for it=1:size(ADN,1)
    
Ib(ADN(it,1)+floor(Nxy/4),ADN(it,2)+floor(Nxy/4),ADN(it,3))=1;
end 



%% Modeling 3D PSF for Widefield 
dx=0.1; % lateral scaling 
dz=0.2;
sigma_x=0.21*(lambda./NA);  % approximation to sigma in lateral
disp(['Lateral resolution is: ', num2str(sigma_x),' um']);
sigma_x=sigma_x./dx; 
sigma_y=sigma_x;

sigma_z=0.75*(n*lambda)/NA^2; % approximation to sigma in axial
disp(['Axial resolution is: ', num2str(sigma_z),' um']);
sigma_z=sigma_z/dz;

sigma=[sigma_x sigma_y sigma_z]; % define 3D sigma size
hsize=[2*ceil(2*sigma_x)+1 2*ceil(2*sigma_y)+1 2*ceil(2*sigma_z)+1]; %  kernel size 
PSF =fspecial3('gaussian',hsize,sigma); % generate 3D psf
 
 
 %% Convolution nuage de point avec 3D PSF
 sim_img = convn(Ib,PSF,'same');  
 
end