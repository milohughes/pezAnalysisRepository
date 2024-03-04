function pez3000_exptID_correction

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
analysisDir = fullfile(dm11Dir,'Data_pez3000_analyzed');
rawDataDir = fullfile(archDir,'data_Pez3000');
mistakesName = 'runCorrections_20140803';
% mistakesName = 'runCorrections_20140821';
mistakesPath = fullfile(analysisDir,'runCorrections',[mistakesName '.txt']);
mistakesTable = readtable(mistakesPath,'Delimiter',',');
for iterEX = 1:size(mistakesTable,1)
    exptID_fixer_upper(mistakesTable(iterEX,:),rawDataDir,analysisDir)
end
end
function exptID_fixer_upper(mistakesTable,rawDataDir,analysisDir)
runID = mistakesTable.run{1};
strParts = strsplit(runID,'_');
dateID = strParts{3};
runDir = fullfile(rawDataDir,dateID,runID);

exptID_wrong = sprintf('%016s',num2str(mistakesTable.wrongID));
exptID_right = sprintf('%016s',num2str(mistakesTable.rightID));

%% Fixing the original data folder
vidList = dir(fullfile(runDir,'*.mp4'));
vidList = {vidList(:).name}';
vidPaths_wrong = cellfun(@(x) fullfile(runDir,x),vidList,'uniformoutput',false);
vidList = cellfun(@(x) regexprep(x,exptID_wrong,exptID_right),vidList,'uniformoutput',false);
vidPaths_right = cellfun(@(x) fullfile(runDir,x),vidList,'uniformoutput',false);
wrongPathTest = cellfun(@(x) ~exist(x,'file'),vidPaths_right);
%%%% Changing the name of the videos
cellfun(@(x,y) movefile(x,y),vidPaths_wrong(wrongPathTest),vidPaths_right(wrongPathTest))

runStatsPath = fullfile(runDir,[runID '_runStatistics.mat']);
load(runStatsPath)
runStats.experimentID = exptID_right;
%%%% Saving new run stats
save(runStatsPath,'runStats')

vidStatsPath = fullfile(runDir,[runID '_videoStatistics.mat']);
load(vidStatsPath)
obsNames = get(vidStats,'ObsNames');
obsNames = cellfun(@(x) regexprep(x,exptID_wrong,exptID_right),obsNames,'uniformoutput',false);
vidStats = set(vidStats,'ObsNames',obsNames);
%%%% Saving new vid stats
save(vidStatsPath,'vidStats')

exptInfoPath = fullfile(runDir,[runID '_experimentIDinfo.mat']);
load(exptInfoPath)
if str2double(exptID_right(13:16)) < 100
    [~,exptInfo_right] = parse_expid(exptID_right);
else
    exptInfo_right = parse_expid_v2(exptID_right);
end
rightVars = get(exptInfo_right,'VarNames');
origVars = get(exptInfo,'VarNames');
addedFields = cellfun(@(x) ~max(strcmp(rightVars,x)),origVars);
exptInfo = set(exptInfo,'ObsNames',{exptID_right});
exptInfo_right = cat(2,exptInfo_right,exptInfo(:,addedFields));
exptInfo = exptInfo_right;
%%%% Saving new expt info
save(exptInfoPath,'exptInfo')

autoAnalysisPath = fullfile(runDir,'inspectionResults',[runID '_autoAnalysisResults.mat']);
load(autoAnalysisPath)
obsNames = get(autoResults,'ObsNames');
obsNames = cellfun(@(x) regexprep(x,exptID_wrong,exptID_right),obsNames,'uniformoutput',false);
autoResults = set(autoResults,'ObsNames',obsNames);
%%%% Saving new inspection results dataset
save(autoAnalysisPath,'autoResults')

vidList = dir(fullfile(runDir,'highSpeedSupplement','*.mp4'));
vidList = {vidList(:).name}';
vidPaths_wrong = cellfun(@(x) fullfile(runDir,'highSpeedSupplement',x),vidList,'uniformoutput',false);
vidList = cellfun(@(x) regexprep(x,exptID_wrong,exptID_right),vidList,'uniformoutput',false);
vidPaths_right = cellfun(@(x) fullfile(runDir,'highSpeedSupplement',x),vidList,'uniformoutput',false);
wrongPathTest = cellfun(@(x) ~exist(x,'file'),vidPaths_right);
%%%% Changing the name of the videos
cellfun(@(x,y) movefile(x,y),vidPaths_wrong(wrongPathTest),vidPaths_right(wrongPathTest))
%% Fixing the analyzed data folder.  Raw data assessment first

exptResultsRefDir_wrong = fullfile(analysisDir,exptID_wrong);
if ~isdir(exptResultsRefDir_wrong), mkdir(exptResultsRefDir_wrong), end
exptResultsRefDir_right = fullfile(analysisDir,exptID_right);
if ~isdir(exptResultsRefDir_right), mkdir(exptResultsRefDir_right), end

assessmentName_wrong = [exptID_wrong '_rawDataAssessment.mat'];
assessmentPath_wrong = fullfile(exptResultsRefDir_wrong,assessmentName_wrong);
if exist(assessmentPath_wrong,'file') == 2
    assessTable_import = load(assessmentPath_wrong);
    dataname = fieldnames(assessTable_import);
    assessTable = assessTable_import.(dataname{1});
else
    disp(['no assessment for wrong ID: ' exptID_wrong])
end
assessNames = assessTable.Properties.RowNames;
badIDs = cellfun(@(x) ~isempty(x),strfind(assessNames,runID));
assessPart2move = assessTable(badIDs,:);
assessTable = assessTable(~badIDs,:);
% saving table which had bad IDs
save(assessmentPath_wrong,'assessTable')

if ~isempty(assessPart2move)
    badNames = assessPart2move.Properties.RowNames;
    goodNames = cellfun(@(x) regexprep(x,exptID_wrong,exptID_right),badNames,'uniformoutput',false);
    assessPart2move.Properties.RowNames = goodNames;
    assessPart2move.Video_Path = cellfun(@(x) regexprep(x,exptID_wrong,exptID_right),...
        assessPart2move.Video_Path,'uniformoutput',false);
    assessmentName_right = [exptID_right '_rawDataAssessment.mat'];
    assessmentPath_right = fullfile(exptResultsRefDir_right,assessmentName_right);
    if exist(assessmentPath_right,'file') == 2
        assessTable_import = load(assessmentPath_right);
        dataname = fieldnames(assessTable_import);
        assessTable = assessTable_import.(dataname{1});
        assessTable = cat(1,assessTable,assessPart2move);
    else
        disp(['no assessment for right ID: ' exptID_right])
        assessTable = assessPart2move;
    end
    % saving table which has correct IDs
    save(assessmentPath_right,'assessTable')
end

% assessmentName_right = [exptID_wrong '_rawDataAssessment.mat'];
% assessmentPath_right = fullfile(exptResultsRefDir_right,assessmentName_right);
% if exist(assessmentPath_right,'file')
%     load(assessmentPath_right)
%     assessPart2move = assessTable;
%     
%     assessmentName_right = [exptID_right '_rawDataAssessment.mat'];
%     assessmentPath_rightB = fullfile(exptResultsRefDir_right,assessmentName_right);
%     if exist(assessmentPath_rightB,'file')
%         load(assessmentPath_rightB)
%         assessNames = assessTable.Properties.RowNames;
%         rightIDs = cellfun(@(x) ~isempty(x),strfind(assessNames,runID));
%         if sum(rightIDs) ~= size(assessPart2move,1)
%             names2remove = cellfun(@(x) max(strcmp(assessPart2move.Properties.RowNames,x)),assessNames);
%             assessTable(names2remove,:) = [];
%             assessTable = cat(1,assessTable,assessPart2move);
%             save(assessmentPath_rightB,'assessTable')
%         else
%             assessmentName_right = [exptID_wrong '_rawDataAssessment.mat'];
%             assessmentPath_right = fullfile(exptResultsRefDir_right,assessmentName_right);
%             if exist(assessmentPath_right,'file')
%                 delete(assessmentPath_right)
%             end
%         end
%     else
%         movefile(assessmentPath_right,assessmentPath_rightB)
%     end
% end
%% Moving background frames and montages
montyDir_wrong = fullfile(exptResultsRefDir_wrong,'montageFrames');
montyList = dir(fullfile(montyDir_wrong,'*.tif'));
montyList = {montyList(:).name}';
montyList = montyList(cellfun(@(x) ~isempty(x),strfind(montyList,runID)));
montyWrongPath = cellfun(@(x) fullfile(montyDir_wrong,x),montyList,'uniformoutput',false);
montyRightPath = cellfun(@(x) regexprep(x,exptID_wrong,exptID_right),montyWrongPath,'uniformoutput',false);
montyDir_right = fullfile(exptResultsRefDir_right,'montageFrames');
if ~isdir(montyDir_right), mkdir(montyDir_right), end
badLoc = cellfun(@(x) ~exist(x,'file'),montyRightPath);
cellfun(@(x,y) movefile(x,y),montyWrongPath(badLoc),montyRightPath(badLoc))

sampleDir_wrong = fullfile(exptResultsRefDir_wrong,'sampleFrames');
sampleList = dir(fullfile(sampleDir_wrong,'*.tif'));
sampleList = {sampleList(:).name}';
sampleList = sampleList(cellfun(@(x) ~isempty(x),strfind(sampleList,runID)));
sampleWrongPath = cellfun(@(x) fullfile(sampleDir_wrong,x),sampleList,'uniformoutput',false);
sampleRightPath = cellfun(@(x) regexprep(x,exptID_wrong,exptID_right),sampleWrongPath,'uniformoutput',false);
sampleDir_right = fullfile(exptResultsRefDir_right,'sampleFrames');
if ~isdir(sampleDir_right), mkdir(sampleDir_right), end
badLoc = cellfun(@(x) ~exist(x,'file'),sampleRightPath);
cellfun(@(x,y) movefile(x,y),sampleWrongPath(badLoc),sampleRightPath(badLoc))
%% Moving tracking, locator, and analyzed data files
locDir_wrong = fullfile(exptResultsRefDir_wrong,[exptID_wrong '_flyLocator3000_v9']);
locList = dir(fullfile(locDir_wrong,'*.mat'));
locList = {locList(:).name}';
locList = locList(cellfun(@(x) ~isempty(x),strfind(locList,runID)));
locWrongPath = cellfun(@(x) fullfile(locDir_wrong,x),locList,'uniformoutput',false);
locRightPath = cellfun(@(x) regexprep(x,exptID_wrong,exptID_right),locWrongPath,'uniformoutput',false);
locDir_right = fullfile(exptResultsRefDir_right,[exptID_right '_flyLocator3000_v9']);
if ~isdir(locDir_right), mkdir(locDir_right), end
badLoc = cellfun(@(x) ~exist(x,'file'),locRightPath);
cellfun(@(x,y) movefile(x,y),locWrongPath(badLoc),locRightPath(badLoc))

locList = dir(fullfile(locDir_right,'*.mat'));
locList = {locList(:).name}';
locRightPath = cellfun(@(x) fullfile(locDir_right,x),locList,'uniformoutput',false);
for iterFix = 1:numel(locRightPath)
    load(locRightPath{iterFix});
    saveobj.orig_video_path{1} = regexprep(saveobj.orig_video_path{1},exptID_wrong,exptID_right);
    saveobj = set(saveobj,'ObsNames',regexprep(get(saveobj,'ObsNames'),exptID_wrong,exptID_right));
    save(locRightPath{iterFix},'saveobj')
end

trkDir_wrong = fullfile(exptResultsRefDir_wrong,[exptID_wrong '_flyTracker3000_v16']);
trkList = dir(fullfile(trkDir_wrong,'*.mat'));
trkList = {trkList(:).name}';
trkList = trkList(cellfun(@(x) ~isempty(x),strfind(trkList,runID)));
trkWrongPath = cellfun(@(x) fullfile(trkDir_wrong,x),trkList,'uniformoutput',false);
trkRightPath = cellfun(@(x) regexprep(x,exptID_wrong,exptID_right),trkWrongPath,'uniformoutput',false);
trkDir_right = fullfile(exptResultsRefDir_right,[exptID_right '_flyTracker3000_v16']);
if ~isdir(trkDir_right), mkdir(trkDir_right), end
badLoc = cellfun(@(x) ~exist(x,'file'),trkRightPath);
cellfun(@(x,y) movefile(x,y),trkWrongPath(badLoc),trkRightPath(badLoc))

trkList = dir(fullfile(trkDir_right,'*.mat'));
trkList = {trkList(:).name}';
trkRightPath = cellfun(@(x) fullfile(trkDir_right,x),trkList,'uniformoutput',false);
for iterFix = 1:numel(trkRightPath)
    load(trkRightPath{iterFix});
    saveobj.locator_path{1} = regexprep(saveobj.locator_path{1},exptID_wrong,exptID_right);
    saveobj = set(saveobj,'ObsNames',regexprep(get(saveobj,'ObsNames'),exptID_wrong,exptID_right));
    save(trkRightPath{iterFix},'saveobj')
end

anaDir_wrong = fullfile(exptResultsRefDir_wrong,[exptID_wrong '_pezAnalyzer3000_v11']);
anaList = dir(fullfile(anaDir_wrong,'*.mat'));
anaList = {anaList(:).name}';
anaList = anaList(cellfun(@(x) ~isempty(x),strfind(anaList,runID)));
anaWrongPath = cellfun(@(x) fullfile(anaDir_wrong,x),anaList,'uniformoutput',false);
anaRightPath = cellfun(@(x) regexprep(x,exptID_wrong,exptID_right),anaWrongPath,'uniformoutput',false);
anaDir_right = fullfile(exptResultsRefDir_right,[exptID_right '_pezAnalyzer3000_v11']);
if ~isdir(anaDir_right), mkdir(anaDir_right), end
badLoc = cellfun(@(x) ~exist(x,'file'),anaRightPath);
cellfun(@(x,y) movefile(x,y),anaWrongPath(badLoc),anaRightPath(badLoc))

anaList = dir(fullfile(anaDir_right,'*.mat'));
anaList = {anaList(:).name}';
anaRightPath = cellfun(@(x) fullfile(anaDir_right,x),anaList,'uniformoutput',false);
for iterFix = 1:numel(anaRightPath)
    load(anaRightPath{iterFix});
    saveobj.tracker_data_path{1} = regexprep(saveobj.tracker_data_path{1},exptID_wrong,exptID_right);
    saveobj.analyzed_vis_path{1} = regexprep(saveobj.analyzed_vis_path{1},exptID_wrong,exptID_right);
    saveobj = set(saveobj,'ObsNames',regexprep(get(saveobj,'ObsNames'),exptID_wrong,exptID_right));
    save(anaRightPath{iterFix},'saveobj')
end

locDir_wrong = fullfile(exptResultsRefDir_wrong,[exptID_wrong '_flyLocator3000_v9_summaryFigures']);
locList = dir(fullfile(locDir_wrong,'*.jpg'));
locList = {locList(:).name}';
locList = locList(cellfun(@(x) ~isempty(x),strfind(locList,runID)));
locWrongPath = cellfun(@(x) fullfile(locDir_wrong,x),locList,'uniformoutput',false);
locRightPath = cellfun(@(x) regexprep(x,exptID_wrong,exptID_right),locWrongPath,'uniformoutput',false);
locDir_right = fullfile(exptResultsRefDir_right,[exptID_right '_flyLocator3000_v9_summaryFigures']);
if ~isdir(locDir_right), mkdir(locDir_right), end
badLoc = cellfun(@(x) ~exist(x,'file'),locRightPath);
cellfun(@(x,y) movefile(x,y),locWrongPath(badLoc),locRightPath(badLoc))

anaDir_right = fullfile(exptResultsRefDir_right,[exptID_right '_pezAnalyzer3000_v11_visualMontage']);
if ~isdir(anaDir_right), mkdir(anaDir_right), end

%% Manual Assessment Fix

manualName_wrong = [exptID_wrong '_manualAnnotations.mat'];
manualPath_wrong = fullfile(exptResultsRefDir_wrong,manualName_wrong);
if exist(manualPath_wrong,'file') == 2
    manualAnnotations_import = load(manualPath_wrong);
    dataname = fieldnames(manualAnnotations_import);
    manualAnnotations = manualAnnotations_import.(dataname{1});
else
    disp(['no manual annotations for wrong ID: ' exptID_wrong])
end
manualNames = manualAnnotations.Properties.RowNames;
badIDs = cellfun(@(x) ~isempty(x),strfind(manualNames,runID));
manualPart2move = manualAnnotations(badIDs,:);
manualAnnotations = manualAnnotations(~badIDs,:);
% saving table which had bad IDs
save(manualPath_wrong,'manualAnnotations')

if ~isempty(manualPart2move)
    badNames = manualPart2move.Properties.RowNames;
    goodNames = cellfun(@(x) regexprep(x,exptID_wrong,exptID_right),badNames,'uniformoutput',false);
    manualPart2move.Properties.RowNames = goodNames;
    manualName_right = [exptID_right '_manualAnnotations.mat'];
    manualPath_right = fullfile(exptResultsRefDir_right,manualName_right);
    if exist(manualPath_right,'file') == 2
        manualAnnotations_import = load(manualPath_right);
        dataname = fieldnames(manualAnnotations_import);
        manualAnnotations = manualAnnotations_import.(dataname{1});
        manualAnnotations = cat(1,manualAnnotations,manualPart2move);
    else
        disp(['no manual annotations for right ID: ' exptID_right])
        manualAnnotations = manualPart2move;
    end
    % saving table which has correct IDs
    save(manualPath_right,'manualAnnotations')
end


%% Automated assessment fix

automatedName_wrong = [exptID_wrong '_automatedAnnotations.mat'];
automatedPath_wrong = fullfile(exptResultsRefDir_wrong,automatedName_wrong);
if exist(automatedPath_wrong,'file') == 2
    autoTable_import = load(automatedPath_wrong);
    dataname = fieldnames(autoTable_import);
    automatedAnnotations = autoTable_import.(dataname{1});
else
    disp(['no automated annotations for wrong ID: ' exptID_wrong])
end
autoNames = automatedAnnotations.Properties.RowNames;
badIDs = cellfun(@(x) ~isempty(x),strfind(autoNames,runID));
autoPart2move = automatedAnnotations(badIDs,:);
automatedAnnotations = automatedAnnotations(~badIDs,:);
% saving table which had bad IDs
save(automatedPath_wrong,'automatedAnnotations')

if ~isempty(autoPart2move)
    badNames = autoPart2move.Properties.RowNames;
    goodNames = cellfun(@(x) regexprep(x,exptID_wrong,exptID_right),badNames,'uniformoutput',false);
    autoPart2move.Properties.RowNames = goodNames;
    automatedName_right = [exptID_right '_automatedAnnotations.mat'];
    automatedPath_right = fullfile(exptResultsRefDir_right,automatedName_right);
    if exist(automatedPath_right,'file') == 2
        autoTable_import = load(automatedPath_right);
        dataname = fieldnames(autoTable_import);
        automatedAnnotations = autoTable_import.(dataname{1});
        automatedAnnotations = cat(1,automatedAnnotations,autoPart2move);
    else
        disp(['no automated annotations for right ID: ' exptID_right])
        automatedAnnotations = autoPart2move;
    end
    % saving table which has correct IDs
    save(automatedPath_right,'automatedAnnotations')
end

% automatedName_right = [exptID_wrong '_automatedAnnotations.mat'];
% automatedPath_right = fullfile(exptResultsRefDir_right,automatedName_right);
% if exist(automatedPath_right,'file')
%     load(automatedPath_right)
%     autoPart2move = automatedAnnotations;
%     
%     automatedName_right = [exptID_right '_automatedAnnotations.mat'];
%     automatedPath_rightB = fullfile(exptResultsRefDir_right,automatedName_right);
%     if exist(automatedPath_rightB,'file')
%         load(automatedPath_rightB)
%         autoNames = automatedAnnotations.Properties.RowNames;
%         rightIDs = cellfun(@(x) ~isempty(x),strfind(autoNames,runID));
%         if sum(rightIDs) ~= size(autoPart2move,1)
%             names2remove = cellfun(@(x) max(strcmp(autoPart2move.Properties.RowNames,x)),autoNames);
%             automatedAnnotations(names2remove,:) = [];
%             automatedAnnotations = cat(1,automatedAnnotations,autoPart2move);
%             save(automatedPath_rightB,'automatedAnnotations')
%         else
%             automatedName_right = [exptID_wrong '_automatedAnnotations.mat'];
%             automatedPath_right = fullfile(exptResultsRefDir_right,automatedName_right);
%             if exist(automatedPath_right,'file')
%                 delete(automatedPath_right)
%             end
%         end
%     else
%         movefile(automatedPath_right,automatedPath_rightB)
%     end
% end
%% Merged Video Statistics

vidInfoMergedName_wrong = [exptID_wrong '_videoStatisticsMerged.mat'];
vidInfoMergedPath_wrong = fullfile(exptResultsRefDir_wrong,vidInfoMergedName_wrong);
if exist(vidInfoMergedPath_wrong,'file') == 2
    vidInfo_import = load(vidInfoMergedPath_wrong);
    dataname = fieldnames(vidInfo_import);
    videoStatisticsMerged = vidInfo_import.(dataname{1});
else
    disp(['no assessment for wrong ID: ' exptID_wrong])
end
vidInfoNames = get(videoStatisticsMerged,'ObsNames');
badIDs = cellfun(@(x) ~isempty(x),strfind(vidInfoNames,runID));
vidInfoPart2move = videoStatisticsMerged(badIDs,:);
videoStatisticsMerged = videoStatisticsMerged(~badIDs,:);
% saving table which had bad IDs
save(vidInfoMergedPath_wrong,'videoStatisticsMerged')

if ~isempty(vidInfoPart2move)
    badNames = get(vidInfoPart2move,'ObsNames');
    goodNames = cellfun(@(x) regexprep(x,exptID_wrong,exptID_right),badNames,'uniformoutput',false);
    vidInfoPart2move = set(vidInfoPart2move,'ObsNames',goodNames);
    vidInfoMergedName_right = [exptID_right '_videoStatisticsMerged.mat'];
    vidInfoMergedPath_right = fullfile(exptResultsRefDir_right,vidInfoMergedName_right);
    if exist(vidInfoMergedPath_right,'file') == 2
        vidInfo_import = load(vidInfoMergedPath_right);
        dataname = fieldnames(vidInfo_import);
        videoStatisticsMerged = vidInfo_import.(dataname{1});
        videoStatisticsMerged = cat(1,videoStatisticsMerged,vidInfoPart2move);
    else
        disp(['no assessment for right ID: ' exptID_right])
        videoStatisticsMerged = vidInfoPart2move;
    end
    % saving table which has correct IDs
    save(vidInfoMergedPath_right,'videoStatisticsMerged')
end

% vidInfoMergedName_right = [exptID_wrong '_videoStatisticsMerged.mat'];
% vidInfoMergedPath_right = fullfile(exptResultsRefDir_right,vidInfoMergedName_right);
% if exist(vidInfoMergedPath_right,'file')
%     load(vidInfoMergedPath_right)
%     vidInfoPart2move = videoStatisticsMerged;
%     
%     vidInfoMergedName_right = [exptID_right '_videoStatisticsMerged.mat'];
%     vidInfoMergedPath_rightB = fullfile(exptResultsRefDir_right,vidInfoMergedName_right);
%     if exist(vidInfoMergedPath_rightB,'file')
%         load(vidInfoMergedPath_rightB)
%         vidStatsNames = get(videoStatisticsMerged,'ObsNames');
%         rightIDs = cellfun(@(x) ~isempty(x),strfind(vidStatsNames,runID));
%         if sum(rightIDs) ~= size(vidInfoPart2move,1)
%             names2remove = cellfun(@(x) max(strcmp(get(vidInfoPart2move,'ObsNames'),x)),vidStatsNames);
%             videoStatisticsMerged(names2remove,:) = [];
%             videoStatisticsMerged = cat(1,videoStatisticsMerged,vidInfoPart2move);
%             save(vidInfoMergedPath_rightB,'videoStatisticsMerged')
%         else
%             vidInfoMergedName_right = [exptID_wrong '_videoStatisticsMerged.mat'];
%             vidInfoMergedPath_right = fullfile(exptResultsRefDir_right,vidInfoMergedName_right);
%             if exist(vidInfoMergedPath_right,'file')
%                 delete(vidInfoMergedPath_right)
%             end
%         end
%     else
%         movefile(vidInfoMergedPath_right,vidInfoMergedPath_rightB)
%     end
% end
%% Merged Experiment Infoa

exptInfoMergedName_wrong = [exptID_wrong '_experimentInfoMerged.mat'];
exptInfoMergedPath_wrong = fullfile(exptResultsRefDir_wrong,exptInfoMergedName_wrong);
if exist(exptInfoMergedPath_wrong,'file') == 2
    experimentInfo_import = load(exptInfoMergedPath_wrong);
    dataname = fieldnames(experimentInfo_import);
    experimentInfoMerged = experimentInfo_import.(dataname{1});
else
    disp(['no assessment for wrong ID: ' exptID_wrong])
end
exptInfoNames = get(experimentInfoMerged,'ObsNames');
badIDs = cellfun(@(x) ~isempty(x),strfind(exptInfoNames,runID));
exptInfoPart2move = experimentInfoMerged(badIDs,:);
experimentInfoMerged = experimentInfoMerged(~badIDs,:);
% saving table which had bad IDs
save(exptInfoMergedPath_wrong,'experimentInfoMerged')

if ~isempty(exptInfoPart2move)
    exptInfoMergedName_right = [exptID_right '_experimentInfoMerged.mat'];
    exptInfoMergedPath_right = fullfile(exptResultsRefDir_right,exptInfoMergedName_right);
    if exist(exptInfoMergedPath_right,'file') == 2
        experimentInfo_import = load(exptInfoMergedPath_right);
        dataname = fieldnames(experimentInfo_import);
        experimentInfoMerged = experimentInfo_import.(dataname{1});
        experimentInfoMerged = cat(1,experimentInfoMerged,exptInfoPart2move);
    else
        disp(['no merged exptInfo for right ID: ' exptID_right])
        experimentInfoMerged = exptInfoPart2move;
    end
    % saving table which has correct IDs
    save(exptInfoMergedPath_right,'experimentInfoMerged')
end

% exptInfoMergedName_right = [exptID_wrong '_experimentInfoMerged.mat'];
% exptInfoMergedPath_right = fullfile(exptResultsRefDir_right,exptInfoMergedName_right);
% if exist(exptInfoMergedPath_right,'file')
%     load(exptInfoMergedPath_right)
%     exptInfoPart2move = experimentInfoMerged;
%     
%     exptInfoMergedName_right = [exptID_right '_experimentInfoMerged.mat'];
%     exptInfoMergedPath_rightB = fullfile(exptResultsRefDir_right,exptInfoMergedName_right);
%     if exist(exptInfoMergedPath_rightB,'file')
%         load(exptInfoMergedPath_rightB)
%         exptNames = get(experimentInfoMerged,'ObsNames');
%         rightIDs = cellfun(@(x) ~isempty(x),strfind(exptNames,runID));
%         if sum(rightIDs) ~= size(exptInfoPart2move,1)
%             names2remove = cellfun(@(x) max(strcmp(get(exptInfoPart2move,'ObsNames'),x)),exptNames);
%             experimentInfoMerged(names2remove,:) = [];
%             experimentInfoMerged = cat(1,experimentInfoMerged,exptInfoPart2move);
%             save(exptInfoMergedPath_rightB,'experimentInfoMerged')
%         else
%             exptInfoMergedName_right = [exptID_wrong '_experimentInfoMerged.mat'];
%             exptInfoMergedPath_right = fullfile(exptResultsRefDir_right,exptInfoMergedName_right);
%             if exist(exptInfoMergedPath_right,'file')
%                 delete(exptInfoMergedPath_right)
%             end
%         end
%     else
%         movefile(exptInfoMergedPath_right,exptInfoMergedPath_rightB)
%     end
% end
%% Updating the statusAssessment variable
pez3000_statusAssessment({exptID_right})
pez3000_statusAssessment({exptID_wrong})
end