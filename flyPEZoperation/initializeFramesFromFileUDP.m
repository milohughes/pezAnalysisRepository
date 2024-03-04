function [stimTrigStruct] = initializeFramesFromFileUDP(stimStruct,fileName)

%%%%% computer and directory variables and information
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');
variablesDir = fullfile(fileDir,'pez3000_variables');

stimLoad = load(fullfile(variablesDir,'visual_stimuli_pez3005',fileName));
stimulusStruct = stimLoad.stimulusStruct;

%%%%% Establish variables needed in stimulus presentation
stimEleForProc = stimStruct.stimEleForProc;
stimAziForProc = stimStruct.stimAziForProc;
win = stimStruct.win;
warpmap = stimStruct.warpmap;
warpoperator = stimStruct.warpoperator;
stimRefROI = stimStruct.stimRefROI;

if isfield(stimulusStruct,'imgWall')
    Wallwarpmap = stimStruct.Wallwarpmap;
    Wallwarpoperator = stimStruct.Wallwarpoperator;
    eleValWall = stimulusStruct.eleValWall;
    aziValWall = stimulusStruct.aziValWall;
elseif isfield(stimulusStruct,'img2')
    warpmap2 = stimStruct.warpmap2;
    warpoperator2 = stimStruct.warpoperator2;
    eleVal2 = stimulusStruct.eleVal2;
    aziVal2 = stimulusStruct.aziVal2;
end

winRect = Screen('Rect',win);
height = winRect(4);
width = winRect(3);
hH = round(height/2);
hW = round(width/2);

eleScale = stimulusStruct.eleScale;%Determines resolution of undistorted image at the cost of speed
aziScale = stimulusStruct.aziScale;

eleCrop = imcrop(stimEleForProc,[hW-hH+1 1 height height]);
aziCrop = imcrop(stimAziForProc,[hW-hH+1 1 height height]);
aziSmall = imresize(aziCrop,[eleScale aziScale]);
eleSmall = imresize(eleCrop,[eleScale aziScale]);

if isfield(stimulusStruct,'stimAzi')
    aziSmall = repmat(aziSmall,[1 1 length(stimulusStruct.stimAzi)]);
    for i = 1:length(stimulusStruct.stimAzi)
        aziSmall(:,:,i) = aziSmall(:,:,i) + (stimulusStruct.stimAzi(i)*(pi/180));
    end
end

%
winRect = Screen('Rect',win);
drawDest = CenterRect([0 0 height height],winRect);
drawDest2 = CenterRect([0 0 height height],winRect);
warpimage = zeros(eleScale,aziScale,3);
Wallwarpimage = zeros(eleScale,aziScale,3);
warpimage2 = zeros(eleScale,aziScale,3);

% Determine where to place the "warp map":
img = uint8(zeros(eleScale,aziScale));
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
WallwarpDest = CenterRectOnPoint(imgRect,xp,yp);
warpDest2 = CenterRectOnPoint(imgRect,xp,yp);


eleOff = repmat(linspace(-eleScale/2+1,eleScale/2,eleScale)',1,aziScale);
aziOff = repmat(linspace(-aziScale/2+1,aziScale/2,aziScale),eleScale,1);

Screen('BlendFunction', win, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); %Sets up ability to have transparency in drawn textures


if isfield(stimulusStruct,'imgWall')
    imgWall = stimulusStruct.imgWall;
    WalleleDelta = -(eleValWall-90)*(pi/180);
    WallaziDelta = -(aziValWall+180)*(pi/180);
    %         WalleleDelta = -(pi/180);
    %         WallaziDelta = -pi;
    [WallxS,WallyS,WallzS] = sph2cart(aziSmall-WallaziDelta,eleSmall,1);
    WallxT = WallxS.*cos(WalleleDelta)-WallzS.*sin(WalleleDelta);
    WallyT = WallyS;
    WallzT = WallxS.*sin(WalleleDelta)+WallzS.*cos(WalleleDelta);
    [WallstimXazi,WallstimYele] = cart2sph(WallxT,WallyT,WallzT);
    WallstimYele = WallstimYele./(pi/2).*(eleScale/2);
    WallstimXazi = WallstimXazi./(pi).*(aziScale/2);
    
    Wallwarpimage(:,:,1) = fliplr(WallstimXazi+aziOff);
    Wallwarpimage(:,:,2) = fliplr(WallstimYele+eleOff);
    
    Wallmodtex = Screen('MakeTexture', win, Wallwarpimage,[],[],1);
    
    Screen('FillRect',Wallwarpmap,0);
    Screen('DrawTexture',Wallwarpmap,Wallmodtex,[],WallwarpDest);
    warpedWalltex = [];
elseif isfield(stimulusStruct,'img2')
    img2 = stimulusStruct.img2;
    eleDelta2 = -(eleVal2-90)*(pi/180);
    aziDelta2 = -(aziVal2+180)*(pi/180);
    %         WalleleDelta = -(pi/180);
    %         WallaziDelta = -pi;
    [xS2,yS2,zS2] = sph2cart(aziSmall-aziDelta2,eleSmall,1);
    xT2 = xS2.*cos(eleDelta2)-zS2.*sin(eleDelta2);
    yT2 = yS2;
    zT2 = xS2.*sin(eleDelta2)+zS2.*cos(eleDelta2);
    [stimXazi2,stimYele2] = cart2sph(xT2,yT2,zT2);
    stimYele2 = stimYele2./(pi/2).*(eleScale/2);
    stimXazi2 = stimXazi2./(pi).*(aziScale/2);
    
    warpimage2(:,:,1) = fliplr(stimXazi2+aziOff);
    warpimage2(:,:,2) = fliplr(stimYele2+eleOff);
    
    modtex2 = Screen('MakeTexture', win, warpimage2,[],[],1);
    
    Screen('FillRect',warpmap2,0);
    Screen('DrawTexture',warpmap2,modtex2,[],warpDest2);
    warpedtex2 = [];
end
imgCell = stimulusStruct.imgCell;
if isfield(stimulusStruct,'img2')
    imgCell2 = stimulusStruct.imgCell2;
    textureCt2 = numel(imgCell2);
end
imgReset = stimulusStruct.imgReset;
imgtexReset = Screen('MakeTexture',win,imgReset);
% imgReset2 = stimulusStruct.imgReset2;

if isfield(stimulusStruct,'img2')
    imgReset2 = stimulusStruct.imgReset;
    imgtexReset2 = Screen('MakeTexture',win,imgReset2);
end

stimRefImageB = uint8(zeros(3,3,3));
stimRefTexB = Screen('MakeTexture',win,stimRefImageB);
% Apply image warpmap to image:
warpedtex = Screen('TransformTexture',imgtexReset,warpoperator,warpmap,[]);
if isfield(stimulusStruct,'img2')
    warpedtex2 = Screen('TransformTexture',imgtexReset2,warpoperator2,warpmap,[]);
end

%%% Prepare main image textures
textureCt = numel(imgCell);
if isfield(stimulusStruct,'flipReference')
    flipReference = stimulusStruct.flipReference;
else
    flipReference = (1:textureCt);
end
if isfield(stimulusStruct,'imgWall') && numel(imgWall)~= numel(imgCell)
    frameCt = numel(imgWall)+numel(flipReference);
else
    frameCt = numel(flipReference);
end


if isfield(stimulusStruct,'img2')
    if isfield(stimulusStruct,'flipReference2')
        flipReference2 = stimulusStruct.flipReference2;
        frameCt2 = numel(flipReference2);
    else
        flipReference2 = (1:textureCt2);
    end
end

% if frameCt > frameCt2
%     frameCt2 = frameCt;
% elseif frameCt2 > frameCt
%     frameCt = frameCt2;
% end

imgtex = cell(textureCt,1);
if isfield(stimulusStruct,'imgWall')
    imgWalltex = cell(numel(imgWall),1);
elseif isfield(stimulusStruct,'img2')
    imgtex2 = cell(textureCt2,1);
    imgtexReset2 = Screen('MakeTexture',win,imgReset2);
end
for iterPrep = 1:textureCt
    imgCat = imgCell{iterPrep,1};
    imgtex{iterPrep} = Screen('MakeTexture',win,imgCat);
end
if isfield(stimulusStruct,'imgWall')
    for iterPrep = 1:numel(imgWall)
        imgWallCat = imgWall{iterPrep};
        imgWalltex{iterPrep} = Screen('MakeTexture',win,imgWallCat);
    end
end
if isfield(stimulusStruct,'img2')
    for iterPrep2 = 1:textureCt2
        imgCat2 = imgCell2{iterPrep2};
        imgtex2{iterPrep2} = Screen('MakeTexture',win,imgCat2);
    end
end

imgFin = stimulusStruct.imgFin;
imgtexFin = Screen('MakeTexture',win,imgFin);
if isfield(stimulusStruct,'img2')
    imgFin2 = stimulusStruct.imgFin2;
    imgtexFin2 = Screen('MakeTexture',win,imgFin2);
end



%%% Flicker preparation
%The following two lines work for RGB order [1 2 3]
%stimRefImageWA = uint8(cat(3,zeros(5)+255,zeros(5)+10,zeros(5)+255));
%stimRefImageWB = uint8(cat(3,zeros(5)+10,zeros(5)+255,zeros(5)+10));
%The following two lines works for RGB order [2 3 1]
 stimRefImageWA = uint8(cat(3,zeros(5)+10,zeros(5)+255,zeros(5)+255));
 stimRefImageWB = uint8(cat(3,zeros(5)+255,zeros(5)+10,zeros(5)+10));
stimRefImCell = {stimRefImageWA,stimRefImageWB};
stimRefRefs = repmat([1 2]',ceil(frameCt/2),1);
stimRefRefs = stimRefRefs(:);
whiteCt = 0;
stimtex = cell(frameCt,1);
if isfield(stimulusStruct,'img2')
    stimtex2 = cell(frameCt2,1);
end

for iterPrep = 1:frameCt
    stimIm = stimRefImCell{stimRefRefs(iterPrep)};
    stimtex{iterPrep} = Screen('MakeTexture',win,stimIm);
    if stimRefRefs(iterPrep) == 1
        whiteCt = whiteCt+2;
    else
        whiteCt = whiteCt+1;
    end
end
if isfield(stimulusStruct,'img2')
    stimRefRefs2 = repmat([1 2]',ceil(frameCt2/2),1);
    stimRefRefs2 = stimRefRefs2(:);
    for iterPrep2 = 1:frameCt2
        stimIm2 = stimRefImCell{stimRefRefs2(iterPrep2)};
        stimtex2{iterPrep2} = Screen('MakeTexture',win,stimIm2);
        if stimRefRefs2(iterPrep2) == 1
            whiteCt2 = 2;
        else
            whiteCt2 = 1;
        end
    end
end

% Draw and show the warped image:
Screen('DrawTexture',win,warpedtex,[],drawDest);
if isfield(stimulusStruct,'imgWall')
    warpedWalltex = Screen('TransformTexture',imgWalltex{1},Wallwarpoperator,Wallwarpmap,warpedWalltex);
    Screen('DrawTexture',win,warpedWalltex,[],drawDest);
elseif isfield(stimulusStruct,'img2')
    warpedtex2 = Screen('TransformTexture',imgtexReset2,warpoperator2,warpmap2,warpedtex2);
    Screen('DrawTexture',win,warpedtex2,[],drawDest2);
end
Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
Screen('Flip',win);
Screen('Close',warpedtex);



if isfield(stimulusStruct,'imgWall')
    stimTrigStruct = struct('stimTotalDuration',stimulusStruct.stimTotalDuration,...
        'drawDest',drawDest,'warpimage',warpimage,'Wallwarpimage',Wallwarpimage,'aziSmall',aziSmall,'eleSmall',eleSmall,...
        'eleOff',eleOff,'aziOff',aziOff,'warpDest',warpDest,'WallwarpDest',WallwarpDest,'win',win,...
        'warpmap',warpmap,'Wallwarpmap',Wallwarpmap,'warpoperator',warpoperator,'Wallwarpoperator',Wallwarpoperator','stimRefROI',stimRefROI,...
        'whiteCt',whiteCt,'imgtexReset',imgtexReset,'imgtexFin',imgtexFin,...
        'stimRefTexB',stimRefTexB,'eleScale',eleScale,'aziScale',aziScale,'eleValWall',eleValWall,'aziValWall',aziValWall);
elseif isfield(stimulusStruct,'img2')
    stimTrigStruct = struct('stimTotalDuration',stimulusStruct.stimTotalDuration,...
        'drawDest',drawDest,'warpimage',warpimage,'warpimage2',warpimage2,'drawDest2',drawDest2,'aziSmall',aziSmall,'eleSmall',eleSmall,...
        'eleOff',eleOff,'aziOff',aziOff,'warpDest',warpDest,'warpDest2',warpDest2,'win',win,...
        'warpmap',warpmap,'warpmap2',warpmap2,'warpoperator',warpoperator,'warpoperator2',warpoperator2','stimRefROI',stimRefROI,...
        'whiteCt',whiteCt,'imgtexReset',imgtexReset,'imgtexReset2',imgtexReset2,'imgtexFin',imgtexFin,'imgtexFin2',imgtexFin2,...
        'stimRefTexB',stimRefTexB,'eleScale',eleScale,'aziScale',aziScale,'eleVal2',eleVal2,'aziVal2',aziVal2);
elseif isfield(stimulusStruct,'stimAzi')
        stimTrigStruct = struct('stimTotalDuration',stimulusStruct.stimTotalDuration,...
            'drawDest',drawDest,'warpimage',warpimage,'aziSmall',aziSmall,'eleSmall',eleSmall,...
            'eleOff',eleOff,'aziOff',aziOff,'warpDest',warpDest,'win',win,...
            'warpmap',warpmap,'warpoperator',warpoperator,'stimRefROI',stimRefROI,...
            'whiteCt',whiteCt,'imgtexReset',imgtexReset,'imgtexFin',imgtexFin,...
            'stimRefTexB',stimRefTexB,'eleScale',eleScale,'aziScale',aziScale,'stimAzi',stimulusStruct.stimAzi,'stimEle',stimulusStruct.stimEle);
else
    stimTrigStruct = struct('stimTotalDuration',stimulusStruct.stimTotalDuration,...
        'drawDest',drawDest,'warpimage',warpimage,'aziSmall',aziSmall,'eleSmall',eleSmall,...
        'eleOff',eleOff,'aziOff',aziOff,'warpDest',warpDest,'win',win,...
        'warpmap',warpmap,'warpoperator',warpoperator,'stimRefROI',stimRefROI,...
        'whiteCt',whiteCt,'imgtexReset',imgtexReset,'imgtexFin',imgtexFin,...
        'stimRefTexB',stimRefTexB,'eleScale',eleScale,'aziScale',aziScale);
end
stimTrigStruct(1).imgtex = imgtex;
stimTrigStruct(1).stimtex = stimtex;
if isfield(stimulusStruct,'imgWall')
    stimTrigStruct(1).imgWalltex = imgWalltex;
    if isfield(stimulusStruct,'wallframes')
        stimTrigStruct(1).wallframes = stimulusStruct.wallframes;
    end
elseif isfield(stimulusStruct,'img2')
    stimTrigStruct(1).img2 = img2;
    stimTrigStruct(1).imgtex2 = imgtex2;
    stimTrigStruct(1).stimtex2 = stimtex2;
    stimTrigStruct(1).flipReference2 = flipReference2;
end
if isfield(stimulusStruct,'numLoops')
    stimTrigStruct(1).numLoops = stimulusStruct.numLoops;
end
stimTrigStruct(1).flipReference = flipReference;
