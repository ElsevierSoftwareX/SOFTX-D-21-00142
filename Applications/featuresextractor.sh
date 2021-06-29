#!/bin/bash
#
# Run MicroVIP Features extractor module's MATLAB standalone application to
# apply common features extraction methods to a 3D microscopy image.
#
readonly CURRENT_LOCATION="$(dirname "$0")" || error_exit
readonly CURRENT_NAME="$(basename "$0")" || error_exit
# Default MATALB standalone path.
readonly DEFAULT_STANDALONE="${CURRENT_LOCATION}/featuresextractorstandalone"
# Section to read in .ini configuration file.
readonly INI_SECTION="FeaturesExtractor"

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
#   DEFAULT_STANDALONE
#   INI_SECTION
# Arguments:
#   None
# Outputs:
#   Writes help message to stdout.
# Returns:
#   0
################################################################################
function usage(){
  echo "Usage: ${CURRENT_NAME} [OPTION]... INPUT CONFIGURATION OUTPUT
Run MicroVIP Features extractor module's MATLAB standalone application.
Parameters are read from ${INI_SECTION} of CONFIGURATION .ini file. INPUT is a 
3D microscopy .tif image stack and OUTPUT is a .json file containing extracted
features vectors.

  -h  Display this help and exit.
  -F=STANDALONE Specify path to Features extractor compiled MATLAB standalone.
                This is the standalone allowing simulation for
                widefield, confocal and Structured Illumination Microscopy 
                (SIM). If -F is not used, default path is: 
                ${DEFAULT_STANDALONE}.
  -R=MCRFOLDER  Define MATLAB runtime root folder (without trailing slash) to
                extend and export environment variable LD_LIBRARY_PATH. If -R is
                not used, you should ensure LD_LIBRARY_PATH is correctly set or
                MATLAB runtime will complain about missing libraries.
                
OUTPUT .json file will contain a json object formatted as follows:
  {
    \"2D\": {
      \"Haralick\": [ ... ],
      \"LBP\": [ ... ],
      \"Scattering\": [ ... ],
      \"Autocorrelation\": [ ... ]
    },
    \"3D\": {
      \"Haralick\": [ ... ],
      \"LBP\": [ ... ],
      \"Scattering\": [ ... ]
    }
  }
  
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
matlab_standalone="${DEFAULT_STANDALONE}"
while getopts "hR:F:" option; do
  case $option in
    h)
      usage
      ;;
    R)
      MCRROOT="${OPTARG}"
      LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-.}:${MCRROOT}/runtime/glnxa64"
      LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${MCRROOT}/bin/glnxa64"
      LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${MCRROOT}/sys/os/glnxa64"
      LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${MCRROOT}/sys/opengl/lib/glnxa64"
      export LD_LIBRARY_PATH;
      echo "LD_LIBRARY_PATH is ${LD_LIBRARY_PATH}";
      ;;
    F)
      matlab_standalone="${OPTARG}"
      ;;
    *)
      error_exit "${LINENO}: Unknown option '${option}'.
Try ${CURRENT_NAME} -h for help."
      ;;
  esac
done
# Process positional arguments.
shift $((OPTIND - 1))
if [[ $# -ne 3 ]]
then
  error_exit "${LINENO}: Incorrect number of input arguments.
Try ${CURRENT_NAME} -h for help."
fi
input_tif="$1"
configuration_ini="$2"
output_json="$3"

# -------------------------------------------------
# Read .ini configuration file..
# -------------------------------------------------
echo "Reading ${configuration_ini}."
# Prepare arguments.
declare -a application_command=("${matlab_standalone}" "${input_tif}")
for ini_argument in neighborhood_size_GLCM_2D n_neighbor_LBP_2D \
  radius_LBP_2D n_layer_scattering_2D n_scale_scattering_2D \
  n_orientation_scattering_2D neighborhood_size_GLCM_3D n_xy_neighbor_LBPTOP \
  n_xz_neighbor_LBPTOP n_yz_neighbor_LBPTOP x_radius_LBPTOP y_radius_LBPTOP \
  z_radius_LBPTOP n_layer_scattering_3D n_scale_scattering_3D \
  n_orientation_scattering_3D; do
  ini_value="$(read_ini_variable ${ini_argument})" || error_exit "${LINENO}"
  application_command+=("${ini_value}")
done
application_command+=("${output_json}")
# -----------------------------------------
# Run application.
# -----------------------------------------
echo "Running ${application_command[*]}."
"${application_command[@]}" || error_exit "${LINENO}: ${matlab_standalone} \
returned with non-zero status."
echo "Features extraction completed successfully."
exit 0
