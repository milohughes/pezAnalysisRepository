function output = overlayStimTrace(dataID,plotTable)
%%
plotType = 1; % 1 - photoactivation ; 2 - combo

% manually entered from 'predicting_neual_delay.m'
radiantThreshold = [0.0294 0.0152 0.0232];
frmThreshold = [4 6 40];
thresholdStrings = {'GF','LC4','LC6'};

optionsPath = 'Z:\Data_pez3000_analyzed\WRW_graphing_variables\graphOptions.mat';
graphOptionsLoading = load(optionsPath);
graphOptions = graphOptionsLoading.graphOptions;
excelPath = graphOptions.excelPath;


actKey = readtable(excelPath,'ReadRowNames',false,'Sheet','activation_key');
actKey = table2cell(actKey);
actKey = actKey(:,1:2);
varDir = [filesep filesep 'DM11' filesep 'cardlab' filesep,...
    'pez3000_variables' filesep 'photoactivation_stimuli'];
dataDir = 'Z:\pez3000_variables';
fitFunLoad = load(fullfile(dataDir,'photoactivationTransferFunction.mat'),'fitFun');
fitFun = fitFunLoad.fitFun;
funStr = func2str(fitFun);
funStr = cat(2,funStr(1:4),'4*(',funStr(5:end),')');
fitFun = str2func(funStr);

% xlim = get(axObj,'xlim');
frms_per_ms = 6;
frm2ms = @(x) x/frms_per_ms;
ms2frm = @(x) round(x*frms_per_ms);

dataRef = find(cellfun(@(x) contains(x,dataID),plotTable.Properties.RowNames),1,'first');

prct2mW = fitFun;% generated from avg measurements of LEDs
if  graphOptions.sliceOption == 1
    var2use = strcmp(actKey(:,2),plotTable.stimInfo{dataRef}{1});
    varName = actKey{var2use,1};
else
    varName = plotTable.stimInfo{dataRef}{1};
end
varPath = fullfile(varDir,[varName '.mat']);
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
power(1) = 0;
power(end) = 0;
powerCum = cumsum(power);%integrate
powerCum = frm2ms(powerCum);%necessary because of integration
powerCum = powerCum/1000;%convert to sec from ms since Joule*sec is Watt

% axPos = get(axObj,'pos');
% axPos(3) = axPos(3)*0.9;
% set(axObj,'ylim',[-0.1 1.1],'pos',axPos)
% if plotType == 1
%     powerPlot = power;
    maxY = 4;
    power = power/maxY;
%     plot((1:xlim(2)),powerPlot(1:xlim(2)),'parent',axObj,'color','b')
%     
%     powerPlot = powerCum;
%     maxPower = round(max(powerPlot));
    maxYcum = 0.1;
%     
%     for iterThr = 1:numel(thresholdStrings)
%         if contains(dataID,thresholdStrings{iterThr})
%             %                 thresh = find(powerPlot >= radiantThreshold(iterThr),1,'first');
%             thresh = radiantThreshold(iterThr);
%             frm = ms2frm(frmThreshold(iterThr));
%             if ~isempty(thresh)
%                 %                     plot([thresh thresh],[0 1],'color','g','parent',axObj)
%                 lineAx = findobj('type','line','parent',axObj);
%                 lineRef = lineAx(strcmp(get(lineAx,'linestyle'),'--'));
%                 medFotVal = get(lineRef,'xdata');
%                 medFot = medFotVal(1)-frm;
%                 plot([medFotVal(1) medFot medFot],[0 0 thresh/maxYcum],'color','g','parent',axObj)
%             end
%         end
%     end
   powerCum = powerCum/maxYcum;
   output = [power(:) powerCum(:)];
%     plot((1:xlim(2)),powerPlot(1:xlim(2)),'parent',axObj,'color','r')
%     
%     
%     
%     ypos = linspace(0,1,3);
%     ylabels = linspace(0,maxY,numel(ypos));
%     for iterX = 1:numel(ypos)
%         text(xlim(2)+range(xlim)*0.05,ypos(iterX),num2str(ylabels(iterX),3),'parent',axObj,'color','b')
%     end
%     ylabels = linspace(0,maxYcum,numel(ypos));
%     for iterX = 1:numel(ypos)
%         text(xlim(2)+range(xlim)*0.1,ypos(iterX),num2str(ylabels(iterX),3),'parent',axObj,'color','r')
%     end
%     
% end
% if plotType == 2
%     exptIDs = plotTable.exptIDs{dataRef};
%     for iterE = 1:numel(exptIDs)
%         exptID = exptIDs{iterE}(4:end);
%         analysisDir = fullfile('\\tier2','card','Data_pez3000_analyzed');
%         expt_results_dir = fullfile(analysisDir,exptID);
%         autoAnnoName = [exptID '_automatedAnnotations.mat'];
%         autoAnnotationsPath = fullfile(expt_results_dir,autoAnnoName);
%         autoAnnoTable_import = load(autoAnnotationsPath);
%         dataname = fieldnames(autoAnnoTable_import);
%         automatedAnnotations = autoAnnoTable_import.(dataname{1});
%         videoList = plotTable.videoList{dataRef};
%         videoList = intersect(automatedAnnotations.Properties.RowNames,videoList);
%         photoStart = automatedAnnotations.photoStimFrameStart(videoList);
%         photoStart(cellfun(@(x) isempty(x),photoStart)) = {NaN};
%         visStart = automatedAnnotations.visStimFrameStart(videoList);
%         visStart(cellfun(@(x) isempty(x),visStart)) = {NaN};
%         startDiffs = cell2mat(photoStart)-cell2mat(visStart);
%         startDiffs = -cell2mat(automatedAnnotations.visStimFrameCount(videoList))+startDiffs;
%         startDiffsX = cat(2,repmat(startDiffs,1,2),NaN(size(startDiffs)))';
%         startDiffsY = repmat([0 1 NaN],numel(startDiffs),1)';
%         plot(startDiffsX(:),startDiffsY(:),'parent',axObj,'color','r')
%     end
%     
%     initStimSize = plotTable.startSize(dataRef);
%     finalStimSize = plotTable.stopSize(dataRef);
%     ellovervee = plotTable.lv(dataRef);
%     minTheta = deg2rad(initStimSize);
%     maxTheta = deg2rad(finalStimSize);
%     stimStartTime = ellovervee/tan(minTheta/2);
%     stimStopTime = ellovervee/tan(maxTheta/2);
%     stimVecTime = linspace(stimStartTime,stimStopTime,round(stimStartTime*6));
%     stimVecTheta = 2.*atan(ellovervee./stimVecTime);
%     stimVecDeg = rad2deg(stimVecTheta);
%     stimX = -stimVecTime*6;
%     stimY = stimVecDeg;
%     stimY = (stimY-min(stimY))/range(stimY);
%     plot(stimX,stimY,'parent',axObj,'color','k')
% end
% 
% if plotType == 1
%     text(xlim(2)+range(xlim)*0.05,-0.25,'mW/mm^2','parent',axObj(1),'color','b')
%     text(xlim(2)+range(xlim)*0.05,-0.5,'mJ/mm^2','parent',axObj(1),'color','r')
% end
