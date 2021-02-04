function [img,psf,dzn]=model_LSF_3beam(ADN,lambda,n,NA,pixelsize,magnification,N,zrange,dz)
%% fonction qui mod�lise le PSF / le otf est le fft de PSF

dx=pixelsize/magnification;     % Sampling in lateral plane at the sample in um
dxn = lambda/(4*NA);          % 2*Nyquist frequency in x and y. ( nyquest frequency = res/2) 
Nn = ceil(N*dx/dxn/2)*2;      % Number of points at Nyquist sampling, even number ( Nyquist rate = 1/ 2*dxn); and nyquest sampling is perfect if was > 2* nyquest rate);; 
%%https://svi.nl/NyquistRate
dxn = N*dx/Nn;                % correct spacing
res = 0.5*(lambda)/(NA);           %% lateral resolution  wide field

oversampling = res/dxn;       % factor by which pupil plane oversamples the coherent psf data

dk=oversampling/(Nn/2);       % Pupil plane sampling
[kx,ky] = meshgrid(-dk*Nn/2:dk:dk*Nn/2-dk,-dk*Nn/2:dk:dk*Nn/2-dk);

kr=sqrt(kx.^2+ky.^2); 

% Raw pupil function, pupil defined over circle of radius 1.
csum=sum(sum((kr<1))); % normalise by csum so peak intensity is 1


alpha=asin(NA/n);
dzn=lambda/(2*n*(1-cos(alpha)));    % Nyquist sampling in z, reduce by 10% to account for gaussian light sheet
Nz=2*ceil(zrange/dz);
dz=2*zrange/Nz;
Nzn=2*ceil(zrange/dzn);
dzn=2*zrange/Nzn;
if Nz < Nzn
    Nz = Nzn;
    dz = dzn;
end
clear psf;
psf=zeros(Nn,Nn,Nzn);
c=zeros(Nn);

%fwhmz=(2*n*lambda)/NA^2;
%sigmaz=fwhmz/2.355;
sigmaz=0.75*(n*lambda)/NA^2; %% widefield axial resolution appriximated with sigma

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



%% Calculate 3D-OTF
disp('Creating 3D OTF');
otf = fftn(psf);
aotf = abs(fftshift(otf));



xyrange = Nn/2*dxn;
dkxy = pi/xyrange;
kxy = -Nn/2*dkxy:dkxy:(Nn/2-1)*dkxy;
dkz = pi/zrange;
kz = -Nzn/2*dkz:dkz:(Nzn/2-1)*dkz;


phasetilts=complex(single(zeros(Nn,Nn,Nzn,7)));
phase=complex(single(zeros(Nn,Nn,Nzn,7))); %vt

eta=1;
points=ADN;
npoints=size(ADN,1);
% parfor j = 1:7
parfor j = 1:7
    pxyz = complex(single(zeros(Nn,Nn,Nzn)));
      pxyzvt =complex(single(zeros(Nn,Nn,Nzn)));
     for i = 1:npoints
        x=points(i,1);
        y=points(i,2);
        z=points(i,3)+dz/7*(j-1); 
        ph=eta*4*pi*NA/lambda;
        p1=-j*2*pi/7;
        p2=j*4*pi/7;
         
         ill = 2/9*(3/2+cos(ph*(y)+p1-p2)...
                +cos(ph*(y-sqrt(3)*x)/2+p1)...
                +cos(ph*(-y-sqrt(3)*x)/2+p2));
        
        px = exp(1i*single(x*kxy));
        py = exp(1i*single(y*kxy));
        pz = exp(1i*single(z*kz))*ill;
       
        pxy = px.'*py;
        pzvt=exp(1i*single(z*kz));%vt
 
        for ii = 1:length(kz)
            pxyz(:,:,ii) = pxy.*pz(ii);
             pxyzvt(:,:,ii) = pxy.*pzvt(ii);%vt
        end
        phasetilts(:,:,:,j) = phasetilts(:,:,:,j)+pxyz;
        phase(:,:,:,j) = phase(:,:,:,j)+pxyzvt; % vt
    end
end



%% calculate output
img = zeros(N,N,Nz*7,'single');

for j = 1:7
    ootf = fftshift(otf) .*phasetilts(:,:,:,j);
    img(:,:,j:7:end) = abs(ifftn(ootf,[N N Nz]));  
            % OK to use abs here as signal should be all positive.
            % Abs is required as the result will be complex as the 
            % fourier plane cannot be shifted back to zero when oversampling.
            % But should reduction in sampling be allowed here (Nz<Nzn)?
end


% 
% %% calculate VT
% 
% VT= zeros(N,N,Nz*7,'single');
% 
% for j = 1:7
%     VTootf = (phase(:,:,:,j));
%     VT(:,:,j:7:end) =fftshift( abs(ifftn(VTootf,[N N Nz])));           
% end

end 
