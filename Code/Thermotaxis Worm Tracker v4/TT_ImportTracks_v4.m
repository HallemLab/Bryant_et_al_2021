function [xvals,yvals,frame] = TT_ImportTracks_v4(wormUIDs, tracklength, numworms)
%% TT_ImportTracks_v4 imports the x and y coordinates of individual worm tracking data from an excel spreadsheet.
%
%   [xvals,yvals,frame] = TT_ImportTracks_v4(wormUIDs, tracklength, numworms)
% 
%   Version 4.1
%   Version Date: 2/20/20
%
%   Required Inputs:
%       wormUIDs = names of the tabs containing the tracking data for import
%       tracklength = expected number of images, usually 300 for a 10 min
%           tracking session and 450 for a 15 min session.
%       numworms = number of tracks (i.e. individual worm data) to import
%   Outputs:
%       xvals = x-coordinates of the worm location, in pixels
%       yvals = y-coordinates of the worm location, in pixels
%       frame = frame numbers of the x/y coordinates

%% Revision History
%    12/30/17 Created by Astra S. Bryant
%    4/8/19 modified handling of primary and secondary cameras, renamed
%    version 2.0 ASB
%   9/18/19 upgrading to version 3.0 ASB
%   2/10/20 renamed version 4.0 ASB
%   2/20/20 Removed the complicated secondary camera option as I don't
%   think it's needed anymore.

global calledfile

[xvals,yvals,frame] = deal(NaN(tracklength,numworms));

for i=1:numworms
    [~, sheets]=xlsfinfo(calledfile);
    sheet = [wormUIDs{i}];
    if ~isempty(find(strcmp(sheets,sheet),1))
        testexists = importfileXLS(calledfile, sheet, strcat('D1:D',num2str(tracklength)));
        if ~isempty(testexists)
            tempx(:,1) = importfileXLS(calledfile, sheet, strcat('D1:D',num2str(tracklength)));
            tempy(:,1) = importfileXLS(calledfile, sheet, strcat('E1:E',num2str(tracklength)));
            tempf(:,1) = importfileXLS(calledfile, sheet, strcat('C1:C',num2str(tracklength)));
            xvals(1:length(tempx),i)=tempx;
            yvals(1:length(tempy),i)=tempy;
            frame(1:length(tempf),i)=tempf;
        end
        clear tempx tempy tempf
    end
    
end
end





