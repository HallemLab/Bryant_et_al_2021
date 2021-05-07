function [CLandRxvalscm, CLandRyvalscm] = TT_AlignDualCameras_v4(TstartCam, CLxvalscm, CLyvalscm, CRxvalscm, CRyvalscm,frame, numworms, tracklength)
%%  TT_AlignDualCameras_v4 Modular function for aligning worm tracks (in cm) from two cameras.
%
%   [CLandRxvalscm, CLandRyvalscm] = TT_AlignDualCameras_v4(TstartCam,
%   CLxvalscm, CLyvalscm, CRxvalscm, CRyvalscm,frame, numworms,
%   tracklength)
%   
%   This was split from TT_AnalyzeTracks in order to give more flexibility
%   in the order of the pixels to cm conversion and the alignment of two
%   cameras. Original version included both converstion and alignment and
%   calculation of track parameters such as distance ratio. Now the
%   everything but the camera alignment are found in different functions.
%
%   Version 4.2 Updated 3/18/20
%
%% Revision History
%   2/12/20: Split TT_AnalyzeTracks_v4 into multiple functions. 
%   2/20/20: An aggressive restructuring of how the alignment is functioning. Since the
%       cm values being inputed to the program are already normalized onto a
%       common standard, all that remains to be done is to smartly concatenate
%       the two tracks. Also added the functionality to remove overlapping
%       frames across both cameras as those are no longer necessary for the
%       alignment.
%   3/18/20: Fixed issue where the concatination lengthened the tracks
%       beyond the stated track length, forcing the propagation of zeros in
%       other track columns. This led to some very ugly plots.

CLandRxvalscm = NaN(tracklength, numworms);
CLandRyvalscm = NaN(tracklength, numworms);


%% Depending on whether the Tstart camera is  the left or right camera
% Concatenate the tracks.
if TstartCam{1} == 'R' % Landmark is on the Right Camera, need to preserve those camera values as they are correctly normalized  
    for i = 1:numworms
        trimmedCR.xvals = rmmissing(CRxvalscm(:,i));
        trimmedCR.yvals = rmmissing(CRyvalscm(:,i));
        trimmedCL.xvals = rmmissing(CLxvalscm(:,i));
        trimmedCL.yvals = rmmissing(CLyvalscm(:,i));
        trimmedCL.frames = rmmissing(frame.CL(:,i));
        trimmedCR.frames = rmmissing(frame.CR(:,i));
        
        [~,ia,~] = intersect(trimmedCL.frames,trimmedCR.frames); % remove double frames as they are no longer needed for the alignment.
        if ~isempty(ia)
            trimmedCL.xvals(ia) = NaN;
            trimmedCL.yvals(ia) = NaN;
            trimmedCL.frames(ia) = NaN;
            
            trimmedCL.xvals = rmmissing(trimmedCL.xvals);
            trimmedCL.yvals = rmmissing(trimmedCL.yvals);
            trimmedCL.frames = rmmissing(trimmedCL.frames);
        end
        
        CLandRxvalscm(1:size(cat(1,trimmedCR.xvals,trimmedCL.xvals)),i) = cat(1,trimmedCR.xvals,trimmedCL.xvals);
        CLandRyvalscm(1:size(cat(1,trimmedCR.yvals,trimmedCL.yvals)),i) = cat(1,trimmedCR.yvals,trimmedCL.yvals);
    end
end

if TstartCam{1} == 'L'
    for i = 1:numworms
        trimmedCL.xvals = rmmissing(CLxvalscm(:,i));
        trimmedCL.yvals = rmmissing(CLyvalscm(:,i));
        trimmedCR.xvals = rmmissing(CRxvalscm(:,i));
        trimmedCR.yvals = rmmissing(CRyvalscm(:,i));        
        trimmedCL.frames = rmmissing(frame.CL(:,i));
        trimmedCR.frames = rmmissing(frame.CR(:,i));
        
        [~,ia,~] = intersect(trimmedCR.frames,trimmedCL.frames); % remove double frames as they are no longer needed for the alignment.
        if ~isempty(ia)
            trimmedCR.xvals(ia) = NaN;
            trimmedCR.yvals(ia) = NaN;
            trimmedCR.frames(ia) = NaN;
            
            trimmedCR.xvals = rmmissing(trimmedCR.xvals);
            trimmedCR.yvals = rmmissing(trimmedCR.yvals);
            trimmedCR.frames = rmmissing(trimmedCR.frames);
        end
        
        CLandRxvalscm(1:size(cat(1,trimmedCR.xvals,trimmedCL.xvals)),i) = cat(1,trimmedCL.xvals,trimmedCR.xvals);
        CLandRyvalscm(1:size(cat(1,trimmedCR.yvals,trimmedCL.yvals)),i) = cat(1,trimmedCL.yvals,trimmedCR.yvals);
    end
end

% Trim to appropriate size.
if size(CLandRxvalscm,1)>tracklength
    CLandRxvalscm=CLandRxvalscm(1:tracklength,:);
    CLandRyvalscm=CLandRyvalscm(1:tracklength,:);
    
end

% This may be necessary in cases, but i think it won't be necessary.
%CLandRxvalscm(CLandRxvalscm == 0) = NaN;
%CLandRyvalscm(CLandRyvalscm == 0) = NaN;
end




