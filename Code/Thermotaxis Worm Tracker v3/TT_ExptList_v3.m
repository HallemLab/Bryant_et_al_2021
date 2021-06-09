function [file] = TT_ExptList_v3(datasetfile)
%Generates a GUI for selecting worm tracks for anaylsis by TT_WormTracks_v3.m

%Import variables from the Index sheet
% Designates the camera on which worms start

%% Revision History
% 12/30/17: Created by Astra S. Bryant
% 4/8/19: renamed version 2.0 (ASB)
% 5/1/19: added functionality for reading in pixels per cm for each camera,
%   new output variables.
% 9/18/19: Switched to using uigetfile version, rather than specifying a dataset
% file. This seems like it will be more convenient in the long run. Updated to version 3.

%%

%% Get user to select the file to be analyzed.
% Switched to using uigetfile version, rather than specifying a dataset
% file. This seems like it will be more flexible.

[name, pathstr] = uigetfile('*.xlsx');
if isequal(name,0)
    error('User canceled analysis session');
else
    disp(['User selected ', fullfile(pathstr,name)]);
end

file = fullfile(pathstr,name);

end

