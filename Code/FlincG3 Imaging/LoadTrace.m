function [subset_cAD,subset_temp, full_cAD, full_temp, prestim_cAD, prestim_temp, complete_cAD, complete_temp] = LoadTrace(filename, tempname, fulltemp, Stim, time)
%% LoadTrace
%   Loads a single strFlincG3 trace
%   [subset_cAD,subset_temp, full_cAD, full_temp] = LoadTrace(filename, tempname, fulltemp, Stim, time)
%
%   Version 1.0
%   Version Date: 3-31-20
%
%% Revision History
%   3-31-20:    Forked from older version by ASB
%

warning('off','all'); % Don't display warnings
[~, UID, ~] = fileparts(filename);

%% Load Calcium imaging data from a single .csv file
fulltable = readtable(filename);
warning('on','all'); % Display warnings

% Parse datafile to extract the GFP signals from RO1 1 and ROI 2.
roi1.GFP = fulltable{2:2:end,4};
%roi1.YFP = fulltable{2:2:end,5};

roi2.GFP = fulltable{3:2:end,4};
%roi2.YFP = fulltable{3:2:end,5};

GFP = (roi1.GFP-roi2.GFP);
%YFP = (roi1.YFP-roi2.YFP);

%YFPadjust = YFP - (1.132*GFP); % Conversion factor calculated by ASB on 10-10-19
%YFP_CFP_ratio =  YFPadjust./GFP;

imagetime = fulltable{2:2:end,5};
timestamps= datetime(imagetime,'InputFormat','yyyy-MM-dd''T''HH:mm:ss.SSSSSSS','Format','yyyy-MM-dd HH:mm:ss');
relativetime=duration((timestamps(:)-timestamps(1)),'Format','mm:ss.SSSSSSS');
imagingdata=timetable(timestamps,GFP,roi1.GFP,roi2.GFP);

%% Import and process temperature log
a = datetime(fulltemp{:,1},'InputFormat','MM/dd/yyyy','Format','yyyy-MM-dd HH:mm:ss');
if ~isduration(fulltemp{:,2})
    b = datetime((fulltemp{:,2}),'InputFormat','HH:mm:ss','Format','HH:mm:ss');
    mydatetime = a + timeofday(b);
else
    mydatetime = a + fulltemp{:,2};
end

% subselecting temperature log so that retime doesn't add all the
% times/dates between discontinuous recording days
templog = timetable(mydatetime,fulltemp{:,4});
imagingdate = datestr(timestamps(1),'yyyy-mm-dd');
S = withtol(imagingdate,days(1));
sub_templog = templog(S,:);

%% Compress Data for easy plotting
lossyID=retime(imagingdata,'secondly','mean');
lossyTL=retime(sub_templog,'secondly','mean');

%% Align Imaging and Temperature Log Data
AlignedData = synchronize(lossyID,lossyTL,'intersection');
if isempty(AlignedData)
    error('No overlap between image times and temperature times. Likely gave Matlab the wrong ATEC Temp Log');
end

%% Calculate baseline, defined as time spent at a stated F0 temp + 0.4/ - 0.6 (.2 is the fudge factor on the ATEC machine, going lower on the cooler side in case things are overshot. This is currently a hack think about it a bit more)
dblAlignedData = AlignedData.Variables;
IND=find(dblAlignedData(:,4)<=(Stim.F0+.4) & dblAlignedData(:,4)>=(Stim.F0-0.6));
ibins = [1 ; find(diff(IND)>1); size(IND,1)];
ibins = ibins(IND(ibins)< (time.soak + time.stimdur)); % solves the problem from the next line down - prestim period should be before the stimulus, not after
[M, I] = max(diff(ibins)); %this uses the largest block of time near F0, which can break if the poststim period is longer than the prestim period.
indeces = [IND(ibins(I)+1):IND(ibins(I+1))];
%indeces = indeces(1:find(diff(indeces)>1,1,'first')); %trim so that only the first block of F0 temps is used
base=dblAlignedData(indeces,:);
baselinecorrection = mean(base(:,1));

correctedAlignedData=((dblAlignedData(:,1)-baselinecorrection)/baselinecorrection)*100;

%% Generate new variables for saving and export

[subset_cAD, subset_temp] = deal(NaN(((time.soak + time.pad(1) + time.stimdur)),1));

% This range should go from F0 to Fmax
if (indeces(end))-time.soak(1)-time.pad(1) < 0
    subset_cAD(indeces(1): indeces(end)+time.stimdur) = correctedAlignedData((indeces(1)):(indeces(end)+time.stimdur));
    subset_temp(indeces(1): indeces(end)+time.stimdur) = dblAlignedData((indeces(1)):(indeces(end)+time.stimdur),4);
else
    subset_cAD = correctedAlignedData((indeces(end))-time.soak(1)-time.pad(1):(indeces(end)+time.stimdur-1));
    subset_temp = dblAlignedData((indeces(end))-time.soak(1)-time.pad(1):(indeces(end)+time.stimdur-1),4);
end

% This range includes the prestim period from the start of the recording to
% F0, in cases where F0 ~= Holding
prestim_cAD = correctedAlignedData(1:(indeces(1)));
prestim_temp = dblAlignedData(1:(indeces(1)),4);

[full_cAD, full_temp] = deal(NaN(((indeces(end)+time.pad(4))-((indeces(end)-time.soak(1))-time.pad(3))+1),1));

if ((indeces(end))-time.soak(1))-time.pad(3)<=0
    temp = correctedAlignedData((1):(indeces(end)+time.pad(4)));
    full_cAD(abs(((indeces(end))-time.soak(1))-time.pad(3))+1:abs(((indeces(end))-time.soak(1))-time.pad(3))+size(temp,1))= temp;
    full_temp(abs(((indeces(end))-time.soak(1))-time.pad(3))+1:abs(((indeces(end))-time.soak(1))-time.pad(3))+size(temp,1)) = dblAlignedData((1):(indeces(end)+time.pad(4)),4);
    warning(['Recording ', UID,' is shorter than expected. It is truncated at the start of the experiment']);
elseif (indeces(end)+time.pad(4))>size(correctedAlignedData,1)
    temp = correctedAlignedData(((indeces(end)-time.soak(1)) - time.pad(3)):end);
    full_cAD(1:size(temp,1)) = temp;
    full_temp(1:size(temp,1)) = dblAlignedData((((indeces(end)-time.soak(1))-time.pad(3)):end),4);
    warning(['Recording ', UID,' is shorter than expected. It is truncated at the end of the experiment']);
else
    full_cAD = correctedAlignedData(((indeces(end)-time.soak(1))-time.pad(3)):(indeces(end)+time.pad(4)));
    full_temp = dblAlignedData(((indeces(end)-time.soak(1))-time.pad(3)):(indeces(end)+time.pad(4)),4);
end
complete_cAD = correctedAlignedData;
complete_temp = dblAlignedData(:,4);
end