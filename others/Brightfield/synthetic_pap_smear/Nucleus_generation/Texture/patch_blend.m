function result = patch_blend(base,new,w,mode)

patch_size = size(base);


switch mode
    case 1 % Feather left
        result = newim([patch_size(1)*2 patch_size(2)]);
        result(0:patch_size(1)-w-1,:) = base(0:patch_size(1)-w-1,:);
        for ii = 1 : w
            a = ii/sqrt(w); % Weights for blending, weighted based on euclidean distance in 3
            result(patch_size(1)-w-1+ii,:) = (1-a)*base(patch_size(1)-w,:) + a*new(ii-1,:);
        end
        result(patch_size(1):end,:) = new(w:end,:);
    case 2 % Feather top
        result = newim([patch_size(1) patch_size(2)*2]);
        result(:,0:patch_size(2)-w-1) = base(:,0:patch_size(2)-w-1);
        for ii = 1 : w
            a = ii/sqrt(w);
            result(:,patch_size(2)-w-1+ii) = (1-a)*base(:,patch_size(2)-w) + a*new(:,ii-1);
        end
        result(:,patch_size(2):end) = new(:,w:end);
    case 3 % Feather top & left
        result = newim(patch_size);
        patch_size = patch_size./2;
        result(:,0:patch_size(1)-w-1) = base(:,0:patch_size(1)-w-1);
        result(0:patch_size(1)-w-1,:) = base(0:patch_size(1)-w-1,:);
        
        % Set the weights using dt
        weights = newim(new,'bin');
        weights(end-patch_size(1)+1:end,end-patch_size(2)+1:end) = 1;
        weights = dt(~weights)/max(dt(~weights));
        
        result(patch_size(1)-w:end,patch_size(1)-w:end) = ...
            base(patch_size(1)-w:end,patch_size(1)-w:end)*weights+new*(1-weights);
end