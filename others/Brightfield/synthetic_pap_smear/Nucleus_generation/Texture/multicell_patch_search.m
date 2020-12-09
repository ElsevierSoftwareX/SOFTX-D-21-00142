function result = multicell_patch_search(source,patch_positions,patch,mode,w,d,patch_weights,curweight)

patch_size = size(patch);

switch mode
    case 1 % Only left
        overlap = patch(end-w+1:end,0:patch_size(2)-1);
        result = get_weighted_position(mode,source,overlap,patch_positions,patch_weights,curweight,d,w,patch_size);
    case 2 % Only top
        overlap = patch(0:patch_size(1)-1,end-w+1:end);
        result = get_weighted_position(mode,source,overlap,patch_positions,patch_weights,curweight,d,w,patch_size);
    case 3 % Left and top
        patch_size = patch_size./2;
        overlap = cell(2,1);
        overlap{1} = patch(patch_size(1)-w:end,patch_size(1)-w:patch_size(1)-1);
        overlap{2} = patch(patch_size(1)-w:patch_size(1)-1,patch_size(1):end);
        result = get_weighted_position(mode,source,overlap,patch_positions,patch_weights,curweight,d,w,patch_size);
end

rp = randperm(size(result,1));
result = result(rp(1),:);

function result = get_weighted_position(mode,source,overlap,patch_positions,patch_weights,curweight,d,w,patch_size)

% Set parameters and counters
counter = 1;
good_positions = [];
gp_scores = [];
scores = zeros(sum(cellfun('size', patch_positions, 1)),1);
new_positions = [scores scores];
positions = patch_positions;

% Create probability values
P = patch_weights;
for ii = 1 : length(P)
    P{ii} = 1-abs(P{ii}-curweight);     % P = the offset from the current distance value [0,1] where 1 is outside nucleus
end

while size(good_positions,1)<5 && counter<=length(scores) % 5 is a magic number
    
    cellrand = randperm(length(P));
    while(isempty(P{cellrand(1)}))
        cellrand = circshift(cellrand,[0 -1]);
    end
    
    % WARNING FOLLOWING LINE MIGHT BUG
    posrand = randperm(length(P{cellrand(1)}))-1; % Randomize the remaining positions
    tmpP = P{cellrand(1)}(posrand);
    inloop_counter = 1;
    done = 0;
    
    % Look at the randomly picked points if their P val is higher than
    % random value [0,1]
    
    while inloop_counter<=length(posrand) && ~done
        if rand(1,1) <= tmpP(inloop_counter-1)
            done = 1;
        else
            inloop_counter = inloop_counter + 1;
        end
    end
    
    % Now get the matching score for the accepted positions
    if done
  
        C = ind2sub(source{cellrand(1)},positions{cellrand(1)}(posrand(inloop_counter)+1));

        switch mode
            case 1
                match = source{cellrand(1)}(C(1)-(patch_size(1)-1)/2-w:C(1)-(patch_size(1)-1)/2-1,...
                    C(2)-(patch_size(1)-1)/2:C(2)+(patch_size(1)-1)/2);
            case 2
                match = source{cellrand(1)}(C(1)-(patch_size(1)-1)/2:C(1)+(patch_size(1)-1)/2,...
                    C(2)-(patch_size(1)-1)/2-w:C(2)-(patch_size(1)-1)/2-1);
            case 3
                match = cell(2,1);
                match{1} = source{cellrand(1)}(C(1)-(patch_size(1)-1)/2-w:C(1)+(patch_size(1)-1)/2,...
                    C(2)-(patch_size(1)-1)/2-w:C(2)-(patch_size(1)-1)/2-1);
                match{2} = source{cellrand(1)}(C(1)-(patch_size(1)-1)/2-w:C(1)-(patch_size(1)-1)/2-1,...
                    C(2)-(patch_size(1)-1)/2:C(2)+(patch_size(1)-1)/2);
        end
        
        if mode ~= 3
            scores(counter) = sqrt(sum((match - overlap)^2)/(w*patch_size(1)));
        else
            scores(counter) = sqrt(sum(([match{1}(:) match{2}(:)] - [overlap{1}(:) overlap{2}(:)])^2)/length([match{1}(:) match{2}(:)]));
        end
        
        if scores(counter) <= d
            good_positions(end+1,1:2) = [cellrand(1) positions{cellrand(1)}(posrand(inloop_counter)+1)];
            gp_scores(end+1) = scores(counter);
        end
        
        new_positions(counter,1:2) = [cellrand(1) positions{cellrand(1)}(posrand(inloop_counter)+1)];
        tmpP = tmpP([0:posrand(inloop_counter)-1,posrand(inloop_counter)+1:length(tmpP)-1]);
        positions{cellrand(1)} = positions{cellrand(1)}([1:posrand(inloop_counter)-1,posrand(inloop_counter)+1:length(positions{cellrand(1)})]);
        
    else
        scores(counter) = inf;
        [~,worst] = min(tmpP);
        tmpP = tmpP([0:worst-1,worst+1:length(tmpP)-1]);
        positions{cellrand(1)}(worst+1) = []; 
    end
    
    P{cellrand(1)} = tmpP;
    counter = counter + 1;
end

if size(good_positions,1)>0
    result = good_positions;
else
    [~,perm] = sort(scores);
    positions = new_positions(perm,:);
    result = positions(1:5,:);
end