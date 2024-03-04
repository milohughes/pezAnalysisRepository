clear all
% close all
clc
pDate = datestr(date,'yyyymmdd');
% pDate = num2str(str2double(pDate)-1);%yesterday
% pDate = '20140220';%any day
pPez = 'pez3003';

runType = 2;%set '1' for 'generic' and '2' for 'run'

fileDir = '\\tier2\card\Data_pez3000';
if runType == 1
else
    runFolder = dir(fullfile(fileDir,pDate,['*_' pPez '_*']));
    runFolder = {runFolder.name};
    runCt = numel(runFolder);
end
%

runSelect = 'all';%num or 'all'
vidSelect = 'all';%num or 'all'

dataType = 3;
% 1 - visual stimulus from video statistics
% 2 - photoactivation from video statistics
% 3 - visual stimulus from auto analysis

fileDir = '\\tier2\card\Data_pez3000';
if runType == 1
    pType = 'generic';
    runFolder = {[pType '_' pPez '_' pDate]};
    runSelect = 1;
else
    runFolder = dir(fullfile(fileDir,pDate,['*_' pPez '_*']));
    runFolder = {runFolder.name};
    runCt = numel(runFolder);
    if ischar(runSelect)
        vidSelect = 'all';
        runSelect = (1:runCt);
    elseif numel(runSelect) > 1
        vidSelect = 'all';
    end
end
runFolder = runFolder(runSelect);
runCt = numel(runFolder);
%
dataTally = cell(runCt,1);
for iterR = 1:runCt
    switch dataType
        case 1
            fileString = [runFolder{iterR} '_videoStatistics.mat'];
            filePath = fullfile(fileDir,pDate,runFolder{iterR},fileString);
            if ~exist(filePath,'file')
                disp('file does not exist')
                continue
            end
            load(filePath)
            vidCt = size(vidStats,1);
            photoData = vidStats.visual_stimulus_info;
            try
                photoData = cellfun(@(x) x.nidaq_data,photoData,'uniformoutput',false);
            catch
                continue
            end
        case 2
            fileString = [runFolder{iterR} '_videoStatistics.mat'];
            filePath = fullfile(fileDir,pDate,runFolder{iterR},fileString);
            if ~exist(filePath,'file')
                disp('file does not exist')
                continue
            end
            load(filePath)
            vidCt = size(vidStats,1);
            photoData = vidStats.photoactivation_info;
            photoData = cellfun(@(x) x.nidaq_data,photoData,'uniformoutput',false);
        case 3
            fileString = ['inspectionResults' filesep runFolder{iterR} '_autoAnalysisResults.mat'];
            filePath = fullfile(fileDir,pDate,runFolder{iterR},fileString);
            if ~exist(filePath,'file')
                disp('file does not exist')
                filePath
                continue
            end
%             runFolder{iterR}
            load(filePath)
            photoData = autoResults.diode_data;
            photoData = cellfun(@(x) fieldnames(x),photoData,'uniformoutput',false);
            emptyTest = cellfun(@(x) isempty(x), photoData,'uniformoutput',false);
            photoTest = cellfun(@(x) max(strcmp(x,'nidaq_data')),photoData,'uniformoutput',false);
            photoTest(cell2mat(emptyTest)) = {false};
            photoTest = cell2mat(photoTest);
            photoData = autoResults.diode_data(photoTest);
            photoData = cellfun(@(x) x.nidaq_data,photoData,'uniformoutput',false);
            photoBool = strcmp(autoResults.diode_decision(photoTest),'good photodiode');
            photoData = photoData(~photoBool);
            vidCt = numel(photoData);
%             try
%             frmCount = numel(photoData{1});
%             if frmCount == 7000
%                 filePath
%             end
%             catch
%             end
    end
    if ~ischar(vidSelect)
        vidCt = 1;
        photoData = photoData{vidSelect};
    else
        dataTally{iterR} = photoData;
    end
    
end
dataTest = cell2mat(cellfun(@(x) isempty(x),dataTally,'uniformoutput',false));
dataTally = dataTally(~dataTest);
if min(dataTest)
    figPos = [87,678,1771,420];
    if iscell(photoData)
        photoData = photoData{1};
    end
    plot(photoData)
    set(gcf,'position',figPos)
else
    photoData = cat(1,dataTally{:});
    maxL = max(cellfun(@(x) numel(x),photoData));
    traceCt = numel(photoData);
    dataNorm = cell(traceCt,1);
    for iterT = 1:traceCt
        diodeData2save = photoData{iterT};
        if dataType ~= 2
            frmCount = numel(diodeData2save);
            phBrks = round(linspace(1,frmCount,round(frmCount/100)));
            ranges = zeros(numel(phBrks)-1,1);
            for iterPh = 1:numel(phBrks)-1
                ranges(iterPh) = iqr(diodeData2save(phBrks(iterPh):phBrks(iterPh+1)));
            end
            avgBase = median(diodeData2save(1:300));
%             avgPeak = means(max(ranges) == ranges);
            avgPeak = median(ranges);
            photoSignalTest = abs((avgPeak-avgBase)/min(ranges));
            if photoSignalTest >= 10
                photoNorm = abs(diodeData2save-avgBase(1))./max(ranges);
            else
                photoNorm = abs(diodeData2save-avgBase(1));
            end
            photoNorm(photoNorm > 0.8) = 0.8;
            photoNorm(photoNorm < 0.5) = 0.5;
            photoNorm = (photoNorm-min(photoNorm))/range(photoNorm);
        else
            diodeData2save = diodeData2save./5;
            goodfinder(iterT) = min([min(diodeData2save) < .8,range(diodeData2save) ~= 0]);
            photoNorm = diodeData2save;
        end
        photoNorm(end:maxL) = NaN;
        dataNorm{iterT} = photoNorm;
    end
    photoData = cell2mat(dataNorm);
    photoData = photoData+repmat((1:size(photoData,1))',1,size(photoData,2));
    if dataType == 2
        photoData(~goodfinder,:) = [];
        sortedData = sort(photoData,2);
        sortMean(iterT) = mean(sortedData(1:6000),2);
        sortVar(iterT) = var(sortedData(1:6000)')';
        fullOnData = photoData(sortedData(:,5000) < 0.75,:);
        photoDiffs = (circshift(photoData,[0 -1])-photoData);
        for iterS = 1:size(photoData,1)
            try
                startA(iterS) = find(photoDiffs(iterS,:) < -0.0008,1,'first');
                deltas(iterS) = sum(photoDiffs(iterS,:) < -0.0008);
                stopsA(iterS) = find(photoDiffs(iterS,:) > 0.002,1,'first');
                stopsLast(iterS) = find(photoDiffs(iterS,:) > 0.001,1,'last');
            catch
            end
        end
        
        singlePulse = deltas < 40;
        rampSignal = deltas > 120;
        multiPulse = min(~singlePulse,~rampSignal);
    end
    
%     plot(stopsA(multiPulse)-startA(multiPulse))
%     plot(stopsLast(singlePulse)-startA(singlePulse))
    %
    figPos = [150,150,1700,950];
    figure,plot(photoData')
%     figure,plot(photoData(multiPulse,:)')
%     figure,plot(diff(photoData,5,2)')
%     figure,plot(photoDiffs(multiPulse(4),:)')
    
    %     x = repmat((1:size(photoData,1))',1,size(photoData,2))';
    %     y = repmat(1:size(photoData,2),size(photoData,1),1)';
    %     z = photoData';
    %     plot3(x,y,z)
    set(gcf,'position',figPos)
    %     set(gca,'zlim',[0.8 1])
end

