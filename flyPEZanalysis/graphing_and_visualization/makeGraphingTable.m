function graphTable = makeGraphingTable
%%
if isempty(mfilename)
    clearvars
    showRemoved = 1;
else
    showRemoved = 0;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% set to value of 1 to set dist thresh from vector start
%%%% set to value of 0 to set dist thresh based on stimulus
mvntFromStart = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% METHODS PAPER
excelDir = '\\dm11\cardlab\pez3000_methods_paper';
% excelName = 'pez_consistency.xlsx';
% excelName = 'expts_in_mings_paper.xlsx';
% excelName = 'methods_paper_activation.xlsx';
excelName = 'DL_psychophys.xlsx';
% excelName = 'counted_flies.xlsx';
% excelName = 'LC4_LC6_GF_DL_methodspaper.xlsx';
% excelDir = 'Z:\WryanW\martin4ryan';
% excelName = 'martin4ryan.xlsx';
% excelDir = 'Z:\Martin\flypez_analysis\thesis_analysis\experimental_group_tables';
% excelName = 'peekm_dn_silencing_screen_info.xlsx';

% excelDir = 'Z:\WryanW\flyPez_experiment_management';
% excelName = 'LPLC2_for_reiser.xlsx';
% excelName = 'photoactivation_tuning.xlsx';
% excelName = 'fixing.xlsx';
% excelName = 'low_activation_DI.xlsx';
% excelName = 'mai_collaboration.xlsx';
% excelName = 'CX_screen.xlsx';
% excelName = 'LPLC2_exploration.xlsx';
% excelDir = 'C:\Users\williamsonw\Documents';
% excelName = 'DI.xlsx';
%excelDir = '\\dm11\cardlab\WryanW\LC6-LC4_manuscript';
%excelName = 'LC4_LC6_GF_DL_oldBackup.xlsx';
excelPath = fullfile(excelDir,excelName);
makeGraphOptionsStruct(excelPath)
%%
dataTable = loadDataTable;
optionsPath = '\\dm11\cardlab\Data_pez3000_analyzed\WRW_graphing_variables\graphOptions.mat';
graphOptions = load(optionsPath);
graphOptions = graphOptions.graphOptions;
useManual = graphOptions.useManual;
excelPath = graphOptions.excelPath;
sheetName = graphOptions.exptSheet;
sliceOption = graphOptions.sliceOption;
excelTable = readtable(excelPath,'ReadRowNames',true,'Sheet',sheetName);
excelVarNames = excelTable.Properties.VariableNames;
if max(strcmp(excelVarNames,graphOptions.unique_label)) == 0
    error('specified unique_label not found in excel file exptIDsheet')
end
excelVarNames{strcmp(excelVarNames,graphOptions.unique_label)} = 'unique_label';
excelTable.Properties.VariableNames = excelVarNames;
exptIDlist = excelTable.Properties.RowNames;
exptIDlist = cellfun(@(x) x(4:end),exptIDlist,'uniformoutput',false);
excelTable(cellfun(@(x) numel(x),exptIDlist) ~= 16,:) = [];
exptIDlist = excelTable.Properties.RowNames;
exptCt = numel(exptIDlist);
graphIDlist = unique(excelTable.unique_label);
graphCt = numel(graphIDlist);

vidList = dataTable.Properties.RowNames;
dataExptIDs = cellfun(@(x) x(29:44),vidList,'uniformoutput',false);
if sliceOption > 1
    dataTable.elevation = zeros(size(dataTable,1),1);
end
for iterE = 1:exptCt
    exptID = exptIDlist{iterE}(4:end);
    labelNdx = strcmp(dataExptIDs,exptID);
    dataTable.unique_label(labelNdx) = repmat(excelTable.unique_label(['ID#' exptID]),sum(labelNdx),1);
    if sliceOption > 1
        if max(strcmp(excelTable.Properties.VariableNames,'sliceOp_azi'))
            dataTable.sliceOp(labelNdx) = repmat(excelTable.sliceOp_azi(['ID#' exptID]),sum(labelNdx),1);
            dataTable.elevation(labelNdx) = repmat(excelTable.elevation(['ID#' exptID]),sum(labelNdx),1);
        else
            dataTable.sliceOp(labelNdx) = ones(sum(labelNdx),1);
        end
    elseif sliceOption == -1
        if max(strcmp(excelTable.Properties.VariableNames,'sliceOp_lv'))
            dataTable.sliceOp(labelNdx) = repmat(excelTable.sliceOp_lv(['ID#' exptID]),sum(labelNdx),1);
        else
            dataTable.sliceOp(labelNdx) = ones(sum(labelNdx),1);
        end
    end
    if strcmp(excelTable.Experiment_Type{['ID#' exptID]},'Combo')
        dataTable.stimInfo(labelNdx) = repmat(excelTable.activation1(['ID#' exptID]),sum(labelNdx),1);
    end
end

if sliceOption == 1
    if ~max(strcmp(excelTable.Properties.VariableNames,'activation2'))
        error('activation2 is not available')
    end
    actList = unique(cat(1,excelTable.activation1,excelTable.activation2,excelTable.activation3));
    actList(strcmp(actList,'None')) = [];
    if ~(numel(unique(excelTable.activation1)) > 1 || numel(actList) > 1)
        error('multiple stimuli not detected')
    end
    ids2keep = strcmp(excelTable.Experiment_Type,'Photoactivation');
    ids2keep = strcmp(excelTable.Experiment_Type,'Combo') | ids2keep;
    activationIDs = exptIDlist(ids2keep);
    activationIDs = cellfun(@(x) x(4:end),activationIDs,'uniformoutput',false);
    vidList = dataTable.Properties.RowNames;
    dataExptIDs = cellfun(@(x) x(29:44),vidList,'uniformoutput',false);
    activationNdx = cellfun(@(x) max(strcmp(activationIDs,x)),dataExptIDs);
    try
        actKey = readtable(excelPath,'ReadRowNames',false,'Sheet','activation_key');
    catch
        try
            actList = cat(1,{'None'},actList(:));
            newList = cat(1,{'unknown'},cell(numel(actList)-1,1));
            writetable(cell2table([actList newList],'VariableNames',{'oldName','newName'}),excelPath,...
                'Sheet','activation_key','WriteVariableNames',true)
        catch
            disp('Please close excel file and rerun')
        end
        disp({'Please complete the activation key using ''unknown'' as newName',...
            'for protocols to omit and then rerun code'}')
        return
    end
    actKey = table2cell(actKey);
    actKey = actKey(:,1:2);
    for iterR = 1:size(actKey,1)
        actIndex = cellfun(@(x) ~isempty(strfind(x,actKey{iterR,1})),dataTable.stimInfo);
        dataTable.stimInfo(actIndex) = repmat(actKey(iterR,2),sum(actIndex),1);
    end
    dataTable.unique_label(activationNdx) = cellfun(@(x,y) cat(2,x,'_',y),dataTable.unique_label(activationNdx),dataTable.stimInfo(activationNdx),'uniformoutput',false);
    dataTable.unique_label(~activationNdx) = cellfun(@(x,y) cat(2,x,'_noActivation'),dataTable.unique_label(~activationNdx),'uniformoutput',false);
    dataTable(strcmp(dataTable.stimInfo,'unknown'),:) = [];
    graphIDlist = unique(dataTable.unique_label);
    
elseif sliceOption > 1
    aziGrpCt = sliceOption;% 5 or 7 is recommended ... 13 works too
    overCell = cell(graphCt,aziGrpCt);
    for iterG = 1:graphCt
        sliceBool = dataTable.sliceOp;
        stimInit = dataTable.zeroFly_StimAtStimStart;
        graphID = graphIDlist{iterG};
        groupLogical = strcmp(dataTable.unique_label,graphID);
        elevationVec = dataTable.elevation(groupLogical);
        if ~isempty(strfind(graphOptions.sheetName,'fieldMap'))
            if nanmedian(elevationVec) > 60
                aziGrpCt = 3;
            elseif nanmedian(elevationVec) > 30
                aziGrpCt = 5;
            else
                aziGrpCt = 7;
            end
        end
        aziBreaks = linspace(0,180,aziGrpCt*2-1);
        aziNames = aziBreaks(1:2:aziGrpCt*2-1);
        aziBreaks = [aziBreaks(1) aziBreaks(1,2:2:aziGrpCt*2-1) aziBreaks(end)];
        for iterA = 1:aziGrpCt
            aziNdcs = stimInit > aziBreaks(iterA) & stimInit <= aziBreaks(iterA+1) & groupLogical & sliceBool;
            if ~isempty(strfind(graphOptions.sheetName,'fieldMap'))
%                 overlap = median(diff(aziNames))/2;
                overlap = 0;
            else
                overlap = 0;
            end
            graphIDcell = repmat({[graphID '_azi' num2str(aziNames(iterA))]},sum(aziNdcs),1);
            dataTable.unique_label(aziNdcs) = graphIDcell;
            aziNdcsOver = stimInit > aziBreaks(iterA)-overlap & stimInit <= aziBreaks(iterA+1)+overlap & groupLogical & sliceBool;
            aziNdcsOver = aziNdcsOver & ~aziNdcs;
            dataTableOver = dataTable(aziNdcsOver,:);
            dataTableOver.Properties.RowNames = cellfun(@(x) cat(2,x,'_overlap'),dataTableOver.Properties.RowNames,'uniformoutput',false);
            graphIDcell = repmat({[graphID '_azi' num2str(aziNames(iterA))]},sum(aziNdcsOver),1);
            dataTableOver.unique_label = graphIDcell;
            overCell{iterG,iterA} = dataTableOver;
        end
        groupLogical = strcmp(dataTable.unique_label,graphID);
        dataTable(groupLogical & sliceBool,:) = [];
    end
    dataTable = [dataTable;cat(1,overCell{:})];
    graphIDlist = unique(dataTable.unique_label);
elseif sliceOption == -1
    fot = dataTable.manualFot;
%     fowu_fowd_folp = cell2mat(dataTable.manual_wingup_wingdwn_legpush);
    fowu = cellfun(@(x) x(1),dataTable.manual_wingup_wingdwn_legpush);
    shortThresh = 41;
    shortLogical = (fot-fowu) <= shortThresh;%41
    longLogical = (fot-fowu) > shortThresh;% 30 200
    longLogical(isnan(longLogical)) = false;
    shortLogical(isnan(shortLogical)) = false;
    if max(strcmp(dataTable.Properties.VariableNames,'sliceOp'))
        sliceBool = dataTable.sliceOp;
    else
        sliceBool = true(size(dataTable,1),1);
    end
    shortLogical = shortLogical & sliceBool;
    longLogical = longLogical & sliceBool;
    dataTable.unique_label(shortLogical) = cellfun(@(x) cat(2,x,'_short'),dataTable.unique_label(shortLogical),'uniformoutput',false);
    dataTable.unique_label(longLogical) = cellfun(@(x) cat(2,x,'_long'),dataTable.unique_label(longLogical),'uniformoutput',false);
    dataTable((~(shortLogical | longLogical) & sliceBool),:) = [];
    graphIDlist = unique(dataTable.unique_label);
    
end
graphIDlist(cellfun(@(x) contains(x,'omit'),graphIDlist)) = [];
graphCt = numel(graphIDlist);
%% 

% table variables that might not save to excel
videoList = cell(graphCt,1);
exptIDs = cell(graphCt,1);
jumpTest = cell(graphCt,1);
shortTest = cell(graphCt,1);
moveTest = cell(graphCt,1);
nonMovers = cell(graphCt,1);
earlyMovers = cell(graphCt,1);
fowu_fowd_folp = cell(graphCt,1);
jumpEnd = cell(graphCt,1);
trkEnd = cell(graphCt,1);
maxVelInfo = cell(graphCt,1);
stimInfo = cell(graphCt,1);
stimStart = cell(graphCt,1);
zeroFly_XYZmm_Tdeg_fac1000 = cell(graphCt,1);
dist_speed_accel_fac100 = cell(graphCt,1);
zeroFly_Trajectory = cell(graphCt,1);
zeroFly_Jump = cell(graphCt,1);
zeroFly_Departure = cell(graphCt,1);
zeroFly_StimAtStimStart = cell(graphCt,1);
zeroFly_StimAtJump = cell(graphCt,1);
zeroFly_StimAtFrmOne = cell(graphCt,1);
rawFly_XYZpix_Trad_frmOne = cell(graphCt,1);
distFromCenter_pix = cell(graphCt,1);
relMotion_FB_LR_Tdeg_fac100 = cell(graphCt,1);
relPosition_FB_LR_Tdeg_fac100 = cell(graphCt,1);
lvList = cell(graphCt,1);
flyLength_mm = cell(graphCt,1);
groupID = cell(graphCt,1);
plotID = cell(graphCt,1);

% table variable that can save to excel
dataCount = zeros(graphCt,1);
vidCount = zeros(graphCt,1);
plotCount = zeros(graphCt,1);
jumpCount = zeros(graphCt,1);
manCount = zeros(graphCt,1);
recordRate = zeros(graphCt,1);
stimDur = zeros(graphCt,1);
elevation = zeros(graphCt,1);
azimuth = zeros(graphCt,1);
startSize = zeros(graphCt,1);
stopSize = zeros(graphCt,1);
lv = zeros(graphCt,1);
contrast = cell(graphCt,1);
width = zeros(graphCt,1);
frequency = zeros(graphCt,1);
genotype = cell(graphCt,1);
stimType = cell(graphCt,1);
visStimType = cell(graphCt,1);
order = zeros(graphCt,1);
repeat = zeros(graphCt,1);

graphTable = table(elevation,azimuth,startSize,stopSize,lv,contrast,width,frequency,genotype,...
    vidCount,dataCount,plotCount,jumpCount,manCount,recordRate,stimDur,videoList,exptIDs,...
    jumpTest,shortTest,moveTest,nonMovers,earlyMovers,fowu_fowd_folp,jumpEnd,trkEnd,stimInfo,...
    maxVelInfo,stimStart,zeroFly_XYZmm_Tdeg_fac1000,zeroFly_Trajectory,...
    zeroFly_Jump,zeroFly_Departure,zeroFly_StimAtStimStart,zeroFly_StimAtJump,...
    zeroFly_StimAtFrmOne,rawFly_XYZpix_Trad_frmOne,dist_speed_accel_fac100,distFromCenter_pix,...
    relMotion_FB_LR_Tdeg_fac100,relPosition_FB_LR_Tdeg_fac100,lvList,groupID,...
    plotID,order,repeat,stimType,visStimType,flyLength_mm,'RowNames',graphIDlist);

for iterG = 1:graphCt
    graphID = graphIDlist{iterG};
    groupLogical = strcmp(dataTable.unique_label,graphID);
    exptTable = dataTable(groupLogical,:);
    if abs(sliceOption) > 0
        if sliceOption == 1
            strSplitRefs = strfind(graphID,'_');
            compareID = graphID(1:strSplitRefs(end)-1);
        elseif sliceOption == -1
            compareID = regexprep(graphID,'_long','');
            compareID = regexprep(compareID,'_short','');
        else
            strSplitRefs = strfind(graphID,'_azi');
            if isempty(strSplitRefs)
                compareID = graphID;
            else
                compareID = graphID(1:strSplitRefs(end)-1);
            end
        end
        smlExcelTable = excelTable(strcmp(excelTable.unique_label,compareID),:);
    else
        smlExcelTable = excelTable(strcmp(excelTable.unique_label,graphID),:);
    end
    %%%%% dates filter
%     if isempty(exptTable)
%         continue
%     end
%     dateList = exptTable.Properties.RowNames;
%     dateList = cellfun(@(x) str2double(x(16:23)),dateList);
%     dates2remove = dateList < min(smlExcelTable.First_Date_Run);
%     dates2remove = dateList > max(smlExcelTable.Last_Date_Run) | dates2remove;
%     exptTable(dates2remove,:) = [];
    %%%%%%%%%%%%%%%%%%%
    
    stimTypeString = smlExcelTable.Experiment_Type{1};
    graphTable.visStimType(graphID) = smlExcelTable.visStimType(1);
    if strcmp('Visual_stimulation',stimTypeString) || strcmp('Combo',stimTypeString)
        querryName = {'azimuth','elevation','startSize','stopSize','lv','contrast','width','frequency'};
        members = ismember(querryName,smlExcelTable.Properties.VariableNames);
        for iterM = 1:numel(members)
            querryVal = smlExcelTable.(querryName{iterM})(1);
            if members(iterM) == 0, continue, end
            if strcmp(querryName{iterM},'startSize') && iscell(smlExcelTable.(querryName{iterM})(1))
                querryVal = str2double(regexprep(querryVal{1},'pt','\.'));
            end
            graphTable.(querryName{iterM})(graphID) = querryVal;
        end
        if sliceOption > 1 && exptTable.sliceOp(1) == 1
            exptAzi = graphID;
            exptAzi(1:strfind(exptAzi,'azi')+2) = [];
            exptAzi = str2double(exptAzi);
            graphTable.azimuth(graphID) = exptAzi;
        end
    end
    graphTable.recordRate(graphID) = smlExcelTable.Record_Rate(1);
    if max(strcmp(smlExcelTable.Properties.VariableNames,'genotype'))
        graphTable.genotype(graphID) = smlExcelTable.genotype(1);
    end
    graphTable.vidCount(graphID) = sum(smlExcelTable.Total_Videos);
    graphTable.stimType(graphID) = {stimTypeString};
    smlListIDs = smlExcelTable.Properties.RowNames;
    graphTable.exptIDs(graphID) = {smlListIDs};
    stimDur = max(smlExcelTable.stimDuration(smlExcelTable.stimDuration < Inf));
    if isinf(stimDur) || isempty(stimDur) || isnan(stimDur)
        error('stim dur error')
    end
    graphTable.stimDur(graphID) = stimDur;
    
    exptNames = exptTable.Properties.RowNames;
    exptNames = cellfun(@(x) cat(2,'ID#',x(29:44)),exptNames,'uniformoutput',false);
    noStimNdcs = zeros(size(exptTable,1),1);
    for iterLV = 1:size(exptTable,1)
        noStimNdcs(iterLV) = strcmp(smlExcelTable.contrast(exptNames{iterLV}),'whiteonwhite');
    end
    stimStart = exptTable.stimStart;
    if contains(graphID,'noStim')
        stimStart(noStimNdcs) = exptTable.trkEnd(noStimNdcs);
        stimInit = exptTable.zeroFly_StimAtFrmOne;
    else
        stimInit = exptTable.zeroFly_StimAtStimStart;
    end
    if strcmp('Visual_stimulation',stimTypeString)
        %%%%% Was the stimulus within acceptable boundaries??
        exptAzi = zeros(size(exptTable,1),1);
        for iterLV = 1:size(exptTable,1)
            exptAzi(iterLV) = smlExcelTable.azimuth(exptNames{iterLV});
        end
    else
        exptAzi = 0;
    end
    if isempty(exptTable)
        continue
    end
    stimTol = graphOptions.azimuth_tolerance;
    stimTest = abs(stimInit-exptAzi) < stimTol;
    if isinf(stimTol)
        stimTest = true(size(stimTest));
    end
    notCounting = ~stimTest;
    if showRemoved == 1 && sum(notCounting) > 0
        disp([num2str(sum(notCounting)) ' removed for simulus out of range: ' graphID])
    end
    sizeTest = cellfun(@(x) size(x,2) ~= 3,exptTable.manual_wingup_wingdwn_legpush);
    exptTable.manual_wingup_wingdwn_legpush(sizeTest) = repmat({NaN(1,3)},sum(sizeTest),1);
    if useManual == 1
        jumpTest = exptTable.manualJumpTest;
        fot = exptTable.manualFot;
        fowu_fowd_folp = cell2mat(exptTable.manual_wingup_wingdwn_legpush);
        fowu = fowu_fowd_folp(:,1);
        shortLogical = (fot-fowu) <= 41;
    elseif useManual == 2
        fot = exptTable.autoFot;
        fowu_fowd_folp = NaN(size(fot,1),3);
        shortLogical = NaN(size(fot,1));
        jumpTest = exptTable.autoJumpTest;
    elseif useManual == 3
        jumpTest = exptTable.manualJumpTest;
        fot = exptTable.manualFot;
        fot(isnan(fot)) = exptTable.autoFot(isnan(fot));
        jumpTest(isnan(jumpTest)) = exptTable.autoJumpTest(isnan(jumpTest));
        fowu_fowd_folp = cell2mat(exptTable.manual_wingup_wingdwn_legpush);
        fowu = fowu_fowd_folp(:,1);
        shortLogical = (fot-fowu) <= 41;
    end
    
    notCounting(isnan(jumpTest)) = true;
    if showRemoved == 1 && sum(isnan(jumpTest)) > 0
        disp([num2str(sum(isnan(jumpTest))) ' removed for jump test NaN: ' graphID])
    end
    jumpTest(isnan(jumpTest)) = 0;
    jumpTest = logical(jumpTest);
    nonJumpers = ~jumpTest;
    nonJumpers(notCounting) = false;
    jumpTest(notCounting) = false;
    
    frms_per_ms = double(smlExcelTable.Record_Rate(1)/1000);
    ms2frm = @(x) round(x*frms_per_ms);
    testDir = contains(graphID,'_azi0') || contains(graphID,'_azi180') || contains(graphID,'ele90_');
    if sliceOption > 1 && contains(graphOptions.sheetName,'fieldMap') && testDir
        vidList = exptTable.Properties.RowNames;
        analyzer_name = 'flyAnalyzer3000_v13';
        analysisDir = fullfile('\\DM11','cardlab','Data_pez3000_analyzed');
        stimStart4vid = exptTable.stimStart;
        
        zeroFly_Jump = exptTable.zeroFly_Jump(:,1);
        zeroFly_StimAtStimStart = exptTable.zeroFly_StimAtStimStart(:,1);
        zeroFly_Departure = exptTable.zeroFly_Departure(:,1);
        zeroFly_Trajectory = exptTable.zeroFly_Trajectory(:,1);
        zeroFly_StimAtJump = exptTable.zeroFly_StimAtJump(:,1);
        zeroFly_StimAtFrmOne = exptTable.zeroFly_StimAtFrmOne(:,1);
        
        parfor iterV = 1:numel(vidList)
            videoID = vidList{iterV};
            fileVidID = regexprep(videoID,'_overlap','');
            exptID = fileVidID(29:44);
            expt_results_dir = fullfile(analysisDir,exptID);
            analyzer_expt_ID = [fileVidID '_' analyzer_name '_data.mat'];%experiment ID
            analyzer_data_dir = fullfile(expt_results_dir,[exptID '_' analyzer_name]);
            analyzer_data_path = fullfile(analyzer_data_dir,analyzer_expt_ID);
            
            analysis_data_import = load(analyzer_data_path);
            dataname = fieldnames(analysis_data_import);
            analysis_record = analysis_data_import.(dataname{1});
            smoothWin = round(frms_per_ms);
            botTheta_filt = analysis_record.bot_points_and_thetas{1}(:,3);
            botTheta_filt = smooth(unwrap(botTheta_filt),smoothWin);
            
            if stimStart4vid(iterV) > numel(botTheta_filt)
                stimStart4vid(iterV) = numel(botTheta_filt);
            end
            fly_theta_at_stim_start = botTheta_filt(stimStart4vid(iterV));%sets init theta to fly heading at stim start
            stim_azi = analysis_record.stimulus_azimuth{1};
            uv_zeroFlyStimInit = [cos(stim_azi-fly_theta_at_stim_start) -sin(stim_azi-fly_theta_at_stim_start)];
            zeroFlyStimInit = cart2pol(uv_zeroFlyStimInit(1),-uv_zeroFlyStimInit(2));
            if zeroFlyStimInit < 0
                zeroFly_Jump(iterV) = zeroFly_Jump(iterV).*(-1);
                zeroFly_StimAtStimStart(iterV) = zeroFly_StimAtStimStart(iterV).*(-1);
                zeroFly_Departure(iterV) = zeroFly_Departure(iterV).*(-1);
                zeroFly_Trajectory(iterV) = zeroFly_Trajectory(iterV).*(-1);
                zeroFly_StimAtJump(iterV) = zeroFly_StimAtJump(iterV).*(-1);
                zeroFly_StimAtFrmOne(iterV) = zeroFly_StimAtFrmOne(iterV).*(-1);
            end
        end
        disp([num2str(sum(exptTable.zeroFly_Jump(~isnan(zeroFly_Jump),1) ~= zeroFly_Jump(~isnan(zeroFly_Jump)))) ' out of ',...
            num2str(sum(~isnan(zeroFly_Jump))) ' flipped for ' graphID])
        exptTable.zeroFly_Jump(:,1) = zeroFly_Jump;
        exptTable.zeroFly_StimAtStimStart(:,1) = zeroFly_StimAtStimStart;
        exptTable.zeroFly_Departure(:,1) = zeroFly_Departure;
        exptTable.zeroFly_Trajectory(:,1) = zeroFly_Trajectory;
        exptTable.zeroFly_StimAtJump(:,1) = zeroFly_StimAtJump;
        exptTable.zeroFly_StimAtFrmOne(:,1) = zeroFly_StimAtFrmOne;
        
    end
    moveTest = false(size(exptTable,1),1);
    nonMovers = false(size(exptTable,1),1);
    earlyMovers = false(size(exptTable,1),1);
    maxVelInfo = NaN(size(exptTable,1),7);
    moveThresh = 0.025;% 25 mm/s set by referring to robie et al 2010, Fig.3 JExpBiol
    % and based on trough seen in nonjumping max vel plot 'maxMotion'
    stillThresh = 0.005;
    distCapThresh = 1; % mm to travel before cutoff
    if strcmp('Photoactivation',stimTypeString) || ~strcmp(smlExcelTable.visStimType{1},'loom')
        mvntThreshFrms = 1;
    else
        lv = graphTable.lv(graphID);
        degA = graphTable.startSize(graphID);
        degB = 15;
        mvntThreshMS = lv/tan(deg2rad(degA/2))-lv/tan(deg2rad(degB/2));%duration from stim start to thresh size
        mvntThreshFrms = ms2frm(mvntThreshMS+20);% adding neural delay 20 ms
        if mvntThreshFrms > graphTable.stimDur(graphID)*0.75
            mvntThreshFrms = round(graphTable.stimDur(graphID)*0.75);
        end
        if mvntThreshFrms < 1 || mvntFromStart == 1
            mvntThreshFrms = 1;
        end
        
    end
    winLeg = ms2frm(5);
    mvntCell = cell(size(exptTable,1),1);
    for iterV = 1:size(exptTable,1)
        position_array = double(exptTable.zeroFly_XYZT_fac1000{iterV})/1000;
        mvntArray = graphTable_motionFromZeroFly(position_array,exptTable.mm_per_pixel(iterV),frms_per_ms);
        mvntCell{iterV} = mvntArray;
%         mvntArray = double(exptTable.dist_speed_accel_fac100{iterV})/100;
        mvntVec = mvntArray(stimStart(iterV):end,2);
        if numel(mvntVec) < winLeg*2+1, continue, end
        mvntVec = smooth(mvntVec,winLeg*2+1);
        mvntVec(1:winLeg) = NaN;
        mvntVec(end-winLeg:end) = NaN;
        if mvntThreshFrms > numel(mvntVec), continue, end
        velVec = mvntVec(mvntThreshFrms:end);
        if max(~isnan(velVec)) == 0, continue, end
        [~,maxRef] = nanmax(velVec);
        firstMove = find(velVec > stillThresh,1,'first');
        firstWalk = find(velVec > moveThresh,1,'first');
        if maxRef > numel(velVec)-winLeg, maxRef = numel(velVec)-winLeg;
        elseif maxRef < winLeg+1, maxRef = winLeg+1;
        end
        maxRef = maxRef(1);
        maxVel = velVec(maxRef);
        if maxVel > moveThresh
            moveTest(iterV) = true;
        else
            nonMovers(iterV) = true;
        end
        if velVec(1) > stillThresh, earlyMovers(iterV) = true; end
        distCapVec = mvntArray(mvntThreshFrms+stimStart(iterV):end,1);
        distCapVec = distCapVec-distCapVec(1);
        distCapFrm = find(abs(distCapVec) > distCapThresh,1,'first');
%         if isempty(distCapFrm), distCapFrm = numel(distCapVec); end
        if isempty(distCapFrm)
            distCapFrm = NaN;
        end
        if isempty(firstWalk), firstWalk = NaN; end
        if isempty(firstMove), firstMove = NaN; end
        frmTotalOff = stimStart(iterV)+mvntThreshFrms-1;
        maxVelInfo(iterV,:) = [maxRef+frmTotalOff,...
            maxVel winLeg frmTotalOff distCapFrm+frmTotalOff,...
            firstMove+frmTotalOff firstWalk+frmTotalOff];
    end
    
    earlyJumpers = fot < round(stimStart);
    earlyJumpers(isnan(earlyJumpers)) = false;
    if strcmp('Photoactivation',stimTypeString)
        earlyJumpers = fot < round(stimStart+frms_per_ms*10);
    end
    if strcmp(graphID,'noStim')
        data2keep = earlyJumpers;
    else
        jumpTest(earlyJumpers) = false;
        if showRemoved == 1 && sum(earlyJumpers) > 0
            disp([num2str(sum(earlyJumpers)) ' removed for jumping before stim start: ' graphID])
        end
        data2keep = jumpTest | nonJumpers;
    end
    if sum(data2keep) == 0
        continue
    end
    
    if strcmp('Visual_stimulation',stimTypeString) || strcmp('Combo',stimTypeString)
        if strcmp(smlExcelTable.visStimType{1},'loom')
            lvList = zeros(size(exptTable,1),1);
            for iterLV = 1:size(exptTable,1)
                lvList(iterLV) = smlExcelTable.lv(exptNames{iterLV});
            end
            if ~isempty(strfind(graphOptions.sheetName,'lvCombo'))
                for iterLV = unique(lvList)'
                    lvJumpList = find(lvList(data2keep) == iterLV & jumpTest(data2keep));
                    randRefs = randperm(numel(lvJumpList));
                    maxCt = 150;
                    if numel(randRefs) >= maxCt
                        lvJumpList(randRefs(1:maxCt)) = [];
                        data2keep(lvJumpList) = 0;
                    end
                end
            end
            lvList = lvList(data2keep);
            graphTable.lvList(graphID) = {lvList};
        end
    end
    
    

    graphTable.dataCount(graphID) = size(exptTable,1);
    exptTable = exptTable(data2keep,:);
    jumpTest = jumpTest(data2keep);
    moveTest = moveTest(data2keep);
    nonMovers = nonMovers(data2keep);
    earlyMovers = earlyMovers(data2keep);
    maxVelInfo = maxVelInfo(data2keep,:);
    shortLogical = shortLogical(data2keep);
    fowu_fowd_folp = fowu_fowd_folp(data2keep,:);
    fot = fot(data2keep);
    mvntCell = mvntCell(data2keep);
    
    graphTable.videoList(graphID) = {exptTable.Properties.RowNames};
    graphTable.jumpTest(graphID) = {jumpTest};
    graphTable.shortTest(graphID) = {shortLogical};
    graphTable.fowu_fowd_folp(graphID) = {fowu_fowd_folp};
    graphTable.manCount(graphID) = sum(min(~isnan(fowu_fowd_folp),[],2));
    graphTable.jumpEnd(graphID) = {fot};
    graphTable.moveTest(graphID) = {moveTest & ~jumpTest};
    graphTable.nonMovers(graphID) = {nonMovers & ~jumpTest};
    graphTable.earlyMovers(graphID) = {earlyMovers};
    graphTable.maxVelInfo(graphID) = {maxVelInfo};
    graphTable.trkEnd(graphID) = {exptTable.trkEnd};
%     graphTable.stimInfo(graphID) = {exptTable.stimInfo};
    graphTable.stimStart(graphID) = {exptTable.stimStart};
    graphTable.zeroFly_Trajectory(graphID) = {exptTable.zeroFly_Trajectory};
    graphTable.zeroFly_Jump(graphID) = {exptTable.zeroFly_Jump};
    graphTable.zeroFly_Departure(graphID) = {exptTable.zeroFly_Departure};
    graphTable.zeroFly_StimAtStimStart(graphID) = {exptTable.zeroFly_StimAtStimStart};
    graphTable.zeroFly_StimAtJump(graphID) = {exptTable.zeroFly_StimAtJump};
    graphTable.zeroFly_StimAtFrmOne(graphID) = {exptTable.zeroFly_StimAtFrmOne};
    graphTable.rawFly_XYZpix_Trad_frmOne(graphID) = {exptTable.rawFly_XYZT_atFrmOne};
    centerDist = zeros(size(exptTable,1),1);
    vecCell = cell(size(exptTable,1),1);
    for iterLV = 1:numel(centerDist)
        zeroFly_XYZmm_Tdeg_fac1000 = double(exptTable.zeroFly_XYZT_fac1000{iterLV})/1000;
        zeroFly_XYZmm_Tdeg_fac1000(:,4) = rad2deg(zeroFly_XYZmm_Tdeg_fac1000(:,4));
        vecCell{iterLV} = zeroFly_XYZmm_Tdeg_fac1000;
        roiPos = exptTable.roiAdjusted{iterLV};
        roiPos = roi2crop(roiPos);
        roiCenter = mean(roiPos);
        xyFlyPos = exptTable.rawFly_XYZT_atFrmOne{iterLV}(1:2);
        centerDist(iterLV) = sqrt(sum((xyFlyPos-roiCenter).^2));
    end
    graphTable.zeroFly_XYZmm_Tdeg_fac1000(graphID) = {vecCell};
    graphTable.distFromCenter_pix(graphID) = {centerDist};
%     graphTable.relMotion_FB_LR_Tdeg_fac100(graphID) = {exptTable.relMotion_FB_LR_T_fac1000};
    graphTable.relPosition_FB_LR_Tdeg_fac100(graphID) = {exptTable.relPosition_FB_LR_T_fac1000};
    graphTable.dist_speed_accel_fac100(graphID) = {mvntCell};
    graphTable.flyLength_mm(graphID) = {exptTable.flyLength.*exptTable.mm_per_pixel};
    graphTable.plotCount(graphID) = numel(jumpTest);
    graphTable.jumpCount(graphID) = sum(jumpTest);
    
    
end

[~,B] = xlsfinfo(excelPath);
sheetName = graphOptions.sheetName;
sheetValid = any(strcmp(B,sheetName));

if sheetValid
    write2Table = readtable(excelPath,'Sheet',sheetName,'ReadRowNames',true);
    savedNames = write2Table.Properties.RowNames;
    savedVars = write2Table.Properties.VariableNames;
    writeVars = {'vidCount','dataCount','plotCount','jumpCount','manCount'};
    writeVars = intersect(writeVars,savedVars);
    writeNames = intersect(graphTable.Properties.RowNames,savedNames);
    write2Table(writeNames,writeVars) = graphTable(writeNames,writeVars);
else
    writeVars = {'vidCount','dataCount','plotCount','jumpCount','manCount','recordRate',...
        'stimDur','genotype'};
    if max(strcmp(excelTable.Experiment_Type,'Visual_stimulation'))
        writeVars = cat(2,writeVars,{'elevation','azimuth','startSize','stopSize',...
            'lv','contrast','width','frequency','visStimType'});
    end
    write2Table = graphTable(:,writeVars);
    write2Table.plotID = write2Table.Properties.RowNames;
    write2Table.groupID = repmat({sheetName},size(write2Table,1),1);
    write2Table.order = (1:size(write2Table,1))';
end
try
    writetable(write2Table,excelPath,'Sheet',sheetName,'WriteRowNames',true)
catch
    disp('could not write to excel file - makeGraphingTable.mat')
end
graphTableRowNames = graphTable.Properties.RowNames;
bigNdx = cellfun(@(x) numel(x) > 63,graphTableRowNames);
graphTableRowNames(bigNdx) = cellfun(@(x) x(1:63),graphTableRowNames(bigNdx),'uniformoutput',false);
graphTable.Properties.RowNames = graphTableRowNames;

