function pez3000_curator_v4a
%close all
clc
assessmentTag = '_rawDataAssessment.mat';
%%%% The following were early ideas for this gui.  Decided to just make another gui
% Raw data assessment includes determining whether the video was a blank,
% single, or multi.  Also, if relevant, did fly detect correctly determine
% the direction of the fly?  Finally, are the NIDAQ traces acceptable?

% This will allow the user to view the raw recorded video.  Options should
% include either 1/10th rate, the fullrate portion, or the fully recompiled
% video.  Also, graphing options should include either the NIDAQ traces or
% the tracking results.

% This allows the user to hand annotate the video in various ways.  Either
% frames are manually selected which represent various key moments in the
% video, center of mass is determined for one or more frames, or other
% features of the fly are marked including wings and/or legs.

% Here, the user can assess the tracking results.  Decisions can include to
% redo the tracking using a new initial heading (i.e. when the locator is
% wrong by 180 degress) or using a new end point (i.e. when error is too
% great near the end of the portion tracked).

%%%%% computer and directory variables and information
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');

guiVarDir = fullfile(fileDir,'Pez3000_Gui_folder','Gui_saved_variables');
housekeepingDir = fullfile(fileDir,'Pez3000_Gui_folder','defaults_and_housekeeping_variables');
analysisDir = fullfile(fileDir,'Data_pez3000_analyzed');
userPath = fullfile(guiVarDir,'Saved_User_names.mat');
if exist(userPath,'file')
    userLoading = load(userPath);
    Saved_User_names = userLoading.Saved_User_names;
    userNames = Saved_User_names.User_ID;
end
repositoryDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));

colSaved = load(fullfile(guiVarDir,'Saved_Collection.mat'));
datanameLoad = fieldnames(colSaved);
colSaved = colSaved.(datanameLoad{1});
                
groupData = load(fullfile(guiVarDir,'Saved_Group_IDs_table.mat'));
%groupData = load(fullfile(guiVarDir,'Saved_Group_IDs.mat'));
groupData = groupData.Saved_Group_IDs;
% [groupNames,refsFirst,refsFull] = unique(groupData.Group_Desc);
% groupNames = strtrim(groupNames);
% groupUsers = groupData.User_ID(refsFirst);
% groupExpts = cell(numel(refsFirst),1);
% for iterGrp = 1:numel(refsFirst)
%     groupExpts(iterGrp) = {groupData.Experiment_ID(refsFull == iterGrp)};
% end
% groupData = [groupNames,groupUsers,groupExpts];
groupNames = groupData.Properties.RowNames;
groupUsers = groupData.User_ID;
groupExpts = groupData.Experiment_IDs;

groupData = [groupNames,groupUsers,groupExpts];
groupTableData = groupData(:,1:2);
 
exptSumName = 'experimentSummary.mat';
exptSumPath = fullfile(analysisDir,exptSumName);
experimentSummary = load(exptSumPath);
experimentSummary = experimentSummary.experimentSummary;

exptIDlist = dir(analysisDir);
exptIDexist = cell2mat({exptIDlist(:).isdir});
exptIDlengthTest = cellfun(@(x) numel(x) == 16,{exptIDlist(:).name});
exptIDlist = {exptIDlist(min(exptIDexist,exptIDlengthTest)).name};
colIDlist = unique(cellfun(@(x) x(1:4),exptIDlist,'uniformoutput',false));
colNames = colSaved.Collection_Name(colIDlist);
colUsers = colSaved.User_ID(colIDlist);
collectionTableData = [colIDlist(:),colNames(:),colUsers(:)];
workRef = zeros(1,4);
showCell = cell(1,4);

%curr_logic = cellfun(@(x) str2double(x(1:4)) >= 78,experimentSummary.Properties.RowNames);
curr_logic = cellfun(@(x) str2double(x(1:4)) >= 95,experimentSummary.Properties.RowNames);
%%
%close all

% Screen, figure, axes
screen2use = 2;         % in multi screen setup, this determines which screen to be used
screen2cvr = 0.9;       % portion of the screen to cover
monPos = get(0,'MonitorPositions');
if size(monPos,1) == 1,screen2use = 1; end
scrnPos = monPos(screen2use,:);
figPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+scrnPos(1:2),...
    1295 809]);
figCdone = [.05 0.25 0];
figCworking = [0.05 0 0.25];
figureTitle = 'flyPez3000 Data Curation - WRW';
hOld = findobj('name',figureTitle);
if ~isempty(hOld)
    delete(hOld)
end
hFigA = figure('NumberTitle','off','Name',figureTitle,...
    'menubar','none','units','pix','Color',figCworking,'pos',figPos,...
    'visible','off');%,'colormap',gray(256));
if isempty(mfilename)
    set(hFigA,'Visible','on')
end

axesC = [0 0 0];
axesPosInit = [.01 .2 .98 .79];
hAxes = cell(6,1);
hImage = cell(6,1);
hPlot = cell(6,1);
hQuiv = cell(6,1);
hText = cell(6,1);
visualSummary = uint8(zeros(1020,1890,3));
imW = size(visualSummary,2);
imH = size(visualSummary,1);
boxRatio = double([imW imH])./double(max(imW,imH));
boxRatio(3) = 1;
for iterHa = 1:3
    for iterHb = 1:2
        hRef = iterHa+(iterHb-1)*3;
        hAxes{hRef} = axes('Parent',hFigA,'Position',axesPosInit,...
            'color',axesC,'tickdir','in','nextplot','add',...
            'xticklabel',[],'yticklabel',[],'visible','off');
        if iterHa < 3
            set(hAxes{hRef},'xlim',[1 imW],'ylim',[1 imH],...
                'PlotBoxAspectRatio',boxRatio,'YDir','reverse')
            hImage{hRef} = image('Parent',hAxes{hRef},'CData',visualSummary,'visible','off');
        end
        hPlot{hRef} = plot(zeros(10,10),zeros(10,10),'Parent',hAxes{hRef},'visible','off');
        hQuiv{hRef} = quiver(zeros(3,3),zeros(3,3),zeros(3,3),zeros(3,3),'Parent',hAxes{hRef},'Visible','off');
        hText{hRef} = text(zeros(20,1),zeros(20,1),cell(20,1),'Parent',hAxes{hRef},...
            'Visible','off','fontunits','normalized');
        set(hAxes{hRef},'nextplot','replacechildren')
    end
end
hAxesOrigRef = axes('Parent',hFigA,'Position',axesPosInit,'visible','off');
hSel = 0;

% Create the GUI controls
panelC = [0.2 0.2 0.2];
hPanA = uipanel('Parent',hFigA,'Position',[.01 .01 .98 .18],...
    'Visible','on','BackgroundColor',panelC,'BorderWidth',0);
figPos = get(hFigA,'position');
panPos = get(hPanA,'position');
relSize = round(figPos.*panPos);
guiPos = @(x,y,w,h) cat(2,[x,y],[w,h]./relSize(3:4));
convertW = @(w) w/relSize(3);
convertH = @(h) h/relSize(4);
btnFontSize = 8;
btnH = [30 22];
textH = 20;
editC = [.9 .9 .9];
textC = [.8 .8 .8];
btnC = [.8 .8 .8];
focusC = [.6 .6 .8];
% gamma slider
warning('off','MATLAB:hg:ColorSpec_None');
hPanB = uipanel('Parent',hFigA,'Visible','off','BackgroundColor','k',...
    'position',[.08 .26 .2 .03],'BorderWidth',0);
gamPos = [.01 .15 .8 .7];
hCgamma = uicontrol(hPanB,'style','slider','units','normalized','Position',gamPos,'backgroundcolor',[.8 .8 .8],...
    'fontunits','normalized','fontsize',0.4638,'Interruptible','off',...
    'Min',0.001,'Max',2,'Value',1,'callback',@gammaCallback);
hJGammaBar = findjobj(hCgamma);
if ~isempty(hJGammaBar)
    hJGammaBar.MousePressedCallback = @GammaClickCallback;
    hJGammaBar.MouseReleasedCallback = @GammaReleaseCallback;
end
gammaVal = 1;
gamResetPos = [.85 .15 .13 .7];
uicontrol(hPanB,'style','pushbutton','units','normalized','string','Reset',...
    'Position',gamResetPos,'fontunits','normalized','backgroundcolor',btnC,...
    'callback',@gammaResetCallback);

% Creates a dummy edit box for receiving keyboard inputs
hEditInput = uicontrol(hPanA,'style','edit','units','normalized',...
    'Position',guiPos(.01,.01,230,textH),'visible','on',...
    'foregroundcolor',panelC,'backgroundcolor',panelC);
jObjEditIn = findjobj(hEditInput);
if ~isempty(jObjEditIn)
    jObjEditIn.KeyPressedCallback = @keyPressedCall;
    jObjEditIn.FocusLostCallback = @focusLostCall;
    set(jObjEditIn,'Border',[])
end

% collection, experiment, and video navigation tools
% Gui state togglebuttons
hGuiOps.parent = uibuttongroup('parent',hPanA,'position',...
    guiPos(.01,.2,120,110),'backgroundcolor',textC,...
    'Title',[],'fontsize',10,'fontunits','normalized');
y1 = 0.05;
bH = (1-y1*2)/4;
opStrings = {'Collections','Groups','Experiments','Videos'};
for iterSel = 1:4
    hGuiOps.children(iterSel) = uicontrol(hGuiOps.parent,'style','togglebutton',...
        'units','normalized','string',opStrings{iterSel},...
        'Position',[.05 1-y1-bH*iterSel .9 bH],...
        'fontsize',btnFontSize,'fontunits','normalized','enable','on',...
        'backgroundcolor',btnC);
end
set(hGuiOps.children(4),'enable','off')
% hAutoSave = uicontrol(hGuiOps.parent,'style','checkbox','units','normalized',...
%     'string','Auto Save','Position',[.05 y1 .9 bH],...
%     'fontsize',btnFontSize,'fontunits','normalized','enable','on',...
%     'backgroundcolor',btnC);

hNext = uicontrol(hPanA,'style','pushbutton','units','normalized',...
    'string','Next','Position',guiPos(.01+convertW(60),.05,60,btnH(2)),...
    'fontsize',btnFontSize,'fontunits','normalized','enable','on',...
    'backgroundcolor',btnC);
hPrev = uicontrol(hPanA,'style','pushbutton','units','normalized',...
    'string','Prev','Position',guiPos(.01,.05,60,btnH(2)),...
    'fontsize',btnFontSize,'fontunits','normalized','enable','on',...
    'backgroundcolor',btnC);

% Filters menu
hmFilter = uimenu(hFigA,'Label','Data Filters');
filterStrings = {'None','Hide Curated','Show Curated Only','Hide Failed','Show Failed Only',...
    'Show Passing Only','by User'};
hFilterMenu = zeros(1,numel(filterStrings));
for iterFilter = 1:numel(filterStrings)
    hFilterMenu(iterFilter) = uimenu(hmFilter,'Label',filterStrings{iterFilter},...
        'Callback',@filterMenuCall);
end
set(hFilterMenu(1),'checked','on')
set(hFilterMenu(end),'Callback',[])

userStrings = [{'No user selected'};userNames(:)];
hUserMenu = zeros(1,numel(userStrings));
for iterUser = 1:numel(userStrings)
    hUserMenu(iterUser) = uimenu(hFilterMenu(end),'Label',userStrings{iterUser},...
        'Callback',@filterMenuCall);
end
set(hUserMenu(1),'checked','on')

% Resets menu
hmReset = uimenu(hFigA,'Label','Data Reset Options');
resetStrings = {'Current Video','Current Run','Current Run (ROI only)','Current Experiment'};
hResetMenu = zeros(1,numel(resetStrings));
for iterReset = 1:numel(resetStrings)
    hResetMenu(iterReset) = uimenu(hmReset,'Label',resetStrings{iterReset},...
        'Callback',@resetCall);
end

% tableData = [colIDlist(:),colNames(:),colUsers(:)];
hTable = uitable('Parent',hPanA,'units','normalized',...
    'position',guiPos(.01+convertW(125),.05,350,132),...
    'backgroundcolor',editC,'CellSelectionCallback',@tableCall);
jScroll = findjobj(hTable);
jTable = jScroll.getViewport.getView;

% Now turn the JIDE sorting on
jTable.setSortable(true);
jTable.setAutoResort(true);
jTable.setMultiColumnSortable(true);
jTable.setPreserveSelectionsAfterSorting(true);
jTable.setNonContiguousCellSelection(false);
jTable.setColumnSelectionAllowed(false);
jTable.setRowSelectionAllowed(true);

hJTable = handle(jTable, 'CallbackProperties');
set(hJTable,'MousePressedCallback',@tableCall);

% hTableChildren = get(jScroll,'Components');
% %background of top header
% set(get(hTableChildren(4),'View'),'Background',java.awt.Color(0.8,0.8,0.8))
% %background for empty part of table
% set(hTableChildren(1),'Background',java.awt.Color(0.8,0.8,0.8))
%colors on table
set(jTable,'GridColor',java.awt.Color(0.6,0.6,0.6))
set(jTable,'SelectionBackground',java.awt.Color(0.8,0.8,1))
set(jTable,'SelectionForeground',java.awt.Color(0,0,0))
        
htmlcolor = sprintf('rgb(%d,%d,%d)', round(btnC*255));

% Session menu
hmSession = uimenu(hFigA,'Label','Session Control');
sessionStrings = {'Auto Save','Auto Reset Remaining ROI','Save Experiment',...
    'Save Preferences','Restore Defaults','Quit'};
sessionCalls = {@autoSaveCall,@setChecked,@saveButtonCall,@savePrefsCall,@restoreCall,@myCloseFun};
hSessionMenu = zeros(1,numel(sessionStrings));
for iterSession = 1:numel(sessionStrings)
    hSessionMenu(iterSession) = uimenu(hmSession,'Label',sessionStrings{iterSession},...
        'Callback',sessionCalls{iterSession});
end
set(hSessionMenu(2),'separator','on')
roiChanged = false;

% ROI adjustment controls
hTextROI = uicontrol(hPanA,'style','text','units','normalized','HorizontalAlignment','left',...
    'string','(2/s) ROI Adjustment','Position',guiPos(.39,convertH(98),80,textH*2),'backgroundcolor',textC,...
    'fontsize',btnFontSize,'fontunits','normalized','enable','on');
hPanROI = uipanel('Parent',hPanA,'Position',guiPos(.39,.05,80,95),...
    'Visible','on','BackgroundColor',textC,'BorderWidth',0);
iconshade = 0.2;
moveBtnPosOps = {[.34 .4 .32 .3]
    [.34 .05 .32 .3]
    [.67 .2 .29 .4]
    [.05 .2 .29 .4]
    [.6 .75 .35 .25]
    [.05 .75 .35 .25]};
btnIcons = {'up','down','fwd','rev','plus','minus'};
hMoveROI = zeros(6,1);
for iterBtn = 1:6
    hMoveROI(iterBtn) = uicontrol(hPanROI,'style','pushbutton','units','normalized',...
        'Position',moveBtnPosOps{iterBtn},...
        'fontsize',btnFontSize,'fontunits','normalized','enable','on',...
        'backgroundcolor',btnC);
    makePezIcon_curationGUI(hMoveROI(iterBtn),0.7,btnIcons{iterBtn},iconshade,btnC)
end

% Stage adjustment controls
hTextStage = uicontrol(hPanA,'style','text','units','normalized','HorizontalAlignment','left',...
    'string','(3/d) Stage Adjustment','Position',guiPos(.46,convertH(98),60,textH*2),'backgroundcolor',textC,...
    'fontsize',btnFontSize,'fontunits','normalized','enable','on');
hPanStage = uipanel('Parent',hPanA,'Position',guiPos(.46,.05,60,95),...
    'Visible','on','BackgroundColor',textC,'BorderWidth',0);
iconshade = 0.2;
moveBtnPosOps = {[.05 .55 .4 .4]
    [.05 .05 .4 .4]
    [.55 .55 .4 .4]
    [.55 .05 .4 .4]};
btnIcons = {'up','down','up','down'};
hMoveStage = zeros(4,1);
for iterBtn = 1:4
    hMoveStage(iterBtn) = uicontrol(hPanStage,'style','pushbutton','units','normalized',...
        'Position',moveBtnPosOps{iterBtn},...
        'fontsize',btnFontSize,'fontunits','normalized','enable','on',...
        'backgroundcolor',btnC);
    makePezIcon_curationGUI(hMoveStage(iterBtn),0.7,btnIcons{iterBtn},iconshade,btnC)
end

% Assessment buttons
hPanRaw = uipanel('Parent',hPanA,'Position',guiPos(.515,.05,450,115),...
    'Visible','on','BackgroundColor',textC,'BorderWidth',0);
% assessNames = {'(4/f) Hardware','(5) Heading','(6) Quality','(7) Count','(8) Balancer','(9) Gender'};
assessNames = {'Pez Fail','Fly Fail','Remarks'};
basePos = guiPos(.515,convertH(120),450,textH);
assessCt = numel(assessNames);
colW = ones(assessCt,1);
nameW = basePos(3)/assessCt.*colW;
for iterNames = 1:assessCt
    uicontrol(hPanA,'style','text','units','normalized','HorizontalAlignment','center',...
        'string',assessNames{iterNames},'Position',[sum(nameW(1:iterNames))-nameW(iterNames)+basePos(1),...
        basePos(2) nameW(iterNames) basePos(4)],'backgroundcolor',textC,...
        'fontsize',btnFontSize,'fontunits','normalized','enable','on');
end
% Hardware assessment
assessOps{1} = {'Good';'Short';'FlatLine';'DropFrm';'BadSweep'};
% % Fly detect errors
% assessOps{2} = {'Good';'90degOff';'180degOff'};
% Quality control options
assessOps{3} = {'-----';'ShadowFly';'BadFocus';'90degOff';'180degOff'};
% assessOps{4} = {'Good';'ShadowFly';'BadFocus';'90degOff';'180degOff'};
% Fly count options
assessOps{2} = {'Single';'Multi';'Empty';'Awkward';'StickyWing';'CyO'};
assessRemarks = false(size(assessOps{3}));
% % Gender options
% assessOps{6} = {'Unknown';'Female';'Male'};
wheelPosDefault = cell(1,assessCt);
wheelSelRef = 0;
set(hPanRaw,'userdata',1)
hAssessWheels = zeros(5,assessCt);
btnW = (1)/assessCt.*colW;
btnH = (1-0.05)/5.*[.85 1 1.2 1 .85];
btnFtOps = [7 8 9 8 7];
btnColOpsA = {[.7 .7 .7],[.8 .8 .8],[.9 .9 .9],[.8 .8 .8],[.7 .7 .7]};
btnColOpsB = {[.6 .6 .8],[.7 .7 .9],[.8 .8 1],[.7 .7 .9],[.6 .6 .8]};
for iterCol = 1:assessCt
    strCt = numel(assessOps{iterCol});
    wheelPosDefault{iterCol} = circshift(repmat((1:strCt)',floor(5/strCt)+1,1),[2 0]);
    for iterRow = 1:5
        strRowRef = wheelPosDefault{iterCol}(iterRow);
        posBtn = [sum(btnW(1:iterCol))-btnW(iterCol),...
            sum(btnH(1:iterRow))-btnH(iterRow)+0.05 btnW(iterCol) btnH(iterRow)];
        hAssessWheels(iterRow,iterCol) = uicontrol(hPanRaw,'style','pushbutton',...
            'units','normalized','Position',posBtn,'string',assessOps{iterCol}{strRowRef},...
            'fontsize',btnFtOps(iterRow),'fontunits','normalized','enable','on',...
            'backgroundcolor',btnColOpsA{iterRow},'callback',@assessWheelCall);
    end
    set(hAssessWheels(3,iterCol),'fontweight','bold')
end
wheelPosRefs = wheelPosDefault;

% User defined fail: edit box
uicontrol(hPanA,'style','text','units','normalized','HorizontalAlignment','left',...
    'string','User Input','Position',guiPos(.88,convertH(60)+0.05,140,textH),'backgroundcolor',textC,...
    'fontsize',btnFontSize,'fontunits','normalized','enable','on');
hEditUser = uicontrol(hPanA,'style','edit','units','normalized',...
    'Position',guiPos(.88,.05,140,60),'visible','on','HorizontalAlignment','left',...
    'backgroundcolor',editC,'max',2);

hFinalCall = struct;
hFinalCall.parent = uibuttongroup('parent',hPanA,'position',...
    guiPos(.88,convertH(60+textH)+0.1,140,40),'backgroundcolor',textC,...
    'Title',[],'fontsize',10,'fontunits','normalized');
x1 = 0.05;
bW = (1-x1*2)/2;
hFinalCall.children(1) = uicontrol(hFinalCall.parent,'style','togglebutton',...
    'units','normalized','string','Pass','Position',[x1 .05 bW .9],...
    'fontsize',btnFontSize,'fontunits','normalized','enable','on',...
    'backgroundcolor',btnC);
hFinalCall.children(2) = uicontrol(hFinalCall.parent,'style','togglebutton',...
    'units','normalized','string','Fail','Position',[x1+bW .05 bW .9],...
    'fontsize',btnFontSize,'fontunits','normalized','enable','on',...
    'backgroundcolor',btnC);

videoID = [];
exptID = [];
visStimTest = [];
photoStimTest = [];
assessTable = [];
lrObj = 1;
udObj = 1;
experimentTableData = [];
videoTableData = [];
vidStats = [];
exptInfo = [];
already_saved = [];
assessVars = {'Video_Path','Data_Acquisition','Fly_Count',...
    'Gender','Balancer','Physical_Condition','Analysis_Status',...
    'Fly_Detect_Accuracy','NIDAQ','Raw_Data_Decision','Adjusted_ROI',...
    'Curation_Status','User_Input','Flag_A','Flag_B','Flag_C'};

%% Only Run the Following as a Function !!!
set(hGuiOps.parent,'SelectionChangeFcn',@guiOpsCall)
set(hPrev,'callback',@shiftCall)
set(hNext,'callback',@shiftCall)
set(hMoveROI,'callback',@moveBtnsCall)
set(hMoveStage,'callback',@moveBtnsCall)

%initialize timers
liveRate = 1;%times to be executed per second
tEdit = timer('TimerFcn',@editFocusCall,'ExecutionMode','fixedRate',...
    'Period',round((1/liveRate)*100)/100,'StartDelay',1,'Name','tEdit');
tGam  = timer('TimerFcn',@gammaCallback, 'ExecutionMode','fixedRate','Period',0.1);

disp('Current pez3000 statistics:')
tot_vids = sum(experimentSummary(curr_logic,:).Total_Videos);
tot_curr = sum(experimentSummary(curr_logic,:).Total_Curated);
tot_pass = sum(experimentSummary(curr_logic,:).Total_Passing);
tot_analy = sum(experimentSummary(curr_logic,:).Analysis_Complete);

dummy_data = experimentSummary(curr_logic,:);
dummy_data = dummy_data(dummy_data.Total_Videos - dummy_data.Total_Curated > 0,:);
collect_to_curate = unique(cellfun(@(x) x(1:4), dummy_data.Properties.RowNames,'uniformoutput',false));

disp(['videos: ' num2str(tot_vids) ' (' num2str(tot_vids - tot_curr) ')'])
disp(['curated: ' num2str(tot_curr) ' (' num2str(tot_curr/tot_vids*100) '%)'])
disp(['passing: ' num2str(tot_pass) ' (' num2str(tot_pass/tot_curr*100) '%)'])
disp(['fully analyzed: ' num2str(tot_analy) ' (' num2str(tot_analy/tot_pass*100) '%)'])
disp(collect_to_curate);

curationTally = 0;
hTic = tic;
guiOpsCall
loadPrefs
set(hFigA,'CloseRequestFcn',@myCloseFun,'visible','on')

    function savePrefsCall(~,~)
        [~,host] = system('hostname');
        host = strtrim(regexprep(host,'-','_'));
        prefPath = fullfile(housekeepingDir,['curatorPreferences_' host '.mat']);
        figPos = get(hFigA,'position');
        filterFchecked = get(hFilterMenu,'checked');
        filterFlabel = get(hFilterMenu,'label');
        filterUchecked = get(hUserMenu,'checked');
        filterUlabel = get(hUserMenu,'label');
        curationPrefs = struct('figPos',{figPos},'filterFchecked',...
            {filterFchecked},'filterUchecked',{filterUchecked},...
            'filterFlabel',{filterFlabel},'filterUlabel',{filterUlabel});
        save(prefPath,'curationPrefs')
    end
    function loadPrefs
        [~,host] = system('hostname');
        host = strtrim(regexprep(host,'-','_'));
        prefPath = fullfile(housekeepingDir,['curatorPreferences_' host '.mat']);
        if ~exist(prefPath,'file')
            return
        end
        curationPrefs = load(prefPath);
        curationPrefs = curationPrefs.curationPrefs;
        if ~isfield(curationPrefs,'filterFchecked')
            return
        end
        set(hFigA,'position',curationPrefs.figPos)
        filtOps = curationPrefs.filterFlabel;
        checkedVals = curationPrefs.filterFchecked;
        for iterU = 1:numel(hFilterMenu)
            userLabel = get(hFilterMenu(iterU),'label');
            if max(strcmp(filtOps,userLabel))
                set(hFilterMenu(iterU),'checked',checkedVals{strcmp(filtOps,userLabel)})
                set(hFilterMenu(1),'checked','off')
            end
        end
        filtOps = curationPrefs.filterUlabel;
        checkedVals = curationPrefs.filterUchecked;
        userSaved = filtOps(find(strcmp(checkedVals,'on'),1,'first'));
        userRef = strcmp(get(hUserMenu,'label'),userSaved);
        if ~isempty(userRef)
            filterMenuCall(hUserMenu(userRef))
        else
            filterAction
        end
    end
    function restoreCall(~,~)
        figPos = round([(scrnPos(3:4)-scrnPos(1:2)).*((1-screen2cvr)/2)+scrnPos(1:2),...
            1295 809]);
        set(hFigA,'position',figPos)
        for iterU = 1:numel(hFilterMenu)
            set(hFilterMenu(iterU),'checked','off')
        end
        for iterU = 1:numel(hUserMenu)
            set(hUserMenu(iterU),'checked','off')
        end
    end
    function tableCall(~,~)
        strVal = get(jTable,'SelectedRow')+1;
        if strVal == 0
            strVal = 1;
        end
        hObj = get(hGuiOps.parent,'selectedobject');
        hVal = find(hGuiOps.children == hObj);
        switch hVal
            case 1
                set(hGuiOps.children(3),'enable','on')
                workRef(1) = strVal-1;
            case 2
                set(hGuiOps.children(3),'enable','on')
                workRef(2) = strVal-1;
            case 3
                set(hGuiOps.children(4),'enable','on')
                workRef(3) = strVal-1;
            case 4
                workRef(4) = strVal-1;
                videoPopCall
        end
    end
    function guiOpsCall(~,~)
        hObj = get(hGuiOps.parent,'selectedobject');
        hVal = find(hGuiOps.children == hObj);
        switch hVal
            case 1
                filterAction
                tableData = collectionTableData(showCell{hVal},:);
                widthList = {80 150 100};
                colName = {'ID Number','Collection Name','User'};
                set(hGuiOps.children(4),'enable','off')
                workRef(3:4) = 0;
                displayControl(0)
                set(hGuiOps.parent,'userdata',hObj)
                wheelReset
            case 2
                filterAction
                tableData = groupTableData(showCell{hVal},:);
                widthList = {80+150 100};
                colName = {'Group Name','User'};
                set(hGuiOps.children(4),'enable','off')
                workRef(3:4) = 0;
                displayControl(0)
                set(hGuiOps.parent,'userdata',hObj)
                wheelReset
            case 3
                if get(hGuiOps.parent,'userdata') == hGuiOps.children(1)
                    strList = collectionTableData(showCell{1},1);
                    strOp = strList{workRef(1)+1}(1:4);
                    subExptList = exptIDlist(strcmp(cellfun(@(x) x(1:4),exptIDlist,...
                        'uniformoutput',false),strOp));
                    [~,si] = sort(cellfun(@(x) x(13:16),subExptList,'uniformoutput',false));
                    exptList = subExptList(si)';
                    exptList = cellfun(@(x) strtrim(x),exptList,'uniformoutput',false);
                else
                    exptList = groupData(showCell{2},3);
                    exptList = exptList{workRef(2)+1};
                    exptList = cellfun(@(x) strtrim(x),exptList,'uniformoutput',false);
                end
                exptAvail = experimentSummary.Properties.RowNames;
                exptTest = cellfun(@(x) max(strcmp(exptAvail,x)),exptList);
                exptList(~exptTest) = [];
                experimentTableData = [exptList,num2cell(experimentSummary.Total_Videos(exptList)),...
                    num2cell(experimentSummary.Total_Curated(exptList)),num2cell(experimentSummary.Total_Passing(exptList)),...
                    experimentSummary.Last_Date_Run(exptList),num2cell(experimentSummary.Analysis_Complete(exptList)),...
                    num2cell(experimentSummary.Run_Count(exptList)),experimentSummary.Experiment_Type(exptList),...
                    experimentSummary.UserID(exptList),experimentSummary.Status(exptList)];
                showCell{3} = true(size(experimentTableData,1),1);
                filterAction
                tableData = experimentTableData(showCell{hVal},:);
                widthList = {110,90,90,90,90,90,70,80,75,70};
                
                colName = {'Experiment ID',['Videos (' num2str(sum(cell2mat(experimentTableData(:,2)))) ')'],...
                    ['Curated (' num2str(sum(cell2mat(experimentTableData(:,3)))) ')'],...
                    ['Passing (' num2str(sum(cell2mat(experimentTableData(:,4)))) ')'],...
                    'LastRun',...
                    ['Analyzed (' num2str(sum(cell2mat(experimentTableData(:,6)))) ')'],...
                    ['Runs (' num2str(sum(cell2mat(experimentTableData(:,7)))) ')'],'Type','User','Status'};
                set(hGuiOps.children(4),'enable','on')
                workRef(4) = 0;
                displayControl(0)
                wheelReset
            case 4
                experimentSelect
                filterAction
                tableData = videoTableData(showCell{hVal},:);
                vidTag = ['Video ID  -  showing  ' num2str(workRef(4)+1) ' / ' num2str(sum(showCell{4}))];
                widthList = {320 90 90};
                colName = {vidTag,'Curation Status','Analysis Status'};
        end
        colName = cellfun(@(x,y) strcat('<html><body bgcolor="',htmlcolor,...
            '" width="',num2str(x),'px">',y),widthList,colName,'uniformoutput',false);
        set(hTable,'RowName',[],'ColumnName',colName,'ColumnWidth',widthList,...
            'Data',tableData)
        pause(0.1)
        jTable.changeSelection(0,0,0,0)
        jTable.changeSelection(workRef(hVal),0,0,0)
        tableCall
    end
    function experimentSelect
        strVal = workRef(3)+1;
        strList = experimentTableData(showCell{3},1);
        if strcmp(get(hSessionMenu(1),'checked'),'on')
            if ~already_saved
                saveButtonCall
            end
        end
        exptID = strList{strVal};
        
        assessmentName = [exptID assessmentTag];
        assessmentPath = fullfile(analysisDir,exptID,assessmentName);
        if exist(assessmentPath,'file') == 2
            assessTable_import = load(assessmentPath);
            dataname = fieldnames(assessTable_import);
            assessTable = assessTable_import.(dataname{1});
        else
            error('Assessment table not found')
        end
        vidInfoMergedName = [exptID '_videoStatisticsMerged.mat'];
        vidInfoMergedPath = fullfile(analysisDir,exptID,vidInfoMergedName);
        videoStatisticsMerged = load(vidInfoMergedPath,'videoStatisticsMerged');
        vidStats = videoStatisticsMerged.videoStatisticsMerged;
        exptInfoMergedName = [exptID '_experimentInfoMerged.mat'];
        exptInfoMergedPath = fullfile(analysisDir,exptID,exptInfoMergedName);
        experimentInfoMerged = load(exptInfoMergedPath,'experimentInfoMerged');
        exptInfo = experimentInfoMerged.experimentInfoMerged;
        exptInfo = exptInfo(1,:);
        
        typeList = experimentTableData(showCell{3},8);
        typeStr = typeList{strVal};
        switch typeStr
            case 'Combo'
                visStimTest = true;
                photoStimTest = true;
            case 'Photoactivation'
                visStimTest = false;
                photoStimTest = true;
            case 'Visual_stimulation'
                visStimTest = true;
                photoStimTest = false;
            otherwise
                visStimTest = false;
                photoStimTest = false;
        end
        videoList = assessTable.Properties.RowNames;
        videoTableData = [videoList assessTable.Curation_Status assessTable.Analysis_Status];
        set(hFigA,'color',figCworking)
        videoID = [];
        roiChanged = false;
    end

    function shiftCall(hObj,~)
        selObj = get(hGuiOps.parent,'selectedobject');
        selVal = find(hGuiOps.children == selObj);
        shiftVal = -1;
        if hObj == hNext
            shiftVal = 1;
        end
        workRef(selVal) = workRef(selVal)+shiftVal;
        maxVal = sum(showCell{selVal})-1;
        if workRef(selVal) > maxVal
            workRef(selVal) = 0;
        elseif workRef(selVal) < 0
            workRef(selVal) = maxVal;
        end
        switch selVal
            case 1
                guiOpsCall
            case 2
                guiOpsCall
            case 3
                guiOpsCall
            case 4
                updateTable
                videoPopCall
        end
    end
    
    function videoPopCall(~,~)
        strList = videoTableData(showCell{4},1);
        strVal = workRef(4)+1;
        videoID = strList{strVal};
        examinedNdcs = strcmp(assessTable.Curation_Status(showCell{4}),'Examined');
        savedNdcs = strcmp(assessTable.Curation_Status(showCell{4}),'Saved');
        %if none are empty and hide completed is selected, change the 
        %figure background to green. In this case, some must not be 'saved'
        if min(examinedNdcs+savedNdcs)
            maxVal = sum(showCell{4})-1;
            if workRef(4) == maxVal
                figCdone(2) = abs(((figCdone(2)-.05)/.2)-1)*.2+.05;
                figCdone(1) = abs(((figCdone(2)-.05)/.2)-1)*.2+.05;
            end
            set(hFigA,'color',figCdone)
        else
            figCdone = [.05 0.25 0];
            set(hFigA,'color',figCworking)
        end
        
        montyDir = fullfile(analysisDir,exptID,'montageFrames');
        montyFileName = [videoID '_montage_v2.tif'];
        montyPath = fullfile(montyDir,montyFileName);
        
        imData = imread(montyPath);
        imWntrn = size(imData,2);
        imHntrn = size(imData,1);
        boxRatio_intern = double([imWntrn imHntrn])./double(max(imWntrn,imHntrn));
        boxRatio_intern(3) = 1;
        axPos = get(hAxesOrigRef,'position');
        udlr = [0.3 0.2];%positive values shift right and up, neg are opposite
        newPos = [axPos(3)*udlr(1)+axPos(1) axPos(2)+axPos(4)*udlr(2),...
            axPos(3)*(1-udlr(1)) axPos(4)*(1-udlr(2))];
        set(hAxes{1+hSel},'xlim',[1 imWntrn],'ylim',[1 imHntrn],'position',newPos,...
            'PlotBoxAspectRatio',boxRatio_intern,'YDir','reverse')
%         set(hAxesA,'PlotBoxAspectRatioMode','auto')%uncomment to see true axes position
        set(hImage{1+hSel},'CData',imData);
        set(hText{1+hSel},'color',[1 1 1],'verticalalignment','top')
        
        sampleFrameDir = fullfile(analysisDir,exptID,'sampleFrames');
        sampleFrameName = [videoID '_sampleFrame.tif'];
        sampleFramePath = fullfile(sampleFrameDir,sampleFrameName);
        imData = imread(sampleFramePath);
        imWntrn = size(imData,2);
        imHntrn = size(imData,1);
        boxRatio_intern = double([imWntrn imHntrn])./double(max(imWntrn,imHntrn));
        boxRatio_intern(3) = 1;
        axPos = get(hAxesOrigRef,'position');
        
        newPos = [axPos(1) axPos(2) axPos(3)*(0.3) axPos(4)];
        set(hAxes{2+hSel},'xlim',[1 imWntrn],'ylim',[1 imHntrn],'position',newPos,...
            'PlotBoxAspectRatio',boxRatio_intern,'YDir','reverse')
        set(hImage{2+hSel},'CData',imData,'userdata',double(imData));
%         set(hText{2+hSel}(1),'string',imLabel,'color',[1 1 1],...
%             'verticalalignment','top','position',[10 10 0])
%         set(hText{2+hSel}(2),'string',runDir,'color',[1 1 1],...
%             'verticalalignment','top','position',[10 35 0],'interpreter','none')
%         set(hText{2+hSel}(3),'string',strParts{5},'color',[1 1 1],...
%             'verticalalignment','top','position',[10 60 0],'interpreter','none')
        
        %Show ROI
        tableROI = assessTable.Adjusted_ROI{videoID};
        if ~isempty(tableROI)
            xDataROI = tableROI(:,1);
            yDataROI = tableROI(:,2);
            roiPos = [xDataROI(1),yDataROI(1),xDataROI(3),yDataROI(3)];
        else
            tableROI = double(vidStats.roi{videoID});
            tableROI(6,:) = NaN;
            xDataROI = tableROI(:,1);
            yDataROI = tableROI(:,2);
            roiPos = [xDataROI(1),yDataROI(1),xDataROI(3),yDataROI(3)];
        end
        %making sure the roi is square
        roiW = mean([abs(diff(xDataROI(2:3))),abs(diff(yDataROI(1:2)))]);
        xDataROI([3 4]) = xDataROI(1)+[roiW roiW];
        yDataROI([2 3]) = yDataROI(1)+[roiW roiW];
        xDataROI(7:8) = xDataROI(2:3);
        innerROI = [xDataROI(1:5) yDataROI(1:5)];
        innerROI([1 2 5 6 9 10]) = innerROI([1 2 5 6 9 10])+15;
        innerROI([3 4 7 8]) = innerROI([3 4 7 8])-15;
        xDataROI = [xDataROI;NaN;innerROI(:,1)];
        yDataROI = [yDataROI;NaN;innerROI(:,2)];
        set(hPlot{2+hSel}(1),'XData',xDataROI,'YData',yDataROI,...
            'Marker','none','Color',[0.1 0.3 0.9],'LineStyle','-','linewidth',1.5);
        
        %Display fly detect angle
        avgPrismL = mean([roiPos(3)-roiPos(1),roiPos(4)-roiPos(2)]);
        flyTheta = vidStats.fly_detect_azimuth(videoID)*(pi/180);
        u = cos(flyTheta)*avgPrismL*0.45;
        v = -sin(flyTheta)*avgPrismL*0.45;
        set(hQuiv{2+hSel},'XData',roiPos(1)+avgPrismL/2,'YData',roiPos(2)+avgPrismL/2,...
            'MaxHeadSize',5,'LineWidth',5,'AutoScaleFactor',1,...
            'Color',[0.9 0.3 0.1],'UData',u,'VData',v)
        
        %Plot NIDAQ records
        frmCount = vidStats.frame_count(videoID);
        if visStimTest
            visStimDataStruct = vidStats.visual_stimulus_info{videoID};
            visStimData = double(visStimDataStruct.nidaq_data);
            if isempty(visStimData)
                visStimData = zeros(1,frmCount);
            end
            visStimData = visStimData(:)';
%             visStimData = mean([circshift(visStimData,[0 -1]);visStimData]);
            phBrks = round(linspace(1,frmCount,round(frmCount/100)));
            ranges = zeros(numel(phBrks)-1,1);
            for iterPh = 1:numel(phBrks)-1
                samp_data = visStimData(phBrks(iterPh):phBrks(iterPh+1));
                samp_data = sort(samp_data);
                lower_lim = samp_data(round(length(samp_data)*.25));
                upper_lim = samp_data(round(length(samp_data)*.75));
                ranges(iterPh) = upper_lim - lower_lim;
%                ranges(iterPh) = iqr(visStimData(phBrks(iterPh):phBrks(iterPh+1)));
            end
            avgBase = median(visStimData(1:300));
            avgPeak = median(ranges);
            photoSignalTest = abs(avgPeak/min(ranges));
            if photoSignalTest < 10
                visStimData = abs(visStimData-avgBase(1));
            else
                visStimData = abs(visStimData-avgBase(1))./max(ranges);
            end
            visStimData(visStimData > 0.8) = 0.8;
%             recStart = visStimDataStruct.stim_start;
%             xdata = repmat([recStart recStart],1,11)+linspace(-15,16,22);
%             xdata((2:2:22)) = recStart;
%             ydata = repmat([0 0.5],1,11);
%             ydata(12) = 0.66;
            xData = (1:frmCount);
            set(hPlot{3+hSel}(1),'xdata',xData,'ydata',visStimData,...
                'color',[0.1 0.3 0.9])
%             set(hPlot{3+hSel}(3),'xdata',xdata,'ydata',ydata,...
%                 'color',[0.3 0.9 0.3],'linewidth',1)
        end
        if photoStimTest
            activationDataStruct = vidStats.photoactivation_info{videoID};
%             if max(strcmp(fieldnames(activationDataStruct),'diode_data'))
%                 activationDataRaw = activationDataStruct.diode_data;
%             else
                activationDataRaw = double(activationDataStruct.nidaq_data);
%             end
%             activationData = abs(activationDataRaw-5)./5;
            activationData = (activationDataRaw-min(activationDataRaw))./range(activationDataRaw);
%             recStop = find(activationData < 0.5,1,'last');
%             if isempty(recStop)
%                 recStop = numel(activationData);
%             end
            xData = (1:frmCount);
            set(hPlot{3+hSel}(2),'xdata',xData,'ydata',activationData,...
                'color',[0.1 0.3 0.9])
%             set(hPlot{3+hSel}(3),'xdata',[recStop recStop],'ydata',[0 0.5],...
%                 'color',[0.9 0.3 0.3],'linewidth',3)
        end
        axPos = get(hAxesOrigRef,'position');
        udlr = [0.3 0.18];%positive values shift right and up, neg are opposite
        newPos = [axPos(3)*udlr(1)+axPos(1) axPos(2),...
            axPos(3)*(1-udlr(1)) axPos(4)*(udlr(2))];
        set(hAxes{3+hSel},'xlim',[0 frmCount],'ylim',[-0.1 1.1],'position',newPos)
        
        
        fPos = get(hFigA,'position');
        aPos = get(hAxes{2+hSel},'position');
        relPos = round(fPos(3:4).*aPos(1:2));
        pPos = get(hPanB,'position');
        pOff = aPos(3)/2-pPos(3)/2;
        pPos(1:2) = relPos./fPos(3:4)+[pOff 0];
        set(hPanB,'position',pPos)
        
        %%%%% Update the gui controls
        wheelSel = cell(size(wheelPosRefs,2),1);
        
        %set table with choices
        if strcmp(assessTable.Physical_Condition(videoID),'BadSweep')
            wheelSel(1) = assessTable.Physical_Condition(videoID);
        else
            wheelSel(1) = assessTable.NIDAQ(videoID);
        end
        if strcmp(assessTable.Balancer(videoID),'CyO')
            wheelSel(2) = assessTable.Balancer(videoID);
        elseif max(strcmp({'StickyWing','Awkward'},assessTable.Physical_Condition(videoID)))
            wheelSel(2) = assessTable.Physical_Condition(videoID);
        else
            wheelSel(2) = assessTable.Fly_Count(videoID);
        end
        wheelSel(3) = assessOps{3}(1);
        assessRemarks = false(size(assessOps{3}));
        assessRemarks(strcmp(assessOps{3},assessTable.Physical_Condition(videoID))) = true;
        assessRemarks(strcmp(assessOps{3},assessTable.Fly_Detect_Accuracy(videoID))) = true;
        wheelPosRefs = wheelPosDefault;
        for iterC = 1:size(wheelPosRefs,2)
            if ~isempty(wheelSel{iterC})
                whOff = find(strcmp(assessOps{iterC},wheelSel{iterC}));
                wheelPosRefs{iterC} = circshift(wheelPosRefs{iterC},[-whOff+1 0]);
            end
%             for iterR = 1:5
%                 set(hAssessWheels(iterR,iterC),'backgroundcolor',btnColOpsA{iterR},...
%                     'string',assessOps{iterC}{wheelPosRefs{iterC}(iterR)})
%             end
        end
        wheelCtrl
%         for iterR = 1:5
%             remark = get(hAssessWheels(iterR,size(wheelPosRefs,2)),'string');
%             testA = strcmp(remark,assessTable.Physical_Condition(videoID));
%             testB = strcmp(remark,assessTable.Fly_Detect_Accuracy(videoID));
%             if testA || testB
%                 oldC = get(hAssessWheels(iterR,size(wheelPosRefs,2)),'backgroundcolor');
%                 newC = [oldC(1) oldC(2)+0.1 oldC(1)];
%                 set(hAssessWheels(iterR,size(wheelPosRefs,2)),'backgroundcolor',newC)
%             end
%         end

        set(hEditUser,'string',assessTable.User_Input{videoID});
        if ~isempty(assessTable.Raw_Data_Decision{videoID})
            decision = assessTable.Raw_Data_Decision(videoID);
            decOps = get(hFinalCall.children,'string');
            set(hFinalCall.parent,'selectedobject',hFinalCall.children(strcmp(decOps,decision)))
        else
            set(hFinalCall.parent,'selectedobject',hFinalCall.children(1))
        end
        
        %%%%% Update and show the figure
        displayControl(1)
        gammaCallback
        
        %%%%% Update the table
        vidTag = ['Video ID  -  showing  ' num2str(workRef(4)+1) ' / ' num2str(sum(showCell{4}))];
        widthList = {320 90 90};
        colName = {vidTag,'Curation Status','Analysis Status'};
        colName = cellfun(@(x,y) strcat('<html><body bgcolor="',htmlcolor,...
            '" width="',num2str(x),'px">',y),widthList,colName,'uniformoutput',false);
        set(hTable,'ColumnName',colName)
        pause(0.1)
        jTable.changeSelection(0,0,0,0)
        jTable.changeSelection(workRef(4),0,0,0)
    end
    function displayControl(dispVal)
        if dispVal
            set(hAxes{1+hSel},'visible','on')
            set(hImage{1+hSel},'visible','on')
            set(hAxes{2+hSel},'visible','on')
            set(hImage{2+hSel},'visible','on')
            set(hPlot{2+hSel},'visible','on')
            set(hQuiv{2+hSel},'visible','on')
            set(hAxes{3+hSel},'visible','on')
            if visStimTest
                set(hPlot{3+hSel}(1),'visible','on')
            else
                set(hPlot{3+hSel}(1),'visible','off')
            end
            if photoStimTest
                set(hPlot{3+hSel}(2),'visible','on')
            else
                set(hPlot{3+hSel}(2),'visible','off')
            end
%             set(hPlot{3+hSel}(3),'visible','on')
            set(hPanB,'visible','on')
        else
            set(hAxes{1+hSel},'visible','off')
            set(hImage{1+hSel},'visible','off')
            set(hAxes{2+hSel},'visible','off')
            set(hImage{2+hSel},'visible','off')
            set(hPlot{2+hSel},'visible','off')
            set(hQuiv{2+hSel},'visible','off')
            set(hAxes{3+hSel},'visible','off')
            set(hPlot{3+hSel}(1),'visible','off')
            set(hPlot{3+hSel}(2),'visible','off')
%             set(hPlot{3+hSel}(3),'visible','off')
            set(hPanB,'visible','off')
            set(hFigA,'color',figCworking)
        end
    end
    function updateTable
        if isempty(videoID), return, end
        [~,videoID] = fileparts(videoID);
        
        %getting the strings selected
        updateRemarks
        wheelSel = cell(size(wheelPosRefs,2),1);
        for iterC = 1:size(wheelPosRefs,2)
            iterR = 3;
            wheelSel{iterC} = get(hAssessWheels(iterR,iterC),'string');
        end
        
        %did the video fail?
        failTests = [~strcmp(wheelSel(1),{'Good'})
            ~strcmp(wheelSel(2),{'Single'})];
        if str2double(exptID(13:16)) < 100
            if ~strcmp(wheelSel(1),'BadSweep')
                failTests(1) = false;
            end
        end
        if max(failTests)
            set(hFinalCall.parent,'selectedobject',hFinalCall.children(2))
        end
        
        %set table with choices
        detectFails = {'180degOff','90degOff'};
        wheelSelRmk = assessOps{3}(assessRemarks);
        detectTest = cellfun(@(x) max(strcmp(detectFails,x)),wheelSelRmk);
        if max(detectTest)
            assessTable.Fly_Detect_Accuracy(videoID) = wheelSelRmk(detectTest);
        else
            assessTable.Fly_Detect_Accuracy(videoID) = {'Good'};
        end
        conditionFails = {'BadFocus','ShadowFly'};
        conditionTest = cellfun(@(x) max(strcmp(conditionFails,x)),wheelSelRmk);
        if max(conditionTest)
            assessTable.Physical_Condition(videoID) = wheelSelRmk(conditionTest);
        else
            assessTable.Physical_Condition(videoID) = {'Good'};
        end
        if strcmp(wheelSel(2),'CyO')
            assessTable.Balancer(videoID) = wheelSel(2);
            assessTable.Fly_Count(videoID) = {'Single'};
        elseif max(strcmp({'StickyWing','Awkward'},wheelSel(2)))
            assessTable.Physical_Condition(videoID) = wheelSel(2);
            assessTable.Balancer(videoID) = {'None'};
            assessTable.Fly_Count(videoID) = {'Single'};
        else
            assessTable.Balancer(videoID) = {'None'};
            assessTable.Fly_Count(videoID) = wheelSel(2);
        end
        if isempty(assessTable.Gender{videoID})
            assessTable.Gender(videoID) = {'Unknown'};
        end
        if strcmp(wheelSel(1),'BadSweep')
            assessTable.Physical_Condition(videoID) = wheelSel(1);
            assessTable.NIDAQ(videoID) = {'Good'};
        else
            assessTable.NIDAQ(videoID) = wheelSel(1);
        end
        assessTable.User_Input(videoID) = {cat(2,get(hEditUser,'string'))};
        assessTable.Raw_Data_Decision(videoID) = {get(get(hFinalCall.parent,...
            'selectedobject'),'string')};
        if ~strcmp(assessTable.Curation_Status{videoID},'Saved')
            assessTable.Curation_Status(videoID) = {'Examined'};
        end
        
        rowNames = assessTable(showCell{4},:).Properties.RowNames;
        currRun = videoID;
        currRun = currRun(1:23);
        runNames = cellfun(@(x) x(1:23),rowNames,'uniformoutput',false);
        runBool = strcmp(runNames,currRun);
        vidNums = cellfun(@(x) str2double(x(end-3:end)),rowNames);%,'uniformoutput',false);
        vidBool = vidNums >= str2double(videoID(end-3:end));
        runBool = min(runBool,vidBool);
        roiX = get(hPlot{2+hSel}(1),'XData');
        roiX = roiX(1:8);
        roiY = get(hPlot{2+hSel}(1),'YData');
        roiY = roiY(1:8);
        resetTest = strcmp(get(hSessionMenu(strcmp(get(hSessionMenu,'label'),...
            'Auto Reset Remaining ROI')),'checked'),'on');
        if ~resetTest
            examinedNdcs = strcmp(assessTable.Curation_Status(showCell{4}),'Examined');
            savedNdcs = strcmp(assessTable.Curation_Status(showCell{4}),'Saved');
            runBool = min(runBool,~(examinedNdcs+savedNdcs));
        else
            if ~roiChanged
                emptyNdcs = cellfun(@(x) isempty(x),assessTable.Adjusted_ROI(showCell{4}));
                runBool = min(runBool,emptyNdcs);
            end
        end
        assessTable.Adjusted_ROI(rowNames(runBool)) = repmat({[roiX(:) roiY(:)]},sum(runBool),1);
        assessTable.Adjusted_ROI(videoID) = {[roiX(:) roiY(:)]};
        already_saved = 0;
        roiChanged = false;
    end
    function resetCall(hObj,~)
        switch find(hResetMenu == hObj)
            case 1
                [~,videoID] = fileparts(videoID);
                blankData = cell(1,numel(assessVars));
                assessTable(videoID,:) = cell2table(blankData);
                videoID = [];
                videoPopCall
            case 2
                resetRoi
            case 3
                choice = questdlg('Are you sure?', ...
                    'Reset all work done on this experiment ID', ...
                    'Yes','No','No');
                % Handle response
                if strcmp(choice,'Yes')
                    vidList = assessTable.Properties.RowNames;
                    blankData = cell(numel(vidList),numel(assessVars));
                    assessTable = cell2table(blankData,'RowNames',...
                        vidList,'VariableNames',assessVars);
                    set(hVideoPop,'value',1)
                    videoID = [];
                    set(hGuiOps.children(1),'userdata','...')
                    videoPopCall
                end
        end
    end
    function setChecked(hObj,~)
        if strcmp(get(hObj,'checked'),'off')
            set(hObj,'checked','on')
        else
            set(hObj,'checked','off')
        end
    end
    function autoSaveCall(~,~)
        if strcmp(get(hSessionMenu(1),'checked'),'off')
            set(hSessionMenu(1),'checked','on')
            if strcmp(tEdit.Running,'off'),start(tEdit),end
            keyPressedCall([],struct('getKeyCode',65))
        else
            set(hSessionMenu(1),'checked','off')
            if strcmp(tEdit.Running,'on'),stop(tEdit),end
            wheelReset
        end
    end
    function wheelReset
        lrObj = 0;
        assessRemarks = false(size(assessOps{3}));
        keyPressedCall
        wheelSelRef = 0;
        wheelCtrl
    end
    function saveButtonCall(~,~)
        vidsList = videoTableData(showCell{4},1);
        examinedVids = strcmp(assessTable.Curation_Status(vidsList),'Examined');
        savedList = vidsList(examinedVids);
        passingVids = strcmp(assessTable.Raw_Data_Decision(vidsList),'Pass');
        emptyAnalVids = cellfun(@(x) isempty(x),assessTable.Analysis_Status(vidsList));
        vids2anal = (emptyAnalVids | examinedVids) & passingVids;
        analList = vidsList(vids2anal);
        assessmentName = [exptID assessmentTag];
        assessmentPath = fullfile(analysisDir,exptID,assessmentName);
        curationTally = curationTally+numel(savedList);
        analStr = 'Analysis scheduled';
        assessTable.Analysis_Status(analList) = repmat({analStr},numel(analList),1);
        assessTable.Curation_Status(savedList) = repmat({'Saved'},numel(savedList),1);
        save(assessmentPath,'assessTable')
        expt_results_dir = fullfile(analysisDir,exptID);
        graphTablePath = fullfile(expt_results_dir,[exptID '_dataForVisualization.mat']);
        if exist(graphTablePath,'file')
            graphTableLoading = load(graphTablePath);
            graphTable = graphTableLoading.graphTable;
            if ~isempty(graphTable)
%                if any(contains(graphTable.Properties.VariableNames,'finalStatus'))
                if cellfun(@(x) contains(x,'finalStatus'),graphTable.Properties.VariableNames)
                    graphTable.finalStatus(analList) = assessTable.Analysis_Status(analList);
                    save(graphTablePath,'graphTable')
                end
            end
        end
        disp(['successful save - ' exptID])
        already_saved = 1;
        updateExptSummary
        guiOpsCall
    end
    function updateExptSummary
        savedNdcs = strcmp(assessTable.Curation_Status,'Saved');
        passingNdcs = strcmp(assessTable.Raw_Data_Decision,'Pass');
        experimentSummary = load(exptSumPath);
        experimentSummary = experimentSummary.experimentSummary;
        experimentSummary.Total_Curated(exptID) = sum(savedNdcs);
        experimentSummary.Total_Passing(exptID) = sum(passingNdcs);
        save(exptSumPath,'experimentSummary')
    
%         SaveName = 'experimentSummary.txt';
%         SavePath = fullfile(analysisDir,SaveName);
%         writetable(experimentSummary,SavePath,'WriteRowNames',true)
    end
    function filterMenuCall(hObj,~)
        hGui = get(hGuiOps.parent,'selectedobject');
        if max(strcmp(get(hObj,'label'),get(hFilterMenu,'label')))
            if strcmp(get(hObj,'checked'),'on')
                set(hObj,'checked','off')
            else
                set(hObj,'checked','on')
                if strcmp(get(hObj,'label'),'Hide Curated')
                    set(hFilterMenu(strcmp(get(hFilterMenu,'label'),...
                        'Show Curated Only')),'checked','off')
                elseif strcmp(get(hObj,'label'),'Show Curated Only')
                    set(hFilterMenu(strcmp(get(hFilterMenu,'label'),...
                        'Hide Curated')),'checked','off')
                end
                if strcmp(get(hObj,'label'),'None')
                    for iterU = 1:numel(hFilterMenu)
                        set(hFilterMenu(iterU),'checked','off')
                    end
                    for iterU = 1:numel(hUserMenu)
                        set(hUserMenu(iterU),'checked','off')
                    end
                end
            end
        elseif max(strcmp(get(hObj,'label'),get(hUserMenu,'label')))
            for iterU = 1:numel(hUserMenu)
                set(hUserMenu(iterU),'checked','off')
            end
            set(hObj,'checked','on')
            if strcmp(get(hObj,'label'),'No user selected')
                set(hFilterMenu(end),'checked','off')
            else
                set(hFilterMenu(end),'checked','on')
            end
        end
        filterAction
        workRef(hGuiOps.children == hGui) = 0;
        guiOpsCall
    end
    function filterAction
        hGui = get(hGuiOps.parent,'selectedobject');
        guiVal = find(hGuiOps.children == hGui);
        switch guiVal
            case 1
                showCell{guiVal} = true(size(collectionTableData,1),1);
                if strcmp(get(hFilterMenu(end),'checked'),'on')
                    userID = userStrings{strcmp(get(hUserMenu,'checked'),'on')};
                    showCell{guiVal}(~strcmp(collectionTableData(:,3),userID)) = false;
                end
            case 2
                showCell{guiVal} = true(size(groupTableData,1),1);
                if strcmp(get(hFilterMenu(end),'checked'),'on')
                    userID = userStrings{strcmp(get(hUserMenu,'checked'),'on')};
                    showCell{guiVal}(~strcmp(groupTableData(:,2),userID)) = false;
                end
            case 3
                showCell{guiVal} = true(size(experimentTableData,1),1);
                testComplete = cell2mat(experimentTableData(:,2)) == cell2mat(experimentTableData(:,3));
                testHideCurated = strcmp(get(hFilterMenu(strcmp(get(hFilterMenu,'label'),...
                    'Hide Curated')),'checked'),'on');
                if testHideCurated
                    showCell{guiVal}(testComplete) = false;
                end
                testShowCurated = strcmp(get(hFilterMenu(strcmp(get(hFilterMenu,'label'),...
                    'Show Curated Only')),'checked'),'on');
                if testShowCurated
                    showCell{guiVal}(~testComplete) = false;
                end
                %test if filter removed all options
                if ~max(showCell{guiVal})
                    set(hGuiOps.parent,'selectedobject',get(hGuiOps.parent,'userdata'))
                    guiOpsCall
                end
            case 4
                showCell{guiVal} = true(size(videoTableData,1),1);
                badData = ~strcmp(assessTable.Data_Acquisition,'good');
                showCell{guiVal}(badData) = false;
                assessTable.Curation_Status(badData) = repmat({'Saved'},sum(badData),1);
                assessTable.Raw_Data_Decision(badData) = repmat({'Fail'},sum(badData),1);
                testHideCurated = strcmp(get(hFilterMenu(strcmp(get(hFilterMenu,'label'),...
                    'Hide Curated')),'checked'),'on');
                if testHideCurated
                    showCell{guiVal}(strcmp(videoTableData(:,2),'Saved')) = false;
                end
                testShowCurated = strcmp(get(hFilterMenu(strcmp(get(hFilterMenu,'label'),...
                    'Show Curated Only')),'checked'),'on');
                if testShowCurated
                    showCell{guiVal}(~strcmp(videoTableData(:,2),'Saved')) = false;
                end
                %test if filter removed all options
                %THIS IS FOR FILTER OPTIONS THAT ALSO EXIST AT THE
                %EXPERIMENT LEVEL, VIA THE EXPT SUMMARY VARIABLE
                if ~max(showCell{guiVal})
                    updateExptSummary
                    set(hGuiOps.parent,'selectedobject',hGuiOps.children(3))
                    guiOpsCall
%                     shiftCall(hNext) NO SHIFT YET 
                    set(hGuiOps.parent,'selectedobject',hGuiOps.children(4))
                    guiOpsCall
                    return
                end
                testHideFailed = strcmp(get(hFilterMenu(strcmp(get(hFilterMenu,'label'),...
                    'Hide Failed')),'checked'),'on');
                if testHideFailed
                    failTest = strcmp(assessTable.Raw_Data_Decision(showCell{guiVal}),'Fail');
                    showCell{guiVal}(failTest) = false;
                end
                testShowFailed = strcmp(get(hFilterMenu(strcmp(get(hFilterMenu,'label'),...
                    'Show Failed Only')),'checked'),'on');
                if testShowFailed
                    failTest_1 = strcmp(assessTable.Raw_Data_Decision(showCell{guiVal}),'Fail');
                    failTest_2 = cellfun(@(x) strcmp(x(8:14),'pez3004'),assessTable.Properties.RowNames(showCell{guiVal}));
                    failTest = (failTest_1 & failTest_2); 
                    showCell{guiVal}(~failTest) = false;
                end                
                testShowPassing = strcmp(get(hFilterMenu(strcmp(get(hFilterMenu,'label'),...
                    'Show Passing Only')),'checked'),'on');
                if testShowPassing
                    passTest = strcmp(assessTable.Raw_Data_Decision(showCell{guiVal}),'Pass');
                    showCell{guiVal}(~passTest) = false;
                end
                %test if filter removed all options THE REST...
                if ~max(showCell{guiVal})
                    set(hGuiOps.parent,'selectedobject',hGuiOps.children(3))
                    guiOpsCall
                    shiftCall(hNext) % SHIFT HERE
                    set(hGuiOps.parent,'selectedobject',hGuiOps.children(4))
                    guiOpsCall
                    return
                end
        end
    end
%% Button and keystroke management
    function moveBtnsCall(hObj,~)
        roiX = get(hPlot{2+hSel}(1),'XData');
        roiY = get(hPlot{2+hSel}(1),'YData');
        roiX = roiX(1:8)';
        roiY = roiY(1:8)';
        roiChanged = true;
        if max(hObj == hMoveROI)
            adjVal = 1;
            switch hObj
                case hMoveROI(1)%up
                    roiY(1:5) = roiY(1:5)-adjVal;
                case hMoveROI(2)%down
                    roiY(1:5) = roiY(1:5)+adjVal;
                case hMoveROI(3)%left
                    roiX = roiX+adjVal;
                case hMoveROI(4)%right
                    roiX = roiX-adjVal;
                case hMoveROI(5)%bigger
                    roiX(3:4) = roiX(3:4)+3;
                    roiY([1 4 5]) = roiY([1 4 5])-3;
                case hMoveROI(6)%smaller
                    roiX(3:4) = roiX(3:4)-3;
                    roiY([1 4 5]) = roiY([1 4 5])+3;
            end
        else
            adjVal = 1;
            switch hObj
                case hMoveStage(1) %left side up
                    roiY(7) = roiY(7)-adjVal;
                case hMoveStage(2) %left side down
                    roiY(7) = roiY(7)+adjVal;
                case hMoveStage(3) %right side up
                    roiY(8) = roiY(8)-adjVal;
                case hMoveStage(4) %right side down
                    roiY(8) = roiY(8)+adjVal;
            end
        end
        innerROI = [roiX(1:5) roiY(1:5)];
        innerROI([1 2 5 6 9 10]) = innerROI([1 2 5 6 9 10])+15;
        innerROI([3 4 7 8]) = innerROI([3 4 7 8])-15;
        roiX = [roiX;NaN;innerROI(:,1)];
        roiY = [roiY;NaN;innerROI(:,2)];
        set(hPlot{2+hSel}(1),'XData',roiX,'YData',roiY);
    end
    function keyPressedCall(~,event)
        if nargin == 0
            event.getKeyCode = 0;
        end
%         event.getKeyCode
        switch event.getKeyCode
            case 32 %space bar
                saveButtonCall
            case 77 % 'm'
                if lrObj == 2
                    moveBtnsCall(hMoveROI(5))
                end
            case 76 % 'l'
                if lrObj == 2
                    moveBtnsCall(hMoveROI(6))
                end
            case 37 %left
                switch lrObj
                    case 1
                        shiftCall(hPrev)
                    case 2
                        moveBtnsCall(hMoveROI(4))
                    case 4
                        lrObj = 3;
                    case 5
                        if wheelSelRef > 1
                            wheelSelRef = wheelSelRef-1;
                            wheelCtrl
                        end
                end
            case 39 %right
                switch lrObj
                    case 1
                        shiftCall(hNext)
                    case 2
                        moveBtnsCall(hMoveROI(3))
                    case 3
                        lrObj = 4;
                    case 5
                        if wheelSelRef < size(wheelPosRefs,2)
                            wheelSelRef = wheelSelRef+1;
                            wheelCtrl
                        end
                end
            case 38 %up
                switch udObj
                    case 2
                        moveBtnsCall(hMoveROI(1))
                    case 3
                        if lrObj == 3
                            moveBtnsCall(hMoveStage(1))
                        else
                            moveBtnsCall(hMoveStage(3))
                        end
                    case 5
                        wheelPosRefs{wheelSelRef} = circshift(wheelPosRefs{wheelSelRef},[-1 0]);
                        wheelCtrl
                end
            case 40 %down
                switch udObj
                    case 2
                        moveBtnsCall(hMoveROI(2))
                    case 3
                        if lrObj == 3
                            moveBtnsCall(hMoveStage(2))
                        else
                            moveBtnsCall(hMoveStage(4))
                        end
                    case 5
                        wheelPosRefs{wheelSelRef} = circshift(wheelPosRefs{wheelSelRef},[1 0]);
                        wheelCtrl
                end
            case 97 % '1' on number key pad
                wheelSelRef = 0; wheelCtrl; lrObj = 1; udObj = 1;
            case 98 % '2' on number key pad
                wheelSelRef = 0; wheelCtrl; lrObj = 2; udObj = 2;
            case 99 % '3' on number key pad
                wheelSelRef = 0; wheelCtrl; lrObj = 3; udObj = 3;
            case 100 % '4' on number key pad
                wheelSelRef = 1; wheelCtrl; lrObj = 5; udObj = 5;
            case 101 % '5' on number key pad
                wheelSelRef = 2; wheelCtrl; lrObj = 5; udObj = 5;
            case 102 % '6' on number key pad
                wheelSelRef = 3; wheelCtrl; lrObj = 5; udObj = 5;
            case 103 % '7' on number key pad
                wheelSelRef = 4; wheelCtrl; lrObj = 5; udObj = 5;
            case 104 % '8' on number key pad
%                 wheelSelRef = 5; wheelCtrl; lrObj = 5; udObj = 5;
            case 105 % '9' on number key pad
%                 wheelSelRef = 6; wheelCtrl; lrObj = 5; udObj = 5;
            case 65 % 'a'
                lrObj = 1;
                wheelSelRef = get(hPanRaw,'userdata');
                wheelCtrl;
                udObj = 5;
            case 83 % 's'
                wheelSelRef = 0; wheelCtrl; lrObj = 2; udObj = 2;
            case 68 % 'd'
                wheelSelRef = 0; wheelCtrl; lrObj = 3; udObj = 3;
            case 70 % 'f'
                wheelSelRef = get(hPanRaw,'userdata'); wheelCtrl; lrObj = 5; udObj = 5;
            case 10 % '<return>'
                if udObj == 5 && wheelSelRef == 3
                    updateRemarks
                end
            case 71 % 'g'
                gammaCycle
            case 72 % 'h'
                wheelSelRef = 1; wheelCtrl;
            case 74 % 'j'
                wheelSelRef = 2; wheelCtrl;
            case 75 % 'k'
                wheelSelRef = 3; wheelCtrl;
            case 49 % '1' on main keyboard
                wheelSelRef = 0; wheelCtrl; lrObj = 1; udObj = 1;
            case 50 % '2' on main keyboard
                wheelSelRef = 0; wheelCtrl; lrObj = 2; udObj = 2;
            case 51 % '3' on main keyboard
                wheelSelRef = 0; wheelCtrl; lrObj = 3; udObj = 3;
            case 52 % '4' on main keyboard
                wheelSelRef = 1; wheelCtrl; lrObj = 5; udObj = 5;
            case 53 % '5' on main keyboard
                wheelSelRef = 2; wheelCtrl; lrObj = 5; udObj = 5;
            case 54 % '6' on main keyboard
                wheelSelRef = 3; wheelCtrl; lrObj = 5; udObj = 5;
            case 55 % '7' on main keyboard
                wheelSelRef = 4; wheelCtrl; lrObj = 5; udObj = 5;
            case 56 % '8' on main keyboard
%                 wheelSelRef = 5; wheelCtrl; lrObj = 5; udObj = 5;
            case 57 % '9' on main keyboard
%                 wheelSelRef = 6; wheelCtrl; lrObj = 5; udObj = 5;
            case 67 % 'c'
                if get(hGuiOps.parent,'selectedobject') ~= hGuiOps.children(4)
                    return
                end
                vidsList = videoTableData(showCell{4},1);
                examinedVids = strcmp(assessTable.Curation_Status(vidsList),'Examined');
                failedVids = strcmp(assessTable.Raw_Data_Decision(vidsList),'Fail');
                vids2save = examinedVids & failedVids;
                resetList = vidsList(~vids2save);
                assessTable.Curation_Status(resetList) = repmat({''},numel(resetList),1);
                workRef(4) = 0;
                saveButtonCall
            case 69 % 'e'
                if strcmp(get(hSessionMenu(1),'checked'),'on')
                    return
                end
                set(hGuiOps.parent,'selectedobject',hGuiOps.children(3));
                guiOpsCall
            case 82 % 'r'
                if get(hGuiOps.parent,'selectedobject') ~= hGuiOps.children(4)
                    return
                end
                resetRoi
            case 86 % 'v'
                if strcmp(get(hSessionMenu(1),'checked'),'on')
                    return
                end
                set(hGuiOps.parent,'selectedobject',hGuiOps.children(4));
                guiOpsCall
            case 88 % 'x'
                if get(hGuiOps.parent,'selectedobject') ~= hGuiOps.children(4)
                    return
                elseif get(hFinalCall.parent,'selectedobject') == hFinalCall.children(1)
                    set(hFinalCall.parent,'selectedobject',hFinalCall.children(2))
                else
                    set(hFinalCall.parent,'selectedobject',hFinalCall.children(1))
                end
        end
        set(hPrev,'backgroundcolor',textC)
        set(hNext,'backgroundcolor',textC)
        set(hTextROI,'backgroundcolor',textC)
        set(hPanROI,'backgroundcolor',textC)
        set(hTextStage,'backgroundcolor',textC)
        set(hPanStage,'backgroundcolor',textC)
        if lrObj == 1
            set(hPrev,'backgroundcolor',focusC)
            set(hNext,'backgroundcolor',focusC)
            set(hTextROI,'backgroundcolor',textC)
            set(hPanROI,'backgroundcolor',textC)
            set(hTextStage,'backgroundcolor',textC)
            set(hPanStage,'backgroundcolor',textC)
        elseif lrObj == 2
            set(hTextROI,'backgroundcolor',focusC)
            set(hPanROI,'backgroundcolor',focusC)
            set(hPrev,'backgroundcolor',textC)
            set(hNext,'backgroundcolor',textC)
            set(hTextStage,'backgroundcolor',textC)
            set(hPanStage,'backgroundcolor',textC)
        elseif lrObj == 3 || lrObj == 4
            set(hPrev,'backgroundcolor',textC)
            set(hNext,'backgroundcolor',textC)
            set(hTextROI,'backgroundcolor',textC)
            set(hPanROI,'backgroundcolor',textC)
            set(hTextStage,'backgroundcolor',focusC)
            set(hPanStage,'backgroundcolor',focusC)
        else
            wheelCtrl
        end
    end
    function resetRoi(~,~)
        rowNames = assessTable.Properties.RowNames;
        rowNames = rowNames(showCell{4});
        currRun = videoID;
        currRun = currRun(1:23);
        runNames = cellfun(@(x) x(1:23),rowNames,'uniformoutput',false);
        runBool = strcmp(runNames,currRun);
        vidNums = cellfun(@(x) str2double(x(end-3:end)),rowNames);%,'uniformoutput',false);
        vidBool = vidNums >= str2double(videoID(end-3:end));
        runBool = min(runBool,vidBool);
        assessTable.Adjusted_ROI(rowNames(runBool)) = cell(sum(runBool),1);
        assessTable.Curation_Status(rowNames(runBool)) = cell(sum(runBool),1);
        videoPopCall
    end
    function assessWheelCall(hObj,~)
        [rowRef,colRef] = find(hAssessWheels == hObj);
        wheelPosRefs{colRef} = circshift(wheelPosRefs{colRef},[3-rowRef 0]);
        wheelCtrl
        if colRef == 3
            updateRemarks
        end
    end
    function updateRemarks
        wheelSel = get(hAssessWheels(3,3),'string');
        if strcmp(wheelSel,assessOps{3}{1})
            return
        end
        oldBool = assessRemarks(strcmp(assessOps{3},wheelSel));
        assessRemarks(strcmp(assessOps{3},wheelSel)) = ~oldBool;
        wheelPosRefs{3} = wheelPosDefault{3};
        wheelCtrl
    end
    function wheelCtrl
        if wheelSelRef ~= 0
            set(hPanRaw,'userdata',wheelSelRef)
        end
        for iterC = 1:size(wheelPosRefs,2)
            for iterR = 1:5
                if iterC == wheelSelRef
                    set(hAssessWheels(iterR,iterC),'backgroundcolor',btnColOpsB{iterR},...
                        'string',assessOps{iterC}{wheelPosRefs{iterC}(iterR)})
                else
                    set(hAssessWheels(iterR,iterC),'backgroundcolor',btnColOpsA{iterR},...
                        'string',assessOps{iterC}{wheelPosRefs{iterC}(iterR)})
                end
                
            end
        end
        for iterR = 1:5
            remark = get(hAssessWheels(iterR,size(wheelPosRefs,2)),'string');
            testC = false;
            testC(max(strcmp(assessOps{3}(assessRemarks),remark))) = true;
            if testC
                oldC = get(hAssessWheels(iterR,size(wheelPosRefs,2)),'backgroundcolor');
                newC = [oldC(1) oldC(2)+0.1 oldC(1)];
                set(hAssessWheels(iterR,size(wheelPosRefs,2)),'backgroundcolor',newC)
            end
        end
    end
    function editFocusCall(~,~)
        ptrLoc = get(0,'PointerLocation');
        bounds = get(hFigA,'position');
        ptrTestA = ptrLoc(1) > bounds(1) && ptrLoc(1) < (bounds(1)+bounds(3));
        ptrTestB = ptrLoc(2) > bounds(2) && ptrLoc(2) < (bounds(2)+bounds(4));
        if ptrTestA && ptrTestB
            uicontrol(hEditInput)
        end
        drawnow
    end
    function focusLostCall(~,event)
        try
            oldVal = get(hSessionMenu(1),'checked');
            set(hSessionMenu(1),'checked','off')
            hOpp = (event.getOppositeComponent);
            if max(strcmp(methods(hOpp),'getUIClassID'))
%                 hOpp.getUIClassID
                popTest = strcmp(hOpp.getUIClassID,'ComboBoxUI');
                editTest = strcmp(hOpp.getUIClassID,'TextPaneUI');
                if ~(popTest || editTest)
                    if strcmp(oldVal,'on')
                        set(hSessionMenu(1),'checked','off')
                    else
                        set(hSessionMenu(1),'checked','on')
                    end
                end
            end
            autoSaveCall
        catch
        end
    end
%% gamma slider functions
    function GammaClickCallback(~,~)
        set(hSessionMenu(1),'checked','off')
        autoSaveCall
        start(tGam)
    end
    function GammaReleaseCallback(~,~)
        stop(tGam)
    end
    function gammaCallback(~,~)
        gammaVal = get(hCgamma,'Value');
        im = (get(hImage{2+hSel},'userdata'));
        im(:,:,2:3) = im(:,:,2:3).^gammaVal;
        backGr = uint8(im(:,:,1)-im(:,:,2));
        backGr = double(backGr).^(gammaVal+0.75);
        im(:,:,1) = im(:,:,2)+backGr;
        set(hImage{2+hSel},'cdata',uint8(im))
        drawnow
    end
    function gammaCycle
        gammaVal = get(hCgamma,'Value');
        gammaVal = ceil(gammaVal*2)/2+0.5;
        if gammaVal > 2
            gammaResetCallback
        else
            set(hCgamma,'Value',gammaVal)
            gammaCallback
        end
    end
    function gammaResetCallback(~,~)
        set(hCgamma,'Value',1)
        gammaCallback([],[])
    end
%% Close and clean up
    function myCloseFun(~,~)
        if curationTally > 1000
            disp([num2str(curationTally) ' videos curated this session!!!'])
            disp('Congratulations...you win!!!')
        else
            disp([num2str(curationTally) ' videos curated this session'])
        end
        currPerHr = round((curationTally/toc(hTic))*60*60);
        disp(['Curation rate: ' num2str(currPerHr) ' per hour'])
        if strcmp(get(hSessionMenu(1),'checked'),'on')
            if ~already_saved
                saveButtonCall
            end
        end
        
        if strcmp(tEdit.Running,'on'),stop(tEdit),end
        if strcmp(tGam.Running,'on'),stop(tGam),end
        
        delete(tEdit)
        delete(tGam)
        delete(hFigA)
    end
end