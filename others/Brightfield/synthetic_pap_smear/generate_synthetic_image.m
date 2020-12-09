%% Set paths

disp('Initializing synthetic image generation')

addpath Cytoplasm_generation/Shape/
addpath Cytoplasm_generation/Texture/
addpath Nucleus_generation/Shape/
addpath Nucleus_generation/Texture/
addpath Debris_object_generation/
addpath Population_distribution/
addpath Data/
addpath General_functions/
addpath General_functions/distmesh

%% Setup generation parameters

default_parameters

%% Run generation script

generation_script

%% Display final image

dip_image(final_image,'uint8')
nuclei_mask

%% Remove paths

disp('Removing paths')
rmpath Cytoplasm_generation/Shape/
rmpath Cytoplasm_generation/Texture/
rmpath Nucleus_generation/Shape/
rmpath Nucleus_generation/Texture/
rmpath Debris_object_generation/
rmpath Population_distribution/
rmpath Data/
rmpath General_functions/
rmpath General_functions/distmesh