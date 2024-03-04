function [stimTrigStruct,visParams] = initializeBlackDiskOnWhiteCalibration(stimStruct,visParams)
%initializeBlackDiskOnWhite Prepares a black disk on white background for
%optimal presentation upon triggering

% L/V is in milliseconds and represents the time it takes for an
% approaching object at a constant velocity to expand in the visual field
% from 90 degrees to 180 degrees.

ellovervee = visParams.ellovervee;
initStimSize = visParams.radiusbegin;%in degrees
finalStimSize = visParams.radiusend;%in degrees
% %%
% ellovervee = 180;
% initStimSize = 10;
% finalStimSize = 180;

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
% The following is done because the projector displays R then B then G
% stimThetaRefs = [stimThetaRefs(3,:);stimThetaRefs(1,:);stimThetaRefs(2,:)];
stimThetaRefs = rad2deg(stimThetaRefs);
% plot(rad2deg(stimThetaVector))

%%%%% Establish variables needed in stimulus presentation
stimEleForProc = stimStruct.stimEleForProc;
stimAziForProc = stimStruct.stimAziForProc;
win = stimStruct.win;
warpmap = stimStruct.warpmap;
warpoperator = stimStruct.warpoperator;
stimRefROI = stimStruct.stimRefROI;
ifi = stimStruct.ifi;
% vertLinesIm = stimStruct.vertLinesIm;

winRect = Screen('Rect',win);
% winRect = [0 0 768 768];
height = winRect(4);
width = winRect(3);
hH = round(height/2);
hW = round(width/2);

smlSide = 720;%Determines resolution of undistorted image at the cost of speed

drawDest = CenterRect([0 0 height height],winRect);
warpimage = zeros(smlSide,smlSide,3);

eleCrop = imcrop(stimEleForProc,[hW-hH+1 1 height height]);
aziCrop = imcrop(stimAziForProc,[hW-hH+1 1 height height]);
aziSmall = imresize(aziCrop,[smlSide smlSide],'nearest');
eleSmall = imresize(eleCrop,[smlSide smlSide]);

scaleVal = 360;
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
img = imresize(img,[scaleVal*2,radiusCt]);

% %%%%%%% uncomment the following to add latitudinal lines to the background
% imgLines = ones(size(img));
% degOpts = linspace(1,360,size(imgLines,1));
% degTargets = (0:20:360);
% for iterLats = 1:numel(degTargets)
%     latA = degTargets(iterLats);
%     [~,degRow] = min(abs(degOpts-latA));
%     imgLines(degRow,:) = 0;
% %     imshow(img,'initialmagnification',33)
% %     uiwait(gcf)
% end
% imgLines = imerode(imgLines,strel('disk',3));
% % imshow(imgLines(:,1:500))
% img = min(img,imgLines);
% %%%%%%%%%%

img = imfilter(img,fspecial('average',[4 4]),'replicate');
% img = abs(img-1);
% imshow(img(:,1:500))

whiteVal = 255;%0-255
imgCell = cell(radiusCt,1);
for iterI = 1:radiusCt
    imgCell{iterI} = uint8(repmat(img(:,iterI),1,smlSide).*whiteVal);
end
% imshow(img)

imgForTex = repmat(imgCell{1},[1 1 3]);
imgtexDummy = Screen('MakeTexture',win,imgForTex);

% Determine where to place the "warp map":
imgRect = Screen('Rect',imgtexDummy);
refRect = CenterRect(imgRect,winRect);
xoffset = refRect(RectLeft);
yoffset = refRect(RectTop);
[xp, yp] = RectCenter(winRect);
xp = xp-xoffset;
yp = yp+yoffset;%dunno why this works, from ImageWarpingDemo (WRW)
warpDest = CenterRectOnPoint(imgRect,xp,yp);


imgReset = cat(3,imgCell{1},imgCell{1},imgCell{1});
imgtexReset = Screen('MakeTexture',win,imgReset);
stimRefImageB = uint8(zeros(3,3,3));
stimRefTexB = Screen('MakeTexture',win,stimRefImageB);
% Apply image warpmap to image:
warpedtex = Screen('TransformTexture',imgtexReset,warpoperator,warpmap,[]);
% Draw and show the warped image:
Screen('DrawTexture',win,warpedtex,[],drawDest);
Screen('DrawTexture',win,stimRefTexB,[],stimRefROI);
Screen('Flip',win);
Screen('Close',warpedtex);

frmCt = size(stimThetaRefs,2);
stimRefImageWA = uint8(cat(3,zeros(5)+10,zeros(5)+255,zeros(5)+255));
stimRefImageWB = uint8(cat(3,zeros(5)+255,zeros(5)+10,zeros(5)+10));
stimRefImCell = {stimRefImageWA,stimRefImageWB};
stimRefRefs = repmat([1 2]',ceil(frmCt/2),1);
stimRefRefs = stimRefRefs(:);
whiteCt = 0;
imgtex = cell(frmCt,1);
stimtex = cell(frmCt,1);
stimRefRGB = [2 3 1];
for iterPrep = 1:frmCt
    imgCat = cat(3,imgCell{stimThetaRefs(stimRefRGB(1),iterPrep)},...
        imgCell{stimThetaRefs(stimRefRGB(2),iterPrep)},...
        imgCell{stimThetaRefs(stimRefRGB(3),iterPrep)});
    imgtex{iterPrep} = Screen('MakeTexture',win,imgCat);
    stimIm = stimRefImCell{stimRefRefs(iterPrep)};
    stimtex{iterPrep} = Screen('MakeTexture',win,stimIm);
    if stimRefRefs(iterPrep) == 1
        whiteCt = whiteCt+2;
    else
        whiteCt = whiteCt+1;
    end
end
imgCat = cat(3,imgCell{stimThetaRefs(3,iterPrep)},...
    imgCell{stimThetaRefs(3,iterPrep)},imgCell{stimThetaRefs(3,iterPrep)});
imgtexFin = Screen('MakeTexture',win,imgCat);

stimTrigStruct = struct('stimTotalDuration',stimTotalDuration,'drawDest',...
    drawDest,'warpimage',warpimage,'aziSmall',aziSmall,'eleSmall',eleSmall,...
    'stimThetaRefs',stimThetaRefs,'eleOff',eleOff,'warpDest',warpDest,...
    'win',win,'warpmap',warpmap,'warpoperator',warpoperator,...
    'scaleVal',scaleVal,'stimRefROI',stimRefROI,'ifi',ifi,...
    'stimThetaVector',stimThetaVector,'whiteCt',whiteCt,...
    'imgtexReset',imgtexReset,'imgtexFin',imgtexFin,...
    'stimRefTexB',stimRefTexB,'stimRadiusVector',stimRadiusVector);
stimTrigStruct(1).imgCell = imgCell;
stimTrigStruct(1).imgtex = imgtex;
stimTrigStruct(1).stimtex = stimtex;
end

