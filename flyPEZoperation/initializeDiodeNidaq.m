function [sDiode] = initializeDiodeNidaq(device_ID)
%initializeDiodeNidaq Called by pez control to initialize the nidaq
%associated with photodiode data acquisition

sDiode = daq.createSession('ni');
diodeCh = sDiode.addAnalogInputChannel(device_ID,'ai0','Voltage');
diodeCh.InputType = 'SingleEnded';
recCh = sDiode.addAnalogInputChannel(device_ID,'ai15','Voltage');
recCh.InputType = 'SingleEnded';
recChNeg = sDiode.addAnalogInputChannel(device_ID,'ai10','Voltage');
recChNeg.InputType = 'SingleEnded';

%I know this works because when I hook a SYNC_POS channel up to an analog
%input without the clock connection, I record a mix of signal peaks ranging
%from peak to trough.  However, if I only add the clock connection and
%record again, I only observe peaks with nearly zero variance in the analog
%version of the signal.  This required two GEN_OUT lines from the camera
%which were both set to SYNC_POS.  I then reasoned that any additional
%digital lines needing to be recorded from the camera can simply be added
%as analog and will be automatically aligned with the sync signal.  This
%holds true even when the nidaq is set to record at a factor of 10 faster
%than the camera is firing.
sDiode.addClockConnection('External',[device_ID '/PFI2'],'ScanClock');
% digital channels can't be used with any clocked operations
% s.addDigitalChannel('Dev2','Port1/Line0','InputOnly')

end

