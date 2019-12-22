function [w,nChan,xsMask,nSkip] = calcWidth(mask, cl, wSearch)
%% rivWidth
% calculates width across vectors perpendicular to centerline. input 'cl'
% should be nx2 matrix that has column and row indeces for the centerline.
% chanWidth is a guess of largest channel width (in pixels, inclusive of
% channel bars or distance between braids). Will automatically increase
% chanWidth if the ends do not touch both banks of all channels found. It
% does not check if there are more channels beyond the ends.
%
% 
% w = rivWidth(mask, clColRow, wSearch);
% [w, nChan, xsMask, nSkip] = rivWidth(mask, clColRow, wSearch);
%
% Ted Langhorst. October 2019
% tlang@live.unc.edu

%% width calc
%discrete derivative then rotated for perpindicular vector. Could be
%done using the coefficients from spline, but will require more
%algebra.
w = NaN(length(cl),1);
nChan = NaN(length(cl),1);
% ug = gradient(cl(:,2));
% vg = gradient(cl(:,1));

nSkip = 0;
xsMask = false(size(mask));
for j = 3:length(cl(:,1))-2
    maxWidth = wSearch;
    
%     u = ug(j);
%     v = vg(j);
    
    %could use gradient() function instead
    u = diff(cl([j-2, j+2],2));
    v = -diff(cl([j-2, j+2],1));
    tmpMagnitude = sqrt(u^2 + v^2);
    u = u / tmpMagnitude;
    v = v / tmpMagnitude; %u,v is now unit vector

    findingBanks = true;
    while findingBanks
        %[x1 y1 x2 y2].
        endPts(1,1:4) = maxWidth/2 .* [u v -u -v] + ... 
            cl(j,[1 2 1 2]);
        x1 = endPts(1);
        y1 = endPts(2);
        x2 = endPts(3);
        y2 = endPts(4);
        
        %check that ends are inside domain of img.
        if any(endPts<1) || any(endPts([1,3])>size(mask,2)) || any(endPts([2,4])>size(mask,1))
            findingBanks = false;
            continue
        end

        %https://www.mathworks.com/matlabcentral/answers/275180-how-to-get-the-pixels-intersected-with-a-vector-line
        %create lots of samples between end pts.
        numSamples = ceil(sqrt((x2-x1)^2+(y2-y1)^2) / sqrt(0.5));
        xSpc = linspace(x1, x2, numSamples);
        ySpc = linspace(y1, y2, numSamples);
        xy = round([xSpc',ySpc']);
        %remove duplicates
        uxy = unique(xy,'rows');
        
        %calculate distance from start then sort.
        dxy = sqrt((uxy(:,1)-x1).^2 + (uxy(:,2)-y1).^2);
        [dxy,sortOrder] = sort(dxy);
        uxy = uxy(sortOrder,:);
        
        %have to transform row,col to linear indexing.
        uxyLinearIdx = sub2ind(size(mask),uxy(:,2),uxy(:,1));
        maskProf = mask(uxyLinearIdx); %mask values across xs
        dMaskProf = [diff(maskProf); 0]; %changes in mask xs (banks)

        %check we have found both banks for all channels. If not, make
        %the cross section 10% wider and check again.
        if sum(dMaskProf)~=0 || maskProf(1)==1 || maskProf(end)==1
            maxWidth = maxWidth * 1.1;
            %only do this up to 5x the guessed width.
            if maxWidth > wSearch*5
                nSkip = nSkip+1;
                findingBanks = false;
            end
        else
            findingBanks = false;
            %center to center distance between edge pixels of all channels.
            %Have to add 1 to the positive mask profile edge due to the way
            %it's calculated. Hard to describe, but plotting these points
            %on the mask makes this very apparent.
            channelWidths = dxy(dMaskProf==-1) - dxy(find(dMaskProf==1)+1);
            w(j) = sum(channelWidths); %total channel width
            nChan(j) = numel(channelWidths); %number of channels
            
            if mod(j,10)==0
                xsMask(uxyLinearIdx) = 1;
            end
        end    
    end
end

if nSkip>0
    warning('Bank finding failed at %d XS.',nSkip)
end

w(w==0) = NaN;
nChan(nChan==0) = NaN;
end

