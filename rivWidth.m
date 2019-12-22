function [xyw,nChan,xsMask,nSkip] = rivWidth(mask, I, varargin)
%%rivWidth
%Calculates river widths from a water mask. Currently has the option to run
%only from water mask and info structure, but this is not working very
%well. Use the extra inputs 'centerline' and 'width' to avoid problems!
%
%% INPUTS:
%   mask    =   binary image of water. 1 = water.
%   I       =   structure returned from geotiffinfo().
%% NAME-VALUE OPTIONS:
%   'cl',       n-by-2 matrix of centerline x and y values.
%   'width',    guess of max width, inclusive of land between channels.
%% OUTPUTS:
%   w       =   width at each centerline point
%   nChan   =   number of channels at centerline point
%   xsMask  =   binary mask of sampling locations for widths for
%               visualization. Only includes every 10th xs for clarity.
%   nSkip   =   calcWidth.m attempts to increase the search width until it
%               finds both banks of all channels it found, but will stop at
%               5 times the width parameter and produce a NaN width. If
%               this happens, a warning is written to the command window,
%               and can be saved here. If you get many of these, check the
%               original water mask and the xsMask to see what is
%               happening.
%% EXAMPLES:
%   [w, nChan, xsMask, skipCount] = rivWidth(mask, I, 'cl', clxy, 'width', w);
%    w = rivWidth(mask, I); <- runs but not currently recommended
%
% Ted Langhorst. November 2019
% tlang@live.unc.edu
%% args
if I.PixelScale(1) ~= I.PixelScale(2)
    warning('non-square pixels passed. rivWidth does not account for this.')
end

tmp = strncmpi(varargin,'center',6);
if any(tmp)
    calcClOpt = false;
    clxy = varargin{find(tmp)+1};
else
    calcClOpt = true;
end

tmp = strncmpi(varargin,'width',5);
if any(tmp)
    wSearch = varargin{find(tmp)+1};
else
    %klugey guess at starting width. Total area of water divided by
    %longest dimension of image times a 'sinuosity' factor...
    wSearch = sum(sum(mask)) / length(mask) * 2;
end

%% calc

% get centerline mask
if calcClOpt
    [cl, sampleXY] = calcCL(mask,I);
else
    [cl, sampleXY] = findCL(clxy(:,1),clxy(:,2),I);
end

%cumulative cost mapping - off for now.
% clMask = false(size(mask));
% clMask(sub2ind(size(mask),cl(:,2),cl(:,1))) = true;
% d = bwdistgeodesic(mask,clMask); %cumulative cost mapping
% mask = ~isnan(d) & ~isinf(d); %pick connected pixels

% calc widths
[w, nChan, xsMask, nSkip] = calcWidth(mask, cl, wSearch);

w = w .* I.PixelScale(1); %scale pixel width to real width.

xyw = [sampleXY w];

end





