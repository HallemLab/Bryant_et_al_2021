function [file, analyze, TstartCam] = ExptList(datasetfile)
%Generates a GUI for selecting worm tracks for anaylsis by Manual_WormTracks.m

%Import variables from the Index sheet
% Designates the camera on which worms start


[num, txt]=xlsread(datasetfile);
fileIDs = txt(2:end,1);
[S, V]= listdlg('PromptString','Select a Dataset:','SelectionMode', 'single', 'ListString', fileIDs);
S=S+1; %account for column headers in xlsx file

file.CL=txt{S,2};

if ~isempty(txt{S,2})
    analyze.CL=1;
    file.CL=txt{S,2};
else
    analyze.CL=0;
    TstartCam = 'R';
end

if ~isempty(txt{S,3})
    analyze.CR=1;
    file.CR=txt{S,3};
else
    analyze.CR=0;
    TstartCam = 'L';
end

if ~exist('TstartCam')
    TstartCam = txt{S,4};
end

end

