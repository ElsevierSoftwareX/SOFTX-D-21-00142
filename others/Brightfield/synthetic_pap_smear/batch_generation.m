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

%% Load default parameters

default_parameters;

%% Setup batch 1 parameters

NO_IMAGES_BATCH = 5;
IMAGE_SIZE = [600 600];
SAVE_PATH = 'Evaluation/fake_images/';
NO_CELLS = 15;
CYTOPLASM_ABSORBANCE = [0.04 0.07];
CYTOPLASM_OVERLAP_ABS_FACTOR = 0.8;
NO_BACILLI_CLUSTERS = 0;
NO_WBC_CLUSTERS = 200;
NO_WBC_PER_CLUSTER = [3 6];
WBC_CLUSTER_SPREAD = 50;

%% Run generation script for batch 1

for bbb = 1 : NO_IMAGES_BATCH
    generation_script
    final_image = dip_image(final_image,'uint8');
    writeim(final_image,[SAVE_PATH 'batch_01_' num2str(bbb) '.tif'],'TIFF',0)
end

%% Setup batch 2 

clear all
default_parameters

NO_IMAGES_BATCH = 5;
IMAGE_SIZE = [600 600];
SAVE_PATH = 'Evaluation/fake_images/';
% Cell setup
BG_INTENSITY = 260;
NO_CELLS = 12;

CYTOPLASM_SIZE_VARIATION = [0.60 0.8]; % Percentage of average size
CYTOPLASM_ABSORBANCE = [0.12 0.15];
CYTOPLASM_OVERLAP_ABS_FACTOR = 0.8; % Decide to which factor absorbance will increase for each overlap. I = A / (F * N), F : [0,1]

NUCLEUS_SIZE_VARIATION = [0.80 1.2]; % Percentage of average size
NUCLEUS_ABSORBANCE = [0.25 0.30];
NUCLEUS_OVERLAP_ABS_FACTOR = 0.8;
NUCLEUS_POSITION_VARIATION = 7; 

% Debris setup
BACILLI_ABSORBANCE = 0.10;
NO_BACILLI_CLUSTERS = 5;
NO_BACILLI_PER_CLUSTER = [10 12];
BACILLI_CLUSTER_SPREAD = 50;       % px

NO_WBC_CLUSTERS = 0;

NO_SPECKLES = 200;
SPECKLE_DILATION = [0 2];           % Integer [min max]
SPECKLE_ABSORBANCE = 0.30;
SPECKLE_HALO = 1;                   % Bool

NO_BLOBS = 6;                       % Out of focus blobs
BLOB_ABSORBANCE = 0.8;
MAX_BLOB_SIZE = 100;
BLOB_DISTANCE = 4;                  % Distance from focus plane, um

%% Run generation script for batch 2

for bbb = 1 : NO_IMAGES_BATCH
    generation_script
    final_image = dip_image(final_image,'uint8');
    writeim(final_image,[SAVE_PATH 'batch_02_' num2str(bbb) '.tif'],'TIFF',0)
end

%% Setup batch 3 

clear all
default_parameters

NO_IMAGES_BATCH = 5;
IMAGE_SIZE = [600 600];
SAVE_PATH = 'Evaluation/fake_images/';
% Cell setup
BG_INTENSITY = 245;
NO_CELLS = 9;

CYTOPLASM_SIZE_VARIATION = [0.70 1.1]; % Percentage of average size
CYTOPLASM_ABSORBANCE = [0.02 0.03];
CYTOPLASM_OVERLAP_ABS_FACTOR = 0.8; % Decide to which factor absorbance will increase for each overlap. I = A / (F * N), F : [0,1]

NUCLEUS_ABSORBANCE = [0.15 0.17];
NUCLEUS_OVERLAP_ABS_FACTOR = 0.8;

% Debris setup
BACILLI_ABSORBANCE = 0.15;
NO_BACILLI_CLUSTERS = 5;
NO_BACILLI_PER_CLUSTER = [5 7];
BACILLI_CLUSTER_SPREAD = 50;       % px

NO_WBC_CLUSTERS = 15;

NO_SPECKLES = 100;
SPECKLE_DILATION = [0 2];           % Integer [min max]
SPECKLE_ABSORBANCE = 0.15;
SPECKLE_HALO = 1;                   % Bool

NO_BLOBS = 1;                       % Out of focus blobs
BLOB_ABSORBANCE = 0.8;
MAX_BLOB_SIZE = 100;
BLOB_DISTANCE = 4;                  % Distance from focus plane, um

%% Run generation script for batch 3

for bbb = 1 : NO_IMAGES_BATCH
    generation_script
    final_image = dip_image(final_image,'uint8');
    writeim(final_image,[SAVE_PATH 'batch_03_' num2str(bbb) '.tif'],'TIFF',0)
end

%% Setup batch 4 

clear all
default_parameters

NO_IMAGES_BATCH = 5;
IMAGE_SIZE = [600 600];
SAVE_PATH = 'Evaluation/fake_images/';
% Cell setup
BG_INTENSITY = 255;
NO_CELLS = 20;

CYTOPLASM_SIZE_VARIATION = [0.6 1]; % Percentage of average size
CYTOPLASM_ABSORBANCE = [0.05 0.09];
CYTOPLASM_OVERLAP_ABS_FACTOR = 1.0; % Decide to which factor absorbance will increase for each overlap. I = A / (F * N), F : [0,1]

NUCLEUS_ABSORBANCE = [0.20 0.25];
NUCLEUS_OVERLAP_ABS_FACTOR = 0.7;
NUCLEUS_POSITION_VARIATION = 7; 

% Debris setup
BACILLI_ABSORBANCE = 0.15;
NO_BACILLI_CLUSTERS = 0;
NO_BACILLI_PER_CLUSTER = [5 7];
BACILLI_CLUSTER_SPREAD = 50;       % px

NO_WBC_CLUSTERS = 50;

NO_SPECKLES = 150;
SPECKLE_DILATION = [0 2];           % Integer [min max]
SPECKLE_ABSORBANCE = 0.20;
SPECKLE_HALO = 1;                   % Bool

NO_BLOBS = 10;                       % Out of focus blobs
BLOB_ABSORBANCE = 0.8;
MAX_BLOB_SIZE = 150;
BLOB_DISTANCE = 5;                  % Distance from focus plane, um

%% Run generation script for batch 4

for bbb = 1 : NO_IMAGES_BATCH
    generation_script
    final_image = dip_image(final_image,'uint8');
    writeim(final_image,[SAVE_PATH 'batch_04_' num2str(bbb) '.tif'],'TIFF',0)
end

%% Setup batch 5

clear all
default_parameters

NO_IMAGES_BATCH = 5;
IMAGE_SIZE = [600 600];
SAVE_PATH = 'Evaluation/fake_images/';
% Cell setup
BG_INTENSITY = 255;
NO_CELLS = 20;
IMAGE_DEPTH = 0.4;

CYTOPLASM_SIZE_VARIATION = [0.6 0.9]; % Percentage of average size
CYTOPLASM_ABSORBANCE = [0.05 0.09];
CYTOPLASM_OVERLAP_ABS_FACTOR = 1.0; % Decide to which factor absorbance will increase for each overlap. I = A / (F * N), F : [0,1]

NUCLEUS_SIZE_VARIATION = [0.7 1]; 
NUCLEUS_ABSORBANCE = [0.25 0.30];
NUCLEUS_OVERLAP_ABS_FACTOR = 0.7;
NUCLEUS_POSITION_VARIATION = 7; 
NUCLEUS_SAMPLING_FREQ = 1;

% Debris setup
BACILLI_ABSORBANCE = 0.15;
NO_BACILLI_CLUSTERS = 0;
NO_BACILLI_PER_CLUSTER = [5 7];
BACILLI_CLUSTER_SPREAD = 50;       % px

NO_WBC_CLUSTERS = 20;

NO_SPECKLES = 400;
SPECKLE_DILATION = [0 1];           % Integer [min max]
SPECKLE_ABSORBANCE = 0.10;
SPECKLE_HALO = 1;                   % Bool

NO_BLOBS = 1;                       % Out of focus blobs
BLOB_ABSORBANCE = 0.8;
MAX_BLOB_SIZE = 150;
BLOB_DISTANCE = 5;                  % Distance from focus plane, um

%% Run generation script for batch 5

for bbb = 1 : NO_IMAGES_BATCH
    generation_script
    final_image = dip_image(final_image,'uint8');
    writeim(final_image,[SAVE_PATH 'batch_05_' num2str(bbb) '.tif'],'TIFF',0)
end

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