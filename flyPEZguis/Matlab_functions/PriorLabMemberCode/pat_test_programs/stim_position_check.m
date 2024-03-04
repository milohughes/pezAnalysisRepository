function stim_position_check
    archDir = [filesep filesep 'dm11' filesep 'cardlab'];
    dm11Dir = [filesep filesep 'dm11' filesep 'cardlab'];
    analysisDir = fullfile(archDir,'Data_pez3000_analyzed');
    data_path = '\\DM11\cardlab\Data_pez3000';
    guiVarDir = fullfile(dm11Dir,'Pez3000_Gui_folder','Gui_saved_variables');
    
    repositoryDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repositoryDir,'Support_Programs'))    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    exptSumName = 'experimentSummary.mat';
    exptSumPath = fullfile(analysisDir,exptSumName);
    experimentSummary = load(exptSumPath);
    experimentSummary = experimentSummary.experimentSummary;   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    try
        poolobj = parpool;
    catch
        poolobj = gcp;
    end    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
    collectionTableData = [];        userNames = [];              exptIDlist = [];            groupTableData = [];
    experimentTableData = [];        videoTableData = [];         jTable = [];
    pannel_num = 12;                  data_to_use = [];            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    btnFontSize = 8;                        btnH = [30 22];                         btnC = [.8 .8 .8];
    workRef = zeros(1,4);                   showCell = cell(1,4);                   videoID = [];
    vidStats = [];                          vidObjCell = cell(2,1);                 frameReferenceMesh = [];                
    htmlcolor = sprintf('rgb(%d,%d,%d)', round(btnC*255));                          exptID = [];   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figPos = [129 81 1494 1050];
    figCworking = [0.05 0 0.25];
    figureTitle = 'Wing Lift Tracking - PMB';
    hFigA = figure('NumberTitle','off','Name',figureTitle,'menubar','none','units','pix','Color',figCworking,'pos',figPos,'visible','on',...
        'CloseRequestFcn',@close_graph);
    hPanA = uipanel('Parent',hFigA,'Position',[.01 .01 .98 .18],'Visible','on','BackgroundColor',[0.2 0.2 0.2],'BorderWidth',0);
    
    x_spacing = (.980-(.01*4))/4;   y_spacing = (.780-(.01*3))/3;
    index = 1;
    for iterI = 1:3
        for iterP = 1:4
            x_cord = (iterP-1)*(x_spacing+.01)+.01;            y_cord = (3-iterI)*(y_spacing+.01)+.20;
            hAxes_Im{index} = axes('Parent',hFigA,'Position',[x_cord y_cord x_spacing y_spacing],'color',rgb('black'),'tickdir','in','nextplot','add','xticklabel',[],'yticklabel',[],...
                'visible','on','Ydir','reverse');
            index = index + 1;
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figPos = get(hFigA,'position');                     panPos = get(hPanA,'position');    
    relSize = round(figPos.*panPos);
    guiPos = @(x,y,w,h) cat(2,[x,y],[w,h]./relSize(3:4));
    convertW = @(w) w/relSize(3);           %convertH = @(h) h/relSize(4);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hTable = uitable('Parent',hPanA,'units','normalized','position',guiPos(.01+convertW(125),.05,450,132),'backgroundcolor',[.9 .9 .9],'CellSelectionCallback',@tableCall);
    htmlcolor = sprintf('rgb(%d,%d,%d)', round(btnC*255));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hGuiOps.parent = uibuttongroup('parent',hPanA,'position',guiPos(.01,.2,120,110),'backgroundcolor',[.8 .8 .8],'Title',[],'fontsize',10,'fontunits','normalized');
    y1 = 0.05;                      bH = (1-y1*2)/4;
    opStrings = {'Collections','Groups','Experiments','Videos'};
    for iterSel = 1:4
        hGuiOps.children(iterSel) = uicontrol(hGuiOps.parent,'style','togglebutton','units','normalized','string',opStrings{iterSel},...
            'Position',[.05 1-y1-bH*iterSel .90 bH],'fontsize',btnFontSize,'fontunits','normalized','enable','on','backgroundcolor',btnC);
    end
    set(hGuiOps.children(4),'enable','off')
    set(hGuiOps.parent,'SelectionChangeFcn',@guiOpsCall)    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    hNext = uicontrol(hPanA,'style','pushbutton','units','normalized','string','Next','Position',guiPos(.01+convertW(60),.05,60,btnH(2)),...
        'fontsize',btnFontSize,'fontunits','normalized','enable','on','backgroundcolor',btnC);
    hPrev = uicontrol(hPanA,'style','pushbutton','units','normalized','string','Prev','Position',guiPos(.01,.05,60,btnH(2)),...
        'fontsize',btnFontSize,'fontunits','normalized','enable','on','backgroundcolor',btnC);
    
    set(hPrev,'callback',@shiftCall)
    set(hNext,'callback',@shiftCall)    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
% Filters menu
    hmFilter = uimenu(hFigA,'Label','Data Filters');
    filterStrings = {'None','Hide Curated','Show Curated Only','Hide Failed',...
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    make_collect_table;
    make_group_table;
    set_java;
    guiOpsCall
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    function make_collect_table(~,~)
        colSaved = load(fullfile(guiVarDir,'Saved_Collection.mat'));
        datanameLoad = fieldnames(colSaved);
        colSaved = colSaved.(datanameLoad{1});

        exptIDlist = dir(analysisDir);
        exptIDexist = cell2mat({exptIDlist(:).isdir});
        exptIDlengthTest = cellfun(@(x) numel(x) == 16,{exptIDlist(:).name});
        exptIDlist = {exptIDlist(min(exptIDexist,exptIDlengthTest)).name};
        colIDlist = unique(cellfun(@(x) x(1:4),exptIDlist,'uniformoutput',false));
        colNames = colSaved.Collection_Name(colIDlist);
        colUsers = colSaved.User_ID(colIDlist);
        collectionTableData = [colIDlist(:),colNames(:),colUsers(:)];
        
        collectionTableData = collectionTableData(cellfun(@(x) str2double(x) >= 85,collectionTableData(:,1)),:);
        userNames = unique(colUsers);
    end
    function make_group_table(~,~)
        groupData = load(fullfile(guiVarDir,'Saved_Group_IDs_table.mat'));
        groupData = groupData.Saved_Group_IDs;
        groupNames = groupData.Properties.RowNames;
        groupUsers = groupData.User_ID;
        groupExpts = groupData.Experiment_IDs;

        groupData = [groupNames,groupUsers,groupExpts];
        groupTableData = groupData(:,1:2);  
    end    
    function set_java
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

        hTableChildren = get(jScroll,'Components');
        set(get(hTableChildren(4),'View'),'Background',java.awt.Color(0.8,0.8,0.8));    %background of top header
        set(hTableChildren(1),'Background',java.awt.Color(0.8,0.8,0.8));                %background for empty part of table
        set(jTable,'GridColor',java.awt.Color(0.6,0.6,0.6))                             %colors on table
        set(jTable,'SelectionBackground',java.awt.Color(0.8,0.8,1))
        set(jTable,'SelectionForeground',java.awt.Color(0,0,0));       
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    function guiOpsCall(~,~)
        hObj = get(hGuiOps.parent,'selectedobject');
        hVal = find(hGuiOps.children == hObj);
        switch hVal
            case 1
                filterAction
                tableData = collectionTableData(showCell{hVal},:);
                widthList = {75 250 120};
                colName = {'ID Number','Collection Name','User'};
                set(hGuiOps.children(4),'enable','off')
                workRef(3:4) = 0;
                set(hGuiOps.parent,'userdata',hObj)
            case 2
                filterAction
                tableData = groupTableData(showCell{hVal},:);
                widthList = {80+150 100};
                colName = {'Group Name','User'};
                set(hGuiOps.children(4),'enable','off')
                workRef(3:4) = 0;
                set(hGuiOps.parent,'userdata',hObj)
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
            case 4
                experimentSelect
                filterAction
                tableData = videoTableData(showCell{hVal},:);
                vidTag = ['Video ID  -  showing  ' num2str(workRef(4)+1) ' / ' num2str(sum(showCell{4}))];
                widthList = {400};
                colName = {vidTag};
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
        videoID = [];
        strVal = workRef(3)+1;
        strList = experimentTableData(showCell{3},1);
        exptID = strList{strVal};
        
        test_data = Experiment_ID(exptID);
        test_data.load_data;
        test_data.load_tracking;
        
        data_to_use = test_data.Complete_usuable_data;
        remove_fails = ~strcmp(data_to_use.Fly_Count,'Single');
        data_to_use(remove_fails,:) = [];
        
        data_to_use = data_to_use(cellfun(@(x) ~isempty(x), data_to_use.frame_of_leg_push),:);
        data_to_use = data_to_use(cellfun(@(x) ~isnan(x), data_to_use.frame_of_leg_push),:);
        
        reorder_list = cellfun(@(x) sprintf('%s_%s_%s',x(16:23),x(1:14),x(24:end)),data_to_use.Properties.RowNames,'uniformoutput',false);
        [~,sort_idx] = sort(reorder_list);
        data_to_use = data_to_use(sort_idx,:);
                       
        videoList = data_to_use.Properties.RowNames;
        videoTableData = videoList;
        set(hFigA,'color',figCworking)
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
    function videoPopCall(~,~)
        frameReferenceMesh = [];
        hIm = [];
        strList = videoTableData(showCell{4},1);
        strVal = workRef(4)+1;
        videoID = strList{strVal};        
        
        vid_name = videoID;
        vid_date = vid_name(16:23);
        vid_run = vid_name(1:23);
        
        vidStats = load([analysisDir filesep vid_name(29:44) filesep vid_name(29:44) '_videoStatisticsMerged.mat']);
        vidStats =  vidStats.videoStatisticsMerged;
        
        assess_table = load([analysisDir filesep vid_name(29:44) filesep vid_name(29:44) '_rawDataAssessment']);
        assess_table = assess_table.assessTable;
        
        temp_vidStats = vidStats(videoID,:);   
        
        fullPath_parital = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,[vid_name,'.mp4']);
        fullPath_supplement = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,'highSpeedSupplement',[vid_name,'_supplement.mp4']);
        
        vidObj_partail = VideoReader(fullPath_parital);
        try
            vidObj_supplement = VideoReader(fullPath_supplement);
        catch
            vidObj_supplement = vidObj_partail;
        end
        
        vidObjCell{1} = vidObj_partail;
        vidObjCell{2} = vidObj_supplement;

        frameRefcutrate = double(temp_vidStats.cutrate10th_frame_reference{1});
        frameReffullrate = double(temp_vidStats.supplement_frame_reference{1});
        
        vidWidth = vidObj_partail.Width;        
        vidHeight = vidObj_partail.Height;        
        vidFrames_partial = vidObj_partail.NumberOfFrames; %#ok<VIDREAD>
        
        offset = vidHeight - vidWidth;
        
        Y = (1:numel(frameRefcutrate));
        xi = (1:(vidFrames_partial*10));
        yi = repmat(Y,10,1);
        yi = yi(:);
        [~,xSuppl] = ismember(frameReffullrate,xi);
        objRefVec = ones(1,(vidFrames_partial*10));
        objRefVec(xSuppl) = 2;
        yi(xSuppl) = (1:length(frameReffullrate));
        frameReferenceMesh = [xi(:),yi(:),objRefVec(:)];   
        
        wing_lift = cell2mat(data_to_use(videoID,:).frame_of_wing_movement);
        down_stroke = cell2mat(data_to_use(videoID,:).wing_down_stroke);
        frame_vector = [wing_lift,(down_stroke-100):10:down_stroke];
%        frame_vector = round(linspace(cell2mat(data_to_use(videoID,:).frame_of_wing_movement),cell2mat(data_to_use(videoID,:).wing_down_stroke),9));
        
        frameReferenceMesh = frameReferenceMesh(ismember(frameReferenceMesh(:,1),frame_vector),:);
        adj_roi = assess_table(videoID,:).Adjusted_ROI{1};
        
        if isempty(adj_roi)
            roi = cell2mat(vidStats(videoID,:).roi);
        else
            roi = adj_roi;
        end

        for iterZ = 1:pannel_num
            frmData = read(vidObjCell{frameReferenceMesh(iterZ,3)},frameReferenceMesh(iterZ,2));
            tI = log(double(frmData)+15);
            frmAdj = uint8(255*(tI/log(265)-log(15)/log(265)));
            [~,frm_graymap] = gray2ind(frmAdj,256);
            tol = [0 0.9999];                   gammaAdj = 0.75;
            lowhigh_in = stretchlim(frmAdj,tol);
            lowhigh_in(1) = 0.01;
            frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],gammaAdj);
            frm_remap = uint8(frm_remap(:,1).*255);
            frmData = intlut(frmAdj,frm_remap);            
            hIm(iterZ) = image('Parent',hAxes_Im{iterZ},'CData',frmData(1:offset,:,:));
            set(hIm(iterZ),'ButtonDownFcn',@clickpoints);
            set(hAxes_Im{iterZ},'Xlim',[-1 vidWidth+2],'Ylim',[-1 vidWidth+2])
            text(vidWidth/2,20,sprintf('%4.0f', frame_vector(iterZ)),'horizontalalignment','center','color',rgb('white'),'parent',hAxes_Im{iterZ});
            line([roi(7,1) roi(8,1)],[roi(7,2) roi(8,2)],'parent',hAxes_Im{iterZ},'Tag','roi line','color',[0 1 0]);
        end
        pause(0.1)
        jTable.changeSelection(0,0,0,0)
        jTable.changeSelection(workRef(4),0,0,0)        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
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
%                vid_index = find(ismember(videoTableData(showCell{4},1),videoID),1,'first');
                videoPopCall
        end
    end
    function clickpoints(objectHandle,~)
        axesHandle  = get(objectHandle,'Parent');
        coordinates = get(axesHandle,'CurrentPoint'); 
        coordinates = coordinates(1,1:2);
        warning('this work?');
        plot(coordinates(1),coordinates(2),'b*')
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function close_graph(~,~)
        try
            delete(poolobj);
        catch
        end
        delete(hFigA)
    end
end