function Brightfield_pap_smear(ouput_prefix, varargin)

rng('shuffle')
for argument=2:2:size(varargin,2)
    if isstring(varargin{argument}) || ischar(varargin{argument})
        varargin{argument} = str2double(varargin{argument});
    end
end
parser = inputParser;
validPositive = @(x, length) isnumeric(x) && isequal( x>0, ones(1, length));
validPositiveOrNull = @(x, length) isnumeric(x) && isequal(x>=0, ones(1, length));
validInteger = @(x, length) isequal(~rem(x, 1), ones(1, length));
validPercentage = @(x, length) validPositiveOrNull(x, length) && isequal(x<=1, ones(1, length));
addParameter(parser, 'image_size_x', 600, @(x) validPositive(x, 1) && validInteger(x, 1));
addParameter(parser, 'image_size_y', 400, @(x) validPositive(x, 1) && validInteger(x, 1));
addParameter(parser, 'resolution', 0.25, @(x) validPositive(x, 1));
addParameter(parser, 'padding', 200, @(x) validPositive(x, 1) && validInteger(x, 1));
addParameter(parser, 'image_depth', 0.4, @(x) validPositive(x, 1));
addParameter(parser, 'z_resolution', 0.2, @(x) validPositive(x, 1));
addParameter(parser, 'bg_intensity', 255, @(x) validPositive(x, 1) && validInteger(x, 1));
addParameter(parser, 'bg_intensity_variation', 10, @(x) validPositiveOrNull(x, 1) && validInteger(x, 1));
addParameter(parser, 'bg_nonuniform_strength', 0.02, @(x) validPositiveOrNull(x, 1));
addParameter(parser, 'malignant_chance', 0.0, @(x) validPositiveOrNull(x, 1));
addParameter(parser, 'no_cells', 20, @(x) validPositive(x, 1) && validInteger(x, 1));
addParameter(parser, 'cytoplasm_size_min', 0.6, @(x) validPercentage(x, 1));
addParameter(parser, 'cytoplasm_size_max', 0.9, @(x) validPercentage(x, 1));
addParameter(parser, 'cytoplasm_min_base_absorbance', 0.01, @(x) validPercentage(x, 1));
addParameter(parser, 'cytoplasm_max_base_absorbance', 0.02, @(x) validPercentage(x, 1));
addParameter(parser, 'cytoplasm_min_texture_absorbance', 0.06, @(x) validPercentage(x, 1));
addParameter(parser, 'cytoplasm_max_texture_absorbance', 0.06, @(x) validPercentage(x, 1));
addParameter(parser, 'cytoplasm_overlap_abs_factor', 0.6, @(x) validPercentage(x, 1));
addParameter(parser, 'nucleus_size_min', 1 , @(x) validPositiveOrNull(x, 1));
addParameter(parser, 'nucleus_size_max', 1.1, @(x) validPositiveOrNull(x, 1));
addParameter(parser, 'nucleus_position_variation', 15, @(x) validPositiveOrNull(x, 1));
addParameter(parser, 'nucleus_absorbance_min', 0.21, @(x) validPercentage(x, 1));
addParameter(parser, 'nucleus_absorbance_max', 0.21, @(x) validPercentage(x, 1));
addParameter(parser, 'nucleus_sampling_freq', 3, @(x) validPositive(x, 1) && validInteger(x, 1));
addParameter(parser, 'nucleus_overlap_abs_factor', 0.3, @(x) validPercentage(x, 1));
addParameter(parser, 'bacilli_absorbance', 0.15, @(x) validPercentage(x, 1));
addParameter(parser, 'no_bacilli_clusters', 2, @(x) validPositiveOrNull(x, 1) && validInteger(x, 1));
addParameter(parser, 'no_bacilli_per_cluster_min', 5 , @(x) validPositive(x, 1) && validInteger(x, 1));
addParameter(parser, 'no_bacilli_per_cluster_max', 10, @(x) validPositive(x, 1) && validInteger(x, 1));
addParameter(parser, 'bacilli_cluster_spread', 30, @(x) validPositive(x, 1) && validInteger(x, 1));
addParameter(parser, 'wbc_absorbance', 0.7, @(x) validPercentage(x, 1));
addParameter(parser, 'no_wbc_clusters', 5, @(x) validPositiveOrNull(x, 1) && validInteger(x, 1));
addParameter(parser, 'no_wbc_per_cluster_min', 3, @(x) validPositive(x, 1) && validInteger(x, 1));
addParameter(parser, 'no_wbc_per_cluster_max', 5, @(x) validPositive(x, 1) && validInteger(x, 1));
addParameter(parser, 'wbc_cluster_spread', 50, @(x) validPositive(x, 1) && validInteger(x, 1));
addParameter(parser, 'no_speckles', 50, @(x) validPositiveOrNull(x, 1) && validInteger(x, 1));
addParameter(parser, 'speckle_dilation_min', 0, @(x) validPositiveOrNull(x, 1) && validInteger(x, 1));
addParameter(parser, 'speckle_dilation_max', 1, @(x) validPositiveOrNull(x, 1) && validInteger(x, 1));
addParameter(parser, 'speckle_absorbance', 0.25, @(x) validPercentage(x, 1));
addParameter(parser, 'speckle_halo', 1, @(x) isequal(x, 0) || isequal(x, 1));
addParameter(parser, 'no_blobs', 0, @(x) validPositiveOrNull(x, 1) && validInteger(x, 1));
addParameter(parser, 'blob_absorbance', 0.8, @(x) validPercentage(x, 1));
addParameter(parser, 'max_blob_size', 200, @(x) validPositive(x, 1) && validInteger(x, 1));
addParameter(parser, 'blob_distance', 4, @(x) validPositive(x, 1));
addParameter(parser, 'poisson_conversion', 70, @(x) validPositiveOrNull(x, 1));
addParameter(parser, 'gaussian_white_noise', 1, @(x) validPositiveOrNull(x, 1));
parse(parser,varargin{:});
%% Default parameters
IMAGE_SIZE = [parser.Results.image_size_x, parser.Results.image_size_y];
RESOLUTION = parser.Results.resolution; % um/px
PADDING = parser.Results.padding; % px (per side)
IMAGE_DEPTH = parser.Results.image_depth; % um
Z_RESOLUTION = parser.Results.z_resolution; % um/px
BG_INTENSITY = parser.Results.bg_intensity; % max intensity
BG_INTENSITY_VARIATION = parser.Results.bg_intensity_variation; % maximum subtracted from max
BG_NONUNIFORM_STRENGTH = parser.Results.bg_nonuniform_strength; % strength of uneven illumination
MALIGNANT_CHANCE = parser.Results.malignant_chance; % Chance of malignant nuclei
% Cell setup
USE_PREGENERATED = 0; % 0 = Use single run, 1 = Will load cells from /data/pregen.mat, 2 = Will write created cells
NO_CELLS = parser.Results.no_cells;
CYTOPLASM_SIZE_VARIATION = [parser.Results.cytoplasm_size_min, parser.Results.cytoplasm_size_max]; % Percentage of average size
CYTOPLASM_BASE_ABSORBANCE = [parser.Results.cytoplasm_min_base_absorbance, parser.Results.cytoplasm_max_base_absorbance];
CYTOPLASM_TEXTURE_ABSORBANCE = [parser.Results.cytoplasm_min_texture_absorbance, parser.Results.cytoplasm_max_texture_absorbance];
CYTOPLASM_OVERLAP_ABS_FACTOR = parser.Results.cytoplasm_overlap_abs_factor; % Decide to which factor absorbance will increase for each overlap. I = A / (F * N), F : [0,1]
NUCLEUS_SIZE_VARIATION = [parser.Results.nucleus_size_min, parser.Results.nucleus_size_max]; % Min/Max
NUCLEUS_POSITION_VARIATION = parser.Results.nucleus_position_variation; % Maximum offset from cytoplasm center, um
NUCLEUS_ABSORBANCE = [parser.Results.nucleus_absorbance_min, parser.Results.nucleus_absorbance_max];
NUCLEUS_SAMPLING_FREQ = parser.Results.nucleus_sampling_freq; % No cells that are used for nucleus texture synthesis
NUCLEUS_OVERLAP_ABS_FACTOR = parser.Results.nucleus_overlap_abs_factor;
% Debris setup
BACILLI_ABSORBANCE = parser.Results.bacilli_absorbance;
NO_BACILLI_CLUSTERS = parser.Results.no_bacilli_clusters;
NO_BACILLI_PER_CLUSTER = [parser.Results.no_bacilli_per_cluster_min, parser.Results.no_bacilli_per_cluster_max];
BACILLI_CLUSTER_SPREAD = parser.Results.bacilli_cluster_spread; % px
WBC_ABSORBANCE = parser.Results.wbc_absorbance;
NO_WBC_CLUSTERS = parser.Results.no_wbc_clusters;
NO_WBC_PER_CLUSTER = [parser.Results.no_wbc_per_cluster_min, parser.Results.no_wbc_per_cluster_max]; % No in [min max]
WBC_CLUSTER_SPREAD = parser.Results.wbc_cluster_spread; % px
NO_SPECKLES = parser.Results.no_speckles;
SPECKLE_DILATION = [parser.Results.speckle_dilation_min, parser.Results.speckle_dilation_max]; % Integer [min max]
SPECKLE_ABSORBANCE = parser.Results.speckle_absorbance;
SPECKLE_HALO = parser.Results.speckle_halo; % Bool
NO_BLOBS = parser.Results.no_blobs; % Out of focus blobs
BLOB_ABSORBANCE = parser.Results.blob_absorbance;
MAX_BLOB_SIZE = parser.Results.max_blob_size;
BLOB_DISTANCE = parser.Results.blob_distance; % Distance from focus plane, um
% Sensor noise level
POISSON_CONVERSION = parser.Results.poisson_conversion; % Smaller values yields higher noise
GAUSSIAN_WHITE_NOISE = parser.Results.gaussian_white_noise; % Sigma 
dip_initialise_libs
if ~isfolder('Data')
    mkdir('Data');
end
generation_script;
write_cut_image(final_image, IMAGE_SIZE, ouput_prefix + "final.tif");
write_cut_image(cytoplasm_mask_stack, IMAGE_SIZE, ouput_prefix + "cytoplasms.tif");
write_cut_image(nucleus_mask_stack, IMAGE_SIZE, ouput_prefix + "nuclei.tif");

rmdir('Data')
end

function write_cut_image(original_image, image_size, filename)
    cut_image = original_image / max(original_image) * 255;
    cut_image = dip_image(cut_image, 'uint8');
    if size(size(cut_image), 2) == 3
        image_size = [image_size, size(cut_image, 3)];
    end
    cut_image = cut(cut_image, image_size);
    disp(filename)
    writeim(cut_image, char(filename), 'TIF', 0)
end
