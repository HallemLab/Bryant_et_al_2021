function [tempxvals, plotyvals, plotxvalscm, starttemp, finaltemp, finaltempdiff, finaldistdiff, gradientmaxAU] = TT_TempConvert_v3(xvalscm, yvalscm, cmperdeg, gradientmax, gradientmaxAU)
%TrackTempConvert.m Modular function that relates x/y coordinates of
%tracked worms (in cm) to movement within a given thermal gradient
% This function also calculates useful data, like the final temperature
% reached by each worm, and the total temperature distance moved
%   Inputs:
%   xvalscm: tracks in cm
%   cmperdeg: number of cm that make up 1 degree Celcius
%   gradientmax: Tstart on the gradient (As of Nov 5,2018)
%   gradientmaxAU: a "fudge factor" that accounts for the physical location
%       of the edge of the worm arena
%
%   Outputs:
%   tempxvals = movement of the worm along the x-axis of the plate,
%   translated into degrees Celcius.
%   plotyvals, starttemp, finaltemp finaltempdiff, finaldist, 
%   totaldist = % total cm distance traveled by the worm
%
%   Version 3.2
%   Updated 2-20-20
%
%% Revision History
%   12/31/17: Created by Astra S. Bryant, Dec 31, 2017
%   11/5/18: Edited to change the math for the
%   "GradientMaxAU" ASB
%   4/8/19: Renamed version 2.0 ASB
%   9/18/19: Renamed version 3.0 (ASB)
%   2/20/20: Added error message that handles condition for what all
%   gradientmaxAU values are missing. (ASB)

clear global plotflag

tracklength=size(xvalscm,1);

if isempty(cmperdeg)
    cmperdeg= ones(1, size(gradientmax,2))*-1;
    gradientmaxAU = zeros(1,size(gradientmax,2));
    gradientmax = zeros(1,size(gradientmaxAU,2));
    global plotflag
    plotflag=1; %triggers a flag so when it comes time to plot, the axis will be labeled in cm, not degrees
end
%% Caclulate gradientmaxAU if desired   
answer = questdlg('Do you want to calculate a GradientMaxAU value?', 'Optional Analysis: GradientMaxAU', 'Yes');
switch answer
    case 'Yes'
        %gradientmaxAU = [];
        track = inputdlg({'Enter the track number for calculating GradientMaxAU'});
        track = str2num(track{1});
        list = string([1:1:size(gradientmax,2)]);
        trackrange = listdlg ('PromptString','Select tracks that to which we will apply the new GradientMaxAU','ListString',list);
        %gradientmaxAU(trackrange) = []
        gradientmaxAU(trackrange) = (xvalscm(1,track)./cmperdeg(1,track));
        %gradientmaxAU = repmat(gradientmaxAU,1,size(gradientmax,2));
    case 'No'
    case 'Cancel'
end
%% The Conversion to temperature
   cmperdeg=repmat(cmperdeg, tracklength,1);
   gradientmax=repmat(gradientmax,tracklength,1);
   %starttemp=repmat(starttemp,tracklength,1);
   gradientmaxAU=repmat(gradientmaxAU,tracklength,1);
   %tempxvals=((gradientmaxAU -(xvalscm./cmperdeg))+gradientmax); Old
   %version that uses a gradientmaxAU based on guestimating the ending
   %temperature. on 11-5-18 ASB started migrating to using a version that
   %identifies a starting temperature.
   if isempty(gradientmaxAU)
   error ('The next computation requires gradientmaxAU values that do not exist. Maybe re-run the code and select the option to calculate these values?')
   end
   tempxvals=(gradientmax+(gradientmaxAU - (xvalscm./cmperdeg))); %here, gradient max is actually Tstart, but I don't want to change the variable name. Sloppy, but I can fix it at some point.
   plotyvals= yvalscm*-1;
    plotxvalscm=xvalscm*-1;
   
   %Calculate Total/Final Temperature and Total/Final Distance Reached by the Worm
   B = ~isnan(tempxvals);
    Indices = arrayfun(@(x) find(B(:, x), 1, 'last'), 1:size(tempxvals, 2));
    finaldist = arrayfun(@(x,y) xvalscm(x,y), Indices, 1:size(xvalscm,2));
    finaldistdiff = abs(xvalscm(1,:)-finaldist); % difference between the final worm position and the starting postition - normalized movement along the x-axis
    
    
    finaltemp = arrayfun(@(x,y) tempxvals(x,y), Indices, 1:size(tempxvals, 2));
    starttemp=tempxvals(1,:);
    finaltempdiff=finaltemp-starttemp;
    
    gradientmaxAU=gradientmaxAU(1,:);
   
end



