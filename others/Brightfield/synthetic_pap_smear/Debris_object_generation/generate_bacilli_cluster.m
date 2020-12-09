function cluster = generate_bacilli_cluster(no_obj,weight_patch,resolution)

pad_dist = round(4/resolution); % px

im = newim(weight_patch);
% w = rr(im);
% w = (max(w) - w)^5;
% w = w / max(w);
padim = extend(im,size(weight_patch)+pad_dist*2*[1 1]);
padw = extend(weight_patch,size(padim));

C = weighted_distribution(no_obj,size(padim),padw);

xprim = dx(weight_patch);
yprim = dy(weight_patch);

for ii = 1 : no_obj
    
%     cc = C(ii,:)-pad_dist*[1 1];
%     D = double([xprim(cc(1),cc(2));yprim(cc(1),cc(2))]);
%     D = D / norm(D,2);
%     angle = atan(D(1)/D(2)); % Set angle as being orthogonal to gradient
%     angle = angle+0.4*randn; % Randomize a little
    angle = rand;
    
    shape = generate_bacilli_shape(resolution,angle);
    shapesz = size(shape);
    x_bit = C(ii,1)-floor(shapesz(1)/2):C(ii,1)+ceil(shapesz(1)/2)-1;
    y_bit = C(ii,2)-floor(shapesz(2)/2):C(ii,2)+ceil(shapesz(2)/2)-1;
    
    padim(x_bit,y_bit) = padim(x_bit,y_bit) + shape;
    
end

C = findcoord(padim>0);
cluster = padim(min(C(:,1)):max(C(:,1)),min(C(:,2)):max(C(:,2)));


