function [missedFrms] = presentDiodeTest(stimTrigStruct,nDeviceNo)
%presentDiskStimulus Receives previously initialized variables in struct
%and quickly presents the visual stimulus

drawDest = stimTrigStruct.drawDest;
warpimage = stimTrigStruct.warpimage;
stimThetaRefs = stimTrigStruct.stimThetaRefs;
warpDest = stimTrigStruct.warpDest;
win = stimTrigStruct.win;
warpmap = stimTrigStruct.warpmap;
warpoperator = stimTrigStruct.warpoperator;
imgCell = stimTrigStruct.imgCell;
stimRefROI = stimTrigStruct.stimRefROI;

eleDelta = -(stimTrigStruct.eleVal-90)*(pi/180);
aziDelta = (stimTrigStruct.aziVal)*(pi/180);
[xS,yS,zS] = sph2cart(stimTrigStruct.aziSmall-aziDelta,...
    stimTrigStruct.eleSmall,1);
% elevation is rotation about the y-axis
xT = xS.*cos(eleDelta)-zS.*sin(eleDelta);
yT = yS;
zT = xS.*sin(eleDelta)+zS.*cos(eleDelta);
% [stimXazi,stimYele] = cart2sph(xT,yT,zT);%left for stimuli other than plain circle
stimYele = atan2(zT,sqrt(xT.^2+yT.^2));
stimYele = stimYele./(pi/2).*stimTrigStruct.scaleVal;

% plot(stimXazi(:),stimYele(:),'.')



% Compute a texture that contains the distortion vectors:
% Red channel encodes x offset components, Green encodes y offsets:
warpimage(:,:,2) = stimYele+stimTrigStruct.eleOff;
stimRefImageWA = uint8(cat(3,zeros(5)+255,zeros(5)+255,zeros(5)+255));
stimRefImageWB = uint8(cat(3,zeros(5)+255,zeros(5)+10,zeros(5)+10));
stimRefImCell = {stimRefImageWA,stimRefImageWB};
try
%     % Flag set to '1' yields a floating point texture to allow fractional
%     % offsets that are bigger than 1.0 and/or negative:
%     modtex = Screen('MakeTexture', win, warpimage,[],[],1);
%     % Update the warpmap. First clear it out to zero offset, then draw:
%     Screen('FillRect',warpmap,0);
%     Screen('DrawTexture',warpmap,modtex,[],warpDest);
    
    warpedtex = [];
    frmCt = size(stimThetaRefs,2);
%     vbl = zeros(frmCt+1,1);
    missedFrms = zeros(frmCt,1);
    ifi = stimTrigStruct.ifi;
    
%     waitdur = stimTrigStruct.ifi/2;
    stimRefRefs = repmat([1 2]',ceil(frmCt/2),1);
    stimRefRefs = stimRefRefs(:);
    imgtex = cell(frmCt,1);
    stimtex = cell(frmCt,1);
    for iterPrep = 1:frmCt
%         imgCat = cat(3,imgCell{stimThetaRefs(1,iterPrep)},...
%             imgCell{stimThetaRefs(2,iterPrep)},imgCell{stimThetaRefs(3,iterPrep)});
%         imgtex{iterPrep} = Screen('MakeTexture',win,imgCat);
        stimIm = stimRefImCell{stimRefRefs(iterPrep)};
        stimtex{iterPrep} = Screen('MakeTexture',win,stimIm);
    end
%     imgReset = cat(3,imgCell{1},imgCell{1},imgCell{1});
%     imgtexReset = Screen('MakeTexture',win,imgReset);
%     imgCat = cat(3,imgCell{stimThetaRefs(3,iterPrep)},...
%         imgCell{stimThetaRefs(3,iterPrep)},imgCell{stimThetaRefs(3,iterPrep)});
%     imgtexFin = Screen('MakeTexture',win,imgCat);
    stimRefImageB = uint8(cat(3,zeros(3),zeros(3),zeros(3)));
    stimRefTexB = Screen('MakeTexture',win,stimRefImageB);

    priority_level = MaxPriority(win);
    oldPriority = Priority(priority_level);
    if ~isempty(nDeviceNo)
        [~,~] = PDC_TriggerIn(nDeviceNo);
    end
    
%     % Apply image warpmap to image:
%     warpedtex = Screen('TransformTexture',imgtexReset,warpoperator,warpmap,warpedtex);
%     % Draw and show the warped image:
%     Screen('DrawTexture',win,warpedtex,[],drawDest);
    Screen('DrawTexture',win,stimRefTexB,[],drawDest);
    Screen('Flip',win);
    
    for iterStim = 1%:frmCt
%         % Apply image warpmap to image:
%         warpedtex = Screen('TransformTexture',imgtex{iterStim},warpoperator,warpmap,warpedtex);
%         % Draw and show the warped image:
%         Screen('DrawTexture',win,warpedtex,[],drawDest);
        Screen('DrawTexture',win,stimtex{iterStim},[],drawDest);
        [~,~,~,missedFrms(iterStim)] = Screen('Flip',win);
    end
%     warpedtex = Screen('TransformTexture',imgtexFin,warpoperator,warpmap,warpedtex);
%     Screen('DrawTexture',win,warpedtex,[],drawDest);
    Screen('DrawTexture',win,stimRefTexB,[],drawDest);
    Screen('Flip',win);
%     missedFrms = sum(diff(vbl) > stimTrigStruct.ifi);
    missedFrms = sum(missedFrms > 0);
    
%     pause(2)
%     % Apply image warpmap to image:
%     warpedtex = Screen('TransformTexture',imgtexReset,warpoperator,warpmap,warpedtex);
%     % Draw and show the warped image:
%     Screen('DrawTexture',win,warpedtex,[],drawDest);
%     Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
%     Screen('Flip',win);
    
    Screen('Close');
    Priority(oldPriority);
    
catch
    Screen('CloseAll');
    Priority(oldPriority);
    psychrethrow(psychlasterror);
end

end

