function pez3000_variableAssessment
%% close all
runmode = 2;%1 is initial assessment,2 is inspect, 3 is fix and check, 4 is fix and save
%%%%%%%%%%%%%%% RUN IN ORDER %%%%%%%%%%%%%%%%%%

%%%%% computer and directory variables and information
op_sys = system_dependent('getos');
if strfind(op_sys,'Microsoft Windows 7')
    %    archDir = [filesep filesep 'arch' filesep 'card'];
    archDir = [filesep filesep 'tier2' filesep 'card'];
    dm11Dir = [filesep filesep 'dm11' filesep 'cardlab'];
else
    archDir = [filesep 'Volumes' filesep 'card'];
    if ~exist(archDir,'file')
        archDir = [filesep 'Volumes' filesep 'card-1'];
    end
    dm11Dir = [filesep 'Volumes' filesep 'cardlab'];
end
if ~exist(archDir,'file')
    error('Archive access failure')
end
if ~exist(dm11Dir,'file')
    error('dm11 access failure')
end
analysisDir = fullfile(archDir,'Data_pez3000_analyzed');
failure_path = fullfile(analysisDir,'errorLogs','variableAssessmentErrors.txt');

ignorePath = fullfile(analysisDir,'ignoreLists','runs2ignoreList.txt');
ignoreCell = readtable(ignorePath,'Delimiter','\t','ReadVariableNames',false);
runs2ignoreCell = table2cell(ignoreCell);
ignorePath = fullfile(analysisDir,'ignoreLists','videos2ignoreList.txt');
ignoreCell = readtable(ignorePath,'Delimiter','\t','ReadVariableNames',false);
vids2ignoreCell = table2cell(ignoreCell);

if runmode == 1
    if exist(failure_path,'file')
        delete(failure_path)
    end
    exptIDlist = dir(analysisDir);
    exptIDexist = cell2mat({exptIDlist(:).isdir});
    exptIDlengthTest = cellfun(@(x) numel(x) == 16,{exptIDlist(:).name});
    exptIDlist = {exptIDlist(min(exptIDexist,exptIDlengthTest)).name};
    exptIDlist = flipud(exptIDlist(:));
elseif runmode == 2
    exptIDlist = {'0067000021690510'};
else
    %%%%% makes expt list from error record
    errorList = importdata(failure_path);
    exptIDlist = cellfun(@(x) x(1:16),errorList.textdata(:,1),'uniformoutput',false);
end
exptCt = numel(exptIDlist);
sizeTally = 0;
for iterE = 1:exptCt
    exptID = exptIDlist{iterE};
    exptResultsRefDir = fullfile(analysisDir,exptID);
    assessmentName = [exptID '_rawDataAssessment.mat'];
    assessmentPath = fullfile(exptResultsRefDir,assessmentName);
    if exist(assessmentPath,'file') == 2
        assessTable_import = load(assessmentPath);
        dataname = fieldnames(assessTable_import);
        assessTable = assessTable_import.(dataname{1});
    else
        fidErr = fopen(failure_path,'a');
        fprintf(fidErr,'%s\t%s\t%s\r\n',exptID,'no assessment file',datestr(now));
        fclose(fidErr);
        continue
    end
    assessNames = assessTable.Properties.RowNames;
    discardListA = cellfun(@(x) isempty(strfind(x,exptID)),assessNames,'uniformoutput',false);
    discardListA = cell2mat(discardListA);
    discardListB = cellfun(@(x) numel(x) ~= 52,assessNames);
    
    % removes entries matching ignore lists
    discardList = cell(numel(assessNames),1);
    for iterI = 1:numel(assessNames)
        discardList{iterI} = cellfun(@(x) ~isempty(strfind(assessNames{iterI},x)),...
            runs2ignoreCell(:,1),'uniformoutput',false);
        discardList{iterI} = max(cell2mat(discardList{iterI}));
    end
    discardListC = cell2mat(discardList);
    discardList = cell(numel(assessNames),1);
    for iterI = 1:numel(assessNames)
        discardList{iterI} = max(cellfun(@(x) strcmp(x,assessNames{iterI}),...
            vids2ignoreCell(:,1)));
    end
    discardListD = cell2mat(discardList);
    discardList = max([discardListA,discardListB,discardListC,discardListD],[],2);
    if sum(discardList) > 0
        assessTable(discardList,:) = [];
        fidErr = fopen(failure_path,'a');
        errStr = [num2str(sum(discardList)) ' videos discarded'];
        fprintf(fidErr,'%s\t%s\r\n',exptID,errStr);
        fclose(fidErr);
    end
    
%     assessNames = assessTable.Properties.RowNames;
    
    %%%%% make sure the green versus flicker versus white is right!!
    %%%%% deal with activation nidaq traces which we have decided to ignore
    
    
    manualAnnotationsName = [exptID '_manualAnnotations.mat'];
    manualAnnotationsPath = fullfile(exptResultsRefDir,manualAnnotationsName);
    if exist(manualAnnotationsPath,'file') == 2
        manualAnnotations_import = load(manualAnnotationsPath);
        dataname = fieldnames(manualAnnotations_import);
        manualAnnotations = manualAnnotations_import.(dataname{1});
    else
        fidErr = fopen(failure_path,'a');
        fprintf(fidErr,'%s\t%s\t%s\r\n',exptID,'no manual annotations file',datestr(now));
        fclose(fidErr);
        continue
    end
%     manualNames = manualAnnotations.Properties.RowNames;
%     discardList = cellfun(@(x) isempty(strfind(x,exptID)),manualNames,'uniformoutput',false);
%     discardList = cell2mat(discardList);
%     if sum(discardList) > 0
%         manualAnnotations(discardList,:) = [];
%     end

    autoAnnoName = [exptID '_automatedAnnotations.mat'];
    autoAnnotationsPath = fullfile(analysisDir,exptID,autoAnnoName);
    if exist(autoAnnotationsPath,'file') == 2
        autoAnnoTable_import = load(autoAnnotationsPath);
        dataname = fieldnames(autoAnnoTable_import);
        automatedAnnotations = autoAnnoTable_import.(dataname{1});
    else
        fidErr = fopen(failure_path,'a');
        fprintf(fidErr,'%s\t%s\t%s\r\n',exptID,'no automatic annotations file',datestr(now));
        fclose(fidErr);
        continue
    end

    vidInfoMergedName = [exptID '_videoStatisticsMerged.mat'];
    vidInfoMergedPath = fullfile(exptResultsRefDir,vidInfoMergedName);
    if exist(vidInfoMergedPath,'file') == 2
        vidInfo_import = load(vidInfoMergedPath);
        dataname = fieldnames(vidInfo_import);
        videoStatisticsMerged = vidInfo_import.(dataname{1});
    else
        fidErr = fopen(failure_path,'a');
        fprintf(fidErr,'%s\t%s\t%s\r\n',exptID,'no vid stats file',datestr(now));
        fclose(fidErr);
        continue
    end
%     vidStatNames = get(videoStatisticsMerged,'ObsNames');
%     discardList = cellfun(@(x) isempty(strfind(x,exptID)),vidStatNames,'uniformoutput',false);
%     discardList = cell2mat(discardList);
%     if sum(discardList) > 0
%         videoStatisticsMerged(discardList,:) = [];
%     end
    
    assessNames = assessTable.Properties.RowNames;
    manualNames = manualAnnotations.Properties.RowNames;
    vidStatNames = get(videoStatisticsMerged,'ObsNames');
    autoNames = automatedAnnotations.Properties.RowNames;
    nameCell = {assessNames,manualNames,vidStatNames,autoNames};
    nameCounts = [numel(nameCell{1}),numel(nameCell{2}),numel(nameCell{3}),numel(nameCell{4})];
    if sum(abs(diff(nameCounts))) > 0
        if runmode == 1
            fidErr = fopen(failure_path,'a');
            errStr = ['vidStats: ' num2str(numel(vidStatNames)) ' - assessNames: ',...
                num2str(numel(assessNames)) ' - manualNames: ',...
                num2str(numel(manualNames)) ' - autoNames: ' num2str(numel(autoNames))];
            fprintf(fidErr,'%s\t%s\r\n',exptID,errStr);
            fclose(fidErr);
        end
        [~,minNdx] = min(nameCounts);
        masterList = nameCell{minNdx};
        if runmode ~= 2
            videoStatisticsMerged = videoStatisticsMerged(masterList,:);
            manualAnnotations = manualAnnotations(masterList,:);
            assessTable = assessTable(masterList,:);
            automatedAnnotations = automatedAnnotations(masterList,:);
        end
        if runmode == 3
            %%% use the following to be sure appropriate corrections were made
            assessNames = assessTable.Properties.RowNames;
            manualNames = manualAnnotations.Properties.RowNames;
            vidStatNames = get(videoStatisticsMerged,'ObsNames');
            autoNames = automatedAnnotations.Properties.RowNames;
            nameCell = {assessNames,manualNames,vidStatNames,autoNames};
            nameCounts = [numel(nameCell{1}),numel(nameCell{2}),numel(nameCell{3}),numel(nameCell{4})];
            sum(abs(diff(nameCounts)))
        elseif runmode == 4
            %%% only after absolute certainty, save out the modified variables
            save(assessmentPath,'assessTable')
            save(manualAnnotationsPath,'manualAnnotations')
            save(vidInfoMergedPath,'videoStatisticsMerged')
            save(autoAnnotationsPath,'automatedAnnotations')
        end
    end
end
