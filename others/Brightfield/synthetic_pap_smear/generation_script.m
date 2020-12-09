%% Setup the basic starting image

disp('Creating image container')

image = newim(IMAGE_SIZE);

% Pad the image to handle objects placed on border
image = extend(image,IMAGE_SIZE+PADDING*[2 2]);

%% Generate cells

disp('Create/Load cells')

if USE_PREGENERATED == 1
    disp('Load cells')
    load data/pregen
    no_stored = size(cells,1);
    rp = randperm(no_stored);
    if no_stored < NO_CELLS
        tmpind = 1+round((no_stored-1)*rand(1,NO_CELLS-no_stored));
        rp = [rp tmpind];
    end
    cells = cells(rp(1:NO_CELLS),:);
    % Resize cells
    for ii = 1 : NO_CELLS
        cyt_size_offset = CYTOPLASM_SIZE_VARIATION(1)+rand*(CYTOPLASM_SIZE_VARIATION(2)-CYTOPLASM_SIZE_VARIATION(1));
        cells{ii,1} = resample(gaussf(cells{ii,1}),cyt_size_offset*[1 1]);
        cells{ii,2} = resample(cells{ii,2},cyt_size_offset*[1 1]);
        
        nuc_size_offset = NUCLEUS_SIZE_VARIATION(1)+rand*(NUCLEUS_SIZE_VARIATION(2)-NUCLEUS_SIZE_VARIATION(1));
        cells{ii,3} = resample(+cells{ii,3},nuc_size_offset*[1 1],0,'zoh')>0;
        cells{ii,4} = resample(cells{ii,4},nuc_size_offset*[1 1]);
    end
else
    disp('Create cells')
    % Container for cell objects
    cells = cell(NO_CELLS,4);
    for ii = 1 : NO_CELLS
        disp(['Cell ' num2str(ii) ' out of ' num2str(NO_CELLS)])
        % Create the random sizes for cells
        cyt_size_offset = CYTOPLASM_SIZE_VARIATION(1)+rand*(CYTOPLASM_SIZE_VARIATION(2)-CYTOPLASM_SIZE_VARIATION(1));
        nuc_size_offset = NUCLEUS_SIZE_VARIATION(1)+rand*(NUCLEUS_SIZE_VARIATION(2)-NUCLEUS_SIZE_VARIATION(1));
        
        disp('Creating the cytoplasm')
        % Cytoplasm shape and texture
        cyt_shape = generate_cytoplasm_shape(RESOLUTION,cyt_size_offset);
        [cyt_texture,cyt_mask] = generate_cytoplasm_texture(cyt_shape);
        disp('Creating the nucleus')
        % Nucleus shape and texture
        nuc_shape = generate_nucleus_shape(RESOLUTION,nuc_size_offset,rand<MALIGNANT_CHANCE);
        [nuc_texture,nuc_mask] = generate_nucleus_texture(nuc_shape,NUCLEUS_SAMPLING_FREQ,rand<MALIGNANT_CHANCE);
        % Store results
        cells(ii,:) = {cyt_mask,cyt_texture,nuc_mask,nuc_texture};
    end
    if USE_PREGENERATED == 2
        save data/pregen cells;
    end
end
disp('Applying absorbance values to cells')
% Apply absorbance values for the cells;
for ii = 1 : NO_CELLS
    % Add randomness
    cyt_tex_abs = CYTOPLASM_TEXTURE_ABSORBANCE(1)+rand*(CYTOPLASM_TEXTURE_ABSORBANCE(2)-CYTOPLASM_TEXTURE_ABSORBANCE(1));
    nuc_abs = NUCLEUS_ABSORBANCE(1)+rand*(NUCLEUS_ABSORBANCE(2)-NUCLEUS_ABSORBANCE(1));
    cells{ii,1} = cells{ii,1} * cyt_tex_abs;
    cells{ii,3} = cells{ii,3} * nuc_abs;
end

%% Create and distribute other objects for later addition to image

disp('Generate distributions for cells and debris')
% Generate the cell distribution in x-y coordinates
W = rr(IMAGE_SIZE)^3; W = extend((max(W)-W)/max(W),IMAGE_SIZE+PADDING*[2 2]);
celldistr = weighted_distribution(NO_CELLS,IMAGE_SIZE+PADDING*2,W);

% Create a cytoplasm distribution
cytoplasm_stack = newim([size(image),NO_CELLS]);
cytoplasm_mask_stack = newim([size(image),NO_CELLS]);
for ii = 1 : NO_CELLS
    % Find coordinates
    psz = size(cells{ii,1});
    x_bit = (celldistr(ii,1)-floor(psz(1)/2):celldistr(ii,1)+ceil(psz(1)/2)-1);
    y_bit = (celldistr(ii,2)-floor(psz(2)/2):celldistr(ii,2)+ceil(psz(2)/2)-1);
    
    % Add the mask to the ii:th level of the stack
    cytoplasm_mask_stack(x_bit,y_bit,ii-1) = cells{ii,1};
    
    % Add the texture to the ii:th level.
    
    % Add a base intensity which becomes less close to the boundary
    cyt_base_abs = CYTOPLASM_BASE_ABSORBANCE(1)+rand*(CYTOPLASM_BASE_ABSORBANCE(2)-CYTOPLASM_BASE_ABSORBANCE(1));
    cyt_thickness = dt(cells{ii,1}>0);
    cyt_thickness = (cyt_thickness / max(cyt_thickness))^(1/2);
    cytoplasm_stack(x_bit,y_bit,ii-1) = cells{ii,2}*mean(cells{ii,1}(cells{ii,1}>0))+cyt_base_abs*cyt_thickness;
end

% Create a nucleus distribution
nucleus_stack = newim([size(image),NO_CELLS]);
nucleus_mask_stack = newim([size(image),NO_CELLS]);
% Offset the nucleus positions so they do no always end up in the middle of
% the cytoplasm.
nucdistr = celldistr - round((NUCLEUS_POSITION_VARIATION/RESOLUTION)*(rand(size(celldistr))-0.5));
for ii = 1 : NO_CELLS
    % Find coordinates
    psz = size(cells{ii,3});
    x_bit = (nucdistr(ii,1)-floor(psz(1)/2):nucdistr(ii,1)+ceil(psz(1)/2)-1);
    y_bit = (nucdistr(ii,2)-floor(psz(2)/2):nucdistr(ii,2)+ceil(psz(2)/2)-1);
    
    % Add the mask to the ii:th level of the stack
    nucleus_mask_stack(x_bit,y_bit,ii-1) = cells{ii,3};
    
    % Add the texture to the ii:th level.
    targetGW = 10^(log10(255)-mean(cells{ii,3}(cells{ii,3}>0)));
    nucleus_stack(x_bit,y_bit,ii-1) = (-log10((cells{ii,4}+targetGW)/255))*(cells{ii,3}>0);
end

% Create bacilli clusters and distribution
if NO_BACILLI_CLUSTERS > 0
    % Create weightmap that limit the bacilli to the cytoplasm regions,
    % preferably closer to the edge
    W_mask = squeeze(max(cytoplasm_mask_stack,[],3))>0;
    W = dt(W_mask);
    W = gaussf(((max(W)-W)*W_mask),5);
    W = (W/max(W))^2;
    
    % Generate the bacilli cluster positions
    bacdistr = weighted_distribution(NO_BACILLI_CLUSTERS,IMAGE_SIZE+PADDING*2,W);
    
    disp('Create bacilli clusters')
    % Generate the bacilli clusters
    bacilli_stack = newimar(NO_BACILLI_CLUSTERS);
    for ii = 1 : NO_BACILLI_CLUSTERS
        % Cut out the weightmap around the region and use for individual
        % bac placements
        x_bit = bacdistr(ii,1)-floor(BACILLI_CLUSTER_SPREAD/2):bacdistr(ii,1)+ceil(BACILLI_CLUSTER_SPREAD/2)-1;
        y_bit = bacdistr(ii,2)-floor(BACILLI_CLUSTER_SPREAD/2):bacdistr(ii,2)+ceil(BACILLI_CLUSTER_SPREAD/2)-1;
        tmp_weightmap = W(x_bit,y_bit);
        % Generate the bacs
        no_bacilli = round(NO_BACILLI_PER_CLUSTER(1)+rand*(NO_BACILLI_PER_CLUSTER(2)-NO_BACILLI_PER_CLUSTER(1)));
        bacilli_stack{ii} = generate_bacilli_cluster(no_bacilli,tmp_weightmap,RESOLUTION);
    end
end

% Create clusters of white blood cells (WBC)
if NO_WBC_CLUSTERS > 0
    disp('Create WBC clusters')
    % Create the weights for the distribution
    W = extend(ones((IMAGE_SIZE))',IMAGE_SIZE+PADDING*2);
    
    % Generate the positions
    wbcdistr = weighted_distribution(NO_WBC_CLUSTERS,IMAGE_SIZE+PADDING*2,W);
    
    % Generate the wbc clusters
    wbc_stack = newimar(NO_WBC_CLUSTERS);
    for ii = 1 : NO_WBC_CLUSTERS
        % Generate the cluster
        wbc_stack{ii} = generate_wbc_cluster(NO_WBC_PER_CLUSTER,WBC_CLUSTER_SPREAD,WBC_ABSORBANCE,RESOLUTION);
    end
end

disp('Create speckles')
% Generate a speckle distribution
W = extend(ones((IMAGE_SIZE))',IMAGE_SIZE+PADDING*2);
speckle_coord = weighted_distribution(NO_SPECKLES,IMAGE_SIZE+2*PADDING,W);
speckle_offsets = [-1 -1;0 -1;-1 0;1 1]; % Used to add some small random shape to speckles

%% Add objects to the image. From lower Z-levels to higher

disp('Populating the image one Z-level at a time')
% Generate Z levels
if IMAGE_DEPTH~=0
    heightmap = cut(medif(dip_image(perlin_noise(max(IMAGE_SIZE+2*PADDING))*(IMAGE_DEPTH/Z_RESOLUTION),'uint8')),IMAGE_SIZE+2*PADDING);
    heightmap = hist_equalize(heightmap);
    heightmap = heightmap - mean(heightmap);
    heightmap = round(heightmap/max(abs(heightmap))*(IMAGE_DEPTH/Z_RESOLUTION)/2);
else
    heightmap = newim(IMAGE_SIZE+2*PADDING);
end
% Find Z level offset for each object coordinate
Z_cells = []; Z_wbc = Z_cells; Z_speckles = Z_cells;
if NO_CELLS > 0
    Z_cells = double(heightmap(sub2ind(heightmap,celldistr)));
end
if NO_WBC_CLUSTERS > 0
    Z_wbc = double(heightmap(sub2ind(heightmap,wbcdistr)));
end
if NO_SPECKLES > 0
    Z_speckles = double(heightmap(sub2ind(heightmap,speckle_coord)));
end
if NO_BACILLI_CLUSTERS > 0
    % For bacilli check which nucleus is closest for later pairing
    D = pdist2(bacdistr,celldistr);
    [~,closest] = min(D,[],2);
end

% Create map for placed debris
debris_map = newim(IMAGE_SIZE+2*PADDING);

z_levels = unique([Z_cells Z_wbc Z_speckles]);
% Build the image
for zz = 1 : length(z_levels)
    
    disp(['Z-level ' num2str(z_levels(zz))])
    %Create variable for storing the objects on this level
    lvlobj = newim(IMAGE_SIZE+2*PADDING);
    
    % Add cells and bacilli belonging to this level
    ind = find(Z_cells==z_levels(zz));
    for ii = 1 : length(ind)
        % Add cells
        lvlobj = lvlobj + squeeze(cytoplasm_stack(:,:,ind(ii)-1)); % Add cytoplasm
        lvlobj = lvlobj + squeeze(nucleus_stack(:,:,ind(ii)-1)); % Add nucleus
        
        if NO_BACILLI_CLUSTERS > 0
            % Add bacilli
            if any(ismember(ind(ii),closest)) % Add bacilli on the same Z-level as closest cell
                B = find(closest == ind(ii));
                for bb = 1 : length(B)
                    % Find coordinates
                    psz = size(bacilli_stack{B(bb)});
                    x_bit = (bacdistr(B(bb),1)-floor(psz(1)/2):bacdistr(B(bb),1)+ceil(psz(1)/2)-1);
                    y_bit = (bacdistr(B(bb),2)-floor(psz(2)/2):bacdistr(B(bb),2)+ceil(psz(2)/2)-1);
                    % Add bac-cluster to level image
                    lvlobj(x_bit,y_bit) = lvlobj(x_bit,y_bit) + bacilli_stack{B(bb)}*BACILLI_ABSORBANCE;
                    debris_map(x_bit,y_bit) = debris_map(x_bit,y_bit) + bacilli_stack{B(bb)};
                end
            end
        end
    end
    
    % Add wbc belonging to this level
    ind = find(Z_wbc==z_levels(zz));
    for ii = 1 : length(ind)
        % Get the coordinates
        psz = size(wbc_stack{ind(ii)});
        x_bit = (wbcdistr(ind(ii),1)-floor(psz(1)/2):wbcdistr(ind(ii),1)+ceil(psz(1)/2)-1);
        y_bit = (wbcdistr(ind(ii),2)-floor(psz(2)/2):wbcdistr(ind(ii),2)+ceil(psz(2)/2)-1);
        % Add the cluster
        lvlobj(x_bit,y_bit) = lvlobj(x_bit,y_bit) + wbc_stack{ind(ii)};
        debris_map(x_bit,y_bit) = debris_map(x_bit,y_bit) + wbc_stack{ind(ii)}>0;
    end
    
    % Add speckles belonging to this level
    ind = Z_speckles==z_levels(zz);
    if sum(ind>0)
        specks = label(coord2image(speckle_coord(ind,:),size(lvlobj)));
        for ii = 1 : max(specks)
            tmpspeck = specks == ii;
            tmpspeck = tmpspeck + circshift(tmpspeck,speckle_offsets(round(1+3*rand),:));
            speck_dil = round(SPECKLE_DILATION(1)+(SPECKLE_DILATION(2)-SPECKLE_DILATION(1))*rand);
            if speck_dil>0
                tmpspeck = bdilation(tmpspeck,speck_dil);
            end
            if (abs(z_levels(zz))) ~= 0 && SPECKLE_HALO
                tmpspeck = laplace(tmpspeck,abs(z_levels(zz)));
                tmpspeck(abs(tmpspeck)>0) = tmpspeck(abs(tmpspeck)>0) * -1;
            end
            %             tmpspeck(abs(tmpspeck)>0) = tmpspeck(abs(tmpspeck)>0) / max(abs(tmpspeck));
            lvlobj = lvlobj + tmpspeck*SPECKLE_ABSORBANCE;
            debris_map = debris_map + tmpspeck;
        end
    end
    
    % Now add the level to the composition image with the correct level of
    % blurring
    image = image + gaussf(lvlobj,abs(Z_RESOLUTION*z_levels(zz)));
end

%% Add out of focus noise objects

disp('Create and add out of focus blobs')
% Blobs
blobdistr = weighted_distribution(NO_BLOBS,IMAGE_SIZE+2*PADDING,W);
for ii = 1 : NO_BLOBS
    blob = generate_random_blob(MAX_BLOB_SIZE,5);
    psz = size(blob);
    x_bit = (blobdistr(ii,1)-floor(psz(1)/2):blobdistr(ii,1)+ceil(psz(1)/2)-1);
    y_bit = (blobdistr(ii,2)-floor(psz(2)/2):blobdistr(ii,2)+ceil(psz(2)/2)-1);
    pnoise = gaussf(perlin_noise(psz(1)),BLOB_DISTANCE);
    image(x_bit,y_bit) = image(x_bit,y_bit) + gaussf(blob*pnoise*BLOB_ABSORBANCE,BLOB_DISTANCE);
end

%% Create background plane

disp('Create background plane')
% Create the background
bg = newim(IMAGE_SIZE)+BG_INTENSITY;

% Create lighting unevenness from passing through sample
pnoise = cut(perlin_noise(max(IMAGE_SIZE)),IMAGE_SIZE);

% Uneven illumination
unewen_illum = rr(pnoise);
unewen_illum = (max(unewen_illum)-unewen_illum)+1;
unewen_illum = unewen_illum/max(unewen_illum);

bg = (bg - (BG_INTENSITY_VARIATION*pnoise))*(unewen_illum^BG_NONUNIFORM_STRENGTH);

%% Finish it up

disp('Finishing touches')
% Correct graylevels for overlapping cytoplasms and nuclei
cyt_overlap = squeeze(sum(cytoplasm_mask_stack>0,[],3));
cyt_overlap = (cyt_overlap>1)*squeeze(sum(cytoplasm_mask_stack,[],3));
% cyt_overlap = ((cyt_overlap>1)*(cyt_overlap-1))*mean(CYTOPLASM_ABSORBANCE);
if sum(cyt_overlap) > 0
    cyt_overlap = gaussf(cyt_overlap,3)/max(cyt_overlap);
    image = image / (CYTOPLASM_OVERLAP_ABS_FACTOR*cyt_overlap+1);
end

nuc_overlap = squeeze(sum(nucleus_mask_stack>0,[],3));
nuc_overlap = (nuc_overlap>1)*squeeze(sum(nucleus_mask_stack,[],3));
% nuc_overlap = ((nuc_overlap>1)*(nuc_overlap-1)) * mean(NUCLEUS_ABSORBANCE);
if sum(nuc_overlap > 0)
    nuc_overlap = gaussf(nuc_overlap,3)/max(nuc_overlap);
    image = image / (NUCLEUS_OVERLAP_ABS_FACTOR*nuc_overlap+1);
end

% Convert in [0 255] image space
final_image = 10^(log10(bg)-cut(image,IMAGE_SIZE));

% Preserve the nucleus textures since they already have been convoluted
nuclei_mask = cut(squeeze(max(nucleus_mask_stack,[],3))>0,IMAGE_SIZE);
% Remove debris and overlaps from preserved area
nuclei_mask = nuclei_mask-cut(debris_map>0,IMAGE_SIZE)-cut(squeeze(sum(nucleus_mask_stack>0,[],3)>1),IMAGE_SIZE);
nuclei_mask = berosion(nuclei_mask,2); % Make sure we get blurring on the edges
preserved = final_image(nuclei_mask);

% Apply PSF approximation
final_image = squeeze(gaussf(final_image,0.7));

% Add sensor noise
final_image(final_image < 0) = 0;
if POISSON_CONVERSION
    final_image = noise(final_image,'poisson',POISSON_CONVERSION);
end
if GAUSSIAN_WHITE_NOISE
    final_image = noise(final_image,'Gaussian',GAUSSIAN_WHITE_NOISE);
end
% Restore nuclei
final_image(nuclei_mask) = preserved;
nuclei_mask = cut(squeeze(max(nucleus_mask_stack>0,[],3)),IMAGE_SIZE);