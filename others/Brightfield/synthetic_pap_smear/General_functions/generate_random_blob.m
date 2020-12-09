function blob = generate_random_blob(max_size,sigma)

blob = newim(max_size*[1 1]);
blob_size = max_size / 3;
min_size = 0.3*blob_size;
sz = min_size + (blob_size-min_size)*rand;
t = (1/16:1/8:1)'*2*pi;
x = sin(t);
y = cos(t);
C = [x y];
C = C + 0.30*(rand(8,2)-0.5);
C = C*sz + ones(8,2)*0.5*max_size;

blob = fillholes(drawpolygon(blob,C,1,'closed')>0);

blob = gaussf(blob*perlin_noise(max_size),sigma);