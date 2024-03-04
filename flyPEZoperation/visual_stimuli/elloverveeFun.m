function [stimThetaRefs,stimTotalDuration] = elloverveeFun(ellovervee)

% L/V is in milliseconds and represents the time it takes for an
% approaching object at a constant velocity to expand in the visual field
% from 90 degrees to 180 degrees.

% ellovervee = 70;
initStimSize = 5;%in degrees
finalStimSize = 90;%in degrees

deg2rad = @(x) x*(pi/180);
rad2deg = @(x) x./(pi/180);

minTheta = deg2rad(initStimSize);
maxTheta = deg2rad(finalStimSize);
stimStartTime = ellovervee/tan(minTheta/2);
stimEndTime = ellovervee/tan(maxTheta/2);
stimTotalDuration = stimStartTime-stimEndTime;
stimTimeStep = (1/360)*1000;%milliseconds per frame channel at 120 Hz
stimTimeVector = fliplr(stimEndTime:stimTimeStep:stimStartTime);
stimThetaVector = 2.*atan(ellovervee./stimTimeVector);
stimFrmCt = numel(stimThetaVector);
stimThetaRemainder = round((ceil(stimFrmCt/3)-stimFrmCt/3)*3);
stimThetaVector = [stimThetaVector,...
    repmat(stimThetaVector(end),[1 stimThetaRemainder])];
stimThetaRefs = reshape(stimThetaVector,3,numel(stimThetaVector)/3);
stimThetaRefs = rad2deg(stimThetaRefs);
% plot(rad2deg(stimThetaVector))
