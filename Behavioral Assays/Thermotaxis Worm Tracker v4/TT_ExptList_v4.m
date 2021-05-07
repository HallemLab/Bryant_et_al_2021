function [] = TT_ExptList_v4()
%% TT_ExptList_v4 generates a GUI for selecting worm tracks for anaylsis by TT_WormTracks_v4.m
%
%   [] = TT_ExptList_v4()
%   Import variables from the Index sheet
%
%   Version 4.0
%   Version Date: 2/10/20
%
%% Revision History
%   12/30/17: Created by Astra S. Bryant
%   4/8/19: renamed version 2.0 (ASB)
%   5/1/19: added functionality for reading in pixels per cm for each camera,
%   new output variables.
%	9/18/19: Switched to using uigetfile version, rather than specifying a dataset
%   file. This seems like it will be more convenient in the long run. Updated to version 3.
%   2/10/20: Updated to version 4.

%%

%% Get user to select the file to be analyzed.
% Switched to using uigetfile version, rather than specifying a dataset
% file. This seems like it will be more flexible.
global calledfile

[name, pathstr] = uigetfile('*.xlsx');
if isequal(name,0)
    error('User canceled analysis session');
else
    disp(['User selected ', fullfile(pathstr,name)]);
end

calledfile = fullfile(pathstr,name);

%% Determine the type of thermotaxis assay being analyzed

global assaytype % make the variable assaytype a global variable, so I can retreive it from any function, without passing it through the input/output calls.

[selection, ok] = listdlg('Name','Select Assay Type',...
    'PromptString','Pick a thermotaxis assay type',...
    'ListString',{'Pure Thermotaxis'; 'Thermotaxis + Odor'; 'Isothermal Odor';'Pure Isothermal';},...
    'SelectionMode','single','ListSize',[200 150]);
% Handle response
if ok < 1
    error('User canceled analysis session');
end

switch selection
    case 1
        assaytype = 1; % Pure Thermotaxis Gradient
    case 2
        assaytype = 2; % Multisensory Experiment, i.e. Odor + Thermal Gradient
    case 3
        assaytype = 3; % Pure Odor Experiment, i.e. Odor on isothermal plate
    case 4
        assaytype = 4; % Isothermal, i.e. unstimulated experiment
end

end

