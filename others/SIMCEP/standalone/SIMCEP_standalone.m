function [rgb, binary ]=SIMCEP_standalone(sizeX, sizeY, cells, clusters, clustP, ...
    clustVar, overlap, illumFactor, misalignX, misalignY, ...
    autofluoFactor, gaussVar, compArtefacts, cytoRadius, ...
    cytoShape1, cytoShape2, cytoTextPersist, cytoTextOctave1, ...
    cytoTextOctaveLast, cytoTextBias, nucRadius, nucShape1, ...
    nucShape2, nucTextPersist, nucTextOctave1, nucTextOctaveLast, ...
    nucTextBias, subcellN, subcellRadius, subcellShape1, ...
    subcellShape2, subcellTextPersist, subcellTextOctave1, ...
    subcellTextOctaveLast, subcellTextBias, output_prefix)

if ~isdeployed
    make_simcep
end

rng('shuffle')
if nargin>0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Parameters for population level simulation
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Define the size of the simulated image and part of the image where cells
    % will be simulated. For example, ones(500), results as a 500 x 500 image
    % where cells can be simulated in every part of the image.
    population.template = ones(todouble(sizeX), todouble(sizeY));
    % Amount of cells simulated in the image
    population.N = todouble(cells);
    % Amount of clusters
    population.clust = todouble(clusters);
    % Probability for assiging simulated cell into a cluster. Otherwise the
    % cell is uniformly distributed on the image.
    population.clustprob = todouble(clustP);
    % Variance for clustered cells
    population.spatvar = todouble(clustVar);
    % Amount of allowed overlap for cells [0,1]. For example, 0 = no overlap
    % allowed and 1 = overlap allowed.
    overlap = todouble(overlap);
    population.overlap = overlap ~= 0;
    % Is the overlap measured on nuclei (=1) level, or cytoplasm (=2) level
    population.overlap_obj = overlap; %Overlap: nuclei = 1, cytoplasm = 2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Parameters for the measurement system
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Energy of illumination compared to the energy of cells
    measurement.illumscale = todouble(illumFactor);
    % Misalignment of illumination source in x and y direction
    measurement.misalign_x = todouble(misalignX);
    measurement.misalign_y = todouble(misalignY);
    % Energy of autofluorescence compared to the energy of cells
    measurement.autofluorscale = todouble(autofluoFactor);
    % Variance of noise for ccd detector
    measurement.ccd = todouble(gaussVar);
    % Amount of compression artefacts
    measurement.comp = todouble(compArtefacts);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Cell level parameters
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Cytoplasm
    % Is cytoplasm included in the simulation ( 0 = no, 1 = yes)
    cytoRadius = todouble(cytoRadius);
    cell_obj.cytoplasm.include = cytoRadius ~= 0;
    % Cytoplasm radius
    cell_obj.cytoplasm.radius = cytoRadius;
    % Parameters for random shape
    cell_obj.cytoplasm.shape = [todouble(cytoShape1), todouble(cytoShape2)];
    % Parameters for texture: persistence, 1st octave, last octave, and
    % intensity bias
    cell_obj.cytoplasm.texture = [todouble(cytoTextPersist), ...
        todouble(cytoTextOctave1), todouble(cytoTextOctaveLast), ...
        todouble(cytoTextBias)];
    %%% Nuclei (see cytoplasm parameters for details)
    nucRadius = todouble(nucRadius);
    cell_obj.nucleus.include = nucRadius ~= 0;
    cell_obj.nucleus.radius = nucRadius;
    cell_obj.nucleus.shape = [todouble(nucShape1), todouble(nucShape2)];
    cell_obj.nucleus.texture = [todouble(nucTextPersist), ...
        todouble(nucTextOctave1), todouble(nucTextOctaveLast), ...
        todouble(nucTextBias)];
    %%% Subcellular parts (modeled as objects inside the cytoplasm; note cytoplasm
    %%% simulation needed for simulation of subcellular parts).
    subcellN = todouble(subcellN);
    subcellRadius = todouble(subcellRadius);
    cell_obj.subcell.include = subcellN && subcellRadius;
    % Number of subcellular objects
    cell_obj.subcell.ns = subcellN;
    % Radius of single object
    cell_obj.subcell.radius = todouble(subcellRadius);
    cell_obj.subcell.shape = [todouble(subcellShape1), ...
        todouble(subcellShape2)];
    cell_obj.subcell.texture = [todouble(subcellTextPersist), ...
        todouble(subcellTextOctave1), todouble(subcellTextOctaveLast), ...
        todouble(subcellTextBias)];
else
    simcep_options;
end

[rgb, binary, ~] = simcep(cell_obj, measurement, population);
imwrite(rgb, output_prefix + "final.tif");
object = ["cytoplasm", "subcell", "nucleus"];
for stack = 1:size(binary,3)
    if max(max(binary(:,:,stack)))
        imwrite(binary(:,:,stack), output_prefix + object(stack) + ".tif");
    end
end
end

function number = todouble(n_string)
    if isstring(n_string) || ischar(n_string)
        number = str2double(n_string);
    else
        number = n_string;
    end
end