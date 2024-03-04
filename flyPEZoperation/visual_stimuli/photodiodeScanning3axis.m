function photodiodeScanning3axis
set(0,'showhiddenhandles','on')
delete(get(0,'Children'))

% Get communications variables
variablesDir = [filesep filesep 'dm11' filesep 'cardlab' filesep 'pez3000_variables'];
[~, comp_name] = system('hostname');
comp_name = comp_name(1:end-1); %Remove trailing character.
compDataPath = fullfile(variablesDir,'computer_info.xlsx');
compData = dataset('XLSFile',compDataPath);
compRef = find(strcmp(compData.control_computer_name,comp_name));%this computer
if isempty(compRef)
    disp('computer not valid')
    return
end
hostIP = compData.stimulus_computer_IP{compRef};
portNum = 21566;


%%%%% 1 - make new
%%%%% 2 - use existing
aziMode = 2;
%%%%%
dataDir = [filesep filesep 'dm11' filesep 'cardlab' filesep 'pez3000_variables'];
[~, comp_name] = system('hostname');
comp_name = comp_name(1:end-1); %Remove trailing character.
compDataPath = fullfile(dataDir,'computer_info.xlsx');
compData = dataset('XLSFile',compDataPath);
compRef = find(strcmp(compData.control_computer_name,comp_name));
if isempty(compRef)
    %     compRef = 1;
    disp('computer not valid')
    return
end
pezName = ['pez' num2str(compData.pez_reference(compRef))];
varName = [pezName '_stimuliVars.mat'];
varPath = fullfile(dataDir,varName);
load(varPath)

deg2rad = @(x) x.*(pi/180);
rad2deg = @(x) x./(pi/180);

scanningVarPath = fullfile(dataDir,'scanningVariables',[pezName '_azimuthData.mat']);
if aziMode == 1
    commandVal = 5;
    judp('send',portNum,hostIP,int8(commandVal))
    rcvdMssg = judp('receive',portNum,50,15000);
    char(rcvdMssg')
    judp('send',portNum,hostIP,int8(50))
    [photoDataCell,posOpsB,successBool] = azimuthDataAcquisition2servos_v3;
    if ~successBool, return, end
    save(scanningVarPath,'photoDataCell','posOpsB')
else
    load(scanningVarPath)
end
%%
scanResults_init = mean(cat(1,photoDataCell{:}));
scanResults_init = scanResults_init(1:end-5);
photoDataMeanLR = (scanResults_init);
parts2divide = 18;
scanCount = numel(scanResults_init);
partRefs = round(linspace(0,scanCount,parts2divide+1));
partC = cell(1,parts2divide);
for iterP = 1:parts2divide
    partA = photoDataMeanLR(partRefs(iterP)+1:partRefs(iterP+1));
    partB = (partA-min(partA))./range(partA);
    photoDataMeanLR(partRefs(iterP)+1:partRefs(iterP+1)) = partB;
end
photoDataSmooth = (photoDataMeanLR)';
photoDataZero = (photoDataSmooth-min(photoDataSmooth))./range(photoDataSmooth);
figure,plot([photoDataZero(:)';photoDataMeanLR(:)']')
%
[pkVal,pkInd] = findpeaks(photoDataZero,'MINPEAKHEIGHT',0.5,'MINPEAKDISTANCE',3);
if numel(pkInd) ~= 36
    error('azimuth peak detection failure')
end
photoDataNormRaw = (scanResults_init-min(scanResults_init))./range(scanResults_init);
figure,plot([photoDataZero(:)';photoDataNormRaw(:)']')
hold all
plot(pkInd,pkVal,'.')
% plot(partRefs,ones(size(partRefs)),'.')
hold off
%%
degX_rescan = (0:10:360);
degX_rescan = degX_rescan(1:end-1);
% servoPos_rescan = polyval(spp,degX_rescan);
Y = posOpsB(pkInd);
x = degX_rescan;
xi = degX_rescan;
servoPos_rescan = interp1(x,Y,xi,'pchip');

aziCount = 30;
aziCpos = linspace(-pi,pi,aziCount+1);
aziCpos = aziCpos(2:end);
% aziCpos = aziCpos(1:end-1)+diff(aziCpos)./2;
degX_azi = rad2deg(aziCpos);
degX_azi(degX_azi < 1) = degX_azi(degX_azi < 1)+360;
[~,sortNdx] = sort(degX_azi);
degX_azi = degX_azi(sortNdx);
aziCpos = aziCpos(sortNdx);

%%%%% empirically determined azimuth location of the lights
lightsA = degX_azi > 30 & degX_azi < 66;
lightsB = degX_azi > 108 & degX_azi < 144;
lightsC = degX_azi > 210 & degX_azi < 252;
lightsD = degX_azi > 288 & degX_azi < 324;
lightsTest = max([lightsA;lightsB;lightsC;lightsD]);
aziCpos(lightsTest) = [];
aziCpos = aziCpos*(-1);%corrects for a difference in how the servo works
degX_azi(lightsTest) = [];

xi = degX_azi;
servoPos_azi = interp1(x,Y,xi,'pchip');

figure,plot(degX_rescan,servoPos_rescan)
hold all
plot(degX_azi,servoPos_azi,'.')
rowNames = strtrim(cellstr(num2str(round(rad2deg(aziCpos)'))))
%%
tic
runMode = 2;%1 - 1hr, 2 - 35 min
trialsEach = 1;
trialsFull = 3;

if runMode == 0
    trialsFull = 1;
end
scanStatsName = ['photoScanResults_pez' num2str(compData.pez_reference(compRef)),...
    '_whiteLED_10AzimuthalSteps.mat'];
scanStatsDest = fullfile(dataDir,'scanningVariables',scanStatsName);
contrastName = ['photoScanResults_pez' num2str(compData.pez_reference(compRef)),...
    '_contrast_15_30_60_90.mat'];
contrastDest = fullfile(dataDir,'scanningVariables',contrastName);
makeNew = true;
if exist(scanStatsDest,'file')
    load(scanStatsDest);
    if isequal(scanStats.Properties.RowNames,rowNames)
        makeNew = false;
    end
end
if makeNew
    varNames = {'scanResults_init','scanL','posList',...
        'servoPos_rescan','degX_rescan','scanResults_rescan',...
        'servoPos_top','degX_top','scanResults_top','servoPos_bot','degX_bot',...
        'scanResults_bot','scanResults_unbalanced','scanResults_balanced'};
    scanStats = cell2table(cell(numel(aziCpos),numel(varNames)),...
        'RowNames',rowNames,'VariableNames',varNames);
end

if runMode == 3
    %%
    commandVal = 0;
    judp('send',portNum,hostIP,int8(commandVal))
    rcvdMssg = judp('receive',portNum,50,15000);
    char(rcvdMssg')
    dispAziVal = 180;
    dispEleVal = 45;
    stim_data_matrix = [num2str(dispAziVal),';',num2str(dispEleVal)];
else
    commandVal = 5;
    judp('send',portNum,hostIP,int8(commandVal))
    rcvdMssg = judp('receive',portNum,50,15000);
    char(rcvdMssg')
end
for iterFull = 1:trialsFull
    hWaitI = waitbar(0,'Replicate scans',...
        'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(hWaitI,'canceling',0)
    posWait = get(hWaitI,'position');
    posWait(2) = posWait(2)-150;
    set(hWaitI,'position',posWait)
    
    
    for iterAzi = 1:numel(aziCpos)
        waitbar(iterAzi/numel(aziCpos),hWaitI)
        scanName = rowNames(iterAzi);
        disp(scanName)
        
        if runMode == 0
            minPos = 130;
        else
            minPos = 85;
        end
        maxPos = 195;%must be the zenith!
        
        %command options: 'makeNew','usePrevious','useExisting'
        posOpCommand = 1;
        if iterFull > 1 || runMode > 1
            posOpCommand = 3;
        elseif iterAzi > 1 %round(posAzi/2) == posAzi/2
            posOpCommand = 2;
        end
        switch posOpCommand
            case 1
                judp('send',portNum,hostIP,int8(51))
                if runMode == 0
                    posListLR = [minPos,maxPos];
                else
                    posListLR = (minPos:1:maxPos);%better readings is start from bottom and go up
                end
                [photoDataCellLR,passB] = elevationDataAcquisition2servos_v3(posListLR,...
                    servoPos_azi(iterAzi),5,minPos,maxPos);
                scanL = size(photoDataCellLR,1);
                scanCount = size(photoDataCellLR,2);
                if ~passB
                    break
                end
                scanResults_init = fliplr(mean((photoDataCellLR)));
                posList = fliplr(posListLR);
                
            case 2
                lastName = num2str(rad2deg(aziCpos(iterAzi-1)));
                scanResults_init = scanStats.scanResults_init{lastName};
                scanL = scanStats.scanL{lastName};
                posList = scanStats.posList{lastName};
            case 3
                scanResults_init = scanStats.scanResults_init{scanName};
                scanL = scanStats.scanL{scanName};
                posList = scanStats.posList{scanName};
        end
        %%
        if runMode == 0
            continue
        end
        if runMode < 3
            scanStats.scanResults_init(scanName) = {scanResults_init};
            scanStats.scanL(scanName) = {scanL};
            scanStats.posList(scanName) = {posList};
            save(scanStatsDest,'scanStats')
        end
        close all
        figure,plot(scanResults_init)
        
        %%
        
        photoDataMeanLR = (scanResults_init);
        parts2divide = 12;
        scanCount = numel(scanResults_init);
        partRefs = round(linspace(0,scanCount,parts2divide+1));
        for iterP = 1:parts2divide
            partA = photoDataMeanLR(partRefs(iterP)+1:partRefs(iterP+1));
            partB = (partA-min(partA))./range(partA);
            photoDataMeanLR(partRefs(iterP)+1:partRefs(iterP+1)) = partB;
        end
        photoDataSmooth = (photoDataMeanLR)';
        photoDataZero = (photoDataSmooth-min(photoDataSmooth))./range(photoDataSmooth);
        % figure,plot([photoDataZero(:)';photoDataMeanLR(:)']')
        minDist = floor(scanCount/parts2divide*0.7);
        [pkVal,pkInd] = findpeaks(photoDataZero,'MINPEAKHEIGHT',0.5,'MINPEAKDISTANCE',minDist);
        photoDataNormRaw = (scanResults_init-min(scanResults_init))./range(scanResults_init);
        figure,plot([photoDataZero(:)';photoDataNormRaw(:)']')
        hold all
        plot(pkInd,pkVal,'.')
        plot(partRefs,ones(size(partRefs)),'.')
        hold off
        %%
        
        degX_rescan = (0:1:120);
        % servoPos_rescan = polyval(spp,degX_rescan);
        Y = posList(pkInd);
        Y = Y(2:end);
        x = (0:10:120);
        x = x(2:12);
        xi = degX_rescan;
        servoPos_rescan = interp1(x,Y,xi,'pchip','extrap');
        
        %%% The following manipulation makes the projectorCalibration azimuth
        %%% references compatible with the one used for the servo.  In
        %%% projectorCalibration, the equator is 0 and zenith is 90 degrees.  Here,
        %%% zenith is 0 and the equator is 90 degrees (-30 is now 120 deg).
        topCount = 40;
        topCpos = linspace(topThresh,pi/2,topCount+1);
        topCpos = topCpos(1:end-1)+diff(topCpos)./2;
        botCount = 40;
        botCpos = linspace(minTheta,mirMaxEle,botCount+1);
        botCpos = botCpos(1:end-1)+diff(botCpos)./2;
        
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
        
        
        if runMode == 1
            if iterFull == 1
                scanResults_rescan = zeros(trialsFull,numel(servoPos_rescan));
                scanResults_bot = zeros(trialsFull,numel(servoPos_bot));
                scanResults_top = zeros(trialsFull,numel(servoPos_top));
                scanResults_unbalanced = zeros(trialsFull,numel(servoPos_rescan));
            else
                scanResults_rescan = scanStats.scanResults_rescan{scanName};
                scanResults_bot = scanStats.scanResults_bot{scanName};
                scanResults_top = scanStats.scanResults_top{scanName};
                scanResults_unbalanced = scanStats.scanResults_unbalanced{scanName};
            end
            judp('send',portNum,hostIP,int8(51))
            [photoDataL,passB] = elevationDataAcquisition2servos_v3(servoPos_rescan,servoPos_azi(iterAzi),...
                trialsEach,minPos,maxPos);%top,down
            if ~passB, break, end
            scanResults_rescan(iterFull,:) = mean(photoDataL);
            scanStats.scanResults_rescan(scanName) = {scanResults_rescan};
            save(scanStatsDest,'scanStats')
            figure, plot(scanResults_rescan')
            
            judp('send',portNum,hostIP,int8(52))
            [photoDataL,passB] = elevationDataAcquisition2servos_v3(servoPos_bot,servoPos_azi(iterAzi),...
                trialsEach,minPos,maxPos);%bottom, up
            if ~passB, break, end
            scanResults_bot(iterFull,:) = mean(photoDataL);
            scanStats.scanResults_bot(scanName) = {scanResults_bot};
            save(scanStatsDest,'scanStats')
            figure,plot(scanResults_bot')
            
            judp('send',portNum,hostIP,int8(53))
            [photoDataL,passB] = elevationDataAcquisition2servos_v3(servoPos_top,servoPos_azi(iterAzi),...
                trialsEach,minPos,maxPos);%bottom, up
            if ~passB, break, end
            scanResults_top(iterFull,:) = mean(photoDataL);
            scanStats.scanResults_top(scanName) = {scanResults_top};
            save(scanStatsDest,'scanStats')
            figure,plot(scanResults_top')
%         elseif runMode == 2
%             if iterFull == 1
%                 scanResults_unbalanced = zeros(trialsFull,numel(servoPos_rescan));
%             else
%                 scanResults_unbalanced = scanStats.scanResults_unbalanced{scanName};
%             end
%             imReadPath = fullfile(dataDir,[pezName '_im2show.tif']);
%             im2show = repmat(uint8(zeros(768,1024)+255),[1 1 3]);
%             imwrite(im2show,imReadPath)
%             judp('send',portNum,hostIP,int8(54))
%             [photoDataL,passB] = elevationDataAcquisition2servos_v3(servoPos_rescan,servoPos_azi(iterAzi),...
%                 trialsEach,minPos,maxPos);
%             if ~passB, break, end
%             scanResults_unbalanced(iterFull,:) = mean(photoDataL);
%             scanStats.scanResults_unbalanced(scanName) = {scanResults_unbalanced};
%             figure,plot(scanResults_unbalanced')
        elseif runMode == 2
            if iterFull == 1
                scanResults_balanced = zeros(trialsFull,numel(servoPos_rescan));
            else
                scanResults_balanced = scanStats.scanResults_balanced{scanName};
            end
            judp('send',portNum,hostIP,int8(9))
            [photoDataL,passB] = elevationDataAcquisition2servos_v3(servoPos_rescan,servoPos_azi(iterAzi),...
                trialsEach,minPos,maxPos);
            if ~passB, break, end
            scanResults_balanced(iterFull,:) = mean(photoDataL);
            scanStats.scanResults_balanced(scanName) = {scanResults_balanced};
            save(scanStatsDest,'scanStats')
            
        elseif runMode == 3
            if iterAzi == 1 && iterFull == 1
                contrastArray = zeros(4,numel(servoPos_rescan),trialsFull);
            end
            if ~strcmp(scanName,'-180')
                continue
            end
            fileName = 'testing_10to15_lv30_blackonwhite.mat';
            judp('send',portNum,hostIP,int8([3 fileName]))
            stimdurstr = judp('receive',portNum,50,15000);
            pause(1)
            stimdur = str2double(char(stimdurstr'));
            judp('send',portNum,hostIP,int8([4 stim_data_matrix]))
            judp('receive',portNum,50,stimdur+5000);
            servoPos = servoPos_rescan;%top,down
            [photoDataL,passB] = elevationDataAcquisition2servos_v3(servoPos,servoPos_azi(iterAzi),...
                trialsEach,minPos,maxPos);
            if ~passB, break, end
            contrastArray(1,:,iterFull) = mean(photoDataL);
            
            fileName = 'testing_10to30_lv30_blackonwhite.mat';
            judp('send',portNum,hostIP,int8([3 fileName]))
            stimdurstr = judp('receive',portNum,50,15000);
            pause(1)
            stimdur = str2double(char(stimdurstr'));
            judp('send',portNum,hostIP,int8([4 stim_data_matrix]))
            judp('receive',portNum,50,stimdur+5000);
            servoPos = servoPos_rescan;%top,down
            [photoDataL,passB] = elevationDataAcquisition2servos_v3(servoPos,servoPos_azi(iterAzi),...
                trialsEach,minPos,maxPos);
            if ~passB, break, end
            contrastArray(2,:,iterFull) = mean(photoDataL);
            
            fileName = 'testing_10to60_lv30_blackonwhite.mat';
            judp('send',portNum,hostIP,int8([3 fileName]))
            stimdurstr = judp('receive',portNum,50,15000);
            pause(1)
            stimdur = str2double(char(stimdurstr'));
            judp('send',portNum,hostIP,int8([4 stim_data_matrix]))
            judp('receive',portNum,50,stimdur+5000);
            servoPos = servoPos_rescan;%top,down
            [photoDataL,passB] = elevationDataAcquisition2servos_v3(servoPos,servoPos_azi(iterAzi),...
                trialsEach,minPos,maxPos);
            if ~passB, break, end
            contrastArray(3,:,iterFull) = mean(photoDataL);
            %%
            fileName = 'testing_10to90_lv30_blackonwhite.mat';
            judp('send',portNum,hostIP,int8([3 fileName]))
            stimdurstr = judp('receive',portNum,50,15000);
            pause(1)
            stimdur = str2double(char(stimdurstr'));
            judp('send',portNum,hostIP,int8([4 stim_data_matrix]))
            judp('receive',portNum,50,stimdur+3000);
            %%
            servoPos = servoPos_rescan;%top,down
            [photoDataL,passB] = elevationDataAcquisition2servos_v3(servoPos,servoPos_azi(iterAzi),...
                trialsEach,minPos,maxPos);
            if ~passB, break, end
            contrastArray(4,:,iterFull) = mean(photoDataL);
            
            save(contrastDest,'contrastArray')
        end
    end
    delete(hWaitI)
    if ~passB
        break
    end
end
toc
elevationDataAcquisition2servos_v3; %closes servos
%%
set(0,'ShowHiddenHandles','on')
delete(get(0,'Children'))
set(0,'ShowHiddenHandles','off')

