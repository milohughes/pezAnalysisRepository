function graphingFeederFun
%%
graphTable = makeGraphingTable;
%%
clearvars -except graphTable

runModeChoice = 4;
getVarsFromExcel = 0;
addpath('C:\Users\williamsonw\Documents\MATLAB\altmany-export_fig-2763b78')
runModeStrOps = {'lvTuning','aziSweep','eleSweep','Screening','Custom'};
runModeStr = runModeStrOps{runModeChoice};
if getVarsFromExcel == 1
    excelSelectionsPath = 'C:\Users\williamsonw\Documents\MATLAB\graphSelections.xlsx';
    graphChoicesTable = table2cell(readtable(excelSelectionsPath,'ReadVariableNames',false,'Sheet',runModeStr));
    graphChoicesTable = graphChoicesTable(:,1:end-1);
    plotChoiceOps = cell2mat(graphChoicesTable(1,2:end));
elseif getVarsFromExcel == 0
    plotChoiceOps = (1);
end
for iterPP = 1:numel(plotChoiceOps)
    if plotChoiceOps(iterPP) == 0, continue, end
    
    % use with frameOfX_time (2) and durationOf (1 to 2)
    epochChoice = [2 4]; % 1 - fowu ; 2 - folp ; 3 - fowd ; 4 - fot ; 5 - fomvnt ; 6 - distCap ; 7 - mvmntfrm
    % use with absMotion
    segmentChoice = 3; % 1-full 10 ms...2-fot...3-mid leg extend...4-full leg
    % extend...5-entire vector...6-half loom...7-jumpCap...8-last half
    % loom...9-distCap...10-fullStim...11-maxVelWin
    
    % use with ESCAPE plot
    dirChoice = [3 1 1 1]; % [1-Jump 2-Departure 3-Trajectory 4-Meatball   1-zeroStimAzi 2-zeroFlyAzi 3-3D 4-elevation
    %    1-Angle 2-Dist    1-Variable Rho 2-One Rho]
    dirFlag = 0;  % 0-none ; 1-back ; 2-fwrd ; 3-right ; 4-left --- use with binomial plus zeroFly
    
    % use with RELMOTION
    motionChoice = 2; % 1-movement 2-walking 3-turning 4-sidepass
    unitChoice = 3; % 1 - velocity ; 2 - acceleration ; 3 - distance ; 4 - force
    
    
    binomialFlag = [1 0 7];% 1-above -1-below...
    % 0-do nothing 1-use median thresh 2-use custom thresh...custom thresh
    
    plotChoice = 9;
    
    saveFig = 0;    appendFig = 0;
    write2excel = 0;
    showRedLine = 0; % 0-hide ; 1-binomial plots ; 2-jitter/box plots ; 3-custom thresh
    useExplicitAxesLimits = 0;
    getXaxisFromPlotIDs = 0;
    xScale = 0; % 0 - normal ; 1 - log ; 2 - deg2rad
    yScale = 0; % 0 - normal ; 1 - log
    noPlot = 0;         plotError = 2; % 1 - median and se(median) ; 2 - ...iqr ; 3 - mean and se(mean)
    boxPlot = 0;        dataStyle = 1; % 0 - hide dots ; 1 - jitter ; 2 - raster ; 3 - combo
    regression = 0;     exp4fit = 2;
    modelChoice = 1; % 1-poly 2-sin 3-gauss 4-power 5-exp 6-fourier 7-weibull
    modelOps = {'poly','sin','gauss','power','exp','fourier','weibull'};
    modelStr = modelOps{modelChoice};
    explicitTimeBounds = [0 1 250]; % 1 to use, start time, stop time (ms)
    nDelay = 0;
    maxDataCt = Inf;
    plotOps = {'jumpFrequency';'frameOfX_deg';'frameOfX_time' % 1 - 3
        'escape';'durationOf';'flyLength';'initialOrientation' % 4 - 7
        'absMotion';'relMotion';'jumpingWatts';'jumpingJoules' % 8 - 11
        'maxMotion';'moveFrequency';'earlyMoverFrequency';'groundTruthing' %12 - 15
        'shortFrequency';'short2ctrlRatio';'montageMaking'}; % 16 - 18
    if getVarsFromExcel == 1
        for iterC = 2:size(graphChoicesTable,1)
            eval([graphChoicesTable{iterC,1} ' =  ' num2str(graphChoicesTable{iterC,iterPP+1}) ';'])
        end
        if iterPP == 1
            appendFig = 0;
        end
    end
    graphName = plotOps{plotChoice};
    dirOpsA = {'Jump','Departure','Trajectory','Meatball'};
    dirOpsB = {'zeroStimAzi','zeroFlyAzi','3D','elevation'};
    dirOpsC = {'Angle','Dist','Binomial'};
    dirOpsD = {'RhoVar','RhoOne'};
    motionOps = {'movement','walking','turning','sidepass'};
    segmentOps = {'FullJumpDur','Fot','MidLegExt','FullLegExt','FullDur','MidLoom','JumpCap','LateLoom','MvntCap','FullStim','MaxVelWin'};
    unitOps = {'Vel','Accel','Dist','Force'};
    frameOfOps = {'wingsUp','legPush','wingsDwn','takeoff','mvnt','distCap','mvntFrm'};
    if explicitTimeBounds(1) == 1
        segmentOps{segmentChoice} = ['timeBounds' num2str(explicitTimeBounds(2)) 'to' num2str(explicitTimeBounds(3))];
    end
    if strcmp(graphName,'absMotion')
        graphName = cat(2,graphName,'_',motionOps{motionChoice},'_',unitOps{unitChoice},'_',segmentOps{segmentChoice});
    elseif strcmp(graphName,'frameOfX_time')
        graphName = cat(2,graphName,'_',frameOfOps{epochChoice(2)});
    elseif strcmp(graphName,'durationOf')
        graphName = cat(2,graphName,'_',frameOfOps{epochChoice(1)},'2',frameOfOps{epochChoice(2)});
    elseif strcmp(graphName,'relMotion')
        graphName = cat(2,graphName,'_',motionOps{motionChoice},'_',unitOps{unitChoice},'_',segmentOps{segmentChoice});
    elseif strcmp(graphName,'escape')
        graphName = cat(2,graphName,dirOpsA{dirChoice(1)},'_',dirOpsB{dirChoice(2)},...
            '_',dirOpsC{dirChoice(3)},dirOpsD{dirChoice(4)});
    elseif strcmp(graphName,'jumpingJoules')
        graphName = cat(2,graphName,'_nd',sprintf('%03s',num2str(nDelay)));
    end
    
    graphSelections = struct;
    graphSelections.useExplicitAxesLimits = useExplicitAxesLimits;
    graphSelections.getXaxisFromPlotIDs = getXaxisFromPlotIDs;
    graphSelections.xScale = xScale;
    graphSelections.yScale = yScale;
    graphSelections.noPlot = noPlot;
    graphSelections.plotError = plotError;
    graphSelections.boxPlot = boxPlot;
    graphSelections.dataStyle = dataStyle;
    graphSelections.regression = regression;
    graphSelections.exp4fit = exp4fit;
    graphSelections.modelStr = modelStr;
    graphSelections.graphName = graphName;
    graphSelections.write2excel = write2excel;
    graphSelections.saveFig = saveFig;
    graphSelections.dirFlag = dirFlag;
    graphSelections.showRedLine = showRedLine;
    graphSelections.binomialFlag = binomialFlag;
    graphSelections.epochChoice = epochChoice;
    graphSelections.maxDataCt = maxDataCt;
    makeGraphOptionsStruct([],graphName)
    [pdfName,plotTable] = graphing_pez3000(graphTable,graphSelections,appendFig);
end
