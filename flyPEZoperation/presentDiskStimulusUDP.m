function [missedFrms,whiteCt] = presentDiskStimulusUDP(stimTrigStruct)
%presentDiskStimulus Receives previously initialized variables in struct
%and quickly presents the visual stimulus

try
    
    whiteCt = stimTrigStruct.whiteCt;
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
    
    frmCt = numel(imgtex);
    missedFrms = zeros(frmCt,1);
    
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
        Screen('DrawTexture',win,stimtex{iterStim},[],stimRefROI);
        [~,~,~,missedFrms(iterStim)] = Screen('Flip',win);
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
    missedFrms = sum(missedFrms > 0);
    
catch ME
    getReport(ME)
    psychrethrow(psychlasterror);
    Screen('CloseAll');
    Priority(oldPriority);
    
end

end

