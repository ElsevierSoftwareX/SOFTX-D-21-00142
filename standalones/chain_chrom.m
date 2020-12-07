function [Ensoneof,ADN]=chain_chrom(distribfun,DC)
% distribfun function picking a value in a distribution. For
% instance, with @() 10*rand(1,1) distances between fluorophores
% along a chromatin chain will follow a uniform distribution from 0 to
% 10. distribfun should not have parameters

    %% G�n�ration des chaines de chromatine
    % Generate 16 permutations of integers from 1 to 100 for each chain
    permutations = cellfun(@(x) randperm(100), cell(16,1), 'UniformOutput', false);

    % Get the required number of chains.
    % We alternate the chromatin chains, and for each of them, we randomly pick
    % configurations using the permutations computed
    Ensoneof = cell(1,DC);
    for ii=1:DC
       chain_idx = mod(ii, 16) +1; % will vary from 1 to 16, alternating the chains
       conf_idx = ceil(ii/16); % will be used to pick a random configuration
       load(['data_base_chro_chaine/100',num2str(chain_idx),'.mat'], 'Ensemble');
       Ensoneof{ii}=squeeze(Ensemble(permutations{chain_idx}(conf_idx),:,:));    
    end  

    %% G�n�ration des biomarqueurs selon une distribution uniform
    ADN=[];
    for i=1:length(Ensoneof) 
        ch=Ensoneof{i};
        [q] = curvspace_unif(ch, distribfun);
        ADN=[ADN ; q] ; %%%%%% toutes les coordon�es des ADNs g�n�r�s (IMPORTANT, entr�e de MODULE 2)%%%%%%% 
     end 

end 