function runMonitor_v1
% clear all
% close all
% clc

%%%%% computer and directory variables and information
data_dir = [filesep filesep 'arch' filesep 'card' filesep 'Data_pez3000'];
variablesDir = [filesep filesep 'dm11' filesep 'cardlab' filesep 'pez3000_variables'];

compDataPath = fullfile(variablesDir,'computer_info.xlsx');
compData = dataset('XLSFile',compDataPath);
comp_nameList = compData.control_computer_name;
compCt = numel(comp_nameList);
vidCt = cell(compCt,1);
runStatus = cell(compCt,1);
timeRem = cell(compCt,1);
discardCt = cell(compCt,1);
runLog = cell(compCt,1);
stimFail = cell(compCt,1);
prismCt = cell(compCt,1);
tunnelCt = cell(compCt,1);
logBool = num2cell(false(compCt,1));
runLength = 20;%run length in minutes
getInfo
%
backC = [0.1 0.1 0.1];
f = figure('Position',[100 200 1180 190],'color',backC,'NumberTitle','off',...
    'menubar','none');
panPos = [.015 .05 .97 .9];
p = uipanel('Parent',f,'Title','Pez Status Update','foregroundColor',[.7 .7 .7],...
    'FontSize',12,'backgroundcolor',backC,'Position',panPos);
rnames = cellfun(@(x) ['pez_' num2str(x)],...
    num2cell(compData.pez_reference(:)'),'uniformoutput',false);
cnames = {'Status','Time Remaining','Video Count','Blank or Multi',...
    'Stimulus Failures','Prism Count','Tunnel Count','Show Log'};
logBool{1} = true;
dat = [runStatus(:)';timeRem(:)';vidCt(:)';discardCt(:)';stimFail(:)'
    prismCt(:)';tunnelCt(:)';logBool(:)']';
tFormat = {'char','char','char','char','char','char','char','logical'};
colW = num2cell(zeros(1,numel(tFormat))+100);
tPos = [.02 .1 .8 .8];
columneditable = false(1,numel(tFormat));
columneditable(end) = true;
t = uitable('Parent',p,'Data',dat,'ColumnName',cnames,...
    'RowName',rnames,'columnformat',tFormat,'units','normalized',...
    'enable','on','Position',tPos,'columnwidth',colW,...
    'CellEditCallback',@tableCall,'columneditable',columneditable);
ePos = [.83 .1 .15 .8];
e = uicontrol(p,'Style','edit','HorizontalAlignment','left','units','normalized',...
    'fontsize',8,'string',flipud(runLog{1}),'max',2,'position',ePos);
refRate = 4;%times to be executed per minute
tRun = timer('TimerFcn',@setInfo,'ExecutionMode','fixedRate',...
    'Period',round((60/refRate)*100)/100,'StartDelay',1,'Name','tPlay');
%%
set(f,'CloseRequestFcn',@myCloseFun)
start(tRun)
    function tableCall(~,~)
        tData = get(t,'data');
        logBoolNew = tData(:,end);
        if max(cell2mat(logBoolNew) ~= cell2mat(logBool));
            logBool = cell2mat(logBoolNew) ~= cell2mat(logBool);
            logBool = num2cell(logBool);
        end
        set(e,'string',flipud(runLog{cell2mat(logBool)}))
        dat = [runStatus(:)';timeRem(:)';vidCt(:)';discardCt(:)';stimFail(:)'
            prismCt(:)';tunnelCt(:)';logBool(:)']';
        set(t,'data',dat)
        drawnow
    end
    function setInfo(~,~)
        try
            getInfo
            tableCall
%             disp('refreshed')
        catch ME
            getReport(ME)
        end
    end
    function getInfo
        for iterC = 1:compCt
            % computer-specific information
            comp_name = comp_nameList{iterC}; %Remove trailing character.
            compRef = (strcmp(compData.control_computer_name,comp_name));
            pezName = ['pez' num2str(compData.pez_reference(compRef))];
            
            currDate = datestr(date,'yyyymmdd');
            destDatedDir = fullfile(data_dir,currDate);
            runFolderCount = dir(fullfile(destDatedDir,'run*'));
            runIndex = numel({runFolderCount(:).name});
            runBool = false(1,runIndex);
            for iterResume = 1:runIndex
                runFolders = ['run',sprintf('%03.0f',iterResume),'_',pezName,'_',currDate];
                runPaths = fullfile(destDatedDir,runFolders);
                runStatsDests = fullfile(runPaths,[runFolders,'_runStatistics.mat']); %path to save runStatistics
                runBool(iterResume) = exist(runStatsDests,'file');
            end
            lastRunRef = find(runBool,1,'last');
            if isempty(lastRunRef)
                messageFun('No previous run found')
            else
                runIndex = lastRunRef;
            end
            runFolder = ['run',sprintf('%03.0f',runIndex),'_',pezName,'_',currDate];
            runPath = fullfile(destDatedDir,runFolder);
            
            
            video_filesMP4 = dir(fullfile(runPath,'*.mp4'));
            video_filesAVI = dir(fullfile(runPath,'*.avi'));
            vidCt{iterC} = numel({video_filesMP4(:).name})+numel({video_filesAVI(:).name});
            
            eventLogPath = fullfile(runPath,[runFolder,'_eventLog.txt']); %path to save event log
            if exist(eventLogPath,'file')
                eventTable = readtable(eventLogPath,'Delimiter','\t','ReadVariableNames',false);
                eventTable.Properties.VariableNames = {'Time','Event'};
                runLog{iterC} = eventTable.Event;
                startRef = find(strcmp(eventTable.Event,'Run timer started'),1,'last');
                stopRef = find(strcmp(eventTable.Event,'Run timer stopped'),1,'last');
                if ~isempty(startRef)
                    runStatus{iterC} = 'Running';
                    [~,~,~,H,MN] = datevec(eventTable.Time(startRef));
                    minPast = MN+H*60;
                    [~,~,~,H,MN] = datevec(now);
                    timeVal = (MN+H*60)-minPast-runLength;
                    if timeVal > 0
                        timeRem{iterC} = 'Over time';
                    else
                        timeRem{iterC} = num2str(abs(timeVal));
                    end
                    
                    if startRef < stopRef
                        runStatus{iterC} = 'Stopped';
                        timeRem{iterC} = 'n/a';
                    end
                else
                    runStatus{iterC} = 'Not Started';
                    timeRem{iterC} = 'n/a';
                end
            end
            runStatsDest = fullfile(runPath,[runFolder,'_runStatistics.mat']); %path to save runStatistics
            if exist(runStatsDest,'file')
                runLoad = load(runStatsDest);
                runStats = runLoad.runStats;
                if ~isempty(runStats)
                    discardCt{iterC} = runStats.multi_count+runStats.empty_count;
                    stimFail{iterC} = runStats.diode_failures;
                    tunnelCt{iterC} = runStats.tunnel_fly_count;
                    prismCt{iterC} = runStats.prism_fly_count;
                end
            end
        end
    end
% Close and clean up
    function myCloseFun(~,~)
        if strcmp(tRun.Running,'on'),stop(tRun),end
        delete(f)
    end
end