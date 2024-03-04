function [missedFrms,whiteCt] = presentGeneralStimulusUDP_flipRef(stimTrigStruct)
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
    
    
    if isfield(stimTrigStruct, 'imgtex2')
        imgtex2 = stimTrigStruct.imgtex2;
        stimtex2 = stimTrigStruct.stimtex2;
        warpimage2 = stimTrigStruct.warpimage2;
        warpDest2 = stimTrigStruct.warpDest2;
        warpmap2 = stimTrigStruct.warpmap2;
        warpoperator2 = stimTrigStruct.warpoperator2;
        imgtexReset2 = stimTrigStruct.imgtexReset2;
        imgtexFin2 = stimTrigStruct.imgtexFin2;
        drawDest2 = stimTrigStruct.drawDest2;
        flipRefVec2 = stimTrigStruct.flipReference2;
        frmCt2 = numel(flipRefVec2);
    end
    
    
    
    if isfield(stimTrigStruct,'imgWalltex')
        imgWalltex = stimTrigStruct.imgWalltex;
        Wallwarpimage = stimTrigStruct.Wallwarpimage;
        WallwarpDest = stimTrigStruct.WallwarpDest;
        Wallwarpmap = stimTrigStruct.Wallwarpmap;
        Wallwarpoperator = stimTrigStruct.Wallwarpoperator;
        
        if isfield(stimTrigStruct,'wallframes')
            wallframes = stimTrigStruct.wallframes;
        end
    end
    
    flipRefVec = stimTrigStruct.flipReference;
    if isfield(stimTrigStruct,'imgWalltex') && numel(imgWalltex)~= numel(imgtex)
        frmCt = numel(imgWalltex)+numel(flipRefVec);
    else
        frmCt = numel(flipRefVec);
    end
    
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
    
    if isfield(stimTrigStruct, 'imgtex2')
        eleDelta2 = -(stimTrigStruct.eleVal2-90)*(pi/180);
        aziDelta2 = -(stimTrigStruct.aziVal2+180)*(pi/180);
        [xS2,yS2,zS2] = sph2cart(stimTrigStruct.aziSmall-aziDelta2,stimTrigStruct.eleSmall,1);
        
        xT2 = xS2.*cos(eleDelta2)-zS2.*sin(eleDelta2);
        yT2 = yS2;
        zT2 = xS2.*sin(eleDelta2)+zS2.*cos(eleDelta2);
        [stimXazi2,stimYele2] = cart2sph(xT2,yT2,zT2);%left for stimuli other than plain circle
        stimYele2 = stimYele2./(pi/2).*(stimTrigStruct.eleScale/2);
        stimXazi2 = stimXazi2./(pi).*(stimTrigStruct.aziScale/2);
        warpimage2(:,:,1) = fliplr(stimXazi2+stimTrigStruct.aziOff);
        warpimage2(:,:,2) = fliplr(stimYele2+stimTrigStruct.eleOff);
        
        modtex2 = Screen('MakeTexture', win, warpimage2,[],[],1);
        % Update the warpmap. First clear it out to zero offset, then draw:
        Screen('FillRect',warpmap2,0);
        Screen('DrawTexture',warpmap2,modtex2,[],warpDest2);
        warpedtex2 = [];
    end
    
    if isfield(stimTrigStruct,'imgWalltex')
        WalleleDelta = -(stimTrigStruct.eleValWall-90)*(pi/180);
        WallaziDelta = -(stimTrigStruct.aziValWall+180)*(pi/180);
        %        WalleleDelta = -(pi/180);
        %        WallaziDelta = -pi;
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
    if isfield(stimTrigStruct, 'imgtex2')
        warpedtex2 = Screen('TransformTexture',imgtexReset2,warpoperator2,warpmap2,warpedtex2);
        Screen('DrawTexture',win,warpedtex2,[],drawDest2)
    end
    if isfield(stimTrigStruct,'imgWalltex')
        warpedWalltex = Screen('TransformTexture',imgWalltex{1},Wallwarpoperator,Wallwarpmap,warpedWalltex);
        Screen('DrawTexture',win,warpedWalltex,[],drawDest);
    end
    Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
    Screen('Flip',win);
    
    % Visual stimulus presentation
    if isfield(stimTrigStruct, 'imgtex2')
        if frmCt >= frmCt2
            for iterStim = 1:frmCt
                warpedtex = Screen('TransformTexture',imgtex{flipRefVec(iterStim)},warpoperator,warpmap,warpedtex);
                Screen('DrawTexture',win,warpedtex,[],drawDest);
                if iterStim <= frmCt2
                    warpedtex2 = Screen('TransformTexture',imgtex2{flipRefVec2(iterStim)},warpoperator2,warpmap2,warpedtex2);
                    Screen('DrawTexture',win,warpedtex2,[],drawDest2);
                elseif iterStim > frmCt2
                    warpedtex2 = Screen('TransformTexture',imgtexFin2,warpoperator2,warpmap2,warpedtex2);
                    Screen('DrawTexture',win,warpedtex2,[],drawDest2);
                end
                Screen('DrawTexture',win,stimtex{iterStim},[],stimRefROI);
                [~,~,~,missedFrms(iterStim)] = Screen('Flip',win);
            end
        else
            for iterStim = 1:frmCt2
                warpedtex2 = Screen('TransformTexture',imgtex2{flipRefVec2(iterStim)},warpoperator2,warpmap2,warpedtex2);
                Screen('DrawTexture',win,warpedtex2,[],drawDest2);
                if iterStim <= frmCt
                    warpedtex = Screen('TransformTexture',imgtex{flipRefVec(iterStim)},warpoperator,warpmap,warpedtex);
                    Screen('DrawTexture',win,warpedtex,[],drawDest);
                elseif iterStim > frmCt && iterStim <= frmCt2
                    warpedtex = Screen('TransformTexture',imgtexFin,warpoperator,warpmap,warpedtex);
                    Screen('DrawTexture',win,warpedtex,[],drawDest);
                end
                Screen('DrawTexture',win,stimtex2{iterStim},[],stimRefROI);
                [~,~,~,missedFrms(iterStim)] = Screen('Flip',win);
            end
        end
    elseif isfield(stimTrigStruct,'imgWalltex') && numel(imgWalltex)~= numel(imgtex)
        for iterStim = 1:frmCt
            if iterStim <= numel(imgWalltex)
                warpedWalltex = Screen('TransformTexture',imgWalltex{iterStim},Wallwarpoperator,Wallwarpmap,warpedWalltex);
                Screen('DrawTexture',win,warpedWalltex,[],drawDest);
            else
                warpedtex = Screen('TransformTexture',imgtex{flipRefVec(iterStim-numel(imgWalltex))},warpoperator,warpmap,warpedtex);
                Screen('DrawTexture',win,warpedtex,[],drawDest);
            end
            Screen('DrawTexture',win,stimtex{iterStim},[],stimRefROI);
            [~,~,~,missedFrms(iterStim)] = Screen('Flip',win);
        end
    else
        for iterStim = 1:frmCt
            warpedtex = Screen('TransformTexture',imgtex{flipRefVec(iterStim)},warpoperator,warpmap,warpedtex);
            Screen('DrawTexture',win,warpedtex,[],drawDest);
            if isfield(stimTrigStruct,'wallframes') && iterStim > wallframes
            elseif isfield(stimTrigStruct,'imgWalltex')
                warpedWalltex = Screen('TransformTexture',imgWalltex{flipRefVec(iterStim)},Wallwarpoperator,Wallwarpmap,warpedWalltex);
                Screen('DrawTexture',win,warpedWalltex,[],drawDest);
            end
            Screen('DrawTexture',win,stimtex{iterStim},[],stimRefROI);
            [~,~,~,missedFrms(iterStim)] = Screen('Flip',win);
        end
    end
    % Hold the final frame for 2 seconds
    warpedtex = Screen('TransformTexture',imgtexFin,warpoperator,warpmap,warpedtex);
    Screen('DrawTexture',win,warpedtex,[],drawDest);
    if isfield(stimTrigStruct,'wallframes') && iterStim > wallframes
    elseif isfield(stimTrigStruct,'imgWalltex') && numel(imgWalltex) == numel(imgtex)
        warpedWalltex = Screen('TransformTexture',imgWalltex{1},Wallwarpoperator,Wallwarpmap,warpedWalltex);
        Screen('DrawTexture',win,warpedWalltex,[],drawDest);
    end
    if isfield(stimTrigStruct, 'imgtex2')
        warpedtex2 = Screen('TransformTexture',imgtexFin2,warpoperator2,warpmap2,warpedtex2);
        Screen('DrawTexture',win,warpedtex2,[],drawDest2);
    end
    
    
    Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
    Screen('Flip',win);
    pause(2)
    %
    
    % Return to ready state
    warpedtex = Screen('TransformTexture',imgtexReset,warpoperator,warpmap,warpedtex);
    Screen('DrawTexture',win,warpedtex,[],drawDest);
    if isfield(stimTrigStruct,'imgWalltex')
        warpedWalltex = Screen('TransformTexture',imgWalltex{1},Wallwarpoperator,Wallwarpmap,warpedWalltex);
        Screen('DrawTexture',win,warpedWalltex,[],drawDest);
    end
    if isfield(stimTrigStruct, 'imgtex2')
        warpedtex2 = Screen('TransformTexture',imgtexReset2,warpoperator2,warpmap2,warpedtex2);
        Screen('DrawTexture',win,warpedtex2,[],drawDest2);
    end
    Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
    Screen('Flip',win);
    % Close the transformation texture
    Screen('Close',[modtex;warpedtex]);
    if isfield(stimTrigStruct, 'imgtex2')
        Screen('Close',[modtex2;warpedtex2]);
    end
    Priority(oldPriority);
    missedFrms = sum(missedFrms > 0);
    
catch ME
    getReport(ME)
    psychrethrow(psychlasterror);
    Screen('CloseAll');
    Priority(oldPriority);
    
end
end
