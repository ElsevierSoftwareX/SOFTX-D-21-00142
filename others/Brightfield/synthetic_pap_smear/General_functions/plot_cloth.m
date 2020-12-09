function plot_cloth( tri , positions, figure_no )
%PLOT_CLOTH Summary of this function goes here
%   Detailed explanation goes here

    figure(figure_no)
    coords = cat(1,positions{:,3});
    colormap gray;
    trimesh(tri,coords(:,1),coords(:,2),coords(:,3),zeros(size(coords,1),1));%repmat([0.3 0.3 0.3],size(tri,1),1))
    
    axis equal
end

