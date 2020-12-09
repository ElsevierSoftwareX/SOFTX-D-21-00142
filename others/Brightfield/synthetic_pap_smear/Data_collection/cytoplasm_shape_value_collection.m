% Collect cytoplasm shapes from segmentation 

addpath ../General_functions/

datapath = '../Data/cytoplasm_masks/';
files = dirc([datapath '*.pgm'],'f');files = files(:,1);

no_points = 420;

shapes = [];
scalings = [];

for ii = 1 : length(files)  
    I = label(readim([datapath files{ii}])>0);  
    for jj = 1 : max(I)
        [shapes(end+1,1:no_points),scalings(end+1,1)] = fsd_special(I==jj,no_points);      
    end  
end

