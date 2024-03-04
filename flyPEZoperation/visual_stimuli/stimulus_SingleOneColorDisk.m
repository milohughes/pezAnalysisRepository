function missedFrms = stimulus_SingleOneColorDisk(stimStruct)

stimEleForProc = stimStruct.stimEleForProc;
stimAziForProc = stimStruct.stimAziForProc;
win = stimStruct.win;
warpmap = stimStruct.warpmap;
warpoperator = stimStruct.warpoperator;
stimSpecs = stimStruct.stimSpecs;
stimThetaRefs = stimStruct.stimThetaRefs;

deg2rad = @(x) x*(pi/180);

winRect = Screen('Rect',win);
height = winRect(4);
width = winRect(3);
hH = round(height/2);
hW = round(width/2);
smlSide = 360;
drawDest = CenterRect([0 0 height height],winRect);
warpimage = zeros(smlSide,smlSide,3);

eleCrop = imcrop(stimEleForProc,[hW-hH+1 1 height height]);
aziCrop = imcrop(stimAziForProc,[hW-hH+1 1 height height]);
aziSmall = imresize(aziCrop,[smlSide smlSide],'nearest');
eleSmall = imresize(eleCrop,[smlSide smlSide]);

scaleVal = 180;
minR = 0;
maxR = 360;
radiusResRef = 6;
radiusCt = (maxR-minR)*radiusResRef;
stimThetaRefs = round(stimThetaRefs.*radiusResRef);
eleOff = repmat(linspace(-scaleVal+1,scaleVal,smlSide)',1,smlSide);

img = ones(radiusCt,radiusCt);
imgIndA = repmat(linspace(2.5,radiusCt,radiusCt)',1,radiusCt);
imgIndB = repmat(linspace(1,radiusCt+1.5,radiusCt),radiusCt,1);
img(imgIndA < imgIndB) = 0;
img = imfilter(img,fspecial('average'),'replicate');
img = imresize(img,[scaleVal*2,radiusCt]);

% imshow(img)

imgCell = cell(radiusCt,1);
for iterI = 1:radiusCt
    imgCell{iterI} = uint8(repmat(img(:,iterI),1,smlSide).*255);
end
% imshow(img)

imgForTex = repmat(imgCell{1},[1 1 3]);
imgtex = Screen('MakeTexture',win,imgForTex);

% Determine where to place the "warp map":
imgRect = Screen('Rect',imgtex);
refRect = CenterRect(imgRect,winRect);
xoffset = refRect(RectLeft);
yoffset = refRect(RectTop);
[xp, yp] = RectCenter(winRect);
xp = xp-xoffset;
yp = yp+yoffset;%dunno why this works, from ImageWarpingDemo (WRW)
warpDest = CenterRectOnPoint(imgRect,xp,yp);

eleDelta = -deg2rad(stimSpecs.ele-90);
aziDelta = deg2rad(stimSpecs.azi);
[xS,yS,zS] = sph2cart(aziSmall-aziDelta,eleSmall,1);
% elevation is rotation about the y-axis
xT = xS.*cos(eleDelta)-zS.*sin(eleDelta);
yT = yS;
zT = xS.*sin(eleDelta)+zS.*cos(eleDelta);
% [stimXazi,stimYele] = cart2sph(xT,yT,zT);%left for stimuli other than plain circle
stimYele = atan2(zT,sqrt(xT.^2+yT.^2));
stimYele = stimYele./(pi/2).*scaleVal;

% plot(stimXazi(:),stimYele(:),'.')


% Compute a texture that contains the distortion vectors:
% Red channel encodes x offset components, Green encodes y offsets:

warpimage(:,:,2) = stimYele+eleOff;
try
    priorityLevel = MaxPriority(win);
    Priority(priorityLevel);
    
    % Flag set to '1' yields a floating point texture to allow fractional
    % offsets that are bigger than 1.0 and/or negative:
    modtex = Screen('MakeTexture', win, warpimage,[],[],1);
    % Update the warpmap. First clear it out to zero offset, then draw:
    Screen('FillRect',warpmap,0);
    Screen('DrawTexture',warpmap,modtex,[],warpDest);
    
    warpedtex = [];
    frmCt = size(stimThetaRefs,2);
    vbl = zeros(frmCt+1,1);
    vbl(1) = Screen('Flip',win);
    waitdur = ifi/2;
    for iterStim = 1:frmCt
        img = cat(3,imgCell{stimThetaRefs(1,iterStim)},...
            imgCell{stimThetaRefs(2,iterStim)},imgCell{stimThetaRefs(3,iterStim)});
        imgtex = Screen('MakeTexture',win,img);
        % Apply image warpmap to image:
        warpedtex = Screen('TransformTexture',imgtex,warpoperator,warpmap,warpedtex);
        % Draw and show the warped image:
        Screen('DrawTexture',win,warpedtex,[],drawDest);
        vbl(iterStim+1) = Screen('Flip',win,vbl(iterStim)+waitdur);
    end
    missedFrms = sum(diff(vbl) > ifi);
    Priority(0);
    Screen('Close');
catch
    Priority(0);
    Screen('CloseAll');
    psychrethrow(psychlasterror);
end
