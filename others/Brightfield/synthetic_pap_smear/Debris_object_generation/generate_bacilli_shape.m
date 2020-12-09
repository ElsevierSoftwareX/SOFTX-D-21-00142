function image = generate_bacilli_shape(RESOLUTION,angle)

% From measurements: 0.5-3 um length and 1um (~1px) width
l = (0.5+1*rand)/RESOLUTION;

% Generate mask image
image = newim((ceil(l)*2+1)*[1 1]);

% Generate a random direction 
no_angles = 360;
angles = linspace(0,2*pi,no_angles);
rp = randperm(no_angles);

% Draw the line
xt = ceil(l+1+l*cos(angles(rp(1)))); 
yt = ceil(l+1-l*sin(angles(rp(1))));
% xt = ceil(l+1+l*cos(angle)); 
% yt = ceil(l+1-l*sin(angle));
image = drawline(image, [floor(l+1) floor(l+1)], [xt yt], 1);
image = circshift(image,ceil(-[(xt-l) (yt-l)]/2));