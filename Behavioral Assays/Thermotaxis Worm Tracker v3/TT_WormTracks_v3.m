function [] = TT_WormTracks_v3()
% Function that takes manual thermotaxis worm tracks from Fiji and makes a figure that
% overlays the tracks.
%
% Used to analyze worms moving in a thermotaxis gradient. Will process tracks
% collected using either a single camera or dual camera setup. This program assumes that could be 2
% cameras, but is happy to analyze data from only a single camera. 
%
%   Version 3.2
%   Updated 2-20-20
%
%% Revision History
% 12/22/17: Created by Astra S. Bryant 
% 12/30/17: Made modular (ASB)
% 3/25/18: added CamR-only functionality
% 4/8/19: Better handling of primary/secondary camera systems. Renamed
% version 2.
% 6/18/19: More robust spreadsheet saving code makes it work across Mac and
% PC systems.
% 9/18/19: Updating some elements, particularly handling of data import.
% Upgrading to version 3. This version also takes into account the possibility that worms in the same experiment 
% have been collected with different pixels/cm parameters. So will now
% require a new input via the Index sheet, of pixels/cm for each worm. Also
% trying to combine _CR and _CL files into a single excel sheet containing wormUIDs labeled as _CR or _CL.
% 10/29/19: Updated so that pathlength is now included in the results file
% saved at the end. Also made some changes so that this code works on a
% PC.(ASB)
%
%% Input = excel spreadsheet with an Index sheet listing:
%       the number of worms to analyze, 
%       the UIDs associated with the trakcs analyze that are ...
%           ... the names of the tabs in the excel file with the track
%           datas, cmperdeg, maxgradient, maxgradientAU (optional), and 
%           CamL and CamR pixelspercm data for each UID. The track data
%           should be organized into tabs named with the wormUID+'_CL' or
%           '_CR', depending on which camera the track is from (e.g.
%           190919_CL).


%% IMPORTANT ASSUMPTIONS: 
% Assumes that the frame rate of the images is 1 frame/2 seconds.

%% DEPENDENCIES
% displace.m
% TT_ExptList.m
% importfileXLS.m
% linspecer.m
% TT_ImportTracks_v3.m
% TT_AnalyzeTracks_v3.m
% TT_TempConvert_v3
% TT_TrackPlotter_v3.m


%% Variables
%   Input = excel spreadsheet with an Index sheet listing:
%       the number of worms to analyze, 
%       the UIDs associated with the tracks analyze that are ...
%           ... the names of the tabs in the excel file with the track datas
%       for each UID: orientation of ctrl vs experimental side, ...
%           ...XY coordinates for location of ctrl vs experimental chemical (4 columns: Xleft, Yleft, Xright, Yright)...
%           ...pixelspercm value for each UID - this may change depending
%           on which tracking station was used to collect the data
close all; clear all

%% GUI for selecting what experiment to analyze.
[calledfile] = TT_ExptList_v3();
[pathstr, name, ~] = fileparts(calledfile);


%% Import variables from the Index sheet
disp('Reading data from file....');
[status, sheets] = xlsfinfo(calledfile); % Detect names of tabs in excel spreadsheet

% Import general parameters
numworms = importfileXLS(calledfile, 'Index', 'A2');
tracklength = importfileXLS(calledfile, 'Index', 'A5');
[num, TstartCam] = xlsread(calledfile, 'Index', 'A8');

analyze.CL = 0;
analyze.CR = 0;

if TstartCam{1} == 'L'
    analyze.CL = 1;
    if any(cellfun(@(x) ~isempty(x),strfind(sheets,'CR'))) % Do the names of any of the tabs contain the string 'CR'?
        analyze.CR = 1;
    end    
else
   analyze.CR = 1;
    if any(cellfun(@(x) ~isempty(x),strfind(sheets,'CL'))); % Do the names of any of the tabs contain the string 'CL'?
        analyze.CL = 1;
    end 
end

% Import worm-specific parameters
[num, wormUIDs] = xlsread(calledfile, 'Index', strcat('B2:B', num2str(1+numworms))); 
cmperdeg = xlsread(calledfile, 'Index', strcat('C2:C', num2str(1+numworms)))';
gradientmax = xlsread(calledfile, 'Index', strcat('D2:D', num2str(1+numworms)))';
gradientmaxAU = xlsread(calledfile,'Index',strcat('E2:E', num2str(1+numworms)))';
pixelspercm.CL = xlsread(calledfile,'Index',strcat('F2:F', num2str(1+numworms)))';
pixelspercm.CR = xlsread(calledfile,'Index',strcat('G2:G', num2str(1+numworms)))';


%% Generate list of all possible tab names, given cameras and wormUIDs
if analyze.CL>0
    if ~any(cellfun(@(x) ~isempty(x),strfind(sheets,'CR'))) & ~any(cellfun(@(x) ~isempty(x),strfind(sheets,'CL')));
        datatabs.CL = strcat(wormUIDs);
    else
    datatabs.CL = strcat(wormUIDs,'_CL');%intersect(strcat(wormUIDs,'_CL'),sheets); % Only try to import data tabs if they exist.
    end
end
if analyze.CR>0
    if ~any(cellfun(@(x) ~isempty(x),strfind(sheets,'CR'))) & ~any(cellfun(@(x) ~isempty(x),strfind(sheets,'CL')));
        datatabs.CR = strcat(wormUIDs);
    else
   datatabs.CR = strcat(wormUIDs,'_CR'); %intersect(strcat(wormUIDs,'_CR'),sheets); % Only try to import data tabs if they exist.
    end
end


%% Import tracks from the Index Sheet
if TstartCam{1} == 'L'
    [tracks.CL.xvals, tracks.CL.yvals]=TT_ImportTracks_v3(calledfile, datatabs.CL, tracklength, numworms);
    if analyze.CR>0
        [tracks.CR.xvals, tracks.CR.yvals]=TT_ImportTracks_v3(calledfile, datatabs.CR, tracklength, numworms, 'secondarycam');
    end
elseif TstartCam{1} == 'R'
    [tracks.CR.xvals, tracks.CR.yvals]=TT_ImportTracks_v3(calledfile, datatabs.CR, tracklength, numworms);
    if analyze.CL>0
        [tracks.CL.xvals, tracks.CL.yvals]=TT_ImportTracks_v3(calledfile, datatabs.CL, tracklength, numworms, 'secondarycam');
    end
end

disp('...done.');

%% Analysis
% Okay, if there are 2 cameras, the pixel values for each worm have been
% imported. The next step is to get those pixel values into a common value
% (b/c both cameras have different pixel-to-cm ratios). After that's done,
% the final CamR value and the first CamL value will be the same point in
% time, so I can use that to stich together the tracks.
disp('Analyzing data...');
if analyze.CL>0 && analyze.CR>0 % Both CamL and CamR
    [tracks.CL.xvalscm, tracks.CL.yvalscm,  pathlength, distanceratio, meanspeed, instantspeed, mergedtracks.xvals, mergedtracks.yvals]=TT_AnalyzeTracks_v3(TstartCam, tracks.CL.xvals, tracks.CL.yvals, pixelspercm.CL, tracks.CR.xvals, tracks.CR.yvals, pixelspercm.CR, numworms, tracklength);
    [tempxvals, plotyvals, plotxvalscm, starttemp, finaltemp, finaltempdiff, finaldistdiff, gradientmaxAU]= TT_TempConvert_v3 (mergedtracks.xvals, mergedtracks.yvals, cmperdeg, gradientmax, gradientmaxAU);
elseif analyze.CL>0 && analyze.CR<1 % Only CamL
    [tracks.CL.xvalscm, tracks.CL.yvalscm,  pathlength, distanceratio, meanspeed, instantspeed]=TT_AnalyzeTracks_v3(TstartCam, tracks.CL.xvals, tracks.CL.yvals, pixelspercm.CL);
    [tempxvals, plotyvals, plotxvalscm, starttemp, finaltemp, finaltempdiff, finaldistdiff, gradientmaxAU]= TT_TempConvert_v3 (tracks.CL.xvalscm, tracks.CL.yvalscm, cmperdeg, gradientmax, gradientmaxAU);
elseif analyze.CL<1 && analyze.CR>0 % Only CamR
    [tracks.CR.xvalscm, tracks.CR.yvalscm,  pathlength, distanceratio, meanspeed, instantspeed, mergedtracks.xvals, mergedtracks.yvals]=TT_AnalyzeTracks_v3(TstartCam, [], [], pixelspercm.CL, tracks.CR.xvals, tracks.CR.yvals, pixelspercm.CR, numworms, tracklength);
    [tempxvals, plotyvals, plotxvalscm, starttemp, finaltemp, finaltempdiff, finaldistdiff, gradientmaxAU]= TT_TempConvert_v3 (mergedtracks.xvals, mergedtracks.yvals, cmperdeg, gradientmax, gradientmaxAU);
end
disp('...done.');
%% Calculate mean speed for specific thermal bins, if desired
answer = questdlg('Do you want to calculate speed over a subset of the track?', 'Optional Analysis: Binned Mean Speed', 'Yes');
binnedspeed = [];
switch answer
    case 'Yes'
        binnedspeed = TT_BinnedAnalyses_v3(tempxvals, instantspeed)';
    case 'No'
        clear binnedspeed
    case 'Cancel'
        clear binnedspeed
end


%% Plotting and Saving
if ~exist(fullfile(pathstr,name),'dir')
    mkdir([fullfile(pathstr,name)]);
end

TT_TrackPlotter_v3(tempxvals, plotyvals, plotxvalscm, name, starttemp, gradientmax, pathstr);
if exist('binnedspeed')
    headers={'GradientMax_AU', 'Final_Temp', 'Final_Difference_in_Temp', 'Final_Difference_in_Distance', 'DistanceRatio','MeanSpeed','BinnedSpeed'};
    T=table(gradientmaxAU',finaltemp', finaltempdiff', finaldistdiff', distanceratio', meanspeed', binnedspeed','VariableNames',headers);
else
    headers={'GradientMax_AU', 'Final_Temp', 'Final_Difference_in_Temp', 'Final_Difference_in_Distance', 'DistanceRatio','MeanSpeed'};
    T=table(gradientmaxAU',finaltemp', finaltempdiff', finaldistdiff', distanceratio', meanspeed','VariableNames',headers);
end
writetable(T,fullfile(pathstr,name,strcat(name,'_results.xlsx')));
writetable(T,fullfile(pathstr,name,strcat(name,'_results.csv')));


disp('Finished Analyzing Worm Tracks!');

close all;
end


