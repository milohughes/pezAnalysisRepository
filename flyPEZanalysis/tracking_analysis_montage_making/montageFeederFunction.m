function montageFeederFunction
%%
rng('default');
rng(19);
%%%%%
graphTable = makeGraphingTable;
%% time to contact plots and table making
clearvars -except graphTable

makeGraphOptionsStruct([],'montage')
%%%%%
plotTable = addPlotData(graphTable);

%% %%%
optionsPath = 'Z:\Data_pez3000_analyzed\WRW_graphing_variables\graphOptions.mat';
graphOptionsLoading = load(optionsPath);
graphOptions = graphOptionsLoading.graphOptions;

totalComps = 1;
thisComp = 1;
% viewMode - 1 bottom, underside view
% viewMode - 2 top, side view
for viewMode = 1:2
% runMode - 1 aligned to fot, sort by wing mvmnt
% runMode - 2 aligned to frame of wing mvmnt, sort by differential
% runMode - 3 aligned to stimulus start, sort by fot
% runMode - 4 like 3, has been used for gratings and activation
% runMode - 5 aligned to frame of wing down, sort by differential
% runMode - 6 aligned to frame of leg push, sort by differential
% runMode - 7 aligned to frame of movement
runMode = 3;
stimType = 1;
% stimType - 1 looming stimulus
% stimType - 2 other
allowRotation = true;
allowMovement = true;
randPermute = false;

rowCt = 3;
colCt = 10;
maxMontages = 1;

specificVideos = 0;

specificID = 0;
id2use = 'SS00942';
destDir = fullfile(fileparts(graphOptions.excelPath),'montage_vids');

returnData = plotTable.returnData;
uniqIDlist = plotTable.Properties.RowNames;
plotIDlist = plotTable.plotID;
videoArray = plotTable.videoList;
traceArray = cell(size(videoArray));
if stimType == 2
    
    for iterT = 1:numel(traceArray)
        dataID = uniqIDlist{iterT};
        frms_per_ms = round(plotTable.recordRate(dataID)/1000);
        ms2frm = @(x) round(x*frms_per_ms);
        excelPath = graphOptions.excelPath;
        if graphOptions.sliceOption == 1
            actKey = readtable(excelPath,'ReadRowNames',false,'Sheet','activation_key');
            actKey = table2cell(actKey);
            actKey = actKey(:,1:2);
        end
        varDir = [filesep filesep 'DM11' filesep 'cardlab' filesep,...
            'pez3000_variables' filesep 'photoactivation_stimuli'];
        if ~exist('fitFun','var')
            dataDir = 'Z:\pez3000_variables';
            fitFunLoad = load(fullfile(dataDir,'photoactivationTransferFunction.mat'),'fitFun');
            fitFun = fitFunLoad.fitFun;
            funStr = func2str(fitFun);
            funStr = cat(2,funStr(1:4),'4*(',funStr(5:end),')');
            fitFun = str2func(funStr);
        end
        prct2mW = fitFun;% generated from avg measurements of LEDs
        if  graphOptions.sliceOption == 1
            var2use = strcmp(actKey(:,2),plotTable.stimInfo{dataID}{1});
            varName = actKey{var2use,1};
        else
            varName = plotTable.stimInfo{dataID}{1};
        end
        varPath = fullfile(varDir,[varName '.mat']);
        if exist(varPath,'file')
            
            photoVar = load(varPath);
            if contains(varName,'ramp')
                varDur = ms2frm(photoVar.var_tot_dur*1.028);
                prctPwr = zeros(1,varDur);
                rampVals = linspace(photoVar.var_ramp_init,photoVar.var_intensity,ms2frm(photoVar.var_ramp_width*1.028));
                prctPwr(1:numel(rampVals)) = rampVals;
                prctPwr(prctPwr < 3) = 0;
                Woutput = prct2mW(prctPwr);
                Woutput(Woutput < 0) = 0;
                Woutput = Woutput/1000;% converts from uW to mW
                power = Woutput;
            elseif contains(varName,'pulse')
                varDur = ms2frm(photoVar.var_tot_dur*1.028);
                pulsePos = photoVar.zPulse;
                prctPwr = photoVar.aPulse;
                Woutput = prct2mW(prctPwr);
                Woutput(Woutput < 0) = 0;
                Woutput = Woutput/1000;% converts from uW to mW
                power = zeros(1,varDur)+Woutput(end);
                pulsePos(1) = 1;
                for i = 1:numel(pulsePos)-1
                    startPt = ms2frm(pulsePos(i)*1.028);
                    endPt = ms2frm(pulsePos(i+1)*1.028);
                    power(startPt:endPt) = Woutput(i);
                end
            else
                error('unknown photoactivation stimulus')
            end
            traceArray{iterT} = power;
        else
            traceArray{iterT} = zeros(1,plotTable.stimDur(dataID));
        end
    end
else
    for iterT = 1:numel(traceArray)
        dataID = uniqIDlist{iterT};
        frms_per_ms = round(plotTable.recordRate(dataID)/1000);
        ms2frm = @(x) round(x*frms_per_ms);
        ellovervee = plotTable.lv(dataID);
        initStimSize = plotTable.startSize(dataID);
        finalStimSize = plotTable.stopSize(dataID);
        minTheta = deg2rad(initStimSize);
        maxTheta = deg2rad(finalStimSize);
        stimStartTime = ellovervee/tan(minTheta/2);
        stimEndTime = ellovervee/tan(maxTheta/2);
        stimDurFrm = ms2frm(abs(stimEndTime-stimStartTime));
        stimTimeVector = linspace(stimStartTime,stimEndTime,stimDurFrm);
        stimY = 2*atan(ellovervee./stimTimeVector)./(pi/180);
%         stimTimeVector = fliplr(stimTimeVector);
%         stimTimeVector = stimTimeVector-stimTimeVector(end);
%         stimX = ms2frm(stimTimeVector);
%         altYlabel = (0:60:180);
%         altYpos = (altYlabel-min(stimThetaVector))/range(stimThetaVector);
        stimY = (stimY-min(stimY))/range(stimY);
%         clf
%         plot(stimY,'color',[0.5 0 0])
%         return
        traceArray{iterT} = stimY;
    end
end

if specificID == 1
    returnData = returnData(strcmp(uniqIDlist,id2use));
    videoArray = videoArray(strcmp(uniqIDlist,id2use));
    traceArray = traceArray(strcmp(uniqIDlist,id2use));
    plotIDlist = plotIDlist(strcmp(uniqIDlist,id2use));
    uniqIDlist = uniqIDlist(strcmp(uniqIDlist,id2use));
end

if specificVideos == 1
    annotationsTable = readtable(graphOptions.excelPath,'Sheet','annotations');
    vids2keep = annotationsTable.file_name;
    for iterT = 1:numel(traceArray)
        vidLogic = cellfun(@(x) max(strcmp(vids2keep,x)),videoArray{iterT});
        returnData{iterT} = returnData{iterT}(vidLogic,:);
        videoArray{iterT} = videoArray{iterT}(vidLogic);
    end
    
end

%%

dataCt = size(uniqIDlist,1);
% anaGrpList = unique(plotTable.groupID);
% grpCt = numel(anaGrpList);



montPosR = repmat((1:rowCt),colCt,1);
montPosC = repmat((1:colCt)',1,rowCt);
montPos = [montPosR(:) montPosC(:)];
maxFlies = size(montPos,1);

montTally = 0;
videoListCell = cell(0);
startVecCell = cell(0);
destNameCell = cell(0);
traceCell = cell(0);
for iterM = 1:dataCt
    groupName = plotIDlist{iterM};
    startVecFull = returnData{iterM};
    videoListFull = videoArray{iterM};
    if randPermute == 1
        vidRefs = randperm(numel(videoListFull));%%%%%%%%%%%%% Random permutation
    else
        vidRefs = (1:numel(videoListFull));%%%%%%%%%%%% No permutation
    end
    videoListFull = videoListFull(vidRefs);
    startVecFull = startVecFull(vidRefs,:);
    vidsAvailable = numel(videoListFull);
    if vidsAvailable == 0
        continue
    end
    vidRefBrksPre = (1:maxFlies:vidsAvailable);
    vidRefBrks = [vidRefBrksPre vidsAvailable+1];
    montCt = numel(vidRefBrks)-1;
    if montCt > maxMontages, montCt = maxMontages; end
    for iterMont = 1:montCt
        montTally = montTally+1;
        videoListCell{montTally} = videoListFull(vidRefBrks(iterMont):vidRefBrks(iterMont+1)-1);
        startVecCell{montTally} = startVecFull(vidRefBrks(iterMont):vidRefBrks(iterMont+1)-1,:);
        if montCt > 1
            destName = [groupName '_mont' num2str(iterMont) 'of' num2str(montCt)];
        else
            destName = groupName;
        end
        destNameCell{montTally} = destName;
        traceCell(montTally) = traceArray(iterM);
    end
end
%%
vidRefBreaks = round(linspace(1,montTally,totalComps+1));
if ~isdir(fullfile(destDir,'videoReference')), mkdir(fullfile(destDir,'videoReference')), end
parfor iterC = vidRefBreaks(thisComp):vidRefBreaks(thisComp+1)
    destName = destNameCell{iterC};
    disp(destName)
    savedVarPath = fullfile(destDir,'videoReference',[destName '_videoReference.mat']);
    videoList = videoListCell{iterC};
    startVec = startVecCell{iterC};
    traceVec = traceCell{iterC};
    if viewMode == 1
        destPathA = fullfile(destDir,['bottomView_' destName]);
    elseif viewMode == 2
        destPathA = fullfile(destDir,['sideView_' destName]);
    end
    if runMode == 1
        destPath = [destPathA '_aligned2takeoff.mp4'];
    elseif runMode == 2
        destPath = [destPathA '_aligned2wingup.mp4'];
    elseif runMode == 3 || runMode == 4
        destPath = [destPathA '_aligned2stim.mp4'];
    elseif runMode == 5
        destPath = [destPathA '_aligned2wingdown.mp4'];
    elseif runMode == 6
        destPath = [destPathA '_aligned2legpush.mp4'];
    elseif runMode == 7
        destPath = [destPathA '_aligned2movement.mp4'];
    end
    parSaveMonty(savedVarPath,videoList,montPos,startVec,...
        destPath,runMode,viewMode,stimType,allowRotation,allowMovement,traceVec)
    try
        vidMontage_flexible_exploration(savedVarPath,1)
    catch ME
        getReport(ME)
    end
%     break
end
end
end
function parSaveMonty(savePath,videoList,montPos,startVec,destPath,runMode,viewMode,stimType,allowRotation,allowMovement,traceVec) %#ok<INUSD>
save(savePath,'videoList','montPos','startVec',...
    'destPath','runMode','viewMode','stimType','allowRotation','allowMovement','traceVec')
end
