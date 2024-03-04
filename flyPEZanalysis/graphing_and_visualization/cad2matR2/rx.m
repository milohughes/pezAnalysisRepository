function Rx = rx(THETA)
% ROTATION ABOUT THE X-AXIS
%
% Rx = rx(THETA)
%
% This is the homogeneous transformation for
% rotation about the X-axis.
%
%	    NOTE:  The angle THETA must be in DEGREES.
%
THETA = THETA*pi/180;  % Note: THETA in radians.
c = cos(THETA);
s = sin(THETA);
Rx = [1 0 0 0; 0 c -s 0; 0 s c 0; 0 0 0 1];
