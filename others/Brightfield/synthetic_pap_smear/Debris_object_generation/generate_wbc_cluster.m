function [wbc_cluster,wbc_cluster_mask] = generate_wbc_cluster(cluster_range,spread,absorbance,resolution)

% cluster_range = [3 5];
% pixel_size = 0.25; % um/px
wbc_diameter = 3; % um, measured from image data

% Determine the number of objects to generate
crange = cluster_range(1):cluster_range(2);
rp = randperm(length(crange));
no_obj = crange(rp(1));

% Create the canvas and pad it with max diameter
padval = wbc_diameter/resolution;
% wbc_cluster = newim(spread*[1 1]+padval*2);

% Create a weightmap in the form of a random blob for placement
W = generate_random_weightmap(spread)^2;                                              
W = extend(W^2,size(W)+padval*2);                   % Scale the weights and pad the results
% Get coordinates

% D = weighted_distribution(no_obj,spread*[1 1]+padval*2,W);
D = weighted_distribution(no_obj,size(W),W);
wbc_cluster = newim(W);

% Loop and place objects
for ii = 1 : no_obj
    [wbc,wbc_size] = generate_wbc_shape(wbc_diameter,resolution);
    x_bit = D(ii,1)-floor(wbc_size(1)/2):D(ii,1)+ceil(wbc_size(1)/2)-1;
    y_bit = D(ii,2)-floor(wbc_size(2)/2):D(ii,2)+ceil(wbc_size(2)/2)-1;
    wbc_cluster(x_bit,y_bit) = wbc_cluster(x_bit,y_bit) + wbc;
end

C = findcoord(wbc_cluster>0);
wbc_cluster = wbc_cluster(min(C(:,1)):max(C(:,1)),min(C(:,2)):max(C(:,2)));
wbc_cluster_mask = wbc_cluster>0;
% Add texture
noise = cut(perlin_noise(max(size(wbc_cluster))),size(wbc_cluster));
wbc_cluster = wbc_cluster * noise * absorbance;