function [psf,dxn, dzn]=model_PSF_CF(lambda,n,NA,pixelsize,magnification,N,zrange,dz)
%% fonction qui mod�lise le PSF / le otf est le fft de PSF

dx=pixelsize/magnification;     % Sampling in lateral plane at the sample in um
dxn = lambda/(4*NA);          % 2*Nyquist frequency in x and y. ( nyquest frequency = res/4 confocal case) 
Nn = ceil(N*dx/dxn/2)*2;      % Number of points at Nyquist sampling, even number ( Nyquist rate = 1/ 2*dxn); and nyquest sampling is perfect if was > 2* nyquest rate);; 
%%https://svi.nl/NyquistRate
dxn = N*dx/Nn;                % correct spacing
res = 0.41*(lambda)/(NA);           %% lateral resolution  wide field

oversampling = res/dxn;       % factor by which pupil plane oversamples the coherent psf data

dk=oversampling/(Nn/2);       % Pupil plane sampling
[kx,ky] = meshgrid(-dk*Nn/2:dk:dk*Nn/2-dk,-dk*Nn/2:dk:dk*Nn/2-dk);

kr=sqrt(kx.^2+ky.^2); 

% Raw pupil function, pupil defined over circle of radius 1.
csum=sum(sum((kr<1))); % normalise by csum so peak intensity is 1


alpha=asin(NA/n);
dzn=lambda/(2*n*(1-cos(alpha)));    % Nyquist sampling in z, 
Nzn=2*ceil(zrange/dzn);
dzn=2*zrange/Nzn;
Nz=max(2*ceil(zrange/dz), Nzn);

clear psf;
psf=zeros(Nn,Nn,Nzn);
c=zeros(Nn);

%fwhmz=(2*n*lambda)/NA^2;
%sigmaz=fwhmz/2.355;
sigmaz=0.53*(n*lambda)/NA^2; %% confocal axial resolution appriximated with sigma

pupil = (kr<1);


%% Calculate 3d PSF
nz = 1;
disp('Creating 3D PSF');

for z = -zrange:dzn:zrange-dzn
    c(pupil) = exp(1i*(z*n*2*pi/lambda*sqrt((1-kr(pupil).^2*NA^2/n^2))));
    psf(:,:,nz) = abs(fftshift(ifft2(c))).^2*exp(-z^2/2/sigmaz^2);
    nz = nz+1; 
end

% Normalised so power in resampled psf (see later on) is unity in focal plane
psf = psf * Nn^2/sum(pupil(:))*Nz/Nzn; 

end 
