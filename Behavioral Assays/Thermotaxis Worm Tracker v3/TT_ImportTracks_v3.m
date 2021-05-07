function [xvals,yvals] = TT_ImportTracks_v3(file, wormUIDs, tracklength, numworms, secondarycam)
%ImportTracks - Modular function that will import the x and y coordinates
%of individual worm tracking data from an excel spreadsheet.
%   Required Inputs:
%       file = name of excel spreadsheet containing the tracking data in
%       tabs
%       wormUIDs = names of the tabs containing the tracking data for import
%       tracklength = expected number of images, usually 300 for a 10 min
%           tracking session and 450 for a 15 min session.
%       numworms = number of tracks (i.e. individual worm data) to import
%   Optional Inputs:
%       secondarycam = if this variable exists, it tells matlab that it's impoting tracks from the secondary (non-Tstart) camera
%   Outputs:
%       xvals = x-coordinates of the worm location, in pixels
%       yvals = y-coordinates of the worm location, in pixels

%% Revision History
%    12/30/17 Created by Astra S. Bryant
%    4/8/19 modified handling of primary and secondary cameras, renamed
%    version 2.0 ASB
%   9/18/19 upgrading to version 3.0 ASB

xvals=NaN(tracklength,numworms);
yvals=NaN(tracklength,numworms);

if exist('secondarycam')
    %% Dual Camera Import, assumes an initial import has already occured and now you're importing the secondary camera
    [status, sheets]=xlsfinfo(file);
    
    for i=1:numworms
        sheet = [wormUIDs{i}];
        if ~isempty(find(strcmp(sheets,sheet)))
            testexists = importfileXLS(file, sheet, strcat('D1:D',num2str(tracklength)));
            if ~isempty(testexists)
                tempx(:,1) = importfileXLS(file, sheet, strcat('D1:D',num2str(tracklength)));
                tempy(:,1)= importfileXLS(file, sheet, strcat('E1:E',num2str(tracklength)));
                xvals(1:length(tempx),i)=tempx;
                yvals(1:length(tempy),i)=tempy;
                
                clear tempx tempy     
            end  
        end 
    end
else
    %% Primary Camera Import
    for i=1:numworms
        
        sheet = [wormUIDs{i}];
        testexists = importfileXLS(file, sheet, strcat('D1:D',num2str(tracklength)));
        if ~isempty(testexists)
            tempx(:,1) = importfileXLS(file, sheet, strcat('D1:D',num2str(tracklength)));
            tempy(:,1)= importfileXLS(file, sheet, strcat('E1:E',num2str(tracklength)));
            xvals(1:length(tempx),i)=tempx;
            yvals(1:length(tempy),i)=tempy;
        end
        clear tempx tempy
        
    end
end


end


