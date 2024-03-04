function [graphDataStruct,graphOptions] = getDataFromTable(dataIDlist,graphTable)
persistent graphDataStructOld graphOptionsOld
%%
if isempty(mfilename) || nargin == 0
    graphDataStructOld = [];
    graphOptionsOld = [];
end
graphOptionsLoading = load('Z:\pez3000_methods_paper\DLpsych_phys_figures\graphOptions');
graphOptions = graphOptionsLoading.graphOptions;
graphName = graphOptions.graphName;
useManual = graphOptions.useManual;
sepPathUse = graphOptions.sepPathUse;
anaGrpList = graphOptions.anaGrpList;
if ~isempty(graphOptionsOld)
    if isequal(graphOptions,graphOptionsOld)
        graphDataStruct = graphDataStructOld;
        graphOptions = graphOptionsOld;
%         return
    end
end


%%
% dataCt = size(dataIDlist,1);
% dataIDlist = dataIDlist(1:round(dataCt/2));
% dataIDlist = dataIDlist(round(dataCt/2)+1:end);

dataCt = size(dataIDlist,1);

% graphTable.Properties.VariableNames'

jumpChoice = 1;%defaults to 'jumpers'
if ~isempty(strfind(graphName,'nonjumper'))
    jumpChoice = 2;
    sepPathUse = false;
elseif ~isempty(strfind(graphName,'all'))
    jumpChoice = 3;
    sepPathUse = false;
end
jumpOps = {'jumping','nonjumping','all'};
grpCt = numel(anaGrpList);
graphDataStruct = struct;
deg2rad = @(x) x*(pi/180);
rad2deg = @(x) x./(pi/180);
medDur = median(graphTable.stimDuration);
for grpNdx = 1:grpCt
    groupLogical = strcmp(graphTable.groupLabel,anaGrpList{grpNdx});
    %     groupLogical = true(size(graphTable,1),1);
    groupTable = graphTable(groupLogical,:);
    uniqIDsGrp = groupTable.dataLabel;
    vidNdcsCell = cellfun(@(x) find(strcmp(uniqIDsGrp,x)),dataIDlist,'uniformoutput',false);
    graphDataStruct(grpNdx).groupID = anaGrpList(grpNdx);
    graphDataStruct(grpNdx).dataID = cell(1,dataCt);
    graphDataStruct(grpNdx).shortUseLogical = cell(1,dataCt);
    graphDataStruct(grpNdx).returnData = cell(1,dataCt);
    graphDataStruct(grpNdx).videoList = cell(1,dataCt);
    graphDataStruct(grpNdx).dataCount = zeros(1,dataCt);
    graphDataStruct(grpNdx).recordRate = zeros(1,dataCt);
    graphDataStruct(grpNdx).jumpCount = zeros(1,dataCt);
    graphDataStruct(grpNdx).shortUseTotal = zeros(1,dataCt);
    graphDataStruct(grpNdx).stimDur = zeros(1,dataCt);
    graphDataStruct(grpNdx).exptIDs = cell(1,dataCt);
    graphDataStruct(grpNdx).labels = cell(1,dataCt);
    for iterE = 1:dataCt
        %%
        ndx2plot = vidNdcsCell{iterE};
        if sum(ndx2plot) == 0
            continue
        end
        exptTable = groupTable(ndx2plot,:);
        stimTypeString = exptTable.Experiment_Type{1};
        stimInit = exptTable.zeroFly_StimAtStimStart;
        if strcmp('Visual_stimulation',stimTypeString)
            %%%%% Was the stimulus within acceptable boundaries??
            strPtsStim = strsplit(exptTable.stimInfo{1},'_');
            azindx = cellfun(@(x) ~isempty(strfind(x,'azi')),strPtsStim);
            exptAzi = str2double(strPtsStim{azindx}(strfind(strPtsStim{azindx},'azi')+3:end));
        else
            exptAzi = 0;
        end
        stimInit = stimInit-exptAzi;
        while sum(stimInit < -179) > 0,stimInit(stimInit < -179) = stimInit(stimInit < -179)+360;end
        while sum(stimInit > 180),stimInit(stimInit > 180) = stimInit(stimInit > 180)-360;end
        if ~isempty(strfind(graphName,'zero'))
            stimTol = 30;
        elseif ~isempty(strfind(exptTable.stimInfo{1},'grating'))
            stimTol = 90;
        elseif strcmp('Photoactivation',stimTypeString);
            stimTol = 60;
        else
            stimTol = 45;
        end
        stimBounds = [-stimTol stimTol];
        stimTest = min([stimInit > stimBounds(1),stimInit < stimBounds(2)],[],2);
        stimInit = stimInit+exptAzi;

        notCounting = ~stimTest;
        
        if useManual == 1
            jumpTest = exptTable.manualJumpTest;
            fot = exptTable.manualFot;
            fowm = exptTable.manualFowm;
            shortLogical = (fot-fowm) <= 41;
        elseif useManual == 2
            fot = exptTable.autoFot;
            fowm = NaN(size(fot));
            shortLogical = NaN(size(fot));
            jumpTest = exptTable.autoJumpTest;            
        elseif useManual == 3
            jumpTest = exptTable.manualJumpTest;
            fot = exptTable.manualFot;
            fot(isnan(jumpTest)) = exptTable.autoFot(isnan(jumpTest));
            jumpTest(isnan(jumpTest)) = exptTable.autoJumpTest(isnan(jumpTest));
            fowm = exptTable.manualFowm;
            shortLogical = (fot-fowm) <= 41;
        end
        stimStart = exptTable.stimStart;
        stimDur = exptTable.stimDuration;
        
        stimDur = zeros(size(stimDur))+1200;
%         stimDur = zeros(size(stimDur))+medDur;
        if grpNdx == 1 && iterE == 1
            disp('explicit stim dur')
        end
        graphDataStruct(grpNdx).stimDur(iterE) = stimDur(1);
        
        notCounting(isnan(jumpTest)) = true;
        jumpTest(isnan(jumpTest)) = 0;
        jumpTest = logical(jumpTest);
        nonJumpers = ~jumpTest;
        if strcmp('Photoactivation',stimTypeString);
            if strcmp(graphOptions.anaCol,'activationVSsilencing_CCX')
                threshTime = 500;%in milliseconds
            else
                threshTime = 200;%in milliseconds
%                 threshTime = stimDur;%in milliseconds
            end
            lateJumpers = fot > round(stimStart+threshTime*6);
            lateJumpers(isnan(lateJumpers)) = false;
            jumpTest(lateJumpers) = false;
            nonJumpers(lateJumpers) = true;
        end
        nonJumpers(notCounting) = false;
        jumpTest(notCounting) = false;
        earlyJumpers = fot < round(stimStart);
        earlyJumpers(isnan(earlyJumpers)) = false;
        jumpTest(earlyJumpers) = false;
        
        graphDataStruct(grpNdx).jumpCount(iterE) = sum(jumpTest);
        graphDataStruct(grpNdx).shortUseTotal(iterE) = sum(shortLogical(jumpTest));
        grpVarA = exptTable.dataLabel{1};
%         if strcmp('pulse_50ms_50pct_CTRL_DL_1500090_0028FCF_DL_1500090',grpVarA)
%             error('')
%         end
        if ~strcmp(grpVarA,dataIDlist{iterE})
            error('ID mismatch')
        end
        graphDataStruct(grpNdx).dataID(iterE) = {grpVarA};
        graphDataStruct(grpNdx).labels(iterE) = exptTable.parentsInfo(1);
        %%%%% scatter plot stuff
        if strcmp(jumpOps{jumpChoice},'jumping')
            data2keep = jumpTest;
        elseif strcmp(jumpOps{jumpChoice},'nonjumping')
            data2keep = nonJumpers;
        else
            data2keep = jumpTest | nonJumpers;
        end
        
        graphDataStruct(grpNdx).shortUseLogical(iterE) = {shortLogical(data2keep)};
        if ~isempty(strfind(graphName,'initialOrientation'))
            returnData = exptTable.rawFly_XYZpix_Trad_frmOne(data2keep,4);
        elseif ~isempty(strfind(graphName,'DirPlot'))
            if strcmp('Photoactivation',stimTypeString); continue, end
            if ~isempty(strfind(graphName,'jumpDir'))
                zeroFlyVec = exptTable.zeroFlyJump(:,1);
                rhoVec = exptTable.zeroFlyJump(:,2);
            elseif ~isempty(strfind(graphName,'departDir'))
                zeroFlyVec = exptTable.zeroFlyDept(:,1);
                rhoVec = exptTable.zeroFlyDept(:,2);
            else
                zeroFlyVec = exptTable.zeroFlyTraj(:,1);
                rhoVec = exptTable.zeroFlyTraj(:,2)*5;% x5 because the rho was the avg of 5 segments (analyzer_v12)
            end
            if ~isempty(strfind(graphName,'zeroStim'))
                if ~isempty(strfind(graphName,'trajectoryDir'))
                    dirResult = zeroFlyVec+exptTable.zeroFlyStimInit-exptAzi;
                else
                    dirResult = zeroFlyVec+exptTable.zeroFlyStimJump-exptAzi;
                end
            else
                dirResult = zeroFlyVec;
            end
            data2keep(isnan(dirResult)) = false;
            while sum(dirResult > 180) > 0,dirResult(dirResult > 180) = dirResult(dirResult > 180)-360;end
            while sum(dirResult < -179) > 0,dirResult(dirResult < -179) = dirResult(dirResult < -179)+360;end
            returnData = [dirResult(data2keep) rhoVec(data2keep)];
        elseif ~isempty(strfind(graphName,'relMotion'))
            posArray = exptTable.relativeMotion(data2keep);
            start2keep = stimStart(data2keep);
            dur2keep = stimDur(data2keep);
            returnData = NaN(numel(posArray),1);
            dur2keep(jumpTest(data2keep)) = fot(jumpTest(data2keep))-stimStart(jumpTest(data2keep))-30;
            
            for iterR = 1:numel(posArray)
                if start2keep(iterR) > numel(posArray{iterR})
                    continue
                end
                if isnan(dur2keep(iterR)) || isinf(dur2keep(iterR))
                    continue
%                     dur2keep(iterR) = 3000;
                end
                if dur2keep(iterR) < 1
                    continue
                end
                if ~isempty(strfind(graphName,'longTrans'))
                    posRef = 1;
                elseif ~isempty(strfind(graphName,'latTrans'))
                    posRef = 2;
                else
                    posRef = 3;
                end
                posXY = posArray{iterR}(start2keep(iterR):end,posRef);
                posXY(dur2keep(iterR)+1) = 0;
                posXY(dur2keep(iterR):end) = [];
                returnData(iterR) = nansum(posXY);
%                 returnData(iterR) = nanmean(posXY);
                if isempty(strfind(graphName,'longTrans')) % selects for lateral and turning
                    returnData(iterR) = abs(returnData(iterR));
                end
            end
        elseif ~isempty(strfind(graphName,'departureScatter'))
            if strcmp('Photoactivation',stimTypeString); continue, end
            zeroFlyVec = exptTable.zeroFlyJump(:,1);
            stimJump = exptTable.zeroFlyStimJump;
            %                 dirResult = zeroStimDept_degs(data2keep);% zeros relative to the fly
            dirResult = zeroFlyVec-(stimJump+exptAzi);
            while sum(dirResult > 0) > 0,dirResult(dirResult > 0) = dirResult(dirResult > 0)-360;end
            while sum(dirResult < -360) > 0,dirResult(dirResult < -360) = dirResult(dirResult < -360)+360;end
            %             dirResult = dirResult-zeroFlyStim_degs(data2keep);
            dirResult = dirResult+(stimJump+exptAzi);
            data2keep(isnan(dirResult)) = false;
            returnData = [dirResult(data2keep) stimJump(data2keep)];
        elseif ~isempty(strfind(graphName,'frameOfTakeoff'))
            normalFot = fot-stimStart;
            if strcmp(graphName,'frameOfTakeoff_frm')
                if ~strcmp('Photoactivation',stimTypeString);
                    normTo180fot = (normalFot-stimDur)/6;%hard coded for 6000 fps record rate!!!!!!!!!!!
                else
                    normTo180fot = normalFot/6;
                end
            else
                if strcmp('Photoactivation',stimTypeString);
                    error('incompatible stimulus')
                end
                initStimSize = str2double(strPtsStim{2}(1:strfind(strPtsStim{2},'to')-1));
                ellovervee = str2double(strPtsStim{3}(strfind(strPtsStim{3},'lv')+2:end));
        
                graphDataStruct(grpNdx).ellovervee(iterE) = ellovervee;
                graphDataStruct(grpNdx).initStimSize(iterE) = initStimSize;
                if strcmp(graphName,'frameOfTakeoff_deg')
                    finalStimSize = 360;
                else
                    finalStimSize = str2double(strPtsStim{2}(strfind(strPtsStim{2},'to')+2:end));
                end
                graphDataStruct(grpNdx).finalStimSize(iterE) = finalStimSize;
                minTheta = deg2rad(initStimSize);
                maxTheta = deg2rad(finalStimSize);
                stimStartTime = ellovervee/tan(minTheta/2);
                stimEndTime = ellovervee/tan(maxTheta/2);
                fotTime = stimStartTime-normalFot/6;
                fotTheta = 2.*atan(ellovervee./fotTime);
                normTo180fot = rad2deg(fotTheta);
                normTo180fot(fotTime < 0) = normTo180fot(fotTime < 0)+360;
                normTo180fot(fotTime < stimEndTime) = normTo180fot(fotTime < stimEndTime)+360;
            end
            returnData = normTo180fot(data2keep);
%         elseif ~isempty(strfind(graphName,'short2ctrlRatio'))
%             returnData
        elseif ~isempty(strfind(graphName,'minDeltaZ'))
            returnData = exptTable.minZ_mm(data2keep,1);
        elseif ~isempty(strfind(graphName,'maxDeltaZ'))
            returnData = exptTable.maxZ_mm(data2keep,1);
        elseif ~isempty(strfind(graphName,'deltaHeading'))
            deltaHeadingNet = abs(exptTable.zeroFlyStimJump-stimInit);
            returnData = deltaHeadingNet(data2keep);
%             returnData = exptTable.deltaHeadingNet(data2keep,1);
%             returnData{iterE,grpNdx} = exptTable.deltaHeadingCumSum(scatterTest,1);
        elseif ~isempty(strfind(graphName,'pitch'))
            returnData = exptTable.pitch75frm(data2keep,1);
        elseif ~isempty(strfind(graphName,'accelMax'))
            returnData = exptTable.accelMax(data2keep);
        elseif ~isempty(strfind(graphName,'accelFrm'))
            returnData = (exptTable.accelMaxFrm(data2keep)-fot(data2keep))/6;
        elseif ~isempty(strfind(graphName,'velMax'))
            returnData = exptTable.velMax(data2keep);
        elseif ~isempty(strfind(graphName,'velFrm'))
            returnData = (exptTable.velMaxFrm(data2keep)-fot(data2keep))/6;
        elseif ~isempty(strfind(graphName,'fromCenter'))
            returnData = exptTable.distFromCenter_pix(data2keep);
        elseif strcmp(graphName,'wing2fot')
            sepPathUse = false;
%             x_start = 0;    x_end = 7;  x_step = .075;
%             histVals = hist(histVals,(x_start:x_step:x_end));
            returnData = fot(data2keep)-fowm(data2keep);
%             returnData = histVals+rand(size(histVals));
        elseif ~isempty(strfind(graphName,'departureElevation'))
            returnData = exptTable.departure_elevation(data2keep);
%             sepPathUse = false;
        elseif ~isempty(strfind(graphName,'Dist'))
            if ~isempty(strfind(graphName,'departureDist3D'))
                returnData = exptTable.XYZdistPreNpost(data2keep,2)/1.5;
%                 returnData(returnData < 0.1) = NaN;
            elseif ~isempty(strfind(graphName,'departureDistXY'))
                returnData = exptTable.zeroFlyDept(data2keep,2);
            elseif ~isempty(strfind(graphName,'jumpDistXY'))
                returnData = exptTable.zeroFlyJump(data2keep,2);
            end
%             sepPathUse = false;
        elseif ~isempty(strfind(graphName,'spaghettiPlot'))
            if ~isempty(strfind(graphName,'zeroFly'))
                dirResult = zeros(1,sum(data2keep));% zeros relative to the fly
            elseif ~isempty(strfind(graphName,'zeroStim'))
                dirResult = stimInit(data2keep);% zeros relative to the stimulus
            end
            dirResult = deg2rad(dirResult);
            posArray = exptTable.zeroFlyTheta_XY_mm(data2keep);
            for iterReor = 1:numel(posArray)
                posXY = double(posArray{iterReor}(:,1:2))/1000;
                [posTheta,posRho] = cart2pol(posXY(:,1),posXY(:,2));
                posTheta = posTheta-dirResult(iterReor);
                [posX,posY] = pol2cart(posTheta,posRho);
                posArray{iterReor} = cat(2,[posX;NaN],[posY;NaN]);
            end
            returnData = cat(1,posArray{:});
        elseif ~isempty(strfind(graphName,'wing2fot_histogram'))
            histVals = (fot(data2keep)-fowm(data2keep));
            histVals = log(histVals./6);
            returnData = histVals;
        elseif ~isempty(strfind(graphName,'overlay'))
            if ~isempty(strfind(graphName,'speed'))
                vecRef = 1;     scaleFac = 10;  fotNorm = true;
            elseif ~isempty(strfind(graphName,'acceleration'))
                vecRef = 2;     scaleFac = 100; fotNorm = true;
            else
                vecRef = 1;     scaleFac = 1; fotNorm = false;
            end
            if fotNorm
                padVal = 60;
                data2keep(fot <= padVal) = false;
                subfot = fot(data2keep);
            end
            if ~isempty(strfind(graphName,'turningVel'))
                mvmntArray = exptTable.turningVector(data2keep);
                xmax = max(cellfun(@(x) numel(x),mvmntArray));
            else
                mvmntArray = exptTable.speed_accel_mm(data2keep);
            end
            
            for iterPad = 1:numel(mvmntArray)
                if fotNorm
                    mvmntVec = [double(mvmntArray{iterPad}(:,vecRef));NaN(padVal,1)];
                    mvmntVec = mvmntVec(subfot(iterPad)-padVal:subfot(iterPad)+padVal);
                else
                    if ~isempty(strfind(graphName,'turningVel'))
                        mvmntVecA = smooth(double(mvmntArray{iterPad}(:,vecRef)),15);
                    else
                        mvmntVecA = double(mvmntArray{iterPad}(:,vecRef));
                    end
                    mvmntVec = [mvmntVecA;NaN(xmax-numel(mvmntVecA)+1,1)];
                end
                mvmntArray{iterPad} = mvmntVec/scaleFac;
            end
            returnData = cat(2,mvmntArray{:});
        elseif strcmp(graphName,'groundTruthing_all')
            returnData = [exptTable.centerDist(data2keep) fot(data2keep) exptTable.maxDist(data2keep) exptTable.trkEnd(data2keep)];
        else % has info for montage
            returnArray = [fowm fot stimStart stimDur exptTable.trkEnd];
            returnData = returnArray(data2keep,:);
            if ~isempty(strfind(graphName,'escapeFrequency'))
                data2keep = jumpTest | nonJumpers;
            end
        end
        graphDataStruct(grpNdx).returnData(iterE) = {returnData};
        vidList = exptTable.Properties.RowNames;
        graphDataStruct(grpNdx).videoList(iterE) = {vidList(data2keep)};
        graphDataStruct(grpNdx).dataCount(iterE) = sum(data2keep);
        graphDataStruct(grpNdx).recordRate(iterE) = max(exptTable.recRate);
        graphDataStruct(grpNdx).exptIDs(iterE) = {unique([graphDataStruct(grpNdx).exptIDs{iterE};unique(exptTable.exptID)])};
    end
end

graphDataStructOld = graphDataStruct;
graphOptions.sepPathUse = sepPathUse;
graphOptions.jumpChoice = jumpChoice;
graphOptions.dataCt = dataCt;
graphOptions.dataIDlist = dataIDlist;
graphOptions.graphName = graphName;
graphOptionsOld = graphOptions;
