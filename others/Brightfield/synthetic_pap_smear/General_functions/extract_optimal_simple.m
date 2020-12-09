%% EXTRACT OPTIMAL SIMPLE 
% 
% Input: Nucleus stack & mask
%
% Will locate the focus image in the focus stack

function [res,ind] = extract_optimal_simple(stack,mask)

scores = squeeze(sum(sum(gaussf(stack)-stack,repmat(mask,1,1,size(stack,3)),1),[],2));
[~,ind] = max(scores);
res = squeeze(stack(:,:,ind));