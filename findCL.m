function [cl, sampleXY] = findCL(x, y, I)
%finds location of cl x,y points in mask raster.

xRes = I.PixelScale(1);
yRes = I.PixelScale(2);

%vector of pixel center coordinates
xv = I.BoundingBox(1,1):xRes:I.BoundingBox(2,1);
yv = flip(I.BoundingBox(1,2):yRes:I.BoundingBox(2,2));

%center to corner distance for pixel resolution. CL points and pixel
%centers won't perfectly match, so this is the allowable difference.
pixMaxDist = sqrt((xRes)^2 + (yRes)^2) /2; 

%init
cl = NaN(length(x),2); 
 
%loop through each point and look for matches in xv,yv.
for k = 1:length(x)
    minDist = sqrt( min(abs(x(k) - xv))^2 + min(abs(y(k) - yv))^2 );
    if minDist < pixMaxDist
        [~,cl(k,1)] = min(abs(x(k) - xv));
        [~,cl(k,2)] = min(abs(y(k) - yv));
    end
end

cl(any(isnan(cl),2),:) = []; %remove empty rows
cl = unique(cl(:,1:2),'rows','stable');

%XY of where we actually find widths.
sampleXY = [xv(cl(:,1))' yv(cl(:,2))'];
end

