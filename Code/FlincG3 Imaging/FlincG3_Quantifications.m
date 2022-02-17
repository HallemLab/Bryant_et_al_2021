function [Temps, Response, Results] = FlincG3_Quantifications (Temps,Response, Stim, time,n)
%% FlincG3_Quantifications
%   Quantifies YC3.6 responses to thermal stimuli. Calculations include:
%   T*, temp eliciting maximal response, mean FlincG3 response at specified temp
%   bins, Pearson and Spearman Correlation coefficients
%
%   Version 1.2
%   Version Date: 9-6-20
%
%% Revision History
%   04-01-20    Forked from older version by ASB
%   04-02-20    Renamed a bunch of variables to make more accessible.
%   09-08-20    Changed procedure for detecting threshold such that if
%               calcium trace does not cross threshold, NaN is returned.

global assaytype

%Response.nsub = Response.subset./max(Response.full);

if assaytype ~= 2
    %% Generate data subsets for positive thermotaxis ramps
    [Response.AtTh, Temps.AtTh, ...
        Response.AboveTh, Temps.AboveTh, ...
        Response.Tmax, Temps.Tmax] = deal(NaN(size(Temps.subset)));
    
    for i = 1:size(Temps.subset,2)
        % Temperature bin of Near T(holding)
        Temps.AtTh(1:size(find(Temps.subset(:,i)>=Stim.NearTh(1) & Temps.subset(:,i)<=Stim.NearTh(2)),1),i) = Temps.subset(find(Temps.subset(:,i)>=Stim.NearTh(1) & Temps.subset(:,i)<=Stim.NearTh(2)),i);
        Response.AtTh(1:size(find(Temps.subset(:,i)>=Stim.NearTh(1) & Temps.subset(:,i)<=Stim.NearTh(2)),1),i) = Response.subset(find(Temps.subset(:,i)>=Stim.NearTh(1) & Temps.subset(:,i)<=Stim.NearTh(2)),i);
        
        % Temperature bin of above T(holding)
        Temps.AboveTh(1:size(find(Temps.subset(:,i)>=Stim.AboveTh(1)),1),i) = Temps.subset(find(Temps.subset(:,i)>=Stim.AboveTh(1)),i);
        Response.AboveTh(1:size(find(Temps.subset(:,i)>=Stim.AboveTh(1)),1),i) = Response.subset(find(Temps.subset(:,i)>=Stim.AboveTh(1)),i);
        
        % Temperature bin of near T(max)
        Temps.Tmax(1:size(find(Temps.full(:,i)>=Stim.max(1)-3),1),i) = Temps.full(find(Temps.full(:,i)>=Stim.max(1)-3),i);
        Response.Tmax(1:size(find(Temps.full(:,i)>=Stim.max(1)-3),1),i) = Response.full(find(Temps.full(:,i)>=Stim.max(1)-3),i);
        
    end
    
    %% Calculate and plot linear regression of different temperature windows
    % When calling FlincG3_ResponseFitting.m, users choose whether to calculate
    % Spearman's or Pearson's correlation using the 3rd input variable.
    % 1 = Pearson's correlation, for quantifying linear correlation
    % 2 = Spearman's correlation, for quantifying monotonic correlations
    set(0,'DefaultFigureVisible','off');
    [Results.rsq.AtTh, Results.Corr.AtTh] = FlincG3_ResponseFitting(Temps.AtTh, Response.AtTh,2,strcat(n,'_AtTh_'));
    [Results.rsq.AboveThPear, Results.Corr.AboveThPear] = FlincG3_ResponseFitting(Temps.AboveTh, Response.AboveTh,1,strcat(n,'_AboveThPear_'));
    [Results.rsq.AboveThSpear, Results.Corr.AboveThSpear] = FlincG3_ResponseFitting(Temps.AboveTh, Response.AboveTh,2,strcat(n,'_AboveThSpear_'));
    
    set(0,'DefaultFigureVisible','on');
    
else
    %% Generate data subsets for negative thermotaxis ramps
    [Response.BelowTh, Temps.BelowTh,...
        Response.Tmin, Temps.Tmin] = deal(NaN(size(Temps.subset)));
    
    for i = 1:size(Temps.subset,2)
        % Temperature bin of descending portion
        Temps.BelowTh(1:size(find(Temps.subset(:,i)<=(Stim.BelowTh(1)+0.2) & Temps.subset(:,i)>= (Stim.BelowTh(2)-0.2)),1),i) = Temps.subset(find(Temps.subset(:,i)<=(Stim.BelowTh(1)+0.2) & Temps.subset(:,i)>= (Stim.BelowTh(2)-0.2)),i);
        Response.BelowTh(1:size(find(Temps.subset(:,i)<=(Stim.BelowTh(1)+0.2) & Temps.subset(:,i)>= (Stim.BelowTh(2)-0.2)),1),i) = Response.subset(find(Temps.subset(:,i)<=(Stim.BelowTh(1)+0.2) & Temps.subset(:,i)>= (Stim.BelowTh(2)-0.2)),i);
        trim(i) = find(Temps.BelowTh(:,i)<=(Stim.BelowTh(2)+.2),1,'last');
        Temps.BelowTh(trim(i)+1:end,i)=NaN;
        Response.BelowTh(trim(i)+1:end,i)=NaN;
        
        
         % Temperature bin of near T(max)
        Temps.Tmin(1:size(find(Temps.full(:,i)<=Stim.min(1)+3),1),i) = Temps.full(find(Temps.full(:,i)<=Stim.min(1)+3),i);
        Response.Tmin(1:size(find(Temps.full(:,i)<=Stim.min(1)+3),1),i) = Response.full(find(Temps.full(:,i)<=Stim.min(1)+3),i);
        
    end
    
    
    %% Calculate and plot linear regression of different temperature windows
    % When calling FlincG3_ResponseFitting.m, users choose whether to calculate
    % Spearman's or Pearson's correlation using the 3rd input variable.
    % 1 = Pearson's correlation, for quantifying linear correlation
    % 2 = Spearman's correlation, for quantifying monotonic correlations
    set(0,'DefaultFigureVisible','off');
    [Results.rsq.BelowTh, Results.Corr.BelowTh] = FlincG3_ResponseFitting(Temps.BelowTh, Response.BelowTh,1,strcat(n,'_BelowTh_'));
    set(0,'DefaultFigureVisible','on');
end

%% Calculate Temperature at which point Experimental trace deviates from control trace by 3*STD of control for at least N seconds
% The amount of time the absolute value of the trace should be above threshold should reflect 0.25 degree C
% Calculate based on ramp rate such that:
% If ramp rate is 0.025C/s, the time it would take to increase 0.25C is 10 seconds, which equals 20 frames.

for i = 1:size(Temps.subset,2)
    base(i)=mean(Response.subset(find(Temps.subset(:,i)<=(Stim.F0+.2) & Temps.subset(:,i) >= (Stim.F0 - 0.2)),i));
    stdbase(i)=std(Response.subset(find(Temps.subset(:,i)<=(Stim.F0+.2) & Temps.subset(:,i) >= (Stim.F0 - 0.2)),i));
    threshold(i) = (3*abs(stdbase(i))); %+ abs(base(i));
end

n_expt = size(Response.subset,2);
disp(strcat('number of recordings: ',num2str(n_expt)));

N = 0.25/time.rampspeed*2; % required number of consecutive numbers following a first one (with a 500 ms frame rate, this is N/2 seconds)

if assaytype ~= 2
    % RUN THIS FOR EACH INDIVIDUAL EXPERIMENTAL TRACE
    II = arrayfun(@(x)(find(Response.subset(:,x)>=threshold(x) | Response.subset(:,x)<=-threshold(x))), [1:n_expt], 'UniformOutput', false);
    kk = arrayfun(@(x)([true;diff(II{x})~=1]), [1:n_expt], 'UniformOutput', false);
    ss = arrayfun(@(x)(cumsum(kk{x})), [1:n_expt], 'UniformOutput', false);
    xx = arrayfun(@(x)(histc(ss{x},1:ss{x}(end))), [1:n_expt], 'UniformOutput', false);
    idxx = arrayfun(@(x)(find(kk{x})), [1:n_expt], 'UniformOutput', false);
    outt = arrayfun(@(x)(II{x}(idxx{x}(xx{x} >= N))), [1:n_expt], 'UniformOutput', false);
    
else
    % RUN THIS FOR EACH INDIVIDUAL EXPERIMENTAL TRACE
    % Only look for threshold during the negative temp ramp
    II = arrayfun(@(x)(find(Response.subset(time.soak:end,x)>=threshold(x) | Response.subset(time.soak:end,x)<=-threshold(x))), [1:n_expt], 'UniformOutput', false);
    kk = arrayfun(@(x)([true;diff(II{x})~=1]), [1:n_expt], 'UniformOutput', false);
    ss = arrayfun(@(x)(cumsum(kk{x})), [1:n_expt], 'UniformOutput', false);
    xx = arrayfun(@(x)(histc(ss{x},1:ss{x}(end))), [1:n_expt], 'UniformOutput', false);
    idxx = arrayfun(@(x)(find(kk{x})), [1:n_expt], 'UniformOutput', false);
    outt = arrayfun(@(x)(II{x}(idxx{x}(xx{x} >= N))), [1:n_expt], 'UniformOutput', false);
    outt = arrayfun(@(x)(outt{x}+time.soak), [1:n_expt], 'UniformOutput', false);
end

% Find Calcium Response at Temperature Thresh
for x = 1:n_expt
    
    if ~isempty(outt{x})
        Results.Thresh.index(x) = Response.subset(outt{x}(1),x);
    else
        Results.Thresh.index(x) = NaN;
    end
end

% Get Temperature Threshold
for x = 1:n_expt
    
    if ~isempty(outt{x})
        Results.Thresh.temp(x) = Temps.subset(outt{x}(1),x);
    else
        Results.Thresh.temp(x) = NaN;
    end
end

for x = 1:n_expt
    
    if ~isempty(outt{x})
        plot_outt(x) = (outt{x}(1));
    else
        plot_outt(x) = NaN;
    end
end

% Get the average of the individual thresholds (for the FlincG3 Response and Temperature
% trace)
Results.Thresh_temp = median(Results.Thresh.temp, 'omitnan');
disp(strcat('Median T*: ',num2str(Results.Thresh_temp)));

Results.Tx = median(Results.Thresh.index, 'omitnan');

% Align the full and subset traces to identify the timing of the threshold
% cross
for i = 1:n_expt
    [~, ia, ~] = intersect(Response.full(:,i), Response.subset(:,i), 'stable');
    time_adjustment_index(i) = ia(1) - 1;
end

Results.out = median((plot_outt + time_adjustment_index), 'omitnan');

%% Calculate temperature that elicits maximal response
[m, I] = max(Response.subset,[],1,'linear');
Results.maximalTemp = Temps.subset(I);

Tmax_temp = median(Results.maximalTemp, 'omitnan');
disp(strcat('Median Tmax: ',num2str(Tmax_temp)));

%% Calculate temperature that elicits most negative response
[m, I] = min(Response.subset,[],1,'linear');
Results.minimalTemp = Temps.subset(I);

Tmin_temp = median(Results.minimalTemp, 'omitnan');
disp(strcat('Median Tmin: ',num2str(Tmin_temp)));

%% Determine whether miminal temp is above or below Tc
Results.Tmin_category = Results.minimalTemp > Stim.F0+1;

%% Calculate average Response at given temperature bins
for i = 1:n_expt
    Results.ResponseBin1(i) = median(Response.subset(find(Temps.subset(:,i)>=Stim.Analysis(1)-.2 & Temps.subset(:,i)<=Stim.Analysis(1)+.2),i));
    
    Results.ResponseBin2(i) = median(Response.subset(find(Temps.subset(:,i)>=Stim.Analysis(2)-.2 & Temps.subset(:,i)<=Stim.Analysis(2)+.2),i));
end

%% Calculate average Response at at holding temp during prestimulus period
for i = 1:n_expt
    Results.Holding(i) = median(Response.prestim(find(Temps.prestim(:,i)>=Stim.holding-.2 & Temps.prestim(:,i)<=Stim.holding+.2),i));
end


%% Calculate average Response at max temperature
for i = 1:n_expt
    Results.MaxTempResponse(i) = median(Response.subset(find(Temps.subset(:,i)>=Stim.max-.2 & Temps.subset(:,i)<=Stim.max+.2),i));
end

%% Get response during first 15 seconds of Stim.max
for i = 1:n_expt
    if assaytype ~=2
        temp = (Response.full(find(Temps.full(:,i)>=Stim.max, 1,'first'):find(Temps.full(:,i)>=Stim.max-0.1, 1,'last'),i));
    
        Results.AdaptBins(1,i) = median(temp(1:15));
        Results.AdaptBins(2,i) = median(temp(31:end));
    else
        temp = (Response.full(find(Temps.full(:,i)<=Stim.min, 1,'first'):find(Temps.full(:,i)<=Stim.min+0.1, 1,'last'),i));
        Results.AdaptBins(1,i) = median(temp(1:15));
        Results.AdaptBins(2,i) = median(temp(31:end));
    
    end   
end

%% Categorize Tmax responses
        % as greater, lesser, or not different than the holding response
temp = Results.AdaptBins;
     if assaytype ~=2 
        if assaytype ~= 4
            % If this is a stimulus where holding response is higher than
            % F0, calculate the threshold from the prestim period
            for i = 1:size(Temps.prestim,2)
                base(i)=mean(Response.prestim(find(Temps.prestim(:,i)<=(Stim.holding+.2) & Temps.prestim(:,i) >= (Stim.holding - 0.2)),i));
                stdbase(i)=std(Response.prestim(find(Temps.prestim(:,i)<=(Stim.holding+.2) & Temps.prestim(:,i) >= (Stim.holding - 0.2)),i));
                threshold(i) = (3*abs(stdbase(i))); %+ abs(base(i));    
            end
            
            % Renormalized Response.Tmax and Early/Late tmax quantifications relative to the mean Tc response, aka
            % the "base" here
            Response.Tmax_adjusted = Response.Tmax-base;
            Results.AdaptBins(1,:) = Results.AdaptBins(1,:) - base;
            Results.AdaptBins(2,:) = Results.AdaptBins(2,:) - base;
        else   
            % If this is a reversal stimulus, then the holding response is
            % F0 and threshold is as defined above
            Response.Tmax_adjusted = Response.Tmax;
        end 
            % Categorize first 15 seconds of Tmax response
            above = (temp(1,:) >= threshold);
            below = (temp(1,:) <= -threshold)*-1;
            Results.TmaxEarly_Cat = above + below;
            
            % Categorize late Tmax response
            above = (temp(2,:) >= threshold);
            below = (temp(2,:) <= -threshold)*-1;
            Results.TmaxLate_Cat = above + below; 
     else
         % Stimulus where holding response is higher than
            % F0, so calculate the threshold from the prestim period
            for i = 1:size(Temps.prestim,2)
                base(i)=mean(Response.prestim(find(Temps.prestim(:,i)<=(Stim.holding+.2) & Temps.prestim(:,i) >= (Stim.holding - 0.2)),i));
                stdbase(i)=std(Response.prestim(find(Temps.prestim(:,i)<=(Stim.holding+.2) & Temps.prestim(:,i) >= (Stim.holding - 0.2)),i));
                threshold(i) = (3*abs(stdbase(i))); %+ abs(base(i));    
            end
            
            % Renormalized Response.Tmax and Early/Late tmax quantifications relative to the mean Tc response, aka
            % the "base" here
            Response.Tmin_adjusted = Response.Tmin-base;
            Results.AdaptBins(1,:) = Results.AdaptBins(1,:) - base;
            Results.AdaptBins(2,:) = Results.AdaptBins(2,:) - base;
            
            % Categorize first 15 seconds of Tmax response
            above = (temp(1,:) >= threshold);
            below = (temp(1,:) <= -threshold)*-1;
            Results.TminEarly_Cat = above + below;
            
            % Categorize late Tmax response
            above = (temp(2,:) >= threshold);
            below = (temp(2,:) <= -threshold)*-1;
            Results.TminLate_Cat = above + below;
    end   


%% Calculate average Response at F0 temperature
for i = 1:n_expt
    Results.F0TempResponse(i) = median(Response.subset(find(Temps.subset(:,i)>=Stim.F0-.2 & Temps.subset(:,i)<=Stim.F0+.2),i));
end




end


