function [t,cloth] = clothsim(target_shape,cloth_shape,max_iter)
%CLOTH_SIMULATION - Does a very specific cloth simulation for cytoplasm
%generation
%   INPUTS: * 2 Nx2 arrays with coordinates. Centered at [0,0]
%           * Maximum number of iterations
%           * alpha value for the texture

%% COPYRIGHT COMMENT
% This code uses the DistMesh toolbox created by Per-Olof Persson. The code
% is published and described in "Per-Olof Persson and Gilbert Strang, A 
% Simple Mesh Generator in MATLAB, SIAM Review Vol. 46 (2) 2004."

%% Global constants (could be changed depending on application needs)

DAMPING = 0.1; % how much to dampen the cloth simulation each frame
TIME_STEPSIZE2 = 0.7^2; % how large time step each particle takes each frame
CONSTRAINT_ITERATIONS = 2; % how many iterations of constraint satisfaction each frame (more is rigid, less is soft)
MAX_ITER = max_iter; % Self-explanatory
NO_POINTS = size(cloth_shape,1); % Number of cordinates in the shapes
RADIUS = max(abs(cloth_shape(:))); % Radius of the cloth object

%% Do the tasselation of the cloth shape using distmesh library written by Per-Olof Persson

% Set some parameters for the tasselation
extreme = max(abs(cloth_shape(:)));
edge_length = 2*pi*extreme/NO_POINTS;

% Do tasselation, get vertices and triangles
fd=@(p) sqrt(sum(p.^2,2))-extreme;
[p,t]=distmesh2d(fd,@huniform,edge_length,extreme*[-1,-1;1,1]+1,cloth_shape);

%% Initialize and populate variables needed for the cloth simulation

% Cloth and constraints variables
constraints = {}; % p1, p2, restdist (the springs)
cloth = cell(size(p,1),5); % Movable, mass, pos, oldpos, acceleration

% Populate the cloth and constraints variables
for ii = 1 : size(p,1)
    % Adding vertex information, random z-position U[0,1] added
    zp = rand(1,1);
    cloth(ii,:) = {true,1,[p(ii,:) zp],[p(ii,:) zp],[0 0 0]};
    
    % Add constraints for the vertex. Starting by locating the neighbours in
    % the mesh
    [r,~] = find(t==ii);
    u = unique(t(r,:));
    u(u == ii) = [];
    
    % Add constraints (the distances between the points that need to be
    % maintained) for vertex
    for jj = 1 : length(u)
        constraints(end+1,1:3) = {ii,u(jj),pdist2(p(ii,:),p(u(jj),:))}; %#ok
    end
end

% Initialize the deformation object variable. This is essentially the cloth
% shape, slightly enlarged, with an infinite height. It is used to compress
% the cloth object
deform = cell(NO_POINTS,3); % pos, oldpos, acceleration
for ii = 1 : NO_POINTS
    deform(ii,:) = {1.03*cloth_shape(ii,:),1.03*cloth_shape(ii,:),zeros(1,2)};
end


%% Main simulation loop

counter = 1; % Using while loop if I ever want to implement stopping criterion
while counter <= MAX_ITER
    % Set the acceleration for the deformation mesh. Currently it's set to
    % the vector to the corresponding target position divided with the
    % radius of the initial cloth object
    for ii = 1 : NO_POINTS
        v = target_shape(ii,:) - deform{ii,1};
        deform{ii,3} = v/RADIUS;
    end
    
    % Make sure all constraints are satisfied, this is iterated.
    for jj = 1 : CONSTRAINT_ITERATIONS
        for ii = 1 : size(constraints,1)
            p1_to_p2 = cloth{constraints{ii,2},3}-cloth{constraints{ii,1},3};
            current_distance = norm(p1_to_p2,2);
            correctionVector = p1_to_p2*(1 - constraints{ii,3}/current_distance);
            correctionVectorHalf = correctionVector*0.5;
            
            % Apply corrections to both points in the dependancy
            if cloth{constraints{ii,1},1} % If movable
                cloth{constraints{ii,1},3} = cloth{constraints{ii,1},3} + correctionVectorHalf;
            end
            if cloth{constraints{ii,2},1} % If movable
                cloth{constraints{ii,2},3} = cloth{constraints{ii,2},3} - correctionVectorHalf;
            end
        end
    end
    
    % Apply the acceleration and velocity effects to the deformation
    % vertices
    for ii = 1 : NO_POINTS
        temp = deform{ii,1};
        deform{ii,1} = deform{ii,1} + (deform{ii,1}-deform{ii,2})*(1-DAMPING) + deform{ii,3}*TIME_STEPSIZE2;
        deform{ii,2} = temp;
        deform{ii,3} = [0 0]; % acceleration is reset since it HAS been translated into a change in position (and implicitely into velocity)
    end
    
    % Resolve collisions for cloth with floor and deform object
    cur_deform = cat(1,deform{:,1}); % For convenience
    for ii = 1 : size(cloth,1)
        % Check collision between point and deformation object
        p = [cloth{ii,3}(1),cloth{ii,3}(2)]; % Current point
        % Use pnpoly function to check if point is inside

        if ~inpolygon(p(1),p(2),cur_deform(:,1),cur_deform(:,2))
            % Not inside, find closest perpendicular edge

            ind = find_closest_edge(cur_deform,p);
            % Project onto that edge
            if ind == 1
                q = cur_deform(end,:);
            else
                q = cur_deform(ind-1,:);
            end
            r = cur_deform(ind,:);
            w = r-q;
            proj = (dot(w,p-q)/dot(w,w))*w; % Locate projection vector
            cloth{ii,3}(1) = q(1)+proj(1); % Do translation
            cloth{ii,3}(2) = q(2)+proj(2);
        end
        
        % Check ground plane collision
        if cloth{ii,3}(3) < 0
            cloth{ii,3}(3) = 0;
        end
    end
    
    counter = counter + 1;
    
end % while

end % function