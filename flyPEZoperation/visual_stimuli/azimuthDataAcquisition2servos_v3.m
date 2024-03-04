function [photoDataCell,posOpsB,successBool] = azimuthDataAcquisition2servos_v3
s = daq.createSession('ni');
s.addAnalogInputChannel('Dev1','ai0', 'Voltage');
durL = 0.05;
s.DurationInSeconds = durL;
s.NumberOfScans = 50;
scanL = s.NumberOfScans;



if ~exist('s','var')
    scanL = 1;
end
minPosnA = 100;
maxPosnA = 195;%must be the zenith!
posA = (maxPosnA-minPosnA)*(.4)+minPosnA;

aziReps = 1;

minPosnB = 112;
maxPosnB = 135;
posOpsB = linspace(minPosnB,maxPosnB,360);


%%%%%%%%%%%%%%%%%%%% TESTING !!!!!!!!!!!
% minPosnB = posOpsB(1);
% posOpsA = posOpsA(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


aziCt = numel(posOpsB);
loadphidget21;

handleA = libpointer('int32Ptr');
handleB = libpointer('int32Ptr');
calllib('phidget21', 'CPhidgetAdvancedServo_create', handleA);
calllib('phidget21', 'CPhidgetAdvancedServo_create', handleB);
try
    calllib('phidget21', 'CPhidget_open', handleA, 119165);%elevation motor
    calllib('phidget21', 'CPhidget_open', handleB, 119168);%azimuth motor
    
    if calllib('phidget21', 'CPhidget_waitForAttachment', handleA, 2500) == 0
        disp('Opened Advanced Servo A')
        if calllib('phidget21', 'CPhidget_waitForAttachment', handleB, 2500) == 0
            disp('Opened Advanced Servo B')
            maxVelocity = 6400;%actual maxVelocity 6400
            maxAccel = 2000;%actual maxAccel 320000, usual 2000
            
            calllib('phidget21','CPhidgetAdvancedServo_setAcceleration',handleA,0,maxAccel);
            calllib('phidget21','CPhidgetAdvancedServo_setPositionMax',handleA,0,maxPosnA);
            calllib('phidget21','CPhidgetAdvancedServo_setPositionMin',handleA,0,minPosnA);
            calllib('phidget21','CPhidgetAdvancedServo_setEngaged',handleA,0,1);
            calllib('phidget21','CPhidgetAdvancedServo_setAcceleration',handleB,0,maxAccel);
            calllib('phidget21','CPhidgetAdvancedServo_setPositionMax',handleB,0,maxPosnB);
            calllib('phidget21','CPhidgetAdvancedServo_setPositionMin',handleB,0,minPosnB);
            calllib('phidget21','CPhidgetAdvancedServo_setEngaged',handleB,0,1);
            
            successBool = true;
            hWaitI = waitbar(0,'Replicate scans',...
                'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
            setappdata(hWaitI,'canceling',0)
            posWait = get(hWaitI,'position');
            posWait(2) = posWait(2)-150;
            set(hWaitI,'position',posWait)
            
            photoDataCell = cell(aziReps,1);
            
            calllib('phidget21','CPhidgetAdvancedServo_setVelocityLimit',handleB,0,maxVelocity);
            calllib('phidget21','CPhidgetAdvancedServo_setPosition',handleB,0,minPosnB);
            pause(5)
            calllib('phidget21','CPhidgetAdvancedServo_setVelocityLimit',handleA,0,maxVelocity);
            calllib('phidget21','CPhidgetAdvancedServo_setPosition',handleA,0,posA);
            pause(1)
            for iterI = 1:aziReps
                scanCount = numel(posOpsB);
                photoData = zeros(scanL,scanCount);
                for iterP = 1:scanCount
                    waitbar(iterP/aziCt/aziReps+((iterI-1)/aziReps),hWaitI)
                    
                    pos = posOpsB(iterP);
                    calllib('phidget21','CPhidgetAdvancedServo_setPosition',handleB,0,pos-1);
                    pause(1)
                    calllib('phidget21','CPhidgetAdvancedServo_setPosition',handleB,0,pos);
                    pause(2)
                    if exist('s','var')
                        data = s.startForeground();
                    else
                        data = 0;
                    end
                    if getappdata(hWaitI,'canceling')
                        successBool = false;
                        break
                    end
                    photoData(:,iterP) = data(:);
                end
                calllib('phidget21','CPhidgetAdvancedServo_setPosition',handleB,0,minPosnB);
                pause(6)
                if getappdata(hWaitI,'canceling')
                    successBool = false;
                    break
                end
                
                photoDataCell{iterI} = photoData;
            end
            calllib('phidget21','CPhidgetAdvancedServo_setVelocityLimit',handleA,0,500);
            calllib('phidget21','CPhidgetAdvancedServo_setPosition',handleA,0,maxPosnA);
                
            calllib('phidget21','CPhidgetAdvancedServo_setVelocityLimit',handleB,0,500);
            calllib('phidget21','CPhidgetAdvancedServo_setPosition',handleB,0,minPosnB);
            pause(5)
            delete(hWaitI)
            calllib('phidget21','CPhidgetAdvancedServo_setEngaged',handleB,0,0);
        else
            disp('Could not open advanced servo B')
        end
    else
        disp('Could not open advanced servo A')
    end
    disp('Closing servos')
    calllib('phidget21', 'CPhidget_close', handleA);
    calllib('phidget21', 'CPhidget_delete', handleA);
    calllib('phidget21', 'CPhidget_close', handleB);
    calllib('phidget21', 'CPhidget_delete', handleB);
catch ME
    successBool = false;
    getReport(ME)
    disp('Closing servo')
    calllib('phidget21', 'CPhidget_close', handleA);
    calllib('phidget21', 'CPhidget_delete', handleA);
    calllib('phidget21', 'CPhidget_close', handleB);
    calllib('phidget21', 'CPhidget_delete', handleB);
end
set(0,'ShowHiddenHandles','on')
delete(get(0,'Children'))
set(0,'ShowHiddenHandles','off')