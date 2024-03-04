function dailyExptTableUpdater(exptID,runDir)

op_sys = system_dependent('getos');
if strfind(op_sys,'Microsoft Windows 7')
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
parentDir = fullfile(archDir,'Data_pez3000');
analysisDir = fullfile(dm11Dir,'Data_pez3000_analyzed');
repositoryDir = 'C:\Users\cardlab\Documents\pezAnalysisRepository\Pez3000_Gui_folder\Matlab_functions';
addpath(fullfile(repositoryDir,'Support_Programs'))
failure_path = fullfile(analysisDir,'dailyExptTableUpdaterFailures.txt');

assessmentTag = '_rawDataAssessment.mat';

assessVars = {'Video_Path','Data_Acquisition','Fly_Count',...
    'Gender','Balancer','Physical_Condition','Analysis_Status',...
    'Fly_Detect_Accuracy','NIDAQ',...
    'Raw_Data_Decision','Adjusted_ROI',...
    'Curation_Status','User_Input','Flag_A','Flag_B','Flag_C'};
manualAnnotationsVars = {'notes','frame_of_wing_movement','frame_of_leg_push',...
    'leg_slip','wing_down_stroke','frame_of_take_off'};


runRefPath = fullfile(analysisDir,exptID,[exptID '_rawDataReference_v2.mat']);
vidPopPass = true;
if exist(runRefPath,'file') == 2
    runRefData_import = load(runRefPath);
    dataname = fieldnames(runRefData_import);
    runRefData = runRefData_import.(dataname{1});
    runRefData = runRefData(strcmp({runRefData(:).runPath},runDir));
    if ~isempty(runRefData)
        videoList = cat(1,runRefData(:).videoList);
        if ~isempty(videoList)
            [~,videoNameList] = cellfun(@(x) fileparts(x),videoList,'uniformoutput',false);
            dotBug = cellfun(@(x) strcmp(x(1),'.'),videoNameList);
            videoNameList(dotBug) = [];
            videoNameList = unique(videoNameList);
        else
            vidPopPass = false;
        end
    else
        vidPopPass = false;
    end
else
    vidPopPass = false;
end
if ~vidPopPass
    fidErr = fopen(failure_path,'a');
    fprintf(fidErr,'%s \t %s\r\n',exptID,'raw data assessment fail');
    fclose(fidErr);
    return
end


%%%%% Load and append assess table
assessmentName = [exptID assessmentTag];
assessmentPath = fullfile(analysisDir,exptID,assessmentName);
assessTable = cell2table(cell(numel(videoNameList),numel(assessVars)),...
    'RowNames',videoNameList,'VariableNames',assessVars);
if exist(assessmentPath,'file') == 2
    assessTable_import = load(assessmentPath);
    dataname = fieldnames(assessTable_import);
    assessTable_import = assessTable_import.(dataname{1});
    if ~isempty(assessTable_import)
        existList = assessTable_import.Properties.RowNames;
        existTest = cellfun(@(x) max(strcmp(existList,x)),videoNameList);
        newVidList = videoNameList(~existTest);
        blankData = cell(numel(newVidList),numel(assessVars));
        assessTable2Append = cell2table(blankData,'RowNames',...
            newVidList,'VariableNames',assessVars);
        
        
        %%%% Denotes current stimulus being used
        assessTable2Append.Flag_A = repmat({'White_stimulus_v1'},...
            numel(newVidList),1);
        
        
        assessTable = [assessTable_import;assessTable2Append];
    end
end
save(assessmentPath,'assessTable')


%%%%% Load and append manual annotations table
manualAnnotationsName = [exptID '_manualAnnotations.mat'];
manualAnnotationsPath = fullfile(analysisDir,exptID,manualAnnotationsName);
manualAnnotations = cell2table(cell(numel(videoNameList),numel(manualAnnotationsVars)),...
    'RowNames',videoNameList,'VariableNames',manualAnnotationsVars);
if exist(manualAnnotationsPath,'file') == 2
    manualAnnotations_import = load(manualAnnotationsPath);
    dataname = fieldnames(manualAnnotations_import);
    manualAnnotations_import = manualAnnotations_import.(dataname{1});
    n = 0;
    while isstruct(manualAnnotations_import)
        manualAnnotations_import = manualAnnotations_import.manualAnnotations;
        n = n+1;
        if n > 10
            break
        end
    end
    if ~isempty(manualAnnotations_import)
        existList = manualAnnotations_import.Properties.RowNames;
        existTest = cellfun(@(x) max(strcmp(existList,x)),videoNameList);
        newVidList = videoNameList(~existTest);
        blankData = cell(numel(newVidList),numel(manualAnnotationsVars));
        manualAnnotations2Append = cell2table(blankData,'RowNames',...
            newVidList,'VariableNames',manualAnnotationsVars);
        manualAnnotations = [manualAnnotations_import;manualAnnotations2Append];
    end
end
save(manualAnnotationsPath,'manualAnnotations')


vidNameMat = cell2mat(videoNameList);
runList = cellstr(vidNameMat(:,1:23));
runList = unique(runList);
if numel(runList) > 1
    error('video naming error')
end
runName = runList{1};
runDir = fullfile(parentDir,runName(end-7:end),runName);

%%%%% Load and append experiment info master dataset
exptInfoPath = fullfile(runDir,[runName '_experimentIDinfo.mat']);
if ~exist(exptInfoPath,'file')
    fidErr = fopen(failure_path,'a');
    fprintf(fidErr,'%s\t%s\t%s\r\n',runDir,'experimentIDinfo loading fail',datestr(now));
    fclose(fidErr);
    return
else
    exptInfoFromRun_import = load(exptInfoPath);
    dataname = fieldnames(exptInfoFromRun_import);
    exptInfoFromRun = exptInfoFromRun_import.(dataname{1});
    if isstruct(exptInfoFromRun)
        if str2double(exptID(13:16)) < 100 % old style for backward compatability
            exptInfo = parse_expid(exptID);
            if ischar(exptInfo)
                error(exptInfo)
            end
        else % new way of parsing and storing data
            exptInfo = parse_expid_v2(exptID);
            if ischar(exptInfo)
                error(exptInfo)
            end
            if strcmp('Alternating',exptInfo.Photo_Activation{1})
                exptInfo.Photo_Activation = {{'pulse_General_widthBegin1000_widthEnd1000_cycles1_intensity20';
                    'pulse_General_widthBegin5_widthEnd150_cycles5_intensity30'}};
            end
        end
        exptInfoFromRun = exptInfo;
    end
end
varNames = get(exptInfoFromRun,'VarNames');
if max(strcmp(varNames,'Videos_In_Collection'))
    exptInfoFromRun.Videos_In_Collection = [];
end
if max(strcmp(varNames,'Archived_Videos'))
    exptInfoFromRun.Archived_Videos = [];
end
if max(strcmp(varNames,'Duplicate_Entry'))
    exptInfoFromRun.Duplicate_Entry = [];
end
exptInfoFromRun = set(exptInfoFromRun,'ObsNames',{runName});
experimentInfoMerged = exptInfoFromRun;
exptInfoMergedName = [exptID '_experimentInfoMerged.mat'];
exptInfoMergedPath = fullfile(analysisDir,exptID,exptInfoMergedName);
if exist(exptInfoMergedPath,'file') == 2
    experimentInfo_import = load(exptInfoMergedPath);
    dataname = fieldnames(experimentInfo_import);
    experimentInfo_import = experimentInfo_import.(dataname{1});
    existList = get(experimentInfo_import,'ObsNames');
    existTest = strcmp(existList,runName);
    experimentInfo_import(existTest,:) = [];
    experimentInfoMerged = [experimentInfo_import;experimentInfoMerged];
end
save(exptInfoMergedPath,'experimentInfoMerged')


%%%%% Load and append video statistics master dataset
vidInfoFromRun_import = load(fullfile(runDir,[runName '_videoStatistics.mat']));
dataname = fieldnames(vidInfoFromRun_import);
vidInfoFromRun = vidInfoFromRun_import.(dataname{1});
varNames = get(vidInfoFromRun,'VarNames');
if max(strcmp(varNames,'videoID'))
    vidInfoFromRun.videoID = [];
end
if max(strcmp(varNames,'time_on_prism'))
    vidInfoFromRun.time_on_prism = [];
end
autoAnalysisPath = fullfile(runDir,'inspectionResults',[runName '_autoAnalysisResults.mat']);
if exist(autoAnalysisPath,'file')
    autoAnalysisRun_import = load(autoAnalysisPath);
    dataname = fieldnames(autoAnalysisRun_import);
    autoAnalysisRun = autoAnalysisRun_import.(dataname{1});
    vidNamesRun = get(vidInfoFromRun,'ObsNames');
    try
        vidInfoFromRun.trigger_timestamp(vidNamesRun) = autoAnalysisRun.timestamp(vidNamesRun);
    catch
        autoNames = get(autoAnalysisRun,'ObsNames');
        vidInfoFromRun.trigger_timestamp(autoNames) = autoAnalysisRun.timestamp(autoNames);
    end
end
videoStatisticsMerged = vidInfoFromRun;
vidInfoMergedName = [exptID '_videoStatisticsMerged.mat'];
vidInfoMergedPath = fullfile(analysisDir,exptID,vidInfoMergedName);
if exist(vidInfoMergedPath,'file') == 2
    vidInfo_import = load(vidInfoMergedPath);
    dataname = fieldnames(vidInfo_import);
    vidInfo_import = vidInfo_import.(dataname{1});
    existList = get(vidInfo_import,'ObsNames');
    existTest = cellfun(@(x) max(strcmp(videoNameList,x)),existList);
    vidInfo_import(existTest,:) = [];
    videoStatisticsMerged = [vidInfo_import;videoStatisticsMerged];
end
save(vidInfoMergedPath,'videoStatisticsMerged')

