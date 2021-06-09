function [] = TT_TrackPlotter_v3(xvals,yvals, xvalscm,name, starttemp, gradientmax, pathstr)
%TrackPlotter.m Modular function for plotting worm tracks.
%  

%   Version 3.1
%   Version Date: 9/20/19

%% Revision History
%   12/30/17: created by Astra S. Bryant
%   11/5/18: adjusted the code for generating the automatic
%   axis to reflect using Tstart instead of GMax in converting track
%   distance to track temperatures (ASB)
%   4/8/19: renamed version 2.0 (ASB)
%   4/12/19: ported over some functionality from the chemotaxis version 2
%   tracker: making a separate plot of a subset of the tracks,
%   adding marks that indicate starting position of worms (ASB)
%   6/4/19: Updated to replace linspecer with cbrewer - also it's worth
%   noting that previously the linspecer wasn't actually implemented so the
%   colors were actually the default colors for matlab. (ASB)
%   6/18/19: Fixed a bug that I don't understand that was altering how the
%   .eps file was being exported. See:
%   https://www.mathworks.com/matlabcentral/answers/92521-why-does-matlab-not-export-eps-files-properly
%   (ASB)
%   9/20/19: Added 'Interpreter','none' to title() call. (ASB)

%% Make a plot with all the tracks, then save it.
fig = DrawThePlot(xvals, yvals, xvalscm,name);
movegui('northeast');
global plotflag
ax=get(fig,'CurrentAxes');
set(ax,'YLim',[-12 1]);
if isempty(plotflag)
    set(ax,'XLim',[min(floor(min(xvals))-1) max(ceil(max(xvals))+1)]);
end
setaxes = 1;
while setaxes>0 % loop through the axes selection until you're happy
answer = questdlg('Adjust X/Y Axes?', 'Axis adjustment', 'Yes');
            switch answer
                case 'Yes'
                    setaxes=1;
                    vals=inputdlg({'X Min','X Max','Y Min', 'Y Max'},...
                        'New X/Y Axes',[1 35; 1 35; 1 35;1 35],{num2str(ax.XLim(1)) num2str(ax.XLim(2))  num2str(ax.YLim(1)) num2str(ax.YLim(2))});
                    if isempty(vals)
                        setaxes = -1;
                    else
                    ax.XLim(1) = str2num(vals{1});
                    ax.XLim(2) = str2num(vals{2});
                    ax.YLim(1) = str2num(vals{3});
                    ax.YLim(2) = str2num(vals{4});
                    end
                case 'No'
                    setaxes=-1;
                case 'Cancel'
                    setaxes=-1;
            end

end
saveas(gcf, fullfile(pathstr,[name,'/', name, '-all.eps']),'epsc');
saveas(gcf, fullfile(pathstr,[name,'/', name,'-all.png']));

p = [1:1:size(xvals,2)];
%% Make a plot with a random subset of the tracks
if size(xvals,2)>10
    
    plotit = 1;
    movegui('northeast');
    
    while plotit>0 % Loop through the subset plotter until you get one you like.
        n = 5; % number of tracks to plot
        rng('shuffle'); % Seeding the random number generator to it's random.
        p = randperm(size(xvals,2),n);
        
        fig2=DrawThePlot(xvals(:,p),yvals(:,p),xvalscm(:,p),strcat(name, ' subset'));
        movegui('northeast');
        % Set axes for subplot equal to axes for full plot
        ax2=get(fig2,'CurrentAxes');
        set(ax2,'XLim',ax.XLim);
        set(ax2,'YLim',ax.YLim);
        
        answer = questdlg('Plot it again?', 'Subset Plot', 'Yes');
        switch answer
            case 'Yes'
                plotit=1;
            case 'No'
                plotit=-1;
            case 'Cancel'
                plotit=-1;
        end
    end
    
    saveas(gcf, fullfile(pathstr,[name,'/', name, '- subset.eps']),'epsc');
    saveas(gcf, fullfile(pathstr,[name,'/', name,'- subset.png']));
end


%% Make a plot showing temperature of the worms over time.
% Assumes that frame rate is 2 frames per second.
times = [0.5:0.5:length(xvals)*0.5]';
times = repmat(times, 1, size(xvals,2));
times(isnan(xvals)) = NaN;

fig = DrawThePlot(times(:,p), xvals(:,p), xvalscm(:,p),strcat(name, ' subset'), {'Time (sec)','Temperature (C)'});
movegui('northeast');
global plotflag
ax=get(fig,'CurrentAxes');
set(ax,'XLim',[min(floor(min(times))) max(ceil(max(times)))]);
set(ax,'YLim',[min(floor(min(xvals))-1) max(ceil(max(xvals))+1)]);

setaxes = 1;
while setaxes>0 % loop through the axes selection until you're happy
answer = questdlg('Adjust X/Y Axes?', 'Axis adjustment', 'Yes');
            switch answer
                case 'Yes'
                    setaxes=1;
                    vals=inputdlg({'X Min','X Max','Y Min', 'Y Max'},...
                        'New X/Y Axes',[1 35; 1 35; 1 35;1 35],{num2str(ax.XLim(1)) num2str(ax.XLim(2))  num2str(ax.YLim(1)) num2str(ax.YLim(2))});
                    if isempty(vals)
                        setaxes = -1;
                    else
                    ax.XLim(1) = str2num(vals{1});
                    ax.XLim(2) = str2num(vals{2});
                    ax.YLim(1) = str2num(vals{3});
                    ax.YLim(2) = str2num(vals{4});
                    end
                case 'No'
                    setaxes=-1;
                case 'Cancel'
                    setaxes=-1;
            end

end
saveas(gcf, fullfile(pathstr,[name,'/', name, '-allTime.eps']),'epsc');
saveas(gcf, fullfile(pathstr,[name,'/', name,'-allTime.png']));

end

%% The bit that makes the figure
% Oh look, an inline script!

function [fig] = DrawThePlot(xvals, yvals, xvalscm,name, varargin)
%varargin are optional arguments for axis labels. Input should be in the
%format {'xlabel', 'ylabel'}
% Retrieve some global variables!
global plotflag % retrieve flag for isothermal assay

if length(varargin) == 0
    xaxislab = 'Temperature (C)';
    yaxislab = 'Distance (cm)';
else
    xaxislab = varargin{1}{1};
    yaxislab = varargin{1}{2};
end

fig=figure;
C=cbrewer('qual','Set1',size(xvals,2),'PCHIP'); % set color scheme
set(groot,'defaultAxesColorOrder',C);  % apply color scheme. Comment this out if you'd rather use matlabs default colors.
hold on;

% Drawing Tracks
plot(xvals, yvals, 'LineWidth',1);
plot(xvals(1,:),yvals(1,:),'k.'); % plotting starting locations
hold off

% Labeling the figure and saving
ylabel(yaxislab); xlabel(xaxislab);
title(name,'Interpreter','none');
set(gcf, 'renderer', 'Painters');

% Adjusting for the case of tracks in an isothermal gradient
if ~isempty(plotflag)
    xaxislab = 'Distance (cm)';
    plot(xvalscm, yvals);
    if min(floor(min(xvalscm)))+12 > max(ceil(max(xvalscm)))
        axis([min(floor(min(xvalscm)))-1 min(floor(min(xvalscm)))+12 -10 3]);
    else
        axis([min(floor(min(xvalscm)))-1 max(ceil(max(xvalscm))) -12 1]);
    end
    ylabel(yaxislab); xlabel(xaxislab);
end
end

