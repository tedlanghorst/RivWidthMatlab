clear
close all
clc

%centerline array: first column is x, second column is y.
load('test_clxy.mat')

%water mask: 1 is water.
A = geotiffread('test_mask.tif');

%Variable 'I' could be replaced by the second output of geotiffread, but I
%generally prefer using 'geoimread' from the file exchange instead of the
%default geotiffread. geoimread allows only reading in part of an image and
%provides an updated I structure with the correct image boundaries, while
%outputs from geotiffread aren't updated if you trim the image afterwards.
%(https://www.mathworks.com/matlabcentral/fileexchange/46904-geoimread)
I = geotiffinfo('test_mask.tif');


[xyw,nChan,xsMask,nMiss] = rivWidth(A,I,'centerline',clxy,'width',25);
% [xyw,nChan,xsMask,nMiss] = rivWidth(A,I);

%%
figure
im = imshow(cat(3, xsMask, zeros(size(A)), A & ~xsMask));
set(im, 'AlphaData', A|xsMask);

figure
plot(xyw(:,3))