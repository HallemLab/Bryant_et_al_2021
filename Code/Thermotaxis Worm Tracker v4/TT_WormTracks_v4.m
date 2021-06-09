function [] = TT_WormTracks_v4()
%% TT_WormTracks_v4 the top level function for analysis and plotting worms migrating in the Hallem Lab Thermotaxis Rig. 
%
%   Requires a specificly formatted excel spreadsheet containing tracking
%   data. For details, please see TT_Tracker v4 Readme.rtf
%
%   Will process tracks collected using either a single camera or dual camera setup.
%
%   Version 4.1
%   Version Date: 2/21/20
%
%% Revision History
%   12/22/17: Created by Astra S. Bryant 
%   12/30/17: Made modular (ASB)
%   3/25/18: added CamR-only functionality
%   4/8/19: Better handling of primary/secondary camera systems. Renamed
%       version 2.
%   6/18/19: More robust spreadsheet saving code makes it work across Mac and
%       PC systems.
%   9/18/19: Updating some elements, particularly handling of data import.
%       Upgrading to version 3. This version also takes into account the possibility that worms in the same experiment 
%       have been collected with different pixels/cm parameters. So will now
%       require a new input via the Index sheet, of pixels/cm for each worm. Also
%    trying to combine _CR and _CL files into a single excel sheet containing wormUIDs labeled as _CR or _CL.
%   10/29/19: Updated so that pathlength is now included in the results file
%       saved at the end. Also made some changes so that this code works on a
%       PC.(ASB)
%   2/10/20: Renamed to version 4 to support additional analyses for
%       multisensory experiments. Added error messages to detect if the
%       .xlsx file is missing inputs. (ASB)
%   2/20/20: Finished major upgrade to dual camera alignment system, and
%       added Odor Quantification functionality! (ASB)
%   2/21/20: Minor changes, and added quantification of the percent of worms
%   that enter the scoring region.
%
%% IMPORTANT ASSUMPTIONS: 
% Assumes that the frame rate of the images is 1 frame/2 seconds.

close all; clear all
warning('off');
%% GUI for selecting what experiment to analyze.
TT_ExptList_v4();
global assaytype;
global calledfile;

[pathstr, name, ~] = fileparts(calledfile);


%% Import variables from the Index sheet
disp('Reading data from file....');
[~, sheets] = xlsfinfo(calledfile); % Detect names of tabs in excel spreadsheet

% Import general parameters
numworms = importfileXLS(calledfile, 'Index', 'A2');
tracklength = importfileXLS(calledfile, 'Index', 'A5');
[~, TstartCam] = xlsread(calledfile, 'Index', 'A8');
if isempty(TstartCam) || numworms == 0 || isempty(numworms) || isempty(tracklength)
    error('User Error. The Index tab in your .xlsx file contains missing/incorrect values in column A.');
end 

analyze.CL = 0;
analyze.CR = 0;

% The utility of this code will depend on how the user set up their excel
% spreadsheet. If they included a named tab for every worm on ever
% camera, irrespective of whether there is data or not, this code won't
% actually matter. But if they didn't, this will catch that condition.
if TstartCam{1} == 'L'
    analyze.CL = 1;
    if any(cellfun(@(x) ~isempty(x),strfind(sheets,'CR'))) % Do the names of any of the tabs contain the string 'CR'?
        analyze.CR = 1;
    end    
else
   analyze.CR = 1;
    if any(cellfun(@(x) ~isempty(x),strfind(sheets,'CL'))) % Do the names of any of the tabs contain the string 'CL'?
        analyze.CL = 1;
    end 
end

% Import worm-specific parameters
[~, wormUIDs] = xlsread(calledfile, 'Index', strcat('B2:B', num2str(1+numworms))); 
cmperdeg = xlsread(calledfile, 'Index', strcat('C2:C', num2str(1+numworms)))';
Tref = xlsread(calledfile, 'Index', strcat('D2:D', num2str(1+numworms)))';
pixelspercm.CL = xlsread(calledfile,'Index',strcat('F2:F', num2str(1+numworms)))';
pixelspercm.CR = xlsread(calledfile,'Index',strcat('G2:G', num2str(1+numworms)))';
if ~isequal(numel(wormUIDs),numel(pixelspercm.CL),numel(pixelspercm.CR))
    error('User Error. There are missing values in required columns (B, F, or G)');
end

% Designate assay-specific parameters
TT_AssayParams_v4 (wormUIDs,numworms);

%% Generate list of all possible tab names, given cameras and wormUIDs
if analyze.CL>0
    if ~any(cellfun(@(x) ~isempty(x),strfind(sheets,'CR'))) && ~any(cellfun(@(x) ~isempty(x),strfind(sheets,'CL')))
        datatabs.CL = strcat(wormUIDs);
    else
    datatabs.CL = strcat(wormUIDs,'_CL');%intersect(strcat(wormUIDs,'_CL'),sheets); % Only try to import data tabs if they exist.
    end
end
if analyze.CR>0
    if ~any(cellfun(@(x) ~isempty(x),strfind(sheets,'CR'))) && ~any(cellfun(@(x) ~isempty(x),strfind(sheets,'CL')))
        datatabs.CR = strcat(wormUIDs);
    else
   datatabs.CR = strcat(wormUIDs,'_CR'); %intersect(strcat(wormUIDs,'_CR'),sheets); % Only try to import data tabs if they exist.
    end
end

%% Import tracks from the Index Sheet or generate NaN-filled variables
% Notably, the ImportTracks function does check to make sure a tab exists
% before it tries to import data. If the tab doesn't exist, it will
% generate a NaN column. 
if analyze.CL>0
    [Xvals.Pixels_CL, Yvals.Pixels_CL, frame.CL]=TT_ImportTracks_v4(datatabs.CL, tracklength, numworms);
else
    [Xvals.Pixels_CL, Yvals.Pixels_CL, frame.CL]= deal(NaN (tracklength, numworms));
end

if analyze.CR>0
    [Xvals.Pixels_CR, Yvals.Pixels_CR, frame.CR]=TT_ImportTracks_v4(datatabs.CR, tracklength, numworms);
else
    [Xvals.Pixels_CR, Yvals.Pixels_CR, frame.CR]= deal(NaN (tracklength, numworms));
end
disp('...done');
% Quality check the data to make sure that there are no cases where a
% single worm has only NaN values on both cameras. If this is true, then
% something went wrong with the track import.
if any(arrayfun(@(x) all(isnan(Xvals.Pixels_CR(:,x))) & all(isnan(Xvals.Pixels_CL(:,x))),1:numworms))
    errormsg = wormUIDs(arrayfun(@(x) all(isnan(Xvals.Pixels_CR(:,x))) & all(isnan(Xvals.Pixels_CL(:,x))),1:numworms));
    error(['Tracks associated with the following UIDs failed to load.' newline 'Please check correct labeling of excel tabs:' newline strjoin(errormsg,'\n')]);   
end

%% Step 1: Convert tracks from pixels to cm
[Xvals.Cm_CR, Yvals.Cm_CR]= TT_ConvertToCm_v4(Xvals.Pixels_CR, Yvals.Pixels_CR, pixelspercm.CR);
[Xvals.Cm_CL, Yvals.Cm_CL]= TT_ConvertToCm_v4(Xvals.Pixels_CL, Yvals.Pixels_CL, pixelspercm.CL);



%% Step 2: Rotate and scale tracks as a function of hard coded scaling/rotational values
% This will normalize the data from the two cameras onto a common axis, 
% making it very easy align and merge the tracks.
[normCL, normCR]=TT_RotationMatrix_v4(Xvals, Yvals, numworms);

%% Step 3: Aligning/Merging tracks across both cameras.
[mergedtracks.xvals, mergedtracks.yvals]=TT_AlignDualCameras_v4(TstartCam, normCL.xvals, normCL.yvals,  normCR.xvals, normCR.yvals, frame, numworms, tracklength);


%% For cases without a designated landmark (aka Pure isothermal or pure thermotaxis), calculate a landmark
% This will be based on the median value of the starting points for each
% experimental run.
global Landmark
if assaytype == 4 || assaytype == 1 % If the assay type is a Pure isothermal or Pure thermotaxis
    ExptNum = xlsread(calledfile,'Index', strcat('E2:E', num2str(1+numworms)))'; % This variable indicates which group
    if ~isequal(numel(ExptNum),numel(wormUIDs))
        error('User Error. The Index tab in your .xlsx file contains missing values in column I.');
    elseif any(rem(ExptNum,1))
        error('User Error. Please make sure the Experiment Number value in Column I of your .xlsx file only contains integer values.');
    end
    
    [C, ~, ic] = unique(ExptNum);
    WormStart(1:numworms,1) = mergedtracks.xvals(1,:);
    WormStart(1:numworms,2) = mergedtracks.yvals(1,:);
    
    for ii = 1:numel(C)
        Landmark.RS(find(ic == ii),1)= median(WormStart(find(ic == ii),1));% Index into a subset of tracks belonging to the same bin. This find should produce the wormnum values, use that to select the WormStarting locations and take the median value
        Landmark.RS(find(ic == ii),2)= median(WormStart(find(ic == ii),2));
    end  
end

[normalizedtracks]= TT_LandmarkAlignment_v4(mergedtracks); %At this point, by definition, (0,0) equals the centroid of the Landmark Location. 


%% Calculate path and max displacement for generating a distance ratio, in combination with the maximum distance moved.
% I currently don't need the travelpath and pathlength data, but it might
% come in handy later.
[maxdisplacement, pathlength, meanspeed, instantspeed]= TT_displace([normalizedtracks.xvals(1,:);normalizedtracks.yvals(1,:)], normalizedtracks.xvals, normalizedtracks.yvals);
distanceratio=pathlength./maxdisplacement; %Calculation of distance ratio, as defined in Castelletto et al 2014. Total distance traveled/maximum displacement.

%% Multisensory Experimental Analyses
%   New section (as of 2/10/20) that adds chemotaxis-style analyses
if assaytype == 2 || assaytype == 3 % If the assay type selected is Multisensory or Isothermal + Odor
    [OdorQuant] = TT_Odor_Quantification_v4(normalizedtracks);
end


%% Convert x-axis from cm to degrees, when appropriate. 
% Will run all assay types through this "conversion". 
%   For Thermotaxis + OdorIf there is a odor on the plate,
%   Tref should refer to the temperature the odor is placed at. 
%   For pure thermotaxis experiments, Tref should be the Tstart position of
%   the worms.
% For pure isothermal experiments or pure odor experiments, Tref is not required.
disp('Converting units to temperature...');
[Xvals.temp, Yvals.final_cm, Xvals.final_cm, finaltemp, finaltempdiff, finaldistdiff]= TT_TempConvert_v4 (normalizedtracks.xvals, normalizedtracks.yvals, cmperdeg, Tref);
disp('...done.');


%% Calculate mean speed for specific thermal bins, if desired
%answer = questdlg('Do you want to calculate speed over a subset of the track?', 'Optional Analysis: Binned Mean Speed', 'Yes');
answer = 'No';
binnedspeed = [];
switch answer
    case 'Yes'
        binnedspeed = TT_BinnedAnalyses_v4(Xvals.temp, instantspeed)';
    case 'No'
        clear binnedspeed
    case 'Cancel'
        clear binnedspeed
end


%% Plotting and Saving
if ~exist(fullfile(pathstr,name),'dir')
    mkdir(fullfile(pathstr,name));
end

TT_TrackPlotter_v4(Xvals.temp, Yvals.final_cm, Xvals.final_cm, name, pathstr);

%% Saving data
% Basic calculations
headers={'Final_Temp', 'Final_Difference_in_Temp', 'Final_Difference_in_Distance_cm', 'DistanceRatio','MeanSpeed_mm_per_sec'};
t = [finaltemp', finaltempdiff', finaldistdiff', distanceratio', meanspeed'];

if exist('OdorQuant','var')
   headers = [headers, {'Time_in_OR_sec', 'Distance_ratio_in_OR','Mean_speed_in_OR_mm_per_sec','Num_OR_entrances','Num_OR_exits','Percent_enter_OR'}];
   t = [t, OdorQuant.time', OdorQuant.distanceratio', OdorQuant.meanspeed',OdorQuant.nentrances',OdorQuant.nexits',[OdorQuant.nenter, NaN(1,numworms-1)]'];
end

if exist('binnedspeed','var')
   headers = [headers, {'BinnedSpeed'}];
   t  = [t, binnedspeed'];
end

T = array2table(t, 'VariableNames',headers);
tt = cell2table(wormUIDs);
T = [tt, T];

writetable(T,fullfile(pathstr,name,strcat(name,'_results.xlsx')));
writetable(T,fullfile(pathstr,name,strcat(name,'_results.csv')));


disp('Finished Analyzing Worm Tracks!');

close all;
end


