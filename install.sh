#!/bin/bash
#
# Install MicroVIP by creating a chromatin chain database if needed, and then
# compiling MATLAB codes ino standalone applications.

# Paths to sources
readonly CURRENT_LOCATION="$(dirname "$0")" || error_exit
readonly CURRENT_NAME="$(basename "$0")" || error_exit
readonly SRC_FOLDER="${CURRENT_LOCATION}/src"
readonly CELL_GENERATOR_FOLDER="${SRC_FOLDER}/CellGenerator"
readonly CHROMATIN_FOLDER="${CELL_GENERATOR_FOLDER}/ChromatinChainDatabase"
readonly FEATURES_EXTRACTOR_FOLDER="${SRC_FOLDER}/FeaturesExtractor"
readonly IMAGE_SIMULATOR_FOLDER="${SRC_FOLDER}/MicroscopySimulator"
readonly UTIL_FOLDER="${SRC_FOLDER}/util"
# Temporary folder
readonly TMP_FOLDER="/tmp/MicroVipInstall"
# Compilation command
readonly -a MCC_COMMAND=(mcc -R -nodisplay -R -singleCompThread \
                         -d "${TMP_FOLDER}" -a "${UTIL_FOLDER}" -m)
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

# ------------------------------------------
# Prepare empty tmp directory.
# ------------------------------------------
if [[ -d "${TMP_FOLDER}" ]]; then
  rm -fr "${TMP_FOLDER:?}/*" || error_exit "${LINENO}: Could not clean up \
${TMP_FOLDER} directory."
else
  mkdir "${TMP_FOLDER}" || error_exit "${LINENO}: Could not create \
${TMP_FOLDER} directory."
fi
# ------------------------------------------
# Ensure chromatin chain database existence.
# ------------------------------------------
# Check if chromatin chain database exists and is not empty
empty_database='true'
if [[ -d "${CHROMATIN_FOLDER}" ]]; then
  if [[ "$(ls -Q "${CHROMATIN_FOLDER}")" =~ .mat\" ]]; then
    empty_database='false'
  fi
fi
# Generate chromatin database if needed
if $empty_database; then
  echo "Generate chromatin chain database, this may take some time."
  # Get the application to generate database
  git clone "https://github.com/draguar/InfMod3DGen.git" "${TMP_FOLDER}" || \
    error_exit "${LINENO}: Could not clone draguar/InfMod3DGen.git."
  # Run the application
  matlab -sd "${TMP_FOLDER}" -batch "for chromosomeNo=1:16 \
      disp(sprintf('Generate chromatin chain %i/16.', chromosomeNo));\
      ChrMod_main(chromosomeNo, 100); end" || error_exit "${LINENO}: Error in \
MATLAB while generating chromatin database."
  #for chromosome_no in {1..16}; do
   # echo -e "\tGenerate configurations for chromosome ${chromosome_no}/16."
    #matlab -sd "${TMP_FOLDER}" -batch "ChrMod_main(${chromosome_no}, 100)"
  #done
  mv "${TMP_FOLDER}/*.mat" "${CHROMATIN_FOLDER}" || error_exit "${LINENO}: \
Could not move chromatin database .mat files to ${CHROMATIN_FOLDER}."
  rm -rf "${TMP_FOLDER:?}/*"
fi
# ------------------------------------------
# Compile standalone for each module.
# ------------------------------------------
echo "Compile standalone applications:"
# Cell generator
echo "  Compile Cell generator."
${MCC_COMMAND[*]} "${CELL_GENERATOR_FOLDER}/cellgeneratorstandalone.m" \
  -a "${CELL_GENERATOR_FOLDER}" || error_exit "${LINENO}: Could not compile \
${CELL_GENERATOR_FOLDER}/cellgeneratorstandalone.m."
# Microscopy simulator
echo "  Compile Microscopy simulator."
${MCC_COMMAND[*]} "${IMAGE_SIMULATOR_FOLDER}/microscopysimulatorstandalone.m" \
  -a "${IMAGE_SIMULATOR_FOLDER}" || error_exit "${LINENO}: Could not compile \
${IMAGE_SIMULATOR_FOLDER}/microscopysimulatorstandalone.m."
${MCC_COMMAND[*]} "${IMAGE_SIMULATOR_FOLDER}/sofistandalone.m" \
  -a "${IMAGE_SIMULATOR_FOLDER}" || error_exit "${LINENO}: Could not compile \
${IMAGE_SIMULATOR_FOLDER}/sofistandalone.m"
# Features extractor
echo "  Compile Features extractor."
${MCC_COMMAND[*]} "${FEATURES_EXTRACTOR_FOLDER}/featuresextractorstandalone.m" \
  -a "${FEATURES_EXTRACTOR_FOLDER}" || error_exit "${LINENO}: Could not \
compile ${FEATURES_EXTRACTOR_FOLDER}/featuresextractorstandalone.m"
mv "${TMP_FOLDER}"/*standalone "${CURRENT_LOCATION}/Applications" || \
error_exit "${LINENO}: Could not move standalones to \
${CURRENT_LOCATION}/Applications."
rm -rf "${TMP_FOLDER}"
echo "Installation completed succesfully."
exit 0
