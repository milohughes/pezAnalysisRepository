
function projectorCalibration3000
%% projectorCalibrate3000 Calibrates the projector in preparation for stimulus
%   The inputs are...
set(0,'showhiddenhandles','on')
delete(get(0,'Children'))
clearvars
clc

calibrateOp = 5;

[~, comp_name] = system('hostname');
comp_name = comp_name(1:end-1); %Remove trailing character.

% comp_name = 'peekm-ww3';%pez1
% comp_name = 'cardlab-ww5';%pez2
% comp_name = 'CARDG-WW9';%pez3

[~,userName] = dos('echo %USERNAME%');
userName = userName(1:end-1);
repositoryName = 'Photron_flyPez3000';
varDest = ['C:\Users\' userName '\Documents\' repositoryName '\visual_stimuli'];
varName = [comp_name '_stimuliVars.mat'];
varPath = fullfile(varDest,varName);

% Setup Screen
% Open onscreen window with black background clear color:
% if ~isempty(Screen('Windows')),Screen('CloseAll'),end

AssertOpenGL;
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
% height = 768;
% width = 1024;
hW = round(width/2);
hH = round(height/2);

% computer-specific information
switch comp_name
    case 'peekm-ww3' %stimulus computer no. 1
        scanStatsName = 'photoScanResults_pez3001_greenLED_15degLatitudinalSteps.mat';
        
        % Measure the distance from the top of the mirror plane to the lens
        atMirPlane2projector = 33.25;%in inches
        % Using tailor's measuring tape, empirically determine the 
        % circimference of the dome
        sphereCircumference = 473;%in millimeters
        
        % Adjust the following until the scale of the top projection aligns
        % with the 10mm marks on the measuring tape. Bigger numbers reduce
        % the spacing between the lines.
        zoomTheta = 20;%in degrees
        % Adjust the following until the bottom projection dashed lines
        % align with the two top projection dashed lines.  Bigger numbers
        % make the bottom lines lower.  When the dashed lines align, the
        % solid ones should all line up with the 10-mm marks.  If not,
        % slightly adjust the zoom and try again.
        sphDropDiff = 0.215;
        % Adjust the following until the sides align.  Bigger numbers make
        % the mirror reflection go down on the sides relative to the top
        % reflection.
        whRatioAdjust = 0.99;
        % Position the transition from top-projection to mirror-projection
        % to the edge of the mirror
        topThreshFactor = 1.035;
        %reference flicker window
        stimRefROI = [95 430];%x1 y1 x2 y2 from top,left of screen
        
        % The following are for fine-tuning, needed to skew diagonally.
        % Positive numbers for 'TB' rocks the mirror-reflected ring towards
        % the camera.  Positive numbers for LR rock the mirror reflected
        % ring to the right from the perspective of the camera.
        hypSkewTB = 0.00;
        hypSkewLR = 0.00;
        
        %positive numbers twist top or right
        hypTwistA = 0.09;%right side twist
        hypTwistB = 0.0;%left side twist
        hypTwistC = -0.05;%bottom twist
        hypTwistD = 0.0;%top twist
        
    case 'cardlab-ww5' %stimulus computer no. 2
        scanStatsName = 'photoScanResults_pez3001_greenLED_15degLatitudinalSteps.mat';
        atMirPlane2projector = 33.25;
        sphereCircumference = 482.6;
        zoomTheta = 20;
        sphDropDiff = 0.165;
        topThreshFactor = 1.035;
        whRatioAdjust = 0.989;
        stimRefROI = [92 430];
        hypSkewTB = 0.00;
        hypSkewLR = 0.00;
        
        %positive numbers twist top or right
        hypTwistA = 0.09;%right side twost
        hypTwistB = -0.03;%left side twist
        hypTwistC = 0.0;%bottom twost
        hypTwistD = 0.0;%top twist
        
    case 'CARDG-WW9' %stimulus computer no. 3
        scanStatsName = 'photoScanResults_pez3001_greenLED_15degLatitudinalSteps.mat';
        atMirPlane2projector = 34.4;
        sphereCircumference = 474;
        zoomTheta = 19.08;
        sphDropDiff = 0.245;
        topThreshFactor = 1.033;
        whRatioAdjust = 0.992;
        stimRefROI = [92 433];
        hypSkewTB = 0.00;
        hypSkewLR = 0.000;
        
        %positive numbers twist top or right
        hypTwistA = 0.0;%right side twost
        hypTwistB = 0.05;%left side twist
        hypTwistC = 0.0;%bottom twost
        hypTwistD = 0.0;%top twist

    case 'CARDLAB-WW7' %stimulus computer no. 4
        scanStatsName = 'photoScanResults_pez3001_greenLED_15degLatitudinalSteps.mat';
        atMirPlane2projector = 35.25;
        sphereCircumference = 474;
        zoomTheta = 18.6;
        sphDropDiff = 0.19;
        topThreshFactor = 1.023;
        whRatioAdjust = 0.9845;
        stimRefROI = [85 420];
        hypSkewTB = 0.00;
        hypSkewLR = -0.00;
        
        %positive numbers twist top or right
        hypTwistA = 0.0;%right side twost
        hypTwistB = 0.0;%left side twist
        hypTwistC = 0.0;%bottom twost
        hypTwistD = 0.0;%top twist
    otherwise
end
stimRefROI = [stimRefROI stimRefROI+35];

paramName = [comp_name '_stimuliParams.mat'];
paramPath = fullfile(varDest,paramName);
save(paramPath,'atMirPlane2projector','zoomTheta','sphDropDiff',...
    'sphereCircumference','hypSkewTB','hypSkewLR','whRatioAdjust','stimRefROI')

stimRef = ones(height,width);
stimRef(1:stimRefROI(2),:) = 0;
stimRef(stimRefROI(4):end,:) = 0;
stimRef(:,1:stimRefROI(1)) = 0;
stimRef(:,stimRefROI(3):end) = 0;

initIm = zeros(height-2,width-2);
initIm = padarray(initIm,[1 1],1);
initIm(hH:hH+1,:) = 1;
initIm(:,hW:hW+1) = 1;
crosshairsIm = repmat(uint8((initIm+stimRef).*255),[1 1 3]);
% initIm(initIm ~= 1 ) = 1;%white screen!!

if calibrateOp == 1
    if isempty(Screen('Windows'))
        window = Screen(screenid,'OpenWindow');
    else
        window = Screen('Windows');
    end
    Screen(window,'PutImage',crosshairsIm);
    Screen(window,'Flip');
    return
end

wallFbot = .15;

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
minTheta = deg2rad(-21);%minimum elevation to be projected onto the dome
mirRtop = in2mm(11.955/2-0.09);%radius from center axis to top of mirror
% radius from center axis at sphere center to mirror %
mirRcntr = mirRtop-in2mm(tan(mirTheta)*(distOfSphereBelow-0.083));
sphR = (sphereCircumference/pi)/2;%radius of sphere in mm

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
% hypSkewVecTB = abs(cos(linspace(-pi/2,pi/2,height))-1).*linspace(-hypSkewTB,hypSkewTB,height);
hypSkewVecTB = linspace(-hypSkewTB,hypSkewTB,height);
hypSkewMatTB = repmat(hypSkewVecTB',1,width)+0.5;
% hypSkewVecLR = abs(cos(linspace(-pi/2,pi/2,width))-1).*linspace(-hypSkewLR,hypSkewLR,width);
hypSkewVecLR = linspace(-hypSkewLR,hypSkewLR,width);
hypSkewMatLR = repmat(hypSkewVecLR,height,1)+0.5;
hypPlane = hypPlane.*(hypSkewMatTB+hypSkewMatLR);
%
hypTwistVecA = linspace(-hypTwistA,hypTwistA,height)';
hypTwistMatA = hypTwistVecA*linspace(0,-abs(hypTwistA),width);
hypTwistVecB = linspace(-hypTwistB,hypTwistB,height)';
hypTwistMatB = fliplr(hypTwistVecB*linspace(0,-abs(hypTwistB),width));
hypTwistVecC = linspace(-hypTwistC,hypTwistC,width);
hypTwistMatC = hypTwistVecC'*linspace(0,-abs(hypTwistC),height);
hypTwistVecD = linspace(-hypTwistD,hypTwistD,width);
hypTwistMatD = fliplr(hypTwistVecD'*linspace(0,-abs(hypTwistD),height));
hypTwistPlane = hypTwistMatA+hypTwistMatB+hypTwistMatC'+hypTwistMatD'+1;
hypPlane = hypPlane.*hypTwistPlane;
% figure,imshow(hypTwistMatD',[])
% size(hypTwistMatC)
% max(hypTwistMatC(:))
% min(hypTwistMatC(:))

% figure, imshow(hypSkewMatTB,[])
% plot(hypSkewMatTB(:,1))
% %%
% plot([cos(linspace(-pi/2,0,hH)).*(-1)+2,cos(linspace(0,pi/2,hH))]-1)
% plot(sin(linspace(-pi/2,pi/2,height)))
% figure,plot(cos(linspace(-pi,0,height)))


% The following then subtracts the hypotenuse of the lens from that of the
% plane at the top of the mirror ('opposite' leg) and calculates the theta
% from origin for each pixel, knowing the distance lens is above plane
origTheta = atan(hypPlane./atMid_proj2wall);
% thSkewVecTB = repmat(linspace(0.5-thSkewTB,0.5+thSkewTB,height)',1,width);
% thSkewVecLR = repmat(linspace(0.5-thSkewLR,0.5+thSkewLR,width),height,1);
% origTheta = origTheta.*(thSkewVecTB+thSkewVecLR).*1.0;


%%%%% Determine the elevation at which the reflected rays intercept the
%%%%% dome, in degrees above (+) or below (-) the equator
mirPlane = hypPlane;
outerRingMir = rangesearch(mirPlane(:),mirRtop*topThreshFactor,1);
mirPlane(hypPlane > mirRtop*topThreshFactor*1.1) = NaN; %test: set ring of dots at max hyps around center
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
eleFrmTop(eleFrmTop < topThresh*0.99) = NaN;
topMask = false(height,width);
topMask(eleFrmTop > topThresh*0.99) = true;

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

hXeleVec = (-30:0.5:90);
hXaziVec = (-180:0.5:180);
hXw = numel(hXaziVec);
hXh = numel(hXeleVec);
hXele = repmat(hXeleVec(:),1,hXw);
hXazi = repmat(hXaziVec,hXh,1);

if calibrateOp == 2 || calibrateOp == 3
    hVal = zeros(hXh,hXw);
    if calibrateOp == 2
        lats = (0:10:160);
    else
        lats = 0;
    end
    latsMeet = round(rad2deg([mirMaxEle topThresh]));
    latsMeet = abs(deg2rad(latsMeet)-pi/2).*sphR;
    lats = [lats latsMeet];
    latsMat = repmat(lats,hXh,1);
    latsLutMat = repmat((abs(deg2rad(hXeleVec(:))-pi/2).*sphR),1,numel(lats));
    [~,latNdx] = min(abs(latsLutMat-latsMat));
    hVal(latNdx,:) = 1;
    gapSize = 14;%must be even
    blankVals = (1:gapSize:hXw);
    hXele_mm = abs(deg2rad(hXele)-pi/2).*sphR;
    meetRef = [numel(lats)-1 numel(lats)];
    for iterGap = 1:gapSize/2
        hVal(latNdx(meetRef),blankVals(1:end-1)+iterGap-1) = 0;
    end
    VqA = griddata(deg2rad(hXazi),hXele_mm,hVal,aziPlane,abs(eleFrmMir-pi/2).*sphR);
    hVal = zeros(hXh,hXw);
    hVal(latNdx,:) = 1;
    blankVals = (1:gapSize:hXw);
    for iterGap = (gapSize/2+1):gapSize
        hVal(latNdx(meetRef),blankVals(1:end-1)+iterGap-1) = 0;
    end
    VqB = griddata(deg2rad(hXazi),hXele_mm,hVal,aziPlane,abs(eleFrmTop-pi/2).*sphR);
    Vq = max(VqA,VqB);
    Vq(isnan(Vq)) = 0;
    Vq = Vq+stimRef+initIm;
    calibIm = repmat(uint8(Vq.*255),[1 1 3]);
    if isempty(Screen('Windows'))
        window = Screen(screenid,'OpenWindow');
    else
        window = Screen('Windows');
    end
    Screen(window, 'PutImage', calibIm);
    Screen(window, 'Flip');
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scanStatsDest = fullfile(varDest,scanStatsName);
brightDensitiesDest = fullfile(varDest,'brightDensities.mat');

if exist(scanStatsDest,'file') == 2
    load(scanStatsDest);
    rescanResults = cell2mat(scanStats.scanResults_rescan);
    minD = min(rescanResults(:));
    if exist(brightDensitiesDest,'file') == 2
        load(brightDensitiesDest)
    else
        topDensity = cell2mat(scanStats.scanResults_top)';
        botDensity = cell2mat(scanStats.scanResults_bot)';
        dim1span = size(topDensity,1);
        dim1span4avg = round(dim1span/2);
        dim2span = size(topDensity,2);
        dim2span4avg = round(dim2span/5);
        
        topDensity = circshift(topDensity,[0 dim2span/4]);
        topDensity = mean(cat(3,topDensity,fliplr(topDensity)),3);
        topDensity = circshift(topDensity,[0 -dim2span/4]);
        botDensity = circshift(botDensity,[0 -dim2span/4]);
        botDensity = mean(cat(3,botDensity,fliplr(botDensity)),3);
        botDensity = circshift(botDensity,[0 dim2span/4]);
        
        for iterS = 1:dim1span
            topDensity(iterS,:) = smooth(topDensity(iterS,:),dim1span4avg);
        end
        topDensityPadded = [topDensity,topDensity,topDensity];
        for iterS = 1:dim2span
            topDensityPadded(:,iterS) = smooth(topDensityPadded(:,iterS),dim2span4avg);
        end
        topDensity = topDensityPadded(:,dim2span+1:dim2span*2);
        for iterS = 1:dim1span
            botDensity(iterS,:) = smooth(botDensity(iterS,:),dim1span4avg);
        end
        botDensityPadded = [botDensity,botDensity,botDensity]';
        for iterS = 1:dim2span
            botDensityPadded(:,iterS) = smooth(botDensityPadded(:,iterS),dim2span4avg);
        end
        botDensityPadded = botDensityPadded';
        botDensity = botDensityPadded(:,dim2span+1:dim2span*2);
        topDensity = flipud(topDensity);
        botDensity = flipud(botDensity);
        save(brightDensitiesDest,'topDensity','botDensity')
    end
    rangeD = prctile([topDensity(:);botDensity(:)],99)-minD;
    % rangeD = max([topDensity(:);botDensity(:)])-minD;
    topFactor = ((topDensity-minD)./rangeD).^(-1);
    botFactor = ((botDensity-minD)./rangeD).^(-1);
    
    
    %%%%%%%%%% use when filming stimulus
%     botFactor = botFactor.*(0.8);
    %%%%%%%%%
    
    
    topFactor = imresize(topFactor,[90-rad2deg(topThresh),360]);
    botFactor = imresize(botFactor,[rad2deg(mirMaxEle-minTheta),360]);
    
    fadeSeqVec = linspace(0,1,rad2deg(fadeSpan)+2);
    fadeSeq = repmat(fadeSeqVec(2:end-1)',1,360);
    
    topFacFadePart = topFactor(end-rad2deg(fadeSpan)+1:end,:);
    botFacFadePart = botFactor(1:rad2deg(fadeSpan),:);
    topFader = topFacFadePart.*flipud(fadeSeq);
    botFader = botFacFadePart.*fadeSeq;
    topFactor(end-rad2deg(fadeSpan)+1:end,:) = topFader;
    botFactor(1:rad2deg(fadeSpan),:) = botFader;
    rangeF = prctile([topFactor(:);botFactor(:)],99);
    topFactor = topFactor./rangeF;
    botFactor = botFactor./rangeF;
%     filtH = fspecial('average',[5 5]);
%     topFactor = imfilter(topFactor,filtH,'replicate');
%     botFactor = imfilter(botFactor,filtH,'replicate');
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
    
    shaderMasterBrighter = (shaderTop+shaderBot);
%     shaderMaster = mean(cat(3,fliplr(shaderMaster),shaderMaster),3);
%     shaderMaster = imfilter(shaderMaster,fspecial('average',[5 5]));
    shaderMasterBrighter = max(shaderMasterBrighter,stimRef);
    gainMatrixBrighter = repmat(shaderMasterBrighter,[1 1 3]);
    gainMatrixBrighter(gainMatrixBrighter < 0) = 0;
    gainMatrixBrighter(gainMatrixBrighter > 1) = 1;
    
%     if isempty(Screen('Windows'))
%         window = Screen(screenid,'OpenWindow');
%     else
%         window = Screen('Windows');
%     end
%     brighterIm = uint8(gainMatrixBrighter.*255);
%     Screen(window,'PutImage',brighterIm);
%     Screen(window,'Flip');
%     figure, imshow(shaderMasterBrighter)
else
    shaderMasterBrighter = [];
end

hVal = zeros(hXh,hXw);
lats = round(rad2deg((mirMaxEle+topThresh)/2));
lats = [lats -30 0];
latsMat = repmat(lats,hXh,1);
latsLutMat = repmat(hXeleVec(:),1,numel(lats));
[~,latNdx] = min(abs(latsLutMat-latsMat));
hVal(latNdx,:) = 1;
gapSize = 14;%must be even
blankVals = (1:gapSize:hXw);
for iterGap = 1:gapSize/2
    hVal(:,blankVals(1:end-1)+iterGap-1) = 0;
end
VqA = griddata(deg2rad(hXazi),deg2rad(hXele),hVal,aziPlane,eleFrmMir);
hVal = zeros(hXh,hXw);
hVal(latNdx,:) = 1;
blankVals = (1:gapSize:hXw);
for iterGap = (gapSize/2+1):gapSize
    hVal(:,blankVals(1:end-1)+iterGap-1) = 0;
end
VqB = griddata(deg2rad(hXazi),deg2rad(hXele),hVal,aziPlane,eleFrmTop);
Vq = max(VqA,VqB);
Vq(isnan(Vq)) = 0;
Vq = Vq+stimRef+initIm;
calibImB = repmat(uint8(shaderMasterBrighter.*Vq.*255),[1 1 3]);

if calibrateOp == 4
    if isempty(Screen('Windows'))
        window = Screen(screenid,'OpenWindow');
    else
        window = Screen('Windows');
    end
    Screen(window,'PutImage',calibImB);
    Screen(window,'Flip');
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%generate old style, theoretical brightness correction
topCount = 40;
aziCount = 24;
topCpos = linspace(topThresh,pi/2,topCount+1);
topCpos = topCpos(1:end-1)+diff(topCpos)./2;
aziCpos = linspace(-pi,pi,aziCount+1);
aziCpos = aziCpos(1:end-1)+diff(aziCpos)./2;
topCenters = {topCpos,aziCpos};
topDensity = hist3([eleFrmTop(:) aziFrmTop(:)],topCenters);
topDensity = topDensity./cos(repmat(topCenters{1}(:),1,aziCount));
[~,top20] = min(abs(topCpos-deg2rad(90-20)));
topDensity(top20:end,:) = repmat(mean(topDensity(top20:end,:),2),1,aziCount);
[~,top10] = min(abs(topCpos-deg2rad(90-20)));
topDensity(top10:end,:) = repmat(topDensity(top10,:),size(topDensity,1)-top10+1,1);

botCount = 40;
botCpos = linspace(minTheta,mirMaxEle,botCount+1);
botCpos = botCpos(1:end-1)+diff(botCpos)./2;
botCenters = {botCpos,aziCpos};
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
minD = 0;
rangeD = prctile([topDensity(:);botDensity(:)],99)-minD;
% rangeD = max([topDensity(:);botDensity(:)])-minD;
topFactor = ((topDensity-minD)./rangeD).^(-1);
botFactor = ((botDensity-minD)./rangeD).^(-1);
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
shaderMaster = max(shaderMaster,stimRef);
% figure,imshow(shaderMaster)
%end making of old shaderMaster

% hXeleVec = (-30:90);
% hXaziVec = (-180:180);
% hXw = numel(hXaziVec);
% hXh = numel(hXeleVec);
% hXele = repmat(hXeleVec(:),1,hXw);
% hXazi = repmat(hXaziVec,hXh,1);
lats = (-30:10:90);
latsMat = repmat(lats,hXh,1);
latsLutMat = repmat(hXeleVec(:),1,numel(lats));
[~,latNdxA] = min(abs(latsLutMat-latsMat));
longs = (-180:10:180);
longsMat = repmat(longs,hXw,1);
longsLutMat = repmat(hXaziVec(:),1,numel(longs));
[~,longNdxA] = min(abs(longsLutMat-longsMat));

lats = [-2 2];
latsMat = repmat(lats,hXh,1);
latsLutMat = repmat(hXeleVec(:),1,numel(lats));
[~,latNdxB] = min(abs(latsLutMat-latsMat));
longs = [-180 -90 0 90 180];
longs = [longs-2 longs+2];
longsMat = repmat(longs,hXw,1);
longsLutMat = repmat(hXaziVec(:),1,numel(longs));
[~,longNdxB] = min(abs(longsLutMat-longsMat));

hVal = zeros(hXh,hXw);
hVal(latNdxA,:) = 1;
hVal(:,longNdxA) = 1;
hVal(latNdxB,:) = 0.5;
hVal(:,longNdxB) = 0.5;
VqA = griddata(deg2rad(hXazi),deg2rad(hXele),hVal,aziPlane,eleFrmMir);
VqB = griddata(deg2rad(hXazi),deg2rad(hXele),hVal,aziPlane,eleFrmTop);
Vq = max(VqA,VqB);
Vq(isnan(Vq)) = 0;
Vq = Vq+stimRef;
gridIm = repmat(uint8(shaderMasterBrighter.*Vq.*255),[1 1 3]);

%%%%%%%%%%%%%generating a lat line only image

lats = (-30:10:90);
latsMat = repmat(lats,hXh,1);
latsLutMat = repmat(hXeleVec(:),1,numel(lats));
[~,latNdxA] = min(abs(latsLutMat-latsMat));
hVal = zeros(hXh,hXw);
hVal(latNdxA,:) = 1;
VqA = griddata(deg2rad(hXazi),deg2rad(hXele),hVal,aziPlane,eleFrmMir);
VqB = griddata(deg2rad(hXazi),deg2rad(hXele),hVal,aziPlane,eleFrmTop);
Vq = max(VqA,VqB);
Vq(isnan(Vq)) = 0;
latsOnlyIm = Vq.*shaderMasterBrighter;

%%%%%%%%%%%%%%generating a gridded background
lats = 0;
latsMat = repmat(lats,hXh,1);
latsLutMat = repmat(hXeleVec(:),1,numel(lats));
[~,latNdxA] = min(abs(latsLutMat-latsMat));

lats = [-2 2];
latsMat = repmat(lats,hXh,1);
latsLutMat = repmat(hXeleVec(:),1,numel(lats));
[~,latNdxB] = min(abs(latsLutMat-latsMat));

hVal = zeros(hXh,hXw);
hVal(latNdxA,:) = 1;
hVal(latNdxB,:) = 0.5;
VqA = griddata(deg2rad(hXazi),deg2rad(hXele),hVal,aziPlane,eleFrmMir);
VqB = griddata(deg2rad(hXazi),deg2rad(hXele),hVal,aziPlane,eleFrmTop);
Vq = max(VqA,VqB);
Vq(isnan(Vq)) = 0;
Vq = Vq+stimRef;
gridBackground = shaderMasterBrighter.*abs(Vq-1);
gridBackground = max(gridBackground,stimRef);

%%%%%%%%%%%%%% vertical lines
longs = (-180:10:180);
longs = [longs+1 longs longs-1];
longsMat = repmat(longs,hXw,1);
longsLutMat = repmat(hXaziVec(:),1,numel(longs));
[~,longNdx] = min(abs(longsLutMat-longsMat));
hVal = zeros(hXh,hXw);
hVal(:,longNdx) = 1;
VqA = griddata(deg2rad(hXazi),deg2rad(hXele),hVal,aziPlane,eleFrmMir);
VqB = griddata(deg2rad(hXazi),deg2rad(hXele),hVal,aziPlane,eleFrmTop);
Vq = max(VqA,VqB);
Vq(isnan(Vq)) = 0;
vertLinesIm = im2bw(Vq);
vertLinesIm = imdilate(vertLinesIm,strel('disk',3));
vertLinesIm = double(abs(vertLinesIm-1));
vertLinesIm = imfilter(vertLinesIm,fspecial('average',[9 9]));
vertLinesIm = repmat(uint8(vertLinesIm.*255),[1 1 3]);

whiteIm = repmat(uint8(shaderMasterBrighter.*255),[1 1 3]);
blackIm = repmat(uint8(zeros(height,width)),[1 1 3]);

% for use in the 'GainMatrix'
gainMatrix = repmat(shaderMaster,[1 1 3]);
gainMatrix(gainMatrix < 0) = 0;
gainMatrix(gainMatrix > 1) = 1;


save(varPath,'gainMatrix','stimEleForProc','stimAziForProc','stimRefROI',...
    'crosshairsIm','calibImB','gridIm','vertLinesIm','gridBackground',...
    'shaderTop','shaderBot','latsOnlyIm','topCpos','botCpos','aziCpos',...
    'gainMatrixBrighter')

if calibrateOp == 5
    if isempty(Screen('Windows'))
        window = Screen(screenid,'OpenWindow');
    else
        window = Screen('Windows');
    end
    brighterIm = uint8(gainMatrixBrighter.*255);
    Screen(window,'PutImage',brighterIm);
    Screen(window,'Flip');
end


%%
if calibrateOp == 5
    if isempty(Screen('Windows'))
        window = Screen(screenid,'OpenWindow');
    else
        window = Screen('Windows');
    end
    Screen(window,'PutImage',gridIm);
    Screen(window,'Flip');
end



%%
Screen(window,'PutImage',whiteIm);
Screen(window,'Flip');
%%
brighterIm = uint8(gainMatrixBrighter.*255);
Screen(window,'PutImage',brighterIm);
Screen(window,'Flip');
