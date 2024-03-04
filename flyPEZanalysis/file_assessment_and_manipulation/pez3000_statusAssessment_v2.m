function pez3000_statusAssessment_v2(exptIDlist)
%pez3000_statusAssessment Updates raw data assessment after tracking
%   This function queries the locator, tracking, and analyzed data folders
%   and updates the status column of the raw data assessment table.  It
%   also updates the experimentSummary variable, making it anew if unfound.
%   If no input list of cellstrings containing experiment IDs is given, all
%   experiment IDs found in the analysis directory are assessed.

%% %%% computer and directory variables and information
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');

analysisDir = fullfile(fileDir,'Data_pez3000_analyzed');
if ~exist('exptIDlist','var')
    exptIDlist = dir(analysisDir);
    exptIDexist = cell2mat({exptIDlist(:).isdir});
    exptIDlengthTest = cellfun(@(x) numel(x) == 16,{exptIDlist(:).name});
    exptIDlist = {exptIDlist(min(exptIDexist,exptIDlengthTest)).name};
    exptIDlist = flipud(exptIDlist(:));
end
exptCt = numel(exptIDlist);
%%
exptSumName = 'experimentSummary.mat';
exptSumBU = 'experimentSummary_backup.mat';
exptSumPath = fullfile(analysisDir,exptSumName);
exptSumPathBU = fullfile(analysisDir,exptSumBU);
exptTableCell = exptIDlist;
if exist(exptSumPath,'file') && nargin == 1
    for iterLoad = 1:5
        try
            experimentSummary_import = load(exptSumPath);
            experimentSummary_import = experimentSummary_import.experimentSummary;
            importNames = experimentSummary_import.Properties.RowNames;
            existingExpts = intersect(importNames,exptIDlist,'stable');
            for iterS = 1:exptCt
                exptID = exptTableCell{iterS};
                if max(strcmp(importNames,exptID))
                    exptTableCell{iterS} = experimentSummary_import(exptID,:);
                end
            end
            experimentSummary_import(existingExpts,:) = [];
            break
        catch
            if iterLoad == 5
                error('loading failure: experiment summary file is corrupted')
            end
            pause(1)
        end
    end
else
    experimentSummary_import = [];
end

parfor iterE = 1:exptCt
    try
        experimentSummaryLoc = exptTableCell{iterE};
        experimentSummaryLoc = getExptInfo(experimentSummaryLoc,analysisDir);
        exptTableCell{iterE} = experimentSummaryLoc;
    catch ME
        if ischar(experimentSummaryLoc)
            exptID = experimentSummaryLoc;
        else
            exptID = experimentSummaryLoc.Properties.RowNames;
            exptID = exptID{1};
        end
        report = getReport(ME);
        disp([exptID ': ' report])
    end
end

experimentSummary = cat(1,exptTableCell{:});
experimentSummary = cat(1,experimentSummary_import,experimentSummary); %#ok<NASGU>
save(exptSumPath,'experimentSummary','-v7.3')
save(exptSumPathBU,'experimentSummary','-v7.3')


end

function experimentSummaryLoc = getExptInfo(experimentSummaryLoc,analysisDir)
makeNewTable = false;

if ischar(experimentSummaryLoc)
    exptID = experimentSummaryLoc;
    makeNewTable = true;
    
    %%%%% Making blank table
    exptSumVarNames = {'Total_Raw_Failed','Total_Videos','Total_Curated','Total_Passing',...
        'Failed2locate','Failed2track','Failed2analyze',...
        'Analysis_Complete','Total_Jumping','Total_Manual_Annotations','Run_Count',...
        'Stim_Info','Stim_Duration','First_Date_Run','Median_Date_Run','Last_Date_Run',...
        'Experiment_Type','UserID','Status','Synonyms','Parent_Info'};
    
    experimentSummaryLoc = table(0,0,0,0,0,0,0,0,0,0,0,{''},0,{''},{''},...
        {''},{''},{''},{''},{'None'},{''},'RowNames',{exptID},...
        'VariableNames',exptSumVarNames);
    
    Frame_Count = NaN;
    Frame_Width = NaN;
    Frame_Height = NaN;
    Record_Rate = NaN;
    Vis_Stim_Type = {''};
    Elevation = NaN;
    Azimuth = NaN;
    Start_Size = NaN;
    Stop_Size = NaN;
    LV = NaN;
    Contrast = {''};
    Bar_Width = NaN;
    Bar_Freq = NaN;
    Activation1 = {'None'};
    Activation2 = {'None'};
    Activation3 = {'None'};
    incubatorVars = {'Name','Location','LightsOn','LightsOff','Temperature','Humidity'};
    
    stimTable = table(Frame_Count,Frame_Width,Frame_Height,Record_Rate,...
        Vis_Stim_Type,Elevation,Azimuth,Start_Size,Stop_Size,LV,Contrast,...
        Bar_Width,Bar_Freq,Activation1,Activation2,Activation3,'RowNames',{exptID});
    exptInfoCopyVars = {'Collection_Name','Collection_Description',...
        'User_ID','ParentA_name','ParentA_ID','ParentA_genotype','ParentB_name',...
        'ParentB_ID','ParentB_genotype','Males','Females','No_Balancers',...
        'Chromosome1','Chromosome2','Chromosome3','Food_Type','Foiled',...
        'Compression_Opts','Download_Opts','Trigger_Type',...
        'Time_Before','Time_After','Room_Temp'};
    addlVars = cat(1,exptInfoCopyVars(:),incubatorVars(:));
    table2append = cell2table(cell(1,numel(addlVars)),'RowNames',{exptID},...
        'VariableNames',addlVars);
    experimentSummaryLoc = cat(2,experimentSummaryLoc,stimTable,table2append);
else
    exptID = experimentSummaryLoc.Properties.RowNames;
    exptID = exptID{1};
end


%%%%% Checking for table availability and consistency
expt_results_dir = fullfile(analysisDir,exptID);
assessmentName = [exptID '_rawDataAssessment.mat'];
assessmentPath = fullfile(expt_results_dir,assessmentName);
if ~exist(assessmentPath,'file')
    experimentSummaryLoc.Status = {'no_assessTable'};
    return
end
assessTable_import = load(assessmentPath);

dataname = fieldnames(assessTable_import);
assessTable = assessTable_import.(dataname{1});
assessNames = assessTable.Properties.RowNames;

masterList = assessNames;
vidCt = numel(masterList);
if ~max(strcmp(assessTable.Properties.VariableNames,'Final_Status'))
    assessTable.Final_Status = cell(vidCt,1);
end

autoAnnoName = [exptID '_automatedAnnotations.mat'];
autoAnnotationsPath = fullfile(expt_results_dir,autoAnnoName);
if ~exist(autoAnnotationsPath,'file')
    experimentSummaryLoc.Status = {'no_auto_anno'};
    return
end
autoAnnoTable_import = load(autoAnnotationsPath);
dataname = fieldnames(autoAnnoTable_import);
automatedAnnotations = autoAnnoTable_import.(dataname{1});
masterList = intersect(masterList,automatedAnnotations.Properties.RowNames);
totalJumping = sum(cellfun(@(x) ~isempty(x) && x == 1,automatedAnnotations.jumpTest(masterList)));
experimentSummaryLoc.Total_Jumping(exptID) = totalJumping;

manAnnoName = [exptID '_manualAnnotations.mat'];
manAnnotationsPath = fullfile(expt_results_dir,manAnnoName);
if ~exist(manAnnotationsPath,'file')
    experimentSummaryLoc.Status = {'no_man_anno'};
    return
end
manAnnoTable_import = load(manAnnotationsPath);
dataname = fieldnames(manAnnoTable_import);
manualAnnotations = manAnnoTable_import.(dataname{1});
masterList = intersect(masterList,manualAnnotations.Properties.RowNames);
manFot = manualAnnotations.frame_of_take_off(masterList);
manTest = cellfun(@(x) ~isempty(x) && ~isnan(x) && x > 0,manFot);
%     manTest = manTest & cellfun(@(x) ~isnan(x),manFot);
%     manTest = manTest & cellfun(@(x) x > 0,manFot);
experimentSummaryLoc.Total_Manual_Annotations(exptID) = sum(manTest);



vidStatsName = [exptID '_videoStatisticsMerged.mat'];
vidStatsPath = fullfile(expt_results_dir,vidStatsName);
if ~exist(vidStatsPath,'file')
    experimentSummaryLoc.Status = {'no_vid_stats'};
    return
end
vidStatsLoading = load(vidStatsPath);
if isempty(fields(vidStatsLoading))
    experimentSummaryLoc.Status = {'empty_vid_stats'};
    return
end
dataname = fieldnames(vidStatsLoading);
videoStatisticsMerged = vidStatsLoading.(dataname{1});
masterList = intersect(masterList,get(videoStatisticsMerged,'ObsNames'));
vidStats = videoStatisticsMerged(1,:);


experimentSummaryLoc.Total_Videos(exptID) = vidCt;

exptInfoMergedName = [exptID '_experimentInfoMerged.mat'];
exptInfoMergedPath = fullfile(expt_results_dir,exptInfoMergedName);
if ~exist(exptInfoMergedPath,'file')
    experimentSummaryLoc.Status = {'no_expt_info'};
    return
end
experimentInfoLoading = load(exptInfoMergedPath,'experimentInfoMerged');
experimentInfoMerged = experimentInfoLoading.experimentInfoMerged;
experimentSummaryLoc.Run_Count(exptID) = size(experimentInfoMerged,1);
runList = get(experimentInfoMerged,'ObsNames');
dateList = unique(cellfun(@(x) x(end-7:end),runList,'uniformoutput',false));
dateNumList = cell2mat(cellfun(@(x) datenum((x),'yyyymmdd'),dateList,'uniformoutput',false));
minDate = datestr(min(dateNumList),'yyyymmdd');
maxDate = datestr(max(dateNumList),'yyyymmdd');
medianDate = datestr(round(median(dateNumList)),'yyyymmdd');
experimentSummaryLoc.First_Date_Run{exptID} = minDate;
experimentSummaryLoc.Last_Date_Run{exptID} = maxDate;
experimentSummaryLoc.Median_Date_Run{exptID} = medianDate;
exptInfo = experimentInfoMerged(1,:);

%%%%%%%%%%%%%%%%%%%%%% THINGS THAT CAN CHANGE %%%%%%%%%%%%%%%%%%%%%%%%%%
analyzer_name = 'flyAnalyzer3000_v14';
analyzer_data_dir = fullfile(expt_results_dir,[exptID '_' analyzer_name]);
for iterV = 1:numel(assessNames)
    videoID = assessNames{iterV};
    strParts = strsplit(videoID,'_');
    runID = [strParts{1} '_' strParts{2} '_' strParts{3}];
    if ~max(strcmp(runList,runID))
        assessTable.Final_Status(videoID) = {'runID from video not found'};
        assessTable.Analysis_Status(videoID) = {'Other'};
    elseif ~max(strcmp(masterList,videoID))
        assessTable.Final_Status(videoID) = {'missing from another table'};
        assessTable.Analysis_Status(videoID) = {'Ignore'};
    elseif strcmp(assessTable.Raw_Data_Decision{videoID},'Fail')
        assessTable.Analysis_Status(videoID) = {'Raw data fail'};
        assessTable.Final_Status(videoID) = {'Raw data fail'};
    else
        analyzer_expt_ID = [videoID '_' analyzer_name '_data.mat'];%experiment ID
        analyzer_data_path = fullfile(analyzer_data_dir,analyzer_expt_ID);
        %%%% Analyzer table
        if exist(analyzer_data_path,'file') == 2
            analysis_data_import = load(analyzer_data_path);
            dataname = fieldnames(analysis_data_import);
            analysis_record = analysis_data_import.(dataname{1});
            analyzer_outcome = analysis_record.final_outcome{1};
            assessTable.Final_Status{videoID} = analyzer_outcome;
            if max(strcmp({'no locator file','locator could not find fly'},analyzer_outcome))
                assessTable.Analysis_Status(videoID) = {'Failed to locate'};
            elseif max(strcmp({'no tracking file','tracking too short','no movement detected'},analyzer_outcome))
                assessTable.Analysis_Status(videoID) = {'Failed to track'};
            else
                assessTable.Analysis_Status(videoID) = {'Analysis complete'};
            end
        else
%             assessTable.Analysis_Status(videoID) = {'Analysis scheduled'};
        end
    end
end
save(assessmentPath,'assessTable')

%%%%% Update experiment summary variable
totNdcs = strcmp(assessTable.Analysis_Status,'Raw data fail');
experimentSummaryLoc.Total_Raw_Failed(exptID) = sum(totNdcs);
experimentSummaryLoc.Total_Videos(exptID) = vidCt;
totNdcs = strcmp(assessTable.Curation_Status,'Saved');
experimentSummaryLoc.Total_Curated(exptID) = sum(totNdcs);
totNdcs = strcmp(assessTable.Raw_Data_Decision,'Pass');
experimentSummaryLoc.Total_Passing(exptID) = sum(totNdcs);
totNdcs = strcmp(assessTable.Analysis_Status,'Analysis complete');
experimentSummaryLoc.Analysis_Complete(exptID) = sum(totNdcs);
totNdcs = strcmp(assessTable.Analysis_Status,'Failed to locate');
experimentSummaryLoc.Failed2locate(exptID) = sum(totNdcs);
totNdcs = strcmp(assessTable.Analysis_Status,'Failed to track');
experimentSummaryLoc.Failed2track(exptID) = sum(totNdcs);
totNdcs = strcmp(assessTable.Analysis_Status,'Failed to analyze');
experimentSummaryLoc.Failed2analyze(exptID) = sum(totNdcs);


%%%%%%%%%%%%%%%%%%%%%% THINGS THAT WONT CHANGE %%%%%%%%%%%%%%%%%%%%%%%%%%
if ~makeNewTable
    return
end

%%%%% Video-related
experimentSummaryLoc.Frame_Count(exptID) = double(vidStats.frame_count(1));
experimentSummaryLoc.Frame_Width(exptID) = double(vidStats.frame_width(1));
experimentSummaryLoc.Frame_Height(exptID) = double(vidStats.frame_height(1));
experimentSummaryLoc.Record_Rate(exptID) = double(vidStats.record_rate(1));

%%%%% Stimulus information
stimStr = '';
stim_dur = NaN;
Vis_Stim_Type = exptInfo.Stimuli_Type{1};
visStimTest = false;
if ~strcmp('None',Vis_Stim_Type)
    if ~strcmp('Template_making',Vis_Stim_Type)
        visStimTest = true;
    end
end
activationStrCell = exptInfo.Photo_Activation{1};
if ischar(activationStrCell)
    activationStrCell = {activationStrCell};
end
if ~strcmp('None',activationStrCell{1})
    photoStimTest = true;
else
    photoStimTest = false;
end
if photoStimTest && visStimTest
    exptType = 'Combo';
elseif photoStimTest
    exptType = 'Photoactivation';
elseif visStimTest
    exptType = 'Visual_stimulation';
elseif strcmp('Template_making',Vis_Stim_Type)
    exptType = 'Template_making';
elseif strcmp('None',Vis_Stim_Type) && strcmp('None',activationStrCell{1})
    exptType = 'None';
else
    exptType = 'Unknown';
end
if strcmp(exptType,'Visual_stimulation')
    stimStr = [exptInfo.Stimuli_Type{1} '_ele' exptInfo.Stimuli_Vars(1).Elevation,...
        '_azi' exptInfo.Stimuli_Vars(1).Azimuth];
    stim_dur = automatedAnnotations.visStimFrameCount{1};
elseif strcmp(exptType,'Photoactivation')
    stimStr = automatedAnnotations.photoStimProtocol{1};
    stim_dur = automatedAnnotations.photoStimFrameCount{1};
elseif strcmp(exptType,'Combo')
    stimStr = 'combo';
    stim_dur = automatedAnnotations.visStimFrameCount{1};
elseif max(strcmp({'None','Template_making'},exptType))
    stimStr = 'no or unknown visual stimulus';
    stim_dur = experimentSummaryLoc.Frame_Count(exptID);
end
if isempty(stim_dur)
    stim_dur = NaN;
end
if isempty(stimStr)
    stimStr = '';
end
experimentSummaryLoc.Stim_Duration(exptID) = stim_dur;
experimentSummaryLoc.Stim_Info{exptID} = stimStr;
if strcmp('Visual_stimulation',exptType) || strcmp('Combo',exptType)
    stimInfo = exptInfo.Stimuli_Type{1};
    splitCell = strsplit(stimInfo,'_');
    if strcmp(splitCell{1},'loom')
        experimentSummaryLoc.Vis_Stim_Type(exptID) = splitCell(1);
        experimentSummaryLoc.Elevation(exptID) = str2double(exptInfo.Stimuli_Vars.Elevation);
        experimentSummaryLoc.Azimuth(exptID) = str2double(exptInfo.Stimuli_Vars.Azimuth);
        experimentSummaryLoc.LV(exptID) = str2double(splitCell{3}(strfind(splitCell{3},'lv')+2:end));
        experimentSummaryLoc.Start_Size(exptID) = str2double(splitCell{2}(1:strfind(splitCell{2},'to')-1));
        experimentSummaryLoc.Stop_Size(exptID) = str2double(splitCell{2}(strfind(splitCell{2},'to')+2:end));
        experimentSummaryLoc.Contrast(exptID) = splitCell(end);
    elseif strcmp(splitCell{1},'constSize')
        experimentSummaryLoc.Vis_Stim_Type(exptID) = splitCell(1);
        experimentSummaryLoc.Elevation(exptID) = str2double(exptInfo.Stimuli_Vars.Elevation);
        experimentSummaryLoc.Azimuth(exptID) = str2double(exptInfo.Stimuli_Vars.Azimuth);
        experimentSummaryLoc.Start_Size(exptID) = str2double(splitCell(2));
        experimentSummaryLoc.Contrast(exptID) = splitCell(end);
    elseif ~isempty(strfind(splitCell{1},'grating'))
        experimentSummaryLoc.Vis_Stim_Type(exptID) = {'grating'};
        experimentSummaryLoc.Elevation(exptID) = str2double(exptInfo.Stimuli_Vars.Elevation);
        experimentSummaryLoc.Azimuth(exptID) = str2double(exptInfo.Stimuli_Vars.Azimuth);
        experimentSummaryLoc.Bar_Width(exptID) = str2double(splitCell{2}(1:strfind(splitCell{2},'deg')-1));
        experimentSummaryLoc.Bar_Freq(exptID) = str2double(regexprep(splitCell{3}(1:strfind(splitCell{3},'Hz')-1),'p','.'));
        experimentSummaryLoc.Contrast(exptID) = splitCell(end);
    end
end
if strcmp('Photoactivation',exptType) || strcmp('Combo',exptType)
    if ~iscell(exptInfo.Photo_Activation{1})
        exptInfo.Photo_Activation = {exptInfo.Photo_Activation};
    end
    for iterS = 1:numel(exptInfo.Photo_Activation{1})
        experimentSummaryLoc.(['Activation' num2str(iterS)])(exptID) = exptInfo.Photo_Activation{1}(iterS);
    end
end

%%%%% Additional useful info
Incubator_Info = exptInfo.Incubator_Info;
for iterInc = 1:numel(incubatorVars)
    if ~max(strcmp(fieldnames(Incubator_Info),incubatorVars{iterInc}))
        addlInfo = 'no info';
    else
        addlInfo = Incubator_Info.(incubatorVars{iterInc});
        if ischar(addlInfo) && isempty(deblank(addlInfo))
            addlInfo = 'None';
        end
    end
    experimentSummaryLoc.(incubatorVars{iterInc})(exptID) = {addlInfo};
end
parentInfo = sort([exptInfo.ParentA_name(1) exptInfo.ParentB_name(1)]);
parentInfo = cat(2,parentInfo{1},'_cross2_',parentInfo{2});
experimentSummaryLoc.Parent_Info{exptID} = parentInfo;
experimentSummaryLoc.Experiment_Type{exptID} = exptType;
experimentSummaryLoc.UserID(exptID) = exptInfo.User_ID;
for iterAddl = 1:numel(exptInfoCopyVars)
    if ~max(strcmp(get(exptInfo,'VarNames'),exptInfoCopyVars{iterAddl}))
        addlInfo = 'no info';
    else
        addlInfo = exptInfo.(exptInfoCopyVars{iterAddl});
        while iscell(addlInfo)
            addlInfo = addlInfo{1};
        end
        if ischar(addlInfo) && isempty(deblank(addlInfo))
            addlInfo = 'None';
        end
    end
    experimentSummaryLoc.(exptInfoCopyVars{iterAddl})(exptID) = {addlInfo};
end
end
