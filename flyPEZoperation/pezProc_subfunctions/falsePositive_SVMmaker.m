function falsePositive_SVMmaker

clear all
set2use = 2;
stimType = 'Photoactivation';%'Visual_stimulation' vs 'Photoactivation'
if set2use == 1
%     load('Y:\WryanW\labmeetingPrep_20140907\graphingVars_collection19_withSVMcorrection')
    load('Y:\WryanW\labmeetingPrep_20140907\graphingVars_collection19_noSVMcorrection')
else
%     load('Y:\WryanW\labmeetingPrep_20140907\graphingVars_collections5and8_withSVMcorrection')
    load('Y:\WryanW\labmeetingPrep_20140907\graphingVars_collections5and8_noSVMcorrection')
end

%%
analysisDir = fullfile('\\dm11\cardlab','Data_pez3000_analyzed');
exptSumName = 'experimentSummary.txt';
exptSumPath = fullfile(analysisDir,exptSumName);
experimentSummary = readtable(exptSumPath,'ReadRowNames',true);
exptNames = experimentSummary.Properties.RowNames;
exptNames = cellfun(@(x) sprintf('%016s',x),exptNames,'uniformoutput',false);
experimentSummary.Properties.RowNames = exptNames;
exptList = unique(cellfun(@(x) x(29:44),videoList,'uniformoutput',false));
totalVidsInCollection = sum(experimentSummary.Total_Videos(exptList))-500;%not planning to curate some
disp(['Total videos acquired: ' num2str(totalVidsInCollection)])
disp(['Total videos analyzed: ' num2str(numel(videoList))])
disp(['percent passing curation: ' num2str(round(numel(videoList)/totalVidsInCollection*1000)/10)])
disp(['percent fully analyzed: ' num2str(round(size(graphTable,1)/totalVidsInCollection*1000)/10)])
%%

graphTable.Properties.VariableNames

%%

if strcmp(stimType,'Photoactivation')
    stimTypeTest = strcmp(graphTable.stim_type,'Photoactivation');
else
    stimTypeTest = strcmp(graphTable.stim_type,'Visual_stimulation');
end
graphTable(~stimTypeTest,:) = [];
vidListAll = graphTable.Properties.RowNames;
manLogical = ~isnan(graphTable.manJumpTest);
manSubTable = graphTable(manLogical,:);

autoSubJumpTest = logical(manSubTable.jumpTest);
autoPosSubTable = manSubTable(autoSubJumpTest,:);
trainY = logical(autoPosSubTable.manJumpTest);
vidListTrain = autoPosSubTable.Properties.RowNames;
manualJumpers = vidListTrain(trainY);
manualNonJumpers = vidListTrain(~trainY);

autoJumpTest = logical(graphTable.jumpTest);
vidListJumpers = vidListAll(autoJumpTest);
vidListNonJumpers = vidListAll(~autoJumpTest);
%% %%%%%%%%%%%%%% Testing Mode %%%%%%%%%%%%%%%%%%%%%%
mode = 2;
% 1 is training
% 2 is testing
% 3 is predicting
varNames = {'accelMax','accelMaxFrm','manFot','maxzdist','autoFot','trk_end'};
setRefs = [1 5 6];
if mode ~= 3
    X = [autoPosSubTable.accelMax,autoPosSubTable.autoFot,autoPosSubTable.trk_end];
else
    X = [graphTable.accelMax,graphTable.autoFot,graphTable.trk_end];
end

if mode == 1
    tclass = {'non_jumper','jumper'};
    nbY = tclass(double(trainY+1));
    SVMModel = fitcsvm(X,nbY,'Standardize',true,'KernelFunction','RBF',...
        'KernelScale','auto');
%     CVSVMModel = crossval(SVMModel);
%     classLoss = kfoldLoss(CVSVMModel);
%     classLoss = round(classLoss*1000)/100000;
%     disp(['cross validation loss: ' num2str(classLoss)])
    if strcmp(stimType,'Photoactivation')
        save('Z:\pez3000_variables\analysisVariables\falsePosJumpTestSVM_photoactivation.mat','SVMModel')
    else
        save('Z:\pez3000_variables\analysisVariables\falsePosJumpTestSVM.mat','SVMModel')
    end
    plot3(X(trainY,1),X(trainY,2),X(trainY,3),'.','color',[1 0 0],'MarkerSize',8)
    hold on
    plot3(X(~trainY,1),X(~trainY,2),X(~trainY,3),'.','color',[0 0 1],'MarkerSize',8)
    set(gcf,'position',[1921 1 1920 1124])
%     set(gca,'xlim',[1 100])
    % set(gca,'ylim',[1 10])
    % set(gca,'zlim',[1 100])
    xlabel(varNames{setRefs(1)})
    ylabel(varNames{setRefs(2)})
    zlabel(varNames{setRefs(3)})
else
    if strcmp(stimType,'Photoactivation')
        load('Z:\pez3000_variables\analysisVariables\falsePosJumpTestSVM_photoactivation.mat')
    else
        load('Z:\pez3000_variables\analysisVariables\falsePosJumpTestSVM.mat')
    end
end

%%
nbY = predict(SVMModel,X);
predictY = strcmp(nbY,'jumper');

ndxPredictPos = predictY;
ndxPredictNeg = ~predictY;
% %%
% plotY = predictSet{2}(ndxPredictPos);
% % plotX = rand(1,numel(plotY));
% plotX = predictSet{5}(ndxPredictPos);
% close all
% plot(plotX,plotY,'.')
% set(gca,'ylim',[1 1000])
% set(gcf,'position',[1950 50 1000 1000])

if mode ~= 3
    ndxFalsePos = ndxPredictPos & ~trainY;
    ndxFalseNeg = ndxPredictNeg & trainY;
    vidsNowNeg = vidListTrain(ndxPredictNeg);
    vidsStayPos = vidListTrain(ndxPredictPos);
else
    vidsNowNeg = vidListJumpers(ndxPredictNeg);
    vidsStayPos = vidListJumpers(ndxPredictPos);
end

plot3(X(ndxPredictPos,1),X(ndxPredictPos,2),X(ndxPredictPos,3),'.','color',[1 0 0],'MarkerSize',12)
% plot3(X(~trainY,1),X(~trainY,2),X(~trainY,3),'.','color',[0 0 1],'MarkerSize',16)
hold on
plot3(X(ndxPredictNeg,1),X(ndxPredictNeg,2),X(ndxPredictNeg,3),'.','color',[0 0 1],'MarkerSize',12)
% plot3(X(trainY,1),X(trainY,2),X(trainY,3),'.','color',[0 1 0],'MarkerSize',16)

% set(gca,'xlim',[1 100])
set(gcf,'position',[1921 1 1920 1124])
xlabel(varNames{setRefs(1)})
ylabel(varNames{setRefs(2)})
zlabel(varNames{setRefs(3)})
%
if mode ~= 3
    plot3(X(ndxFalsePos,1),X(ndxFalsePos,2),X(ndxFalsePos,3),'.','color',[0 1 0],'MarkerSize',8)
    plot3(X(ndxFalseNeg,1),X(ndxFalseNeg,2),X(ndxFalseNeg,3),'.','color',[0 1 0],'MarkerSize',8)
end

if mode ~= 3
    loomTotal = size(manSubTable,1);
    jumpTotal = sum(manSubTable.jumpTest);
    correctedJumpList = vidsStayPos(:);
    correctedNonJumpList = [vidsNowNeg;manualNonJumpers(:)];
    correctedJumpTotal = sum(predictY);
    falsePosCtA = sum(~manSubTable.manJumpTest & manSubTable.jumpTest);
    falseNegCtA = sum(manSubTable.manJumpTest & ~manSubTable.jumpTest);
    falsePosPctA = round(falsePosCtA/numel(trainY)*10000)/100;
    falseNegPctA = round(falseNegCtA/numel(trainY)*10000)/100;
    
    falsePosCtB = sum(ndxFalsePos);
    falseNegCtB = sum(ndxFalseNeg);
    falsePosPctB = round(falsePosCtB/numel(ndxFalsePos)*10000)/100;
    falseNegPctB = round(falseNegCtB/numel(ndxFalseNeg)*10000)/100;
    
else
    loomTotal = numel([vidListNonJumpers;vidListJumpers]);
    jumpTotal = numel(vidListJumpers);
    
    correctedJumpList = vidsStayPos(:);
    correctedNonJumpList = [vidsNowNeg;vidListNonJumpers(:)];
    loomTotal = numel([correctedNonJumpList;correctedJumpList]);
    correctedJumpTotal = numel(correctedJumpList);
end
disp(' ')
disp(' ')
disp(['total videos: ' num2str(loomTotal)])
jumperPctA = round(jumpTotal/loomTotal*1000)/10;
disp(['jumpers: ' num2str(jumperPctA) ' %'])
if mode ~= 3
    disp(['false-positives: ' num2str(falsePosPctA) ' %'])
    disp(['false-negatives: ' num2str(falseNegPctA) ' %'])
end
disp(' ')
disp('after corrections:')
disp(' ')
jumperPctB = round(correctedJumpTotal/loomTotal*1000)/10;
disp(['jumpers: ' num2str(jumperPctB) ' %'])
if mode ~= 3
    disp(['false-positives: ' num2str(falsePosPctB) ' %'])
    disp(['false-negatives: ' num2str(falseNegPctB) ' %'])
end
% throwAwayPct = round(throwAwayCt/numel(correctedJumpList)*10000)/100;
% disp(['throw-away: ' num2str(throwAwayPct) ' %'])
% One false negative jumps, lands in the water, and takes off
% again, flying directly through the viewing window above the prism:
% run051_pez3004_20140507_expt0019000006180101_vid0005


%%
rescreenPathA = 'C:\Users\williamsonw\Documents\Card Lab\labmeetingPrep_20140907\rescreen_results_falsePositives_233a';
jump_rescreen_resultsA = readtable(rescreenPathA,'ReadRowNames',true,'ReadVariableNames',true);
rescreenListA = jump_rescreen_resultsA.Properties.RowNames;
rescreenPathB = 'C:\Users\williamsonw\Documents\Card Lab\labmeetingPrep_20140907\rescreen_results_falsePositives_75b';
jump_rescreen_resultsB = readtable(rescreenPathB,'ReadRowNames',true,'ReadVariableNames',true);
rescreenListB = jump_rescreen_resultsB.Properties.RowNames;

%% False positive testing prep
vids2test = correctedJumpList;
falsePosTest = (cellfun(@(x) max(strcmp(manualNonJumpers,x)),vids2test));
viewList = vids2test(falsePosTest);
if exist('rescreenList','var')
    viewList(cellfun(@(x) max(strcmp(rescreenList,x)),viewList)) = [];
    jump_rescreen_results = table(zeros(numel(viewList),1),'VariableNames',...
        {'rescreen_results'},'RowNames',viewList);
    jump_rescreen_results = [jump_rescreen_results;jump_rescreen_results_saved];
else
    jump_rescreen_results = table(zeros(numel(viewList),1),'VariableNames',...
        {'rescreen_results'},'RowNames',viewList);
end
%% False megative testing prep
vids2test = correctedNonJumpList;
falseNegTest = (cellfun(@(x) max(strcmp(manualJumpers,x)),vids2test));
viewList = vids2test(falseNegTest);
jump_rescreen_results = table(zeros(numel(viewList),1),'VariableNames',...
    {'rescreen_results'},'RowNames',viewList);
%%
rescreenPath = 'C:\Users\williamsonw\Documents\Card Lab\labmeetingPrep_20140907\rescreen_results_falseNegatives_round2sheesh.txt';
table_read = readtable(rescreenPath,'ReadRowNames',true,'ReadVariableNames',true)
table_read(cellfun(@(x) ~max(strcmp(viewList,x)),table_read.Properties.RowNames),:) = [];
table_names = table_read.Properties.RowNames;
viewList = viewList(cellfun(@(x) ~max(strcmp(table_names,x)),viewList));
jump_rescreen_results_append = table(zeros(numel(viewList),1),'VariableNames',...
    {'rescreen_results'},'RowNames',viewList);
jump_rescreen_results = [table_read;jump_rescreen_results_append];
viewList = jump_rescreen_results.Properties.RowNames;
%%
iterV = 1;
%%
locator_name = 'flyLocator3000_v10';
tracker_name = 'flyTracker3000_v17';
analyzer_name = 'flyAnalyzer3000_v12';

rescreenPath = 'C:\Users\williamsonw\Documents\Card Lab\labmeetingPrep_20140907\rescreen_results_falsePositives_Photoactivation19a';
% rescreenPath = 'C:\Users\williamsonw\Documents\Card Lab\labmeetingPrep_20140907\rescreen_results_falseNegatives';
% jump_rescreen_results = readtable(rescreenPath,'ReadRowNames',true,'ReadVariableNames',true);
% taly = 0
vidRefs = (iterV:numel(viewList));
for iterV = vidRefs
    round(iterV/numel(viewList)*1000)/10
    videoID = viewList{iterV}
%     trk_summary = trackingVisualizer3000_v12(videoID,locator_name,tracker_name,analyzer_name);
%     taly = trk_summary.manjumptest+taly
%     if trk_summary.manjumptest
%         break
%     end
%     continue
    strParts = strsplit(videoID,'_');
    exptID = strParts{4}(5:end);
    dateID = strParts{3};
    runID = [strParts{1} '_' strParts{2} '_' strParts{3}];
    vidPath = fullfile('\\tier2\card\Data_pez3000',dateID,runID,[videoID '.mp4']);
    vidObj = VideoReader(vidPath);
    frmCt = vidObj.NumberOfFrames;
    frmVec = (1:10:frmCt);
    try
        for iterFrms = frmVec
            imshow(read(vidObj,iterFrms),[])
            drawnow
        end
    catch
    end
    choice = questdlg('jump test','jump test','jump','non-jump','ignore','jump');
    switch choice
        case 'jump'
            jump_rescreen_results.rescreen_results(videoID) = 1;
        case 'non-jump'
            jump_rescreen_results.rescreen_results(videoID) = 0;
        case 'ignore'
            jump_rescreen_results.rescreen_results(videoID) = 2;
    end
    close all
    writetable(jump_rescreen_results,rescreenPath,'WriteRowNames',true)
end

%%
fotLogical = autoPosSubTable.manFot > 1;
lengthLogical = (autoPosSubTable.manFot < 4201);
trkFarLogical = (autoPosSubTable.autoFot <= autoPosSubTable.trk_end);
useThese = lengthLogical & trkFarLogical & fotLogical;
fotDiffA = autoPosSubTable.autoFot(useThese)-autoPosSubTable.accelMaxFrm(useThese);
fotDiffB = autoPosSubTable.autoFot(useThese)-autoPosSubTable.manFot(useThese);
fotDiffC = autoPosSubTable.manFot(useThese)-autoPosSubTable.accelMaxFrm(useThese);
diffLogicalA = abs(fotDiffA) > 10;
sum(diffLogicalA)
sum(abs(fotDiffB(diffLogicalA)) > 10)
sum(abs(fotDiffC(diffLogicalA)) > 10)
%%
diffLogical = abs(fotDiffB) > 10;
sum(diffLogical)
sum(abs(fotDiffC(diffLogical)) > 10)
% plot3(autoPosSubTable.autoFot(fotLogical),autoPosSubTable.manFot(fotLogical),autoPosSubTable.accelMaxFrm(fotLogical),'.')
% plot(autoPosSubTable.autoFot(useThese),autoPosSubTable.manFot(useThese),'.')
% plot(autoPosSubTable.accelMaxFrm(useThese),autoPosSubTable.manFot(useThese),'.')
plot(autoPosSubTable.accelMaxFrm(useThese),autoPosSubTable.autoFot(useThese),'.')
set(gcf,'position',[1921 1 1920 1124])
xlabel('accel fot')
ylabel('auto fot')
% zlabel('accel max frm')
fotDiff = autoPosSubTable.autoFot(useThese)-autoPosSubTable.manFot(useThese);
% mean(fotDiff)
% iqr(abs(fotDiff))
% prctile(abs(fotDiff),90)
% prctile(abs(fotDiff),95)
%%
% fotDiff = autoPosSubTable.autoFot(useThese)-autoPosSubTable.manFot(useThese);
% fotLogical = abs(fotDiff) > 40;
fotDiff = autoPosSubTable.accelMaxFrm(fotLogical)-autoPosSubTable.manFot(fotLogical);
% fotDiff = autoPosSubTable.autoFot(fotLogical)-autoPosSubTable.manFot(fotLogical);
% fotDiff = autoPosSubTable.autoFot(useThese)-autoPosSubTable.accelMaxFrm(useThese);

fotDiff(abs(fotDiff) > 100) = [];
% xpts = rand(numel(fotDiff),1);
% plot(fotDiff,xpts,'.')
hist(fotDiff,100)
%%

stimTypeTest = strcmp(graphTable.stim_type,'Visual_stimulation');
% plot(graphTable.autoFot(loomTest),graphTable.accelMax(loomTest),'.')
plot(graphTable.departure_zero_fly(stimTypeTest),graphTable.departure_zero_stim(stimTypeTest),'.')
% plot(graphTable.accelMaxFrm(loomTest),graphTable.departure_XYdist(loomTest),'.')
%%
stimTypeTest = strcmp(graphTable.stim_type,'Visual_stimulation');

zeroFlyDept_degs = graphTable.departure_zero_fly;
zeroStimDept_degs = graphTable.departure_zero_stim;
zeroFlyStim_degs = zeroFlyDept_degs-zeroStimDept_degs;
zeroFlyStim_degs(zeroFlyStim_degs < -179) = zeroFlyStim_degs(zeroFlyStim_degs < -179)+360;
zeroFlyStim_degs(zeroFlyStim_degs > 180) = zeroFlyStim_degs(zeroFlyStim_degs > 180)-360;
stimTol = (0:90)';%60 includes dramatically more videos
stimBounds = [-stimTol stimTol]+45;
stimTest = zeros(1,numel(stimTol));
for iterStimTest = 1:numel(stimTol)
    stimTest(iterStimTest) = sum(min([zeroFlyStim_degs > stimBounds(iterStimTest,1),zeroFlyStim_degs < stimBounds(iterStimTest,2)],[],2));
end
plot(stimTest)
%%
stimTypeTest = strcmp(graphTable.stim_type,'Visual_stimulation');

zeroFlyDept_degs = graphTable.departure_zero_fly;
zeroStimDept_degs = graphTable.departure_zero_stim;
zeroFlyStim_degs = zeroFlyDept_degs-zeroStimDept_degs;
zeroFlyStim_degs(zeroFlyStim_degs < -179) = zeroFlyStim_degs(zeroFlyStim_degs < -179)+360;
zeroFlyStim_degs(zeroFlyStim_degs > 180) = zeroFlyStim_degs(zeroFlyStim_degs > 180)-360;
stimTol = 45/2;%45 ideal
stimBounds = [-stimTol stimTol]+45;
stimTest = min([zeroFlyStim_degs > stimBounds(1),zeroFlyStim_degs < stimBounds(2)],[],2);
fot = graphTable.autoFot;
stimStart = graphTable.stim_start;
normalFot = fot-stimStart;
stimDur = graphTable.stim_dur;
lateNufJumpTest = fot > round(stimStart+stimDur*(1/2));
%         lateNufJumpTest = true(size(lateNufJumpTest));%%% removes late enough test
earlyNufJumpTest = fot < round(stimStart+stimDur*1.1);
%         earlyNufJumpTest = true(size(earlyNufJumpTest));%%% removes early enough test
jumpEver = logical(graphTable.jumpTest);
jumpJustRight = jumpEver & lateNufJumpTest & earlyNufJumpTest & stimTest & stimTypeTest;
notJumpJustRight = ~jumpEver & stimTest & stimTypeTest;
justRight = stimTest & stimTypeTest;
velocityArray = cellfun(@(x) double(x(:,2)/10)',graphTable.pos_speed_accel_mm(justRight),'uniformoutput',false);
velCounts = cellfun(@(x) numel(x),velocityArray);
velocityArray = cellfun(@(x,y) [NaN(1,y) x],velocityArray,num2cell(stimStart(justRight)),'uniformoutput',false);
newVelCount = cellfun(@(x) numel(x),velocityArray);
maxCount = max(newVelCount);
velocityArray = cellfun(@(x,y) [x NaN(1,maxCount-y+1)],velocityArray,num2cell(newVelCount),'uniformoutput',false);
%%
velocityArray = cell2mat(velocityArray);
%%
plot(velocityArray')