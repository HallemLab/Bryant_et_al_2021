function [CLxvalscm, CLyvalscm, pathlength, distanceratio, meanspeed, instantspeed, CLandRxvalscm, CLandRyvalscm] = TT_AnalyzeTracks_v3(TstartCam, CLxvals, CLyvals, CLppcm, CRxvals, CRyvals, CRppcm, numworms, tracklength)
% AnalyzeTracks.m Modular function for taking worm tracks, represented as
% x-, y-coordinates in pixels, and turning them in to cm values. Will take
% both a single camera input or a dual camera input
%   Inputs: C1xvals, C1yvals = x- and y- coordinates from a primary camera
%   C1ppcm = pixels per cm for the primary camera Optional Inputs: C2xvals,
%   C2yvals = x- and y- coordinates from a secondary camera C2ppcm = pixels
%   per cm for the secondary camera Outputs: C1xvalscm, C2yvalscm,
%   C1and2xvalscm, C1and2yvalscm, maxdisplacement, displacement,
%   travelpath, pathlength
%
%   Version 3.2
%   Updated 2-20-20
%
%% Revision History
%   12/31/17: Created by Astra S. Bryant
%   1/28/19: Edited  to make the dual camera offset operation more
%   flexible. Previously, the code found the last value in the right camera
%   and added that to the first value on the left camera. This works if the
%   worm is moving from right to left, but not if it's going from left to
%   right. The update places the "first" and "last" with "smallest" and
%   "largest" value. On the right camera, the smallest x value will be the
%   furthest left; on the left camera, the largest value will be the
%   furthest right. Those two will be equivalent when the worm is crossing
%   over. (ASB)
%   1/21/19: Works ok with worms crossing from CamR to CamL, and on worms starting
%   on CamL and staying there. Haven't yet tested on worms transitioning
%   from CamL to CamR (ASB)
%   4/8/19: Renamed version 2.0 (ASB)
%   9/18/19: Renamed version 3.0 (ASB)
%   9/19/19: Updated so that the pixels per cm value is declared for each
%   track, to account for the addition of multiple worm tracking setups.
%   Also updating/cleaning up the commenting. This could be way more streamlined; the program 
%   is exporting way more variables than necessary. At some point could make this better. (ASB)
%   1/30/20: Updated so that the two camera alignment is back to using the
%   first/last number schema that we started with. This will hopefully
%   prevent there being an issue is the worm is circling around near the
%   transition point. (ASB)
%   2/11/20 Realized there was an issue with the 2 camera alignment
%   adjustment that I implimented on 1/30/20. This update should fix the
%   issue. (ASB)
%   2/20/20. Debuged the TstartCam = L condition. Changed how the system
%   handles empty data from one of the cameras on a track (used to assign a
%   fax value of zero, now sticking to NaN values. Fixed another problem with the 2 camera alignment
%   code adjustment written on 1/30/20.

%% Preprocessing CamL Data
if isempty(CLxvals) % If no data from CamL, populate array with NaN
    CLxvals=NaN(tracklength, numworms);
    CLyvals=NaN(tracklength, numworms);
end

CLppcmarray = repmat(CLppcm, size(CLxvals,1),1);
CLxvalscm=CLxvals./CLppcmarray;
CLyvalscm=CLyvals./CLppcmarray;

%% Preprocessing CamR Data
if exist('CRxvals') && ~isempty(CRxvals)
    CRppcmarray = repmat(CRppcm, size(CRxvals,1),1);
    CRxvalscm=CRxvals./CRppcmarray;
    CRyvalscm=CRyvals./CRppcmarray;
    
    %Step 1: Give a fake value if the CR column is empty
    for i=1:numworms
        if all(isnan(CRxvalscm(:,i)))
            CRxvalscm(1:tracklength,i)=NaN;
            CRyvalscm(1:tracklength,i)=NaN;
        end
    end
    
%% Aligning X Values of both Cameras
    % Step 2: Depending on whether the worms are moving from R to L OR L to Right,
    % Find the values that need to be used to align the cameras.
    
     if TstartCam{1} == 'R'
           B = ~isnan(CRxvalscm);
           IndicesCR = arrayfun(@(x) find(B(:, x), 1, 'last'), 1:size(CRxvalscm, 2));
           leftmostCRpoint.xvals = arrayfun(@(x,y) CRxvalscm(x,y), IndicesCR, 1:size(CRxvalscm,2));
           
           C = ~isnan(CLxvalscm);
           for i = 1:numworms
               if ~isempty(find(C(:,i),1,'first'))
                   IndicesCL(i) = find(C(:,i),1,'first');
                   rightmostCLpoint.xvals(i) = CLxvalscm(IndicesCL(i),i); 
               else
                   IndicesCL(i) = NaN;
                   rightmostCLpoint.xvals(i) = NaN;
               end
           end
           
     elseif TstartCam{1} == 'L'
           B = ~isnan(CRxvalscm);
           for i = 1:numworms
               if ~isempty(find(B(:,i),1,'first'))
                   IndicesCR(i) = find(B(:,i),1,'first');
                   leftmostCRpoint.xvals(i) = CRxvalscm(IndicesCR(i),i);
               else
                   IndicesCR(i) = NaN;
                   leftmostCRpoint.xvals(i) = NaN;
               end
           end
           
           C = ~isnan(CLxvalscm);
           IndicesCL = arrayfun(@(x) find(C(:, x), 1, 'last'), 1:size(CLxvalscm, 2));
           rightmostCLpoint.xvals = arrayfun(@(x,y) CLxvalscm(x,y), IndicesCL, 1:size(CLxvalscm,2));
     end
     
    
    if TstartCam{1} == 'R' % Worms start on CamR side
        for i=1:numworms
            if ~isnan(rightmostCLpoint.xvals(i))
                subCamoffset.xvals (i) = rightmostCLpoint.xvals (i);
                subCamoffset.yvals (i) = CLyvalscm (IndicesCL(i),i);
            else
                subCamoffset.xvals (i) = 0;
                subCamoffset.yvals (i) = 0;
            end
            leftmostCRpoint.yvals (i) = CRyvalscm(IndicesCR(i),i);
        end
        subCamoffset.xvals = repmat(subCamoffset.xvals, tracklength, 1);
        subCamoffset.yvals = repmat(subCamoffset.yvals, tracklength, 1);
        
        subC.xvalscmoffset= leftmostCRpoint.xvals + (CLxvalscm - subCamoffset.xvals);
        subC.yvalscmoffset= leftmostCRpoint.yvals + (CLyvalscm - subCamoffset.yvals);
        
        CLandRxvalscm = cat(1,CRxvalscm, subC.xvalscmoffset);
        CLandRyvalscm = cat(1,CRyvalscm, subC.yvalscmoffset);
    end
    
    if TstartCam{1} == 'L' % Worms start on CamL side.
        for i=1:numworms
            if ~isnan(leftmostCRpoint.xvals(i))
                subCamoffset.xvals (i) = leftmostCRpoint.xvals (i);
                subCamoffset.yvals (i) = CRyvalscm (IndicesCR(i),i);
            else
                subCamoffset.xvals (i) = 0;
                subCamoffset.yvals (i) = 0;
            end
            rightmostCLpoint.yvals (i) = CLyvalscm(IndicesCL(i),i);
        end
        subCamoffset.xvals = repmat(subCamoffset.xvals, tracklength, 1);
        subCamoffset.yvals = repmat(subCamoffset.yvals, tracklength, 1);
        
        subC.xvalscmoffset= rightmostCLpoint.xvals + (CRxvalscm - subCamoffset.xvals);
        subC.yvalscmoffset= rightmostCLpoint.yvals + (CRyvalscm - subCamoffset.yvals);
        
        CLandRxvalscm = cat(1,subC.xvalscmoffset, CLxvalscm);
        CLandRyvalscm = cat(1,subC.yvalscmoffset, CLyvalscm);
        
    end
    
    
end

%% Calculate path and max displacement for generating a distance ratio, in combination with the maximum distance moved.
% I currently don't need the travelpath and pathlength data, but it might
% come in handy later.
if exist('CLandRxvalscm')
    [maxdisplacement pathlength meanspeed instantspeed]= displace([CLandRxvalscm(1,:);CLandRyvalscm(1,:)], CLandRxvalscm, CLandRyvalscm);
else
    [maxdisplacement pathlength meanspeed instantspeed]= displace([CLxvalscm(1,:);CLyvalscm(1,:)], CLxvalscm, CLyvalscm);
end

distanceratio=pathlength./maxdisplacement; %Calculation of distance ratio, as defined in Castelletto et al 2014. Total distance traveled/maximum displacement.
end




