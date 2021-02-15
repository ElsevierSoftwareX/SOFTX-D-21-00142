function ADN=inter_inFOV(ADN, cell_size, radius, prune)
% prune - logical (optional) : if true, we will cut everything further from the center
if nargin < 3
    radius = 300;
end
if nargin < 4
    prune=true;
end
%% sim_img : image simul�e
% %% Refine cell size as cercle of  radius
if prune
    D = sqrt(sum((ADN - [0,0,0]).^2, 2));
    ADN=ADN(D<radius,:); 
end

%% cell rotation : rotation de la nuage 3D autour x, y ou z al�atoirement choisi avec une angle qui est al�atoirment choisi 
 [XYZnew, ~, ~] = AxelRot(ADN', randi([0 360]), [1 0 0],[]); 
 [XYZnew, ~, ~] = AxelRot(XYZnew, randi([0 360]), [0 1 0],[]); 
 [XYZnew, ~, ~] = AxelRot(XYZnew, randi([0 360]), [0 0 1],[]); 
     
pts=XYZnew'; %% rotated 3D point cloud
%% %% max interpolation
if prune
    maxes = max(abs(pts));
else
    maxes = [radius,radius,radius];
end
ADN = pts./maxes.*cell_size;
end 