function [ind] = find_closest_edge(shape,point)
%FIND_CLOSEST_EDGE Locate the closest edge
    
    dists = zeros(size(shape,1),1);
    lagind = size(shape,1);
    for ii = 1 : size(shape,1)
        
        % Line parameterized as p1 + t (p1 - p2)
        % Find projection of point onto the line
        % It falls where t = [(p-v) . (w-v)] / |w-v|^2
        
        t = dot((point - shape(lagind,:)),shape(ii,:)-shape(lagind,:))/sum((shape(ii,:)-shape(lagind,:)).^2);
        
        if t < 0
            dists(ii) = norm(point-shape(lagind,:),2); %Beyond the start of the segment
        elseif t > 1
            dists(ii) = norm(point-shape(ii,:),2); %Beyond the end of the segment
        else
            dists(ii) = norm(shape(lagind,:)+t*(shape(ii,:)-shape(lagind,:)),2); % Projection falls on the segment
        end
        
        % Move the index
        lagind = ii;
        
    end
    
    [~,ind] = min(dists);

end

