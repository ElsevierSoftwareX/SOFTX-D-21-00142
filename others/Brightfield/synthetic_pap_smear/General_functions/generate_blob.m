function blob = generate_blob(spread)

C = round(spread*rand(3,2));                                        % Base points
D = squareform(pdist(C));
[~,S] = min(sum(D,2));                                              % Find startpoint
[~,P] = sort(D(S,:));                                               % Order other two points startpoint
blob = drawpolygon(newim([1 1]*spread),C([S P(2:3)],:),1,'open');      % Initial weights
blob = gaussf(extend(blob,2*spread*[1 1]),spread/4);
blob = blob / max(blob);