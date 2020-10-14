function [Ensoneof,ADN]=chain_chrom(d,DC)


%% Génération des chaines de chromatine
round1=1;
round2=1;
round3=1;
p=randperm(100); % vecteur p(1,100) dont les valeurs entre 1 et 100 sont choisies aléatoirement
for ii=1:DC
     

   load(['data_base_chro_chaine/100',num2str(mod(ii,16)+1),'.mat']);
   Ensoneof{ii}=squeeze(Ensemble(p(ii),:,:)); 
   
   
end  


%% Génération des biomarqueurs selon une distribution uniform
% Uncomment to visualize
%%figure(1);
ADN=[];
for i=1:length(Ensoneof) 
  ch=Ensoneof{i};
   [q] = curvspace_unif(ch,d);
   ADN=[ADN ; q] ; %%%%%% toutes les coordonées des ADNs générés (IMPORTANT, entrée de MODULE 2)%%%%%%% 
 end 

end 