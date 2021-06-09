function [adjustedtracks] = TT_LandmarkAlignment_v4(mergedtracks)
%% TT_LandmarkAlignment_v4 aligns experiments conducted on the Hallem Lab thermotaxis rig based on a landmark
%
%   [adjustedtracks] = TT_LandmarkAlignment_v4(mergedtracks)
%
%   Landmark is either an odor (multisensory or odor only experiments) or a median
%   starting location (isothermal only experiments). This function will do
%   the alignment, given arrays with x/y coordinates (in cm) and landmark
%   locations (also in cm).
%
% Version number: 4.1
% Version date: 2/20/20
%
%% Revision History
%   2/11/20:    Created by Astra S. Bryant
%   2/20/20:    Minor changes to keep up with upstream coding changes.

%% Code
global Landmark

% Normalize traces relative to the landmarks. This should all be
% done in the cm scale.
temp.x = repmat(Landmark.RS(:,1)',size(mergedtracks.xvals,1),1);
temp.y = repmat(Landmark.RS(:,2)',size(mergedtracks.yvals,1),1);

adjustedtracks.xvals = mergedtracks.xvals-temp.x;
adjustedtracks.yvals = mergedtracks.yvals-temp.y;
end