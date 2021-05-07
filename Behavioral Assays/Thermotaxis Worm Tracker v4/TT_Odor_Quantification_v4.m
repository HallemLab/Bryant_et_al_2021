function [E] = TT_Odor_Quantification_v4 (normalizedtracks)
%% TT_Odor_Quantification_v4 analyses odor tracking assays, in the context of the thermotaxis rig.
%
%   [E] = TT_Odor_Quantification_v4 (normalizedtracks)This code was taken
%   from the Chemotaxis Tracker, version 6.
%
%   Calculates % of worms that enter scoring region, distance ratio and
%   speed inside scoring region time spent in scoring region by individual
%   worms, # of entrances and exits by individual worms.
%
%   Version 4.2 
%   Version Date: 2/22/20
%
%% Inputs
% Inputs:
%   normalizedtracks: the compiled xvals/yvals of worm tracks normalized to a landmark location.
%       Using this I can easily calculate the amount of time
%       the worm spends in a region relative to the landmark.
%
%% Revision History
%   2/10/20 Forked from CT_Odor_Quantification_v6 (ASB)
%   2/20/20 Completed coding (ASB)
%   2/21/20 Added counts for number of times worms exit/enter the odor
%   scoring region. Added ability to make scoring region a rectangle or
%   circle.

% Import global variables

global SR; % import radius of the scoring region
numworms = size(normalizedtracks.xvals,2);

%% Time spend in scoring region
% A pretty easy calculation, as there is a built in matlab function that
% allows me to determine whether values are located inside or on the edge
% of a polygonal region. So I merely need to define the circular or
% rectangular polygon using geometry.
% Remember: by definition the center of the scoring region (aka the
% landmark) is (0,0).

% Use computational geometry to define the shape of the scoring region
[x,y] = TT_polygon([0,0],SR.w, SR.h, SR.shape{1});

% Logical array for if the worm tracks are inside the scording region? 0 = not in the score region, 1 = within the
% scoring region
cE = inpolygon(normalizedtracks.xvals,normalizedtracks.yvals,x,y);
    
% How much time does each worm spend within the scoring zone 
nE = arrayfun(@(x) nnz(cE(:,x)), 1:numworms); % applying the function nnz to every x column in cE
E.time=nE*2; % assuming 1 frame/ 2 seconds - this tells us the amount of time (number of seconds) the worm spent within the experimental scoring region.
E.time(E.time==0)=NaN;

% How many times did the worm enter and exit the scoring zone
dcE = diff(cE); % Worm entering scoring region = 1; worm exitin scoring region = -1. 
E.nentrances = arrayfun(@(x) nnz(dcE(:,x)>0), 1:numworms); % Count number of "1" values
E.nentrances(E.nentrances==0)=NaN;
E.nexits = arrayfun(@(x) nnz(dcE(:,x)<0), 1:numworms); % Count number of "-1" values
E.nexits(E.nexits==0)=NaN;

% Percent of worms entering the scoring zone for any amount of time
E.nenter = (nnz(nE)/size(nE,2))*100; % number of non-zero elements in the count of how many frames each worm was in the experimental zone
subset.xvals = normalizedtracks.xvals;
subset.yvals = normalizedtracks.yvals;

subset.xvals(~cE) = NaN;
subset.yvals(~cE) = NaN;

EnterScoring = NaN(2,numworms);

for i=1:numworms
    qq = rmmissing(subset.xvals(:,i));
    rr = rmmissing(subset.yvals(:,i));
    if ~isempty(qq)
        EnterScoring(1,i) = qq(1);
        EnterScoring(2,i) = rr(1);
    else
        EnterScoring(1,i) = NaN;
        EnterScoring(2,i) = NaN;
    end
end
[E.maxdisplacement, E.pathlength, E.meanspeed, ~]= TT_displace(EnterScoring,subset.xvals, subset.yvals);
E.pathlength(E.pathlength==0)=NaN;
E.distanceratio=E.pathlength./E.maxdisplacement; %Calculation of distance ratio, as defined in Castelletto et al 2014. Total distance traveled/maximum displacement.

end