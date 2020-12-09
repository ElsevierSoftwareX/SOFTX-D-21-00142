%% Default parameters

IMAGE_SIZE = [600 400];
RESOLUTION = 0.25;                  % um/px
PADDING = 200;                      % px (per side)
IMAGE_DEPTH = 0.4;                  % um
Z_RESOLUTION = 0.2;                 % um/px
BG_INTENSITY = 255;                 % max intensity
BG_INTENSITY_VARIATION = 10;        % maximum subtracted from max
BG_NONUNIFORM_STRENGTH = 0.02;      % strength of uneven illumination
MALIGNANT_CHANCE = 0.0;             % Chance of malignant nuclei

% Cell setup
USE_PREGENERATED = 0;               % 0 = Use single run, 1 = Will load cells from /data/pregen.mat, 2 = Will write created cells
NO_CELLS = 20;

CYTOPLASM_SIZE_VARIATION = [0.6 0.9]; % Percentage of average size
CYTOPLASM_BASE_ABSORBANCE = [0.01 0.02];
CYTOPLASM_TEXTURE_ABSORBANCE = [0.06 0.06];
CYTOPLASM_OVERLAP_ABS_FACTOR = 0.6; % Decide to which factor absorbance will increase for each overlap. I = A / (F * N), F : [0,1]

NUCLEUS_SIZE_VARIATION = [1 1.1];     % Min/Max
NUCLEUS_POSITION_VARIATION = 15;    % Maximum offset from cytoplasm center, um
NUCLEUS_ABSORBANCE = [0.21 0.21];
NUCLEUS_SAMPLING_FREQ = 3;          % No cells that are used for nucleus texture synthesis
NUCLEUS_OVERLAP_ABS_FACTOR = 0.3;

% Debris setup
BACILLI_ABSORBANCE = 0.15;
NO_BACILLI_CLUSTERS = 2;
NO_BACILLI_PER_CLUSTER = [5 10];
BACILLI_CLUSTER_SPREAD = 30;       % px

WBC_ABSORBANCE = 0.70;
NO_WBC_CLUSTERS = 5;
NO_WBC_PER_CLUSTER = [3 5];         % No in [min max]
WBC_CLUSTER_SPREAD = 50;            % px

NO_SPECKLES = 50;
SPECKLE_DILATION = [0 1];           % Integer [min max]
SPECKLE_ABSORBANCE = 0.25;
SPECKLE_HALO = 1;                   % Bool

NO_BLOBS = 0;                       % Out of focus blobs
BLOB_ABSORBANCE = 0.8;
MAX_BLOB_SIZE = 200;
BLOB_DISTANCE = 4;                  % Distance from focus plane, um

% Sensor noise level
POISSON_CONVERSION = 70;            % Smaller values yields higher noise
GAUSSIAN_WHITE_NOISE = 1;           % Sigma 