function vidMontage_flexible_exploration(savedVarPath,writeVid)
%% %%% computer and directory variables and information
if isempty(mfilename) || nargin == 0
%     savedVarPath = 'Z:\Santiago\montage_vids\videoReference\ID#0096000023830713_mont2of2_videoReference.mat';
%     savedVarPath = 'Z:\WryanW\martin4ryan\montage_vids\videoReference\P11_mont1of1_videoReference.mat';
    savedVarPath = 'Z:\WryanW\LC6-LC4_manuscript\montage_vids\videoReference\DL_long_lv40_nonJumpers_videoReference.mat';
    writeVid = 0;
end

%%%%%%%%%%% Options %%%%%%%%%%%%
overlayFrmOne = 1;
showVideoReference = 1;
showDots = 1;
forceOverwright = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


montageStruct = load(savedVarPath);
videoList = montageStruct.videoList;
montPos = montageStruct.montPos;
startVec = montageStruct.startVec;
destPath = montageStruct.destPath;
runMode = montageStruct.runMode;
viewMode = montageStruct.viewMode;
allowRotation = montageStruct.allowRotation;
allowMovement = montageStruct.allowMovement;
stimType = montageStruct.stimType;
traceVec = montageStruct.traceVec;
if viewMode == 2
    allowRotation = true;
end
% runMode - 1 aligned to fot, sort by wing mvmnt
% runMode - 2 aligned to frame of wing mvmnt, sort by differential
% runMode - 3 aligned to stimulus start, sort by fot
% viewMode - 1 bottom, underside view
% viewMode - 2 top, side view

archDir = [filesep filesep 'dm11' filesep 'cardlab'];
if ~exist(archDir,'file')
    error('Archive access failure')
end
analysisDir = fullfile(archDir,'Data_pez3000_analyzed');

% baseFrmVec - defines the frames to be displayed before and after the event
% set by frm2align, a variable set later in this function
rateFactor = 10;
baseFrmVec = (-round(max(startVec(:,4))*0.75):rateFactor:100);
if runMode == 3
    rateFactor = 10;%between 1 and 10
    baseFrmVec = (round(max(startVec(:,4))*0.25):rateFactor:round(max(startVec(:,4))));
elseif runMode == 4
    rateFactor = 2;%between 1 and 10
%     baseFrmVec = (1:rateFactor:startVec(1,4));
    baseFrmVec = (1:rateFactor:600);
elseif runMode == 7
    rateFactor = 10;%between 1 and 10
    baseFrmVec = (-2500:rateFactor:500);
end
montFrmCt = numel(baseFrmVec);
if exist(destPath,'file') && ~(isempty(mfilename) || nargin == 0)
    try
        writeTestObj = VideoReader(destPath);
        writeCt = get(writeTestObj,'NumberOfFrames');
        delete(writeTestObj)
        if montFrmCt ~= writeCt
            disp('bad existing montage')
            delete(destPath)
        elseif forceOverwright ~= 1
            disp('Video already exists')
            return
        end
    catch ME
        getReport(ME)
    end
end

rowCt = max(montPos(:,1));
colCt = max(montPos(:,2));
maxFlies = size(montPos,1);

tol = [0 0.995];
lowhighFac = [0.1 0.1];
% lowhighFac = [0 0];
gammaAdj = 0.8;
backoff = 10;

vidCount = numel(videoList);
vidObjA = cell(vidCount,1);
vidObjB = cell(vidCount,1);
frm_remapCell = cell(vidCount);
xyTheta = cell(vidCount,1);
flyLength = zeros(vidCount,1);
event2plot = zeros(vidCount,1);
frameReferenceCell = cell(vidCount,1);
outOfRangeCell = cell(vidCount,1);
exptID = [];
for vRef = 1:vidCount
    videoID = videoList{vRef};
    strParts = strsplit(videoID,'_');
    dateID = strParts{3};
    runID = [strParts{1} '_' strParts{2} '_' strParts{3}];
    loadNewTable = true;
    if ~isempty(exptID)
        if strcmp(exptID,strParts{4}(5:end))
            loadNewTable = false;
        end
    end
    
    if loadNewTable
        exptID = strParts{4}(5:end);
        vidInfoMergedName = [exptID '_videoStatisticsMerged.mat'];
        vidInfoMergedPath = fullfile(analysisDir,exptID,vidInfoMergedName);
        vidInfo_import = load(vidInfoMergedPath);
        dataname = fieldnames(vidInfo_import);
        videoStatisticsMerged = vidInfo_import.(dataname{1});
    end
    analyzer_name = 'flyAnalyzer3000_v13';
    analyzer_expt_ID = [videoID '_' analyzer_name '_data.mat'];
    analyzer_data_dir = fullfile(analysisDir,exptID,[exptID '_' analyzer_name]);
    analyzer_data_path = fullfile(analyzer_data_dir,analyzer_expt_ID);
    if contains(analyzer_data_path,'tier2')
        analyzer_data_path = regexprep(analyzer_data_path,'tier2','dm11');
        analyzer_data_path = regexprep(analyzer_data_path,'card','cardlab');
    end
    if exist(analyzer_data_path,'file') == 2
        analysis_data_import = load(analyzer_data_path);
        dataname = fieldnames(analysis_data_import);
        analyzerRecord = analysis_data_import.(dataname{1});
        if isempty(analyzerRecord.XYZ_3D_filt{1})
            disp('Empty analyzer record')
            return
        end
    else
        disp('No analyzer record')
        return
    end
    runPath = fullfile('\\dm11\cardlab\Data_pez3000',dateID,runID);
    vidPath = fullfile(runPath,[videoID '.mp4']);
    vidpathH = fullfile(runPath,'highSpeedSupplement',[videoID '_supplement.mp4']);
    
    vidStats = videoStatisticsMerged(videoID,:);
    frms_per_ms = double(vidStats.record_rate(videoID))/1000;
    
    frameRefcutrate = vidStats.cutrate10th_frame_reference{videoID};
    frameReffullrate = vidStats.supplement_frame_reference{videoID};
    
    Y = (1:numel(frameRefcutrate));
    xi = (1:numel(frameRefcutrate)*10);
    yi = repmat(Y,10,1);
    yi = yi(:);
    [~,xSuppl] = ismember(frameReffullrate,xi);
    objRefVec = ones(1,numel(frameRefcutrate)*10);
    objRefVec(xSuppl) = 2;
    yi(xSuppl) = (1:numel(frameReffullrate));
    frmRefVec = [xi(:)';yi(:)';objRefVec(:)'];
    if runMode == 1
%         event2plot{vRef} = -diff(startVec(vRef,1:2));
        frm2alignPre = startVec(vRef,2);%%%%%%% aligns to fot
        event2plot(vRef) = startVec(vRef,1);
    elseif runMode == 2
        event2plot(vRef) = diff(startVec(vRef,1:2));
        frm2alignPre = startVec(vRef,1);
    elseif runMode == 3
        frm2alignPre = startVec(vRef,3);
        event2plot(vRef) = startVec(vRef,2);
    elseif runMode == 4
        event2plot(vRef) = startVec(vRef,3)-startVec(vRef,5);
        frm2alignPre = startVec(vRef,3);
    elseif runMode == 5
        event2plot(vRef) = diff(startVec(vRef,1:2));
        frm2alignPre = startVec(vRef,6);
    elseif runMode == 6
        event2plot(vRef) = diff(startVec(vRef,1:2));
        frm2alignPre = startVec(vRef,7);
    elseif runMode == 7
        frm2alignPre = startVec(vRef,8);
        event2plot(vRef) = startVec(vRef,2);
    end
    if isnan(frm2alignPre), frm2alignPre = 1; end
    event2plot(vRef) = event2plot(vRef)-frm2alignPre;
    frm2align = frm2alignPre+baseFrmVec-1;
    negFrmRefs = frm2align < 1;
    oobRefs = frm2align > size(frmRefVec,2);
    frm2align(negFrmRefs) = 1;
    frm2align(oobRefs) = size(frmRefVec,2);
    frameReferenceCell{vRef} = frmRefVec(:,frm2align);
    outOfRangeCell{vRef} = negFrmRefs | oobRefs;
    
    vidObjA{vRef} = VideoReader(vidPath); %#ok<TNMLP>
    if exist(vidpathH,'file')
        vidObjB{vRef} = VideoReader(vidpathH); %#ok<TNMLP>
    else
        disp('no supplement')
        vidObjB{vRef} = vidObjA;
    end
    
    frmW = vidObjA{vRef}.Width;
    localObj = vidObjA{vRef};
    for itry = 1:5
        try
            video_init = read(localObj,1);
            break
        catch
            pause(1)
        end
    end
    if viewMode == 1
        frame_01_gray = video_init(end-frmW+1:end,:,1);
    elseif viewMode == 2
        frame_01_gray = video_init(1:frmW,:,1);
    end
    tI = log(double(frame_01_gray)+backoff);
    frame_01_gray = uint8(255*(tI/log(255+backoff)-log(backoff)/log(255+backoff)));
    [~,frm_graymap] = gray2ind(frame_01_gray,256);
    lowhigh_in = stretchlim(frm_graymap,tol);
    lowhigh_in(1) = lowhigh_in(1)+range(lowhigh_in)*lowhighFac(1);
    lowhigh_in(2) = lowhigh_in(2)-range(lowhigh_in)*lowhighFac(2);
    frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],gammaAdj);
    frm_remap = uint8(frm_remap(:,1).*255);
    frm_remapCell{vRef} = frm_remap;
    
    if viewMode == 1
        xyTheta{vRef} = analyzerRecord.bot_points_and_thetas{1};
    else
        xyTheta{vRef} = analyzerRecord.top_points_and_thetas{1};
    end
    fc = 150; % cutoff frequency
    fs = frms_per_ms*1000; % sample rate
    filtHz = fc/(fs/2);
    d1 = designfilt('lowpassiir','FilterOrder',1, ...
        'HalfPowerFrequency',filtHz,'DesignMethod','butter');
    for iterFilt = 1:3
        if iterFilt == 3
            xyTheta{vRef} = unwrap(xyTheta{vRef});
        end
        xyTheta{vRef}(:,iterFilt) = filtfilt(d1,xyTheta{vRef}(:,iterFilt));
    end
    flyLength(vRef) = analyzerRecord.fly_length{1};
end
%%
flyLength = flyLength*1.5;%% bigger number makes smaller flies %%
sizeRange = ([max(flyLength) min(flyLength)]);
destTheta = 90;


[sortDiffs,vidReferenceVec] = sort(event2plot);
maxDims = [1088,1920];
origTheta = round(xyTheta{1}(1,3)*(180/pi));
origPos = xyTheta{1}(1,1:2);
outputIm = flyRotate_and_center(frame_01_gray,origPos,origTheta,destTheta,flyLength(1),sizeRange,1);
destDim = [size(outputIm,1) size(outputIm,1)];
montDimInit = destDim.*[rowCt colCt];
[minVal,minRef] = min(maxDims-montDimInit(1:2));
if minVal < 0
    resizeFac = maxDims(minRef)/montDimInit(minRef);
else
    resizeFac = 1;
end
montDimSml = round(fliplr(montDimInit(1:2)*resizeFac));
montDimSml = [montDimSml(1) maxDims(1)-montDimSml(2)-100];
montDimSml(2) = 200;
baseFrame = uint8(zeros(fliplr(montDimSml)));
if runMode == 1
    zeroLabel = 'frame of takeoff';
    yLabel = '% wings up';
    eventName = 'time to takeoff';
    labelOff = 0.285;
elseif runMode == 2
    zeroLabel = 'frame of wing up';
    yLabel = '% jumping';
    eventName = 'time to wing raise';
    labelOff = 0.02;
elseif runMode == 3
    zeroLabel = 'frame of stimulus start';
    yLabel = '% jumping';
    labelOff = 0.23;
    eventName = 'time reference';
elseif runMode == 4
    
    if stimType == 2
        zeroLabel = '  ';
        yLabel = 'mW/mm ';
    else
        zeroLabel = 'frame of stimulus start';
        yLabel = '% tracking';
    end
    labelOff = 0.23;
    eventName = 'time since lights-on';
elseif runMode == 5
    zeroLabel = 'frame of wing down';
    yLabel = '% jumping';
    eventName = 'time to wing down';
    labelOff = 0.02;
elseif runMode == 6
    zeroLabel = 'frame of leg push';
    yLabel = '% jumping';
    eventName = 'time to leg push';
    labelOff = 0.02;
elseif runMode == 7
    zeroLabel = 'frame of departure';
    yLabel = '% departed';
    labelOff = 0.25;
    eventName = 'movement frame';
end

textBase = baseFrame(1:100,:);
textBase(end-1:end,:) = 100;
[~,labelA] = fileparts(destPath);
labelOps = {'name: ';labelA;'exptID: ';exptID;[eventName ' (ms):']
    [yLabel ':'];'current frame: '};
fontSz = 20;
labelPos = {[0.05 0.4];[0.1 0.4];[0.77 0.4];[0.83 0.4];[0.05 0.9];[0.47 0.9];[0.77 0.9]};
labelCt = numel(labelOps);
for iterL = 1:labelCt
    textBase = textN2im_v2(textBase,labelOps(iterL),fontSz,...
        labelPos{iterL},'left');
    if stimType == 2 && iterL == 6
        textBase = textN2im_v2(textBase,{'2'},round(fontSz*0.6),...
            [0.533 0.74],'left');
    end
end
% imshow(textBase)
%%
graphBase = baseFrame;
graphBaseT = graphBase;
baseXa = round(0.13*montDimSml(1));   baseXb = round(0.93*montDimSml(1));
baseYa = round(0.2*montDimSml(2));    baseYb = round(0.7*montDimSml(2));
xOutput = (1:baseXb-baseXa)+baseXa;
if numel(sortDiffs) < 2
    sortDiffs = repmat(sortDiffs,3,1);
end

if stimType == 2% && runMode == 4
    video_pulse = traceVec(baseFrmVec);
%     if range(video_pulse) > 0
%         video_pulse = (video_pulse-min(video_pulse))/range(video_pulse)*100;
%     end
elseif runMode == 3
    traceVec = cat(2,traceVec,zeros(1,max(baseFrmVec))+traceVec(end));
    video_pulse = traceVec(baseFrmVec)*100;
else
    video_pulse = zeros(vidCount,montFrmCt);
    for vRef = 1:vidCount
        for vP = 1:size(video_pulse,2)
            if baseFrmVec(vP) > sortDiffs(vRef)
                video_pulse(vRef,vP:end) = 1;
            end
        end
    end
    video_pulse = sum(video_pulse);
    video_pulse = video_pulse/numel(sortDiffs)*100;
end
% plot(baseFrmVec,video_pulse)
if stimType == 2
    maxInt = 5;
else
    maxInt = 100;
end

xNput = round(linspace(baseXa,baseXb,numel(video_pulse)));
yNput = video_pulse/maxInt;
yNput = abs(yNput-1);
[~,NputRefs] = unique(xNput);
yOutput = interp1(xNput(NputRefs),yNput(NputRefs),xOutput,'nearest','extrap');
yOutput = round(yOutput*(baseYb-baseYa)+baseYa);
graphBase(sub2ind(size(graphBase),yOutput,xOutput)) = 200;
graphBase(sub2ind(size(graphBase),yOutput+1,xOutput)) = 200;
graphBase(sub2ind(size(graphBase),yOutput+2,xOutput)) = 200;
graphBase(sub2ind(size(graphBase),yOutput-1,xOutput)) = 200;
graphBase(sub2ind(size(graphBase),yOutput-2,xOutput)) = 200;

labelOps = {'0';num2str(maxInt);' ';' ';yLabel;zeroLabel};
fontSz = 20;
if runMode == 1
    shortRef = round(find(baseFrmVec == (-41))/numel(baseFrmVec)*numel(xOutput)+baseXa);
    graphBase(baseYa:baseYb,shortRef-1:shortRef+1,:) = 255;
end
eventPos = round(find(baseFrmVec == 0)/numel(baseFrmVec)*numel(xOutput)+baseXa);
graphBaseT(baseYa:baseYb+round(montDimSml(2)*0.2),eventPos-1:eventPos+1,:) = 255;
labelPos = {[baseXa/montDimSml(1)-0.02 baseYb/montDimSml(2)+0.05]
    [baseXa/montDimSml(1)-0.02 baseYa/montDimSml(2)+0.05]
    [baseXa/montDimSml(1)+0.01 baseYb/montDimSml(2)+0.2]
    [baseXb/montDimSml(1) baseYb/montDimSml(2)+0.2]
    [baseXa/montDimSml(1)-0.02 mean([baseYa/montDimSml(2)+0.05,baseYb/montDimSml(2)+0.05])]
    [mean([baseXa/montDimSml(1),baseXb/montDimSml(1)])+labelOff baseYb/montDimSml(2)+0.23]};
labelCt = numel(labelOps);
for iterL = 1:labelCt
    graphBaseT = textN2im_v2(graphBaseT,labelOps(iterL),fontSz,...
        labelPos{iterL},'right');
    if stimType == 2 && iterL == 5
        graphBaseT = textN2im_v2(graphBaseT,{'2'},round(fontSz*0.6),...
            labelPos{iterL}-[0.004 0.08],'right');
    end
end
graphBase = cat(3,max(graphBase,graphBaseT),graphBaseT,graphBaseT)*0.8;
% imshow(graphBase)
% %%
vidLabelCell = cell(vidCount,1);
vidLabelBase = uint8(zeros(destDim(1),destDim(2)));
fontF = 30;
passBool = false;
labelPos = [0.1 0.12];
for iterM = 1:vidCount
    vRef = vidReferenceVec(iterM);
    videoID = videoList{vRef};
    vidspl = strsplit(videoID,'_');
    vidLabelStr = [vidspl{1}(4:end) '_' vidspl{3} '_' vidspl{5}(4:end)];
    while ~passBool
        try
            textN2im_v2(vidLabelBase,vidLabelStr,fontF,...
                labelPos,'right');
            passBool = true;
        catch
            if fontF == 10
                error('text font got too small')
            else
                fontF = fontF-2;
            end
        end
    end
    passBool = false;
    if iterM == 1
        fontF = fontF-2;
    end
    vidLabel = textN2im_v2(vidLabelBase,vidLabelStr,fontF,...
        labelPos,'right');
    %     imshow(vidLabel*0.5)
    vidLabelCell{iterM} = repmat(vidLabel,[1 1 3]);
end
%
if writeVid
    try
        writeObj = VideoWriter(destPath,'MPEG-4');
        disp(['writing to ' destPath])
    catch
        disp(['FAIL - couldn not write to ' destPath])
        return
    end
    open(writeObj)
end

frmStorage = cell(1,vidCount);
frmLast = zeros(vidCount,1);

%%
for iterF = 1:montFrmCt
    montyCell = cell(rowCt,colCt);
    for iterM = 1:vidCount
        vRef = vidReferenceVec(iterM);
        frmRef = frameReferenceCell{vRef}(1,iterF);
        %     videoID = videoList{vRef};
        frameRead = frameReferenceCell{vRef}(2,iterF);
        if iterF > 1
            frmLast(vRef) = frameReferenceCell{vRef}(2,iterF-1);
        else
            frmLast(vRef) = 0;
        end
        if frmLast(vRef) == frameRead
            frmA = frmStorage{vRef};
        else
            readObjRef = frameReferenceCell{vRef}(3,iterF);
%             [iterF iterM readObjRef]
            if readObjRef == 1
                frmA = read(vidObjA{vRef},frameRead);
            else
                frmA = read(vidObjB{vRef},frameRead);
            end
            if viewMode == 1
                frame_01_gray = frmA(end-frmW+1:end,:,1);
            elseif viewMode == 2
                frame_01_gray = frmA(1:frmW,:,1);
            end
            frame_01_gray = frame_01_gray(:,:,1);
            tI = log(double(frame_01_gray)+backoff);
            frmA = uint8(255*(tI/log(255+backoff)-log(backoff)/log(255+backoff)));
            frmA = intlut(frmA,frm_remapCell{vRef});
            frmStorage{vRef} = frmA;
        end
        
        if frmRef <= size(xyTheta{vRef},1)
            if event2plot(vRef) < baseFrmVec(iterF)
                fillFlag = 2;
            else
                fillFlag = 3;
            end
            origPos = xyTheta{vRef}(frmRef,1:2);
            origTheta = round(xyTheta{vRef}(frmRef,3)*(180/pi));
        else
            fillFlag = 1;
            origPos = xyTheta{vRef}(end,1:2);
            origTheta = round(xyTheta{vRef}(end,3)*(180/pi));
        end
        if allowRotation
            frmOneRef = frameReferenceCell{vRef}(1,1);
            if frmOneRef > size(xyTheta{vRef},1)
                frmOneRef = size(xyTheta{vRef},1);
            end
            origTheta = round(xyTheta{vRef}(frmOneRef,3)*(180/pi));
        end
        if allowMovement
            frmOneRef = frameReferenceCell{vRef}(1,1);
            if frmOneRef > size(xyTheta{vRef},1)
                frmOneRef = size(xyTheta{vRef},1);
            end
            origPos = round(xyTheta{vRef}(frmOneRef,1:2));
        end
        if viewMode == 2
            origPos(2) = xyTheta{vRef}(1,2);
            destTheta = origTheta;
        end
        if showDots == 0
            fillFlag = 4;
        end
        [outputIm,sourceIm] = flyRotate_and_center(frmA,origPos,origTheta,destTheta,flyLength(vRef),sizeRange,fillFlag);
        if viewMode == 2
            outputIm = repmat(sourceIm,[1 1 3]);
            outputIm = outputIm(1:destDim(1),:,:);
        end
        if overlayFrmOne == 1
            if iterF == 1
                if iterM == 1
                    frm2compare = cell(vidCount,1);
                end
                frm2compare{iterM} = outputIm(:,:,3)*0.7;
            else
                outputIm = cat(3,outputIm(:,:,1),max(outputIm(:,:,2),frm2compare{iterM}),outputIm(:,:,3));
            end
        end
        labelPos = [0.1 0.2];
        if showVideoReference == 1
            labelIm = textN2im_v2(vidLabelCell{iterM},{num2str(frmRef)},fontF,...
                labelPos,'right');
            outputIm = max(outputIm,labelIm*0.4);
        end
        if outOfRangeCell{vRef}(iterF)
            outputIm = outputIm/3;
        end
        montyCell{montPos(iterM,1),montPos(iterM,2)} = outputIm;
    end
    if iterM < maxFlies
        montyDiff = maxFlies-iterM;
        for iterFill = 1:montyDiff
            montyCell{montPos(iterM+iterFill,1),montPos(iterM+iterFill,2)} = montyCell{1}.*0;
        end
    end
    montyFrm = cell2mat(montyCell);
    if resizeFac ~= 1
        montyFrm = imresize(montyFrm,round(resizeFac*montDimInit));
    end
    %%
    formatSa = ['%0' num2str(numel(num2str(round(max(abs(baseFrmVec/frms_per_ms)))))) 's'];
    if stimType == 2
        sigVal = 10;
    else
        sigVal = 1;
    end
    formatSb = ['%0' num2str(numel(num2str(round(video_pulse(iterF)*sigVal)/sigVal))) 's'];
    formatSc = ['%0' num2str(numel(num2str(round(baseFrmVec(iterF))))) 's'];
    labelOps = {sprintf(formatSa,num2str(abs(round(baseFrmVec(iterF)/frms_per_ms))))
        sprintf(formatSb,num2str(round(video_pulse(iterF)*sigVal)/sigVal))
        sprintf(formatSc,num2str(round(baseFrmVec(iterF))))};
    if round(baseFrmVec(iterF)/frms_per_ms) < 0
        labelOps{1} = ['-' labelOps{1}];
    end
    labelPos = {[0.35 0.9]
        [0.65 0.9]
        [0.98 0.9]};
    textFrm = textBase;
    kern = 0.5;
    for iterL = 1:3
        textFrm = textN2im_v2(textFrm,labelOps(iterL),fontSz,...
            labelPos{iterL},'right',kern);
    end
    frmFullC = [repmat(textFrm*0.8,[1 1 3]);montyFrm];
    frmFullC(end-1:end,:,:) = 100;
    frmFullD = [frmFullC;graphBase];
    frmFullD(baseYa+size(frmFullC,1):baseYb+size(frmFullC,1),xNput(iterF),:) = 235;
    frmFullD(baseYa+size(frmFullC,1):baseYb+size(frmFullC,1),xNput(iterF)+1,:) = 235;
    if writeVid
        frmFullD = imresize(frmFullD,0.75);
        writeVideo(writeObj,frmFullD)
    else
        imshow(frmFullD)
        drawnow
        return
    end
end
if writeVid
    close(writeObj)
end

end
