#!/bin/bash
#
# Run MicroVIP Features extractor module's MATLAB standalone application to
# apply common features extraction methods to a 3D microscopy image.
#
#   MicroVIP, Microscopy image simulation and analysis tool
#   Copyright (C) 2021  Ali Ahmad, Guillaume Vanel,
#   CREATIS, Universite Lyon 1, Insa de Lyon, Lyon, France.
#
#   This file is part of MicroVIP.
#   MicroVIP is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.
readonly CURRENT_LOCATION="$(dirname "$0")" || error_exit
readonly CURRENT_NAME="$(basename "$0")" || error_exit
# Default MATALB standalone path.
readonly DEFAULT_STANDALONE="${CURRENT_LOCATION}/featuresextractorstandalone"
# Default Unloc wrapper script path.
readonly DEFAULT_UNLOC_SCRIPT="${CURRENT_LOCATION}/unlocdetect.sh"
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
#   DEFAULT_UNLOC_SCRIPT
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
                extend and export environment variable LD_LIBRARY_PATH. 
                Default value is environment variable MCR95.
  -r=MCR_UNLOC  Define MATLAB runtime v9.2 root folder (without trailing slash)
                to use as -R option for UNLOC wrapper script. Not needed if
                pointillist extraction is not performed. Default value is
                environment variable MCR92.
  -U=UNLOC      Specify path to UNLOC wrapper script. If -U is not used, default
                path is ${DEFAULT_UNLOC_SCRIPT}.
                
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

echo "    MicroVIP  Copyright (C) 2021  Ali Ahmad, Guillaume Vanel,
    CREATIS, Université Lyon 1, Insa de Lyon, Lyon, France.
    This program comes with ABSOLUTELY NO WARRANTY; for details see
    <https://www.gnu.org/licenses/gpl-3.0.txt>.
"
# -------------------------------------------------
# Process arguments.
# -------------------------------------------------
echo "Processing arguments."
# Default values.
matlab_standalone="${DEFAULT_STANDALONE}"
unloc_script="${DEFAULT_UNLOC_SCRIPT}"
mcr_95="${MCR95}" # MATLAB runtime roots
mcr_92="${MCR92}"
while getopts "hR:r:F:U:" option; do
  case $option in
    h)
      usage
      ;;
    R)
      mcr_95="${OPTARG}"
      ;;
    r)
      mcr_92="${OPTARG}"
      ;;
    F)
      matlab_standalone="${OPTARG}"
      ;;
    U)
      unloc_script="${OPTARG}"
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
# Check if pointillist features should be extracted
extract_pointillist="$(read_ini_variable extract_pointillist)" || \
  error_exit "${LINENO}"
if [[ "${extract_pointillist}" -eq 1 ]]; then
  echo "Pointillist features will be extracted."
  unloc_output="/tmp/unlocDetect"
  echo "Performing UNLOC detection."
  if [[ ! -f "${unloc_script}" ]]; then
    error_exit "${LINENO}: $1 does not exist.
Use -U option to indicate correct path for UNLOC detect wrapper script.
See ${CURRENT_NAME} -h for help."
  fi
  "${unloc_script}" -R "${mcr_92}" "${input_tif}" "${unloc_output}" || \
    error_exit "${LINENO}: UNLOC returned with non-zero status."
  detection_csv="${unloc_output}/$(basename "${input_tif}" .tif).csv" || \
    error_exit "${LINENO}"
  application_command+=("${detection_csv}")
  for ini_argument in radius_step_ripley_um max_radius_ripley_um; do
    ini_value="$(read_ini_variable ${ini_argument})" || error_exit "${LINENO}"
    application_command+=("${ini_value}")
  done
fi
# -----------------------------------------
# Run application.
# -----------------------------------------
echo "Running ${application_command[*]}."
"${application_command[@]}" || error_exit "${LINENO}: ${matlab_standalone} \
returned with non-zero status."
echo "Features extraction completed successfully."
exit 0
