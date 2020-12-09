function [a,scaling] = fsd_special(mask,noPoints)

%% Find the boundary coordinates of the segmentation result
mask = extend(mask,size(mask)+2);
bound = calculate_boundary(dip_array(mask));
bound = bound - repmat(mean(bound),size(bound,1),1); % Zero mean

%% Rescale to noPoints values
if noPoints > size(bound,1)
    pt = bound;
else
    pt = interparc(noPoints,bound(:,1),bound(:,2));
end

%% Restructure the boundary as complex coordinates
s = pt(:,1) + 1j * pt(:,2);

%% Calculate the discrete Fourier transform
a = fft(s);

%% Normalize the Fourier data

% Normalize for translation invariance, F(0) := 0
a(1) = 0;

% Normalize scale while remaining imaginary, F(u) := F(u)/|F(1)|
scaling = abs(a(2));
a = a./abs(a(2));
