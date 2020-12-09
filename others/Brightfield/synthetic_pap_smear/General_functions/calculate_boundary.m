function boundary = calculate_boundary(bimage)

% function boundary = calculate_boundary(bimage)
%
% Based on chain code script written by Cris Luengo. Directions are coded
% according to possible directions along an 8 connected boundary
%
%    3 2 1
%     \|/
%    4-@-0
%     /|\
%    5 6 7
%
% The output is the coordinates of the boundary pixels calculated from one 
% lap around the edge of the object (clockwise). Input is a bindary object
%
% Link to Cris' blog entry:
% http://www.cb.uu.se/~cris/blog/index.php/archives/324#more-324
%
% Patrik Malm, 2010/11

% Pad the image to avoid stepping outside the border
bimage = padarray(bimage,[1 1],0);

% Possible directions for the boundary extraction
directions = [ 1, 0
               1,-1
               0,-1
              -1,-1
              -1, 0
              -1, 1
               0, 1
               1, 1];

% Use find to obtain start point
indx = find(bimage,1);

% Convert index into image coordinates
sz = size(bimage);
[start1,start2]=ind2sub(size(bimage),indx);

% Matlab is column major so from start point possible directions are
% 0,1,6,7. We'll go clockwise

boundary = [];           % The boundary coordinates
coord = [start1,start2]; % Coordinates of the current pixel
dir = 1;                 % The starting direction

while 1
    
    % Get coordinate to check
    newcoord = coord + directions(dir+1,:);
    
    if all(newcoord>=0) && all(newcoord<sz) && bimage(newcoord(1),newcoord(2))
        
        % Found the nonzero pixel, store coordinates
        boundary = [boundary;newcoord]; %#ok
        
        % Prepare for next iteration
        coord = newcoord;
        dir = mod(dir+2,8); % Maximum deviation is a 90 degree left turn
        
    else
        
        % Change to look one step clockwise in directional matrix
        dir = mod(dir-1,8);
        
    end
    
    if all(coord==[start1,start2]) && dir==1 % We're back to starting situation
        
        break;
        
    end
    
end