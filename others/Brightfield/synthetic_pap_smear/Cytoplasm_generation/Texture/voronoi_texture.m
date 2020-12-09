% Voronoi based texture
% Implemented from:
% http://www-cs-students.stanford.edu/~amitp/game-programming/polygon-map-generation/

function texture = voronoi_texture(image,no_points,no_details)

imsz = size(image);
ITERATIONS = 2;     % For smoothing of voronoi diagram   
SPLIT_CHANCE = 0.2; % Branching probability
START_VALUE = 0.5;   % Minimum distance from edge for starting river

C = findcoord(image);
rp = randperm(size(C,1));
C = C(rp(1:no_points),:);

% Relax initial coordinates using Lloyd's algorithm to get a more even
% spacing

for ii = 1 : ITERATIONS
    % Monte Carlo detection of center in each cell
    rpoints = [(imsz(1)-1)*rand(2000,1) (imsz(2)-1)*rand(2000,1)];
    P = pdist2(rpoints,C);
    [~,ind]=min(P,[],2);
    for jj = 1 : no_points
        C(jj,:) = mean(rpoints(ind==jj,:));
    end
    
    % Handle empty points
    badind = any(isnan(C),2);
    if sum(badind)>0
        C(badind,:) = [];
        no_points = no_points - sum(badind);
    end
end

% Voronoi & Delaunay graphs
[vertices,cell_verts] = VoronoiLimit(C(:,1),C(:,2),[0 0;0 imsz(2)-1;imsz(1)-1 imsz(2)-1;imsz(1)-1 0;0 0]);

% Restructure graph information so we get the neighbours of each vertex
vertex_neigh = cell(size(vertices,1),1);
for ii = 1 : length(cell_verts)
    V = cell_verts{ii};
    if any(histc(V,unique(V))>1)
        V(end) = [];
    end
    V = [V(end) V V(1)]; %#ok
    for jj = 2 : length(V)-1
        N = [V(jj-1) V(jj+1)];
        if isempty(vertex_neigh{V(jj)})
            vertex_neigh{V(jj)} = N;
        else
            memb = ismember([V(jj-1) V(jj+1)],vertex_neigh{V(jj)});
            vertex_neigh{V(jj)}(end+1:end+sum(~memb)) = N(~memb);
        end      
    end
end

% Now create the "rivers" flowing downhill from the centre of the mask
height = dt(image);
height = height/max(height);
texture = newim(image,'bin');

rp = randperm(length(vertex_neigh));
added = 0;
ii = 1;
while added <= no_details
    D = round(vertices(rp(ii),:));
    if ~isempty(vertex_neigh{rp(ii)}) && height(D(1),D(2)) > START_VALUE
        texture = trace_river(rp(ii),height,round(vertices),vertex_neigh,texture,SPLIT_CHANCE);
        added = added + 1;
    end
    ii = ii + 1;
end

texture = texture * image;