function pezProcessor3000_v8auto(totalComps,thisComp,runMode,minimum_collectionID)
if isempty(mfilename) || nargin == 0
    totalComps = 1;
    thisComp = 1;
    runMode = 4;
end
if ~exist('minimum_collectionID','var')
    minimum_collectionID = '0005';
end

%%%%% ENTER FUNCTION NAMES:
locator_name = 'flyLocator3000_v10';
tracker_name = 'flyTracker3000_v17';
analyzer_name = 'flyAnalyzer3000_v14';
visualizer_name = 'trackingVisualizer3000_v14';

%%%%% RUN MODE:
% '1' - functions run only when they have been scheduled according to the
% raw data assessment file, regardless of whether previous results exist
% '2' - functions run on all 'passing' raw data regardless of whether
% previous results exist
% '3' - functions run for 'passing' raw data which does not have existing
% tracking, locator, or analyzed data - NEEDS TO QUERY GRAPH TABLE; NOT IN
% USE AT THE MOMENT
% '4' - functions run only for 'passing' and tracked raw data which 
% is missing at least one of the tracking, locating, or analyzing files


%%%%% computer and directory variables and information
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');

set(0,'showhiddenhandles','on')
delete(get(0,'children'))
housekeepingDir = fullfile(fileDir,'Pez3000_Gui_folder','defaults_and_housekeeping_variables');
analysisDir = fullfile(fileDir,'Data_pez3000_analyzed');

failure_path = fullfile(analysisDir,'errorLogs','pezProcessor300_v8auto_errorLog.txt');

listSavePath = fullfile(fileDir,'pez3000_variables\analysisVariables\videoList.mat');
if exist(listSavePath,'file')
    delete(listSavePath)%%%%%% comment out to keep saved list
end
%%
if exist(listSavePath,'file')
    load(listSavePath)
else
    %
    %%% Normal way to load exptIDs
    exptIDlist = dir(analysisDir);
    exptIDexist = cell2mat({exptIDlist(:).isdir});
    exptIDlengthTest = cellfun(@(x) numel(x) == 16,{exptIDlist(:).name});
    exptIDlist = {exptIDlist(min(exptIDexist,exptIDlengthTest)).name};
   
    exptIDlist = exptIDlist(cellfun(@(x) str2double(x(1:4)) >= str2double(minimum_collectionID),exptIDlist));
%    exptIDlist = exptIDlist(cellfun(@(x) str2double(x(1:4)) == 113,exptIDlist));
%    exptIDlist = {'0083000022700609'};
    
    exptCt = numel(exptIDlist);
    videoList = cell(exptCt,1);
    for iterE = 1:exptCt
        exptID = exptIDlist{iterE};
%         if contains(exptID, '0243000017061061')
%             keyboard
%         end
        assessmentPath = fullfile(analysisDir,exptID,[exptID '_rawDataAssessment.mat']);
        if exist(assessmentPath,'file') == 2
            try
                assessTable_import = load(assessmentPath);
                dataname = fieldnames(assessTable_import);
                assessTable = assessTable_import.(dataname{1});
            catch       %file where assestable is corrupt
                assessTable = [];
            end
            if ~isempty(assessTable)
                if runMode == 1 || runMode == 4
                    vids2removeA = strcmp(assessTable.Analysis_Status,'Tracking requested');
                    vids2removeB = strcmp(assessTable.Analysis_Status,'Tracking scheduled');
                    vids2removeC = strcmp(assessTable.Analysis_Status,'Analysis complete');
                    if runMode == 4
                        vids2removeFull = ~(vids2removeA | vids2removeB | vids2removeC);
                    else
                        vids2removeFull = vids2removeA | vids2removeB;
                    end
                    assessTable(~vids2removeFull,:) = [];
                end
                assessTable(~strcmp(assessTable.Raw_Data_Decision,'Pass'),:) = [];
                vidList = assessTable.Properties.RowNames;
                if ~isempty(vidList)
                    videoList{iterE} = vidList;
                end
            end
        end
    end
    videoList = cat(1,videoList{:});
    ignorePath = fullfile(analysisDir,'ignoreLists','videos2ignoreList.txt');
    ignoreCell = readtable(ignorePath,'Delimiter','\t','ReadVariableNames',false);
    ignoreCell = table2cell(ignoreCell);
    ignoreCell = ignoreCell(:,1);
    if ~isempty(videoList)
        videoList = videoList(cellfun(@(x) ~max(strcmp(x,ignoreCell)),videoList));
        save(listSavePath,'videoList')
    end
    %%%%% makes video list from error record
%     errorList = importdata(failure_path);
%     videoList = cellfun(@(x) x(1:52),errorList,'uniformoutput',false);
%     videoList = unique(videoList);
end

%%
videoCt = numel(videoList);
vidRefBreaks = round(linspace(1,videoCt,totalComps+1));
[~,host] = system('hostname');
host = strtrim(regexprep(host,'-','_'));
parCtrlPath = fullfile(housekeepingDir,'parforControl.txt');
if exist(parCtrlPath,'file')
    parTable = readtable(parCtrlPath,'delimiter',',');
else
    parTable = [];
end
iterList = vidRefBreaks(thisComp):vidRefBreaks(thisComp+1);
iterCt = numel(iterList);
localParTable = table({host},{'run'},iterCt,...
    0,'VariableNames',{'computer','action','total_iterations','prev_iterations'});
if isempty(parTable)
    parTable = localParTable;
elseif ~max(strcmp(parTable.computer,host))
    parTable = cat(1,parTable,localParTable);
else
    localParTable.prev_iterations = parTable.total_iterations(strcmp(parTable.computer,host));
    parTable(strcmp(parTable.computer,host),:) = localParTable;
end

writetable(parTable,parCtrlPath)
parfor iterG = iterList
    try
        parTable = readtable(parCtrlPath,'delimiter',',');
        if strcmp(parTable.action{strcmp(parTable.computer,host)},'stop')
            continue
        end
    catch
    end
    locator_fun = str2func(locator_name);
    tracker_fun = str2func(tracker_name);
    analyzer_fun = str2func(analyzer_name);
    videoID = videoList{iterG};
    try
        tic
        locator_fun(videoID,runMode);
        tracker_fun(videoID,locator_name,runMode);
        analyzer_fun(videoID,locator_name,tracker_name,runMode);
        toc
   catch ME
       report = getReport(ME);
       disp(['videoID: ' report])
       fidErr = fopen(failure_path,'a');
       fprintf(fidErr,'%s \r\n',videoID);
       fclose(fidErr);
       toc
        continue
    end
end

if exptCt > 0
    errTally = cell(exptCt,3);
    parfor iterG = 1:exptCt
        exptID = exptIDlist{iterG};
        visualizer_fun = str2func(visualizer_name);
        try
            visualizer_fun(exptID);
        catch ME
            if numel(ME.stack) > 1
                errTally(iterG,:) = {ME.stack(end-1).name ME.stack(end-1).line exptID};
            end
        end
        
        disp(exptID)
    end
    pez3000_statusAssessment_v2(exptIDlist)
    errorList = errTally(cellfun(@(x) ~isempty(x),errTally(:,1)),3); %#ok<NASGU>
    save(fullfile(fileDir,'Data_pez3000_analyzed','errorLogs','graphingVariableGenerationErrors.mat'),'errorList')
end
parTable = readtable(parCtrlPath,'delimiter',',');
parTable.action{strcmp(parTable.computer,host)} = 'stop';
writetable(parTable,parCtrlPath)