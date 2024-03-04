function [photoData,successBool] = elevationDataAcquisition2servos_v3(eleOps,azimuth,eleReps,minPosnA,maxPosnA)

persistent oldAzi stateRef handleA handleB

if isempty(stateRef)
    loadphidget21;
    stateRef = 'closed';
end

s = daq.createSession('ni');
s.addAnalogInputChannel('Dev1','ai0', 'Voltage');
durL = 0.05;
s.DurationInSeconds = durL;
s.NumberOfScans = 50;
scanL = s.NumberOfScans;


if ~exist('s','var')
    scanL = 1;
end
if nargin == 0
    openOrClose2servos_v1('close')
    photoData = [];
    successBool = [];
    return
    azimuth = 113;
    eleOps = (85:5:195);
    eleReps = 1;
    minPosnA = 85;
    maxPosnA = 195;
    %     degSelections = [90 180 270 360];
    %   36    72   108   144   180   216   252   288   324   360
    %     degSelections = 72;
    %     rad2deg = @(x) x./(pi/180);
    %     aziCount = 10;
    %     aziCpos = linspace(0,2*pi,aziCount+1);
    %     degSelections = rad2deg(aziCpos(2:end));
end


%%%%%%%%%%%%%%%%%%%% TESTING !!!!!!!!!!!
% minPosnB = posOpsB(1);
% posOpsA = posOpsA(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(stateRef,'closed')
    openOrClose2servos_v1('open')
end
try
    
    
    maxVelocity = 6400;%actual maxVelocity 6400
    
    successBool = true;
    
    calllib('phidget21','CPhidgetAdvancedServo_setVelocityLimit',handleB,0,maxVelocity);
    calllib('phidget21','CPhidgetAdvancedServo_setPosition',handleB,0,azimuth);
    if ~isempty(oldAzi)
        if oldAzi ~= azimuth
            pause(5)
        end
    end
    hWaitP = waitbar(0,'Moving servo, collecting data...',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(hWaitP,'canceling',0)
    
    
    for iterI = 1:eleReps
        calllib('phidget21','CPhidgetAdvancedServo_setVelocityLimit',handleA,0,maxVelocity);
        calllib('phidget21','CPhidgetAdvancedServo_setPosition',handleA,0,eleOps(1));
        pause(1)
        scanCount = numel(eleOps);
        photoData = zeros(scanL,scanCount);
        for iterP = 1:scanCount
            waitbar(iterP/(scanCount*eleReps)+(iterI-1)/eleReps,hWaitP)
            pos = eleOps(iterP);
            calllib('phidget21','CPhidgetAdvancedServo_setPosition',handleA,0,pos);
            pause(0.05)
            if exist('s','var')
                data = s.startForeground();
            else
                data = 0;
            end
            photoData(:,iterP) = data(:);
            if getappdata(hWaitP,'canceling')
                successBool = false;
                break
            end
        end
        calllib('phidget21','CPhidgetAdvancedServo_setVelocityLimit',handleA,0,500);
        calllib('phidget21','CPhidgetAdvancedServo_setPosition',handleA,0,maxPosnA);
        pause(1)
        if getappdata(hWaitP,'canceling')
            successBool = false;
            break
        end
    end
    delete(hWaitP)
    
    calllib('phidget21','CPhidgetAdvancedServo_setVelocityLimit',handleB,0,500);
    %     calllib('phidget21','CPhidgetAdvancedServo_setPosition',handleB,0,minPosnB);
    %     pause(5)
    
    
    oldAzi = azimuth;
catch ME
    successBool = false;
    getReport(ME)
    openOrClose2servos_v1('close')
end


    function openOrClose2servos_v1(commandVar)
        try
            if strcmp(commandVar,'open')
                if strcmp(stateRef,'closed')
                    maxAccel = 2000;%actual maxAccel 320000, usual 2000
                    minPosnB = 112;
                    maxPosnB = 135;
                    
                    
                    
                    handleA = libpointer('int32Ptr');
                    handleB = libpointer('int32Ptr');
                    calllib('phidget21', 'CPhidgetAdvancedServo_create', handleA);
                    calllib('phidget21', 'CPhidgetAdvancedServo_create', handleB);
                    calllib('phidget21', 'CPhidget_open', handleA, 119165);%elevation motor
                    calllib('phidget21', 'CPhidget_open', handleB, 119168);%azimuth motor
                    
                    
                    
                    if calllib('phidget21', 'CPhidget_waitForAttachment', handleA, 2500) == 0
                        disp('Opened Advanced Servo A')
                        if calllib('phidget21', 'CPhidget_waitForAttachment', handleB, 2500) == 0
                            disp('Opened Advanced Servo B')
                            calllib('phidget21','CPhidgetAdvancedServo_setAcceleration',handleA,0,maxAccel);
                            calllib('phidget21','CPhidgetAdvancedServo_setPositionMax',handleA,0,maxPosnA);
                            calllib('phidget21','CPhidgetAdvancedServo_setPositionMin',handleA,0,minPosnA);
                            calllib('phidget21','CPhidgetAdvancedServo_setEngaged',handleA,0,1);
                            calllib('phidget21','CPhidgetAdvancedServo_setAcceleration',handleB,0,maxAccel);
                            calllib('phidget21','CPhidgetAdvancedServo_setPositionMax',handleB,0,maxPosnB);
                            calllib('phidget21','CPhidgetAdvancedServo_setPositionMin',handleB,0,minPosnB);
                            calllib('phidget21','CPhidgetAdvancedServo_setEngaged',handleB,0,1);
                        else
                            disp('Could not open advanced servo B')
                        end
                    else
                        disp('Could not open advanced servo A')
                    end
                end
                stateRef = 'open';
            else
                if strcmp(stateRef,'open')
                    closeServos
                end
                stateRef = 'closed';
            end
            
        catch ME
            getReport(ME)
            closeServos
            stateRef = 'closed';
        end
        function closeServos
            disp('Closing servo')
            calllib('phidget21','CPhidgetAdvancedServo_setEngaged',handleA,0,0);
            calllib('phidget21','CPhidgetAdvancedServo_setEngaged',handleB,0,0);
            calllib('phidget21', 'CPhidget_close', handleA);
            calllib('phidget21', 'CPhidget_delete', handleA);
            calllib('phidget21', 'CPhidget_close', handleB);
            calllib('phidget21', 'CPhidget_delete', handleB);
        end
    end
end