%%
set(0,'showhiddenhandles','on')
delete(get(0,'Children'))
clearvars
clc

dataDir = [filesep filesep 'dm11' filesep 'cardlab' filesep 'pez3000_variables'];
[~, comp_name] = system('hostname');
comp_name = comp_name(1:end-1); %Remove trailing character.
compDataPath = fullfile(dataDir,'computer_info.xlsx');
compData = dataset('XLSFile',compDataPath);
compRef = find(strcmp(compData.control_computer_name,comp_name));
if isempty(compRef)
    compRef = 1;
%     disp('computer not valid')
%     return
end
pezName = ['pez' num2str(compData.pez_reference(compRef))];
varName = [pezName '_stimuliVars.mat'];
varPath = fullfile(dataDir,varName);
load(varPath)



deg2rad = @(x) x.*(pi/180);
rad2deg = @(x) x./(pi/180);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%command options: 'makeNew','usePrevious','useExisting'
posOpCommand = 2;
posAzi = 24;%must be 1-24
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

scanAzi = rad2deg(aziCpos(posAzi));
scanName = num2str(scanAzi);
disp(scanName)
scanStatsName = 'photoScanResults_pez3001_greenLED_15degLatitudinalSteps.mat';
scanStatsDest = fullfile(dataDir,scanStatsName);
scanStats2add = dataset({{[]},'initScanStruct'},...
        {{[]},'servoPos_rescan'},{{[]},'degX_rescan'},{{[]},'scanResults_rescan'},...
        {{[]},'servoPos_top'},{{[]},'degX_top'},{{[]},'scanResults_top'},...
        {{[]},'servoPos_bot'},{{[]},'degX_bot'},{{[]},'scanResults_bot'},...
        'ObsNames',{scanName});
if exist(scanStatsDest,'file') == 2
    load(scanStatsDest);
    obsNames = get(scanStats,'ObsNames');
    existTest = strcmp(scanName,obsNames);
    if ~existTest
        scanStats = [scanStats;scanStats2add];
    end
else
    scanStats = scanStats2add;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
tic


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
    disp('screen size incorrect')
    return
end
if isempty(Screen('Windows'))
    window = Screen(screenid,'OpenWindow');
else
    window = Screen('Windows');
end
makeUint8 = @(x) repmat(uint8(x.*255),[1 1 3]);

%
% Screen(window,'PutImage',calibImB);
% Screen(window,'Flip');
%

Screen(window,'PutImage',makeUint8(latsOnlyIm));
Screen(window,'Flip');

%%
minPos = 49;%must be the zenith!
maxPos = 139;
switch posOpCommand
    case 1
        posListLR = fliplr(minPos:0.25:maxPos);%better readings is start from bottom and go up
        trials = 7;
        [photoDataCellLR,passB,scanL,scanCount] = RyansAdvServoCalibrated(posListLR,minPos,maxPos,trials);
        if ~passB, return, end
        scanResults_init = fliplr(mean(cell2mat(photoDataCellLR)));%flipping it back !!!
        posList = fliplr(posListLR);%flipping it back !!!
        initScanStruct = struct('scanResults_init',scanResults_init,'scanL',scanL,...
            'scanCount',scanCount,'posList',posList);
    case 2
        lastName = num2str(rad2deg(aziCpos(posAzi-1)));
        initScanStruct = scanStats.initScanStruct{lastName};
        scanResults_init = initScanStruct.scanResults_init;
        scanL = initScanStruct.scanL;
        scanCount = initScanStruct.scanCount;
        posList = initScanStruct.posList;
    case 3
        initScanStruct = scanStats.initScanStruct{scanName};
        scanResults_init = initScanStruct.scanResults_init;
        scanL = initScanStruct.scanL;
        scanCount = initScanStruct.scanCount;
        posList = initScanStruct.posList;
end
scanStats.initScanStruct(scanName) = {initScanStruct};
save(scanStatsDest,'scanStats')

% figure,plot(scanResults_init)

%%

photoDataMeanLR = smooth(scanResults_init)';
parts2divide = 13;
partLength = (scanCount/(parts2divide-1));
partRefs = [0 round(linspace(partLength/3,scanCount,parts2divide))];
partRefs(end) = scanCount;

partC = cell(1,parts2divide);
for iterP = 1:parts2divide
    partA = photoDataMeanLR(partRefs(iterP)+1:partRefs(iterP+1));
    partB = (partA-min(partA))./range(partA);
    partC{iterP} = partB;
end
photoDataMeanLR = cell2mat(partC);
%
photoDataSmooth = smooth(photoDataMeanLR)';
photoDataZero = (photoDataSmooth-min(photoDataSmooth))./range(photoDataSmooth);
% figure,plot([photoDataZero';photoDataMeanLR]')

[pkVal,pkInd] = findpeaks(photoDataZero,'MINPEAKHEIGHT',0,'MINPEAKDISTANCE',20);
pkVal = [photoDataZero(1),pkVal];
pkInd = [1,pkInd];
photoDataNormRaw = (scanResults_init-min(scanResults_init))./range(scanResults_init);
figure,plot([photoDataZero;photoDataNormRaw]')
hold all
plot(pkInd,pkVal,'.')
plot(partRefs,ones(size(partRefs)),'.')
hold off
% %%
% 
% numCoef = 4;
% pp = polyfit((1:numel(pkInd))',pkInd(:),numCoef);
% valCount = pkInd(end);
% xVal = linspace(0,numel(pkInd)+1,valCount);
% redistVal = polyval(pp,xVal);
% redistVal = round(redistVal);
% [~,beginB] = min(abs(redistVal-1));
% [~,endB] = min(abs(redistVal-scanCount));
% redistVal = redistVal(beginB:endB-1);
% redistCt = numel(redistVal);
% 
% %%%% figure showing redistribution curves
% figure
% xValB = linspace(1,max(redistVal),redistCt);
% yValB = xValB+(xValB-redistVal);
% y1 = [redistVal;yValB;xValB];%redistribution curves
% demoX = round(linspace(1,scanCount,redistCt));
% y2 = [photoDataZero(demoX);photoDataZero(redistVal)];%orig and redist peaks
% [hax,h1,h2] = plotyy(xValB,y2,xValB,y1,'plot');
% colr = get(h1(1),'Color');
% set(h1(1),'Color',colr,'LineWidth',1,'LineStyle',':')
% set(h2(1),'Color',colr)
% colr = get(h1(2),'Color');
% set(h1(2),'LineWidth',2)
% set(h2(2),'Color',colr)
% hold all
% plot(pkInd,pkVal,'.')
% hold off
% %%
% 
% 
% zenInd = pkInd(1);
% arcDeg = (numel(pkInd)-1)*10;%distance in degrees from first peak to the last,
%                 %assuming scanned lines were 10-degrees apart
% 
% [~,peakFirst] = min(abs(redistVal-pkInd(1)));
% [~,peakLast] = min(abs(redistVal-pkInd(end)));
% degPerPt = arcDeg/(peakLast-peakFirst);
% degAtEnd = 120;
% 
% % in terms of actual servo positions %
% redistPos = posList(redistVal(1:end));
% numelPos = numel(redistPos);
% polyX = linspace(0,degAtEnd,numelPos);
% spp = polyfit(polyX,redistPos,numCoef);

degX_rescan = fliplr(0:1:120);
% servoPos_rescan = polyval(spp,degX_rescan);
Y = posList(pkInd);
x = (0:10:120);
xi = degX_rescan;
servoPos_rescan = interp1(x,Y,xi,'pchip');


%%% The following manipulation makes the projectorCalibration azimuth
%%% references compatible with the one used for the servo.  In
%%% projectorCalibration, the equator is 0 and zenith is 90 degrees.  Here,
%%% zenith is 0 and the equator is 90 degrees (-30 is now 120 deg).
degX_top = rad2deg((topCpos-pi/2).*(-1));
degX_bot = rad2deg((botCpos-pi/2).*(-1));

% servoPos_top = polyval(spp,degX_top);
% servoPos_bot = polyval(spp,degX_bot);

xi = degX_top;
servoPos_top = interp1(x,Y,xi,'pchip');
xi = degX_bot;
servoPos_bot = interp1(x,Y,xi,'pchip');

figure,plot(degX_rescan,servoPos_rescan)
hold all
plot(degX_top,servoPos_top,'.')
plot(degX_bot,servoPos_bot,'.')
%%
scanStats.degX_rescan(scanName) = {degX_rescan};
scanStats.servoPos_rescan(scanName) = {servoPos_rescan};
scanStats.degX_top(scanName) = {degX_top};
scanStats.servoPos_top(scanName) = {servoPos_top};
scanStats.degX_bot(scanName) = {degX_bot};
scanStats.servoPos_bot(scanName) = {servoPos_bot};

save(scanStatsDest,'scanStats')


%%


servoPos = servoPos_rescan;
trials = 7;
[photoDataL,passB] = RyansAdvServoCalibrated(servoPos,minPos,maxPos,trials);
if ~passB, return, end
scanResults_rescan = mean(cell2mat(photoDataL));
scanStats.scanResults_rescan(scanName) = {scanResults_rescan};
save(scanStatsDest,'scanStats')
figure, plot(degX_rescan,scanResults_rescan)

shaderTop(shaderTop > 0) = 1;
Screen(window,'PutImage',makeUint8(shaderTop));
Screen(window,'Flip');
servoPos = servoPos_top;
[photoDataL,passB] = RyansAdvServoCalibrated(servoPos,minPos,maxPos,trials);
if ~passB, return, end
scanResults_top = mean(cell2mat(photoDataL));
scanStats.scanResults_top(scanName) = {scanResults_top};
save(scanStatsDest,'scanStats')
% figure,plot(photoLatMean)


shaderBot(shaderBot > 0) = 1;
Screen(window,'PutImage',makeUint8(shaderBot));
Screen(window,'Flip');
servoPos = servoPos_bot;
[photoDataL,passB] = RyansAdvServoCalibrated(servoPos,minPos,maxPos,trials);
if ~passB, return, end
scanResults_bot = mean(cell2mat(photoDataL));
scanStats.scanResults_bot(scanName) = {scanResults_bot};
save(scanStatsDest,'scanStats')
% figure,plot(photoLatMean)


toc






