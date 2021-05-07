function[x, y] = TT_polygon (xycenter, w, h, shapeID, plotting, facecolor, edgecolor, facealpha, edgethickness)
%% TT_polygon generates the [X, Y] vertices for a selection of polygons, including: ellipse, rectangle
%
%       [x, y] = TT_polygon(xycenter, hr, vr, facecolor, edgecolor, facealpha,
%       edgethickness).
%
%           xycenter = 1x2 array containing x,y coordinates of the centroid
%           w = width
%           h = height
%           shapeID = 'C' for circle/ellipse, 'S' for square/rectangle
%           plotting = if 'y' draws the polygon, using following parameters
%           facecolor =  fill color
%           edgecolor =  edge color
%           facealpha =  opacity (numerical value)
%           edgethickness = thickeness of edge line (numerical value)
%
%% Revision History
%   2-22-20 created by ASB

%% Code
if shapeID == 'C' % circle
    theta = rad2deg(0:pi/500:2*pi);% calculating the arc of the circular segment
    x = w/2 * cosd(theta) + xycenter(1); % Define x using "Degrees" version of sin and cos.
    y = h/2 * sind(theta) + xycenter(2); % Define y using "Degrees" version of sin and cos.  
elseif shapeID == 'S'    % square
    x = [xycenter(1) - (w/2), xycenter(1) - (w/2), xycenter(1) + (w/2), xycenter(1) + (w/2)];
    y = [xycenter(2) - (h/2), xycenter(2) + (h/2), xycenter(2) + (h/2), xycenter(2) - (h/2)];
end

if exist('plotting','var') && plotting == 'y'
    if ~exist('facecolor','var')
        facecolor = 'k'; edgecolor = 'none'; facealpha = 0.3; edgethickness = 1;
    elseif ~exist('edgethickness','var')
        edgethickness = 1;
    end
patch(x, y,'k','FaceColor',facecolor,'EdgeColor',edgecolor, 'FaceAlpha',facealpha,'LineWidth',edgethickness);
end