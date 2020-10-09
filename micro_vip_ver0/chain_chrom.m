function Ensoneof=chain_chrom
round1=1;
round2=1;
round3=1;
p=randperm(100); % vecteur p(1,100) dont les valeurs entre 1 et 100 sont choisies aléatoirement
for ii=1:64
     
if ii<17
   load(['data_base_chro_chaine/100',num2str(ii),'.mat']);
   Ensoneof{ii}=squeeze(Ensemble(p(ii),:,:)); 
   
elseif ii>16 && ii<33
   load(['data_base_chro_chaine/100',num2str(round1),'.mat']);
   Ensoneof{ii}=squeeze(Ensemble(p(ii),:,:)); 
  round1=round1+1;
   
elseif ii>32 && ii< 49 
   load(['data_base_chro_chaine/100',num2str(round2),'.mat']);
   Ensoneof{ii}=squeeze(Ensemble(p(ii),:,:)); 
   round2=round2+1;
else
     load(['data_base_chro_chaine/100',num2str(round3),'.mat']);
      round3=round3+1;
     Ensoneof{ii}=squeeze(Ensemble(p(ii),:,:));
end  

end 