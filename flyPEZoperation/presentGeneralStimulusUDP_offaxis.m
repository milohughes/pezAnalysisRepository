function [stimTrigStruct2] = presentGeneralStimulusUDP_offaxis(stimTrigStruct)
%presentDiskStimulus Receives previously initialized variables in struct
%and quickly presents the visual stimulus
imgtex = stimTrigStruct.imgtex;
stimtex = stimTrigStruct.stimtex;
imgtexReset = stimTrigStruct.imgtexReset;
imgtexFin = stimTrigStruct.imgtexFin;
stimRefTexB = stimTrigStruct.stimRefTexB;

drawDest = stimTrigStruct.drawDest;
warpimage = stimTrigStruct.warpimage;
warpDest = stimTrigStruct.warpDest;
win = stimTrigStruct.win;
warpmap = stimTrigStruct.warpmap;
warpoperator = stimTrigStruct.warpoperator;
stimRefROI = stimTrigStruct.stimRefROI;

flipRefVec = stimTrigStruct.flipReference;
frmCt = numel(flipRefVec);

% Rotation calculation
eleDelta = ((stimTrigStruct.stimEle)-90)*(pi/180);
aziDelta = -repmat((180)*(pi/180),[size(stimTrigStruct.aziSmall,1) size(stimTrigStruct.aziSmall,2) length(stimTrigStruct.stimAzi)]);
[xS,yS,zS] = sph2cart(stimTrigStruct.aziSmall-aziDelta,repmat(stimTrigStruct.eleSmall,[1 1 size(aziDelta,3)]),1);
% elevation is rotation about the y-axis
eleDelta = repmat(shiftdata(eleDelta,3),[size(stimTrigStruct.aziSmall,1) size(stimTrigStruct.aziSmall,2) 1]);
xT = xS.*cos(eleDelta)-zS.*sin(eleDelta);
yT = yS;
zT = xS.*sin(eleDelta)+zS.*cos(eleDelta);
[stimXazi,stimYele] = cart2sph(xT,yT,zT);%left for stimuli other than plain circle
stimYele = stimYele./(pi/2).*(stimTrigStruct.eleScale/2);
stimXazi = stimXazi./(pi).*(stimTrigStruct.aziScale/2);

%Prepare first warp
% Compute a texture that contains the distortion vectors:
% Red channel encodes x offset components, Green encodes y offsets:
warpimage(:,:,1) = fliplr(stimXazi(:,:,1)+stimTrigStruct.aziOff);
warpimage(:,:,2) = fliplr(stimYele(:,:,1)+stimTrigStruct.eleOff);


% Flag set to '1' yields a floating point texture to allow fractional
% offsets that are bigger than 1.0 and/or negative:
modtex = Screen('MakeTexture', win, warpimage,[],[],1);
% Update the warpmap. First clear it out to zero offset, then draw:
Screen('FillRect',warpmap,0);
Screen('DrawTexture',warpmap,modtex,[],warpDest);

warpedtex = [];

for i = 1:frmCt
    % Compute a texture that contains the distortion vectors:
    % Red channel encodes x offset components, Green encodes y offsets:
    warpimage(:,:,1) = fliplr(stimXazi(:,:,i)+stimTrigStruct.aziOff);
    warpimage(:,:,2) = fliplr(stimYele(:,:,i)+stimTrigStruct.eleOff);
    
    % Flag set to '1' yields a floating point texture to allow fractional
    % offsets that are bigger than 1.0 and/or negative:
    modtex(i) = Screen('MakeTexture', win, warpimage,[],[],1);
end

stimTrigStruct2 = struct('imgtexReset',imgtexReset,'warpoperator',warpoperator,'warpmap',warpmap,'warpedtex',warpedtex,...
    'win',win,'drawDest',drawDest,'stimRefTexB',stimRefTexB,'stimRefROI',stimRefROI,'frmCt',frmCt,'stimXazi',stimXazi,...
    'aziOff',stimTrigStruct.aziOff,'stimYele',stimYele,'eleOff',stimTrigStruct.eleOff,'warpDest',warpDest,...
    'imgtexFin',imgtexFin,'whiteCt',stimTrigStruct.whiteCt,'flipRefVec',flipRefVec,'warpimage',warpimage);
stimTrigStruct2(1).imgtex = imgtex;
stimTrigStruct2(1).stimtex = stimtex;
stimTrigStruct2(1).modtex = modtex;
end