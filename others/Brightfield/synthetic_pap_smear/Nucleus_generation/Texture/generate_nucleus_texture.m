% Patch based texture generation
function [texture,Is_mask,rawtex] = generate_nucleus_texture(Is_mask,no_sources,malignant)

%% Load sample data

% load ../../Data/nucleus_texture_samples
if ~malignant
    load nucleus_texture_samples % Assumes ../../Data in path
else
    load malignant_nucleus_texture_samples
end
Ia = cells(:,1); %#ok
Ia_mask = cells(:,2);

%% Constants

PATCH_SIZE = 7;         % ODD NUMBER PLEASE!
OVERLAP_SIZE = 2;       % Min 2, I think
MATCH_THRESH = 15;      % Not too sensitive
GRAYVAL_STD = 17;

%% Setup doner-images & target image

% Scale input image to match patch size and generate target image
Is_mask = extend(Is_mask,ceil(size(Is_mask)/PATCH_SIZE)*PATCH_SIZE);
Is = newim(Is_mask);

% Select cells to be used for sampling
randcells = randperm(size(cells,1));
Ia = Ia(randcells(1:no_sources));
Ia_mask = Ia_mask(randcells(1:no_sources));
Ia = normalize_cells(Ia,Ia_mask,110,GRAYVAL_STD);

%% Setup patches

% Generate patch selection list & weights for input cells and syntcells
patch_positions = cell(no_sources,1);
patch_weights_a = cell(no_sources,1);
for ii = 1 : no_sources
    patch_positions{ii} = find(berosion(Ia_mask{ii},(PATCH_SIZE-1)/2,-2));
    patch_weights_a{ii} = dt(Ia_mask{ii})/max(dt(Ia_mask{ii}));
    patch_weights_a{ii} = patch_weights_a{ii}(patch_positions{ii});
end

patch_weights_s = dt(Is_mask)/max(dt(Is_mask));
patch_weights_s(~Is_mask) = 1;

% Randomly select first patch and which cell to get it from
randcells = randperm(no_sources);
randpatch = randperm(length(patch_positions{randcells(1)})); % First patch

%% Prepare main loop

% Initialize counters
patch_no_x = size(Is,1)/PATCH_SIZE;
patch_no_y = size(Is,2)/PATCH_SIZE;
current_patch = 1;
used_patches = [];

% Place first patch in new image
C = ind2sub(Ia{randcells(1)},patch_positions{randcells(1)}(randpatch(1)));
tmp_patch = Ia{randcells(1)}(-(PATCH_SIZE-1)/2+C(1):(PATCH_SIZE-1)/2+C(1),-(PATCH_SIZE-1)/2+C(2):(PATCH_SIZE-1)/2+C(2));
[p1,p2] = ind2sub([patch_no_x patch_no_y],current_patch);
Is((p1-1)*PATCH_SIZE:p1*PATCH_SIZE-1,(p2-1)*PATCH_SIZE:p2*PATCH_SIZE-1) = rot90(tmp_patch);
current_patch = current_patch + 1;
used_patches(end+1,1:2) = [randcells(1) , patch_positions{randcells(1)}(randpatch(1))];

%% Main loop

% Now rinse and repeat
while current_patch <= patch_no_x*patch_no_y
    
    % Three search options are encountered
    [p1,p2] = ind2sub([patch_no_x patch_no_y],current_patch);
    cur_weight = double(patch_weights_s((p1-1)*PATCH_SIZE+(PATCH_SIZE-1)/2,(p2-1)*PATCH_SIZE+(PATCH_SIZE-1)/2));
    if p2 == 1 % First row (except first patch)
        patch = Is((p1-2)*PATCH_SIZE:(p1-1)*PATCH_SIZE-1,(p2-1)*PATCH_SIZE:p2*PATCH_SIZE-1);
        new_patch_pos = multicell_patch_search(...
            Ia,...
            patch_positions,...
            patch,...
            1,...
            OVERLAP_SIZE,...
            MATCH_THRESH,...
            patch_weights_a,...
            cur_weight);
        C = ind2sub(Ia{new_patch_pos(1)},new_patch_pos(2));
        new_patch = Ia{new_patch_pos(1)}(...
            -OVERLAP_SIZE-(PATCH_SIZE-1)/2+C(1):(PATCH_SIZE-1)/2+C(1),...
            -(PATCH_SIZE-1)/2+C(2):(PATCH_SIZE-1)/2+C(2));
        Is((p1-2)*PATCH_SIZE:(p1)*PATCH_SIZE-1,(p2-1)*PATCH_SIZE:p2*PATCH_SIZE-1) = ...
            patch_blend(patch,new_patch,OVERLAP_SIZE,1);      
    elseif p2 > 1 && p1 == 1 % First patch of each row after first one
        patch = Is((p1-1)*PATCH_SIZE:(p1)*PATCH_SIZE-1,(p2-2)*PATCH_SIZE:(p2-1)*PATCH_SIZE-1);
        new_patch_pos = multicell_patch_search(...
            Ia,...
            patch_positions,...
            patch,...
            2,...
            OVERLAP_SIZE,...
            MATCH_THRESH,...
            patch_weights_a,...
            cur_weight);
        C = ind2sub(Ia{new_patch_pos(1)},new_patch_pos(2));
        new_patch = Ia{new_patch_pos(1)}(...
            -(PATCH_SIZE-1)/2+C(1):(PATCH_SIZE-1)/2+C(1),...
            -OVERLAP_SIZE-(PATCH_SIZE-1)/2+C(2):(PATCH_SIZE-1)/2+C(2));
        Is((p1-1)*PATCH_SIZE:(p1)*PATCH_SIZE-1,(p2-2)*PATCH_SIZE:p2*PATCH_SIZE-1) = ...
            patch_blend(patch,new_patch,OVERLAP_SIZE,2);
    else % The rest, two contact areas (top and left)
        patch = Is((p1-2)*PATCH_SIZE:(p1)*PATCH_SIZE-1,(p2-2)*PATCH_SIZE:(p2)*PATCH_SIZE-1);
        new_patch_pos = multicell_patch_search(...
            Ia,...
            patch_positions,...
            patch,...
            3,...
            OVERLAP_SIZE,...
            MATCH_THRESH,...
            patch_weights_a,...
            cur_weight);
        C = ind2sub(Ia{new_patch_pos(1)},new_patch_pos(2));
        new_patch = Ia{new_patch_pos(1)}(...
            C(1)-(PATCH_SIZE-1)/2-OVERLAP_SIZE:C(1)+(PATCH_SIZE-1)/2,...
            -OVERLAP_SIZE-(PATCH_SIZE-1)/2+C(2):(PATCH_SIZE-1)/2+C(2));
        Is((p1-2)*PATCH_SIZE:(p1)*PATCH_SIZE-1,(p2-2)*PATCH_SIZE:p2*PATCH_SIZE-1) = ...
            patch_blend(patch,new_patch,OVERLAP_SIZE,3);
    end
    used_patches(end+1,1:2) = new_patch_pos;
    current_patch = current_patch + 1;
end

%% Prepare output

% Rescale the gravalues to match absorbance  # MOVED TO MAIN LOOP
% targetGW = 10^(log10(255)-absorbance);
% Is = Is-(mean(Is(Is_mask))-targetGW);
% S = -inf;
% for ii  = 1 : no_sources
%     Sc = std(Ia{ii}(Ia_mask{ii}));
%     if Sc > S
%         S = Sc;
%     end
% end
rawtex = Is;
Is = Is - mean(Is(Is_mask));
Is = Is / std(Is(Is_mask));
Is = Is * GRAYVAL_STD;

% Clip the image
C = findcoord(Is_mask);
cmin = min(C);cmax = max(C);
Is_mask = Is_mask(cmin(1):cmax(1),cmin(2):cmax(2));
texture = Is(cmin(1):cmax(1),cmin(2):cmax(2));
