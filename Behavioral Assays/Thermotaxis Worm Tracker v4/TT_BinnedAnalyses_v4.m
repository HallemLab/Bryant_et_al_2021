function [binnedspeed]= TT_BinnedAnalyses_v4(tempxvals, instantspeed)
%% TT_BinnedAnalyses_v4 calculates analysis values based on subsets of the data. 
%   Used for analyzing a specific portion of the thermal gradient.
%
%   [binnedspeed]= TT_BinnedAnalyses_v4(tempxvals, instantspeed)
%
%   Version 4.0
%   Version Date: 2/10/20
%
%% Revision History
%   5/2/18: v1.0 written by A.S.B. to analyze instantaneous speed of iL3s at
%   different points along a thermal gradient
%   4/8/19: renamed v.2 by ASB
%   9/18/19 upgrading to version 3.0 ASB
%   2/10/20 renamed version 4.0 ASB


answer = inputdlg({'Upper bound:','Lower bound:'}, 'Input boundaries of thermal bin',[1 35],{'27','25'});
hibound = str2double(answer{1});
lobound = str2double(answer{2});
temps=tempxvals(2:end,:);
Index=(temps>hibound | temps<lobound);
tempbin=instantspeed;
tempbin(Index)=NaN;
binnedspeed=mean(tempbin,'omitnan')';
