%% Script for analysizing reversal behavior
% Specifically includes some code for determining the time varying thermal
% ramp.
%
%% IMPORTANT ASSUMPTIONS: 
% Assumes that the frame rate of the images is 1 frame/2 seconds.


answer = inputdlg({'Upper bound:','Lower bound:'}, 'Input boundaries of thermal bin',[1 35],{'21.1','20.6'});
hibound = str2num(answer{1});   %21.1 for Tc = 15; %24.1 for Tc = 23
lobound =str2num(answer{2});    %20.6 for Tc = 15; %23.6 for Tc = 23

for ii = 1:size(tempxvals,2)
vectTemps = tempxvals(:,ii);
%figure;
%plot(vectTemps);

index.PT = [find(vectTemps>=lobound,1,'first'), find(vectTemps>=hibound,1,'first')];
index.hold = [find(vectTemps>=hibound,1,'first'), find(vectTemps>=hibound,1,'last')];
index.NT = [find(vectTemps>=hibound,1,'last'), find(vectTemps>=lobound,1,'last')];


%The calculations below assume that the sampling frequency is 1 frame/2 seconds.
% Calculate time (in seconds) that it takes to go from the first low bound to the first high bound.
Time.lo2hi(ii) = (index.PT(2) - index.PT(1)) * 2;
a(:,1) = tempxvals(index.PT(1):index.PT(2),ii);
a(:,2) = plotyvals(index.PT(1):index.PT(2),ii);
a(:,3) = instantspeed(index.PT(1):index.PT(2),ii);

%Calculate time (in seconds) that worm is above hibound.
Time.holdhi(ii) = (index.hold(2) - index.hold(1)) * 2;
b(:,1) = tempxvals(index.hold(1): index.hold(2),ii);
b(:,2) = plotyvals(index.hold(1): index.hold(2),ii);
b(:,3) = instantspeed(index.hold(1): index.hold(2),ii);

% Calculate time (in seconds) that it takes to go from the last high bound to the last lo bound.
Time.hi2lo(ii) = (index.NT(2) - index.NT(1)) * 2;
c(:,1) = tempxvals(index.NT(1):index.NT(2),ii);
c(:,2) = plotyvals(index.NT(1):index.NT(2),ii);
c(:,3) = instantspeed(index.NT(1):index.NT(2),ii);

Rate.lo2hi(ii) = median(a(:,3)); % speed during PT through window
Rate.holdhi(ii) = median(b(:,3)); % speed above window
Rate.hi2lo(ii) = median(c(:,3)); % speed during NT through window

clear a b c
end
