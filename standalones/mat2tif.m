function mat2tif(filename, matrix)
% Save a 3D matrix to a .tif image stack with iven filename
    if isfile(filename)
        % Overwrite image
        delete(filename);
    end
    tall_mat = tall(matrix);
    tall_mat = gather(tall_mat / max(tall_mat, [], 'all'));
    for ii=1:size(matrix, 3)
        imwrite(uint16(65535* squeeze(tall_mat(:,:,ii))), filename, ...
            'WriteMode', 'append'); 
    end 
end