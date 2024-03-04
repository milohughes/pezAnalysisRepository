function [SG0,SG1,SG2] = golayDifferentiate(posVec,diffWin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% posVec = XYZ_3D_filt(:,1);
% diffWin = 31;

%%% Use diff and smooth to get speed and acceleration
sgolayF = diffWin;
sgolayK = 4;
[~,sG] = sgolay(sgolayK,sgolayF);
HalfWin = ((sgolayF+1)/2)-1;
sgolayY = posVec;
SG0 = zeros(1,numel(sgolayY));
SG1 = SG0;
SG2 = SG1;
for iterN = (HalfWin+1):numel(sgolayY)-(HalfWin+1)
    vecFragA = sgolayY(iterN-HalfWin:iterN+HalfWin);
    % Zero-th derivative (smoothing only)
    SG0(iterN) = dot(sG(:,1),vecFragA);
    % 1st differential
    SG1(iterN) = dot(sG(:,2),vecFragA);
    % 2nd differential
    SG2(iterN) = 2*dot(sG(:,3)',vecFragA);
end
SG0(end-HalfWin:end) = NaN;
SG1(end-HalfWin:end) = NaN;
SG2(end-HalfWin:end) = NaN;
SG0 = SG0';
SG1 = SG1';
SG2 = SG2';
