#!/bin/bash
#
# Run MicroVIP Microscopy simulator module's MATLAB standalone application to
# simulate a 3D microscopy image from a ground truth 3D biomarkeds pint cloud.
#
readonly CURRENT_LOCATION="$(dirname "$0")" || error_exit
readonly CURRENT_NAME="$(basename "$0")" || error_exit
# Available microscopy techniques.
readonly -a MICROSCOPE_TYPE=("widefield" "confocal" "2-beam SIM" "3-beam SIM" \
                             "bSOFI" "STORM")
# Default MATALB standalone paths.
readonly DEFAULT_MICROSCOPY_STANDALONE="${CURRENT_LOCATION}/\
microscopysimulatorstandalone"
readonly DEFAULT_SOFI_STANDALONE="${CURRENT_LOCATION}/sofistandalone"
# Section to read in .ini configuration file.
readonly INI_SECTION="MicroscopySimulator"

################################################################################
# Exit with error status and message.
# Globals:
#   CURRENT_NAME
# Arguments:
#   None
# Outputs:
#   Writes error message to stdout and stderr.
# Returns:
#   1
################################################################################
function error_exit(){
  echo "${CURRENT_NAME}: ${1:-"Unknown Error"}" 1>&2
  exit 1
}

################################################################################
# Exit with status 0 after displaying help message.
# Globals:
#   CURRENT_NAME
#   DEFAULT_MICROSCOPY_STANDALONE
#   DEFAULT_SOFI_STANDALONE
#   INI_SECTION
# Arguments:
#   None
# Outputs:
#   Writes help message to stdout.
# Returns:
#   0
################################################################################
function usage(){
  echo "Usage: ${CURRENT_NAME} [OPTION]... INPUT CONFIGURATION TRUTH IMAGE
Run MicroVIP Cell generator module's MATLAB standalone application. Parameters
are read from ${INI_SECTION} of CONFIGURATION .ini file. INPUT is a 3 columns
.csv file of ground truth biomarkers 3D coordinates (in µm centered around 0).
Output binarized ground truth image is saved in TRUTH .tif image stack, and
output simulated 3D microscopy image is saved in IMAGE .tif image stack.

  -h  Display this help and exit.
  -i=ICELL      Index of the cell being imaged. ICELL is an integer between
                1 and NCELL (see -n option and note on multiple cells 
                imaging below).
  -M=STANDALONE Specify path to Microscopy simulator first compiled MATLAB
                standalone. This is the standalone allowing simulation for
                widefield, confocal and Structured Illumination Microscopy 
                (SIM). If -M is not used, default path is: 
                ${DEFAULT_MICROSCOPY_STANDALONE}.
  -n=NCELL      Number of cells being imaged in different instances of
                ${CURRENT_NAME} (see note on multiple cells imaging below).
  -R=MCRFOLDER  Define MATLAB runtime root folder (without trailing slash) to
                extend and export environment variable LD_LIBRARY_PATH. 
                Default value is environment variable MCR95.
  -s=SEED       Set MATLAB random numer generator seed. SEED is an integer
                between 0 and 2^32 - 1. Use only in conjunction with -i and -n
                (see note on multiple cells imaging below).
  -S=SOFI       Specify path to Microscopy simulator second compiled MATLAB
                standalone. his is the standalone allowing simulation for
                balanced Super-resolution Optical Fluctuation Imaging (bSOFI)
                and Stochastic Optical Reconstruction Microscopy (STORM). If
                -S is not used, default path is: ${DEFAULT_SOFI_STANDALONE}.
                
To image multiple cells (or multiple images of the same cell) in a statistically
independant fashion (in parallel or not), use -i, -n and -s. Either all or none
of these options must be provided. First, determine the total number of images
you want to simulate NCELL (this corresponds to the number of ground truth cells
you have if you simulate one image per cell). Also choose a random seed SEED for
noise generation. SEED is an integer between 0 and 2^32 - 1, you can choose a
specific value for reproducible results (e.g. 1) or a random value (e.g. based
on current time with command date +%s). Then launch NCELL executions of
${CURRENT_NAME} as follows:
  ${CURRENT_NAME} -i 1 -n NCELL -s SEED [OPTION]... INPUT CONFIGURATION TRUTH \
IMAGE
  ${CURRENT_NAME} -i 2 -n NCELL -s SEED [OPTION]... INPUT CONFIGURATION TRUTH \
IMAGE
  ...
  ${CURRENT_NAME} -i \$((NCELL - 1)) -n NCELL -s SEED [OPTION]... INPUT \
CONFIGURATION TRUTH IMAGE
  ${CURRENT_NAME} -i NCELL -n NCELL -s SEED [OPTION]... INPUT CONFIGURATION \
TRUTH IMAGE
  
For more information on MicroVIP, including full sources and documentation,
visit <https://www.creatis.insa-lyon.fr/site7/en/PROCHIP>."
  exit 0
}

################################################################################
# Read value for given variable name in correct section of .ini configuration
# file.
# Globals:
#   configuration_ini
#   INI_SECTION
# Arguments:
#   Name of a variable in .ini file which value must be read.
# Outputs:
#   Writes variable value to stdout.
# Returns:
#   0 if variable value was read, non-zero on error.
################################################################################
function read_ini_variable(){
  crudini --get "${configuration_ini}" "${INI_SECTION}" "$1" || error_exit "\
${LINENO}: Could not read variable $1 from section ${INI_SECTION} of file
${configuration_ini}.
Please double check variable, section and file names."
}

# -------------------------------------------------
# Process arguments.
# -------------------------------------------------
echo "Processing arguments."
# Default values.
mcr_95="${MCR95}" # MATLAB runtime root
declare -a mutiple_cell_argument # Arguments for multiple cells generation.
# Matlab standalones for Microscopy simulator (microscopy_standalone for
# confocal, widefield and SIM, sofi_standalone for bSOFI and STORM).
microscopy_standalone="${DEFAULT_MICROSCOPY_STANDALONE}"
sofi_standalone="${DEFAULT_SOFI_STANDALONE}"
# Process options.
while getopts "hR:M:S:i:n:s:" option; do
  case $option in
    h)
      usage
      ;;
    R)
      mcr_95="${OPTARG}"
      ;;
    M)
      microscopy_standalone="${OPTARG}"
      ;;
    S)
      sofi_standalone="${OPTARG}"
      ;;
    i)
      mutiple_cell_argument[1]="${OPTARG}"
      ;;
    n)
      mutiple_cell_argument[2]="${OPTARG}"
      ;;
    s)
      mutiple_cell_argument[0]="${OPTARG}"
      ;;
    *)
      error_exit "${LINENO}: Unknown option '${option}'.
Try ${CURRENT_NAME} -h for help."
      ;;
  esac
done
# Set LD_LIBRARY_PATH for MATLAB standalones
LD_LIBRARY_PATH="${mcr_95}/runtime/glnxa64"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${mcr_95}/bin/glnxa64"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${mcr_95}/sys/os/glnxa64"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${mcr_95}/sys/opengl/lib/glnxa64"
export LD_LIBRARY_PATH;
# Check that either all or none of -i, -n and -s have been provided.
if [[ ! "${#mutiple_cell_argument[*]}" =~ 0|3 ]]; then
  error_exit "${LINENO}: All or none of -n, -i and -s options must be used.
Try ${CURRENT_NAME} -h for help."
fi
# Process positional arguments.
shift $((OPTIND - 1))
if [[ $# -ne 4 ]]
then
  error_exit "${LINENO}: Incorrect number of input arguments.
Try ${CURRENT_NAME} -h for help."
fi
input_csv="$1"
configuration_ini="$2"
output_ground_truth="$3"
output_image="$4"

# -------------------------------------------------
# Read .ini configuration file and run application.
# -------------------------------------------------
echo "Reading ${configuration_ini}."
microscope_index="$(read_ini_variable microscope)" || error_exit "${LINENO}"
case $microscope_index in
  0 | 1 | 2 | 3 ) # Application microscopy_standalone.
    microscope="${MICROSCOPE_TYPE["${microscope_index}"]}"
    # Prepare arguments.
    declare -a application_command=("${microscopy_standalone}" "${input_csv}")
    for ini_argument in wavelength refractive_index numerical_aperture \
                        pixel_size_um magnification camera_size_px \
                        axial_range_um axial_step_um bleaching_time_s \
                        marker_intensity_photon gaussian_noise_mean \
                        gaussian_noise_std cell_speed_um_per_s \
                        shutter_speed_hz frame_rate_hz light_sheet_width_um \
                        wiener_parameter; do
      ini_value="$(read_ini_variable ${ini_argument})" || \
        error_exit "${LINENO}"
      application_command+=("${ini_value}")
    done
    application_command+=("${microscope}" "${output_ground_truth}" \
                          "${output_image}" "${mutiple_cell_argument[@]}")
    # Run application.
    echo "Running ${application_command[*]}."
    "${application_command[@]}" || error_exit \
      "${LINENO}: ${microscopy_standalone} returned with non-zero status."
    ;;
  4 | 5 ) # Application sofi_standalone.
    microscope="${MICROSCOPE_TYPE["${microscope_index}"]}"
    # prepare arguments.
    declare -a application_command=("${sofi_standalone}" "${input_csv}")
    for ini_argument in wavelength numerical_aperture pixel_size_um \
                        magnification camera_size_px axial_range_um \
                        axial_step_um bleaching_time_s marker_intensity_photon \
                        background_intensity_photon marker_radius_nm \
                        marker_on_lifetime_ms marker_off_lifetime_ms \
                        gaussian_noise_std dark_current quantum_gain \
                        frame_rate_hz acquisition_duration_s; do
      ini_value="$(read_ini_variable ${ini_argument})" || \
        error_exit "${LINENO}"
      application_command+=("${ini_value}")
    done
    application_command+=("${microscope}" "${output_ground_truth}" \
                          "${output_image}" "${mutiple_cell_argument[@]}")
    # Run application
    ulimit -n 10000 || error_exit "${LINENO}: Could not modify resource limits."
    # Run application.
    echo "Running ${application_command[*]}."
    "${application_command[@]}" || error_exit \
      "${LINENO}: ${sofi_standalone} returned with non-zero status."
    ;;
  *)
    error_exit "$LINENO: Incorrect microscope value: ${microscope_index}.
Only accepted values are integers between 0 and 5."
    ;;
esac
echo "Microscopy simulation completed successfully."
exit 0
