function [missedFrms,whiteCt] = presentGeneralStimulusUDP(stimTrigStruct)
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
    
     if isfield(stimTrigStruct,'imgWalltex')
        imgWalltex = stimTrigStruct.imgWalltex;
        Wallwarpimage = stimTrigStruct.Wallwarpimage;
        WallwarpDest = stimTrigStruct.WallwarpDest;
        Wallwarpmap = stimTrigStruct.Wallwarpmap;
        Wallwarpoperator = stimTrigStruct.Wallwarpoperator;
     end
    
    frmCt = numel(imgtex);
    missedFrms = zeros(frmCt,1);
    
    priority_level = MaxPriority(win);
    oldPriority = Priority(priority_level);
    
    eleDelta = -(stimTrigStruct.eleVal-90)*(pi/180);
    aziDelta = -(stimTrigStruct.aziVal+180)*(pi/180);
    [xS,yS,zS] = sph2cart(stimTrigStruct.aziSmall-aziDelta,stimTrigStruct.eleSmall,1);
    % elevation is rotation about the y-axis
    xT = xS.*cos(eleDelta)-zS.*sin(eleDelta);
    yT = yS;
    zT = xS.*sin(eleDelta)+zS.*cos(eleDelta);
    [stimXazi,stimYele] = cart2sph(xT,yT,zT);%left for stimuli other than plain circle
    stimYele = stimYele./(pi/2).*(stimTrigStruct.eleScale/2);
    stimXazi = stimXazi./(pi).*(stimTrigStruct.aziScale/2);
    
    % Compute a texture that contains the distortion vectors:
    % Red channel encodes x offset components, Green encodes y offsets:
    warpimage(:,:,1) = fliplr(stimXazi+stimTrigStruct.aziOff);
    warpimage(:,:,2) = fliplr(stimYele+stimTrigStruct.eleOff);
    
    % Flag set to '1' yields a floating point texture to allow fractional
    % offsets that are bigger than 1.0 and/or negative:
    modtex = Screen('MakeTexture', win, warpimage,[],[],1);
    % Update the warpmap. First clear it out to zero offset, then draw:
    Screen('FillRect',warpmap,0);
    Screen('DrawTexture',warpmap,modtex,[],warpDest);
    warpedtex = [];
   
    
    if isfield(stimTrigStruct,'imgWalltex')
        WalleleDelta = -(pi/180);
        WallaziDelta = -pi;
        [WallxS,WallyS,WallzS] = sph2cart(stimTrigStruct.aziSmall-WallaziDelta,stimTrigStruct.eleSmall,1);
        WallxT = WallxS.*cos(WalleleDelta)-WallzS.*sin(WalleleDelta);
        WallyT = WallyS;
        WallzT = WallxS.*sin(WalleleDelta)+WallzS.*cos(WalleleDelta);
        [WallstimXazi,WallstimYele] = cart2sph(WallxT,WallyT,WallzT);
        WallstimYele = WallstimYele./(pi/2).*(stimTrigStruct.eleScale/2);
        WallstimXazi = WallstimXazi./(pi).*(stimTrigStruct.aziScale/2);
        
        Wallwarpimage(:,:,1) = fliplr(WallstimXazi+stimTrigStruct.aziOff);
        Wallwarpimage(:,:,2) = fliplr(WallstimYele+stimTrigStruct.eleOff);
        
        Wallmodtex = Screen('MakeTexture', win, Wallwarpimage,[],[],1);
        
        Screen('FillRect',Wallwarpmap,0);
        Screen('DrawTexture',Wallwarpmap,Wallmodtex,[],WallwarpDest);
        warpedWalltex = [];
    end
    
    
    Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); %Sets up ability to have transparency in drawn textures
    
    % Present a single flip in preparation for visual stimulus
    % Apply image warpmap to image:
    warpedtex = Screen('TransformTexture',imgtexReset,warpoperator,warpmap,warpedtex);
    % Draw and show the warped image:
    Screen('DrawTexture',win,warpedtex,[],drawDest);
    if isfield(stimTrigStruct,'imgWalltex')
        warpedWalltex = Screen('TransformTexture',imgWalltex{1},Wallwarpoperator,Wallwarpmap,warpedWalltex);
        Screen('DrawTexture',win,warpedWalltex,[],drawDest);
    end
    Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
    Screen('Flip',win);
    
    
    
    % Visual stimulus presentation
    for iterStim = 1:frmCt
        warpedtex = Screen('TransformTexture',imgtex{iterStim},warpoperator,warpmap,warpedtex);
        Screen('DrawTexture',win,warpedtex,[],drawDest);
        if isfield(stimTrigStruct,'imgWalltex')
            warpedWalltex = Screen('TransformTexture',imgWalltex{iterStim},Wallwarpoperator,Wallwarpmap,warpedWalltex);
            Screen('DrawTexture',win,warpedWalltex,[],drawDest);
        end
            Screen('DrawTexture',win,stimtex{iterStim},[],stimRefROI);
            [~,~,~,missedFrms(iterStim)] = Screen('Flip',win);
    end
    % Hold the final frame for 2 seconds
    warpedtex = Screen('TransformTexture',imgtexFin,warpoperator,warpmap,warpedtex);
    Screen('DrawTexture',win,warpedtex,[],drawDest);
    if isfield(stimTrigStruct,'imgWalltex')
        warpedWalltex = Screen('TransformTexture',imgWalltex{1},Wallwarpoperator,Wallwarpmap,warpedWalltex);
        Screen('DrawTexture',win,warpedWalltex,[],drawDest);
    end
    Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
    Screen('Flip',win);
    pause(2)
    
    % Return to ready state
    warpedtex = Screen('TransformTexture',imgtexReset,warpoperator,warpmap,warpedtex);
    Screen('DrawTexture',win,warpedtex,[],drawDest);
    if isfield(stimTrigStruct,'imgWalltex')
        warpedWalltex = Screen('TransformTexture',imgWalltex{1},Wallwarpoperator,Wallwarpmap,warpedWalltex);
        Screen('DrawTexture',win,warpedWalltex,[],drawDest);
    end
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
