#!/bin/bash
#
# Run UNLOC_detect with provided parameters. UNLOC is a third-party application,
# please consult README.md or MicroVIP project's wiki for complete citations
# and acknowledgements.
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
readonly UNLOC_FOLDER="${CURRENT_LOCATION}/UNLOC"
readonly DEFAULT_PARAM="${UNLOC_FOLDER}/UNLOC_default_plugin_param.m"

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
#   CURRENT_LOCATION
#   CURRENT_NAME
# Arguments:
#   None
# Outputs:
#   Writes help message to stdout.
# Returns:
#   0
################################################################################
function usage(){
  echo "Usage: ${CURRENT_NAME} [OPTION]... IMAGE OUTPUT
Run UNLOC_detect on .tif image IMAGE and save results and used parameter file
in OUTPUT foler. PSF lateral half-width in pixels is written from IMAGE
imageDescription tag, so please make sure this tag is a string with following
format: 'PSF size: [half_width_px]' where [half_width_px] is a float number.
UNLOC is a third-party application, please consult README.md or MicroVIP
project's wiki for complete citations and acknowledgements.

  -h  Display this help and exit.
  -R=MCRROOT    Define MATLAB runtime v92 (R2017a) root folder to extend and
                export environment variable LD_LIBRARY_PATH. This is necessary
                for UNLOC standalone application to run properly. If -R is
                not used, default value is environment variable MCR92.
                
Note: to run this script, you must have run MicroVIP's install.sh with option
-U (see install.sh help). 
  
For more information on MicroVIP, including full sources and documentation,
visit <https://www.creatis.insa-lyon.fr/site7/en/PROCHIP>."
  exit 0
}

echo "    MicroVIP  Copyright (C) 2021  Ali Ahmad, Guillaume Vanel,
    CREATIS, Université Lyon 1, Insa de Lyon, Lyon, France.
    This program comes with ABSOLUTELY NO WARRANTY; for details see
    <https://www.gnu.org/licenses/gpl-3.0.txt>.
"
# -----------------------------------------
# Process arguments.
# -----------------------------------------
if [[ ! -d "${UNLOC_FOLDER}" ]]; then
  error_exit "${LINENO}: ${UNLOC_FOLDER} does not exist. Please ensure you run
install.sh with option -U (see install.sh help) prior to running this."
fi
echo "Processing arguments."
# Default values
mcr_92="${MCR92}"
# Process options.
while getopts "hR:" option; do
  case "${option}" in
    h)
      usage
      ;;
    R)
      mcr_92="${OPTARG}"
      ;;
    *)
      error_exit "${LINENO}: Unknown option '${option}'.
Try ${CURRENT_NAME} -h for help."
      ;;
  esac
done
# Set LD_LIBRARY_PATH for MATLAB standalones
LD_LIBRARY_PATH="${mcr_92}/runtime/glnxa64"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${mcr_92}/bin/glnxa64"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${mcr_92}/sys/os/glnxa64"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${mcr_92}/sys/opengl/lib/glnxa64"
export LD_LIBRARY_PATH;
# Process positional arguments.
shift $((OPTIND-1))
if [ $# -ne 2 ]; then
  error_exit "${LINENO}: Incorrect number of input arguments.
Try ${CURRENT_NAME} -h for help."
fi
image_tif=$(realpath "$1") || error_exit
if [[ ! -f "${image_tif}" ]]; then
  error_exit "${LINENO}: Input image does not exist."
fi
output_folder="${2%/}"
if [[ ! -d "${output_folder}" ]]; then
  mkdir "${output_folder}"
fi
# -----------------------------------------
# Customize UNLOC parameters.
# -----------------------------------------
psf_size=$(exiftool -imageDescription "${image_tif}" | sed s/.*"PSF size: "//) \
  || error_exit "${LINENO}: Error while reading image description."
echo "Customizing UNLOC parameter file."
output_filename="$(basename "${image_tif}" .tif).csv" || error_exit
custom_parameter="${output_folder}/used_parameters.m"
# Note we need to escape slashes in filename variables
sed -e s/^stkrange_begin.*/"stkrange_begin = 1;"/ \
    -e s/^stkrange_end.*/"stkrange_end = inf;"/ \
    -e s/^OUTPUT_FOLDER.*/"OUTPUT_FOLDER = '${output_folder//\//\\/}';"/ \
    -e s/^m_data_file.*/"m_data_file = ['${image_tif//\//\\/}'];"/ \
    -e s/^output_file.*/"output_file = '${output_filename//\//\\/}';"/ \
    -e s/^runparallel.*/"runparallel = 0;"/ \
    -e s/^"r0 =".*/"r0 = ${psf_size};"/ \
    "${DEFAULT_PARAM}" > "${custom_parameter}" || error_exit \
    "${LINENO}: Error while customizing UNLOC parameter file."
# -----------------------------------------
# Run UNLOC.
# -----------------------------------------
echo "Executing UNLOC detection."
"${UNLOC_FOLDER}/UNLOC_detect" "${custom_parameter}" \
  "${UNLOC_FOLDER}/UNLOC_detect_param_expert.m" || error_exit \
  "${LINENO}: UNLOC_detect exited with non-zero status."
echo "UNLOC detection completed successfully"
exit 0
