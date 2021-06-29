function cellgeneratorstandalone(chromatinDatabase, markerDistribution, ...
                                 nChromatinChain, radiusArbitrary, prune, ...,
                                 cellSizeDistribution,  outputCsv, ...
                                 randomSeed, iCell, nCell)
%cellgeneratorstandalone   Generate ground truth markers 3D point cloud.
%   Model a ground truth 3D point cloud of biomarkers in a single
%   cell for microscopy image simulation. The point cloud is saved as a 
%   three columns .csv file containing each marker 3D coordinates.
%
% 	Inputs
%   ------
%       chromatinDatabase - String. Path to a folder of .mat files
%   containing chromatin chains configurations.
%       markerDistribution - Function handle that outputs a value randomly
%	picked from the distribution of distances along the chromatin chain
%   between two successive biomarkers. For instance, "@() 50*rand(1,1)"
%   will produce inter-marker distances following a uniform distribution
%   from 0 to 50 (arbitrary unit).
%       nChromatinChain - Int. Number of chromatin chains (chromozomes) to
%   model inside the cell (46 for human cells).
%       radiusArbitrary - Scalar. Radius in arbitrary units that will be
%   interpolated to the size of the final cell. Higher values produce cells
%   with high markers density near their center and low density near their
%   membrane. Lower values produce cells with homogeneous markers density,
%   but less markers in total. Default value should be ~350.
%       prune - Logical. If true, markers further away from the origin than
%   radius value will be removed from final cell. Else, the interpolation
%   still considers them as outside the cell, but they will be present in
%   the output coordinates .csv file.
%       cellSizeDistribution - Function handle that outputs a value
%   randomly picked from the distribution of cell sizes (µm). For instance,
%   "@() 5 + 7*rand(1,1)" will procduce cells with sizes along X, Y and Z
%   each independantly following a uniform distribution from 5 to 12.
%       outputCsv - String. Path to output .csv file containing markers 
%   coordinates.
%       randomSeed - Int, optional. Used as seed for random number
%   generator. If omitted, rng('shuffle') will be used,
%       iCell - Int, optional. Index of current cell. Used for
%   parallelization.
%       nCell - Int, optional. Number of cells in population. Used for 
%   parallelization.
%
%   Prerequisite
%   ------------
%       nChain must not be higher than the total number of chromatin
%   chains configurations in chromatinDatabase, which is the sum of the
%   number of configurations of each .mat file.
%       Either all or none of randomSeed, iCell and nCell must be provided.
%       If provided, iCell must be between 1 and nCell, included.
%
%   Notes
%   -----
%       All parameters support strings containing their value, in addition
%   to their aforementionned type.
%       randomSeed, iCell and nCell exist for parallelization. They should
%   be omitted otherwise. To paralellize generation of a cell population,
%   call cellgeneratorstandalone in each parallel thread/job with the same
%   parameters set. Provide a randomSeed value (same for every thread/job)
%   and the number nCell of cells in the population. Pass a unique iCell
%   value from 1 to nCell to each job/thread. This procedure ensures each
%   thread/job uses a statistically independant random number generator.
%
%   Example
%   -------
%       cellgeneratorstandalone('path/to/myDatabase', @() 50*rand(1,1), ...
%                               46, 350, true,  @() 5 + 7*rand(1,1), ...
%                               './markers.csv')
%
%   See also cellgenerator.

% Ensure correct input types
[radiusArbitrary, nChromatinChain, prune, markerDistribution, ...
 cellSizeDistribution] = valuesfromstrings({radiusArbitrary}, ...
   {nChromatinChain}, {prune}, {markerDistribution, cellSizeDistribution});
% Initialize random number generator.
nParallelArguments = exist('randomSeed', 'var') + ...
                     exist('iCell', 'var') + exist('nCell', 'var');
switch nParallelArguments
    case 0
        rng('shuffle')
    case 3
        globalrandomgenerator(randomSeed, iCell, nCell)
    otherwise
        error("Either all or none of randomSeed, iCell and nCell " + ...
              "must be provided, but only %i of them were.", ...
              nParallelArguments)
end
% Run application
[coordinateArbitrary] = cellgenerator(chromatinDatabase, ...
                                      markerDistribution, nChromatinChain);
cellSizeUm = [cellSizeDistribution(), cellSizeDistribution(), ...
              cellSizeDistribution()];
coordinateUm = scalecell(coordinateArbitrary, cellSizeUm, ...
                         radiusArbitrary, prune);
csvwrite(outputCsv, coordinateUm)