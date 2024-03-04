function [photoDataCell,successBool,scanL,scanCount] = RyansAdvServoCalibrated(posOps,minPosn,maxPosn,repCt)
s = daq.createSession('ni');
s.addAnalogInputChannel('Dev1','ai0', 'Voltage');
durL = 0.05;
s.DurationInSeconds = durL;
% s.NumberOfScans = 50;
scanL = s.NumberOfScans;
loadphidget21;

handle = libpointer('int32Ptr');
calllib('phidget21', 'CPhidgetAdvancedServo_create', handle);
calllib('phidget21', 'CPhidget_open', handle, -1);

if calllib('phidget21', 'CPhidget_waitForAttachment', handle, 2500) == 0
    disp('Opened Advanced Servo')
    maxVelocity = 6400;%actual maxVelocity 6400
    maxAccel = 2000;%actual maxVelocity 320000
    calllib('phidget21', 'CPhidgetAdvancedServo_setAcceleration', handle, 0, maxAccel);
    calllib('phidget21', 'CPhidgetAdvancedServo_setPositionMax', handle, 0, maxPosn);
    calllib('phidget21', 'CPhidgetAdvancedServo_setPositionMin', handle, 0, minPosn);
    calllib('phidget21', 'CPhidgetAdvancedServo_setEngaged', handle, 0, 1);
    
    photoDataCell = cell(repCt,1);
    successBool = true;
    hWaitI = waitbar(0,'Replicate scans',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(hWaitI,'canceling',0)
    posWait = get(hWaitI,'position');
    posWait(2) = posWait(2)-150;
    set(hWaitI,'position',posWait)
    for iterI = 1:repCt
        waitbar(iterI/repCt,hWaitI)
        calllib('phidget21', 'CPhidgetAdvancedServo_setVelocityLimit', handle, 0, maxVelocity);
        calllib('phidget21', 'CPhidgetAdvancedServo_setPosition', handle, 0, posOps(1));
        pause(1)
        scanCount = numel(posOps);
        photoData = zeros(scanL,scanCount);
        hWaitP = waitbar(0,'Moving servo, collecting data...',...
            'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
        setappdata(hWaitP,'canceling',0)
        for iterP = 1:scanCount
            waitbar(iterP/scanCount,hWaitP)
            pos = posOps(iterP);
            calllib('phidget21', 'CPhidgetAdvancedServo_setPosition', handle, 0, pos);
            pause(0.05)
            data = s.startForeground();
            photoData(:,iterP) = data(:);
            if getappdata(hWaitP,'canceling')
                successBool = false;
                break
            end
        end
        delete(hWaitP)
        calllib('phidget21', 'CPhidgetAdvancedServo_setVelocityLimit', handle, 0, 500);
        calllib('phidget21', 'CPhidgetAdvancedServo_setPosition', handle, 0, posOps(1));
        pause(1)
        if getappdata(hWaitI,'canceling')
            successBool = false;
            break
        end
        photoDataCell{iterI} = photoData;
    end
    delete(hWaitI)
    calllib('phidget21', 'CPhidgetAdvancedServo_setEngaged', handle, 0, 0);
else
    disp('Could not open advanced servo')
end
disp('Closing servo')
calllib('phidget21', 'CPhidget_close', handle);
calllib('phidget21', 'CPhidget_delete', handle);

% set(0,'ShowHiddenHandles','on')
% delete(get(0,'Children'))