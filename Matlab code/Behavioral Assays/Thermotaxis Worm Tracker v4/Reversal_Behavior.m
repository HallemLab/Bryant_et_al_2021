%% Script for analysizing reversal behavior
% Specifically includes some code for determining the time varying thermal
% ramp.
%
%% IMPORTANT ASSUMPTIONS: 
% Assumes that the frame rate of the images is 1 frame/2 seconds.
subsetTemps = tempxvals(:,[1,3]);
for ii = 1:size(subsetTemps,2)
vectTemps = subsetTemps(:,ii);
figure;
plot(vectTemps);

startTemp(ii) = round(vectTemps(1));
maxTemp(ii) = round(max(vectTemps));
endTemp(ii) = round(vectTemps(find(~isnan(vectTemps),1,'last')));

% Calculate time (in seconds) that it takes to go from the starting
% temperature to the maximum temperature.
Time.start2max(ii)=(find(vectTemps>=maxTemp(ii),1,'first'))*2; %This assumes that the sampling frequency is 1 frame/2 seconds.

%Calculate time (in seconds) that worm holds near warmest temperature.
Time.holdmax(ii)=((find(vectTemps>=maxTemp(ii),1,'last'))-(find(vectTemps>=maxTemp(ii),1,'first')))*2;

% Calculate time (in seconds) that it takes to go from the maximum
% temperature to the final temperature.
Time.max2final(ii)=abs((find(vectTemps<=endTemp(ii),1,'first'))-(find(vectTemps>=maxTemp(ii),1,'last')))*2;

end

Rate.start2max=(maxTemp-startTemp)./Time.start2max; % degreeC per second
Rate.max2final=(maxTemp-endTemp)./Time.max2final;  % degreeC per second

Rate.meanstart2max = median(Rate.start2max);
Rate.meanmax2final = median(Rate.max2final);

maxes = max(tempxvals);
arrayfun

index = find(max(tempxvals));

Indices = NaN(size(tempxvals));
    
numRZ = arrayfun(@(x) numel(find(tempxvals(:,x)>(maxes(x)-0.1))), 1:size(tempxvals, 2));
timeRZ = numRZ*2/60;  
avgRZ = median(timeRZ);
    
    finaldist = arrayfun(@(x,y) xvalscm(x,y), Indices, 1:size(xvalscm,2));