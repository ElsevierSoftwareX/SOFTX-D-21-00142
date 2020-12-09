% Collect nuclei

addpath ../General_functions/

load ../Data/squamous_subset

no_cells = 100;

cells = cell(no_cells,2);

rp = randperm(length(squamous_subset));
ii = 1;
jj = 1;

while ii <= no_cells
    
    if strcmp(squamous_subset{rp(jj)}.cell_diagnose,'NILM')
        cells{ii,1} = extract_optimal_simple(squamous_subset{rp(jj)}.volume,squamous_subset{rp(jj)}.seg_mask);
        cells{ii,2} = squamous_subset{rp(jj)}.seg_mask;
        ii = ii + 1;
    end
    
    jj = jj + 1;
    
end

save ../Data/cells cells