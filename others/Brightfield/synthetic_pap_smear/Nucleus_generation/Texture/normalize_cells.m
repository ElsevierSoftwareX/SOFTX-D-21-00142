function normalized = normalize_cells(varargin) % Cells, masks, mean, std

cells = varargin{1};
masks = varargin{2};

means = zeros(size(cells,1),1);
stds = means;
normalized = cells;

% find the means and stds
for ii = 1 : size(cells,1)
    means(ii) = mean(cells{ii}(masks{ii}));
    stds(ii) = std(cells{ii}(masks{ii}));
end

if nargin == 2 
    % Set the nuclei to have the same std and mean (for patching purposes)
    m = mean(means);
    s = mean(stds);
else
    m = varargin{3};
    s = varargin{4};
end

for ii = 1 : size(cells,1)
    tmpcell = cells{ii};
    tmpcell = tmpcell - means(ii);
    tmpcell = tmpcell / stds(ii);
    tmpcell = tmpcell * s;
    normalized{ii} = tmpcell + m;
end
