function ADN=inter_inFOV(ADN)
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
end 