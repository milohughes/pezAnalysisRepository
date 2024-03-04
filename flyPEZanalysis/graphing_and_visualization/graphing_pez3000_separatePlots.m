function pdfName = graphing_pez3000_separatePlots(graphTable)
%%
if ~exist('graphTable','var') || isempty(mfilename)
    graphTable = makeGraphingTable;
end
%%
%
% grpID = 'DL';
% upperBound = Inf;%41
% lowerBound = 100;%41;
%
% exptList = cellfun(@(x) x(29:44),plotTable.videoList{grpID},'uniformoutput',false);
% ratioData = plotTable.returnData{grpID};
% testLogical = ratioData < log(upperBound/6) & ratioData > log(lowerBound/6);
% lowList = exptList(testLogical);
% plotTable.videoList{grpID}(testLogical)
% prctPart = round(cellfun(@(x) sum(strcmp(lowList,x))/numel(strcmp(lowList,x))*100,unique(lowList)));
% [unique(lowList) cellstr(num2str(prctPart))]
%%
clearvars -except graphTable
rng('default');
rng(19);
for iterView = 3%:3
segmentChoice = 10; % 1-full 10 ms...2-fot...3-mid leg extend...4-full leg
% extend...5-entire vector...6-half loom...7-jumpCap...8-last half
% loom...9-distCap
%
% use with escape plot
dirChoice = [1 3 1 1];
%   1-Jump ; 2-Departure ; 3-Trajectory ; 4-Meatball
%   1-zeroStimAzi ; 2-zeroFlyAzi ; 3-3D ; 4-elevation
%   1-Angle ; 2-Dist ; 3-Binomial
%   1-Variable Rho ; 2-One Rho


plotChoice = 4;
groupChoice = 0;
saveFig = 0;
exportVariables = 0;
singleAx = 0;
rhoThresh = [0.5 Inf];%0.05
plotCircHist = 0;
plotCircArrow = 0;
circConfStyle = 0;
rhoStyle = 2;%0=all set to 1,1=dist traveled 0 to 1.5,2=elevation 0to90
showDotsOrLines = 1;% 1-dots; 2-lines
gaussFitCt = 4;
barwidth = .1;% .2  %.16
normalizeWing2fot = 1;
maxScatterCt = 50; % departureScatter, spaghetti, and escape - used 40,50, and 150
showRemoval = 1;
plotContour = 0;
explicitTimeBounds = [1 -1000 -50]; % 1 to use, start time, stop time (ms)
fG = -3;
plotOps = {'wing2fot_histogram';'wing2fot_histogram_smoothed' % 1 - 2
    'escape';'spaghettiPlot_zeroFly';'departureScatter' % 3 - 5
    'departureHistogram_zeroFly';'departureHistogram_zeroStim' % 6 - 7
    'loomApproach'}; % 8
graphName = plotOps{plotChoice};
dirOpsA = {'Jump','Departure','Trajectory','Meatball'};
dirOpsB = {'zeroStimAzi','zeroFlyAzi','3D','elevation'};
dirOpsC = {'Angle','Dist','Binomial'};
dirOpsD = {'RhoVar','RhoOne'};
segmentOps = {'FullJumpDur','Fot','MidLegExt','FullLegExt','FullDur','MidLoom',...
    'JumpCap','LateLoomMvntCap','MvntCap','FullStim','MaxVelWin'};

if strcmp(graphName,'spaghettiPlot_zeroFly')
    if explicitTimeBounds(1) == 1
        segmentOps{segmentChoice} = ['timeBounds' num2str(explicitTimeBounds(2)) 'to' num2str(explicitTimeBounds(3))];
    end
    graphName = cat(2,graphName,'_',segmentOps{segmentChoice},'_overlay');
elseif strcmp(graphName,'escape')
    graphName = cat(2,graphName,dirOpsA{dirChoice(1)},'_',dirOpsB{dirChoice(2)},...
        '_',dirOpsC{dirChoice(3)},dirOpsD{dirChoice(4)});
end
optionsPath = 'Z:\Data_pez3000_analyzed\WRW_graphing_variables\graphOptions.mat';
%%%%%
makeGraphOptionsStruct([],graphName)
[plotTable,excelTable] = addPlotData(graphTable);
%%%%%

graphOptionsLoading = load(optionsPath);
graphOptions = graphOptionsLoading.graphOptions;
sheetName2plot = graphOptions.sheetName;
graphOptionsLoading = load(optionsPath);
graphOptions = graphOptionsLoading.graphOptions;
groupIDlist = graphOptions.groupIDlist;
plotIDlist = graphOptions.plotIDlist;

if groupChoice == 0
    grpOps = 1:numel(groupIDlist);
else
    grpOps = groupChoice;
end

varMfun = cell(max(grpOps),1);
fitXavg4varM = cell(max(grpOps),1);
fitYavg4varM = cell(max(grpOps),1);
fitX4varM = cell(max(grpOps),1);
fitY4varM = cell(max(grpOps),1);
for groupChoice = grpOps
    
    if numel(get(0,'children')) > 5
        close all
    end
    xCt = numel(plotIDlist);
    grpID = groupIDlist{groupChoice};
    grpBool = strcmp(grpID,plotTable.groupID);
    if max(strcmp(excelTable.Properties.VariableNames,'repeat'))
        grpBool = grpBool | plotTable.repeat;
    end
    grpTable = plotTable(grpBool,:);
    grpIDlist = grpTable.Properties.RowNames;
    [~,grpOrder] = sort(excelTable.order(grpIDlist));
    grpTable = grpTable(grpOrder,:);
    grpIDlist = grpTable.Properties.RowNames;
    dataRef = find(ismember((1:xCt),grpTable.order));
    subset2plot = graphOptions.subset2plot;
    xCt = numel(dataRef);
    % return
    
    if xCt > 36 %33
        xCt = 36;
        disp('overcount!')
    end
    if groupChoice == grpOps(1)
        outputData = cell(xCt,numel(grpOps));
        outputVideoNames = cell(xCt,numel(grpOps));
        outputGrpNames = cell(1,numel(grpOps));
        outputPlotNames = cell(xCt,numel(grpOps));
    end
    outputGrpNames(groupChoice) = groupIDlist(groupChoice);
    %group colors
    colorOps = {[55 126 184];[228 26 28];[77 175 74];[152 78 163];[255 127 0]};
    colorOpsA = cellfun(@(x) (x/255).^(0.7),colorOps,'uniformoutput',false);
    colorOps = {[55 126 184];[228 26 28];[77 175 74];[152 78 163];[255 127 0]};
    colorOpsB = cellfun(@(x) (x/255).^(1.2),colorOps,'uniformoutput',false);
    fontSa = 18; fontSb = 12; fontSc = 12;
    
    colorType = 1;
    if colorType == 1
        fontC = [0 0 0];
        backC = [1 1 1];
        lineCa = [0 0 0];
        lineCb = [0.5 0.5 0.5]+0.2;
        colorOps = cat(1,colorOpsB,colorOpsA);
    else
        fontC = [1 1 1];
        backC = [0 0 0];
        lineCa = [0 0 0];
        lineCb = [0 0 0]+0.5;
        colorOps = cat(1,colorOpsA,colorOpsB);
    end
    
    figure
    figPos = [1988 43 1778 1030];
    set(gcf,'position',figPos)
    hax = zeros(1,xCt);
    hax(1) = axes;
    haxPos = get(hax(1),'position');
    growShiftAx = [0.1,-0.1,0,0.02];%grow width, grow height, shift X, shift Y
    haxPos = [haxPos(1)-haxPos(3)*growShiftAx(1)/2,haxPos(2)-haxPos(4)*growShiftAx(2)/2,...
        haxPos(3)*(1+growShiftAx(1)),haxPos(4)*(1+growShiftAx(2))]+[growShiftAx(3:4) 0 0];
    ycolor = 'none';
    rows = 1;
    fG = 0;
    if contains(graphName,'wing2fot_histogram')
        if ~contains(graphName,'barWidth')
            graphName = cat(2,graphName,['_gaussFitCt-' num2str(gaussFitCt) '_barWidth-' regexprep(num2str(barwidth),'\.','pt')]);
        end
        if xCt > 15
            rows = 4;
            cols = ceil(xCt/rows);
        elseif xCt > 9
            rows = 3;
            cols = ceil(xCt/rows);
        else
            rows = 4;
            cols = 2;
        end
        axWH = [haxPos(3)/cols haxPos(4)/rows];
        startPosY = repmat(fliplr(axWH(2)*(0:rows-1)),cols,1)';
        startPosX = repmat(axWH(1)*(0:cols-1),rows,1);
        
        
        options = statset('MaxIter',500);
        xmin = 0.0;      xmax = 7;
        intervals = (xmin:barwidth:xmax);
        fitX = linspace(xmin,xmax,1000);
        %     xtickval = unique(round(logspace(log10(1),log10(300),10)/5)*5);
        xtickval = unique(round(logspace(log10(1),log10(300),10)/10)*10);
        xtickval = [1.25 2.5 5 xtickval(2:end)];
        xtickval = [2.5 5 10 25 50 100 200];
        xtickpos = log(xtickval);
        
        %     xmin = 0;      xmax = 300;
        %     intervals = (xmin:barwidth:xmax);
        %     fitX = linspace(xmin,xmax,1000);
        %     xtickval = round(xmin:50:xmax);
        %     xtickpos = xtickval;
        ytickval = [0 1]; ytickpos = [0 1];
        xAxisName = 'ms';
        grpTable.wing2fot_hist = cell(size(grpTable,1),1);
    elseif contains(graphName,'departureScatter')
        %     xtickpos = (-180:60:180);
        xtickpos = (0:30:180);
        xtickval = xtickpos;
        ytickpos = linspace(0,360+180,7);
        ytickval = ytickpos;
        axWH = [haxPos(3) haxPos(4)];
        startPosY = axWH(2)*0.1;
        startPosX = axWH(1)*0.1;
        xAxisName = 'Stimulus Azimuth (degrees)';
    else %if ~isempty(strfind(graphName,'spaghettiPlot')) || ~isempty(strfind(graphName,'escape'))
        if xCt > 15
            rows = 4;
        elseif xCt > 8
            rows = 3;
        elseif xCt > 1
            rows = 2;
            fG = -2;
        end
        if singleAx == 1
            rows = 1;
            fG = 0;
            axWH = [haxPos(3)/ceil(1/rows) haxPos(4)/rows];
        else
            axWH = [haxPos(3)/ceil(xCt/rows) haxPos(4)/rows];
        end
        
        startPosY = repmat(fliplr(axWH(2)*(0:rows-1)),ceil(xCt/rows),1);
        startPosX = repmat(axWH(1)*(0:ceil(xCt/rows)-1),1,rows);
        xAxisName = 'mm';
        if contains(graphName,'escape') || contains(graphName,'loomApproach')
            if contains(graphName,'Trajectory')
                %         xtickpos = (-3:1.5:3);
                xtickpos = linspace(-1,1,3);
            elseif contains(graphName,'Departure')
                %         xtickpos = (-0.5:0.25:0.5);
                xtickpos = linspace(-1,1,5);
            else
                xtickpos = linspace(-1,1,3);
            end
        else
            xtickpos = (-1:1:1);
        end
        %     xtickpos = xtickpos/2;
        xtickval = xtickpos;
        if contains(graphName,'elevation')
            ytickpos = xtickpos(xtickpos >= 0);
        else
            ytickpos = xtickpos;
        end
        ytickval = ytickpos;
    end
    %%%% %Title and other labels
    fontSa = fontSa+fG; fontSb = fontSb+fG; fontSc = fontSc+fG;
    if strcmp(groupIDlist{groupChoice},sheetName2plot)
        pdfName = [sheetName2plot '_' graphName '_' graphOptions.subset2plot];
    else
        pdfName = [sheetName2plot '_' graphName '_' groupIDlist{groupChoice} '_' graphOptions.subset2plot];
    end
    htit = text(xtickpos(1),ytickpos(end)+range(ytickpos)*(rows/4),pdfName,...
        'horizontalalignment','left','interpreter','none',...
        'rotation',0,'color',fontC,'fontsize',round(fontSa*1.2));
    mainAx = gca;
    if contains(graphName,'departureScatter')
        singleAx = true;
        axWH = [haxPos(3) haxPos(4)];
        startPosY = axWH(2)*0.1;
        startPosX = axWH(1)*0.1;
    end
    thetaCell = cell(xCt,1);
    alphaCell = cell(xCt,1);
    h4leg = zeros(xCt,1);
    dataCtTally = 0;
    hScat = zeros(xCt,1);
    for iterE = 1:xCt
        %     if ~dataRef(iterE)
        %         if iterE == 1
        %             delete(hax(1))
        %         end
        %         continue
        %     end
        ndxName = grpIDlist{iterE};
        outputPlotNames{iterE,groupChoice} = ndxName;
        if contains(graphName,'loomApproach')
            data = grpTable.zeroFly_StimAtStimStart{ndxName}';
        else
            data = grpTable.returnData(ndxName)';
        end
        videoList = grpTable.videoList{ndxName};
        try
            data = (cat(1,data{:}))';
        catch
            data = (cat(2,data{:}))';
        end
        if iterE > 1
            if ~singleAx
                hax(iterE) = axes;
            else
                hax(iterE) = hax(1);
            end
        end
        if hax(iterE) == 0
            continue
        end
        set(hax(iterE),'nextplot','add')
        if isempty(data)
            if ~singleAx
                delete(hax(iterE))
            end
            continue
        end
        if contains(graphName,'wing2fot_histogram')
            if showRemoval == 1
                disp([num2str(sum(data > xmax)) ' removed for duration greater than xmax : ' ndxName])
            end
            videoList(data > xmax) = [];
            data(data > xmax) = [];
            ctMax = Inf;
            if numel(data) > ctMax
                randVec = randperm(ctMax);
                data = data(randVec(1:ctMax));
            end
            [f,x] = hist(data,intervals);
            if contains(graphName,'smoothed')
                f = f/range(f);
                f = round(smooth(f,3)*100);
                fitdata = cell(numel(f),1);
                for iterF = 1:numel(x)
                    fitdata{iterF} = repmat(x(iterF),f(iterF),1);
                end
                fitdata = cat(1,fitdata{:});
            else
                fitdata = data(:);
            end
            if showRemoval == 1
                disp([num2str(sum(isnan(fitdata))) ' removed for nan : ' ndxName])
            end
            videoList(isnan(fitdata)) = [];
            fitdata(isnan(fitdata)) = [];
            if showRemoval == 1
                disp([num2str(sum(fitdata < 1)) ' removed for greater than one : ' ndxName])
            end
            videoList(fitdata < 1) = [];
            fitdata(fitdata < 1) = [];
            if normalizeWing2fot == 1
                f = f/range(f);
            else
                f = f/sum(f)*1.5;
            end
            bar(x,f,'stack','barwidth',1,'facecolor',colorOps{1}.^0.7);
            orig_state = warning;
            warning('off','all')
            
            obj = cell(numel(gaussFitCt),1);
            aic = zeros(numel(gaussFitCt),1);
            for iters = 1:numel(gaussFitCt)
                conv = false;
                iterations = gaussFitCt(iters)+1;
                while ~conv && iterations > 1
                    iterations = iterations - 1;     int_cond = [];
                    for iterI = 1:(iterations - 1)
                        int_cond = [int_cond;ones(round(length(fitdata)/iterations),1)*iterI];
                    end
                    if isempty(iterI), iterI = 0; end
                    int_cond = [int_cond;ones((length(fitdata) - length(int_cond)),1)*(iterI+1)];
                    try
                        %                 obj = gmdistribution.fit(fitdata,iterations,'Options',options,'Start',int_cond);
                        obj{iters} = fitgmdist(fitdata,iterations,'Options',options,'Start',int_cond);
                        conv = obj{iters}.Converged;
                        aic(iters) = obj{iters}.BIC;
                        %                     obj.BIC
                        %                     obj.NegativeLogLikelihood
                    catch
                    end
                end
            end
            warning(orig_state)
            obj = obj{aic == min(aic)};
            if ~isempty(obj) && obj.Converged
                fitY = pdf(obj,fitX');
                if normalizeWing2fot == 1
                    fitY = fitY/range(fitY);
                else
                    fitY = fitY/sum(f)*0.3;
                end
                if showDotsOrLines == 1
                    plot(fitX,fitY,'color',colorOps{2}.^1.3,'LineWidth',3);
                end
            end
            medX = nanmedian(data)+[0 0];
            medY = [0 1];
            plot(medX,medY,'color','g','linewidth',3,'linestyle','--');
            plot(log([41/6 41/6]),[0 1],'color','k','linewidth',3,'linestyle','--');
            ycolor = 'none';
            grpTable.wing2fot_hist(ndxName) = {[x(:),f(:)]};
        elseif contains(graphName,'spaghettiPlot')
            axis equal
            plot([xtickpos(1) xtickpos(end)],zeros(1,2),'color',lineCb)
            plot(repmat(median(xtickpos),1,2),[ytickpos(1) ytickpos(end)],'color',lineCb)
            comboPlot = 3;
            brkPts = find(isnan(data(1,:)));
            brkCt = numel(brkPts);
            if comboPlot == 1
                if brkCt > maxScatterCt
                    brkPt = brkPts(maxScatterCt);
                else
                    brkPt = brkPts(end);
                end
                plot(data(1,1:brkPt),data(2,1:brkPt),'color',colorOps{3},'LineWidth',0.5);
            elseif comboPlot == 2
                if brkCt > maxScatterCt, brkCt = maxScatterCt; end
                for iterBrk = 1:brkCt
                    if iterBrk == 1
                        data2plot = data(:,1:brkPts(iterBrk));
                    else
                        data2plot = data(:,brkPts(iterBrk-1)+1:brkPts(iterBrk));
                    end
                    plot(data2plot(1,:),data2plot(2,:),'LineWidth',0.5)%,'color',cA{iterC});
                end
            else
                if brkCt > maxScatterCt, brkCt = maxScatterCt; end
                data2plot = [];
                for iterBrk = 1:brkCt
                    if grpTable.jumpTest{ndxName}(iterBrk) == 1
                        continue
                    end
                    if iterBrk == 1
                        data2plot = cat(2,data2plot,data(:,1:brkPts(iterBrk)));
                    else
                        data2plot = cat(2,data2plot,data(:,brkPts(iterBrk-1)+1:brkPts(iterBrk)));
                    end
                end
                if ~isempty(data2plot)
                    hplot = plot(data2plot(1,:),data2plot(2,:),'LineWidth',1,...
                        'linestyle','-','color',colorOps{3});
                    hplot.Color(4) = 0.5;
                end
                data2plot = [];
                dot2plot = [];
                for iterBrk = 1:brkCt
                    if grpTable.jumpTest{ndxName}(iterBrk) == 0
                        continue
                    end
                    if iterBrk == 1
                        data2plot = cat(2,data2plot,data(:,1:brkPts(iterBrk)));
                    else
                        data2plot = cat(2,data2plot,data(:,brkPts(iterBrk-1)+1:brkPts(iterBrk)));
                    end
                    dot2plot = cat(2,dot2plot,data2plot(:,end-1));
                end
                if ~isempty(data2plot)
                    hplot = plot(data2plot(1,:),data2plot(2,:),'LineWidth',1,...
                        'linestyle','-','color',colorOps{4});
                    hplot.Color(4) = 0.5;
                    plot(dot2plot(1,:),dot2plot(2,:),'.','markersize',8,...
                        'color','k');
                end
            end
            [stimx,stimy] = pol2cart(grpTable.azimuth(ndxName)*(pi/180),max(ytickpos)/2);
            if ~strcmp(ndxName,'noStim') && ~strcmp(grpTable.stimType{ndxName},'Photoactivation')
                stimX = [0 stimx];
                stimY = [0 stimy];
            else
                stimX = [0 0];
                stimY = [NaN NaN];
            end
            plot(stimX,stimY,'color',colorOps{1},'LineWidth',2);
            ycolor = fontC;
        elseif contains(graphName,'escape') || contains(graphName,'loomApproach')
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            visStyle = 1;% 2-omit jump data ; 3-show loom only
            flipLR = 1; % 1-fliplr ; 2-randomize
            maxDirCt = Inf;% 4 for fieldMap - 50 for something i don't remember
            showMedian = 0;
            plotGrpMedians = 0;
            plotContour = 0;
            colorCode = 0;
            showLoomDir = 0;
            viewAngle = iterView; % 0-mid ; 1-side ; 2-front ; 3-top
            xtickpos = linspace(-1,1,3);
            flyFactor = 0.9;
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            axis equal
            if plotGrpMedians == 1 || plotContour == 1
                maxDirCt = size(data,2);
                rhoThresh = [0.05 2];%0.05
            else
                %             showLoomDir = 0;
            end
            data2remove = data(5,:) < rhoThresh(1);
            if showRemoval == 1
                disp([num2str(sum(data2remove)) ' removed for rho less than rhoThresh minimum : ' ndxName])
            end
            if showRemoval == 1
                disp([num2str(sum(data(5,:) > rhoThresh(2))) ' adjusted for rho more than rhoThresh maximum : ' ndxName])
            end
            data(5,data(5,:) > rhoThresh(2)) = rhoThresh(2);
            eleMin = 0;
            data2remove(data(4,:) < eleMin) = 1;
            if showRemoval == 1
                disp([num2str(sum(data(4,:) < eleMin)) ' removed for elevation less than ' num2str(eleMin) 'deg : ' ndxName])
            end
            grpTable.jumpTest{ndxName}(data2remove) = [];
            grpTable.zeroFly_StimAtStimStart{ndxName}(data2remove) = [];
            data(:,data2remove) = [];
            videoList(data2remove) = [];
            dataCtTally = dataCtTally+size(data,2);
            if size(data,2) > maxDirCt
                randrefs = randperm(size(data,2));
                data = data(:,randrefs(1:maxDirCt));
            end
            if (contains(graphName,'3D') || contains(graphName,'loomApproach')) && plotContour == 0
                
                if visStyle == 3
                    data = [0;grpTable.azimuth(ndxName);0;grpTable.elevation(ndxName);1];
                    flipLR = 0;
                end
                instDataJump = cat(1,data(2,:),data(4,:),data(5,:));
                instDataLoom = cat(1,repmat(grpTable.azimuth(ndxName),1,size(data,2)),...
                    repmat(grpTable.elevation(ndxName),1,size(data,2)),...
                    ones(1,size(data,2)));
                instDataLvJ = data(1,:);
                if flipLR == 2
                    randFlip = rand(size(instDataJump(1,:)));
                    randFlip = round(randFlip)*2-1;
                    instDataJump(1,:) = instDataJump(1,:).*randFlip;
                    instDataLoom(1,:) = instDataLoom(1,:).*randFlip;
                elseif flipLR == 1
                    instDataJump(1,:) = instDataJump(1,:).*(-1);
                    instDataLoom(1,:) = instDataLoom(1,:).*(-1);
                end
                if plotGrpMedians == 1
                    separateAziEle = 0;
                    if separateAziEle == 1
                        [xMed,yMed] = pol2cart(deg2rad(instDataJump(1,:)),...
                            ones(1,size(instDataJump,2)));
                        azi = cart2pol(nanmedian(xMed),nanmedian(yMed));
                        instDataJump = cat(1,rad2deg(azi(:))',median(instDataJump(2,:)),...
                            median(instDataJump(3,:)));
                    else
                        [xMed,yMed,zMed] = sph2cart(deg2rad(instDataJump(1,:)),...
                            deg2rad(instDataJump(2,:)),deg2rad(instDataJump(3,:)));
                        [azi,ele,rho] = cart2sph(nanmedian(xMed),nanmedian(yMed),nanmedian(zMed));
                        instDataJump = cat(1,rad2deg(azi(:))',rad2deg(ele(:))',...
                            median(rho));
                    end
                    [xMed,yMed,zMed] = sph2cart(deg2rad(instDataLoom(1,:)),...
                        deg2rad(instDataLoom(2,:)),instDataLoom(3,:));
                    [azi,ele,rho] = cart2sph(nanmedian(xMed),nanmedian(yMed),nanmedian(zMed));
                    instDataLoom = cat(1,rad2deg(azi(:))',rad2deg(ele(:))',rho(:)');
                    instDataLvJ = median(instDataLvJ);
                end
                if ~singleAx || iterE == 1
                    if iterE == 1
                        make3Dflyplot(hax(iterE),xtickpos(end),1,flyFactor)
                    else
                        make3Dflyplot(hax(iterE),xtickpos(end),0)
                    end
                    dirData = instDataJump(1,:);
                    eleData = instDataJump(2,:);
                    rhoVec = instDataJump(3,:);
                    loomAzi = instDataLoom(1,:);
                    loomEle = instDataLoom(2,:);
                    loomRho = instDataLoom(3,:);
                    loomVSjump = instDataLvJ;
                elseif singleAx && iterE ~= 1
                    dirData = cat(2,dirData,instDataJump(1,:));
                    eleData = cat(2,eleData,instDataJump(2,:));
                    rhoVec = cat(2,rhoVec,instDataJump(3,:));
                    loomAzi = cat(2,loomAzi,instDataLoom(1,:));
                    loomEle = cat(2,loomEle,instDataLoom(2,:));
                    loomRho = cat(2,loomRho,instDataLoom(3,:));
                    loomVSjump = cat(2,loomVSjump,instDataLvJ);
                end
                if singleAx && iterE ~= xCt
                    continue
                end
                
                %             arrowL = xtickpos(end)*(1-rand(1,numel(eleData))*0)*0.8;
                arrowL = rhoVec*flyFactor;
                arrowL(arrowL > xtickpos(end)) = xtickpos(end)*0.98;
                arrowL = 0.95;
                u_bot = cos(deg2rad(dirData)).*cos(deg2rad(eleData)).*arrowL;
                v_bot = -sin(deg2rad(dirData)).*cos(deg2rad(eleData)).*arrowL;
                w_bot = sin(deg2rad(eleData)).*arrowL;
                
                addpath('C:\Users\williamsonw\Documents\MATLAB\mArrow3')
                alpha = 1;
                
                for iterA = 1:numel(u_bot)
                    if colorCode == 1
                        colorMapVar = colorMapMaker(1,135);
                        dirResult = round(loomVSjump(iterA));
                        dirResult(dirResult > 135) = 135;
                        dirResult(dirResult < 1) = 1;
                        colorVar = colorMapVar(dirResult,:);
                    elseif colorCode == 2
                        colorGrid = colorMapMaker2D(91,181);
                        %                     colorGrid = fliplr(colorGrid);
                        gridRefA = round(abs(loomEle(iterA)))+1;
                        gridRefB = round(abs(loomAzi(iterA)))+1;
                        %                     gridRefA = 1;
                        %                     gridRefB = 91;
                        colorVar = squeeze(colorGrid(gridRefA,gridRefB,:));
                    else
                        %                     colorVar = [0.5 0 0];
                        colorVar = [0 0.85 0.25];
                    end
                    if visStyle ~= 2
                        if plotGrpMedians == 0
                            p1 = [0,0,0];
                            p2 = [u_bot(iterA),v_bot(iterA),w_bot(iterA)];
                            h = mArrow3(p1,p2+p1,'color',colorVar,'stemWidth',0.003,'tipWidth',0.015);
                        else
                            arrowL = xtickpos(end)*0;
                            u_bot = cos(deg2rad(dirData)).*cos(deg2rad(eleData)).*arrowL;
                            v_bot = -sin(deg2rad(dirData)).*cos(deg2rad(eleData)).*arrowL;
                            w_bot = sin(deg2rad(eleData)).*arrowL;
                            p1 = [u_bot(iterA),v_bot(iterA),w_bot(iterA)];
                            
                            arrowL = xtickpos(end)*(1.05);
                            u_bot = cos(deg2rad(dirData)).*cos(deg2rad(eleData)).*arrowL;
                            v_bot = -sin(deg2rad(dirData)).*cos(deg2rad(eleData)).*arrowL;
                            w_bot = sin(deg2rad(eleData)).*arrowL;
                            p2 = [u_bot(iterA),v_bot(iterA),w_bot(iterA)];
                            
                            h = mArrow3(p1,p2+p1,'color',colorVar,'stemWidth',0.01,'tipWidth',0.03);
                        end
                        h.FaceLighting = 'gouraud';
                        set(h,'FaceAlpha',alpha,'EdgeAlpha',alpha)
                        
                        h.AmbientStrength = 0.3;
                        h.DiffuseStrength = 0.8;
                        h.SpecularStrength = 0.9;
                        h.SpecularExponent = 25;
                    end
                    if showLoomDir == 1
                        loomL = linspace(0.825,1,3);
                        loomG = linspace(1,0.6,numel(loomL)).^3;
                        for iterLoom = 1:numel(loomL)
                            arrowLa = xtickpos(end)*loomL(iterLoom)*0.98;
                            u_loom = cos(deg2rad(loomAzi)).*cos(deg2rad(loomEle)).*arrowLa;
                            v_loom = -sin(deg2rad(loomAzi)).*cos(deg2rad(loomEle)).*arrowLa;
                            w_loom = sin(deg2rad(loomEle)).*arrowLa;
                            p1 = [u_loom(iterA),v_loom(iterA),w_loom(iterA)];
                            
                            arrowLb = -0.075*0.98;
                            u_loom = cos(deg2rad(loomAzi)).*cos(deg2rad(loomEle)).*arrowLb;
                            v_loom = -sin(deg2rad(loomAzi)).*cos(deg2rad(loomEle)).*arrowLb;
                            w_loom = sin(deg2rad(loomEle)).*arrowLb;
                            p2 = [u_loom(iterA),v_loom(iterA),w_loom(iterA)];
                            if colorCode == 0
                                stimColorVar = [0 0 0]+0.33;
                            else
                                stimColorVar = colorVar;
                            end
                            h = mArrow3(p1,p2+p1,'color',stimColorVar,'stemWidth',0.05,'tipWidth',0.075,'tipAngle',deg2rad(90));
                            h.FaceLighting = 'gouraud';
                            h.AmbientStrength = 0.2;
                            set(h,'FaceAlpha',loomG(iterLoom),'EdgeAlpha',loomG(iterLoom))
                            
                            h.AmbientStrength = 0.3;
                            h.DiffuseStrength = 0.8;
                            h.SpecularStrength = 0.9;
                            h.SpecularExponent = 25;
                        end
                    end
                end
                [xMed,yMed,zMed] = sph2cart(deg2rad(dirData),deg2rad(eleData),rhoVec);
                [azi,ele] = cart2sph(nanmedian(xMed),nanmedian(yMed),nanmedian(zMed));
                if showMedian == 1
                    arrowL = xtickpos(end)*1.033;
                    u_bot = cos(azi).*cos(ele)*arrowL;
                    v_bot = -sin(azi).*cos(ele)*arrowL;
                    w_bot = sin(ele)*arrowL;
                    p1 = [u_bot v_bot w_bot];
                    arrowL = xtickpos(end)*(-0.03);
                    u_bot = cos(azi).*cos(ele)*arrowL;
                    v_bot = -sin(azi).*cos(ele)*arrowL;
                    w_bot = sin(ele)*arrowL;
                    p2 = [u_bot v_bot w_bot];
                    h = mArrow3(p1,p2+p1,'color',[0.4 0.4 1],'stemWidth',0.075,'tipWidth',0);
                    h.FaceLighting = 'gouraud';
                    h.AmbientStrength = 0.2;
                    set(h,'FaceAlpha',alpha,'EdgeAlpha',alpha)
                end
                
                axis equal
                
                ycolor = [0 0 0];
                
                if viewAngle == 1
                    Vi = [  -23.9079    0.0880    0.0180    0.0618
                        0.0156   -0.6384   23.8995   -0.1094
                        -0.0037   -0.9996   -0.0267   43.8322
                        44.2327         0         0    1.0000];
                    lightAzi = 180-20;
                    lightEle = 0;
                elseif viewAngle == 2
                    Vi = [   -0.4363   23.8992   -0.1379    0.0143
                        -1.1019    0.1177   23.8779    0.0991
                        -0.9988   -0.0185   -0.0460   44.4190
                        44.2327         0         0    1.0000];
                    lightAzi = -90-20;
                    lightEle = 0;
                elseif viewAngle == 3
                    Vi = [  -23.9081    0.0815    0.1009   -0.0851
                        -0.0791  -23.9016    0.5694    0.0046
                        -0.0043   -0.0238   -0.9997   44.5684
                        44.2327         0         0    1.0000];
                    lightAzi = 180;
                    lightEle = -20;
                else
                    Vi = [  -23.4524    4.6410   -0.0096    0.0656
                        -3.3233  -16.7588   16.7229   -2.8622
                        -0.1355   -0.6862   -0.7146   44.2198
                        44.2327         0         0    1.0000];
                    lightAzi = 180-10;
                    lightEle = -35;
                end
                camview(Vi)
                set(hax(iterE),'xdir','reverse')
                if iterE == 1
                    delete(findobj('type','Light'))
                end
                hLb = light('style','infinite');% infinite local ambient
                [xL,yL,zL] = sph2cart(deg2rad(lightAzi),deg2rad(lightEle),1);
                lightPos = [-xL,yL,-zL];
                set(hLb,'position',lightPos)
                
                hLb = light('style','local');% infinite local ambient
                [xL,yL,zL] = sph2cart(deg2rad(lightAzi),deg2rad(lightEle),0.98);
                lightPos = [-xL,yL,-zL];
                set(hLb,'position',lightPos)
            elseif plotContour > 0
                contourType = 4;% 2-median and iqr ; 4-2d circle
                ycolor = [0 0 0];
                xAxisName = 'azimuth (degrees)';
                dirData = data(2,:);
                eleData = data(4,:);
                rhoVec = data(5,:);
                
                if contourType == 4
                    normFlag = 1;
                    gridOps = [12 42 162 642 3000];
                    gridChoice = 3;
                    [latGridInDegrees,longGridInDegrees,uniqueTriangles,triangles] = GridSphere(gridOps(gridChoice));% 12 42 162 or 642
                    uniqueTriangles(latGridInDegrees < 0,:,:) = [];
                    longGridInDegrees(latGridInDegrees < 0) = [];
                    latGridInDegrees(latGridInDegrees < 0) = [];
                    tits = get(htit,'string');
                    if ~contains(tits,'degSpace')
                        diffResult = NaN(numel(longGridInDegrees),1);
                        for distA = 1:numel(longGridInDegrees)
                            distLats = latGridInDegrees;
                            distLongs = longGridInDegrees;
                            distLats(distA) = [];
                            distLongs(distA) = [];
                            latA = latGridInDegrees(distA);
                            longA = longGridInDegrees(distA);
                            [x1,y1,z1] = sph2cart(deg2rad(longA),deg2rad(latA),1);
                            distVec = zeros(numel(distLongs),1);
                            for distB = 1:numel(distLongs)
                                [x2,y2,z2] = sph2cart(deg2rad(distLongs(distB)),deg2rad(distLats(distB)),1);
                                distVec(distB) = sqrt((x2-x1)^2+(y2-y1)^2+(z2-z1)^2);
                            end
                            distI = find(distVec == min(distVec),1,'first');
                            [x2,y2,z2] = sph2cart(deg2rad(distLongs(distI)),deg2rad(distLats(distI)),1);
                            a = [x1,y1,z1];
                            b = [x2,y2,z2];
                            diffResult(distA) = atan2(norm(cross(a,b)),dot(a,b));
                        end
                        degSpace = round(rad2deg(median(diffResult)));
                        tits = cat(2,tits,'_degSpace',num2str(degSpace));
                        set(htit,'string',tits)
                    end
                    nnIndices = FindNearestNeighbors(eleData(:),dirData(:),latGridInDegrees,longGridInDegrees);
                    nnIndices = double(nnIndices);
                    histSum = zeros(numel(latGridInDegrees),1);
                    for gridRef = 1:numel(latGridInDegrees)
                        histSum(gridRef) = sum(nnIndices == gridRef);
                    end
                    if normFlag == 1
                        histSum = histSum/range(histSum(:));
                    else
                        histSum = histSum/sum(histSum)*25/gridChoice;
                    end
                    
                    %                     cla
                    F = (1:size(triangles,1))';
                    F = cat(2,F,F+numel(F),F+numel(F)*2);
                    V = cat(1,triangles(:,:,1),triangles(:,:,2),triangles(:,:,3));
                    
                    % make unique triangles
                    for iterUa = 1:size(F,1)
                        for iterUb = 1:3
                            triRef = V(F(iterUa,iterUb),:);
                            triTestA = V(:,1) == triRef(1);
                            triTestB = V(:,2) == triRef(2);
                            triTestC = V(:,3) == triRef(3);
                            triNdx = find(triTestA & triTestB & triTestC,1,'first');
                            F(iterUa,iterUb) = triNdx;
                        end
                    end
                    
                    histRes = 100;
                    histSum = histSum/prctile(histSum,95);
                    histSum = round(histSum*histRes);
                    histSum(histSum > histRes) = histRes;
                    histSaturation = 0;
                    %                 histSaturation = 3;
                    colorVals = colorMapMaker(4,histRes-histSaturation);
                    colorVals = cat(1,colorVals,repmat(colorVals(end,:),histSaturation+1,1));
                    colorVals = colorVals+0.3;
                    colorVals(colorVals > 1) = 1;
                    C = repmat(colorVals(1,:),size(V,1),1);
                    for iterCol = fliplr(1:size(uniqueTriangles,1))
                        for iterTri = 1:3
                            testX = triangles(:,1,iterTri) == uniqueTriangles(iterCol,1,1);
                            testY = triangles(:,2,iterTri) == uniqueTriangles(iterCol,2,1);
                            testZ = triangles(:,3,iterTri) == uniqueTriangles(iterCol,3,1);
                            colNdx = find(testX & testY & testZ);
                            if ~isempty(colNdx)
                                C(colNdx,:) = repmat(colorVals(histSum(iterCol)+1,:),numel(colNdx),1);
                            end
                        end
                    end
                    f2rmv = false(size(F,1),1);
                    for iterFrm = 1:size(F,1)
                        Va = V(F(iterFrm,1),3);
                        Vb = V(F(iterFrm,2),3);
                        Vc = V(F(iterFrm,3),3);
                        if Va < 0 && Vb < 0 && Vc < 0
                            f2rmv(iterFrm) = true;
                        end
                    end
                    F(f2rmv,:) = [];
                    v2keep = unique(F);
                    for iterFk = 1:numel(v2keep)
                        F(F == v2keep(iterFk)) = iterFk;
                    end
                    V = V(v2keep,:);
                    C = C(v2keep,:);
                    [Vazi,Vele] = cart2sph(V(:,1),V(:,2),V(:,3));
                    Vele(Vele < 0) = 0;
                    Vele = (Vele-pi/2)*(-1);
                    [Vx,Vy] = pol2cart(Vazi,(Vele));
                    V = cat(2,Vx,-Vy);
                    ch = filledCircle([0 0],max(Vx)*1.01,1000,colorVals(1,:));
                    set(ch,'edgecolor','none')
                    patch('faces',F(:,:),'vertices',V,'facevertexcdata',C,...
                        'edgecolor','none','FaceColor','interp','facealpha',1,...
                        'facelighting','gouraud');
                    
                    ytickval = [0 90 0];
                    xtickval = [180 90 0];
                    xtickpos = linspace(min(Vx),max(Vx),3);
                    ytickpos = linspace(min(Vy),max(Vy),3);
                    lineC = [0 0 0]+0.3;
                    refXa = [xtickpos(1) xtickpos(end)];
                    refYa = repmat(median(ytickpos),1,2);
                    refXb = repmat(median(xtickpos),1,2);
                    refYb = [ytickpos(1) ytickpos(end)];
                    circT = linspace(-pi,pi,500);
                    circR = zeros(size(circT))+max(Vx);
                    circT = cat(2,circT,NaN,circT);
                    circR = cat(2,circR,NaN,circR/2);
                    [circX,circY] = pol2cart(circT,circR);
                    refX = cat(1,refXa(:),NaN,refXb(:),NaN,circX(:));
                    refY = cat(1,refYa(:),NaN,refYb(:),NaN,circY(:));
                    plot(refX,refY,'color',lineC,'LineWidth',2,'linestyle','-');
                    set(htit,'position',[xtickpos(1) ytickpos(end)+range(ytickpos)*(rows/3)])
                    
                    loomEle = grpTable.elevation(ndxName);
                    if loomEle == 90
                        loomAzi = median(grpTable.azimuth);
                    else
                        loomAzi = grpTable.azimuth(ndxName);
                    end
                    loomEle = (loomEle-90)*(-1);
                    [loomX,loomY] = pol2cart(deg2rad(-loomAzi),deg2rad(loomEle));
                    plot(loomX,loomY,'.','color','k','MarkerSize',60)
                else
                    degSpace = 20;
                    Xedges = (-180:degSpace:180);
                    
                    %                 Xedges = deg2rad(-90:degSpace:90);
                    Yedges = (0:degSpace:90);
                    Yedges = linspace(0,90,numel(Yedges));
                    if plotContour == 1
                        histX = dirData;
                        histY = eleData;
                    else
                        [histX,histY] = pol2cart(deg2rad(instDataJump(1,:)),...
                            deg2rad(instDataJump(2,:)));
                    end
                    histN = histcounts2(histY,histX,(Yedges),(Xedges));
                    histN = (histN)/range(histN(:));
                    
                    xtickpos = linspace(1,size(histN,2),3);
                    ytickpos = linspace(1,size(histN,1),3);
                    xtickval = (xtickpos-min(xtickpos))/range(xtickpos);
                    ytickval = (ytickpos-min(ytickpos))/range(ytickpos);
                    xtickval = xtickval*(range(Xedges))+min(Xedges);
                    ytickval = ytickval*(range(Yedges))+min(Yedges);
                    tits = get(htit,'string');
                    if ~contains(tits,'degSpace')
                        tits = cat(2,tits,'_degSpace',num2str(degSpace));
                        set(htit,'string',tits)
                    end
                    if iterE == 1 || ~singleAx
                        plot([xtickpos(1) xtickpos(end)],ytickpos(1)+[0 0],'color','k')
                        plot(xtickpos(1)+[0 0],[ytickpos(1) ytickpos(end)],'color','k')
                    end
                    set(htit,'position',[xtickpos(1) ytickpos(end)+range(ytickpos)*(rows/3)])
                    loomEle = grpTable.elevation(ndxName);
                    if loomEle == 90
                        loomAzi = median(grpTable.azimuth);
                    else
                        loomAzi = grpTable.azimuth(ndxName);
                    end
                    contourThresh = 0.5;
                    if contourType > 1
                        colorVar = [0 0 0];
                        contourThresh = [0.25 0.5 0.75];
                        %                 contourThresh = linspace(0,1,10);
                        %                 contourThresh = contourThresh(2:end);
                        colorGrid = colorMapMaker(4,numel(contourThresh)+1);
                    elseif colorCode == 1
                        colorGrid = colorMapMaker2D(91,181);
                        gridRefA = round(abs(loomEle))+1;
                        gridRefB = round(abs(loomAzi))+1;
                        colorVar = squeeze(colorGrid(gridRefA,gridRefB,:));
                    else
                        colorGrid = colorMapMaker(0,xCt);
                        colorVar = squeeze(colorGrid(iterE,:));
                    end
                    
                    if contourType == 3
                        image(histN,'cdatamapping','scaled')
                        set(gcf,'colormap',gray)
                    end
                    
                    loomX = loomAzi;
                    loomY = loomEle;
                    loomX = (loomX-min(Xedges(:)))/range(Xedges(:));
                    loomY = (loomY-min(Yedges(:)))/range(Yedges(:));
                    loomX = loomX*(range(xtickpos))+min(xtickpos);
                    loomY = loomY*(range(ytickpos))+min(ytickpos);
                    
                    plot(loomX,loomY,'.','color',colorVar,'MarkerSize',8)
                    
                    histX = (histX-min(Xedges(:)))/range(Xedges(:));
                    histY = (histY-min(Yedges(:)))/range(Yedges(:));
                    histX = histX*numel(Xedges);
                    histY = histY*numel(Yedges);
                    if showDotsOrLines == 1
                        plot(histX,histY,'.','color','k')
                    end
                    
                    
                    
                    for iterCont = 1:numel(contourThresh)
                        datac = contourc(histN,[contourThresh(iterCont) contourThresh(iterCont)]);
                        while ~isempty(datac)
                            ptCt = datac(2,1);
                            if ptCt > 4
                                cX = datac(1,2:ptCt+1);
                                cY = datac(2,2:ptCt+1);
                                if cX(1) ~= cX(end) || cY(1) ~= cY(end)
                                    if contourType == 1
                                        cX = cat(2,cX,cX(1));
                                        cY = cat(2,cY,cY(1));
                                    end
                                end
                                if contourType == 2
                                    colorVar = squeeze(colorGrid(iterCont,:));
                                end
                                h4leg(iterE) = plot(cX,cY,'LineWidth',2,'Color',colorVar);
                                %                             h4leg(iterE) = fill(cX,cY,colorVar,'edgecolor','none');
                            end
                            datac(:,1:ptCt+1) = [];
                        end
                    end
                end
                %%
            else
                plot([xtickpos(1) xtickpos(end)],zeros(1,2),'color',lineCb,'linewidth',2)
                plot(repmat(median(xtickpos),1,2),[ytickpos(1) ytickpos(end)],'color',lineCb,'linewidth',2)
                plotMidLines = 0;
                if plotMidLines == 1
                    [midX,midY] = pol2cart(pi/4,ytickpos(end));
                    if contains(graphName,'elevation')
                        midY = cat(1,midY,0,midY);
                        midX = cat(1,-midX,0,midX);
                    else
                        midY = cat(1,midY,-midY,NaN,-midY,midY);
                        midX = cat(1,-midX,midX,NaN,-midX,midX);
                    end
                    plot(midX,midY,'color',lineCb,'linewidth',2)
                    plot(-midX,midY,'color',lineCb,'linewidth',2)
                end
                if contains(graphName,'elevation')
                    circT = linspace(0,pi,500);
                else
                    circT = linspace(-pi,pi,500);
                end
                if plotMidLines == 1
                    circT = cat(2,circT,circT);
                    circR = [zeros(size(circT))+1 zeros(size(circT))+0.5];
                else
                    circR = zeros(size(circT))+1;
                end
                [circX,circY] = pol2cart(circT,circR);
                plot(circX,circY,'color',lineCb,'LineWidth',2,'linestyle','-');
                if graphOptions.sliceOption > 1 && ~contains(graphName,'elevation')
                    sliceOption = graphOptions.sliceOption;
                    aziGrpCt = sliceOption;% 5 or 7 is recommended ... 13 works too
                    elevationVec = grpTable.elevation(ndxName);
                    if nanmedian(elevationVec) > 60 && ~isempty(strfind(graphOptions.sheetName,'fieldMap'))
                        aziGrpCt = 3;% 5 or 7 is recommended ... 13 works too
                        aziBreaks = linspace(0,180,aziGrpCt*2-1);
                        aziNames = aziBreaks(1:2:aziGrpCt*2-1);
                        aziBreaks = [aziBreaks(1) aziBreaks(1,2:2:aziGrpCt*2-1) aziBreaks(end)];
                    elseif nanmedian(elevationVec) > 30 && ~isempty(strfind(graphOptions.sheetName,'fieldMap'))
                        aziGrpCt = 5;% 5 or 7 is recommended ... 13 works too
                        aziBreaks = linspace(0,180,aziGrpCt*2-1);
                        aziNames = aziBreaks(1:2:aziGrpCt*2-1);
                        aziBreaks = [aziBreaks(1) aziBreaks(1,2:2:aziGrpCt*2-1) aziBreaks(end)];
                    elseif ~isempty(strfind(graphOptions.sheetName,'fieldMap'))
                        aziGrpCt = 7;% 5 or 7 is recommended ... 13 works too
                        aziBreaks = linspace(0,180,aziGrpCt*2-1);
                        aziNames = aziBreaks(1:2:aziGrpCt*2-1);
                        aziBreaks = [aziBreaks(1) aziBreaks(1,2:2:aziGrpCt*2-1) aziBreaks(end)];
                    else
                        aziBreaks = linspace(0,180,aziGrpCt*2-1);
                        aziNames = aziBreaks(1:2:aziGrpCt*2-1);
                        aziBreaks = [aziBreaks(1) aziBreaks(1,2:2:aziGrpCt*2-1) aziBreaks(end)];
                    end
                    brkRef = find(aziNames == grpTable.azimuth(ndxName));
                    stimT = aziBreaks(brkRef:brkRef+1)*(pi/180);
                    stimT = linspace(stimT(1),stimT(2),100);
                    [stimX,stimY] = pol2cart(stimT,zeros(size(stimT))+max(ytickpos)*1);
                    plot(stimX,stimY,'color',[0 0 0]+0.5,'linewidth',5);
                end
                
                dirData = data(1,:);
                eleData = abs(data(3,:));
                if strcmp(grpTable.stimType{ndxName},'Photoactivation')
                    %             dirData = abs(dirData);
                end
                rhoVec = data(5,:)/1.5;
                if rhoStyle == 2
                    rhoVec = data(4,:);
                    rhoVec = rhoVec/90;
                elseif rhoStyle == 0
                    rhoVec = rhoVec*0+1;
                end
                if contains(graphName,'elevation')
                    dirData = abs(centerDegs(dirData+90))-90;
                end
                
                [dataxTot,datayTot,datazTot] = sph2cart(deg2rad(dirData),deg2rad(eleData),rhoVec);
                %                     [dataxTot,datayTot] = pol2cart(dirData*(pi/180),rhoVec);
                for iterJ = 1:2
                    if iterJ == 1
                        datax = dataxTot(grpTable.jumpTest{ndxName});
                        if contains(graphName,'elevation')
                            datay = datazTot(grpTable.jumpTest{ndxName});
                        else
                            datay = datayTot(grpTable.jumpTest{ndxName});
                        end
                        colorRef = 3;
                    else
                        if strcmp(subset2plot,'jumping')
                            continue
                        end
                        datax = dataxTot(~grpTable.jumpTest{ndxName});
                        if contains(graphName,'elevation')
                            datay = datazTot(~grpTable.jumpTest{ndxName});
                        else
                            datay = datayTot(~grpTable.jumpTest{ndxName});
                        end
                        colorRef = 4;
                    end
                    if numel(datax > 5)
                        if plotCircArrow == 1
                            avgx = median(datax(:));
                            avgy = median(datay(:));
                            [avgT,avgR] = cart2pol(avgx,avgy);
                            if avgR >= 0.3
                                avgT = cat(2,avgT,avgT+pi/45*[1 -1],avgT);
                                avgR = max(ytickpos);
                                avgR = cat(2,avgR,[avgR avgR]*(0.7),avgR);
                                [avgx,avgy] = pol2cart(avgT,avgR);
                                plot(avgx,avgy,'color',colorOps{colorRef},'linewidth',2);
                            end
                        end
                        plotResample = randperm(numel(datay));
                        if numel(plotResample) > maxScatterCt
                            plotResample = plotResample(1:maxScatterCt);
                        end
                        datax = datax(:);
                        datay = datay(:);
                        plotResample = plotResample(:);
                        outputData{iterE,groupChoice} = [datax(plotResample) datay(plotResample)];
                        if showDotsOrLines == 1
                            plot(datax(plotResample),datay(plotResample),...
                                '.','color',colorOps{colorRef},'markersize',6)
                        elseif showDotsOrLines == 2
                            for iterP = 1:numel(plotResample)
                                plot([0 datax(plotResample(iterP))],[0 datay(plotResample(iterP))],...
                                    'color',colorOps{colorRef},'linewidth',1)
                            end
                        end
                        if plotCircHist == 1
                            histData = cart2pol(datax,datay);
                            histData = rad2deg(histData);
                            dataCt = numel(histData);
                            if contains(graphName,'elevation')
                                aziGrpCt = 13;% 9 or 13 or 25 or 31 or 60
                            else
                                aziGrpCt = 18;% 9 or 13 or 18 or 25 or 31
                            end
                            aziBreaks = linspace(-180,180,aziGrpCt*2-1);
                            aziBreaks = [aziBreaks(1) aziBreaks(1,2:2:aziGrpCt*2-1) aziBreaks(end)];
                            
                            histVec = zeros(numel(aziBreaks)-1,1);
                            for iterP = 1:numel(aziBreaks)-1
                                histBool = histData > aziBreaks(iterP) & histData < aziBreaks(iterP+1);
                                if iterP == 1
                                    histBoolB = histData > aziBreaks(end-1) & histData < aziBreaks(end);
                                    histBool = histBool | histBoolB;
                                end
                                histVec(iterP) = sum(histBool)/dataCt;
                            end
                            histBorderVal = 3;
                            histVec = histVec*histBorderVal;
                            histVec = cat(2,histVec(:),histVec(:))';
                            aziBreaks = cat(2,aziBreaks(:),aziBreaks(:))';
                            aziBreaks = circshift(aziBreaks(:),[1 0]);
                            if iterJ == 1
                                aziBreaks = aziBreaks+2;
                                histVec = histVec*0.92;
                            else
                                aziBreaks = aziBreaks-2;
                                histVec = histVec*0.88;
                            end
                            histVec = histVec*max(ytickpos);
                            histVec(histVec > max(ytickpos)) = max(ytickpos);
                            [plotX,plotY] = pol2cart(deg2rad(aziBreaks(3:end)),histVec(:));
                            plotX = cat(1,plotX(:),plotX(1));
                            plotY = cat(1,plotY(:),plotY(1));
                            plot(plotX,plotY,'color',colorOps{colorRef},'linewidth',2)
                        end
                        if contains(graphName,'elevation')
                            medData = cart2pol(datax,datay);
                            q1 = prctile(medData,25); q2 = prctile(medData,50);
                            q3 = prctile(medData,75); n = numel(medData);
                            err = 1.57*(q3-q1)/sqrt(n);
                            errR = max(ytickpos);
                            confT = linspace(q2-err,q2+err,100);
                            [errX,errY] = pol2cart([confT NaN q2 q2],[zeros(size(confT))+errR*1.025 NaN errR*1.0 errR*1.05]);
                            plot(errX,errY,'k','linewidth',2)
                        else
                            medVals = zeros(2,2);
                            for iterErr = 1:2
                                if iterErr == 1
                                    medData = datax;
                                else
                                    medData = datay;
                                end
                                q1 = prctile(medData,25); q2 = prctile(medData,50);
                                q3 = prctile(medData,75); n = numel(medData);
                                err = 1.57*(q3-q1)/sqrt(n);
                                medVals(iterErr,1) = q2;
                                medVals(iterErr,2) = err;
                            end
                            if circConfStyle == 1
                                plot([medVals(1,1)-medVals(1,2) medVals(1,1)+medVals(1,2)],...
                                    [medVals(2,1) medVals(2,1)],'linewidth',1,'color','k')
                                plot([medVals(1,1) medVals(1,1)],...
                                    [medVals(2,1)-medVals(2,2) medVals(2,1)+medVals(2,2)],...
                                    'linewidth',1,'color','k')
                            elseif circConfStyle == 2
                                xCenter = medVals(1,1);
                                yCenter = medVals(2,1);
                                xRadius = medVals(1,2);
                                yRadius = medVals(2,2);
                                theta = 0 : 0.01 : 2*pi;
                                x = xRadius * cos(theta) + xCenter;
                                y = yRadius * sin(theta) + yCenter;
                                fill(x,y,'k','LineWidth',2);
                            end
                        end
                        %                 if isempty(strfind(graphName,'Meatball'))
                        %                     plot([0 avgx],[0 avgy],'color','k','LineWidth',5);
                        %                     plot([0 avgx],[0 avgy],'color',colorOps{2},'LineWidth',3);
                        %                 end
                    end
                end
                
                ycolor = fontC;
                if graphOptions.sliceOption == 1
                    [stimx,stimy] = pol2cart(grpTable.azimuth(ndxName)*(pi/180),max(ytickpos));
                    if ~strcmp(ndxName,'noStim') && ~strcmp(grpTable.stimType{ndxName},'Photoactivation')
                        stimX = [0 stimx];
                        stimY = [0 stimy];
                    else
                        stimX = [0 0];
                        stimY = [NaN NaN];
                    end
                    plot(stimX,stimY,'color',colorOps{1},'LineWidth',3);
                end
            end
        elseif contains(graphName,'departureScatter')
            data2remove = data(3,:) < rhoThresh(1);
            data2remove = (data(3,:) > rhoThresh(2)) | data2remove;
            if showRemoval == 1
                disp([num2str(sum(data2remove)) ' removed for rho outside bounds : ' ndxName])
            end
            grpTable.jumpTest{ndxName}(data2remove) = [];
            grpTable.zeroFly_StimAtStimStart{ndxName}(data2remove) = [];
            data(:,data2remove) = [];
            videoList(data2remove) = [];
            theta = data(2,:);
            alpha = data(1,:);
            if numel(theta) > maxScatterCt
                randVec = randperm(maxScatterCt);
                theta = theta(randVec(1:maxScatterCt));
                alpha = alpha(randVec(1:maxScatterCt));
            end
            hScat(iterE) = plot(theta,alpha,'.','color',colorOps{3},'markersize',8);
            ycolor = fontC;
            thetaCell{iterE} = theta;
            alphaCell{iterE} = alpha;
        end
        
        if iterE == 1 || ~singleAx || (contains(graphName,'3D') && plotContour == 0)
            if ~contains(graphName,'3D') || ~singleAx
                haxPos = get(hax(iterE),'position');
                haxPos = [haxPos(1)-haxPos(3)*growShiftAx(1)/2,haxPos(2)-haxPos(4)*growShiftAx(2)/2,...
                    haxPos(3)*(1+growShiftAx(1)),haxPos(4)*(1+growShiftAx(2))]+[growShiftAx(3:4) 0 0];
                haxPos = [haxPos(1:2)+[startPosX(iterE) startPosY(iterE)] axWH.*[0.85 0.75]];
            end
            set(hax(iterE),'xticklabel',[],'position',haxPos,'color','none','box','off',...
                'Xlim',[xtickpos(1)-range(xtickpos)*0.1 xtickpos(end)+range(xtickpos)*0.1],...
                'YLim',[ytickpos(1)-range(ytickpos)*0.1 ytickpos(end)+range(ytickpos)*0.1],...
                'tickdir','out','xtick',[],'yticklabel',[],'ytick',ytickpos,'ycolor','none','xcolor','none')
            if contains(graphName,'escape') && ~(contains(graphName,'3D') && plotContour == 1)
                aziVals = linspace(0,180,5);
                aziRots = aziVals;
                if contains(graphName,'3D') && plotContour == 0
                    aziRots = 0*aziRots+90;
                    %                 hax(iterE) = axes('color','none');
                end
                rhoVals = zeros(size(aziVals))+max(xtickpos);
                [xpos,ypos] = pol2cart(deg2rad(aziVals),rhoVals*1.2);
                hTxtLabel = zeros(1,numel(ypos));
                for iterL = 1:numel(ypos)
                    hTxtLabel(iterL) = text(xpos(iterL),ypos(iterL),num2str(aziVals(iterL)),'rotation',aziRots(iterL)-90,...
                        'color',ycolor,'horizontalalignment','center','fontsize',fontSb);
                end
                if contains(graphName,'3D') && plotContour == 0
                    delete(hTxtLabel)
                end
            else
                %%
                for iterL = 1:numel(ytickval)
                    text(xtickpos(1)-range(xtickpos)*0.05,ytickpos(iterL),num2str(ytickval(iterL)),'rotation',0,...
                        'color',ycolor,'horizontalalignment','right','fontsize',fontSb);
                end
            end
            xlabelPos(1:2) = [mean(xtickpos) ytickpos(1)-range(ytickpos)*0.2];
            if ~contains(graphName,'departureScatter')
                htxtA = text(xtickpos(1),xlabelPos(2),strtrim(grpTable.plotID{ndxName}),...
                    'horizontalalignment','left','rotation',0,...
                    'color',fontC,'interpreter','none','fontsize',fontSc);
                if contains(graphName,'3D') && plotContour == 0
                    plotCt = numel(dirData);
                    jumpCt = plotCt;
                else
                    jumpCt = sum(grpTable.jumpTest{ndxName});
                    %                 plotCt = grpTable.plotCount(ndxName);
                    plotCt = sum(~isnan(data(1,:)));
                end
                if strcmp(subset2plot,'jumping')
                    dataCountTotal = ['n = ' num2str(jumpCt)];
                elseif strcmp(subset2plot,'nojump')
                    dataCountTotal = ['n = ' num2str(plotCt)];
                else
                    dataCountTotal = ['n = ' num2str(plotCt)];
                end
                xlabelPos(1:2) = [mean(xtickpos) ytickpos(1)-range(ytickpos)*0.25];
                htxtB = text(xtickpos(1),xlabelPos(2),dataCountTotal,...
                    'horizontalalignment','left','rotation',0,'VerticalAlignment','top',...
                    'color',fontC,'interpreter','none','fontsize',fontSb,'parent',hax(iterE));
                
            end
            if contains(graphName,'3D') && plotContour == 0
                swellFac = 0.2;
                haxW = haxPos(3);
                haxH = haxPos(4);
                haxPos(1) = haxPos(1)-haxW*swellFac;
                haxPos(2) = haxPos(2)-haxH*swellFac;
                haxPos(3) = haxPos(3)+haxW*swellFac*2;
                haxPos(4) = haxPos(4)+haxH*swellFac*2;
                set(hax(iterE),'position',haxPos,'color','none','box','off')
                aziRots = 0*aziRots+90;
                if viewAngle == 1
                    labelAziShift = -20;
                    labelEleShift = 10;
                elseif viewAngle == 2
                    labelAziShift = 60;
                    labelEleShift = 0;
                elseif viewAngle == 3
                    labelAziShift = 90;
                    labelEleShift = 0;
                else
                    labelAziShift = 0;
                    labelEleShift = 0;
                end
                [tX,tY,tZ] = sph2cart(deg2rad(-180-labelAziShift),deg2rad(45-labelEleShift),xtickpos(end)*2);
                [tXA,tYA,tZA] = sph2cart(deg2rad(90-labelAziShift),deg2rad(0-labelEleShift),xtickpos(end)*1.3);
                [tXB,tYB,tZB] = sph2cart(deg2rad(90-labelAziShift),deg2rad(0-labelEleShift),xtickpos(end)*1.45);
                [tXC,tYC,tZC] = sph2cart(deg2rad(90-labelAziShift),deg2rad(0-labelEleShift),xtickpos(end)*1.65);
                set(htit,'position',[tX,tY,tZ])
                set(htxtA,'position',[tXA,tYA,tZA])
                set(htxtB,'position',[tXB,tYB,tZB])
                medianStr = ['azimuth: ' num2str(rad2deg(azi),3) ' - elevation: ' num2str(rad2deg(ele),3)];
                htxtC = text(xtickpos(1),xlabelPos(2),medianStr,...
                    'horizontalalignment','left','rotation',0,'VerticalAlignment','top',...
                    'color',fontC,'interpreter','none','fontsize',fontSb,'parent',hax(iterE));
                set(htxtC,'position',[tXC,tYC,tZC])
            end
        end
        outputVideoNames{iterE,groupChoice} = videoList;
    end
    if exist('histBorderVal','var')
        text(0,ytickpos(1)-range(ytickpos)*0.2,...
            ['outer ring represents ' num2str(1/histBorderVal*100,2) '% of the population'],...
            'fontsize',12)
    end
    scatterFit = 3;
    %%
    if contains(graphName,'departureScatter')
        cla
        plotMedian = 1;
        theta = cat(2,thetaCell{:});
        alpha = cat(2,alphaCell{:});
        [alphaX,alphaY] = pol2cart(deg2rad(alpha),ones(size(alpha)));
        if scatterFit == 1
            fitLeg = 3;
        else
            fitLeg = 9;%9
        end
        degInit = 0;
        degEnd = 180;
        degCt = degEnd-degInit+1;
        fitPts = zeros(degCt,3);
        fitX = zeros(degCt,1);
        fitZ = zeros(degCt,1);
        fitCts = zeros(degCt,1);
        fitConf = zeros(degCt,1);
        for iterD = 1:degCt
            degCenter = degInit+iterD-1;
            binStart = degCenter-fitLeg;
            binStop = degCenter+fitLeg;
            if binStart < degInit, binStart = degInit; end
            if binStop > degEnd, binStop = degEnd; end
            thetaNdcs = theta >= binStart & theta <= binStop;
            subAlphaX = alphaX(thetaNdcs);
            subAlphaY = alphaY(thetaNdcs);
            
            q2X = mean(subAlphaX);
            q1X = prctile(subAlphaX,25);
            q3X = prctile(subAlphaX,75);
            q2Y = mean(subAlphaY);
            q1Y = prctile(subAlphaY,25);
            q3Y = prctile(subAlphaY,75);
            
            [q2,r2] = cart2pol(q2X,q2Y);
            q1 = cart2pol(q1X,q1Y);
            q3 = cart2pol(q3X,q3Y);
            fitPts(iterD,:) = ([q1 q2 q3]+2*pi);
            fitX(iterD) = deg2rad(degCenter);
            fitZ(iterD) = deg2rad(median(theta(thetaNdcs)));
            fitCts(iterD) = sum(thetaNdcs);
            fitConf(iterD) = r2;
        end
        fitCtMin = 5;
        fitConfMin = 0.3;%0.3
        fitPts2remove = fitCts < fitCtMin;
        fitPts2remove = fitConf < fitConfMin | fitPts2remove;
        fitPts2remove = isnan(fitPts(:,2)) | fitPts2remove;
        origFitX = fitX;
        fitX(fitPts2remove) = [];
        fitPts(fitPts2remove,:) = [];
        fitZ(fitPts2remove) = [];
        
        eqChoice = 4;% 2-m has a friend ; 3-m is a constant ; 4-m is linear ; 5-use complete model
        if scatterFit == 1 || scatterFit == 3
            for iterF = 2%1:3
                fitY = fitPts(:,iterF);
                fitX = fitX(:)';
                fitY = fitY(:)';
                a = -0.121*deg2rad(grpTable.elevation(ndxName))+0.13;
                b = 0.44;
                x = [a b];
                switch eqChoice
                    case 1
                        trigEqFit = @(x) atan2(sin(fitX-pi),cos(fitX-pi)+1./(1-(x(1)*(fitX).^2+fitX*x(2)+x(3)))-1)+2*pi-fitY;
                        lb = [-1 -1 -1];
                        ub = [1 1 1];
                        x0 = [-0.0828 0.166 0.402];
                        x = lsqnonlin(trigEqFit,x0,lb,ub);
                    case 2
                        trigEqFit = @(x) atan2(sin(fitX-pi),cos(fitX-pi)+x(1)/x(2))+2*pi-fitY;
                        lb = [0 0.5001];
                        ub = [0.4999 1];
                        x0 = [a b];
                        x = lsqnonlin(trigEqFit,x0,lb,ub);
                    case 3
                        trialCt = 1000;
                        rsquareTry = zeros(trialCt,1);
                        x2try = linspace(0,0.9,trialCt);
                        for it = 1:trialCt
                            rsqY = atan2(sin(fitX-pi),cos(fitX-pi)+1./(1-x2try(it))-1)+2*pi;
                            stats = regstats(fitY,rsqY,'linear','rsquare');
                            rsquareTry(it) = stats.rsquare;
                        end
                        [rsquare,maxRef] = max(rsquareTry);
                        x = x2try(maxRef);
                        rsqY = atan2(sin(fitX-pi),cos(fitX-pi)+1./(1-x)-1)+2*pi;
                        plot(rad2deg(fitX),rad2deg(fitY+0.1),'g')
                        plot(rad2deg(fitX),rad2deg(rsqY+0.1),'b')
                        %                     x = 0.49;
                        %                     return
                    case 4
                        %                     trigEqFit = @(x) atan2(-(1-(x(1)*fitX+x(2))).*sin(fitX),...
                        %                         -(1-(x(1)*fitX+x(2))).*cos(fitX)+(x(1)*fitX+x(2)))+2*pi-fitY;
                        trigEqFit = @(x) atan2(sin(fitX-pi),cos(fitX-pi)+1./(1-(x(1)*(fitX)+x(2)))-1)+2*pi-fitY;
                        lb = [0 0];
                        ub = [1 1];
                        x0 = [a b];
                        x = lsqnonlin(trigEqFit,x0,lb,ub);
                        varMfun{groupChoice} = ['@(x) (' num2str(x(1),3) '*x+' num2str(x(2),3) ')'];
                end
                
                fitXavg4varM{groupChoice} = fitX;
                fitYavg4varM{groupChoice} = fitY;
                fitX4varM{groupChoice} = theta;
                fitY4varM{groupChoice} = alpha;
                switch eqChoice
                    case 1
                        a = x(1);
                        b = x(2);
                        c = x(3);
                        varMfun{groupChoice} = ['@(x) (' num2str(x(1),3) '*x.^2+' num2str(x(2),3) '*x+' num2str(x(3),3) ')'];
                        trigEq = @(x) atan2(sin(x-pi),cos(x-pi)+1./(1-(a*x.^2+x*b+c))-1)+2*pi;
                    case 2
                        a = x(1);
                        b = x(2);
                        trigEq = @(x) atan2(sin(x-pi),cos(x-pi)+a/b)+2*pi;
                    case 3
                        a = x(1);
                        b = NaN;
                        trigEq = @(x) atan2(sin(x-pi),cos(x-pi)+1./(1-a)-1)+2*pi;
                    case 4
                        trigEq = @(x) atan2(sin(x-pi),cos(x-pi)+1./(1-(a*(x)+b))-1)+2*pi;
                    case 5
                        trigEq = @(x) atan2(sin(x-pi),cos(x-pi)+1./(1-(a*(x)+b))-1)+2*pi;
                        a = x(1);
                        b = x(2);
                        varMfun{groupChoice} = ['@(x) (' num2str(x(1),3) '*x+' num2str(x(2),3) ')'];
                end
                if scatterFit == 2 || scatterFit == 3
                    if plotMedian == 1
                        %                     fitPts(1:fitLeg,iterF) = NaN;
                        %                     fitPts(end-fitLeg:end,iterF) = NaN;
                        plot(rad2deg(fitX),rad2deg(fitY),'color',[0 0 0.5],'linewidth',3)
                    end
                end
                if iterF == 2
                    solvedY = rad2deg(trigEq(origFitX));
                    solvedX = rad2deg(origFitX);
                    plot(solvedX,solvedY,'color',[0.5 0 0],'linewidth',3)
                    rsqY = rad2deg(trigEq(fitX));
                    stats = regstats(rad2deg(fitY),rsqY,'linear','rsquare');
                    rsquare = stats.rsquare;
                end
            end
        end
        plot([0 180],[180 360],'color',fontC,'linewidth',1,'linestyle','-')
        plot([0 180],[0 180],'color',fontC,'linewidth',1,'linestyle','-')
        plot([0 180],[360 360+180],'color',fontC,'linewidth',1,'linestyle','-')
        plot([0 180],[180 180],'color',fontC,'linewidth',2,'linestyle','--')
        plot([0 180],[360 360],'color',fontC,'linewidth',2,'linestyle','--')
        if showDotsOrLines == 0
            set(hScat,'color','none')
        end
        dataCountTotal = ['n = ' num2str(numel(theta)) '     ' varMfun{groupChoice},...
            '  where a = ' num2str(a,3) ' and b = ' num2str(b,3) '     ',...
            'r-square: ' num2str(rsquare,3)];
        ylabelPos = [xtickpos(1)-range(xtickpos)*0.2 mean(ytickpos) 1];
        htxtA = text(ylabelPos(1),ylabelPos(2),'Departure Azimuth (degrees)',...
            'horizontalalignment','center','rotation',90,...
            'color',fontC,'interpreter','none','fontsize',fontSa);
        xlabelPos(1:2) = [mean(xtickpos) ytickpos(1)-range(ytickpos)*0.25];
        htxtB = text(xtickpos(1),xlabelPos(2),dataCountTotal,...
            'horizontalalignment','left','rotation',0,'VerticalAlignment','top',...
            'color',fontC,'interpreter','none','fontsize',fontSb,'parent',hax(iterE));
    elseif singleAx == 1
        set(htxtB,'string',['n = ' num2str(dataCtTally)])
        set(htxtA,'string','group overlay')
        if max(h4leg) > 0
            hLeg = legend(h4leg,grpIDlist,'interpreter','none');
            legPos = get(hLeg,'pos');
            legPos(2) = legPos(2)-0.1;
            %         legPos(1) = legPos(1)*1.3;
            set(hLeg,'pos',legPos)
        end
    end
    
    if ~contains(graphName,'escape') || (contains(graphName,'3D') && plotContour == 1)
        htxtA.Position(2) = htxtA.Position(2)-range(ytickpos)*0.25;
        htxtB.Position(2) = htxtB.Position(2)-range(ytickpos)*0.25;
        set(get(hax(iterE),'xlabel'),'units','normalized')
        xlabelPos = get(get(hax(iterE),'xlabel'),'position');
        xlabelPos(1:2) = [mean(xtickpos) ytickpos(1)-range(ytickpos)*0.2];
        for iterL = 1:numel(xtickval)
            if isnan(xtickval(iterL)), continue, end
            text(xtickpos(iterL),xlabelPos(2),num2str(xtickval(iterL)),'rotation',0,...
                'color',fontC,'horizontalalignment','center','fontsize',fontSb);
        end
        xlabelPos = get(get(hax(iterE),'xlabel'),'position');
        xlabelPos(1:2) = [mean(xtickpos) ytickpos(1)-range(ytickpos)*0.3];
        text(xlabelPos(1),xlabelPos(2),xAxisName,...
            'horizontalalignment','center','rotation',0,...
            'color',fontC,'interpreter','none','fontsize',fontSb);
    end
    
    if contains(graphName,'3D') && numel(findobj('type','axes','parent',gcf)) == 1 && plotContour == 0
        figPos = [3085 100 500 500];
        set(gcf,'pos',figPos)
        axPos = [-0.35 -0.35 1.7 1.7];
        set(gca,'pos',axPos)
        viewStr = {'side','front','top','mid'};
        pdfName = cat(2,pdfName,'_',strtrim(grpTable.plotID{ndxName}),'_',viewStr{viewAngle});
        textObjects = findobj('Type','Text');
        for it = 1:numel(textObjects)
            delete(textObjects(it))
        end
    end
    
    if plotContour == 1 && contourType == 4 && contains(graphName,'3D') && xCt == 1
        figPos = [3085 100 500 500];
        set(gcf,'pos',figPos)
        axPos = [0 0 1 1];
        set(gca,'pos',axPos)
        pdfName = cat(2,pdfName,'_',strtrim(grpTable.plotID{ndxName}),'_circleHist');
        textObjects = findobj('Type','Text');
        for it = 1:numel(textObjects)
            delete(textObjects(it))
        end
        if saveFig > 0
            saveFig = 3;
        end
    end
    
    if (contains(graphName,'3D') || contains(graphName,'loomApproach')) && plotContour == 0
        if saveFig > 0
            saveFig = 3;
        end
    end
    exportVisualizationFigure(pdfName,saveFig)
end
if exportVariables == 1
    save(fullfile(fileparts(graphOptions.excelPath),[pdfName '.mat']),...
        'outputData','outputVideoNames','outputGrpNames','outputPlotNames')
end

end