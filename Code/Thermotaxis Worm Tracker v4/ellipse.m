function[] = ellipse (xycenter, hr, vr, facecolor, edgecolor, edgethickness)
%% Function Description
%   circle (xycenter, hr, vr, facecolor, edgecolor, edgethickness)
%
%   Draws an ellipse horizontal radius 'hr' and vertical radius 'vr' centered around a given x,y coordinate.
%   
% Inputs:
%   hr = horiztonal radius
%   vr = verticle radius
%   xycenter = 1x2 array containing x,y coordinates of the center of the
%   ellipse
%   facecolor =  array defining fill color
%   edgecolor =  array defining edge color
%   edgethickness = thickeness of edge line
%
%% Revision History
%   2-20-20 created by ASB

%% Code
if ~exist('edgethickness')
    edgethickness = 1;
end

theta = rad2deg(0:pi/500:2*pi);%linspace(0,360, 100); % calculating the arc of the circular segment
% Define x and y using "Degrees" version of sin and cos.
x = hr * cosd(theta) + xycenter(1); 
y = vr * sind(theta) + xycenter(2); 
patch(x, y,'k','FaceColor',facecolor,'EdgeColor',edgecolor, 'LineWidth',edgethickness);