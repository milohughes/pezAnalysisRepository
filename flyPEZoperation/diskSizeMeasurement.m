function diskSizeMeasurement(stimTrigStruct)
%presentDiskStimulus Receives previously initialized variables in struct
%and quickly presents the visual stimulus

try
    stimRadiusVector = stimTrigStruct.stimRadiusVector;
    win = stimTrigStruct.win;
    imgCell = stimTrigStruct.imgCell;
    stimThetaRefs = stimTrigStruct.stimThetaRefs;
    stimThetaRefs = stimThetaRefs(:);
    frmCt = numel(stimThetaRefs);
    imgtex = cell(frmCt,1);
    for iterPrep = 1:frmCt
        imgCat = cat(3,imgCell{stimThetaRefs(iterPrep)},...
            imgCell{stimThetaRefs(iterPrep)},imgCell{stimThetaRefs(iterPrep)});
        imgtex{iterPrep} = Screen('MakeTexture',win,imgCat);
    end
    imgtexReset = stimTrigStruct.imgtexReset;
    imgtexFin = stimTrigStruct.imgtexFin;
    stimRefTexB = stimTrigStruct.stimRefTexB;
    
    drawDest = stimTrigStruct.drawDest;
    warpimage = stimTrigStruct.warpimage;
    warpDest = stimTrigStruct.warpDest;
    warpmap = stimTrigStruct.warpmap;
    warpoperator = stimTrigStruct.warpoperator;
    
    winRect = Screen('Rect',win);
    height = winRect(4);
    width = winRect(3);
    hH = round(height/2);
    hW = round(width/2);
    stimRefROI = [hW,hH]-18;
    stimRefROI = [stimRefROI stimRefROI+36];
    stimRefROI(3) = stimRefROI(3)+36;

    frmCt = numel(imgtex);
    
    priority_level = MaxPriority(win);
    oldPriority = Priority(priority_level);
    
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
    
    % Compute a texture that contains the distortion vectors:
    % Red channel encodes x offset components, Green encodes y offsets:
    warpimage(:,:,2) = stimYele+stimTrigStruct.eleOff;
    
    % Flag set to '1' yields a floating point texture to allow fractional
    % offsets that are bigger than 1.0 and/or negative:
    modtex = Screen('MakeTexture', win, warpimage,[],[],1);
    % Update the warpmap. First clear it out to zero offset, then draw:
    Screen('FillRect',warpmap,0);
    Screen('DrawTexture',warpmap,modtex,[],warpDest);
    warpedtex = [];
    
    % Present a single flip in preparation for visual stimulus
    % Apply image warpmap to image:
    warpedtex = Screen('TransformTexture',imgtexReset,warpoperator,warpmap,warpedtex);
    % Draw and show the warped image:
    Screen('DrawTexture',win,warpedtex,[],drawDest);
    Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
    Screen('Flip',win);
    
    % Visual stimulus presentation
    for iterStim = 1:frmCt
        warpedtex = Screen('TransformTexture',imgtex{iterStim},warpoperator,warpmap,warpedtex);
        Screen('DrawTexture',win,warpedtex,[],drawDest);
        Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
        Screen('DrawText',win,num2str(stimRadiusVector(iterStim),'%3.1f'),...
            hW-15,hH-15,uint8([255 255 255]));
        Screen('Flip',win);
        [~,keyCode] = KbWait([],2);
        if find(keyCode) == 27 %pressing 'esc' breaks the loop
            break
        end
    end
    
    % Hold the final frame for 2 seconds
    warpedtex = Screen('TransformTexture',imgtexFin,warpoperator,warpmap,warpedtex);
    Screen('DrawTexture',win,warpedtex,[],drawDest);
    Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
    Screen('Flip',win);
    pause(2)
    
    % Return to ready state
    warpedtex = Screen('TransformTexture',imgtexReset,warpoperator,warpmap,warpedtex);
    Screen('DrawTexture',win,warpedtex,[],drawDest);
    Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
    Screen('Flip',win);
    
    % Close the transformation texture
    Screen('Close',[modtex;warpedtex]);
    Priority(oldPriority);
    
catch ME
    getReport(ME)
    psychrethrow(psychlasterror);
    Screen('CloseAll');
    Priority(oldPriority);
    
end

end

