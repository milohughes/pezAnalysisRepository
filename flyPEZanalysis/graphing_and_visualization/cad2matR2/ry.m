function Ry = ry(THETA)
% ROTATION ABOUT THE Y-AXIS
%
% Ry = ry(THETA)
%
% This is the homogeneous transformation for
% rotation about the Y-axis.
%
%		NOTE: The angel THETA must be in DEGREES.
%
THETA = THETA*pi/180;  %Note: THETA is in radians.
c = cos(THETA);
s = sin(THETA);
Ry = [c 0 s 0; 0 1 0 0; -s 0 c 0; 0 0 0 1];
