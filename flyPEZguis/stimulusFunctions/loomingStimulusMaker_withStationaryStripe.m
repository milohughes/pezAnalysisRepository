%% Run this once for each loom you'd like to make

% clearvars -except stimStruct
% close(gcf)
% clc
pez5 = 1;
%%------Wall Parameters---------%
stripe_width_deg = 45; % deg  
stripe_height_deg = 180; % deg
stripe_azimuth_center = 0; %deg
stripe_elevation_center = 0; %deg
use_stripe_time = 0; %1 - use stripe time (wedge on for specified time then disappears), 0 - do not use (wedge is always on)
stripe_time = 750; %time wedge is on in ms

elecent = num2str(stripe_elevation_center);
if contains(elecent,'.')
    elecent = replace(elecent,'.','p');
end

%%------Loom Parameters---------%
initStimSize = 5;
finalStimSize = 90;
ellovervee = 40;
velocity = 8000;% degress per second
duration = 30000;% milliseconds
foregroundVal = 0;%value from 0 (black) to 1 (white) - this is the disk
backgroundVal = 255;%0-255 (black-white)
diskStyle = 1; % 1 - filled ; 2 - empty ('ring')
ringSize = 10; % in degrees
stimChoice = 2;
stimOps = {'testing'
    'loom'
    'constVelo'
    'constSize'}; % uses init stim size

prefixStr = stimOps{stimChoice};
if foregroundVal == 1
    strA = 'white';
elseif foregroundVal == 0
    strA = 'black';
else
    strA = ['gray' num2str(round(foregroundVal*100))];
end
if backgroundVal == 255
    strB = 'white';
elseif backgroundVal == 0
    strB = 'black';
else
    strB = ['gray' num2str(round(backgroundVal/255*100))];
end
deg2rad = @(x) x*(pi/180);
rad2deg = @(x) x./(pi/180);
stimTimeStep = (1/360)*1000;%milliseconds per frame channel at 120 Hz
imOversizeFactor = 2;

%%%%% stimThetaVector must be in terms of a radius !!!!!!!!!!!!!!!!
if strcmp(prefixStr,'constVelo')
    fileName = [prefixStr '_' num2str(initStimSize) 'to' num2str(finalStimSize),...
        '_' num2str(velocity) 'degPerSec_' strA 'on' strB];
    stimTotalDuration = ((finalStimSize-initStimSize)/velocity)*1000;
    totalSteps = stimTotalDuration/stimTimeStep+1;
    stimThetaVector = deg2rad(linspace(initStimSize,finalStimSize,totalSteps))/2;
elseif strcmp(prefixStr,'constSize')
    fileName = ['wall_w' num2str(stripe_width_deg) 'at' num2str(stripe_azimuth_center) '_h' num2str(stripe_height_deg) 'at'...
        elecent '_' prefixStr,...
        '_' num2str(duration) 'ms_' strA];
    stimTotalDuration = duration;
    totalSteps = stimTotalDuration/stimTimeStep+1;
    stimThetaVector = deg2rad(linspace(initStimSize,initStimSize,totalSteps))/2;
else
    initStimSizeStr = initStimSize;
    if round(initStimSizeStr/2)*2 ~= initStimSizeStr
        initStimSizeStr = regexprep(num2str(initStimSizeStr),'\.','pt');
    else
        initStimSizeStr = num2str(initStimSize);
    end
    if use_stripe_time
        fileName = ['wall_' num2str(stripe_time) 'ms_w' num2str(stripe_width_deg) 'at' num2str(stripe_azimuth_center) '_h' num2str(stripe_height_deg) 'at'...
            elecent '_lwht_' initStimSizeStr 'to' num2str(finalStimSize),...
            '_lv' num2str(ellovervee)];
    else
        fileName = ['wall_w' num2str(stripe_width_deg) 'at' num2str(stripe_azimuth_center) '_h' num2str(stripe_height_deg) 'at'...
            elecent '_' prefixStr '_' initStimSizeStr 'to' num2str(finalStimSize),...
            '_lv' num2str(ellovervee)];
    end
    
    %making disk radius per time (frame) vector
    minTheta = deg2rad(initStimSize);
    maxTheta = deg2rad(finalStimSize);
    if minTheta <= 0
        error('make starting size greater than zero')
    end
    stimStartTime = ellovervee/tan(minTheta/2);
    stimEndTime = ellovervee/tan(maxTheta/2);
    stimTotalDuration = stimStartTime-stimEndTime;
    stimTimeVector = fliplr(stimEndTime:stimTimeStep:stimStartTime);
    stimThetaVector = 1.*atan(ellovervee./stimTimeVector);
    %stimThetaVector = 2.*atan(ellovervee./stimTimeVector);
end

stimFrmCt = numel(stimThetaVector);
stimThetaRemainder = round((ceil(stimFrmCt/3)-stimFrmCt/3)*3);
stimThetaVectorEven = [stimThetaVector,...
    repmat(stimThetaVector(end),[1 stimThetaRemainder])];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
radiusResRef = 6;%radius resolution will be at 1/radiusResRef
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stimRadiusVector = round(rad2deg(stimThetaVectorEven*radiusResRef))/radiusResRef;%rounds to the nearest 1/radiusResRef degree
stimRadiusTriplet = reshape(stimRadiusVector,3,numel(stimRadiusVector)/3);
sameTripletLogical = sum(diff(stimRadiusTriplet)) == 0;
[~,stimRadiusUnique,flipReference] = unique(mean(stimRadiusTriplet));
disp(['orig texture count: ' num2str(numel(flipReference))])
disp(['condensed texture count: ' num2str(numel(stimRadiusUnique))])
disp('all pezzes can handle at least 300 textures')



height = 768;%projector height
width = 1024;%projector width
hH = round(height/2);
hW = round(width/2);

smlSide = 720;%Determines resolution of undistorted image at the cost of speed

scaleVal = 360;
minDiam = 0;
maxDiam = 360;

radiusCt = (maxDiam-minDiam)*radiusResRef;
stimDiameterReference = round(stimRadiusTriplet(:,stimRadiusUnique).*radiusResRef)*2;
stimDiameterReference(stimDiameterReference == 0) = 1;
img = ones([radiusCt radiusCt]*imOversizeFactor);
imgIndA = repmat(linspace(2.5,radiusCt,radiusCt*imOversizeFactor)',1,radiusCt*imOversizeFactor);
imgIndB = repmat(linspace(1,radiusCt+1.5,radiusCt*imOversizeFactor),radiusCt*imOversizeFactor,1);

img(imgIndA < imgIndB) = foregroundVal;
if diskStyle == 2
    ringSize = ringSize*(radiusCt*imOversizeFactor)/360;
    ringRef = round(linspace(1,size(img,1),size(img,2)))-ringSize;
    ringRef(ringRef < 1) = 1;
    for fml = 1:size(img,2)
        img(1:ringRef(fml),fml) = backgroundVal/255;
    end
    fileName = cat(2,fileName,'_',num2str(ringSize),'degRing');
end

img = imresize(img,[scaleVal,radiusCt],'method','bilinear');
 %imshow(img)

eleScale = height;%Determines resolution of undistorted image at the cost of speed
aziScale = width;

imgCell = cell(radiusCt,1);
for iterI = 1:radiusCt
    imgCell{iterI} = imresize(uint8(repmat(img(:,iterI),1,smlSide).*backgroundVal),[eleScale aziScale]);
%    imshow(imgCell{iterI})
%    drawnow
end

% imshow(img)
imgReset = cat(3,imgCell{1},imgCell{1},imgCell{1}).*0+255;

frmCt = size(stimDiameterReference,2);
stimRefImageWA = uint8(cat(3,zeros(5)+10,zeros(5)+255,zeros(5)+255));
stimRefImageWB = uint8(cat(3,zeros(5)+255,zeros(5)+10,zeros(5)+10));
stimRefImCell = {stimRefImageWA,stimRefImageWB};
stimRefRefs = repmat([1 2]',ceil(frmCt/2),1);
stimRefRefs = stimRefRefs(:);
imgtex = cell(frmCt,1);
stimtex = cell(frmCt,1);
imgCat = cell(frmCt,1);
stimRefRGB = [2 3 1];%%%%%%%%%%%% Dont change this !!!!!!!!!!!!
if pez5==1
    stimRefRGB = [1 2 3];
end

for iterPrep = 1:frmCt
    
%     imgCelltrans = cell(frmCt,1);
%     imgCell{stimDiameterReference(stimRefRGB(2),iterPrep);
    
    imgCat{iterPrep} = cat(3,imgCell{stimDiameterReference(stimRefRGB(1),iterPrep)},...
        imgCell{stimDiameterReference(stimRefRGB(2),iterPrep)},...
        imgCell{stimDiameterReference(stimRefRGB(3),iterPrep)});
end
if strcmp(prefixStr,'constSize')
    imgFin = imgReset;
else
    imgFin = cat(3,imgCell{stimDiameterReference(3,iterPrep)},...
        imgCell{stimDiameterReference(3,iterPrep)},imgCell{stimDiameterReference(3,iterPrep)});
end
if strcmp(prefixStr,'testing')
    imgReset = imgFin;
end

%Wall Setup
pixPerDeg = width/360;
stripe_width_pix = 2*round(stripe_width_deg * pixPerDeg/2);
center_width_pix = width/2;
pixPerDeg_el = height/180;
stripe_height_pix = 2*round(stripe_height_deg * pixPerDeg_el/2);
center_height_pix = height/2;
min_height = center_height_pix - stripe_height_pix/2;
max_height = center_height_pix + stripe_height_pix/2;
min_width = center_width_pix - stripe_width_pix/2;
max_width = center_width_pix + stripe_width_pix/2;
if min_height == 0
    min_height = 1;
end

eleValWall = stripe_elevation_center+90;
aziValWall = stripe_azimuth_center;

wall = 255*ones(height,width);

%Have azimuth pixels wrap around if necessary
if min_width < 1
    min_width = width + min_width;
    corr_max_width = width;
    corr_min_width = 1;
    wall(min_height:max_height,corr_min_width:max_width) = 0;
    wall(min_height:max_height,min_width:corr_max_width) = 0;
elseif max_width > width
    corr_min_width = 1;
    max_width = max_width - width;
    corr_max_width = width;
    wall(min_height:max_height,min_width:corr_max_width) = 0;
    wall(min_height:max_height,corr_min_width:max_width) = 0;
else
    wall(min_height:max_height,min_width:max_width) = 0;
end
wall = uint8(flipud(wall));

imgWall = cell(frmCt,1);

walltrans = zeros(size(wall));
[ind1,ind2] = find(wall(:,:)==0);
for i=1:length(ind1)
walltrans(ind1(i),ind2(i)) = 255;
walltrans(min(ind1):min(ind1)+1,ind2(i)) = 0;
walltrans(ind1(i),min_width:min_width+4) = 0;
walltrans(ind1(i),max_width-4:max_width) = 0;
end
blank = zeros(size(wall))+255;



for iterPrep = 1:frmCt
    imgWall{iterPrep} = cat(3,wall(:,:),wall(:,:),wall(:,:),walltrans(:,:));
end


if use_stripe_time
    stripe_frames = stripe_time/(stimTimeStep*3);
    stimulusStruct = struct('stimTotalDuration',stimTotalDuration,'imgReset',imgReset,...
        'imgFin',imgFin,'eleScale',eleScale,'aziScale',aziScale,'eleValWall',eleValWall,'aziValWall',aziValWall,'wallframes',stripe_frames);
else
    stimulusStruct = struct('stimTotalDuration',stimTotalDuration,'imgReset',imgReset,...
        'imgFin',imgFin,'eleScale',eleScale,'aziScale',aziScale,'eleValWall',eleValWall,'aziValWall',aziValWall);
end
stimulusStruct(1).imgCell = imgCat;
stimulusStruct(1).imgWall = imgWall;
stimulusStruct(1).flipReference = flipReference;

if pez5==1
    save(fullfile('\\locker-smb.engram.rc.zi.columbia.edu\card-locker\hhmiData\dm11\cardlab\pez3000_variables\visual_stimuli_pez3005',fileName),'stimulusStruct','-v7.3')
else
    save(fullfile('\\locker-smb.engram.rc.zi.columbia.edu\card-locker\hhmiData\dm11\cardlab\pez3000_variables\visual_stimuli',fileName),'stimulusStruct','-v7.3')
end


%% %%% Run only once, first

%%%%% computer and directory variables and information
op_sys = system_dependent('getos');
    dm11Dir = '\\locker-smb.engram.rc.zi.columbia.edu\card-locker\hhmiData\dm11\cardlab\';
if ~exist(dm11Dir,'file')
    error('dm11 access failure')
end

AssertOpenGL;
Screen('Preference','Verbosity',2);
Screen('Preference', 'SkipSyncTests', 1);
comp_name = 'pez3001';%pez1
varDest = fullfile(dm11Dir,'pez3000_variables');
varName = [comp_name '_stimuliVars.mat'];
varPath = fullfile(varDest,varName);
load(varPath)
% Open onscreen window with black background clear color:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
screenid = 0;% 0 or 1 on mac, 1 or 2 on PC
xOffset = 2000;%offset form the left. '0' is far left
yOffset = 100;%offset from the top. '0' is the top
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set the PTB to balance brightness post-processing
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask','General','UseVirtualFramebuffer');
PsychImaging('AddTask','AllViews','DisplayColorCorrection','GainMatrix');
height = 768;
width = 1024;
hH = round(height/2);
hW = round(width/2);
win = PsychImaging('OpenWindow',screenid,[],[xOffset yOffset width+xOffset height+yOffset]);
% gainMatrixBrighter(gainMatrixBrighter < max(gainMatrixBrighter(:))) = max(gainMatrixBrighter(:));
% sheight = 1;
% eheight = height/3;
% swidth = width/3;
% ewidth = 2*width/3;
% gainMatrixBrighter(sheight:eheight,swidth:ewidth,:)=0; %TODO update pixels in terms of angles
PsychColorCorrection('SetGainMatrix',win,gainMatrixBrighter,[],0);
% Create warpoperator for application of the image warp:
winRect = Screen('Rect',win);
warpoperator = CreateGLOperator(win);
Wallwarpoperator = CreateGLOperator(win);
warpmap = AddImageWarpToGLOperator(warpoperator, winRect);
Wallwarpmap = AddImageWarpToGLOperator(Wallwarpoperator, winRect);
ifi = [];
stimStruct = struct('stimEleForProc',stimEleForProc,'stimAziForProc',...
    stimAziForProc,'win',win,'warpmap',warpmap,'Wallwarpmap',Wallwarpmap,'warpoperator',...
    warpoperator,'Wallwarpoperator',Wallwarpoperator,'stimRefROI',stimRefROI,'ifi',ifi,'vertLinesIm',vertLinesIm);

%% %%% Establish variables needed in stimulus presentation
stimEleForProc = stimStruct.stimEleForProc;
stimAziForProc = stimStruct.stimAziForProc;
win = stimStruct.win;
warpmap = stimStruct.warpmap;
Wallwarpmap = stimStruct.Wallwarpmap;
warpoperator = stimStruct.warpoperator;
Wallwarpoperator = stimStruct.Wallwarpoperator;
stimRefROI = stimStruct.stimRefROI;

eleScale = height;%Determines resolution of undistorted image at the cost of speed
aziScale = width;

eleCrop = imcrop(stimEleForProc,[hW-hH+1 1 height height]);
aziCrop = imcrop(stimAziForProc,[hW-hH+1 1 height height]);
aziSmall = imresize(aziCrop,[eleScale aziScale]);
eleSmall = imresize(eleCrop,[eleScale aziScale]);

%
winRect = Screen('Rect',win);
drawDest = CenterRect([0 0 height height],winRect);
warpimage = zeros(eleScale,aziScale,3);
Wallwarpimage = zeros(eleScale,aziScale,3);

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

%%
demoIm = repmat((0:255),numel(0:255),1);
img = cat(3,imresize(demoIm,[eleScale aziScale]),...
    imresize(rot90(demoIm,3),[eleScale aziScale]),...
    imresize(demoIm*0+255,[eleScale aziScale]));
imgReset = uint8(img);

% imgReset(1:round(eleScale/8),:,:) = 0;
% imgReset(1:round(eleScale/4),:,:) = 0;
% imgReset(1:round(eleScale/2),:,:) = 0;

imshow(imgReset)
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

% for iterStim = 1:frmCt
%     warpedtex = Screen('TransformTexture',imgtex{iterStim},warpoperator,warpmap,warpedtex);
%     Screen('DrawTexture',win,warpedtex,[],drawDest);
%     Screen('DrawTexture',win,stimtex{iterStim},[],stimRefROI);
%     Screen('Flip',win);
% end

%%
%addpath('C:\Users\morrowc2\Documents\Photron_flyPez3000')
stimStruct = initializeVisualStimulusGeneralUDP_brighter;
% fileName = 'spiral_5to90_lv40_forward.mat';
% fileName = 'constVelo_0to90_100degPerSec_blackonwhite';
%fileName = 'stripe_1_15W_180p0H_12A_1Hz_8s';
[stimTrigStruct] = initializeFramesFromFileUDP(stimStruct,fileName);
stimTrigStruct.eleVal = 45;
stimTrigStruct.aziVal =45;
% imgReset = stimTrigStruct.imgCell{1};
%%
[missedFrms,whiteCt] = presentGeneralStimulusUDP_flipRef(stimTrigStruct);
