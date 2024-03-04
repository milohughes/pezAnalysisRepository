
function projectorCalibration3000_diode
%% projectorCalibrate3000 Calibrates the projector in preparation for stimulus
%   The inputs are...


AssertOpenGL;
calibrateOp = 3;
shade2 = false;
varDest = 'C:\Users\cardlab\Documents\MATLAB\Photron_MATLAB\WRW_Module\Sample_R2013a_64bit_withDLLs\visual_stimuli\stimuliVars.mat';

% Setup Screen
% Open onscreen window with black background clear color:
% if ~isempty(Screen('Windows')),Screen('CloseAll'),end

% Select display with max id for our onscreen window:
screenidList = Screen('Screens');
for iterL = screenidList
    [width,~] = Screen('WindowSize', iterL);
    if width == 1024 || width == 1280
        screenid = iterL;
    end
end
[width,height]=Screen('WindowSize', screenid);%1024x768, old was 1280x720
if width ~= 1024
    Screen('Resolution',screenid,1024,768,120)
    [width, height]=Screen('WindowSize', screenid);
end
hW = round(width/2);
hH = round(height/2);
initIm = zeros(height-2,width-2);
initIm = padarray(initIm,[1 1],1);
initIm(hH:hH+1,:) = 1;
initIm(:,hW:hW+1) = 1;
initIm(initIm ~= 1 ) = 1;%white screen!!
calibIm = repmat(uint8(initIm.*255),[1 1 3]);

if calibrateOp == 1
    if isempty(Screen('Windows'))
        window = Screen(screenid,'OpenWindow');
    else
        window = Screen('Windows');
    end
    Screen(window, 'PutImage', calibIm);
    Screen(window, 'Flip');
    return
end

% Measure the distance from the top of the mirror plane to the lens
atMirPlane2projector = 34;%in 'inches'

% First, ensure the longitudinal lines are aligned
% using the screws manipulating the projector

% Adjust the following until the top ring at the bottom
% of the projected image is near the edge of the mirror
zoomTheta = 20.1;%in degrees

% Adjust the following until the rings line up at the 
% bottom of the projected image
%%%% Orig dome
% sphDropDiff = 0.3;%BEST USED TO ADJUST SCALE OF LATITUDE
% sphSizeDiff = -0.085;%adjusts top projection up and down

sphDropDiff = 0.2;%BEST USED TO ADJUST SCALE OF LATITUDE - 0 is normal
sphSizeDiff = -0.07;%adjusts top projection up and down - 0 is normal

hypSkewTB = 0.012;
hypSkewLR = 0.015;
thSkewTB = 0.0;
thSkewLR = 0.0;%start at 0.1.  it's 'rocking' left/right

% Adjust the following until the sides align
% whRatioAdjust = 0.991; % orig dome
whRatioAdjust = 0.99;



% Adjust the following until the top of the projected
% image is near the top of the mirror and aligned
% should stay between 0.15 and 0.25
wallFbot = .15;

topThreshFactor = 1.005;%don't change this

%%%%% Conversion functions, anonymous
in2mm = @(x) x.*25.4;%inch to mm conversion
mm2in = @(x) x./25.4;
deg2rad = @(x) x*(pi/180);
rad2deg = @(x) x./(pi/180);

%%%%% Variables from specs (these values shouldn't change)
% adds distance from lens to theoretical point source %
atMirPlane2projector = atMirPlane2projector+((0.25)/tan(deg2rad(zoomTheta/2)))*2;
% accounts for distance of dome center below mirror plane %
distOfSphereBelow = 0.710+sphDropDiff;
atMid_proj2wall = in2mm(atMirPlane2projector+distOfSphereBelow);
% Radii %
mirTheta = deg2rad(42.7);%angle of the mirror
minTheta = deg2rad(-31);%minimum elevation to be projected onto the dome
sphR = in2mm(3+sphSizeDiff);%radius of sphere in2mm
mirRtop = in2mm(11.955/2-0.09);%radius from center axis to top of mirror
% radius from center axis at sphere center to mirror %
mirRcntr = mirRtop-in2mm(tan(mirTheta)*(distOfSphereBelow-0.083));

%%%%% Variables derived from measurements
onWall_bot2top = tan(deg2rad(zoomTheta/2))*atMid_proj2wall*2;
onWall_floor2bot = wallFbot*onWall_bot2top;
onWall_floor2top = (onWall_bot2top+onWall_floor2bot);
onWall_floor2mid = (onWall_floor2bot+0.5*(onWall_floor2top-onWall_floor2bot))*1;%%%%%had been reducing this
onFloor_proj2wall = sqrt(atMid_proj2wall^2-onWall_floor2mid^2)*1.0;%%%%%



%%%%% Minor adjustments only!!! %%%%%
segTopFactor = 0;%skews the top half of the screen
segBotFactor = -0;%skews the bottom half of the screen
segShiftFactor = -0;
segStretchFactor = 1.0;
segSkewFactor = 1.0;
segSkewVector = (linspace(0,1,height+1).^segSkewFactor-linspace(0,1,height+1)).*(-1)+1;
thetaMidFactor = 1.0;%rocks top v bottom elevation lines and shifts

onWallSegments = (linspace(onWall_floor2top+segTopFactor,...
    onWall_floor2bot+segBotFactor,...
    height+1)+segShiftFactor).*segSkewVector.*segStretchFactor;%%
onWallThetas = atan(onWallSegments./onFloor_proj2wall);
thetaF2M = atan(onWall_floor2mid/onFloor_proj2wall)*thetaMidFactor;
axisThetas = (onWallThetas-thetaF2M).*1;
axisSegments = tan(axisThetas).*atMid_proj2wall;
pixY = axisSegments(1:end-1)+diff(axisSegments)./2;
pixYplane = repmat(pixY(:),1,width).*1;
% pixY(1)+pixY(end)

onWall_mid2side = onWall_bot2top*(width/height)/2*whRatioAdjust;%%
atMidline_proj2wall = sqrt(onFloor_proj2wall^2+onWallSegments.^2);
thetas_mid2sides = atan(onWall_mid2side./atMidline_proj2wall);
atPlane_proj2mids = sqrt(atMid_proj2wall^2+axisSegments.^2);
mid2sides_top2bot = tan(thetas_mid2sides).*atPlane_proj2mids;
mid2sides_top2bot = mid2sides_top2bot(1:end-1)+diff(mid2sides_top2bot)./2;
mid2sides_factors = repmat(linspace(0,1,hW+1),height,1);
mid2sides_hPlaneSegs = repmat(mid2sides_top2bot(:),1,hW+1).*mid2sides_factors;
pixXplaneHalf = diff(mid2sides_hPlaneSegs,[],2)./2+mid2sides_hPlaneSegs(:,1:end-1);
pixXplane = ([fliplr(pixXplaneHalf).*(-1) pixXplaneHalf]);


% The following equation calculates the hypotenuse from the center to each
% pixel of the array, given cumulative sums in x and y from center
hypPlane = sqrt(pixXplane.^2+pixYplane.^2).*1.0;
hypSkewVecTB = repmat(linspace(0.5-hypSkewTB,0.5+hypSkewTB,height)',1,width);
hypSkewVecLR = repmat(linspace(0.5-hypSkewLR,0.5+hypSkewLR,width),height,1);
hypPlane = hypPlane.*(hypSkewVecTB+hypSkewVecLR);


% The following then subtracts the hypotenuse of the lens from that of the
% plane at the top of the mirror ('opposite' leg) and calculates the theta
% from origin for each pixel, knowing the distance lens is above plane
origTheta = atan(hypPlane./atMid_proj2wall);
thSkewVecTB = repmat(linspace(0.5-thSkewTB,0.5+thSkewTB,height)',1,width);
thSkewVecLR = repmat(linspace(0.5-thSkewLR,0.5+thSkewLR,width),height,1);
origTheta = origTheta.*(thSkewVecTB+thSkewVecLR).*1.0;


%%%%% Determine the elevation at which the reflected rays intercept the
%%%%% dome, in degrees above (+) or below (-) the equator
mirPlane = hypPlane;
outerRingMir = rangesearch(mirPlane(:),mirRtop*topThreshFactor,1);
mirPlane(hypPlane > mirRtop*topThreshFactor) = NaN; %test: set ring of dots at max hyps around center
hypA = (mirPlane-mirRcntr);
oppA = sin(mirTheta).*hypA;
hypB = oppA./cos(mirTheta-origTheta);
adjB = sin(origTheta).*hypB;
oppC = cos(origTheta).*hypB;
thetaDepart = pi/2-2*mirTheta+origTheta;

mirPlane = mirPlane-adjB;
oppD = tan(thetaDepart).*mirPlane;
oppE = cos(thetaDepart).*(oppD+oppC);
oppE(abs(oppE) >= sphR) = NaN;
thetaE = asin(oppE./sphR);
eleFrmMir = thetaE-thetaDepart;
stimEleFrmMir = eleFrmMir;
eleFrmMir(eleFrmMir < minTheta) = NaN;
stimEleFrmMir(stimEleFrmMir < deg2rad(-25)) = 0;
stimEleFrmMir(isnan(stimEleFrmMir)) = 0;

%%%%% Determine the elevation at which the central rays intercept the dome,
%%%%% in degrees above the equator.  90 degrees is special, Inf using this
%%%%% method.  Set the center pixel manually (where origTheta=0, oppF=0)

adjT = cos(origTheta).*hypPlane;
adjT(abs(adjT) >= sphR) = NaN;
eleFrmTop = acos(adjT./sphR)+origTheta;

stimEleFrmTop = eleFrmTop;
stimEleFrmTop(stimEleFrmTop < deg2rad(0)) = 0;
stimEleFrmTop(isnan(stimEleFrmTop)) = 0;
stimEleForProc = stimEleFrmTop+stimEleFrmMir;

fadeSpan = deg2rad(5);
mirMaxEle = min(eleFrmMir(outerRingMir{:}));
topThresh = mirMaxEle-fadeSpan;
eleFrmTop(eleFrmTop <= topThresh) = NaN;
topMask = false(height,width);
topMask(~isnan(eleFrmTop)) = true;

elePlane = eleFrmMir;
elePlane(topMask) = eleFrmTop(topMask);

aziFull = atan2(pixYplane,pixXplane);

aziFrmTop = aziFull;
aziFrmMir = aziFull;
aziFull = aziFrmMir;
aziFull(topMask) = aziFrmTop(topMask);
stimAziForProc = aziFull;

aziFrmTop(~topMask) = NaN;
aziFrmMir(isnan(eleFrmMir)) = NaN;

aziPlane = aziFull;
aziPlane(isnan(elePlane)) = NaN;

%
% sphAzi = aziPlane(1:10:end,:);
% sphEle = elePlane(1:10:end,:);
% sphAzi = sphAzi(:,1:10:end);
% sphEle = sphEle(:,1:10:end);
% [x,y,z] = sph2cart(sphAzi,sphEle,300);
% surf(x,y,z)

hXeleVec = (-30:90);
hXaziVec = (-180:180);
hXw = numel(hXaziVec);
hXh = numel(hXeleVec);
hXele = repmat(hXeleVec(:),1,hXw);
hXazi = repmat(hXaziVec,hXh,1);
hVal = zeros(hXh,hXw);
lats = round(rad2deg([mirMaxEle topThresh*1.01]));
% lats = round(linspace(lats(2),lats(1),3));
% lats = [lats -30 0 90 80 70 60 50 40 30 20];
lats = [lats -30 0 90 80 70 60 50];
% lats = (-30:10:90);
latsMat = repmat(lats,hXh,1);
latsLutMat = repmat(hXeleVec(:),1,numel(lats));
[~,latNdx] = min(abs(latsLutMat-latsMat));
longs = [-180 -90 0 90 180];
% longs = (-180:10:180);
longsMat = repmat(longs,hXw,1);
longsLutMat = repmat(hXaziVec(:),1,numel(longs));
[~,longNdx] = min(abs(longsLutMat-longsMat));
hVal(latNdx,:) = 1;
blankVals = (1:8:hXw);
hVal(:,blankVals) = 0;
hVal(:,blankVals(1:end-1)+1) = 0;
hVal(:,blankVals(1:end-1)+2) = 0;
hVal(:,blankVals(1:end-1)+3) = 0;
hVal(:,longNdx) = 1;
VqA = griddata(deg2rad(hXazi),deg2rad(hXele),hVal,aziPlane,eleFrmMir);
hVal = zeros(hXh,hXw);
hVal(latNdx,:) = 1;
blankVals = (1:8:hXw);
hVal(:,blankVals(1:end-1)+4) = 0;
hVal(:,blankVals(1:end-1)+5) = 0;
hVal(:,blankVals(1:end-1)+6) = 0;
hVal(:,blankVals(1:end-1)+7) = 0;
hVal(:,longNdx) = 1;
VqB = griddata(deg2rad(hXazi),deg2rad(hXele),hVal,aziPlane,eleFrmTop,'natural');

stimRef = ones(height,width);
stimRefROI = [92 410 125 442];
stimRef(1:stimRefROI(2),:) = 0;
stimRef(stimRefROI(4):end,:) = 0;
stimRef(:,1:stimRefROI(1)) = 0;
stimRef(:,stimRefROI(3):end) = 0;

Vq = max(VqA,VqB);
Vq(isnan(Vq)) = 0;
Vq = Vq+stimRef;

if shade2 == true
topCount = 40;
aziCount = 40;
topC = linspace(topThresh,pi/2,topCount+1);
topC = topC(1:end-1)+diff(topC)./2;
aziC = linspace(-pi,pi,aziCount+1);
aziC = aziC(1:end-1)+diff(aziC)./2;
topCenters = {topC,aziC};
topDensity = hist3([eleFrmTop(:) aziFrmTop(:)],topCenters);
topDensity = topDensity./cos(repmat(topCenters{1}(:),1,aziCount));
[~,top20] = min(abs(topC-deg2rad(90-20)));
topDensity(top20:end,:) = repmat(mean(topDensity(top20:end,:),2),1,aziCount);
[~,top10] = min(abs(topC-deg2rad(90-20)));
topDensity(top10:end,:) = repmat(topDensity(top10,:),size(topDensity,1)-top10+1,1);

botCount = 40;
botC = linspace(minTheta,mirMaxEle,botCount+1);
botC = botC(1:end-1)+diff(botC)./2;
botCenters = {botC,aziC};
botDensity = hist3([eleFrmMir(:),aziFrmMir(:)],botCenters);
botDensity = botDensity./cos(repmat(botCenters{1}(:),1,aziCount));

topDensity = flipud(topDensity);
botDensity = flipud(botDensity);
rangeD = prctile([topDensity(:);botDensity(:)],99);
topFactor = (topDensity./rangeD).^(-1);
botFactor = (botDensity./rangeD).^(-1);
topFactor = imresize(topFactor,[90-rad2deg(topThresh),360]);
botFactor = imresize(botFactor,[rad2deg(mirMaxEle-minTheta),360]);

rangeF = prctile([topFactor(:);botFactor(:)],99);
topFactor = topFactor./rangeF;
botFactor = botFactor./rangeF;
filtH = fspecial('average',[5 5]);
topFactor = imfilter(topFactor,filtH,'replicate');
botFactor = imfilter(botFactor,filtH,'replicate');
% mesh([topFactor;botFactor])

topDegCover = size(topFactor,1);
eleMat = deg2rad(repmat(linspace(90-topDegCover+1,90,topDegCover)',1,360));
aziMat = deg2rad(repmat(linspace(-180,180,360),topDegCover,1));
Finterp = scatteredInterpolant(eleMat(:),aziMat(:),flipud(topFactor(:)));
vX = Finterp([eleFrmTop(:),aziFrmTop(:)]);
shaderTop = reshape(vX,height,width);
shaderTop(isnan(shaderTop)) = 0;

botDegCover = size(botFactor,1);
eleMat = repmat(linspace(minTheta,mirMaxEle,botDegCover)',1,360);
aziMat = deg2rad(repmat(linspace(-180,180,360),botDegCover,1));
Finterp = scatteredInterpolant(eleMat(:),aziMat(:),flipud(botFactor(:)));
vX = Finterp([eleFrmMir(:),aziFrmMir(:)]);
shaderBot = reshape(vX,height,width);
shaderBot(isnan(shaderBot)) = 0;
shaderMaster = (shaderTop+shaderBot);
calibIm = repmat(uint8(Vq.*max(shaderMaster,stimRef).*255),[1 1 3]);
else
    calibIm = repmat(uint8(Vq.*255),[1 1 3]);
end

if calibrateOp == 2
    
    if isempty(Screen('Windows'))
        window = Screen(screenid,'OpenWindow');
    else
        window = Screen('Windows');
    end
    Screen(window, 'PutImage', calibIm);
    Screen(window, 'Flip');
    return
end

topCount = 40;
aziCount = 40;
topC = linspace(topThresh,pi/2,topCount+1);
topC = topC(1:end-1)+diff(topC)./2;
aziC = linspace(-pi,pi,aziCount+1);
aziC = aziC(1:end-1)+diff(aziC)./2;
topCenters = {topC,aziC};
topDensity = hist3([eleFrmTop(:) aziFrmTop(:)],topCenters);
topDensity = topDensity./cos(repmat(topCenters{1}(:),1,aziCount));
[~,top20] = min(abs(topC-deg2rad(90-20)));
topDensity(top20:end,:) = repmat(mean(topDensity(top20:end,:),2),1,aziCount);
[~,top10] = min(abs(topC-deg2rad(90-20)));
topDensity(top10:end,:) = repmat(topDensity(top10,:),size(topDensity,1)-top10+1,1);

botCount = 40;
botC = linspace(minTheta,mirMaxEle,botCount+1);
botC = botC(1:end-1)+diff(botC)./2;
botCenters = {botC,aziC};
botDensity = hist3([eleFrmMir(:),aziFrmMir(:)],botCenters);
botDensity = botDensity./cos(repmat(botCenters{1}(:),1,aziCount));

% figure,
% h1 = subplot(1,2,1);
% bar3(topDensity)
% topTicksX = (1:4:numel(topCenters{2}));
% topTicksY = (1:4:numel(topCenters{1}));
% set(h1,'XTick',topTicksX,'XTickLabel',num2str(topCenters{2}(topTicksX)',2),...
%     'YTick',topTicksY,'YTickLabel',num2str(topCenters{1}(topTicksY)',2))
% h2 = subplot(1,2,2);
% bar3(botDensity)
% botTicksX = (1:4:numel(botCenters{2}));
% botTicksY = (1:4:numel(botCenters{1}));
% set(h2,'XTick',botTicksX,'XTickLabel',num2str(botCenters{2}(botTicksX)',2),...
%     'YTick',botTicksY,'YTickLabel',num2str(botCenters{1}(botTicksY)',2))

topDensity = flipud(topDensity);
botDensity = flipud(botDensity);
rangeD = prctile([topDensity(:);botDensity(:)],99);
topFactor = (topDensity./rangeD).^(-1);
botFactor = (botDensity./rangeD).^(-1);
topFactor = imresize(topFactor,[90-rad2deg(topThresh),360]);
botFactor = imresize(botFactor,[rad2deg(mirMaxEle-minTheta),360]);
fadeSeq = linspace(0,1,rad2deg(fadeSpan)+2);
fadeSeq = repmat(fadeSeq(2:end-1)',1,360);
topFader = topFactor(end-rad2deg(fadeSpan)+1:end,:).*flipud(fadeSeq);
topFactor(end-rad2deg(fadeSpan)+1:end,:) = topFader;
botFader = botFactor(1:rad2deg(fadeSpan),:).*fadeSeq;
botFactor(1:rad2deg(fadeSpan),:) = botFader;
% mesh([topFactor;botFactor])

rangeF = prctile([topFactor(:);botFactor(:)],99);
topFactor = topFactor./rangeF;
botFactor = botFactor./rangeF;
filtH = fspecial('average',[5 5]);
topFactor = imfilter(topFactor,filtH,'replicate');
botFactor = imfilter(botFactor,filtH,'replicate');
% mesh([topFactor;botFactor])

topDegCover = size(topFactor,1);
eleMat = deg2rad(repmat(linspace(90-topDegCover+1,90,topDegCover)',1,360));
aziMat = deg2rad(repmat(linspace(-180,180,360),topDegCover,1));
Finterp = scatteredInterpolant(eleMat(:),aziMat(:),flipud(topFactor(:)));
vX = Finterp([eleFrmTop(:),aziFrmTop(:)]);
shaderTop = reshape(vX,height,width);
shaderTop(isnan(shaderTop)) = 0;

botDegCover = size(botFactor,1);
eleMat = repmat(linspace(minTheta,mirMaxEle,botDegCover)',1,360);
aziMat = deg2rad(repmat(linspace(-180,180,360),botDegCover,1));
Finterp = scatteredInterpolant(eleMat(:),aziMat(:),flipud(botFactor(:)));
vX = Finterp([eleFrmMir(:),aziFrmMir(:)]);
shaderBot = reshape(vX,height,width);
shaderBot(isnan(shaderBot)) = 0;
shaderMaster = (shaderTop+shaderBot);

% for use in the 'GainMatrix'
gainMatrix = repmat(max(shaderMaster,stimRef),[1 1 3]);
gainMatrix(gainMatrix < 0) = 0;
gainMatrix(gainMatrix > 1) = 1;

save(varDest,'gainMatrix','stimEleForProc','stimAziForProc','stimRefROI','calibIm')

if calibrateOp == 3
    initIm = ones(height,width);
    calibIm = repmat(uint8(initIm.*shaderMaster.*255),[1 1 3]);
%     calibIm = repmat(uint8(Vq.*max(shaderMaster,stimRef).*255),[1 1 3]);
    if isempty(Screen('Windows'))
        window = Screen(screenid,'OpenWindow');
    else
        window = Screen('Windows');
    end
    Screen(window, 'PutImage', calibIm);
    Screen(window, 'Flip');
    
end

