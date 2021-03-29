function [markerCoordinate] = cellgenerator(chromatinDatabase, ...
                                            markerDistribution, nChain)
    %cellgenerator  Generate ground truth markers 3D point cloud.
    %   Model a ground truth 3D point cloud of biomarkers in a 
    %   single cell for microscopy image simulation. The point cloud is 
    %   returned as a three columns matrix containing each marker 3D
    %   coordinates.
    %
    % 	Inputs
    %   ------
    %       chromatinDatabase - String. Path to a folder of .mat files
    %   containing chromatin chains configurations.
    %       markerDistribution - Function handle that outputs a value
    %   randomly picked from the distribution of distances along the
    %   chromatin chain between two successive biomarkers. For instance,
    %   "@() 50*rand(1,1)" will produce inter-marker distances following a 
    %   uniform distribution from 0 to 50 (arbitrary unit).
    %       nChain - Int. Number of chromatin chains (chromozomes) to
    %   model inside the cell (46 for human cells).
    %
    %   Output
    %   ------
    %       markerCoordinate - nx3 double matrix of biomarkers 3D
    %   coordinates in arbitrary unit.
    %
    %   Prerequisite
    %   ------------
    %       nChain must not be higher than the total number of chromatin
    %   chains configurations in chromatinDatabase, which is the sum of the
    %   number of configurations of each .mat file.
    %
    %   Example
    %   -------
    %       cellgenerator('path/to/myDatabase', @() 50*rand(1,1), 46)
    %
    %   See also cellgeneratorstandalone.

    % Chromatin chains are stored in .mat files, each containing 'n'
    % configuration. We will pick the required number of random
    % configuration from them, using random permutations of indices.
    databaseContains = what(chromatinDatabase);
    allPermutation = cellfun(@(x) configurationpermutation(x), ...
                              databaseContains.mat, 'UniformOutput', ...
                              false);
    % Get the required number of chains by picking a random configuration
    % from each chain (each file in chromatinDatabase) and repeating until
    % nChains is reached.
    markerOnChain = cell(nChain, 1);
    for chainNo = 1:nChain
        nFile = uint8(size(databaseContains.mat, 1));
        fileNo = mod(chainNo, nFile) + 1; % Alternate database files.
        configurationNo = allPermutation{fileNo}(idivide(chainNo, ...
                                                         nFile, 'ceil'));
        allConfiguration = load(databaseContains.mat{fileNo}, 'Ensemble');
        iConfiguration = allConfiguration.Ensemble(configurationNo, :, :);
        % Position biomarkers along the chromatin chain
        markerOnChain{chainNo} = pointsoncurve(squeeze(iConfiguration), ...
                                               markerDistribution);
    end
    markerCoordinate = cell2mat(markerOnChain);
end

function permutation = configurationpermutation(configurationFile)
    %configurationpermutation  Return a permutation of indices in file.
    %   Return a permutation of indices of chromatin chain configurations
    %   contained in configurationFile.
    %
    % 	Input
    %   -----
    %       configurationFile - String. Name of a .mat file containing
    %   chromatin chains configurations. It should contain at least a
    %   numeric 'n' giving the number of configrations stored in the file,
    %   and an nxmx3 double matrix 'Ensemble' containing the n.
    %   configurations.
    %
    %   Output
    %   ------
    %       permutation - 1xn double vector. Random permutation of integers
    %   from 1 to n, indices of configurations contained in 
    %   configurationFile.
    %
    %   Example
    %   -------
    %       indices = configurationpermutation('database.mat')
    nConfiguration = load(configurationFile, 'n');
    permutation = randperm(nConfiguration.n);
end