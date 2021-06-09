function [xvalscm, yvalscm] = TT_ConvertToCm_v4(xvals, yvals, ppcm)
% TT_ConvertToCm_v4 takes worm tracks, represented as
%   x-, y-coordinates in pixels, and turning them in to cm values.
%
%   [xvalscm, yvalscm] = TT_ConvertToCm_v4(xvals, yvals, ppcm)
%   
%   Split from TT_AnalyzeTracks in order to give more flexibility
%   in the order of the pixels to cm conversion and the alignment of two
%   cameras. Original version included both converstion and alignment. Now
%   the alignment is found in a different function. 
%
%   Version 4.0
%   Updated 2/12/20
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
%   9/19/19: Updated so that the pixels per cm value is declared for each
%   track, to account for the addition of multiple worm tracking setups.
%   Also updating/cleaning up the commenting. This could be way more streamlined; the program 
%   is exporting way more variables than necessary. At some point could make this better. (ASB)
%   1/30/20: Updated so that the two camera alignment is back to using the
%   first/last number schema that we started with. This will hopefully
%   prevent there being an issue is the worm is circling around near the
%   transition point. (ASB)
%   2/10/20: Renamed to version 4 to support additional analyses for
%   multisensory experiments. Fixed a problem with the 2 camera alignment
%   code adjustment written on 1/30/20.
%   2/12/20: Split TT_AnalyzeTracks_v4 into multiple functions. 

%% Convert Camera Data from pixels to cm, given known converstion rate.
ppcmarray = repmat(ppcm, size(xvals,1),1);
xvalscm=xvals./ppcmarray;
yvalscm=yvals./ppcmarray;

end




