function [otf,psf,Nn,dxn,Nz,Nzn,dzn]=model_PSF_2B_LSF(lambda,n,NA,pixelsize,magnification,N,zrange,dz,LSW)
% SIM psf calculation for 3-phase dual beam SIM with light sheet
% illumination and 2 in plane illumination beams over a single and 3
% illumination angles.
% Also calculates the conventional PSF along the way and transfer functions
% of all psfs.
% Finally calculates a z-stack over the 2-beam 3 orientation SIM psf.


dx=pixelsize/magnification;     % Sampling in lateral plane at the sample in um
dxn = lambda/(4*NA);          % 2*Nyquist frequency in x and y. ( nyquest frequency = res/2) 
Nn = ceil(N*dx/dxn/2)*2;      % Number of points at Nyquist sampling, even number ( Nyquist rate = 1/ 2*dxn); and nyquest sampling is perfect if was > 2* nyquest rate);; 
%%https://svi.nl/NyquistRate
dxn = N*dx/Nn;  
res=lambda/(2*NA);
oversampling = res/dxn;       % factor by which pupil plane oversamples the coherent psf data

dk=oversampling/(Nn/2);       % Pupil plane sampling
[kx,ky] = meshgrid(-dk*Nn/2:dk:dk*Nn/2-dk,-dk*Nn/2:dk:dk*Nn/2-dk);
kr=sqrt(kx.^2+ky.^2); 

% Raw pupil function, pupil defined over circle of radius 1.
csum=sum(sum((kr<1))); % normalise by csum so peak intensity is 1
alpha=asin(NA/n); 

%% IF LIGHT SHEET
if LSW ~=0 
    disp('Light SHEET MODE : ON');
dzn=0.8*lambda/(2*n*(1-cos(alpha)));    % Nyquist sampling in z, reduce by 10% to account for gaussian light sheet
fwhmz=LSW;
sigmaz=fwhmz/2.355;
else 
    disp('Light SHEET MODE: OFF');
sigmaz=0.75*(n*lambda)/NA^2; %% widefield axial resolution appriximated with sigma
dzn=lambda/(2*n*(1-cos(alpha)));    
end 
%%

Nz=2*ceil(zrange/dz);
dz=2*zrange/Nz;
Nzn=2*ceil(zrange/dzn);
dzn=2*zrange/Nzn;
% if Nz < Nzn
%     Nz = Nzn;
%     dz = dzn;
% end
clear psf;
psf=zeros(Nn,Nn,Nzn);
c=zeros(Nn);
% f is the factor by which the illumination grid frequency exceeds the
% incoherent cutoff, f=1 for normal SIM, f=sqrt(3) to maximise
% resolution without zeros in TF
f=1;
[x,y]=meshgrid(0:(Nn-1),0:(Nn-1));
x=f*(x-Nn/2)*2*pi/oversampling;
y=f*(y-Nn/2)*2*pi/oversampling;
cos1=cos(x);
cos2=cos(-0.5*x+sqrt(3)/2*y);
cos3=cos(-0.5*x-sqrt(3)/2*y);
nz=1;
% for z = -zrange:dzn:zrange-dzn
%     c=(kr<1.0).*exp(1i*z*n*2*pi/lambda*sqrt((1-kr.^2*NA^2/n^2)))*exp(-z^2/2/zw^2);
%     p=fftshift(abs(fft2(c)/csum).^2);
%     psf(:,:,nz)=p.*(1.5+cos1+cos2+cos3)/4.5;
%     nz = nz+1; 
% end
pupil = (kr<1);
for z = -zrange:dzn:zrange-dzn
    c(pupil) = exp(1i*(z*n*2*pi/lambda*sqrt((1-kr(pupil).^2*NA^2/n^2))));
    p= abs(fftshift(ifft2(c))).^2*exp(-z^2/2/sigmaz^2);
    psf(:,:,nz) = p.*(1.5+cos1+cos2+cos3)/4.5;
    
    nz = nz+1; 
end

pupil = (kr<1);
% Normalised so power in resampled psf (see later on) is unity in focal plane
psf = psf * Nn^2/sum(pupil(:))*Nz/Nzn; 



%% Calculate 3D-OTF
disp('Creating 3D OTF');
otf = fftn(psf);
aotf = abs(fftshift(otf));
end 