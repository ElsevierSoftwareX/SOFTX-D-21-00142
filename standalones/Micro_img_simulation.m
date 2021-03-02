function [img,GT,psf]=Micro_img_simulation(ADN,lambda,n,NA,pixelsize, ...
    magnification,N,zrange,dz,tau,nphot,Var_GN,Mean_GN,Cell_speed, ...
    shutter_speed, frame_rate, microscope, fwhmz)
% microscope=1 : widefield (WF) (Fast),
% microscope=2 confocal (CF) (a litle bit slow: nyquest samplate rate is smaller then the case of WF
% microscope=3 LSF avec 2 beam  ( 3 phase shift) (Fast)
% microscope=4 LSF avec 3 beam (very slow due to 7 phase shift) 
% tau = 0 for no photobleaching
% Cell_speed = 0 for no motion blur
% nphot = 0 for no Poisson noise
% Var_GN = 0 AND Mean_GN = 0 for no Gaussian noise

if Cell_speed
    if microscope == 2
        warning("Confocal mcroscope can't be used with microfluidics" ...
            + "\n cell speed will be considered to be 0.")
        Cell_speed=0;
    else
        disp("Using microfluidics, dz willl be determined from cell "...
            + "speed and frame rate.")
        dz=Cell_speed/frame_rate;
    end
end
%% mod�lisation de PSF
if microscope~=4
    switch(microscope)
        case{1}
            disp('Simulating WF PSF model');
            [psf,dxn, dzn]=model_PSF_WF(lambda,n,NA,pixelsize, ...
                magnification,N, zrange,dz, fwhmz);
        case{2}
            disp('Simulating CF PSF model');
            [psf,dxn, dzn]=model_PSF_CF(lambda,n,NA,pixelsize, ...
                magnification,N, zrange,dz, fwhmz);
        case{3}
           disp('Simulating LSF 2 beam PSF model');
           [psf,dxn, dzn]=model_PSF_2B_LSF(lambda,n,NA,pixelsize, ...
               magnification,N,zrange,dz, fwhmz);
        otherwise
            error("Unknown microscope type: %i\nmicroscope must be " ...
                + "1, 2, 3 or 4", microscope)
    end 
    %% conversion de  la nuages do point dans une image en espace de fourier
    Nn=size(psf,1);
    Nzn=size(psf,3);
    Nz = max(2*ceil(zrange/dz), Nzn);
    disp('Creating 3D OTF');
    otf = fftn(psf);
    disp('Creating image of 3D point cloud');
    xyrange = Nn/2*dxn;
    dkxy = pi/xyrange;
    kxy = -Nn/2*dkxy:dkxy:(Nn/2-1)*dkxy;
    dkz = pi/zrange;
    kz = -Nzn/2*dkz:dkz:(Nzn/2-1)*dkz;

    points2img=complex(single(zeros(Nn,Nn,Nzn))); % images des points en espace de fourrier
    pxyz = complex(single(zeros(Nn,Nn,Nzn)));     
    for it = 1:size(ADN,1)
         x=ADN(it,1);
         y=ADN(it,2);
         z=ADN(it,3); 

         px = exp(1i*single(x*kxy));
         py = exp(1i*single(y*kxy));
         pz = exp(1i*single(z*kz)); 
         pxy = px.'*py;

            for ii = 1:length(kz)
                pxyz(:,:,ii) = pxy.*pz(ii); 
            end
            points2img = points2img+pxyz;      
    end
    %% GT
    %VT=fftshift(abs(ifftn(points2img,[N N Nz])));    
    %% Cr�ation de l'image microscopique finale: 
    disp('Creating 3D microscopy image');
    ootf = fftshift(otf) .*points2img;
    img = abs(ifftn(ootf,[N N Nz]));  
%%
else
     disp('Simulating LSF 3 beam PSF model');
    [img,psf,dzn]=model_LSF_3beam(ADN,lambda,n,NA,pixelsize, ...
        magnification,N,zrange,dz, fwhmz);
end

%%GT
N = size(img, 1);
n_frames = size(img, 3);
if microscope==4
    n_frames = n_frames / 7; % 7 phase shifts
end
fluo_z = ADN(:, 3);
fluo_coords = ADN(:, 1:2);
% Scale coordinates in pixels
fluo_pixels = fluo_coords * magnification / pixelsize;
fluo_frame = fluo_z / dz;
% Shift to center in the image
fluo_pixels = ceil(fluo_pixels + N/2);
fluo_frame = ceil(fluo_frame + n_frames/2);
in_image = all(fluo_pixels > 0, 2)  & all(fluo_pixels <= N, 2) ...
    & (fluo_frame > 0) & (fluo_frame <= n_frames);
fluo_coords = fluo_pixels(in_image,:);
fluo_z = fluo_frame(in_image,:);
GT = zeros(N, N, n_frames);
fluo_indices = sub2ind([N, N, n_frames], fluo_coords(:, 1), ...
    fluo_coords(:, 2), fluo_z);
GT(fluo_indices) = 1;
if microscope==4
    % duplicate each frame 7 times
    reshaped = reshape(GT, N*N, []); % reshape in 2D : 1 column for each frame
    reshaped = repmat(reshaped, 7, 1); % repeat each column 7 times
    GT = reshape(reshaped, N, N, []); % reshape in correct dimansions
end
 
%% photobleaching
if tau
    disp('Adding photo bleaching...');
    parfor it=1:size(img,3)
        img(:,:,it) =img(:,:,it)*exp(-(it-1)/tau);
    end 
end
%% adding motion blur effect % always before poisson and gaussian noise addition
if Cell_speed
    shutter_speed=1/shutter_speed; 
    mbz_um=Cell_speed*shutter_speed; % motion blur size 
    mbz_px=ceil(mbz_um/dzn); 
    MB=fspecial('motion',mbz_px, 0); 
    disp(['Adding motion blur. Pixel length is ',num2str(mbz_px),' pixels']);% and orientation is ',num2str(orient)]);
    parfor it=1:size(img,1)
        img(it,:,:)=conv2(squeeze(img(it,:,:)),MB,'same');   % motion blur applied to YZ
    end 
end
 
%% Add poisson noise and recalculate, uncomment to simulate noisy data % always before gaussian noise
if nphot
    disp('Adding poisson noise...');
    img = poissrnd(img*nphot);
end
 %%   add gaussian noise (thermal and read noise) 
if Mean_GN || Var_GN
     disp('Adding thermal and read noise...');
     parfor it=1:size(img,3)
         img(:,:,it) = img(:,:,it)+abs(normrnd(Mean_GN,Var_GN,N,N));
     end 
end

end