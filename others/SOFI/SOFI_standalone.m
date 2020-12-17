function SOFI_standalone(output_prefix, dna_csv, type, dz, zrange, na, ...
    lambda, magnification, pixel_size, im_size, bg_intens, fluo_intens, ...
    fluo_radius, fluo_on, fluo_off, fluo_bleach, acq_speed, ...
    acq_duration, readout_noise,  dark_current, quantum_gain, ...
    seed, streamIndex, numStreams)
% Default parameters
if nargin < 3
    type = "sofi";
    dz = 0.3;
    zrange = 5;
    na = 0.8;
    lambda = 0.6; % µm
    magnification = 100;
    pixel_size = 6.45; % µm
    im_size = 64; % px
    bg_intens = 2; % photons/frame
    fluo_intens = 200; % photons/frame
    fluo_radius = 64; 
    fluo_on = 20; % ms
    fluo_off = 40; % ms
    fluo_bleach = 80; %s
    acq_speed = 100; % frames/s
    acq_duration = 3; % s
    readout_noise = 1.6; % rms
    dark_current = 0.06; % electrons/pixels/s
    quantum_gain = 0.7 * 6; % # of electrons per incoming photon 
end
if nargin < 22
    rng('shuffle')
else
    randStr = RandStream.create('mlfg6331_64','NumStreams', ...
        todouble(numStreams),  'Seed', todouble(seed), 'StreamIndices', ...
        todouble(streamIndex));
    RandStream.setGlobalStream(randStr)
end
% For testing : downsamples to reduce to 50 fluorophores
% idx = randperm(size(fluo_coords,1));   %// Random row index
% fluo_coords = fluo_coords(idx(1:50), :);
Cam = struct('pixel_size', todouble(pixel_size) * 1e-6, 'acq_speed', ...
    todouble(acq_speed), 'readout_noise', todouble(readout_noise), ...
    'dark_current', todouble(dark_current), 'quantum_gain', ...
    todouble(quantum_gain));
Cam.thermal_noise = Cam.dark_current/Cam.acq_speed;
% Convert time unit in number of frames
fluo_on = todouble(fluo_on) * 1e-3 * Cam.acq_speed;
fluo_off = todouble(fluo_off) * 1e-3 * Cam.acq_speed;
fluo_bleach = todouble(fluo_bleach) * Cam.acq_speed;
if ~fluo_bleach 
    % fluo_bleach=0 deactivates bleaching simulation
    % This corresponds to an infinite bleaching time
    fluo_bleach = Inf;
end
fluo_radius = todouble(fluo_radius) * 1e-9/sqrt(todouble(fluo_radius));
Fluo = struct('radius', fluo_radius, 'Ion', todouble(fluo_intens), ...
    'Ton', fluo_on, 'Toff', fluo_off,  'Tbl', fluo_bleach, ...
    'background', todouble(bg_intens), ...
    'duration', todouble(acq_duration));
%'density',str2double(get(handles.startMenu_density_edit,'String')),'number',str2double(get(handles.startMenu_number_edit,'String')),,'Peak',str2double(get(handles.startMenu_Peak_edit,'String')),,,'SB',str2double(get(handles.startMenu_SB_edit,'String')));
Optics = struct('NA', todouble(na), 'wavelength', ...
    todouble(lambda) * 1e-6, 'magnification', todouble(magnification), ...
    'frames', Cam.acq_speed * Fluo.duration);
Grid = struct('blckSize', 3, 'sx', todouble(im_size), 'sy', ...
    todouble(im_size));
[Optics.psf, Optics.psf_digital, Optics.fwhm, Optics.fwhm_digital] = ...
    gaussianPSF(Optics.NA, Optics.magnification, Optics.wavelength, ...
    Fluo.radius, Cam.pixel_size); % PSF of the optical system
% Read, project and resize fluorescent markers coordinates
fluo_coords = csvread(dna_csv); % Coordinates in nanometers
fluo_z = fluo_coords(:, 3);
fluo_coords = fluo_coords(:, 1:2);
% Scale coordinates in pixels
fluo_pixels = fluo_coords * Optics.magnification / Cam.pixel_size ...
    * 1e-6;
% Shift to center in the image
fluo_pixels = fluo_pixels + Grid.sx/2;
in_image = all(fluo_pixels > 0, 2)  & all(fluo_pixels < Grid.sx, 2) ;
fluo_coords = fluo_pixels(in_image,:);
fluo_z = fluo_z(in_image,:);
% # of electrons per pixel per frame at ambiant air (+20°C)
% Run SOFI and strom for each z slice
zrange = todouble(zrange);
dz = todouble(dz);
all_slices = -zrange:dz:zrange;
n_slices = length(all_slices);
if contains(type,"sofi",'IgnoreCase',true)
    disp('Running bSOFI simulation')
end
if contains(type,"storm",'IgnoreCase',true)
    disp('Running STORM simulation')
end
for slice_index = 1:n_slices
    slice_bottom = all_slices(slice_index);
    disp("Slice " + slice_index + " / " + n_slices);
    z_in_slice = (slice_bottom <= fluo_z) & (fluo_z < (slice_bottom + dz));
    Fluo.emitters = fluo_coords(z_in_slice, :);
    % time Traces of the digital signal recorded at the camera
    stacks = simStacks(Optics.frames, Optics, Cam, Fluo, Grid, false, ...
        false, false);
    timeTraces = stacks.discrete;
    stacks_discrete = double(timeTraces);
    max_digTT = max(stacks_discrete(:));min_digTT = min(stacks_discrete(:));
    stacks_discrete = (stacks_discrete - min_digTT) / (max_digTT - min_digTT);
    clear max_digTT min_digTT;
    %% Results menu
    % Ground truth
    sample = zeros(7*Grid.sy,7*Grid.sx);
    for k=1:size(Fluo.emitters,1)
        sample(floor(7*Fluo.emitters(k,1)),floor(7*Fluo.emitters(k,2))) = 1;
    end
    if slice_bottom == -zrange % Only for first iteration
        all_samples = zeros([size(sample), n_slices]);
    end
    all_samples(:, :, slice_index) = sample;
    % Update Widefield
    widefield = mean(stacks_discrete,3);
    if slice_bottom == -zrange % Only for first iteration
        all_widefield = zeros([size(widefield), n_slices]);
    end
    all_widefield(:, :, slice_index) = widefield;
    if contains(type,"sofi",'IgnoreCase',true)
        %% SOFI_Calculation
        fwhm = Optics.fwhm_digital;
        SOFI = struct();
        % SOFI orders to compute
        orders = 1:7;
        % ---- CROSS-CUMULANTS computation ----
        % 2nd order cross-cumulants of pixel time traces 
        [SOFI.cumulants_traces] = sofiCumulants2D_traces(timeTraces);
        % cross-cumulants of pixel timeTraces integrated over time
        [SOFI.cumulants, ~]=sofiCumulants(timeTraces, [], [], [], ...
            orders, false, false);
        % cross-cumulants flattened
        SOFI.flattened=sofiAllFlatten(SOFI.cumulants);
        % cross-cumulants linearized
        SOFI.linearized=sofiLinearize(SOFI.flattened,fwhm);
        % cross-cumulants reconvolution
        SOFI.reconvolved=sofiReconvolution(SOFI.linearized,fwhm);
        % parameters of the fluorophores extracted
        [SOFI.fluo_ratio,~,~]=sofiParameters(SOFI.linearized);
        % bSOFI
        SOFI.balanced=sofiBalance(SOFI.reconvolved,SOFI.fluo_ratio);
        % Update SOFI
        if slice_bottom == -zrange % Only for first iteration
                all_sofi = cell(1, length(orders));
        end
        for current_ord = orders
            sofi = SOFI.cumulants{current_ord};
            % Normalization and Contrast Adjustment
            sofi(sofi<0)=0;
            sofi = sofi/max(sofi(:));
            sofi = imadjust(sofi,[min(sofi(:));max(sofi(:))],[0;1]);
            if slice_bottom == -zrange % Only for first iteration
                all_sofi{current_ord} = zeros([size(sofi), n_slices]);
            end
            all_sofi{current_ord}(:, :, slice_index) = sofi;
        end
        bsofi = SOFI.balanced;
        % Normalization and Contrast Adjustment
        bsofi(bsofi<0)=0;
        bsofi = bsofi/max(bsofi(:));
        bsofi = imadjust(bsofi,[min(bsofi(:));max(bsofi(:))],[0;1]);
        if slice_bottom == -zrange % Only for first iteration
            all_bsofi = zeros([size(bsofi), n_slices]);
        end
        all_bsofi(:, :, slice_index) = bsofi;
    end
    if contains(type,"storm",'IgnoreCase',true)
        %% STROM_Calculations
        storm = STORMcalculations([],false, timeTraces, Optics, Fluo);
        % Update STORM
        % Normalization and Contrast adjustment
        storm = storm./(max((storm(:))));
        if slice_bottom == -zrange % Only for first iteration
            all_storm = zeros([size(storm), n_slices]);
        end
        if all(isnan(storm))
            % Empty matrix if storm failed
            warning("STORM calculation failed, probably too many fluorophores to perform localization")
        else
            all_storm(:, :, slice_index) = storm;
        end    
    end
end
mat2tif(output_prefix + "GT.tif", all_samples)
mat2tif(output_prefix + "WF.tif", all_widefield)
if contains(type,"sofi",'IgnoreCase',true)
    for current_ord = orders
            mat2tif(output_prefix + "SOFI-" + current_ord + ".tif", ...
                all_sofi{current_ord})
    end
    mat2tif(output_prefix + "bSOFI.tif", all_bsofi)
end
if contains(type,"storm",'IgnoreCase',true)
    mat2tif(output_prefix + "STORM.tif", all_storm)
end
end

function number = todouble(n_string)
    if isstring(n_string) || ischar(n_string)
        number = str2double(n_string);
    else
        number = n_string;
    end
end