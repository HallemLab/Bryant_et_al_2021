%% Script for analysizing reversal behavior
% Specifically includes some code for determining the time varying thermal
% ramp.
%
%% IMPORTANT ASSUMPTIONS: 
% Assumes that the frame rate of the images is 1 frame/2 seconds.
subsetTemps = tempxvals(:,:);

for ii = 1:size(tempxvals,2)
vectTemps = subsetTemps(:,ii);
figure;
plot(vectTemps);

startTemp(ii) = round(vectTemps(1), 2);
maxTemp(ii) = round(max(vectTemps), 2);
endTemp(ii) = (vectTemps(find(~isnan(vectTemps),1,'last')));

% Calculate time (in seconds) that it takes to go from the starting
% temperature to the maximum temperature, also the distance ratio.
Index.start2max = find(vectTemps>=maxTemp(ii)-.2,1,'first');
Time.start2max(ii)=(Index.start2max)*2; %This assumes that the sampling frequency is 1 frame/2 seconds.
[maxdisp, pathlength] = displace([plotxvalscm(1,ii); plotyvals(1,ii)], plotxvalscm(1:Index.start2max,ii), plotyvals(1:Index.start2max,ii));
DistRatio.start2max(ii) = pathlength/maxdisp; 

%Calculate time (in seconds) that worm holds near warmest temperature +/- .2C .
Index.holdmax(ii,1:2) = [find(vectTemps>=maxTemp(ii)-.2,1,'first'), (find(vectTemps>=maxTemp(ii)-.2,1,'last'))];
Time.holdmax(ii)=(Index.holdmax(ii,2) - Index.holdmax(ii,1))*2;
[maxdisp, pathlength] = displace([plotxvalscm(Index.holdmax(ii,1),ii); plotyvals(Index.holdmax(ii,1),ii)], plotxvalscm(Index.holdmax(ii,1):Index.holdmax(ii,2),ii), plotyvals(Index.holdmax(ii,1):Index.holdmax(ii,2),ii));
DistRatio.holdmax(ii) = pathlength/maxdisp; 

% Calculate time (in seconds) that it takes to go from the maximum
% temperature to the final temperature.
Index.max2final(ii,1:2) = [(find(vectTemps>=maxTemp(ii)-.2,1,'last')), (find(vectTemps<=endTemp(ii),1,'first'))];
Time.max2final(ii)=abs(Index.max2final(ii,2)-Index.max2final(ii,1))*2;
[maxdisp, pathlength] = displace([plotxvalscm(Index.max2final(ii,1),ii); plotyvals(Index.max2final(ii,1),ii)], plotxvalscm(Index.max2final(ii,1):Index.max2final(ii,2),ii), plotyvals(Index.max2final(ii,1):Index.max2final(ii,2),ii));
DistRatio.max2final(ii) = pathlength/maxdisp; 

end
close all
Rate.start2max=(maxTemp-startTemp)./Time.start2max; % degreeC per second
Rate.max2final=(maxTemp-endTemp)./Time.max2final;  % degreeC per second

Rate.meanstart2max = median(Rate.start2max);
Rate.meanmax2final = median(Rate.max2final);

maxes = max(tempxvals);

index = find(max(tempxvals));

Indices = NaN(size(tempxvals));
    
numRZ = arrayfun(@(x) numel(find(tempxvals(:,x)>(maxes(x)-0.1))), 1:size(tempxvals, 2));
timeRZ = numRZ*2/60;  
avgRZ = median(timeRZ);
    
    finaldist = arrayfun(@(x,y) xvalscm(x,y), Indices, 1:size(xvalscm,2));