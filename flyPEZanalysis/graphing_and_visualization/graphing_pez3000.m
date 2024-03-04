function [pdfName,plotTable,hFig] = graphing_pez3000(graphTable,graphSelections,appendFig)
%%

clearvars -except graphTable graphSelections appendFig
hFig = 0;
% selectionsPath = 'Z:\Data_pez3000_analyzed\WRW_graphing_variables\graphSelections.mat';
% graphSelectionsLoading = load(selectionsPath);
% graphSelections = graphSelectionsLoading.graphSelections;


useExplicitAxesLimits = graphSelections.useExplicitAxesLimits;
getXaxisFromPlotIDs = graphSelections.getXaxisFromPlotIDs;
xScale = graphSelections.xScale;
yScale = graphSelections.yScale;
noPlot = graphSelections.noPlot;
plotError = graphSelections.plotError;
boxPlot = graphSelections.boxPlot;
dataStyle = graphSelections.dataStyle;
regression = graphSelections.regression;
exp4fit = graphSelections.exp4fit;
modelStr = graphSelections.modelStr;
graphName = graphSelections.graphName;
write2excel = graphSelections.write2excel;
saveFig = graphSelections.saveFig;
dirFlag = graphSelections.dirFlag;
showRedLine = graphSelections.showRedLine;
binomialFlag = graphSelections.binomialFlag;
epochChoice = graphSelections.epochChoice;
if isfield(graphSelections,'maxDataCt')
    maxDataCt = graphSelections.maxDataCt;
else
    maxDataCt = Inf;
end
rng('default');
rng(19);
if numel(get(0,'children')) > 5
    close all
end
if isempty(mfilename)
    saveFig = 0;
end
if binomialFlag(2) ~= 0
    yScale = 0;
end
optionsPath = 'Z:\Data_pez3000_analyzed\WRW_graphing_variables\graphOptions.mat';
%%%%%
[plotTable,excelTable] = addPlotData(graphTable);
%%%%%

dataIDlist = plotTable.Properties.RowNames;
graphOptionsLoading = load(optionsPath);
graphOptions = graphOptionsLoading.graphOptions;
excelPath = graphOptions.excelPath;
[~,excelName] = fileparts(excelPath);
sheetName2plot = graphOptions.sheetName;
groupIDlist = graphOptions.groupIDlist;
plotIDlist = graphOptions.plotIDlist;
grpCt = numel(groupIDlist);
xCt = numel(plotIDlist);

plotTable.plotData = plotTable.returnData;
emptyRef = cellfun(@(x) isempty(x),plotTable.plotData);
clearvars yMin yMax yMid yAxisName
yAxisName = '';

if strcmp(graphName(1:6),'escape')
    xory = 1;
    if binomialFlag(2) == 1
        yMin = 0; yMax = 100; yMid = 25;
        if ~isempty(strfind(graphName,'zeroStim')) && dirFlag > 2
            str2add = 'toward';
            dirFlag = 1;
        end
        switch dirFlag
            case 1
                str2add = 'backward';
                if ~isempty(strfind(graphName,'zeroStim')) && ~strcmp(plotTable.stimType{1},'Photoactivation')
                    str2add = 'away';
                end
                binomialFlag(1) = -1;
            case 2
                str2add = 'forward';
                if ~isempty(strfind(graphName,'zeroStim')) && ~strcmp(plotTable.stimType{1},'Photoactivation')
                    str2add = 'toward';
                end
                binomialFlag(1) = 1;
            case 3
                if strcmp(plotTable.stimType{1},'Photoactivation')
                    str2add = 'sideways';
                    binomialFlag(1) = 1;
                else
                    str2add = 'rightward';
                    binomialFlag(1) = -1;
                end
                xory = 2;
            case 4
                if strcmp(plotTable.stimType{1},'Photoactivation')
                    str2add = 'sideways';
                else
                    str2add = 'leftward';
                end
                xory = 2;
                binomialFlag(1) = 1;
        end
        yAxisName = ['percent ' str2add];
    elseif ~isempty(strfind(graphName,'3D'))
        yAxisName = 'Theta(jump,stimulus) - degrees';
        yMin = 0; yMax = 150; yMid = 30;
    elseif ~isempty(strfind(graphName,'Dist'))
        plotTable.plotData(~emptyRef) = cellfun(@(x) x(:,2),plotTable.plotData(~emptyRef),'uniformoutput',false);
        yAxisName = 'mm';
        yMin = 0; yMax = 2;    yMid = 0.5;
    elseif ~isempty(strfind(graphName,'elevation'))
        yAxisName = 'Departure elevation (degrees)';
        %     yMin = 40; yMax = 60;    yMid = 5;
        yMin = 0; yMax = 90;    yMid = 15;
        plotTable.plotData(~emptyRef) = cellfun(@(x) x(:,3),plotTable.plotData(~emptyRef),'uniformoutput',false);
    else
        yAxisName = 'Translation (mm)';
        yMin = -180; yMax = 180; yMid = 45;
        if ~isempty(strfind(graphName,'zeroFly'))
            if dirFlag == 1
                graphName = [graphName '_forwardVSback'];
            else
                xory = 2;
                if strcmp(plotTable.stimType{1},'Photoactivation')
                    graphName = [graphName '_sideways'];
                    yMin = 0;
                else
                    graphName = [graphName '_leftVSright'];
                end
            end
        else
            graphName = [graphName '_towardVSaway'];
        end
    end
elseif ~isempty(strfind(graphName,'flyLength'))
    yAxisName = 'mm';
    yMin = 1.5; yMax = 3.5; yMid = 0.5;
elseif ~isempty(strfind(graphName,'jumpingJoules'))
    yAxisName = 'mJ/mm^2';
    yMin = 0; yMax = 0.2; yMid = 0.1;
elseif ~isempty(strfind(graphName,'jumpingWatts'))
    yAxisName = 'mW/mm^2';
    yMin = 0; yMax = 4; yMid = 2;
elseif ~isempty(strfind(graphName,'maxMotion'))
    yAxisName = 'm/s';
    if strcmp(graphOptions.subset2plot,'jumping')
        yMin = 0; yMax = 0.5; yMid = 0.05;
    else
        yMin = 0; yMax = 0.2; yMid = 0.025;
    end
elseif strcmp(graphName,'short2ctrlRatio')
%     plotType = 'regression';
    yAxisName = 'Percent relative to control';
    yMax = 100;
    yMin = 0;   yMid = 50;
elseif ~isempty(strfind(graphName,'durationOf'))
    plotTable.plotData(~emptyRef) = cellfun(@(x) abs(x(:,epochChoice(1))-x(:,epochChoice(2))),...
        plotTable.returnData(~emptyRef),'uniformoutput',false);
    if epochChoice(1) == 1
        yMin = 0; yMax = 50;    yMid = 5;
%         plotTable.plotData(~emptyRef) = cellfun(@(x) x(x < 50),...
%             plotTable.plotData(~emptyRef),'uniformoutput',false);
    elseif abs(diff(epochChoice)) == 1
        yMin = 0; yMax = 3;    yMid = 1;
    else
        yMin = 0; yMax = 15;    yMid = 5;
    end
    yAxisName = 'ms';
%     plotTable.returnData = plotTable.plotData;
elseif ~isempty(strfind(graphName,'frameOf'))
    plotTable.plotData(~emptyRef) = cellfun(@(x) x(:,epochChoice(2)),...
        plotTable.returnData(~emptyRef),'uniformoutput',false);
    if ~isempty(strfind(graphName,'_time'))
        yAxisName = 'ms';
        if strcmp([excelName '_' sheetName2plot],'methods_paper_activation_multiGeno_multiStim')
            yMin = 0; yMax = 100;    yMid = 20;
        else
            if strcmp(plotTable.stimType{1},'Photoactivation')
                yMin = 0; yMax = 500;    yMid = 50;
            else
                yMin = -500; yMax = 50;    yMid = 100;
            end
        end
    else
        yAxisName = 'degrees';
        yMin = 0;    yMax = 180;    yMid = 30;
    end
elseif ~isempty(strfind(graphName,'relMotion')) || ~isempty(strfind(graphName,'absMotion_turning'))
    if ~exist('expval','var')
        if ~isempty(strfind(graphName,'turning'))
            if strcmp(plotTable.stimType{1},'Visual_stimulation')
                if strcmp(plotTable.visStimType{1},'loom')
                    if ~isempty(strfind(graphName,'Dist'))
                        yAxisName = 'degrees';
                        if strcmp(graphOptions.subset2plot,'jumping')
                            yMin = -10;    yMax = 10;    yMid = 2;
                        else
                            yMin = -20;    yMax = 20;    yMid = 5;
                        end
                        if ~isempty(strfind(graphName,'absMotion_turning'))
                            yMin = 0;
                        end
                    else
                        yAxisName = 'deg/sec';
                        yMin = 0;    yMax = 270;    yMid = 45;
                    end
                else
                    if ~isempty(strfind(graphName,'Dist'))
                        yAxisName = 'degrees';                   rangeVal = 90;
                        yMin = -rangeVal;    yMax = rangeVal;    yMid = rangeVal/2;
                    else
                        yAxisName = 'deg/sec';                   rangeVal = 0.05;
                        yMin = -rangeVal;    yMax = rangeVal;    yMid = rangeVal/2;
                    end
                end
            elseif strcmp(plotTable.stimType{1},'Photoactivation')
                if ~isempty(strfind(graphName,'Dist'))
                    yAxisName = 'degrees';
                    yMin = 0;    yMax = 45;    yMid = 15;
                else
                    yAxisName = 'deg/sec';
                    yMin = 0;    yMax = 360;    yMid = 30;
                end
            end
        elseif ~isempty(strfind(graphName,'movement'))
            yAxisName = 'mm';
            if strcmp('Photoactivation',plotTable.stimType{1})
                yMin = 0;    yMax = 10;    yMid = 2;
            else
                yMin = 0;    yMax = 2;    yMid = 0.5;
            end
        elseif strcmp('Photoactivation',plotTable.stimType{1}) && ~isempty(strfind(graphName,'sidepass'))
            yAxisName = 'mm';
            yMin = 0;    yMax = 0.5;    yMid = 0.25;
        else
            yAxisName = 'mm';
            if strcmp(excelName,'backing_on_pez')
                rangeVal = 2.5;
            elseif strcmp(graphOptions.subset2plot,'jumping')
                rangeVal = 1;
            else
                rangeVal = 2;
            end
            yMin = -rangeVal;    yMax = rangeVal;    yMid = rangeVal;
            if dirFlag > 0
                for iterD = 1:size(plotTable,1)
                    data = plotTable.plotData{iterD};
                    if isempty(data), continue, end
                    if dirFlag == 1
                        data = data*(-1);
                    end
                    data(data < 0) = NaN;
                    plotTable.plotData{iterD} = data;
                end
                yMin = 0;   yMid = yMid/2;
                if dirFlag == 1
                    graphName = cat(2,graphName,'_back');
                else
                    graphName = cat(2,graphName,'_fwrd');
                end
            elseif ~isempty(strfind(graphName,'sidepass'))
                for iterD = 1:size(plotTable,1)
                    data = plotTable.plotData{iterD};
                    if isempty(data), continue, end
                    plotTable.plotData{iterD} = abs(data);
                end
                yMin = 0;   yMid = yMid/2;
            end
        end
    end
elseif ~isempty(strfind(graphName,'absMotion'))
    if ~isempty(strfind(graphName,'Accel'))
        yAxisName = 'm/s^2';
        if ~isempty(strfind(graphName,'FullDur'))
            yMax = 80; yMin = 0;   yMid = 20;
        else
            yMax = 200; yMin = 0;   yMid = 25;
        end
    elseif ~isempty(strfind(graphName,'_Vel'))
        yAxisName = 'm/s';
        yMax = 0.3; yMin = 0;   yMid = 0.1;
    elseif ~isempty(strfind(graphName,'Force'))
        yAxisName = 'micro-Newtons';
        if ~isempty(strfind(graphName,'FullDur'))
%             yMax = 80; yMin = 0;   yMid = 20;
        else
            yMax = 200; yMin = 0;   yMid = 50;
        end
    else
        yAxisName = 'mm';
        if strcmp('Photoactivation',plotTable.stimType{1})
            yMin = 0;    yMax = 10;    yMid = 2;
        else
            yMax = 2; yMin = 0;   yMid = 1;
        end
    end
elseif strcmp(graphName,'wing2fot_histogram')
    plotError = 1;
    yAxisName = 'ms';
    yMax = 4;    yMin = 1;    yMid = 1;
end
if ~useExplicitAxesLimits
    clearvars yMin yMax yMid
end
if ~(exist('yMin','var') && exist('yMax','var')) || ~exist('yMid','var')
    maxCounts = cellfun(@(x) nanmax(x(:,1),[],1),plotTable.plotData(~emptyRef));
    minCounts = cellfun(@(x) nanmin(x(:,1),[],1),plotTable.plotData(~emptyRef));
    yMaxAuto = max(maxCounts);
    yMinAuto = min(minCounts);
    if ~exist('yMax','var') || yMax < yMinAuto
        yMax = yMaxAuto(:,1);
    end
    if ~exist('yMin','var') || yMaxAuto < yMin
        yMin = yMinAuto(:,1);
    end
    if ~exist('yMid','var') || yMid < (yMax-yMin)/3
        yMid = (yMax-yMin)/6;
    end
%     yMin = floor(yMin/yMid)*yMid;
%     yMax = ceil(yMax/yMid)*yMid;
else
    disp('explicit data range imposed')
end


if binomialFlag(2) > 0 || ~isempty(strfind(graphName,'Frequency'))
    yAxisName = 'percent';
    yMax = 100; yMin = 0;   yMid = 50;
    plotTable.binomialData = NaN(size(plotTable,1),2);
    if binomialFlag(2) > 0 && ~isempty(strfind(graphName,'Frequency'))
        if binomialFlag(1) == 1 && ~exist('str2add','var')
            str2add = '_pctAbove';
        elseif binomialFlag(1) == -1 && ~exist('str2add','var')
            str2add = '_pctBelow';
        else
            str2add = '_freq';
        end
        graphName = [graphName '_' str2add];
    end
end
yCount = round((yMax-yMin)/yMid)+1;
if yScale == 1
    yMax = log10(yMax);
    if yMin == 0, yMin = 1; end
    yMin = log10(yMin);
end

if ~appendFig
    pdfName = [sheetName2plot '_' graphName '_' graphOptions.subset2plot];
else
    pdfName = [sheetName2plot '_' graphOptions.subset2plot];
end
if ~isempty(strfind(graphName,'montageMaking'))
    save('Z:\Data_pez3000_analyzed\WRW_graphing_variables\plotTable','plotTable')
    disp('saved montage making variable')
    return
end
if noPlot == 1
    return
end
hFig = figure;

%group colors
colorOps = {[55 126 184];[228 26 28];[77 175 74];[152 78 163];[255 127 0]};
colorOpsA = cellfun(@(x) (x/255).^(1.2),colorOps,'uniformoutput',false);
colorOps = {[55 126 184];[228 26 28];[77 175 74];[152 78 163];[255 127 0]};
colorOpsB = cellfun(@(x) (x/255).^(0.7),colorOps,'uniformoutput',false);
colorOps = cat(1,colorOpsA,colorOpsB);
colorOps = colorOps(1:grpCt);
fontSa = 12; fontSb = 10; fontSc = 8;
colorType = 1;%1 for publication, 2 for slides
if colorType == 1
    fontC = [0 0 0];
    backC = [1 1 1];
    lineCa = [0 0 0];
    lineCb = [1 1 1]-0.5;
else
    fontC = [1 1 1];
    backC = [0 0 0];
    lineCa = [0 0 0];
    lineCb = [0 0 0]+0.5;
end

labelDropVal = 0.7;
numRef = max(cellfun(@(x) numel(strfind(x,'_')),plotTable.plotID(dataIDlist)))+2;
shiftList = linspace(-0.3,-labelDropVal,numRef);
ytickpos = linspace(0,1,yCount);
yGridC = [zeros(1,xCt)+1;zeros(1,xCt)-labelDropVal;NaN(1,xCt)];
if getXaxisFromPlotIDs > 0
    if getXaxisFromPlotIDs == 1
        xValBrks = cellfun(@(x) strfind(x,'_'),plotTable.plotID(dataIDlist),'uniformoutput',false);
        xVals = cellfun(@(x,y) str2double(x(y(end)+1:end)),plotTable.plotID(dataIDlist),xValBrks);
        xVals = unique(xVals(:)');
    end
    if xScale == 1
        xVals = log(xVals+1);
    elseif xScale == 2
        xVals = deg2rad(xVals);
    end
else
    xVals = (1:xCt);
end
xGrid = repmat(xVals,4,1);
xGrid = (xGrid-min(xVals))/range(xVals)*(xCt-1)+1;
xlines = repmat([-0.05 xCt+0.5 NaN]',numel(ytickpos),1);
ylines = [ytickpos;ytickpos;ytickpos*NaN];

plot([xlines(:);NaN;0.1;0.1],[ylines(:);NaN;0;1],'color',lineCb,'linewidth',1);
hold on
% plot(xGrid(1:3,:)+0.3,yGridC,'color',lineCb,'linewidth',2);
% plot([0.1 0.1 NaN xlines(1:2)'],[0 1 NaN 0 0],'color',lineCa);
set(gca,'xLim',[0 xCt+1],'ylim',[-labelDropVal 1.01])
set(gcf,'units','pixels')
if size(get(0,'monitorpositions'),1) == 1
    figPos = [50 300 xCt*27+500 750];
else
    figPos = [1950 300 xCt*27+500 750];
end
figPos(3) = figPos(3)*(1+(grpCt-1)*0.2);
set(gcf,'pos',figPos,'color',backC)
set(gca,'units','pixels')
axPos = [100 100 figPos(3:4)-200];
set(gca,'xticklabel',[],'position',axPos,'color','none','box','off',...
    'ticklength',[0 0],'xcolor','none','ycolor','none')
text(-0.75-xCt*0.015,0.5,yAxisName,'rotation',90,'fontsize',fontSb,...
    'color',fontC,'horizontalalignment','center')

hLegendA = zeros(grpCt,1);
if ~max(strcmp(excelTable.Properties.VariableNames,graphName))
    excelTable.(graphName) = zeros(size(excelTable,1),1);
end
for iterG = 1:grpCt
    grpID = groupIDlist{iterG};
    grpBool = strcmp(grpID,plotTable.groupID);
    if max(strcmp(excelTable.Properties.VariableNames,'repeat'))
        grpBool = grpBool | (plotTable.repeat == 1);
    end
    grpTable = plotTable(grpBool,:);
    [~,grpOrder] = sort(grpTable.order);
    grpTable = grpTable(grpOrder,:);
    grpIDlist = grpTable.Properties.RowNames;
    plotC = colorOps{iterG}*.8;
    xOffOps = linspace(-0.4,0.4,grpCt+1);
    xOffA = mean(xOffOps(iterG:iterG+1))-0.2;
    dataRef = ismember((1:xCt),grpTable.order)';
    spreadFac = 1/grpCt/2.5;
    if isempty(strfind(graphName,'Frequency'))
        maxCt = max(cellfun(@(x) size(x,1),grpTable.plotData(:)));
        xScatter = cell(xCt,1);
        yScatter = cell(xCt,1);
        yScatter(dataRef) = grpTable.plotData;
        eYall = NaN(4,xCt); mYall = NaN(3,xCt);
        for iterExpt = 1:xCt
            if isempty(yScatter{iterExpt})
                yScatter{iterExpt} = [NaN NaN];
            end
            upperBound = Inf;
            if numel(yScatter{iterExpt}(:,1)) > upperBound
                randNdx = randperm(numel(yScatter{iterExpt}(:,1)));
                yScatter{iterExpt} = yScatter{iterExpt}(randNdx(1:upperBound),:);
                maxCt = upperBound;
            end
            plotData = yScatter{iterExpt};
            if yScale == 1
                plotData = log10(plotData);
            end
            if dataStyle == 1 || dataStyle == 3
                xScatter{iterExpt} = [(rand(maxCt,1)-0.5)*spreadFac;NaN];
            else
                xScatter{iterExpt} = [zeros(maxCt,1);NaN];
            end
            if ~isempty(strfind(graphName,'escape')) && ~(~isempty(strfind(graphName,'3D')) || ~isempty(strfind(graphName,'elevation')))
                dirData = plotData(:,1);
                dirData = deg2rad(dirData);
                rhoVec = plotData(:,2);
                if ~isempty(strfind(graphName,'RhoOne'))
                    dirData(rhoVec < 0.25) = [];
                    rhoVec(rhoVec < 0.25) = [];
                    rhoVec = rhoVec*0+1;
                end
                if xory == 1
                    [plotData,~] = pol2cart(dirData(:),rhoVec(:));
                else
                    [~,plotData] = pol2cart(dirData(:),rhoVec(:));
                end
                if ~isempty(strfind(graphName,'sideways'))
                    plotData = abs(plotData);
                end
            end
            medData = plotData(:,1);
            medData(isnan(medData)) = [];
            if plotError == 3
                q2 = nanmean(medData);  n = numel(medData);
                err = 1.96*(std(medData)/sqrt(n));
            else
                q1 = prctile(medData,25); q2 = prctile(medData,50);
                q3 = prctile(medData,75); n = numel(medData);
                err = 1.57*(q3-q1)/sqrt(n);
            end
            medVec = [q2 q2 NaN]';
            if plotError == 2
                errVec = [q1 q2 q3 NaN]';
            else
                errVec = [q2-err q2 q2+err NaN]';
            end
            plotData = cat(1,plotData,NaN(maxCt-size(plotData,1)+1,size(plotData,2)));
            yScatter{iterExpt} = plotData(:,1);
            if numel(medData) >= 10
                eYall(:,iterExpt) = errVec;
            end
            if numel(medData) >= 5
                mYall(:,iterExpt) = medVec;
                text(xGrid(1,iterExpt)+0.2+xOffA,shiftList(numRef),...
                    ['median: ' num2str(q2,3)],'rotation',30,...
                    'color',fontC,'horizontalalignment','right','fontsize',fontSc);
                if write2excel == 1
                    excelTable.(graphName)(grpIDlist{sum(dataRef(1:iterExpt))}) = q2;
                end
            end
        end
        if binomialFlag(2) == 2
            binaryThresh = binomialFlag(3);
        else
            binaryThresh = nanmedian(mYall(2,:));
            binaryThresh(2) = prctile(mYall(2,:),25);
            binaryThresh(3) = prctile(mYall(2,:),75);
        end
        
        yScatter = cellfun(@(x) x(:),yScatter,'uniformoutput',false);
        yScatter = cat(2,yScatter{:});
        xScatter = cellfun(@(x) x(:),xScatter,'uniformoutput',false);
        xScatter = cat(2,xScatter{:});
        if binomialFlag(2) == 0
            %         yScatter(yScatter > yMax) = NaN; %%%% sets max value
            plotY = yScatter;
            if yScale == 1
%                 plotY = log10(plotY);
            end
            plotY = (plotY-yMin)./(yMax-yMin);
            for iterE = 1:xCt
                text(xGrid(1,iterE)+0.2+xOffA,-0.05,...
                    ['n = ' num2str(sum(~isnan(yScatter(:,iterE))))],'rotation',30,...
                    'color',fontC,'horizontalalignment','right','fontsize',fontSb);
                
                if numel(plotY(:,iterE)) > maxDataCt && boxPlot == 0
                    numRefs = find(~isnan(plotY(:,iterE)));
                    if numel(numRefs) > maxDataCt
                        subSample = randperm(numel(numRefs));
                        plotY(numRefs(subSample(maxDataCt+1:end)),iterE) = NaN;
                    end
                end
                
            end
            xOff = repmat((1:size(xScatter,2))+xOffA,size(xScatter,1),1);
            if boxPlot
                plotError = 0;
                hDataPlotA = boxplot(gca,plotY,'positions',xGrid(1,:)+xOffA,'boxstyle','outline',...
                    'colors',plotC,'notch','on','widths',spreadFac*1.75);
                set(hDataPlotA(end,:),'marker','.','markeredgecolor','none','markersize',12)
                set(hDataPlotA(1:end-1,:),'linewidth',2,'linestyle','-')
                set(hDataPlotA(3:4,:),'linewidth',2,'linestyle','-','color','none')
                hDataPlotA = hDataPlotA(1);
                plotC = lineCa;
            elseif dataStyle == 1
                hDataPlotA = plot(xScatter+xOff,plotY,...
                    '.','markersize',8,'color',plotC.^1.5);
                plotC = lineCa;
            elseif dataStyle == 2 || dataStyle == 3
                for iterR = 1:size(plotY,2)
                    if dataStyle == 2
                        rasterFac = spreadFac;
                    else
                        rasterFac = spreadFac/10;
                    end
                    subplotX = [xScatter(:,iterR)+xOff(:,iterR)-rasterFac xScatter(:,iterR)+xOff(:,iterR)+rasterFac NaN(size(xScatter,1),1)]';
                    subplotY = [sort(plotY(:,iterR)) sort(plotY(:,iterR)) NaN(size(plotY,1),1)]';
                    for y = 2:size(subplotY,2)
                        if subplotY(1,y) == subplotY(1,y-1)
                            equalRefs = find(subplotY(1,:) == subplotY(1,y-1));
                            addval = 0;
                            for z = 1:numel(equalRefs)
                                subplotY(:,equalRefs(z)) = subplotY(:,equalRefs(z))+addval;
                                addval = addval+0.001;
                            end
                        end
                    end
                    hDataPlotA = plot(subplotX(:),subplotY(:),...
                        'linewidth',0.5,'color',plotC.^1.5);
                end
                plotC = lineCa;
            else
                hDataPlotA = plot(NaN,NaN,...
                    '.','markersize',8,'color',plotC.^1.5);
                plotC = colorOps{iterG}*.8;
            end
            mYall = (mYall-yMin)./(yMax-yMin);
            eYall = (eYall-yMin)./(yMax-yMin);
            if regression > 0
                xOffA = mean(xOffOps(iterG:iterG+1))*0.2-0.2;
                yFit = mYall(2,:);
                wFit = sum(~isnan(yScatter),1);
            end
            medianX = xGrid(1:3,:)+xOffA+repmat([-spreadFac;spreadFac;0],1,xCt);
            if plotError
                if yScale == 1
%                     mYall = log10(mYall);
%                     eYall = log10(eYall);
                end
                eYall(eYall < yMin) = yMin;
                eYall(eYall > yMax) = yMax;
                plot(medianX,mYall,'color',plotC,'linewidth',2);
                plot(xGrid+xOffA,eYall,'color',plotC,'linewidth',1);
            end
            
            try
                hLegendA(iterG) = hDataPlotA(1);
            catch
                hLegendA(iterG) = hDataPlotB(1);
            end
        end
    end
    if binomialFlag(2) > 0 || ~isempty(strfind(graphName,'Frequency'))
        if ~isempty(strfind(graphName,'jumpFrequency'))
            binomialFlag(1) = 10;
            totalTrue = NaN(xCt,1);
            totalTrue(dataRef) = cellfun(@(x) sum(x),grpTable.jumpTest);
            totalVids = NaN(xCt,1);
            totalVids(dataRef) = cellfun(@(x) numel(x),grpTable.jumpTest);
        elseif strcmp(graphName,'shortFrequency')
            binomialFlag(1) = 10;
            totalTrue = NaN(xCt,1);
            totalTrue(dataRef) = cellfun(@(x) sum(x),grpTable.shortTest);
            totalVids = NaN(xCt,1);
            totalVids(dataRef) = cellfun(@(x) sum(x),grpTable.jumpTest);
        elseif strcmp(graphName,'moveFrequency')
            binomialFlag(1) = 10;
            totalTrue = NaN(xCt,1);
            totalTrue(dataRef) = cellfun(@(x) sum(x),grpTable.nonMovers);
            totalVids = NaN(xCt,1);
            totalVids(dataRef) = cellfun(@(x) numel(x),grpTable.nonMovers);
        elseif strcmp(graphName,'earlyMoverFrequency')
            binomialFlag(1) = 10;
            totalTrue = NaN(xCt,1);
            totalTrue(dataRef) = cellfun(@(x) sum(x),grpTable.earlyMovers);
            totalVids = NaN(xCt,1);
            totalVids(dataRef) = cellfun(@(x) numel(x),grpTable.earlyMovers);
        else
            totalVids = NaN(xCt,1);
            totalTrue = NaN(xCt,1);
            for iterExpt = 1:xCt
                binData = yScatter(:,iterExpt);
                if ~isempty(binData)
                    binData = binData(:,1);
                    if binomialFlag(1) == 1
                        totalTrue(iterExpt) = sum(binData > binaryThresh(1));
                    elseif binomialFlag(1) == -1
                        totalTrue(iterExpt) = sum(binData < binaryThresh(1));
                    end
                    totalVids(iterExpt) = sum(~isnan(binData));
                end
                plotTable.binomialData(grpIDlist{sum(dataRef(1:iterExpt))},:) = [totalTrue(iterExpt) totalVids(iterExpt)];
            end
        end
        for iterE = 1:numel(grpTable.order);
            ndx = grpTable.order(iterE);
            text(xGrid(1,ndx)+0.1+xOffA,-0.03,[num2str(round(totalTrue(ndx)/totalVids(ndx)*100),3) ' %'],...
                'rotation',30,'color',fontC,'horizontalalignment','right','fontsize',fontSc);
            text(xGrid(1,ndx)+0.1+xOffA,-0.13,['n = ' num2str(totalVids(ndx))],...
                'rotation',30,'color',fontC,'horizontalalignment','right','fontsize',fontSc);
        end
        binomialData = totalTrue./totalVids*100;
        binomialData(totalVids == 0) = NaN;
        [excelIDlist,ia] = intersect(grpIDlist,excelTable.Properties.RowNames);
        excelTable.(graphName)(excelIDlist) = binomialData(ia)/100;
        yData = [binomialData(:)';NaN(1,xCt)];
        if regression > 0
            xOffA = mean(xOffOps(iterG:iterG+1))*0.3-0.2;
            yFit = binomialData/100;
            wFit = totalVids;
        end
        xPlot = xGrid(1:2,:)+xOffA;
        plotRedLineY = nansum(totalTrue)/nansum(totalVids)*100;
        if ~isempty(strfind(graphName,'Frequency'))
            binaryThresh = plotRedLineY;
        end
        if showRedLine == 1
            plotRedLineX = xlines(1:2);
            plot(plotRedLineX,([plotRedLineY plotRedLineY]-yMin)/(yMax-yMin),'color',[.5 0 0],'linewidth',2);
        end
        alpha = 0.05;
        [~,pci] = binofit(abs(totalTrue(~isnan(totalTrue))),totalVids(~isnan(totalTrue)),alpha);
        pci(totalTrue(dataRef) < 0,:) = pci(totalTrue(dataRef) < 0,:)*(-1);
        errorY = NaN(xCt,2);
        errorY(dataRef,:) = pci;
        errorY = [errorY';NaN(1,size(errorY,1))]*100;
        
        if plotError
            errorY(:,isnan(totalTrue)) = NaN;
            plot(xGrid(1:3,:)+xOffA,(errorY-yMin)/(yMax-yMin),'color',[0 0 0],'linewidth',2);
        end
        
        yPlot = (yData-yMin)/(yMax-yMin);
        if dataStyle == 2
            yPlot = cat(1,yPlot(1,:),yPlot);
            xPlot = [xPlot(1,:)-spreadFac*0.8;xPlot+spreadFac*0.8];
            hDataPlotA = plot(xPlot,yPlot,'color',plotC.^1.5,...
                'linewidth',6);
        else
            hDataPlotA = plot(xPlot,yPlot,'color',plotC.^1.5,...
                'marker','.','linestyle','none','markersize',30);
        end
        hLegendA(iterG) = hDataPlotA(1);
        
    end
    if regression > 0
        xFit = xVals;
        xEval = xFit;
        [xFit,yFit,wFit] = prepareSurfaceData(xFit(:),yFit(:),wFit(:));
        wFit = log(wFit);
        if strcmp(modelStr,'weibull')
            fitModel = modelStr;
            fitobj = fit(xFit(:),yFit(:),fitModel,'weights',wFit(:),'StartPoint',[0.01 1.5]);
        else
            fitModel = [modelStr num2str(exp4fit)];
            if max(strcmp({'sin','fourier'},modelStr)) && exp4fit > 1 && numel(xFit) < 6
                disp('temp model used')
                tempModel = [modelStr num2str(exp4fit-1)];
                fitobj = fit(xFit(:),yFit(:),tempModel,'weights',wFit(:));
            else
                fitobj = fit(xFit(:),yFit(:),fitModel,'weights',wFit(:));
            end
        end
        lineX = linspace(xEval(1),xEval(end),1000);
        lineY = feval(fitobj,lineX(:));
        lineX = linspace(min(xGrid(:)),max(xGrid(:)),1000);
        plot(lineX+xOffA,lineY,'color',plotC.^1.5,'linewidth',2);
    end
end
set(gca,'xLim',[0 xCt+1],'ylim',[-labelDropVal 1.01])

%%%%% Y-axis tick labels
if (yMax-yMin) >= 100, yFac = 1;
elseif (yMax-yMin) >= 10, yFac = 10;
elseif (yMax-yMin) >= 1, yFac = 100;
else yFac = 1000;
end
tickVal = round(linspace(yMin,yMax,yCount)*yFac)/yFac;
if yScale == 1
    tickVal = 10.^tickVal;
end
for iterE = 1:numel(tickVal)
    yStr = num2str(round(tickVal(iterE)*yFac)/yFac);
    text(-0.1,ytickpos(iterE),yStr,'interpreter','none',...
        'color',fontC,'horizontalalignment','right','fontsize',fontSb);
end

%%%% X-axis tick labels
for iterE = 1:xCt
    fullLabel = plotTable.plotID{find(plotTable.order == iterE,1)};
    labelSpl = strsplit(strtrim(fullLabel),'_');
    for iterSL = 1:numRef
        if iterSL > numel(labelSpl)
            continue
        end
        fontSize = fontSb;
        rotVal = 30;
        textXY = [xGrid(1,iterE)+0.1,shiftList(iterSL)+0.03];
        labelX = labelSpl{iterSL};
        text(textXY(1),textXY(2),labelX,...
            'horizontalalignment','right','rotation',rotVal,...
            'color',fontC,'interpreter','none','fontsize',fontSize);
    end
end
if write2excel == 1
    try
        writetable(excelTable,excelPath,'Sheet',sheetName2plot,'WriteRowNames',true)
    catch
        disp('could not write to excel file')
    end
end
%%%%%% Red line plot here

if binomialFlag(2) == 0 && showRedLine == 2
    plotRedLineY = [nanmedian(nanmedian(yScatter))
        nanmedian(prctile(yScatter,25))
        nanmedian(prctile(yScatter,75))];
    plotRedLineY = [plotRedLineY plotRedLineY NaN(3,1)]';
    plotRedLineX = repmat([xlines(1:2);NaN],1,3);
    plot(plotRedLineX,(plotRedLineY-yMin)/(yMax-yMin),'color',[.5 0 0],...
        'linestyle','--','linewidth',1);
    plot(plotRedLineX(:,1),(plotRedLineY(:,1)-yMin)/(yMax-yMin),'color',[.5 0 0],'linewidth',2);
elseif binomialFlag(2) == 0 && showRedLine == 3
    plotRedLineY = [binomialFlag(3);binomialFlag(3)];
    plotRedLineX = xlines(1:2);
    if yScale == 1
        plotRedLineY = log10(plotRedLineY);
    end
    plot(plotRedLineX,(plotRedLineY-yMin)/(yMax-yMin),'color',[.5 0 0],'linewidth',2);
end



%%%% %Title and other labels
writeName = graphName;
if regression == 1
    writeName = [writeName '_' num2str(exp4fit) 'dof_' modelStr];
end
if binomialFlag(2) == 0
    if numel(binaryThresh) == 3
        titleStr = {excelName,sheetName2plot,writeName,...
            [graphOptions.subset2plot ' -- median: ' num2str(binaryThresh(1),3),...
            ' - 25pct: ' num2str(binaryThresh(2),3) ' - 75pct: ' num2str(binaryThresh(3),3)]};
    else
        titleStr = {excelName,sheetName2plot,writeName,...
            [graphOptions.subset2plot ' -- median: ' num2str(binaryThresh(1),3)]};
    end
else
    titleStr = {excelName,sheetName2plot,writeName,...
        [graphOptions.subset2plot ' -- thresh: ' num2str(binaryThresh(1),3)]};
end
text(0,1.15,titleStr,...
    'horizontalalignment','left','interpreter','none',...
    'rotation',0,'color',fontC,'fontsize',round(fontSa));
if grpCt > 1
    hLegend = legend(hLegendA(:)',groupIDlist,'interpreter','none');
    set(hLegend,'units','pixels')
    hLpos = round(get(hLegend,'position'));
    hLpos(1) = figPos(3)-125;
    set(hLegend,'position',hLpos)
end
if ~isempty(strfind(writeName,'escape')) && ~isempty(strfind(writeName,'Azi'))
    nameSpl = strsplit(writeName,'_');
    vsRef = strfind(nameSpl{end},'VS');
    text(-1,1,nameSpl{end}(1:vsRef-1))
    text(-1,0,nameSpl{end}(vsRef+2:end))
end
exportVisualizationFigure(pdfName,saveFig)
end