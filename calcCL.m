function [cl, sampleXY] = calcCL(mask, I)
%calculates centerline by skeletonizing water mask. has problems still,
%sometimes terminates in loops instead of continuing along river.... Not
%sure how to fix this. Should talk to Xiao/Tamlin to see how they do this.

clRaster = longestConstrainedPath(mask,'thinOpt','skel');
[cl(:,2),cl(:,1)] = find(clRaster); 

xRes = I.PixelScale(1);
yRes = I.PixelScale(2);
%vector of pixel center coordinates
xv = I.BoundingBox(1,1):xRes:I.BoundingBox(2,1);
yv = flip(I.BoundingBox(1,2):yRes:I.BoundingBox(2,2));
%XY of where we actually find widths.
sampleXY = [xv(cl(:,1))' yv(cl(:,2))'];
end

