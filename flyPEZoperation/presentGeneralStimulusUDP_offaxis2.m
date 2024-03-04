function [missedFrms,whiteCt] = presentGeneralStimulusUDP_offaxis2(stimTrigStruct2)
%presentDiskStimulus Receives previously initialized variables in struct
%and quickly presents the visual stimulus
%presentDiskStimulus Receives previously initialized variables in struct
%and quickly presents the visual stimulus
try
    
    imgtexReset = stimTrigStruct2.imgtexReset;
    warpoperator = stimTrigStruct2.warpoperator;
    warpmap = stimTrigStruct2.warpmap;
    warpedtex = [];
    win = stimTrigStruct2.win;
    drawDest = stimTrigStruct2.drawDest;
    stimRefTexB = stimTrigStruct2.stimRefTexB;
    stimRefROI = stimTrigStruct2.stimRefROI;
    frmCt = stimTrigStruct2.frmCt;
    stimXazi = stimTrigStruct2.stimXazi;
    aziOff = stimTrigStruct2.aziOff;
    stimYele = stimTrigStruct2.stimYele;
    eleOff = stimTrigStruct2.eleOff;
    warpDest = stimTrigStruct2.warpDest;
    imgtex = stimTrigStruct2.imgtex;
    stimtex = stimTrigStruct2.stimtex;
    imgtexFin = stimTrigStruct2.imgtexFin;
    whiteCt = stimTrigStruct2.whiteCt;
    flipRefVec = stimTrigStruct2.flipRefVec;
    warpimage = stimTrigStruct2.warpimage;
    modtex =  stimTrigStruct2.modtex;
    
    missedFrms = zeros(frmCt,1);
    priority_level = MaxPriority(win);
    oldPriority = Priority(priority_level);
    Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); %Sets up ability to have transparency in drawn textures
    
    % Present a single flip in preparation for visual stimulus
    % Apply image warpmap to image:
    warpedtex = Screen('TransformTexture',imgtexReset,warpoperator,warpmap,warpedtex);
    % Draw and show the warped image:
    Screen('DrawTexture',win,warpedtex,[],drawDest);
    Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
    Screen('Flip',win);
    
    % Visual stimulus presentation
    
    
    for iterStim = 1:frmCt
%         % Compute a texture that contains the distortion vectors:
%         % Red channel encodes x offset components, Green encodes y offsets:
%         warpimage(:,:,1) = fliplr(stimXazi(:,:,iterStim)+aziOff);
%         warpimage(:,:,2) = fliplr(stimYele(:,:,iterStim)+eleOff);
%         
%         
%         % Flag set to '1' yields a floating point texture to allow fractional
%         % offsets that are bigger than 1.0 and/or negative:
%         modtex = Screen('MakeTexture', win, warpimage,[],[],1);
%         toc
        % Update the warpmap. First clear it out to zero offset, then draw:
        Screen('FillRect',warpmap,0);
        Screen('DrawTexture',warpmap,modtex(iterStim),[],warpDest);
        
        warpedtex = Screen('TransformTexture',imgtex{flipRefVec(iterStim)},warpoperator,warpmap,warpedtex);
        Screen('DrawTexture',win,warpedtex,[],drawDest);
        Screen('DrawTexture',win,stimtex{iterStim},[],stimRefROI);
        [~,~,~,missedFrms(iterStim)] = Screen('Flip',win);
    end
    % Hold the final frame for 2 seconds
  
    warpedtex = Screen('TransformTexture',imgtex{flipRefVec(iterStim)},warpoperator,warpmap,warpedtex);
    Screen('DrawTexture',win,warpedtex,[],drawDest);
    Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
    Screen('Flip',win);
    pause(2)
    %
    
    % Return to ready state
    warpedtex = Screen('TransformTexture',imgtexReset,warpoperator,warpmap,warpedtex);
    Screen('DrawTexture',win,warpedtex,[],drawDest);
    Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
    Screen('Flip',win);
    % Close the transformation texture
    Screen('Close',[modtex warpedtex]);
    
    Priority(oldPriority);
    missedFrms = sum(missedFrms > 0);
    
catch ME
    getReport(ME)
    psychrethrow(psychlasterror);
    Screen('CloseAll');
    Priority(oldPriority);
    
end
end
