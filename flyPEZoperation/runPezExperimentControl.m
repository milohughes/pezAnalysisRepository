function runPezExperimentControl
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

addpath(mfilename('fullpath'))

PDC = runSetPDCvalues;
CAM = runOpenCamera(PDC);
GUI = runPezMasterGUI(CAM,PDC);


end

