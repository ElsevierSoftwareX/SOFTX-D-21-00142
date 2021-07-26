#!/bin/bash
#
# Run MicroVIP Cell generator module's MATLAB standalone application to generate
# a ground truth 3D biomarkers point cloud.
#
readonly CURRENT_LOCATION="$(dirname "$0")" || error_exit
readonly CURRENT_NAME="$(basename "$0")" || error_exit
# Default MATALB standalone path.
readonly DEFAULT_STANDALONE="${CURRENT_LOCATION}/cellgeneratorstandalone"
# Section to read in .ini configuration file.
readonly INI_SECTION="CellGenerator"

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
  echo "
${CURRENT_NAME}: ${1:-"Unknown Error"}" 1>&2
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
  echo "Usage: ${CURRENT_NAME} [OPTION]... CONFIGURATION OUTPUT
Run MicroVIP Cell generator module's MATLAB standalone application. Parameters
are read from ${INI_SECTION} of CONFIGURATION .ini file and output ground truth
3D biomarkers point cloud is saved in OUTPUT three columns .csv file.

  -C=STANDALONE Specify path to Cell generator compiled MATLAB standalone. If -C
                is not used, default path is: ${DEFAULT_STANDALONE}.
  -h  Display this help and exit.
  -i=ICELL      Index of the cell being generated. ICELL is an integer between
                1 and NCELL (see -n option and note on multiple cells 
                generation below).
  -n=NCELL      Number of cells being generated in different instances of
                ${CURRENT_NAME} (see note on multiple cells generation below).
  -p            Prune (remove) biomarkers outside of the sphere of radius
                RADIUS before rescaling (see -r). If -p is not used, biomarkers
                are not removed, which does not impact cell rescaling but means
                there will exist biomarkers 'outside the cell'.
  -r=RADIUS     When rescaling biomarkers point cloud from arbitrary units to
                µm, a sphere of radius RADIUS arbitrary units is interpolated
                into final cell's dimensions. If -r is not used, default RADIUS
                value is 350.
  -R=MCRFOLDER  Define MATLAB runtime root folder (without trailing slash) to
                extend and export environment variable LD_LIBRARY_PATH. 
                Default value is environment variable MCR95.
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
  ${CURRENT_NAME} -i 1 -n NCELL -s SEED [OPTION]... CONFIGURATION OUTPUT
  ${CURRENT_NAME} -i 2 -n NCELL -s SEED [OPTION]... CONFIGURATION OUTPUT
  ...
  ${CURRENT_NAME} -i \$((NCELL - 1)) -n NCELL -s SEED [OPTION]... \
CONFIGURATION OUTPUT
  ${CURRENT_NAME} -i NCELL -n NCELL -s SEED [OPTION]... CONFIGURATION OUTPUT
  
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
${LINENO}: Could not read variable $1 from section ${INI_SECTION} of file\
${configuration_ini}.
Please double check variable, section and file names."
}

################################################################################
# Read a distribution type and parameters from .ini configuration file, and
# ouputs a MATLAB function handle to that distribution, in string form.
# Globals:
#   configuration_ini
#   INI_SECTION
# Arguments:
#   Names of variables in .ini file containing distribution information. These
#   should be three names, for variables that are in order: distribution type
#   (value "u" or "g" for Uniform or Gaussian), distribution first parameter
#   (resp. first bound of interval or mean) and distribution second parameter
#   (resp. second bound or standard deviation).
# Outputs:
#   Writes distribution function handle as a string to stdout.
# Returns:
#   0 if distribution function handle could be generated, non-zero on error.
################################################################################
function read_ini_distribution(){
  return_status=0
  type="$(read_ini_variable "$1")" || return_status=1
  first_parameter="$(read_ini_variable "$2")" || return_status=1
  second_parameter="$(read_ini_variable "$3")" || return_status=1
  if [[ ${return_status} -ne 0 ]]; then
    error_exit "${LINENO}: Could not read distribution, at least one variable \
missing."
  fi
  case "${type}" in
    "u" ) # Uniform distribution: parameters are interval bounds.
      echo "@() (${second_parameter} - ${first_parameter}) * rand(1,1) + \
${first_parameter}"
      ;;
    "g" ) # Uniform distribution: parameters are interval bounds.
      echo "@() ${first_parameter} + ${second_parameter} * randn(1,1)"
      ;;
    *)
      error_exit "${LINENO}: Incorrect distribution type '${type}'.
Allowed values are 'u' (Uniform) and 'g' (Gaussian)."
      ;;
  esac
  return 0
}

# -----------------------------------------
# Process arguments.
# -----------------------------------------
echo "Processing arguments."
# Default values.
mcr_95="${MCR95}" # MATLAB runtime root
is_prune='false' # Use of -p option.
radius=350 # Default radius, overwritten if -r is used.
matlab_standalone="${DEFAULT_STANDALONE}"
declare -a mutiple_cell_argument # Arguments for multiple cells generation.
# Process options.
while getopts "hR:C:r:pi:n:s:" option; do
  case "${option}" in
    h)
      usage
      ;;
    R)
      mcr_95="${OPTARG}"
      ;;
    C)
      matlab_standalone="${OPTARG}"
      ;;
    r)
      radius="${OPTARG}"
      ;;
    p)
      is_prune='true'
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
if [[ $# -ne 2 ]]
then
  error_exit "${LINENO}: Incorrect number of input arguments.
Try ${CURRENT_NAME} -h for help."
fi
configuration_ini="$1"
output_csv="$2"
# -----------------------------------------
# Read .ini configuration file.
# -----------------------------------------
echo "Reading ${configuration_ini}."
n_chromatin_chain="$(read_ini_variable n_chromatin_chain)" || \
  error_exit "${LINENO}"
marker_distribution="$(read_ini_distribution marker_distribution_type \
  marker_distribution_param1 marker_distribution_param2)" || \
  error_exit "${LINENO}"
cell_size_distribution="$(read_ini_distribution cell_size_distribution_type \
  cell_size_distribution_param1 cell_size_distribution_param2)" || \
  error_exit "${LINENO}"
# -----------------------------------------
# Run application.
# -----------------------------------------
echo "Running ${matlab_standalone}."
"${matlab_standalone}" "ChromatinChainDatabase" "${marker_distribution}" \
  "${n_chromatin_chain}" "${radius}" "${is_prune}" "${cell_size_distribution}" \
  "${output_csv}" "${mutiple_cell_argument[@]}" || error_exit "\
${LINENO}: ${matlab_standalone} returned with non-zero status."
echo "Cell generation completed successfully"
exit 0
