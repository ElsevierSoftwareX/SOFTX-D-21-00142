%sofi=sofiReconvolution(sofi,fwhm,orders)
%-----------------------------------------------
%
%Deconvolve and denoise flat cumulants and linearize the brightness
%by taking the order-th root of the deconvolved cumulants. The result
%is reconvolved with a realistic point-spread function.
%
%Inputs:
% sofi      Flat cumulants (see sofiFlatten)
% fwhm      PSF diameter (see sofiFlatten)
% orders    Cumulant orders                     {all}
%
%Output:
% sofi      Linar cumulant images

%Copyright ? 2012 Marcel Leutenegger et al, ?cole Polytechnique F?d?rale de Lausanne,
%Laboratoire d'Optique Biom?dicale, BM 5.142, Station 17, 1015 Lausanne, Switzerland.
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
function sofi=sofiReconvolution(sofi,fwhm,orders)
if nargin < 3 || isempty(orders)
   orders=find(~cellfun(@isempty,sofi));
end
orders=orders(orders > 1);
if isempty(orders)
   return;
end

fwhm=fwhm(1)/sqrt(8*log(2));
psf=gaussian(fwhm);
for order=orders(:).'
   [~,~,k]=size(sofi{order});
   for k=1:k
      img=abs(sofi{order}(:,:,k));
      sofi{order}(:,:,k)=conv2(psf,psf,img,'same');
   end
end


