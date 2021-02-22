function [ADN]=inter_inFOV(ADN,cell_size)
%% sim_img : image simulée
% %% Refine cell size as cercle of  radius
radius=350;
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
 anglex=randi([0 360]);
 angley=randi([0 360]);
 anglez=randi([0 360]);
% axis=randi([1 3]);
 
 [XYZnewx, R, t] = AxelRot(ADN', anglex, [1 0 0],[]); 
 [XYZnewy, R, t] = AxelRot(XYZnewx, angley, [0 1 0],[]); 
 [XYZnewxyz, R, t] = AxelRot(XYZnewy, anglez, [0 0 1],[]); 

  
pts=XYZnewxyz'; %% rotated 3D point cloud

%% %% max interpolation
maxes = max(abs(pts));
ADN = pts./maxes.*(cell_size); % une seule interpolation de sorte que sur chaque axe la valeur absolue la plus grande soit à 5 (ou -5)

end 
