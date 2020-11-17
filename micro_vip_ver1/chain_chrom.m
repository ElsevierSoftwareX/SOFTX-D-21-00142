function [Ensoneof,ADN]=chain_chrom(m,sig,DC,type)


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
  if type==1 
   [q] = ADN_distance(ch,m,sig,type);
  else   
      [q] = ADN_distance(ch,m,sig,type);
  end 
   
  ADN=[ADN ; q] ; %%%%%% toutes les coordonées des ADNs générés (IMPORTANT, entrée de MODULE 2)%%%%%%% 
 end 

end 