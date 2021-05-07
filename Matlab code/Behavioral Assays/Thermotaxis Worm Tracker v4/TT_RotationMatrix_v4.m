function [CLCamNorm,CRrot_scaled] = TT_RotationMatrix_v4(Xvals, Yvals, numworms)
%% TT_RotationMatrix_v4 establishes a cartesian coordinate system, and rotates the points in the
%   plane around the origin.
%
%   [normCL,CRrot_scaled] = TT_RotationMatrix_v4(Cm_CR, Cm_CL, numworms)
%   Rotation of CR coordinate plane to match CL coordinate plane.
%
%	A rotation matrix is used to perform a rotation in Euclidean space. 
%   When rotating (x, y) by alpha degrees:
%       x' = x cos alpha - y sin alpha
%       y' = x sin alpha + y cos alpha
%
%   As a matrix:
%       (x',y') = (x,y) * [cos alpha, -sin alpha; sin alpha, cos alpha]
%
% INPUTS:
%   Xvals, Yvals: x and y track coordinates that need to be rotated, 
%   numworms: number of worms
%
% OUTPUTS:
%   CRrot_scaled: CamR X/Y values, rotated and scaled and normalized to
%   alignment position 1
%   normCL: CamL X/Y values, normalized to alignment position 1
%
%   Version Number: 4.1
%   Version Date: 2/20/20
%
%% Revision History
%   2/13/20 Created by Astra S. Bryant
%   2/20/20 Moved repository of alignment coordinates to TT_AssayParams b/c
%   that's where I kept looking for them. ASB

global CL_ac
global CR_ac
global Landmark

% Quality check for alignment
if isempty(CL_ac)
    error ('Camera Alignment Values were not successfully loaded. Please check the Index tab.')
end

%% Pre-processing variables
% Normalize the X2/Y2 coordinates relative to the X1/Y1 values of each
% camera
rel_CLac = CL_ac(:,:,2) - CL_ac (:,:,1);
rel_CRac = CR_ac(:,:,2) - CR_ac (:,:,1);

% Normalize worm tracks on each camera relative to the X1/Y1 values for
% each camera. 
CLCamNorm.xvals = Xvals.Cm_CL - CL_ac (:,1,1)';
CLCamNorm.yvals = Yvals.Cm_CL - CL_ac (:,2,1)';
CRCamNorm.xvals = Xvals.Cm_CR - CR_ac (:,1,1)';
CRCamNorm.yvals = Yvals.Cm_CR - CR_ac (:,2,1)';

% Normalize Landmark locations relative to the X1/Y1 values of each camera
if Landmark.Cam{1} == 'L'
    normLandmarks(:,1) = Landmark.X' - CL_ac(:,1,1);
    normLandmarks(:,2) = Landmark.Y' - CL_ac(:,2,1);
elseif Landmark.Cam{1} == 'R'
    normLandmarks(:,1) = Landmark.X' - CR_ac(:,1,1);
    normLandmarks(:,2) = Landmark.Y' - CR_ac(:,2,1);
end

%% Step 1: Calculate rotation angle 
% Determine the angle (in degrees) that Ref1 (the origin) is offset from Ref2, for each camera
ang.CL = atan2(rel_CLac(:,1),rel_CLac(:,2)) * (180/pi); %to convert this to radians: angle * (pi/180)
ang.CR = atan2(rel_CRac(:,1),rel_CRac(:,2)) * (180/pi); %to convert this to radians: angle * (pi/180)

% Determine how many degrees you'd have to shift the CR angle to get it to be the same as the CL angle.
% Here, we are going to assume that you want to shift the right camera
% values to match the angle of the left camera values. As of 2/18/20, this
% is a pretty valid assumption. If this stops being true, either make it
% true again (easier) or have the "true reference" camera be an inputted
% variable (harder, annoying, doable).
ang.adj = ang.CL - ang.CR;

% Convert the adjustment angle of CR into radians
alpha = ang.adj * (pi/180);
s = sin (-alpha);
c = cos (-alpha);


%% Step 2: Apply the rotation matrix to worm tracks for CR camera 
% these tracks should be normalized to the X1/Y1 location on CR
Xrot = NaN(size(CRCamNorm.xvals));
Yrot = NaN(size(CRCamNorm.yvals));
CR_ac_rot = NaN(size(rel_CRac));

for i = 1:numworms
    A = [CRCamNorm.xvals(:,i)'; CRCamNorm.yvals(:,i)'];
    B = rel_CRac(i,:)';
    
    R = [c(i), -s(i); s(i), c(i)]; % Rotation Matrix
    Arot = R * A;
    
    % Saving the rotated worm tracks
    Xrot(:,i)=Arot(1,:)';
    Yrot(:,i)=Arot(2,:)';
    
    % Saving the rotated CR alignment locations
    CR_ac_rot(i,:) = (R * B)'; % same orientation as C*_alignment_coords
    
    % If Landmark is on the right camera, also have to rotate that.
    if Landmark.Cam{1} == 'R'
        Landmark.RS(i,:) = (R * normLandmarks(i,:)');
    else
        Landmark.RS(i,:) = normLandmarks(i,:);
    end
end

ang.CRrot=atan2(CR_ac_rot(:,1),CR_ac_rot(:,2)) * (180/pi); % This is really just to double check hat the adjusted angle between the CR locations is now the same as those for the CL locations.

%% Scale CR coordinate plane to match CL coordinate plane
%   This does fine adjustments to make sure that the reference points which
%   are now rotated to match are scaled so they align precisely. 
%   Note: All the values remain  in cm scale.

%   Determine the distance between the reference locations for each camera
displacement_refsCR = sqrt((CR_ac_rot(:,1).^2) + (CR_ac_rot(:,2).^2));
displacement_refsCL = sqrt((rel_CLac(:,1).^2) + (rel_CLac(:,2).^2));

%   Determine the scaling factor: how much bigger/smaller CR displacement
%   (aka hypotenuse separating Ref 1 and Ref 2 on cam R) is than CL.
scaling_refCR = displacement_refsCL./displacement_refsCR; % Size of CL as a function of size of CR - can be used to rescale CR

%   Multiply rotated CR worm tracks  by the scaling reference, to match the CL scale.
CRrot_scaled.xvals = Xrot .* (repmat(scaling_refCR',size(Xvals.Cm_CR,1),1));
CRrot_scaled.yvals = Yrot .* (repmat(scaling_refCR',size(Xvals.Cm_CR,1),1));

%   Also multiply the reference point information for Ref 2 (Ref 1 is still
%   at (0,0).
displacement_refsCRscaled = displacement_refsCR .* scaling_refCR; % These numbers should now equal displacement_refsC values.
CR_ac_rotscaled = CR_ac_rot .* (repmat(scaling_refCR,1,2)); % These numbers should now equal rel_CLac values.

%   And also multiply the landmark location information, if its on the
%   right camera
if Landmark.Cam{1} == 'R'
    Landmark.RS = Landmark.RS .* (repmat(scaling_refCR,1,2));
end

%fdsp(:,5)=sqrt(((fdsp(:,1)-fdsp(:,3)).^2) + ((fdsp(:,2)-(fdsp(:,4))).^2))


end