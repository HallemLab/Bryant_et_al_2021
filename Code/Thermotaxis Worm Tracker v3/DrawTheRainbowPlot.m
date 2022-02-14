function [fig] = DrawTheRainbowPlot(xvals, yvals, xvalscm,name, scale, varargin)
%varargin are optional arguments for axis labels. Input should be in the
%format {'xlabel', 'ylabel'}
% Assumes that the maximum duration of an experiment is 20 minutes (600
% frames)

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
colormap(parula)
hold on; 
linecm(xvals, yvals,@parula, scale);
plot(xvals(1,:),yvals(1,:),'k.'); % plotting starting locations
c = colorbar('southoutside',...
    'TickLabels', {'0', '2', '4', '6', '8', '10', '12', '14','16', '18', '20'},...
    'Ticks', [0 .1 .2 .3 .4 .5 .6 .7 .8 .9 1]);
c.Label.String = 'Time (min)';
hold off; 

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

function handles = linecm(x, y, cmap, scale)
%LINECM Plot a line with changing color according to a colormap
% For comparisons across differently scaled inputs, take a scaling
% parameter for the cmap
% x and y should at least have one dimension matching in size and the
% other one should be rescaleable to fit the other one.
% There is an edge case when this does not work like the normal LINE
% function, which is when size(x) == [n 1] and size(y) == [n n].
    arguments
        x (:, :) {mustBeNumeric}
        y (:, :) {mustBeNumeric}
        cmap function_handle
        scale (:, :) {mustBeNumeric}
    end
    % If x is a row vector, make it a row vector for consistency in the
    % rest of the code.
    if size(x, 1) == 1
        x = x.';
        y = y.';
    end
    
    len = size(x,1)-1;
    handles = cell(1, len);
    colors = cmap(scale);
    for i=1:len
        handles{i} = line([x(i, :); x(i+1, :)], [y(i, :); y(i+1, :)], "Color", colors(i, :));
    end
end