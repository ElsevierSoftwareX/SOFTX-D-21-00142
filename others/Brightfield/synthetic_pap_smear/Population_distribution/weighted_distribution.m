% Using Russian Roulette Monte Carlo sampling
% Reference: "Physically Based Rendering - From theory to implementation
% 2 ed, Pharr, M & Humphreys, G. Chapter 14
% INPUTS (no_points,image_size,weight_image[0,1] *optional*)
    

function coords = weighted_distribution(varargin)

no_points = varargin{1};
sz = varargin{2};
im = newim(sz,'bin');
if length(varargin) > 2
    weights = varargin{3};
else
    % Create a radial distance function
    weights = rr(im);
    weights = max(weights) - weights;
    weights = weights/max(weights);
end

% Create control variables
c = 0;
no_pixels = sz(1)*sz(2);
p = randperm(no_pixels);

while sum(im)<no_points && (c*no_points+no_points) <= no_pixels

    selected = p(c*no_points+1:c*no_points + no_points);
    w = double(weights(selected-1));
    r = rand(1,no_points);
    
    accepted = selected(w-r>0);
    
    if length(accepted) > no_points - sum(im)
        im(accepted(1:no_points-sum(im))-1) = true;
    else
        im(accepted-1) = true;
    end

    c = c + 1;
end

coords = findcoord(im);




