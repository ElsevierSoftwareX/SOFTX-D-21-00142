function chain_chrom_standalone(distribfun,DC, radius, prune,  ...
    output_file, seed, streamIndex, numStreams)
% Calls chain_chrom and store outputs in a .mat file
% This is meant to be packaged as a standalone applicatio
% INPUTS:
% distribfun - function picking a value in a distribution. For
% instance, with @() 10*rand(1,1) distances between fluorophores
% along a chromatin chain will follow a uniform distribution from 0 to
% 10. distribfun should not have parameters.
% DC - number of chromatin chains to generate
% output_file - path to the output .mat file to save

if nargin < 6
    rng('shuffle')
else
    if isstring(seed) || ischar(seed)
        seed = str2double(seed);
    end
    if isstring(streamIndex) || ischar(streamIndex)
        streamIndex = str2double(streamIndex);
    end
    if isstring(numStreams) || ischar(numStreams)
        numStreams = str2double(numStreams);
    end
    randStr = RandStream.create('mlfg6331_64','NumStreams',numStreams, ...
        'Seed', seed, 'StreamIndices', streamIndex);
    RandStream.setGlobalStream(randStr)
end
% When calling standalone application, all parameters will be strings.
% Here we convert them
if isstring(distribfun) || ischar(distribfun)
    distribfun = str2func(distribfun);
end
if isstring(DC) || ischar(DC)
    DC = str2double(DC);
end
if isstring(radius) || ischar(radius)
    radius = str2double(radius);
end
if isstring(prune) || ischar(prune)
    prune = logical(str2double(prune));
end
% Run application
[~, markers_raw]=chain_chrom(distribfun,DC);
markers_scaled = inter_inFOV(markers_raw, radius, prune);
csvwrite(output_file, markers_scaled)
%save(output_file, 'chains', 'markers_raw', 'markers_scaled')

