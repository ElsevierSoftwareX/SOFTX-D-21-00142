function mat2tif(filename, matrix)
% Save a 3D matrix to a .tif image stack with iven filename
    if isfile(filename)
        % Overwrite image
        delete(filename);
    end
    matrix = matrix / max(matrix(:));
    for ii=1:size(matrix, 3)
        imwrite(uint16(65535* squeeze(matrix(:,:,ii))), filename, ...
            'WriteMode', 'append'); 
    end 
end