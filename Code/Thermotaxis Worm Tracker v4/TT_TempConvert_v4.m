function [tempxvals, plotyvals, plotxvalscm, finaltemp, finaltempdiff, finaldistdiff] = TT_TempConvert_v4(xvalscm, yvalscm, cmperdeg, Tref)
%% TT_TempConvert_v4 relates x/y coordinates of tracked worms (in cm) to movement within a given thermal gradient
%
%   [tempxvals, plotyvals, plotxvalscm, finaltemp, finaltempdiff,
%   finaldistdiff] = TT_TempConvert_v4(xvalscm, yvalscm, cmperdeg, Tref)
%
%   This function also calculates useful data, like the final temperature
%       reached by each worm, and the total temperature distance moved,
%       final physical distance reached/moved
%
%   Version 4.1
%   Version Date: 2/20/20
%
%   Inputs:
%   xvalscm, yvalscm: tracks in cm
%   cmperdeg: number of cm that make up 1 degree Celcius
%   Tref: Tstart on the gradient (As of Nov 5,2018), alternatively Todor
%       when necessary (As of 2-11-20)
%
%   Outputs:
%   tempxvals = movement of the worm along the x-axis of the plate,
%   translated into degrees Celcius.
%   plotyvals, finaltemp finaltempdiff, finaldist,
%   totaldist = % total cm distance traveled by the worm
%
%% Revision History
%   12/31/17: Created by Astra S. Bryant, Dec 31, 2017
%   11/5/18: Edited to change the math for the
%   "GradientMaxAU" ASB
%   4/8/19: Renamed version 2.0 ASB
%   9/18/19: upgrading to version 3.0 ASB
%   2/10/20: Renamed version 4.0 ASB, adjusting varible names from
%   gradientmax/gradientmaxAU to Tref/TrefAU
%   2/20/20: Removed the TrefAU value, it's no longer necessary as the
%   tracks come into this function already normalized to a known
%   reference location.

clear global plotflag
global assaytype;
global Landmark;
global SR;

tracklength = size(xvalscm,1);
numworms = size(xvalscm,2);
if assaytype == 4 || assaytype == 3 % If assay type is a pure isothermal arena or isothermal + odor
    cmperdeg= NaN(1, numworms);
    Tref = NaN(1,numworms);
    global plotflag
    plotflag=1; %triggers a flag so when it comes time to plot, the axis will be labeled in cm, not degrees
end

if assaytype == 2 % Is assay type is thermotaxis + odor
    Landmark.Tref = Tref; % Saving the Tref (aka Todor) location for plotting purposes later.
    Landmark.Tw = repmat(SR.w,1,numworms) ./ cmperdeg; %Convert width of scoring region to degreesC.
end
%% The Conversion to temperature
cmperdeg=repmat(cmperdeg, tracklength,1);
Tref=repmat(Tref,tracklength,1);
tempxvals = Tref - (xvalscm./cmperdeg);
plotyvals= yvalscm*-1;
plotxvalscm=xvalscm*-1;

%% Calculate Total/Final Temperature and Total/Final Distance Reached by the Worm
% Only do this if the tempxvals isn't just all NaN (i.e. if there isn't a
% thermal gradient, don't run this code.

B = ~isnan(xvalscm);
Indices = arrayfun(@(x) find(B(:, x), 1, 'last'), 1:numworms);
finaldist = arrayfun(@(x,y) xvalscm(x,y), Indices, 1:numworms);
finaldistdiff = abs(xvalscm(1,:)-finaldist); % difference between the final worm position and the starting postition - normalized movement along the x-axis

if all(all(isnan(tempxvals)))
    finaltemp = NaN(1,numworms);
    finaltempdiff = NaN(1,numworms);
else
    finaltemp = arrayfun(@(x,y) tempxvals(x,y), Indices, 1:numworms);
    starttemp=tempxvals(1,:);
    finaltempdiff=finaltemp-starttemp;
end



