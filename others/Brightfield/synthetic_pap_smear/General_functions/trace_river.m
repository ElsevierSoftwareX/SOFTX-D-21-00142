function mask = trace_river(P,I,V,N,mask,S)

% Pick out neighbours and their coordinates
neigh = N{P};
neigh_coords = sub2ind(I,V(neigh,:));

% See which neighbour has the steepest slope
slopes = I(neigh_coords)-double(I(V(P,1),V(P,2)));
[sort_slopes,perm] = sort(double(slopes));
newP = neigh(perm(1));

% Recursively follow the next point and perhaps branch out a bit
if sort_slopes(1)<0
    mask = drawline(mask,[V(P,1) V(P,2)],[V(newP,1) V(newP,2)],1);
    if ~(I(V(newP,1),V(newP,2))==0)
        mask = trace_river(newP,I,V,N,mask,S);
        newP = neigh(perm(2)); % Branching
        if sort_slopes(2)<0 && rand < S && ~(I(V(newP,1),V(newP,2))==0)
%             disp(['Branching at ' num2str(P) ' towards ' num2str(newP)])
            mask = drawline(mask,[V(P,1) V(P,2)],[V(newP,1) V(newP,2)],1);
            mask = trace_river(newP,I,V,N,mask,S);         
        end
    end
end