clc; close all; clear all;

 


%% Module 1: simulation nuage des points 

%% partie 1 : � la base le g�n�re que 16 chaines diff�rentes avec 100 configuration chacune,
% nous g�n�rons  des chaines  tel que plusieurs fois 16 avec diff�rentes config.   

Chromatine=chain_chrom ; % Chromatine des cellules de coordonn�e x,y et z de chaque chaine de chromatine 
figure(1);
for i=1:length(Chromatine) 
  ch=Chromatine{i};
  plot3(ch(:,1),ch(:,2),ch(:,3),'-k');
  xlabel('x');
  ylabel('y');
  zlabel('z');
 hold on
  title('Chaine de chromatines');
end 

%% Partie 2: g�n�ration des ADN sur les chaines chromatines. 
% param�tre d'entr�e: d pour une distribution uniform , ch une chaine de chromatin  (cette partie peut etre integrer dans le for loop pr�c�dente pour ne pas faire deux for loop
% plus d est grande densit� des points est petite, si d petite alors
% densit� augmente
% param�tre d'entr�e: Radius est le rayon de la cellule
%sortie: q coordonn�e de point g�n�rer sur une chaine de chromatine
figure(2);

ADN=[];
d=100; % param�tre de la distirubtion uniform 

for i=1:length(Chromatine) 
  ch=Chromatine{i};
  [q] = curvspace_unif(ch,d);
  ADN=[ADN ; q] ; %%%%%% toutes les coordon�es des ADNs g�n�r�s (IMPORTANT, entr�e de MODULE 2)%%%%%%% 
  
  
  plot3(ch(:,1),ch(:,2),ch(:,3),'-k',q(:,1),q(:,2),q(:,3),'.g','MarkerSize',7); % plot ADN sur chaine de chromatine
  xlabel('x');
  ylabel('y');
  zlabel('z');
  title('ADN sur chaine de chromatines');
  hold on % comment hold on pour voir sur une seule chaine de chromatine
end 





%% Module 2: Simulation de la microscope (cas widefield, sans bruit de poisson et flou de mouvement)
% Entr�e nuage de point 3D ADN +  param�tre d'objective 
% Sortie: image synth�tique 3D 

radius=200; % cell radius
NA=0.5; % Num�rical aperture, NA=1.1 
n=1.33;  % refractive index , water imersion n = 1.33
lambda=0.525;  % Laser wavelength , lambda=0.525 um 
Nxy=256;    % Image size  , 256x256 en lat�ral
Nz=30;       % z depth



 
 
[PSF,sim_img, ADN]=Simulation3D(ADN,NA,n,lambda,Nxy,Nz,radius);
 figure(4) 
 plot3(ADN(:,1),ADN(:,2),ADN(:,3),'.g','MarkerSize',7); % plot ADN 
 xlabel('x');
 ylabel('y');
 zlabel('z');
 title('3D nuage de point interpol�e');
% 
% simulated image to stack 
 
 filename=('simulated_stack.tif'); 
 delete(filename);
   for ii=1:size(sim_img,3)
    
 r=zeros(size(sim_img,1),size(sim_img,2));
 g=10*ones(size(sim_img,1),size(sim_img,2)); 
 b=zeros(size(sim_img,1),size(sim_img,2)); 
 r=immultiply(r,sim_img(:,:,ii)); 
 RGB=cat(3,r,g,b); 
 RGB= uint8(255 * mat2gray(RGB));
 imwrite(RGB,filename,'WriteMode','append'); 
   end 
 %% display MIP projection : maximum intensity projection
MIP=max(sim_img,[],3); 
MIP=double(MIP);
r=zeros(size(MIP));
g=ones(size(MIP)); 
b=zeros(size(MIP)); 
g=immultiply(g,MIP); 
MIP=cat(3,r,g,b); 
MIP=uint8(255 * mat2gray(MIP));
figure(5);
imshow(MIP); 
% 
% 


