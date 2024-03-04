stimStruct = initializeVisualStimulusGeneralUDP_brighter;
%%
clearvars -except stimStruct
close(gcf)
clc

deg2rad = @(x) x*(pi/180);
rad2deg = @(x) x./(pi/180);

ellovervee = 140;

initStimSize = 5;
finalStimSize = 90;

deg2rad = @(x) x*(pi/180);
rad2deg = @(x) x./(pi/180);

minTheta = deg2rad(initStimSize);
maxTheta = deg2rad(finalStimSize);
stimStartTime = ellovervee/tan(minTheta/2);
stimEndTime = ellovervee/tan(maxTheta/2);
stimTotalDuration = stimStartTime-stimEndTime;
stimTimeStep = (1/360)*1000;%milliseconds per frame channel at 120 Hz
stimTimeVector = fliplr(stimEndTime:stimTimeStep:stimStartTime);
stimThetaVector = 2.*atan(ellovervee./stimTimeVector);
stimFrmCt = numel(stimThetaVector);
stimThetaRemainder = round((ceil(stimFrmCt/3)-stimFrmCt/3)*3);
stimThetaVector = [stimThetaVector,...
    repmat(stimThetaVector(end),[1 stimThetaRemainder])];
stimRadiusVector = rad2deg(stimThetaVector);
stimThetaRefs = reshape(stimThetaVector,3,numel(stimThetaVector)/3);

thetaCt = numel(stimThetaRefs);%%%%%the number of frame fragments

% The following is done because the projector displays R then B then G
% stimThetaRefs = [stimThetaRefs(3,:);stimThetaRefs(1,:);stimThetaRefs(2,:)];
stimThetaRefs = rad2deg(stimThetaRefs);
% plot(stimThetaRefs(:))

revolutionsPerLoom = 11;%defines how many black bands will be present on a radius

magV = 10;
imThetaRefs = interp1(linspace(1,thetaCt*magV,thetaCt),stimThetaRefs(:)',(1:thetaCt*magV),'pchip');
imThetaRefs = imThetaRefs.*magV;
% plot(imThetaRefs)
spiralImW = ones(finalStimSize*magV,thetaCt*magV);
for iterSpA = 1:thetaCt*magV
    spiralImW(1:round(imThetaRefs(iterSpA)),iterSpA) = 0;
end
spiralImB = abs(spiralImW-1);
% imshow([spiralImW;spiralImB])
padW = round(thetaCt*magV/revolutionsPerLoom/2);
padB = zeros(finalStimSize*magV,padW);
padW = abs(padB+1);
spiralImBW = [spiralImW padB]+[padB spiralImB];
spiralImCum = spiralImBW;
for iterRevs = 1:revolutionsPerLoom*2
    padIter = repmat(padW,1,iterRevs*2);
    spiralImCum = [spiralImCum padW padW].*[padIter spiralImBW];
end
%
dirstrCell = {'forward','reverse'};
for iterFR = 1:2
    dirstr = dirstrCell{iterFR};
    fileName = ['spiral_5to90_lv' num2str(ellovervee) '_' dirstr '.mat']
    
    lastB = find(spiralImCum(1,:) == 0,1,'last');
    spiralImCrop = spiralImCum(:,1:lastB);
    lastW = find(spiralImCrop(1,:) == 1,1,'last');
    spiralImCrop = spiralImCrop(:,1:lastW);
    spiralImCrop = spiralImCrop(:,end-thetaCt*magV+1:end);
    spiralImCrop(1:initStimSize*magV,:) = 0;
    spiralImCrop(finalStimSize*magV:360*magV,:) = 1;
    % imshow(spiralImCrop)
    cropMag = round(thetaCt*magV/revolutionsPerLoom);
    spiralIm = spiralImCrop(:,1:cropMag);
    % imshow(spiralIm)
    
    height = 768;
    width = 1024;
    hH = round(height/2);
    hW = round(width/2);
    
    eleScale = height;%Determines resolution of undistorted image at the cost of speed
    aziScale = width;
    
%     stimTotalDuration = 3000;
%     frmCt = round(stimTotalDuration/stimTimeStep);
    frmCt = size(stimThetaRefs,2);
    stimRefRGB = [2 3 1];
    spiralImCrop = imresize(spiralImCrop,[eleScale size(spiralImCrop,2)]);
    imgCell = cell(frmCt,1);
    if strcmp(dirstr,'reverse')
        magSign = 1;
    else
        magSign = -1;
    end
    for iterPrep = 1:frmCt
        imgCat = zeros(eleScale,aziScale,3);
        for iterFrm = 1:3
            spiralIm = spiralImCrop(:,1:cropMag);
            img = imresize(spiralIm,[eleScale aziScale]);
            %         img = imfilter(img,fspecial('average',[3 3]),'replicate');
            imgCat(:,:,stimRefRGB(iterFrm)) = img;
            spiralImCrop = circshift(spiralImCrop,[0 magV*magSign]);
        end
        imgCell{iterPrep} = uint8(imgCat.*255);
    end
    
    imgReset = repmat(imgCell{1}(:,:,3),[1 1 3]);
    imgFin = repmat(imgCell{1}(:,:,3),[1 1 3]);
    %
    stimulusStruct = struct('stimTotalDuration',stimTotalDuration,'imgReset',imgReset,...
        'imgFin',imgFin,'eleScale',eleScale,'aziScale',aziScale);
    stimulusStruct(1).imgCell = imgCell;
    save(fullfile('Z:\pez3000_variables\visual_stimuli',fileName),'stimulusStruct','-v7.3')
end
%%
%%%%% Establish variables needed in stimulus presentation
stimEleForProc = stimStruct.stimEleForProc;
stimAziForProc = stimStruct.stimAziForProc;
win = stimStruct.win;
warpmap = stimStruct.warpmap;
warpoperator = stimStruct.warpoperator;
stimRefROI = stimStruct.stimRefROI;

eleCrop = imcrop(stimEleForProc,[hW-hH+1 1 height height]);
aziCrop = imcrop(stimAziForProc,[hW-hH+1 1 height height]);
aziSmall = imresize(aziCrop,[eleScale aziScale]);
eleSmall = imresize(eleCrop,[eleScale aziScale]);

%
winRect = Screen('Rect',win);
drawDest = CenterRect([0 0 height height],winRect);
warpimage = zeros(eleScale,aziScale,3);

img = uint8(zeros(eleScale,aziScale));
% Determine where to place the "warp map":
imgForTex = repmat(img,[1 1 3]);
imgtexDummy = Screen('MakeTexture',win,imgForTex);
imgRect = Screen('Rect',imgtexDummy);
refRect = CenterRect(imgRect,winRect);
xoffset = refRect(RectLeft);
yoffset = refRect(RectTop);
[xp, yp] = RectCenter(winRect);
xp = xp-xoffset;
yp = yp+yoffset;%dunno why this works, from ImageWarpingDemo (WRW)
warpDest = CenterRectOnPoint(imgRect,xp,yp);


eleVal = 90;
aziVal = 180;
eleDelta = -(eleVal-90)*(pi/180);
aziDelta = -(aziVal+180)*(pi/180);
[xS,yS,zS] = sph2cart(aziSmall-aziDelta,eleSmall,1);
% elevation is rotation about the y-axis
xT = xS.*cos(eleDelta)-zS.*sin(eleDelta);
yT = yS;
zT = xS.*sin(eleDelta)+zS.*cos(eleDelta);
[stimXazi,stimYele] = cart2sph(xT,yT,zT);%left for stimuli other than plain circle
% [stimXazi,~] = cart2sph(xS,yS,zS);%left for stimuli other than plain circle


% stimYele = atan2(zT,sqrt(xT.^2+yT.^2));
stimYele = stimYele./(pi/2).*(eleScale/2);
stimXazi = stimXazi./(pi).*(aziScale/2);

% Compute a texture that contains the distortion vectors:
% Red channel encodes x offset components, Green encodes y offsets:
eleOff = repmat(linspace(-eleScale/2+1,eleScale/2,eleScale)',1,aziScale);
aziOff = repmat(linspace(-aziScale/2+1,aziScale/2,aziScale),eleScale,1);
warpimage(:,:,1) = fliplr(stimXazi+aziOff);
warpimage(:,:,2) = fliplr(stimYele+eleOff);
warpdemo = warpimage(:,:,2);
warpdemo = (warpdemo-min(warpdemo(:)))./range(warpdemo(:));
% imshow(warpdemo)

%%%%% image post processing
img = imresize(spiralIm,[eleScale aziScale]);
% img = imfilter(img,fspecial('average',[3 3]),'replicate');

% imshow(img)
imgReset = repmat(uint8(img.*255),[1 1 3]);
imgtexReset = Screen('MakeTexture',win,imgReset);
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Flag set to '1' yields a floating point texture to allow fractional
% offsets that are bigger than 1.0 and/or negative:
modtex = Screen('MakeTexture', win, warpimage,[],[],1);
% Update the warpmap. First clear it out to zero offset, then draw:
Screen('FillRect',warpmap,0);
Screen('DrawTexture',warpmap,modtex,[],warpDest);
warpedtex = [];

warpedtex = Screen('TransformTexture',imgtexReset,warpoperator,warpmap,warpedtex);
% Draw and show the warped image:
Screen('DrawTexture',win,warpedtex,[],drawDest);
% Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
Screen('Flip',win);




%%

for iterStim = 1:frmCt
    warpedtex = Screen('TransformTexture',imgtex{iterStim},warpoperator,warpmap,warpedtex);
    Screen('DrawTexture',win,warpedtex,[],drawDest);
    Screen('DrawTexture',win,stimtex{iterStim},[],stimRefROI);
    Screen('Flip',win);
end

%%
% stimStruct = initializeVisualStimulusGeneralUDP_brighter;
fileName = 'spiral_5to90_lv40_forward.mat';
[stimTrigStruct] = initializeFramesFromFileUDP(stimStruct,fileName);
stimTrigStruct.eleVal = 90;
stimTrigStruct.aziVal = 0;
%%
[missedFrms,whiteCt] = presentGeneralStimulusUDP(stimTrigStruct);


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
    writeObj = VideoWriter('C:\Users\williamsonw\Documents\Card Lab\spiral_5to90_lv40_forward.avi','Grayscale AVI');
    open(writeObj)
    % Visual stimulus presentation
    for iterStim = 1%:frmCt
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








