#!/bin/bash
#
# Run MicroVIP complete pipeline, by successively calling wrapper script of each
# module.
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
  echo "Usage: ${CURRENT_NAME} [OPTION]... PIPELINE CONFIGURATION OUTPUT
Run MicroVIP modules successively. PIPELINE is 0, 1 or 2 and defines which
modules are to be run:
  * 0 runs only ground truth biomarkers position modelling (Cell generator
    module).
  * 1 additionally simulates microscopy imaging (Cell generator + Microscopy
    simulator modules).
  * 2 also applies common features extraction methods to obtained image (Cell
    generator + Microscopy simulator + Features extractor modules).
Parameters of each module are respectively read from CellGenerator, 
MicroscopySimulator and FeaturesExtractor sections of CONFIGURATION .ini file.
Outputs of all modules are saved in OUTPUT .tar archive file.

  -h  Display this help and exit.
  -i=ICELL      Index of the cell being generated. ICELL is an integer between
                1 and NCELL (see -n option and note on multiple cells 
                generation below).
  -m=MODULES    Specify path to directory containing MicroVIP modules wrapper
                scripts: cellgenerator.sh, microscopysimulator.sh and
                featuresextractor.sh. If -m is not used, default path is
                ${CURRENT_LOCATION}. If pointillist features should be extracted
                this directory should also contain unlocdetect.sh script as well
                as a sub-directory UNLOC with necessary executable and parameter
                files (see install.sh -U option).
                UNLOC_detect standalone 
  -n=NCELL      Number of cells being generated in different instances of
                ${CURRENT_NAME} (see note on multiple cells generation below).
  -p            Call Cell generator module with -p option: prune (remove)
                biomarkers outside the sphere of radius RADIUS before rescaling
                (see -r). If -p is not used, biomarkers are not removed, which
                does not impact cell rescaling but means there will exist
                biomarkers 'outside the cell'.
  -r=RADIUS     Call Cell generator module with -r option: when rescaling
                biomarkers point cloud from arbitrary units to µm, a sphere of
                radius RADIUS arbitrary units is interpolated into final cell's
                dimensions. If -r is not used, default RADIUS value is 350.
  -R=MCRFOLDER  Define MATLAB runtime root folder to extend and export 
                environment variable LD_LIBRARY_PATH. This is necessary for
                modules MATALB standalone applications to run properly. 
                Default value is environment variable MCR95.
  -U=UNLOC_MCR  Define MATLAB runtime v9.2 root folder (without trailing slash)
                to use as -R option for UNLOC wrapper script. Not needed if
                pointillist extraction is not performed. Default value is
                environment variable MCR92.
  -s=SEED       Set MATLAB random numer generator seed. SEED is an integer
                between 0 and 2^32 - 1. Use only in conjunction with -i and -n
                (see note on multiple cells generation below).
                
To generate multiple statistically independant cells (in parallel or not), use
-i, -n and -s. Either all or none of these options must be provided. First,
determine the number of cells you want to generate NCELL, and a random seed for
the generation SEED. SEED is an integer between 0 and 2^32 - 1, you can choose a
specific value for reproducible results (e.g. 1) or a random value (e.g. based
on current time with command date +%s). Then launch NCELL executions of
${CURRENT_NAME} as follows:
  ${CURRENT_NAME} -i 1 -n NCELL -s SEED [OPTION]... PIPELINE CONFIGURATION \
OUTPUT
  ${CURRENT_NAME} -i 2 -n NCELL -s SEED [OPTION]... PIPELINE CONFIGURATION \
OUTPUT
  ...
  ${CURRENT_NAME} -i \$((NCELL - 1)) -n NCELL -s SEED [OPTION]... PIPELINE \
CONFIGURATION OUTPUT
  ${CURRENT_NAME} -i NCELL -n NCELL -s SEED [OPTION]... PIPELINE CONFIGURATION \
OUTPUT
  
For more information on MicroVIP, including full sources and documentation,
visit <https://www.creatis.insa-lyon.fr/site7/en/PROCHIP>."
  exit 0
}

################################################################################
# Run given wrapper script with given arguments, after checking its existence.
# Globals:
#   CURRENT_NAME
# Arguments:
#   Path to wrapper script to run.
#   Array of arguments for the wrapper script
# Outputs:
#   Write wrapper script output to stdout. Write errors to stdout and stderr..
# Returns:
#   0 if wrapper script exists and completes with status 0, 1 else.
################################################################################
function run_module(){
  if [[ ! -f "$1" ]]; then
    error_exit "${LINENO}: $1 does not exist.
Use -m option to indicate correct path for MicroVIP modules wrapper scripts.
See ${CURRENT_NAME} -h for help."
  fi
  "$@" || error_exit "${LINENO}: $1 exited with non-zero status."
}
echo "    MicroVIP  Copyright (C) 2021  Ali Ahmad, Guillaume Vanel,
    CREATIS, Université Lyon 1, Insa de Lyon, Lyon, France.
    This program comes with ABSOLUTELY NO WARRANTY; for details see
    <https://www.gnu.org/licenses/gpl-3.0.txt>.
"
# -----------------------------------------
# Process arguments.
# -----------------------------------------
echo "Processing arguments."
# Default values.
mcr_95="${MCR95}" # MATLAB runtime roots
mcr_92="${MCR92}"
modules_directory="${CURRENT_LOCATION}" # Path to modules wrapper scripts.
declare -a cell_generator_option # Will contain options -p and -r if needed.
declare -a mutiple_cell_option # Arguments for multiple cells generation.
# Process options.
while getopts "hR:U:m:r:pi:n:s:" option; do
  case "${option}" in
    h)
      usage
      ;;
    R)
      mcr_95="${OPTARG}"
      ;;
    U)
      mcr_92="${OPTARG}"
      ;;
    m)
      modules_directory="${OPTARG/%\//}"
      ;;
    r)
      cell_generator_option+=("-r" "${OPTARG}")
      ;;
    p)
      cell_generator_option+=("-p")
      ;;
    i | n | s)
      mutiple_cell_option+=("-${option}" "${OPTARG}")
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
if [[ ! "${#mutiple_cell_option[*]}" =~ 0|6 ]]; then
  error_exit "${LINENO}: All or none of -n, -i and -s options must be used.
Try ${CURRENT_NAME} -h for help."
fi
# Process positional arguments.
shift $((OPTIND-1))
if [ $# -ne 3 ]
then
  error_exit "${LINENO}: Incorrect number of input arguments.
Try ${CURRENT_NAME} -h for help."
fi
declare -i pipeline="$1"
configuration_ini="$2"
output_tar="$3"
prefix="${output_tar/%.tar/}."
# -----------------------------------------
# Cell generator module.
# -----------------------------------------
biomarker_csv="${prefix}csv"
declare -a all_modules_output=( "${biomarker_csv}" )
echo "Modelling ground truth biomarkers positions."
run_module "${modules_directory}/cellgenerator.sh" -R "${mcr_95}" \
  "${cell_generator_option[@]}" "${mutiple_cell_option[@]}" \
  "${configuration_ini}" "${biomarker_csv}"
# -----------------------------------------
# Microscopy simulator module.
# -----------------------------------------
if [[ ${pipeline} -gt 0 ]]; then
  ground_truth_tif="${prefix}gt.tif"
  image_tif="${prefix}img.tif"
  all_modules_output+=( "${ground_truth_tif}" "${image_tif}")
  echo "Simulating microscopy image acquisition."
  run_module "${modules_directory}/microscopysimulator.sh" -R "${mcr_95}" \
    "${mutiple_cell_option[@]}" "${biomarker_csv}" "${configuration_ini}" \
    "${ground_truth_tif}" "${image_tif}"
  # -----------------------------------------
  # Features extraction module.
  # -----------------------------------------

  if [[ ${pipeline} -gt 1 ]]; then
    features_json="${prefix}json"
    all_modules_output+=( "${features_json}")
    echo "Performing features extraction."
    run_module "${modules_directory}/featuresextractor.sh" -R "${mcr_95}" \
      -r "${mcr_92}" "${image_tif}" "${configuration_ini}" "${features_json}"
  fi
fi
# -----------------------------------------
# Create results archive.
# -----------------------------------------
echo "Archiving results in ${output_tar}."
tar -cf "${output_tar}" "${all_modules_output[@]}" || error_exit "${LINENO}: \
Error while creating archive ${output_tar}."
echo "MicroVIP completed successfully."
exit 0
