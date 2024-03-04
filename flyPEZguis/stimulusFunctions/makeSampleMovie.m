
%Destination path
movieDir = 'C:\Users\williamsonw\Documents\Card Lab';
%Name of movie to be saved
movieName = 'spiral_5to90_lv40_forward.avi';
%Name of stimulus to be used
fileName = 'spiral_5to90_lv40_forward.mat';



moviePath = fullfile(movieDir,movieName);
[~,~,movExt] = fileparts(moviePath);
if strcmp(movExt,'.avi')
    movType = 'Grayscale AVI';
elseif strcmp(movExt,'.mp4')
    movType = 'MPEG-4';
else
    disp('specify movie file extention')
    return
end

% PTB-3 properly installed and working?
AssertOpenGL;
Screen('Preference','Verbosity',2);
Screen('Preference', 'SkipSyncTests', 1);
comp_name = 'peekm-ww3';%pez1
varDest = 'C:\Users\williamsonw\Documents\Photron_flyPez3000\visual_stimuli';
varName = [comp_name '_stimuliVars.mat'];
varPath = fullfile(varDest,varName);
load(varPath)
% Open onscreen window with black background clear color:

screenid = 0;
[width,height] = Screen('WindowSize',screenid);
xy = [round(width/8*5) round(height/4)]
% Set the PTB to balance brightness post-processing
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask','General','UseVirtualFramebuffer');
PsychImaging('AddTask','AllViews','DisplayColorCorrection','GainMatrix');
win = PsychImaging('OpenWindow',screenid,[],[0 0 1024 768]+[xy xy]);
gainMatrixBrighter(gainMatrixBrighter < max(gainMatrixBrighter(:))) = max(gainMatrixBrighter(:));
PsychColorCorrection('SetGainMatrix',win,gainMatrixBrighter,[],0);
% Create warpoperator for application of the image warp:
winRect = Screen('Rect',win);
warpoperator = CreateGLOperator(win);
warpmap = AddImageWarpToGLOperator(warpoperator, winRect);
ifi = [];
stimStruct = struct('stimEleForProc',stimEleForProc,'stimAziForProc',...
    stimAziForProc,'win',win,'warpmap',warpmap,'warpoperator',...
    warpoperator,'stimRefROI',stimRefROI,'ifi',ifi,'vertLinesIm',vertLinesIm);
% end
%%
[stimTrigStruct] = initializeFramesFromFileUDP(stimStruct,fileName);
stimTrigStruct.eleVal = 90;
stimTrigStruct.aziVal = 0;
%%
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
    
    % Present a single flip in preparation for visual stimulus
    % Apply image warpmap to image:
    warpedtex = Screen('TransformTexture',imgtexReset,warpoperator,warpmap,warpedtex);
    % Draw and show the warped image:
    Screen('DrawTexture',win,warpedtex,[],drawDest);
    Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
    Screen('Flip',win);
    
    height = 768;
    width = 1024;
    hH = round(height/2);
    hW = round(width/2);
    cH = 200;
    cW = 300;
    
    writeObj = VideoWriter(moviePath,movExt);
    open(writeObj)
    % Visual stimulus presentation
    for iterStim = 1:frmCt
        warpedtex = Screen('TransformTexture',imgtex{iterStim},warpoperator,warpmap,warpedtex);
        Screen('DrawTexture',win,warpedtex,[],drawDest);
        Screen('DrawTexture',win,stimtex{iterStim},[],stimRefROI);
        [~,~,~,missedFrms(iterStim)] = Screen('Flip',win);
        imGotten = Screen('GetImage',win);
        for iterT = ([2,3,1])
            imCrop = imGotten(hH-cH+1:hH+cH,hW-cW+1:hW+cW,iterT);
            writeVideo(writeObj,imCrop)
        end
    end
    close(writeObj)
    
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








