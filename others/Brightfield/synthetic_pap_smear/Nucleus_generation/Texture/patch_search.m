function result = patch_search(source,patch_positions,patch,mode,w,d,patch_weights,curweight)

patch_size = size(patch);
scores = zeros(length(patch_positions),1);

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

rp = randperm(length(result));
result = result(rp(1));

function result = get_weighted_position(mode,source,overlap,patch_positions,patch_weights,curweight,d,w,patch_size)

% Set parameters and counters
counter = 1;
good_positions = [];
gp_scores = [];
scores = zeros(length(patch_positions),1);
new_positions = scores;
positions = patch_positions;

% Create probability values
P = 1-abs(patch_weights-curweight);     % P = the offset from the current distance value [0,1] where 1 is outside nucleus
            
while length(good_positions)<5 && counter<=length(patch_positions) % 10 is a magic number
    
    rp = randperm(length(P));   % Randomize the remaining positions
    tmp_P = P(rp);              
    inloop_counter = 1;
    done = 0;
    
    % Look at the randomly picked points if their P val is higher than
    % random value [0,1]
    
    while inloop_counter<=length(rp) && ~done
        if rand(1,1) <= tmp_P(inloop_counter)
            done = 1;
        else
            inloop_counter = inloop_counter + 1;
        end
    end
    
    % Now get the matching score for the accepted positions
    if done
        
        C = ind2sub(source,positions(rp(inloop_counter)));
        switch mode
            case 1
                match = source(C(1)-(patch_size(1)-1)/2-w:C(1)-(patch_size(1)-1)/2-1,...
                    C(2)-(patch_size(1)-1)/2:C(2)+(patch_size(1)-1)/2);
            case 2
                match = source(C(1)-(patch_size(1)-1)/2:C(1)+(patch_size(1)-1)/2,...
                    C(2)-(patch_size(1)-1)/2-w:C(2)-(patch_size(1)-1)/2-1);
            case 3
                match = cell(2,1);
                match{1} = source(C(1)-(patch_size(1)-1)/2-w:C(1)+(patch_size(1)-1)/2,...
                    C(2)-(patch_size(1)-1)/2-w:C(2)-(patch_size(1)-1)/2-1);
                match{2} = source(C(1)-(patch_size(1)-1)/2-w:C(1)-(patch_size(1)-1)/2-1,...
                    C(2)-(patch_size(1)-1)/2:C(2)+(patch_size(1)-1)/2);           
        end
        
        if mode ~= 3
            scores(counter) = sqrt(sum((match - overlap)^2)/(w*patch_size(1)));
        else
            scores(counter) = sqrt(sum(([match{1}(:) match{2}(:)] - [overlap{1}(:) overlap{2}(:)])^2)/length([match{1}(:) match{2}(:)]));
        end
        
        if scores(counter) <= d
            good_positions(end+1) = positions(rp(inloop_counter));
            gp_scores(end+1) = scores(counter);
        end
        
        new_positions(counter) = positions(rp(inloop_counter));
        P(rp(inloop_counter)) = [];
        positions(rp(inloop_counter)) = [];
        
    else
        scores(counter) = inf;
        [~,worst] = min(P);
        P(worst) = [];
        positions(worst) = [];
        
    end
    
    counter = counter + 1;
end

if length(good_positions)>2
    result = good_positions;
else
    [~,perm] = sort(scores);
    positions = new_positions(perm);
    result = positions(1:5);
end