function pez3000_rawDataPrep
%pez3000_rawDataPrep Updates experiment ID / run associations
%   Assimilates newly run experiments and prepares the
%   variables needed for curation and analysis

%%%%% computer and directory variables and information
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');
parentDir = fullfile(fileDir,'Data_pez3000');
housekeepingDir = fullfile(fileDir,'Pez3000_Gui_folder','defaults_and_housekeeping_variables');
analysisDir = fullfile(fileDir,'Data_pez3000_analyzed');

subfun_dir = fullfile(repositoryDir,'flyPEZanalysis','pezProc_subfunctions');
saved_var_dir = fullfile(repositoryDir,'flyPEZanalysis','pezProc_saved_variables');
assessment_dir = fullfile(repositoryDir,'flyPEZanalysis','file_assessment_and_manipulation');
addpath(repositoryDir,subfun_dir,saved_var_dir,assessment_dir)
addpath(fullfile(repositoryDir,'flyPEZguis','Matlab_functions','Support_Programs'))
addpath(fullfile(repositoryDir,'flyPEZanalysis','graphing_and_visualization'))

dateFolders = dir(fullfile(parentDir,'20*'));
dateFolders = sort({dateFolders(:).name});
%%%%%%%%%%%%%%%%%%%%%%%%%
startFlag = 2;
%%%%%%%%%%%%%%%%%%%%%%%%%
if startFlag == 2
    lastDate = load(fullfile(housekeepingDir,'lastDateAssessed_curator.mat'));
    datanameLoad = fieldnames(lastDate);
    lastDateAssessed = lastDate.(datanameLoad{1});
%     lastDateAssessed = '20230701';%%%%%%%%%%%%%%%%%%%%%%%%
    beginRef = find(strcmp(dateFolders,lastDateAssessed));
    if beginRef < 1, beginRef = 1; end
else
    beginRef = 1;
end
%%
ignorePath = fullfile(analysisDir,'ignoreLists','runs2ignoreList.txt');
ignoreCell = readtable(ignorePath,'Delimiter','\t','ReadVariableNames',false);
ignoreCell = table2cell(ignoreCell);
refs = (beginRef:numel(dateFolders));
% dateFolders(refs)'
% refs = fliplr(1:beginRef);%%%%%%%%%%%%%%%%%%%%%%%%%%
for iterBrk = 1:numel(refs)
    dateFolderStr = dateFolders{refs(iterBrk)};
    disp(dateFolderStr)
    datePath = fullfile(parentDir,dateFolderStr);
    if isdir(datePath)
        runFolders = dir(fullfile(datePath,'run*'));
        runFolders = {runFolders(:).name};
        runCt = numel(runFolders);
        if strcmp(datestr(date,'yyyymmdd'),dateFolderStr)
%             runCt = runCt-4;
        end
        if runCt < 1
            continue
        else
            for iterRun = 1:runCt
                if max(strcmp(ignoreCell(:,1),runFolders{iterRun}))
                    continue
                end
                makeDataVars(runFolders{iterRun},datePath)
            end
        end
    end
    save(fullfile(housekeepingDir,'lastDateAssessed_curator.mat'),'dateFolderStr')
end
end

function makeDataVars(runName,datePath)
%% %%% computer and directory variables and information
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');

analysisDir = fullfile(fileDir,'Data_pez3000_analyzed');
failure_path = fullfile(analysisDir,'errorLogs','experimentRefErrors.txt');

subfun_dir = fullfile(repositoryDir,'flyPEZanalysis','pezProc_subfunctions');
saved_var_dir = fullfile(repositoryDir,'flyPEZanalysis','pezProc_saved_variables');
addpath(repositoryDir,subfun_dir,saved_var_dir)
addpath(fullfile(repositoryDir,'flyPEZguis','Matlab_functions','Support_Programs'))

ignorePath = fullfile(analysisDir,'ignoreLists','videos2ignoreList.txt');
ignoreCell = readtable(ignorePath,'Delimiter','\t','ReadVariableNames',false);
ignoreCell = table2cell(ignoreCell);

runPath = fullfile(datePath,runName);
videoListMP4 = dir(fullfile(runPath,'*.mp4'));
videoListAVI = dir(fullfile(runPath,'*.avi'));
if ~isempty(videoListMP4)
    videoListExt = videoListMP4;
elseif ~isempty(videoListAVI)
    videoListExt = videoListAVI;
else
    fidErr = fopen(failure_path,'a');
    fprintf(fidErr,'%s\t%s\t%s\r\n',runPath,'no videos detected',datestr(now));
    fclose(fidErr);
    return
end
videoListExt = {videoListExt(:).name}';
dotBug = cellfun(@(x) strcmp(x(1),'.'),videoListExt);

videoListExt(dotBug) = [];
videoList = cellfun(@(x) x(1:end-4),videoListExt,'uniformoutput',false);
runStatName = dir(fullfile(runPath,'*runStatistics.mat'));
if isempty(runStatName)
    fidErr = fopen(failure_path,'a');
    fprintf(fidErr,'%s\t%s\t%s\r\n',runPath,'run statistics missing',datestr(now));
    fclose(fidErr);
    return
end
runStats_import = load(fullfile(runPath,runStatName(1).name));
datanameLoad = fieldnames(runStats_import);
runStats = runStats_import.(datanameLoad{1});
if isempty(runStats)
    fidErr = fopen(failure_path,'a');
    fprintf(fidErr,'%s\t%s\t%s\r\n',runPath,'run statistics empty',datestr(now));
    fclose(fidErr);
    return
end
try
    exptID = runStats.experimentID;
catch
    fidErr = fopen(failure_path,'a');
    fprintf(fidErr,'%s\t%s\t%s\r\n',runPath,'run statistics incomplete',datestr(now));
    fclose(fidErr);
    return
end
if numel(exptID) > 16
    fidErr = fopen(failure_path,'a');
    fprintf(fidErr,'%s\t%s\t%s\r\n',runPath,'expt ID too many characters',datestr(now));
    fclose(fidErr);
    return
end
if strcmp(exptID,'0000000000000000')
    return
end

%make experiment directories
exptResultsRefDir = fullfile(analysisDir,exptID);
if ~isdir(exptResultsRefDir), mkdir(exptResultsRefDir),end
montyDir = fullfile(exptResultsRefDir,'montageFrames');
if ~isdir(montyDir), mkdir(montyDir),end


%%%%% Load and append experiment info master dataset
exptInfoPath = fullfile(runPath,[runName '_experimentIDinfo.mat']);
makeNewExptInfo = true;
if ~exist(exptInfoPath,'file')
    fidErr = fopen(failure_path,'a');
    fprintf(fidErr,'%s\t%s\t%s\r\n',runPath,'experimentIDinfo does not exist',datestr(now));
    fclose(fidErr);
else
    exptInfoFromRun_import = load(exptInfoPath);
    dataname = fieldnames(exptInfoFromRun_import);
    exptInfo = exptInfoFromRun_import.(dataname{1});
    if ~isstruct(exptInfo)
        makeNewExptInfo = false;
    end
end
if makeNewExptInfo
    if str2double(exptID(13:16)) < 100 % old style for backward compatability
        [~,exptInfo] = parse_expid(exptID);
        if ischar(exptInfo)
            error(exptInfo)
        end
    else % new way of parsing and storing data
        exptInfo = parse_expid_v2(exptID);
        if ischar(exptInfo)
            error(exptInfo)
        end
    end
end

varNamesExpt = get(exptInfo,'VarNames');
if max(strcmp(varNamesExpt,'Stimuli_type'))
    [~,exptInfo] = parse_expid(exptInfo);
end

visStimType = exptInfo.Stimuli_Type{1};
visStimTest = false;
if ~strcmp('None',visStimType)
    if ~strcmp('Template_making',visStimType)
        visStimTest = true;
    end
end

if str2double(exptID(13:16)) < 100
    [~,exptInfo4photo] = parse_expid(exptID);
else
    exptInfo4photo = parse_expid_v2(exptID);
end
try
exptInfo.Photo_Activation{1} = exptInfo4photo.Photo_Activation{1};
catch
    keyboard
end

if strcmp('Alternating',exptInfo.Photo_Activation{1})
    exptInfo.Photo_Activation = {{'pulse_General_widthBegin1000_widthEnd1000_cycles1_intensity20';
        'pulse_General_widthBegin5_widthEnd150_cycles5_intensity30'}};
end
activationStrCell = exptInfo.Photo_Activation{1};
if ischar(activationStrCell)
    activationStrCell = {activationStrCell};
end
if ~strcmp('None',activationStrCell{1}) && ~contains(activationStrCell{1},'intensity0')
    photoStimTest = true;
else
    photoStimTest = false;
end

varNamesExpt = get(exptInfo,'VarNames');
if max(strcmp(varNamesExpt,'Videos_In_Collection'))
    exptInfo.Videos_In_Collection = [];
end
if max(strcmp(varNamesExpt,'Archived_Videos'))
    exptInfo.Archived_Videos = [];
end
if max(strcmp(varNamesExpt,'Duplicate_Entry'))
    exptInfo.Duplicate_Entry = [];
end
exptInfo = set(exptInfo,'ObsNames',{runName});
experimentInfoMerged = exptInfo;
exptInfoMergedName = [exptID '_experimentInfoMerged.mat'];
exptInfoMergedPath = fullfile(exptResultsRefDir,exptInfoMergedName);
if exist(exptInfoMergedPath,'file') == 2
    experimentInfo_import = load(exptInfoMergedPath);
    dataname = fieldnames(experimentInfo_import);
    experimentInfo_import = experimentInfo_import.(dataname{1});
    existList = get(experimentInfo_import,'ObsNames');
    existTest = strcmp(existList,runName);
    experimentInfo_import(existTest,:) = [];
    if size(experimentInfo_import,2) == size(experimentInfoMerged,2)
        try
            if ~isempty(experimentInfo_import)
                experimentInfoMerged = [experimentInfo_import;experimentInfoMerged]; %#ok<NASGU>
            end
        catch
            disp('badcat')
            disp(exptID)
        end
    end
end

%%%%% Load and append video statistics master dataset
vidInfoFromRun_import = load(fullfile(runPath,[runName '_videoStatistics.mat']));
dataname = fieldnames(vidInfoFromRun_import);
vidInfoFromRun = vidInfoFromRun_import.(dataname{1});
varNamesVid = get(vidInfoFromRun,'VarNames');
if max(strcmp(varNamesVid,'videoID'))
    vidInfoFromRun.videoID = [];
end
if max(strcmp(varNamesVid,'time_on_prism'))
    vidInfoFromRun.time_on_prism = [];
end
autoAnalysisPath = fullfile(runPath,'inspectionResults',[runName '_autoAnalysisResults.mat']);
if exist(autoAnalysisPath,'file')
    autoAnalysisRun_import = load(autoAnalysisPath);
    dataname = fieldnames(autoAnalysisRun_import);
    autoAnalysisRun = autoAnalysisRun_import.(dataname{1});
    vidNamesRun = get(vidInfoFromRun,'ObsNames');
    try
        vidInfoFromRun.trigger_timestamp(vidNamesRun) = autoAnalysisRun.timestamp(vidNamesRun);
    catch
        autoNames = get(autoAnalysisRun,'ObsNames');
        discardList = cellfun(@(x) ~isempty(strfind(x,'discard')),autoNames,'uniformoutput',false);
        discardList = cell2mat(discardList);
        autoNames(discardList) = [];
        vidInfoFromRun.trigger_timestamp(autoNames) = autoAnalysisRun.timestamp(autoNames);
    end
end

vidNamesRun = get(vidInfoFromRun,'ObsNames');
% removes vid stats with wrong names
discardList = cellfun(@(x) ~isempty(strfind(x,'discard')),vidNamesRun,'uniformoutput',false);
discardList = cell2mat(discardList);
vidInfoFromRun(discardList,:) = [];

% removes vid stats with no videos
vidNamesRun = get(vidInfoFromRun,'ObsNames');
existTest = cellfun(@(x) ~max(strcmp(videoList,x)),vidNamesRun);
if sum(existTest) > 0
    vidInfoFromRun(existTest,:) = [];
    fidErr = fopen(failure_path,'a');
    errStr = [num2str(numel(videoList)) ' videos for ',...
        num2str(numel(vidNamesRun)) ' vidstats records'];
    fprintf(fidErr,'%s\t%s\t%s\r\n',runPath,errStr,datestr(now));
    fclose(fidErr);
end

% removes videos with no vid stats
vidNamesRun = get(vidInfoFromRun,'ObsNames');
if numel(videoList) > numel(vidNamesRun)
    fidErr = fopen(failure_path,'a');
    errStr = [num2str(numel(videoList)) ' videos for ',...
        num2str(numel(vidNamesRun)) ' vidstats records'];
    fprintf(fidErr,'%s\t%s\t%s\r\n',runPath,errStr,datestr(now));
    fclose(fidErr);
    existTest = cellfun(@(x) ~max(strcmp(vidNamesRun,x)),videoList);
    videoListExt(existTest) = [];
    videoList(existTest) = [];
end

% removes vid stats matching 'bad' videos
discardList = cellfun(@(x) max(strcmp(ignoreCell(:,1),x)),vidNamesRun);
vidInfoFromRun(discardList,:) = [];
existTest = cellfun(@(x) max(strcmp(ignoreCell(:,1),x)),videoList);
videoListExt(existTest) = [];
videoList(existTest) = [];
if isempty(videoList)
    return
end
videoStatisticsMerged = vidInfoFromRun;
vidInfoMergedName = [exptID '_videoStatisticsMerged.mat'];
vidInfoMergedPath = fullfile(exptResultsRefDir,vidInfoMergedName);
if exist(vidInfoMergedPath,'file') == 2
    vidInfo_import = load(vidInfoMergedPath);
    dataname = fieldnames(vidInfo_import);
    vidInfo_import = vidInfo_import.(dataname{1});
    existList = get(vidInfo_import,'ObsNames');
    existTest = cellfun(@(x) max(strcmp(videoList,x)),existList);
    discardList = cellfun(@(x) ~isempty(strfind(x,'discard')),existList,'uniformoutput',false);
    discardList = cell2mat(discardList);
    discardList = max(existTest,discardList);
    vidInfo_import(discardList,:) = [];
    videoStatisticsMerged = [vidInfo_import;videoStatisticsMerged];
end


%%%%% Load and append assess table
assessVars = {'Video_Path','Data_Acquisition','Fly_Count',...
    'Gender','Balancer','Physical_Condition','Analysis_Status',...
    'Fly_Detect_Accuracy','NIDAQ',...
    'Raw_Data_Decision','Adjusted_ROI',...
    'Curation_Status','User_Input','Flag_A','Flag_B','Flag_C','Final_Status','APT_Tracking','APT_RetrackFlag'};
assessmentTag = '_rawDataAssessment.mat';
assessmentName = [exptID assessmentTag];
assessmentPath = fullfile(exptResultsRefDir,assessmentName);
assessTable = cell2table(cell(numel(videoList),numel(assessVars)),...
    'RowNames',videoList,'VariableNames',assessVars);
if exist(assessmentPath,'file') == 2
    try
        assessTable_import = load(assessmentPath);
    catch       %there is a case of a corupted file that crashes code
        return
    end
    dataname = fieldnames(assessTable_import);
    try
    assessTable_import = assessTable_import.(dataname{1});
    catch
        keyboard
    end
    if ~isempty(assessTable_import)
        if ~ismember('APT_Tracking', assessTable_import.Properties.VariableNames) %if APT columns haven't been added yet, add them
            assessTable_import.APT_Tracking = ones(height(assessTable_import),1); %default 1, add to tracking list - not yet tracked
            assessTable_import.APT_RetrackFlag = zeros(height(assessTable_import),1); %default 0, no retrack
        end
        existList = assessTable_import.Properties.RowNames;
        existTest = cellfun(@(x) max(strcmp(existList,x)),videoList);
        newVidList = videoList(~existTest);
        blankData = cell(numel(newVidList),numel(assessVars));
        assessTable2Append = cell2table(blankData,'RowNames',...
            newVidList,'VariableNames',assessVars);
        
        %%%% Denotes current stimulus being used
        assessTable2Append.Flag_A = repmat({'White_stimulus_v1'},...
            numel(newVidList),1);
        
        assessTable2Append.APT_Tracking = ones(height(assessTable2Append),1); %flags all new vids to be tracked by APT
        assessTable2Append.APT_RetrackFlag = zeros(height(assessTable2Append),1);
        
        try
            assessTable = [assessTable_import;assessTable2Append];
        catch
            warning('table append error')
        end
    end
else
    assessTable.APT_Tracking = ones(height(assessTable),1); %flags all new vids to be tracked by APT
    assessTable.APT_RetrackFlag = zeros(height(assessTable),1); %default 0, no retrack
end
assessTable.Video_Path(videoList) = cellfun(@(x) fullfile(runPath,x),...
    videoListExt,'uniformoutput',false);

autoVarNames = {'jumpTest','jumpScore','autoFrameOfTakeoff'};
automatedAnnotations = cell2table(cell(numel(videoList),numel(autoVarNames)),...
    'RowNames',videoList,'VariableNames',autoVarNames);
autoAnnoName = [exptID '_automatedAnnotations.mat'];
autoAnnotationsPath = fullfile(analysisDir,exptID,autoAnnoName);
if exist(autoAnnotationsPath,'file') == 2
    autoAnnoTable_import = load(autoAnnotationsPath);
    dataname = fieldnames(autoAnnoTable_import);
    autoAnnoTable_import = autoAnnoTable_import.(dataname{1});
    if ~isempty(autoAnnoTable_import)
        existList = autoAnnoTable_import.Properties.RowNames;
        existTest = cellfun(@(x) max(strcmp(existList,x)),videoList);
        newVidList = videoList(~existTest);
        autoVarNames = autoAnnoTable_import.Properties.VariableNames;
        blankData = cell(numel(newVidList),numel(autoVarNames));
        autoAnnoTable2Append = cell2table(blankData,'RowNames',...
            newVidList,'VariableNames',autoVarNames);
        automatedAnnotations = [autoAnnoTable_import;autoAnnoTable2Append];
    end
end
newAutoVars = {'visStimProtocol','visStimFrameStart','visStimFrameCount',...
    'photoStimProtocol','photoStimFrameStart','photoStimFrameCount'};
currVars = automatedAnnotations.Properties.VariableNames;
if ~max(strcmp(currVars,newAutoVars{1}))
    fullVideoList = automatedAnnotations.Properties.RowNames;
    autoAnnotations_add = cell2table(cell(numel(fullVideoList),numel(newAutoVars)),...
        'RowNames',fullVideoList,'VariableNames',newAutoVars);
    automatedAnnotations = [automatedAnnotations(:,1:3) autoAnnotations_add];
end


for iterM = 1:numel(videoList)
    videoID = videoList{iterM};
    
    %roi redux
    roiPos = videoStatisticsMerged.roi{videoID};
    if numel(roiPos) ~= 4
        continue
    end
    stagePos = videoStatisticsMerged.prism_base{videoID};
    xROI = [roiPos(1) roiPos(1) roiPos(3) roiPos(3) roiPos(1)];
    yROI = [roiPos(2) roiPos(4) roiPos(4) roiPos(2) roiPos(2)];
    xDataROI = [xROI(:);NaN;stagePos(1,1);stagePos(end,1)];
    yDataROI = [yROI(:);NaN;stagePos(1,2);stagePos(end,2)];
    roi2save = uint16([xDataROI(:) yDataROI(:)]);
    videoStatisticsMerged.prism_base{videoID} = [];
    videoStatisticsMerged.roi{videoID} = roi2save;
    
    %frame references made compacter
    frmRefCut = uint16(videoStatisticsMerged.cutrate10th_frame_reference{videoID});
    videoStatisticsMerged.cutrate10th_frame_reference{videoID} = frmRefCut;
    frmRefSup = uint16(videoStatisticsMerged.supplement_frame_reference{videoID});
    videoStatisticsMerged.supplement_frame_reference{videoID} = frmRefSup;
    frameCt = double(videoStatisticsMerged.frame_count(videoID));
    rateFactor = double(videoStatisticsMerged.record_rate(videoID))/1000;
    %stimuli redux
    if visStimTest
        visStimStruct = videoStatisticsMerged.visual_stimulus_info{videoID};
        if ~isfield(visStimStruct,'parameters')
            fidVid = fopen(ignorePath,'a');
            fprintf(fidVid,'%s\t%s\r\n',videoID,'vis stim info missing');
            fclose(fidVid);
            makeDataVars(runName,datePath)
            return
        end
        visStimStruct.azimuth = visStimStruct.parameters.azimuth;
        visStimStruct.elevation = visStimStruct.parameters.elevation;
        visStimStruct.decision = 'good photodiode';
        stimTestA = ~isfield(visStimStruct.parameters,'stimulus_duration');
        stimTestB = ~isfield(visStimStruct,'peakPos');
        if stimTestB %normally this is unassessed, old traces...
            %adding the following because auto assess photodiode is
            %unchecked for slow frame rate videos (gratings)
            if rateFactor < 3
                
                stimTestB = false;
                if range(visStimStruct.nidaq_data) == 0
                    visStimStruct.decision = 'signal to noise ratio insufficient';
                else
                    visStimStruct.decision = 'good photodiode';
                end
            end
            %adding the following because auto assess photodiode is
            %unchecked for white on white stimuli
            if ~isempty(strfind(visStimStruct.method,'whiteonwhite'))
                stimTestB = false;
                visStimStruct.peakPos = 1;
                visStimStruct.peakVals = 1;
                visStimStruct.normalized_data = 1;
            end
        end
        if stimTestA || stimTestB
            if ~isfield(visStimStruct,'method')
                stimstart = num2str(visStimStruct.parameters.radius_begin);
                stimend = num2str(visStimStruct.parameters.radius_end);
                stimeloverv = num2str(visStimStruct.parameters.ellovervee);
                visStimStruct.method = ['loom_' stimstart 'to' stimend '_lv' stimeloverv '_blackonwhite.mat'];
            end
            visStimStruct = visStimNidaqAnalyzer(visStimStruct,videoStatisticsMerged(videoID,:));
        end
        visStimStruct.duration = visStimStruct.parameters.stimulus_duration;
        if range(visStimStruct.nidaq_data) == 0
            visStimStruct.nidaq_data(end)=1; %added 4/11/23 by SA to test if this fixes "missing stimulus" error
            visStimStruct.decision = 'signal to noise ratio insufficient';
        end
        if isfield(visStimStruct,'peakPos') && isempty(visStimStruct.peakPos)
            visStimStruct = visStimNidaqAnalyzer(visStimStruct,videoStatisticsMerged(videoID,:));
        end
        if strcmp(visStimStruct.decision,'good photodiode')
            nData = visStimStruct.nidaq_data;
            nData = (nData-min(nData))./range(nData);
            if rateFactor < 3
                if ~isfield(visStimStruct,'peakPos')
                    visStimStruct.peakPos(1) = find(nData < 0.7,1,'first');
                    visStimStruct.peakVals = [];
                    visStimStruct.normalized_data = [];
                elseif isempty(visStimStruct.peakPos)
                    visStimStruct.peakPos(1) = find(nData < 0.7,1,'first');
                end
            end
            
            visStimStruct.stim_start = visStimStruct.peakPos(1);
            visStimStruct.nidaq_data = uint8(nData.*256);
            field2rmv = {'parameters','peakVals','normalized_data','decision'};
            visStimStruct = rmfield(visStimStruct,field2rmv);
            videoStatisticsMerged.visual_stimulus_info{videoID} = visStimStruct;
            automatedAnnotations.visStimProtocol(videoID) = {visStimStruct.method};
            automatedAnnotations.visStimFrameCount(videoID) = {round(visStimStruct.duration*rateFactor)};
            automatedAnnotations.visStimFrameStart(videoID) = {visStimStruct.stim_start};
        else
            if strcmp(visStimStruct.decision,'signal to noise ratio insufficient')
                assessTable.NIDAQ(videoID) = {'FlatLine'};
            elseif strcmp(visStimStruct.decision,'frames were dropped')
                assessTable.NIDAQ(videoID) = {'DropFrm'};
            elseif strcmp(visStimStruct.decision,'visual stimulus incomplete')
                assessTable.NIDAQ(videoID) = {'Short'};
            end
            assessTable.Raw_Data_Decision(videoID) = {'Fail'};
            assessTable.Curation_Status(videoID) = {'Saved'};
        end
    else
        videoStatisticsMerged.visual_stimulus_info{videoID} = [];
    end
    
    if photoStimTest
        photoStimStruct = videoStatisticsMerged.photoactivation_info{videoID};
        if ~isempty(fieldnames(photoStimStruct))
            if isfield(photoStimStruct,'diode_data')
                photoStimStruct.nidaq_data = photoStimStruct.diode_data;
                photoStimStruct = rmfield(photoStimStruct,'diode_data');
            end
            nData = photoStimStruct.nidaq_data;
            nData = (nData-min(nData))./range(nData);
        else
            
            nData = zeros(1,frameCt);
        end
        photoStimStruct.nidaq_data = uint8(nData.*256);
        videoStatisticsMerged.photoactivation_info{videoID} = photoStimStruct;
        photoStimStruct.rateFactor = rateFactor;
        photoStimStruct.frameCt = frameCt;
        stimOps = activationStrCell;
        stimOps = stimOps(~strcmp(stimOps,'None'));
        photoStimStruct.stimOps = stimOps;
        photoStimStruct = photoactivationAnalyzer(photoStimStruct,exptID);
        if ~strcmp(photoStimStruct.stimDecision,'Good')
            assessTable.NIDAQ(videoID) = {photoStimStruct.stimDecision};
            if str2double(exptID(13:16)) >= 100
                if str2double(exptID(13:16)) ~= 135
                    if ~(photoStimTest && visStimTest)
                        assessTable.Raw_Data_Decision(videoID) = {'Fail'};
                        assessTable.Curation_Status(videoID) = {'Saved'};
                    end
                end
            end
        else
            automatedAnnotations.photoStimProtocol(videoID) = photoStimStruct.photoStimProtocol;
            automatedAnnotations.photoStimFrameCount(videoID) = photoStimStruct.photoStimFrameCount;
            automatedAnnotations.photoStimFrameStart(videoID) = photoStimStruct.photoStimFrameStart;
        end
    else
        videoStatisticsMerged.photoactivation_info{videoID} = [];
    end
end

%make directories before sending to parfor
sampleFrameDir = fullfile(analysisDir,exptID,'sampleFrames');
if ~isdir(sampleFrameDir),mkdir(sampleFrameDir),end
montyDir = fullfile(analysisDir,exptID,'montageFrames');
if ~isdir(montyDir), mkdir(montyDir),end
for iterN = 1:numel(videoList)
    videoID = videoList{iterN};
    %saves out montage frames for quick loading in the curator gui
    montyFileName = [videoID '_montage_v2.tif'];
    montyPath = fullfile(montyDir,montyFileName);
    if ~exist(montyPath,'file')
        try
        makeMontageFrame_v2(montyDir,sampleFrameDir,videoListExt{iterN});
        catch
            keyboard
        end
    end
end
for iterO = 1:numel(videoList)
    videoID = videoList{iterO};
    %saves out montage frames for quick loading in the curator gui
    montyFileName = [videoID '_montage_v2.tif'];
    montyPath = fullfile(montyDir,montyFileName);
    if exist(montyPath,'file')
        outcome = 'good';
    else
        outcome = makeMontageFrame_v2(montyDir,sampleFrameDir,videoListExt{iterO});
    end
    if strcmp(outcome,'good')
        if ~isempty(assessTable.Data_Acquisition{videoID})
            if ~strcmp(assessTable.Data_Acquisition{videoID},outcome)
                assessTable.Raw_Data_Decision{videoID} = [];
            end
        end
    else
        assessTable.Raw_Data_Decision(videoID) = {'Fail'};
    end
    assessTable.Data_Acquisition(videoID) = {outcome};
end


%%%%% Load and append manual annotations table
manualAnnotationsVars = {'notes','frame_of_wing_movement','frame_of_leg_push',...
    'leg_slip','wing_down_stroke','frame_of_take_off'};
manualAnnotationsName = [exptID '_manualAnnotations.mat'];
manualAnnotationsPath = fullfile(exptResultsRefDir,manualAnnotationsName);
if exist(manualAnnotationsPath,'file') == 2
    manualAnnotations_import = load(manualAnnotationsPath);
    dataname = fieldnames(manualAnnotations_import);
    manualAnnotations_import = manualAnnotations_import.(dataname{1});
    if ~isempty(manualAnnotations_import)
        existList = manualAnnotations_import.Properties.RowNames;
        existTest = cellfun(@(x) max(strcmp(existList,x)),videoList);
        newVidList = videoList(~existTest);
        blankData = cell(numel(newVidList),numel(manualAnnotationsVars));
        manualAnnotations2Append = cell2table(blankData,'RowNames',...
            newVidList,'VariableNames',manualAnnotationsVars);
        try
            manualAnnotations = [manualAnnotations_import;manualAnnotations2Append]; %#ok<NASGU>
        catch
            manualAnnotations_import.leg_slip = repmat({[]},height(manualAnnotations_import),1);
            
            label_order = manualAnnotations2Append.Properties.VariableNames;
            [~,iB] = ismember(label_order,manualAnnotations_import.Properties.VariableNames);
            manualAnnotations_import = manualAnnotations_import(:,iB);
            
            manualAnnotations = [manualAnnotations_import;manualAnnotations2Append]; %#ok<NASGU>
            
        end
    end
else
    manualAnnotations = cell2table(cell(numel(videoList),numel(manualAnnotationsVars)),...
        'RowNames',videoList,'VariableNames',manualAnnotationsVars); %#ok<NASGU>
end

%%%%% Load and append graphTable
graphTablePath = fullfile(exptResultsRefDir,[exptID '_dataForVisualization.mat']);
if exist(graphTablePath,'file') == 2
    graphTableLoading = load(graphTablePath);
    graphTable_import = graphTableLoading.graphTable;
    if ~isempty(graphTable_import)
        existList = graphTable_import.Properties.RowNames;
        existTest = cellfun(@(x) max(strcmp(existList,x)),videoList);
        newVidList = videoList(~existTest);
        if ~isempty(newVidList)
            graphTableVars = graphTable_import.Properties.VariableNames;
            blankData = graphTable_import(1,:);
            for iterG = 1:numel(graphTableVars)
                if iscell(blankData.(graphTableVars{iterG}))
                    blankData.(graphTableVars{iterG}){1} = [];
                else
                    blankData.(graphTableVars{iterG}) = blankData.(graphTableVars{iterG})*0;
                end
            end
            graphTable2Append = repmat(blankData,numel(newVidList),1);
            graphTable2Append.Properties.RowNames = newVidList;
            graphTable = [graphTable_import;graphTable2Append]; %#ok<NASGU>
            save(graphTablePath,'graphTable')
        end
    end
end

save(assessmentPath,'assessTable')
save(manualAnnotationsPath,'manualAnnotations')
save(autoAnnotationsPath,'automatedAnnotations')
save(vidInfoMergedPath,'videoStatisticsMerged')
save(exptInfoMergedPath,'experimentInfoMerged')
pez3000_statusAssessment_v2({exptID});

end

function visStimInfo = visStimNidaqAnalyzer(visStimInfo,vidStats)
%visStimNidaqAnalyzer Analyzes nidaq traces in the same way pezControl does
%   Made for use with the makeDataVars function

diodeData2save = visStimInfo.nidaq_data;
if ~isfield(visStimInfo.parameters,'ellovervee')
    strParts = strsplit(visStimInfo.method,'_');
    midNdx = strfind(strParts{2},'to');
    ellovervee = str2double(strParts{3}(3:end));
    initStimSize = str2double(strParts{2}(1:midNdx-1));
    finalStimSize = str2double(strParts{2}(midNdx+2:end));
else
    ellovervee = visStimInfo.parameters.ellovervee;
    initStimSize = visStimInfo.parameters.radius_begin;%in degrees
    finalStimSize = visStimInfo.parameters.radius_end;%in degrees
end
deg2rad = @(x) x*(pi/180);
rad2deg = @(x) x./(pi/180);

minTheta = deg2rad(initStimSize);
maxTheta = deg2rad(finalStimSize);
stimStartTime = ellovervee/tan(minTheta/2);
stimEndTime = ellovervee/tan(maxTheta/2);
stimTotalDuration = stimStartTime-stimEndTime;
stimTimeStep = (1/360)*1000;%milliseconds per frame channel at 120 Hz
stimTimeVector = fliplr(stimEndTime:stimTimeStep:stimStartTime);
stimThetaVector = 2.*atan(ellovervee./stimTimeVector);
stimFrmCt = numel(stimThetaVector);
stimThetaRemainder = round((ceil(stimFrmCt/3)-stimFrmCt/3)*3);
stimThetaVector = [stimThetaVector,...
    repmat(stimThetaVector(end),[1 stimThetaRemainder])];
% visParams.stimThetaVector = stimThetaVector;
stimThetaRefs = reshape(stimThetaVector,3,numel(stimThetaVector)/3);
% The following is done because the projector displays R then B then G
stimThetaRefs = [stimThetaRefs(3,:);stimThetaRefs(1,:);stimThetaRefs(2,:)];
stimThetaRefs = rad2deg(stimThetaRefs);

frmCt = size(stimThetaRefs,2);
stimRefRefs = repmat([1 2]',ceil(frmCt/2),1);
stimRefRefs = stimRefRefs(:);
whiteCt = 0;
for iterPrep = 1:frmCt
    if stimRefRefs(iterPrep) == 1
        whiteCt = whiteCt+2;
    else
        whiteCt = whiteCt+1;
    end
end
visStimInfo.whiteCt = whiteCt;
visStimInfo.parameters.stimulus_duration = stimTotalDuration;

memRate = vidStats.record_rate;
frmCount = vidStats.frame_count;
stimDwellTime = memRate/360;
phBrks = round(linspace(1,frmCount,30));
ranges = zeros(numel(phBrks)-1,1);
means = zeros(numel(phBrks)-1,1);
for iterPh = 1:numel(phBrks)-1
    ranges(iterPh) = iqr(diodeData2save(phBrks(iterPh):phBrks(iterPh+1)));
    means(iterPh) = mean(diodeData2save(phBrks(iterPh):phBrks(iterPh+1)));
end
avgBase = means(min(ranges) == ranges);
avgPeak = means(max(ranges) == ranges);
photoSignalTest = abs((avgPeak-avgBase)/min(ranges));
if photoSignalTest < 10
    diodeDecision = 'signal to noise ratio insufficient';
    visStimInfo.decision = diodeDecision;
    return
else
    dataNorm = abs(diodeData2save-avgBase(1))./max(ranges);
    minPkHt = 0.25;
    pkThresh = 0.5;
    dataNorm(dataNorm > pkThresh) = pkThresh;
    minPkDist = floor(stimDwellTime*1.5);
    [peakVals,peakPos] = findpeaks(dataNorm,'MINPEAKHEIGHT',minPkHt,'MINPEAKDISTANCE',minPkDist);
    visStimInfo.peakPos = peakPos;
    visStimInfo.peakVals = peakVals;
    visStimInfo.normalized_data = dataNorm;
    flipLengths = diff(peakPos);
    peakRange = range(flipLengths);
    if peakRange > 2
        diodeDecision = 'frames were dropped';
        visStimInfo.decision = diodeDecision;
        return
    elseif numel(peakPos) < whiteCt-1
        diodeDecision = 'visual stimulus incomplete';
        visStimInfo.decision = diodeDecision;
        return
    else
        diodeDecision = 'good photodiode';
        visStimInfo.decision = diodeDecision;
    end
end
    
end

function photoStimStruct = photoactivationAnalyzer(photoStimStruct,exptID)
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');

savedPhotostimDir = fullfile(fileDir,'pez3000_variables','photoactivation_stimuli');

nidaqData = photoStimStruct.nidaq_data;
nidaqData = double(nidaqData)./256;
if range(nidaqData) == 0
    photoStimStruct.stimDecision = 'flatLine';
    return
end
nidaqData = abs(nidaqData-max(nidaqData))/range(nidaqData);
rateFactor = photoStimStruct.rateFactor;
frameCt = photoStimStruct.frameCt;

stimOps = photoStimStruct.stimOps;
stimCt = numel(stimOps);
%
pulseOpsX = cell(3,1);
pulseOpsY = cell(3,1);
for iterS = 1:stimCt
    photoStimName = stimOps{iterS};
    nameParts = strsplit(photoStimName,'_');
    methodName = nameParts{1};
    if str2double(exptID(13:16)) < 100
        photoStimStruct.photoStimProtocol = {photoStimName};
        photoStimStruct.photoStimFrameStart = {find(nidaqData > .5,1,'first')};
        photoStimStruct.photoStimFrameCount = {round(2000*(1.028)*rateFactor)};
        if numel(find(nidaqData > .4 & nidaqData < 0.6))/2 > 10
            photoStimStruct.stimDecision = 'Unsure';
        else
            photoStimStruct.stimDecision = 'Good';
        end
        return
    elseif exist(fullfile(savedPhotostimDir,[photoStimName '.mat']),'file')
        load(fullfile(savedPhotostimDir,[photoStimName '.mat']))
    elseif exist(fullfile(savedPhotostimDir,'photoactivation_archive',[photoStimName '.mat']),'file')
        load(fullfile(savedPhotostimDir,'photoactivation_archive',[photoStimName '.mat']))
    else
        if strcmp('pulse',methodName)
            var_pul_width_begin = str2double(nameParts{3}(numel('widthBegin')+1:end));
            var_pul_width_end = str2double(nameParts{4}(numel('widthEnd')+1:end));
            var_pul_count = str2double(nameParts{5}(numel('cycles')+1:end));
            var_intensity = str2double(nameParts{6}(numel('intensity')+1:end));
            if var_pul_count == 1
                if strcmp(photoStimName,'pulse_Namikis_width1000_period1000_cycles1_intensity2')
                    var_pul_width_begin = 1000;
                    var_pul_width_end = 1000;
                    var_pul_count = 1;
                    var_intensity = 2;
                    var_tot_dur = var_pul_width_begin;
                else
                    var_tot_dur = var_pul_width_begin;
                end
            elseif strcmp(photoStimName,'pulse_General_widthBegin5_widthEnd150_cycles5_intensity30')
                var_tot_dur = 1000;
            elseif strcmp(photoStimName,'pulse_Williamsonw_widthBegin5_widthEnd75_cycles5_intensity30')
                var_tot_dur = 500;
            else
                var_tot_dur = 500;
            end
        elseif strcmp('ramp',methodName)
            var_ramp_width = str2double(nameParts{3}(numel('rampWidth')+1:end));
            var_tot_dur = str2double(nameParts{6}(numel('totalDur')+1:end));
            var_ramp_init = str2double(nameParts{4}(numel('initVal')+1:end));
            var_intensity = str2double(nameParts{5}(numel('finalVal')+1:end));
        elseif strcmp('combo',methodName)
            var_pul_width_begin = str2double(nameParts{3}(numel('pulseWidthBegin')+1:end));
            var_pul_width_end = str2double(nameParts{4}(numel('pulseWidthEnd')+1:end));
            var_pul_count = str2double(nameParts{5}(numel('cycles')+1:end));
            var_ramp_width = str2double(nameParts{6}(numel('rampWidth')+1:end));
            var_tot_dur = str2double(nameParts{9}(numel('totalDur')+1:end));
            var_ramp_init = str2double(nameParts{7}(numel('initVal')+1:end));
            var_intensity = str2double(nameParts{8}(numel('finalVal')+1:end));
        elseif strcmp('Alternating',methodName)
            photoStimStruct.stimDecision = 'Unsure';
            return
        else
            error('invalid name')
        end
    end
    
    oldProtocols = {'pulse_Testing_widthBegin5_widthEnd150_period150_cycles6_intensity20'
        'pulse_Testing_widthBegin5_widthEnd150_period150_cycles6_intensity30'
        'pulse_Testing_widthBegin5_widthEnd150_period150_cycles6_intensity40'
        'combo_Testing_pulseWidth5_period150_cycles6_rampWidth800_initVal5_finalVal50_totalDur900'
        'combo_Testing_pulseWidth100_period150_cycles6_rampWidth800_initVal5_finalVal50_totalDur900'
        'combo_Testing_pulseWidth25_period150_cycles6_rampWidth800_initVal5_finalVal50_totalDur900'};
    if max(strcmp(oldProtocols,photoStimName))
        photoStimStruct.photoStimProtocol = {photoStimName};
        photoStimStruct.photoStimFrameStart = {find(nidaqData > .5,1,'first')};
        if ~exist('var_tot_dur','var')
            var_tot_dur = 900;
        end
        photoStimStruct.photoStimFrameCount = {round(var_tot_dur*(1.028)*rateFactor)};
        if numel(find(nidaqData > .4 & nidaqData < 0.6))/2 > 10
            photoStimStruct.stimDecision = 'Unsure';
        else
            photoStimStruct.stimDecision = 'Good';
        end
        return
    end

    if strcmp('ramp',methodName)
        pulseGui_x = (1:var_tot_dur);
        var_slope = (var_ramp_init-var_intensity)/(0-var_ramp_width);
        pulseGui_y = var_slope.*pulseGui_x+var_ramp_init;
    else
        if exist('var_pul_count','var')
            cycles = var_pul_count;
        else
            cycles = str2double(photoStimName(strfind(photoStimName,'cycles')+numel('cycles')));
        end
        xA = linspace(var_pul_width_begin,var_pul_width_end,cycles);
        if cycles == 1
            xOff = 0;
        else
            xOff = (var_tot_dur-sum(xA))/(cycles-1);
        end
        if xOff < 0
            xOff = 0;
        end
        xB = zeros(1,cycles)+xOff;
        xC = [xB;xA];
        xC = repmat(cumsum(xC(:)),1,2)'-xOff;
        pulseGui_x = round(xC(:));
        
        yA = repmat([0;var_intensity;var_intensity;0],1,cycles);
        if strcmp('combo',methodName)
            var_slope = (var_ramp_init-var_intensity)/(0-var_ramp_width);
            yA(2,:) = var_slope.*xB(2,:)+var_ramp_init;
            yA(3,:) = yA(2,:);
            yA(yA > var_intensity) = var_intensity;
        end
        pulseGui_y = round(yA(:));
        if max(pulseGui_x > var_tot_dur)
            pulseGui_y(pulseGui_x >= var_tot_dur) = [];
            pulseGui_x(pulseGui_x >= var_tot_dur) = [];
            pulseGui_xB = [pulseGui_x;var_tot_dur;var_tot_dur];
            pulseGui_yB = [pulseGui_y;var_intensity;0];
            pulseGui_x = pulseGui_xB;
            pulseGui_y = pulseGui_yB;
        end
        pulseRef = (2:2:numel(pulseGui_x));
        pulseGui_xPart = pulseGui_x(pulseRef);
        pulseGui_yPart = pulseGui_y(pulseRef);
        pulseGui_x = (1:var_tot_dur);
        pulseGui_y = zeros(1,var_tot_dur);
        for iterP = 1:numel(pulseRef)-1
            xrefA = pulseGui_xPart(iterP);
            xrefB = pulseGui_xPart(iterP+1);
            pulseGui_y(xrefA+1:xrefB) = pulseGui_yPart(iterP);
        end
    end
    
    %         plot(pulseGui_x,pulseGui_y,'-r','LineWidth', 1);
    %         set(gca,'yLim',[-1 101],'xLim',[-1 var_tot_dur])
    pulseOpsX{iterS} = pulseGui_x;
    pulseOpsY{iterS} = pulseGui_y;
end

maxVals = zeros(3,1);
valRefs = zeros(3,1);
for iterS = 1:stimCt
%     pulseGui_xReal = round(pulseOpsX{iterS}*(1.028)*rateFactor);
    pulseGui_xReal = (pulseOpsX{iterS}*(1.028)*rateFactor);
    video_x = (1:max(pulseGui_xReal));
    
    video_pulse = interp1(pulseGui_xReal,pulseOpsY{iterS},video_x,'nearest','extrap');
    video_pulse = video_pulse/max(video_pulse);
    video_pulse(video_pulse < 0) = 0;
    compareVec = video_pulse;
    compareVec(frameCt) = 0;
    compareVec = [zeros(frameCt,1);compareVec(:);zeros(frameCt,1)];
    [cvals,clags] = xcorr(zscore(compareVec),zscore(nidaqData));
    [cmax,cref] = max(abs(cvals));
    maxVals(iterS) = cmax;
    valRefs(iterS) = clags(cref(1));
end
[~,crefMax] = max(maxVals);
crefMax = crefMax(1);
stimStart = frameCt-valRefs(crefMax);

stimFail = 0;

% pulseGui_xReal = round(pulseOpsX{crefMax}*(1.028)*rateFactor);
pulseGui_xReal = (pulseOpsX{crefMax}*(1.028)*rateFactor);
video_x = (1:max(pulseGui_xReal));
pulse_length = max(video_x);%%%%%% Real pulse length
if stimStart < -round(pulse_length/2)
    stimFail = 1;
else
    video_pulse = interp1(pulseGui_xReal,pulseOpsY{crefMax},video_x,'linear','extrap');
    video_pulse = video_pulse/max(video_pulse);
    video_pulse(video_pulse < 0) = 0;
    if stimStart < 1
        video_pulse(1:abs(stimStart)) = [];
    else
        video_pulse = [zeros(stimStart,1);video_pulse(:)];
    end
    if numel(video_pulse) > frameCt
        stimFail = 1;
    else
        video_pulse(frameCt) = 0;
        corrVal = corrcoef(nidaqData,video_pulse);
        if corrVal(2) < 0.8
            stimFail = 1;
        end
    end
end
if ~stimFail
    photoStimStruct.photoStimProtocol = stimOps(crefMax);
    photoStimStruct.photoStimFrameStart = {stimStart};
    photoStimStruct.photoStimFrameCount = {pulse_length};
    photoStimStruct.stimDecision = 'Good';
else
    photoStimStruct.stimDecision = 'Unsure';
    %     if rateFactor == .25
%     plot(nidaqData)
%     hold all
%     plot((1:numel(video_pulse)),video_pulse)
%     hold off
%     uiwait(gcf,2)
%     close(gcf)
    %     end
end

end


