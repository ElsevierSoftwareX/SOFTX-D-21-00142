function [texture,mask] = generate_cytoplasm_texture(raw_shape)

%% Setup

% addpath ../../General_functions/

% TEMPORARY CODE, WILL REMOVE WHEN RESTRUCTURED TO FUNCTION

% addpath ../Shape/
% raw_shape = generate_cytoplasm_shape();

%% Constants

CLOTHSIM_RES = 75;  % For cloth simulation
MAX_ITER = 60;      % For cloth simulation
ALPH = 0.1;         % Alpha value for the clothsim

%% Generate the initial cloth object coordinates

% Do some measurements on the generated shape
msr = measure(raw_shape,[],{'Radius','Center'});
radius = msr.radius(1);
center = msr.center;

% Create the base cloth shape (right now a circle)
cloth = [1.03*radius*cos(linspace(0,2*pi,CLOTHSIM_RES+1));1.03*radius*sin(linspace(0,2*pi,CLOTHSIM_RES+1))];
cloth = cloth([2 1],1:end-1)';

%% Reduce the resolution of the target shape

% Get the boundary coordinates of the target shape
shape_boundary = calculate_boundary(raw_shape);
shape_boundary = [shape_boundary(:,2) shape_boundary(:,1)]-3; % -3 to compensate for offset added in calculate_boundary

% Translate to [0 0] and reduce the number of boundary coordinates 
shape_boundary = shape_boundary - repmat(center',size(shape_boundary,1),1);
sub_ind = round(linspace(1,size(shape_boundary,1),CLOTHSIM_RES+1));
shape_boundary = shape_boundary(sub_ind(1:end-1),:);

%% Match the indeces of the cloth and target shapes [IMPORTANT]

[~,ind] = min(pdist2(shape_boundary(1,:),cloth));
cloth = circshift(cloth,-(ind-1));

%% Run the cloth simulator
[tri,simmed_cloth] = clothsim(shape_boundary,cloth,MAX_ITER);

%% Draw the result to generate texture and mask

% Setup a hidden figure and plot the mesh
fig = figure('visible','off'); % fig = figure('visible','on');
set(fig,'paperpositionmode','auto')
TR = TriRep(tri,cat(1,simmed_cloth{:,3}));

tm = trisurf(TR);
set(tm,'EdgeColor','none','FaceColor','interp')
% set(tm,'EdgeColor',[0.2 0.2 0.2],'FaceColor','interp') % remove
alpha(tm,ALPH); % Transparancy

axis equal;grid off;axis off;
set(gca,'CameraPosition',[0 0 100],'CameraTarget',[0 0 0],'CameraUpVector',[0 -1 0]);

% Setup colors for base texture image
colormap(1-colormap(gray));
set(fig,'color',[1 1 1])

% Get the rendered texture

print(fig,'Data/cytoplasmtmp','-dpng','-r0','-opengl');
cdata = imread('Data/cytoplasmtmp.png');
delete('Data/cytoplasmtmp.png')

graymap = cdata(:,:,1);

% Setup colors for mask image
set(fig,'color',[0 0 0])
colormap(min(colormap(gray)+1,1));
alpha(tm,1);

% Get the rendered mask
set(fig,'InvertHardcopy','off')
print(fig,'Data/cytoplasmtmp','-dpng','-r0','-zbuffer');
cdata = imread('Data/cytoplasmtmp.png');
delete('Data/cytoplasmtmp.png')
mask = cdata(:,:,1);

% Store the final results

graymap = dip_image(graymap);
mask = dip_image(mask);

% Close the figure IMPORTANT
close(fig)

%% Scale the result to match input

% Measure new mask
msr = measure(mask>0,[],'radius');
ratio = radius / msr.radius(1);

% Rescale result
base = resample(graymap,ratio*[1 1],0,'linear');
mask = resample(mask,ratio*[1 1],0,'zoh')>0;

%% Do postprocessing on the base result

basetex = 255-base; % Invert
% basetex = basetex*(absorbance/max(basetex));
basetex = basetex/max(basetex);

n1 = noise(newim(size(mask)),'brownian',1);
n1(n1<0)=0;
% n1 = (absorbance/max(n1))*n1;
n1 = n1/max(n1);

n2 = gaussf(noise(newim(size(mask)),'gaussian',1),7);
n2 = n2 + abs(min(n2));
n2 = n2 / max(n2);
% n2 = (absorbance/max(n2))*n2;

n3 = voronoi_texture(mask,300,15);
% n3 = (absorbance/max(n3))*n3;

texture = (1.2*basetex+0.7*n1+0.2*n2+0.3*n3)*mask;

%% Crop the result

C = findcoord(mask);
cmin = min(C);cmax = max(C);
mask = mask(cmin(1):cmax(1),cmin(2):cmax(2));
texture = texture(cmin(1):cmax(1),cmin(2):cmax(2));
