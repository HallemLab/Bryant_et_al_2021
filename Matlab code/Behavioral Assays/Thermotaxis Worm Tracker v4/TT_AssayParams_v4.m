function[] = TT_AssayParams_v4 (wormUIDs,numworms)
%% TT_AssayParams_v4 user-defined parameters associated with thermotaxis tracking assays.
%
%   [] = TT_AssayParams_v4 (wormUIDs,numworms)
% 
%   Assigns a landmark camera, which is either the Camera on which an odor
%   is placed, or the Tstart camera, for non-odor experiments.
%
%   Contains hardwired alignment values for the two cameras found in the
%   Hallem Lab Thermotaxis Rig (the Collection Epoch name/value pairs). The
%   specific values used depend on how the cameras were aligned, which can
%   change over time. When it does change, users should add a new case.
%
%   Version 4.2 Version Date: 2/21/20
%
%%  Revision History
%   2-11-20     Created by Astra S. Bryant
%   2-20-20     Added camera alignment parameters
%   2-21-20     Added ability to define rectangular or circular odor
%               scoring region.

%% Code
global assaytype; % Retrieve the global variable assaytype defined in TT_ExptList. 1 = Pure Thermotaxis Assay; 2=Thermotaxis + Odor Assay; 3 = Isothermal Odor Assay; 3 = Pure Isothermal Assay
global SR; % Contains information about Odor Scoring Region
global CL_ac; % Alignment coordinates for Left Camera
global CR_ac; % Alignment coordinates for Right Camera
global Landmark;
global calledfile;


%% Import assay-specific parameters

%% If the assay type selected is Multisensory (2) or Isothermal + Odor (3)
if assaytype == 2 || assaytype == 3
    
    % Import Landmark Coodinates/Camera
    Landmark.X = xlsread(calledfile, 'Index', strcat('I2:I', num2str(1+numworms)))';
    Landmark.Y = xlsread(calledfile, 'Index', strcat('J2:J', num2str(1+numworms)))';
    [~, Landmark.Cam] = xlsread(calledfile, 'Index', 'A11');
    
    % Quality Checks of Landmark Coordinates
    if ~isequal(numel(Landmark.X),numel(Landmark.Y),numel(wormUIDs))
        error('User Error. The Index tab in your .xlsx file contains missing values in columns H-I.');
    end
    if isempty(Landmark.Cam)
        error('User Error. The Odor Camera value is missing from the Index tab in your .xlsx file.');
    end
    
    % Odor Scoring Region
    [~, SR.shape] = xlsread(calledfile, 'Index', 'A14');
    
    if SR.shape{1} == 'C' % scoring region shape is a circle
        SR.w = 2; % width, in cm
        SR.h = 2; % height, in cm
    elseif SR.shape{1} == 'S' %scoring region shape is square-ish aka a rectangle (staying away from using 'R' as anything but 'Right')
        SR.w = 2; % width, in cm
        SR.h = 3; % height, in cm
    else
        error('User Error. The Odor Arena shape value does not match expected values. It should be S (square-ish) or C (circle)');
    end
end

%% If the assay type is a Pure isothermal (4) or Pure thermotaxis (1)
if assaytype == 4 || assaytype == 1
    
    % Import Landmark Coodinates/Camera
    [Landmark.X,Landmark.Y] = deal(NaN(1,numworms)); %Will populate this later.
    [~, Landmark.Cam] = xlsread(calledfile, 'Index', 'A8'); % Landmark Camera is the same as the T(start) Camera.
end

%% Import camera alignment parameters, aka Collection Epoch Parameters

% Make array of L and R camera alignment coordinates, depending on the
% inputed identity of the track.
[~,~,ExptEpoch] = xlsread(calledfile, 'Index', strcat('H2:H', num2str(1+numworms)));
for i = 1:numworms
    if isnumeric(ExptEpoch{i})
        ExptEpoch{i} = num2str(ExptEpoch{i});
    end
end

for i = 1:numworms
    switch ExptEpoch{i}
        case 'late 2019'
            CL_ac(i,:,1) = [11.162, 2.444]; % X1, Y1;
            CL_ac(i,:,2) = [11.18, 4.807]; % X2, Y2
            
            CR_ac(i,:,1) = [0.045, 2.389]; % X1, Y1;
            CR_ac(i,:,2) = [0.006, 4.755]; % X2, Y2
        case '2020'
            CL_ac(i,:,1) = [12.020, 2.257]; % X1, Y1;
            CL_ac(i,:,2) = [12.109, 8.267]; % X2, Y2
            
            CR_ac(i,:,1) = [1.430, 1.808]; % X1, Y1;
            CR_ac(i,:,2) = [1.346, 7.790]; % X2, Y2
        case '2020_t'
            CL_ac(i,:,1) = [12.523, 2.260]; % X1, Y1;
            CL_ac(i,:,2) = [12.560, 8.275]; % X2, Y2
            
            CR_ac(i,:,1) = [1.428, 1.811]; % X1, Y1;
            CR_ac(i,:,2) = [1.348, 7.797]; % X2, Y2
            
        case '2018'
            CL_ac(i,:,1) = [14.45, 4.01]; % X1, Y1;
            CL_ac(i,:,2) = [14.42, 5.72]; % X2, Y2
            
            CR_ac(i,:,1) = [0.05, 2.74]; % X1, Y1;
            CR_ac(i,:,2) = [0.08, 4.37]; % X2, Y2
    end
end

end
