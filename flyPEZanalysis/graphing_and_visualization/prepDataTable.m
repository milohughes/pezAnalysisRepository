function [dataIDlist,outputTable] = prepDataTable
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
persistent loadingStructOld outputTableOld dataIDlistOld
%%
if isempty(mfilename)
    loadingStructOld = [];
    outputTableOld = [];
    dataIDlistOld = [];
end
graphOptions = load('Z:\pez3000_methods_paper\DLpsych_phys_figures\graphOptions');
graphOptions = graphOptions.graphOptions;
anaCol = graphOptions.anaCol;
crossCompare = graphOptions.crossCompare;
anaGrpList = graphOptions.anaGrpList;
if ~isempty(loadingStructOld)
    if isequal(graphOptions,loadingStructOld)
        outputTable = outputTableOld;
        dataIDlist = dataIDlistOld;
%         return
    end
end
graphTable = loadDataTable;

%% %%% computer and directory variables and information
op_sys = system_dependent('getos');
if strfind(op_sys,'Microsoft Windows 7')
    archDir = [filesep filesep 'tier2' filesep 'cardlab'];
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

[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
subfun_dir = fullfile(repositoryDir,'pezProc_subfunctions');
saved_var_dir = fullfile(repositoryDir,'pezProc_saved_variables');
addpath(subfun_dir,saved_var_dir)
addpath(fullfile(repositoryDir,'Pez3000_Gui_folder','Matlab_functions','Support_Programs'))




pStr = cellfun(@(x,y) {x y},graphTable.parentA,graphTable.parentB,'uniformoutput',false);
pStr = cat(1,pStr{:});
if ~isempty(strfind(anaCol,'screen'))
    graphTable.dataLabel = cellfun(@(x,y) [x '_' y],graphTable.stimInfo,graphTable.parentB,...
        'uniformoutput',false);
    graphTable.groupLabel = cell(size(graphTable,1),1);
    targetA = {'CTRL_DL_1500090_0028FCF_DL_1500090'
        'DL_UAS_GAL80ts_Kir21_23_0010'
        'UAS_Chrimson_Venus_X_0070'
        'UAS_TNT_2_0003'};
    refKeyA = {'DL'
        'Kir'
        'Chr'
        'TNT'};
    refCt = numel(refKeyA);
    for iterR = 1:refCt
        pFindA = strcmp(pStr,targetA{iterR,1});
        pFindB = strcmp(pStr,targetA{iterR,1});
        pFindC = sum(sum(cat(3,pFindA,pFindB),3),2) == 2;
        pFindDa = pFindC & ~(sum(pFindA,2) == 2) & ~(sum(pFindB,2) == 2);
        pFindDb = sum(sum(cat(3,pFindA,pFindB),3),2) == 4;
        pFindD = pFindDa | pFindDb;
        graphTable.groupLabel(pFindD) = repmat(refKeyA(iterR),sum(pFindD),1);
    end
    if strcmp(anaCol,'CCX_screen')
        pdir = 'Z:\WryanW\CX_prelim_images_max_projection';
        destdir = fullfile(pdir,'ccx_sample_images');
        imlist = dir(fullfile(destdir,'*_crop.tif'));
        imlist = {imlist(:).name}';
        labels2keep = cellfun(@(x) x(1:end-9),imlist,'uniformoutput',false);
        labels2keep = [labels2keep(:);{'CTRL_DL_1500090_0028FCF_DL_1500090'}];
        graphTable = graphTable(cellfun(@(x) max(strcmp(labels2keep,x)),graphTable.parentB),:);
    elseif strcmp(anaCol,'OL_screen')
        excelDir = 'Z:\WryanW\flyPez_experiment_management';
        excelName = 'bulk_testing_geno.xlsx';
        excelTable = readtable(fullfile(excelDir,excelName),'Sheet','OL_stock_info');
        labels2keep = strtrim(excelTable.LineName);
%         graphTable = graphTable(cellfun(@(x) max(strcmp(labels2keep,x)),graphTable.parentA),:);
%         graphTable.groupLabel = repmat({graphOptions.sheetName},size(graphTable,1),1);
        anaGrpList = unique(graphTable.groupLabel);
    else
        excelDir = 'Z:\Ming_RubinLab';
        excelName = 'Table1_v5_WRW.xlsx';
        excelTable = readtable(fullfile(excelDir,excelName),'Sheet','Quantified_results');
        labels2keep = strtrim(excelTable.Driver);
        labels2keep = [cellfun(@(x) ['GMR_' x],labels2keep(:),'uniformoutput',false)
            cellfun(@(x) ['BJD_' x],labels2keep(:),'uniformoutput',false);labels2keep(:)];
        graphTable = graphTable(cellfun(@(x) isempty(strfind(x,'ramp')),graphTable.stimInfo),:);
        graphTable = graphTable(cellfun(@(x) isempty(strfind(x,'Begin1000')),graphTable.stimInfo),:);
        dataLabel = repmat({'pulse_50ms_50pct'},size(graphTable,1),1);
        dataLabel(strcmp(graphTable.Experiment_Type,'Unknown')) = {'pulse_0ms_0pct'};
        graphTable.dataLabel = cellfun(@(x,y) [x '_' y],dataLabel,graphTable.parentB,...
            'uniformoutput',false);
        graphTable.groupLabel = repmat({'Chr'},size(graphTable,1),1);
        graphTable = graphTable(cellfun(@(x) max(strcmp(labels2keep,x)),graphTable.parentB),:);
    end
    
elseif ~isempty(strfind(anaCol,'mingPaper_group_compare'))
    graphTable.dataLabel = graphTable.exptID;
    graphTable.groupLabel = cell(size(graphTable,1),1);
    excelPath = graphOptions.excelPath;
    excelTable = readtable(excelPath,'ReadRowNames',true,'Sheet',graphOptions.sheetName);
    for iterG = 1:size(graphTable,1)
        exptID = graphTable.exptID{iterG};
        graphTable.groupLabel(iterG) = excelTable.CellTypes(exptID);
        graphTable.dataLabel(iterG) = {[excelTable.CellTypes{exptID} excelTable.Driver{exptID}]};
    end
    graphTable.groupLabel = repmat({'Chr'},size(graphTable,1),1);
    anaGrpList = unique(graphTable.groupLabel);
%     parentList = unique(graphTable.parents_info);
    
elseif strcmp(anaCol,'GF_longVshortVonVoff')
    graphTable.groupLabel = cell(size(graphTable,1),1);
    graphTable.dataLabel = cell(size(graphTable,1),1);
    sFindA = cellfun(@(x) ~isempty(strfind(x,'loom_10to180')),graphTable.stimInfo);
    sFindB = cellfun(@(x) ~isempty(strfind(x,'blackonwhite_ele45_azi90')),graphTable.stimInfo);
    loomLogic = sFindA & sFindB;
%     photoLogic = cellfun(@(x) ~isempty(strfind(x,'pulse_General')),graphTable.stimInfo);
    photoLogic = cellfun(@(x) ~isempty(strfind(x,'pulse')),graphTable.stimInfo);
    
    pFindA = strcmp(pStr,'CTRL_DL_1500090_0028FCF_DL_1500090');
    pFindB = strcmp(pStr,'CTRL_DL_1500090_0028FCF_DL_1500090');
    pFindC = sum(sum(cat(3,pFindA,pFindB),3),2) == 2;
    pFindDa = pFindC & ~(sum(pFindA,2) == 2) & ~(sum(pFindB,2) == 2);
    pFindDb = sum(sum(cat(3,pFindA,pFindB),3),2) == 4;
    pFindD = pFindDa | pFindDb;
    pFindEa = graphTable.shortLogical == 1;
    groupFindAa = pFindEa & pFindD & loomLogic;
    graphTable.dataLabel(groupFindAa) = repmat({'loom_10to180_DL_short_ele45_azi90'},sum(groupFindAa),1);
    pFindEb = graphTable.longLogical == 1;
    groupFindAb = pFindEb & pFindD & loomLogic;
    graphTable.dataLabel(groupFindAb) = repmat({'loom_10to180_DL_long_ele45_azi90'},sum(groupFindAb),1);
    
    pFindA = strcmp(pStr,'17A04-p65ADZP(attp40); 68A06-ZpGdbd(attp2)');
    pFindB = strcmp(pStr,'UAS_Chrimson_Venus_X_0070');
    pFindC = sum(sum(cat(3,pFindA,pFindB),3),2) == 2;
    pFindDa = pFindC & ~(sum(pFindA,2) == 2) & ~(sum(pFindB,2) == 2);
    pFindDb = sum(sum(cat(3,pFindA,pFindB),3),2) == 4;
    pFindD = pFindDa | pFindDb;
    groupFindB = pFindD & photoLogic;
    graphTable.dataLabel(groupFindB) = repmat({'activation_pulse_DL_Chrimson_various_protocols'},sum(groupFindB),1);
    
    pFindA = strcmp(pStr,'17A04-p65ADZP(attp40); 68A06-ZpGdbd(attp2)');
    pFindB = strcmp(pStr,'w+ DL; DL; pJFRC49-10XUAS-IVS-eGFPKir2.1 in attP2 (DL)');
    pFindC = sum(sum(cat(3,pFindA,pFindB),3),2) == 2;
    pFindDa = pFindC & ~(sum(pFindA,2) == 2) & ~(sum(pFindB,2) == 2);
    pFindDb = sum(sum(cat(3,pFindA,pFindB),3),2) == 4;
    pFindD = pFindDa | pFindDb;
    groupFindC = pFindD & loomLogic;
    graphTable.dataLabel(groupFindC) = repmat({'loom_10to180_DL_Kir_ele45_azi90'},sum(groupFindC),1);
    
    groupFind = (groupFindAa | groupFindAb) | (groupFindB | groupFindC);
    graphTable.groupLabel(groupFind) = repmat({'GF_longVshortVonVoff'},sum(groupFind),1);
elseif ~isempty(strfind(anaCol,'grating'))
    graphTable.groupLabel = cell(size(graphTable,1),1);
    graphTable.dataLabel = graphTable.stimInfo;
    gratingLogic = cellfun(@(x) ~isempty(strfind(x,'grating')),graphTable.stimInfo);
    pFindA = strcmp(pStr,'CTRL_DL_1500090_0028FCF_DL_1500090');
    pFindB = strcmp(pStr,'CTRL_DL_1500090_0028FCF_DL_1500090');
    pFindC = sum(sum(cat(3,pFindA,pFindB),3),2) == 2;
    pFindDa = pFindC & ~(sum(pFindA,2) == 2) & ~(sum(pFindB,2) == 2);
    pFindDb = sum(sum(cat(3,pFindA,pFindB),3),2) == 4;
    pFindD = pFindDa | pFindDb;
    groupFind = pFindD & gratingLogic;
    graphTable.groupLabel(groupFind) = repmat({'DL_grating'},sum(groupFind),1);
    if ~strcmp(anaCol,'DL_grating')
        exptFindA = graphTable.exptNum == 41000004300400;
        exptFindB = graphTable.exptNum == 41000004300399;
        exptFindC = graphTable.exptNum == 40000004300258;
        graphTable = graphTable(exptFindA | exptFindB | exptFindC,:);
        graphTable.groupLabel = repmat({'DL_grating'},size(graphTable,1),1);
    end
elseif ~isempty(strfind(anaCol,'activationVSsilencing'))
    graphTable.groupLabel = cell(size(graphTable,1),1);
    if strcmp(anaCol,'activationVSsilencing_DN')
        targetA = {'20XUAS-CsChrimson-mVenus trafficked in attP18'
            'CTRL_DL_1500090_0028FCF_DL_1500090'
            'FCF_DL_1500090'
            'UAS_Chrimson_Venus_X_0070'
            'UAS_TNT_2_0003'
            'w+ DL; DL; pJFRC49-10XUAS-IVS-eGFPKir2.1 in attP2 (DL)'
            'w+; UAS-cTNT E'};
        refKeyA = {'Chr'
            'DL'
            'DL'
            'Chr'
            'TNT'
            'Kir'
            'TNT'};
    else
        targetA = {'CTRL_DL_1500090_0028FCF_DL_1500090'
            'DL_UAS_GAL80ts_Kir21_23_0010'
            'UAS_Chrimson_Venus_X_0070'
            'UAS_TNT_2_0003'};
        refKeyA = {'DL'
            'Kir'
            'Chr'
            'TNT'};
    end
    refCt = numel(refKeyA);
    for iterR = 1:refCt
        pFindA = strcmp(pStr,targetA{iterR,1});
        pFindB = strcmp(pStr,targetA{iterR,1});
        pFindC = sum(sum(cat(3,pFindA,pFindB),3),2) == 2;
        pFindDa = pFindC & ~(sum(pFindA,2) == 2) & ~(sum(pFindB,2) == 2);
        pFindDb = sum(sum(cat(3,pFindA,pFindB),3),2) == 4;
        pFindD = pFindDa | pFindDb;
        graphTable.groupLabel(pFindD) = repmat(refKeyA(iterR),sum(pFindD),1);
    end
    if strcmp(anaCol,'activationVSsilencing_DN')
        graphTable.dataLabel = graphTable.parentB;
    else
        graphTable.dataLabel = graphTable.parentA;
    end
    graphTable = graphTable(cellfun(@(x) isempty(strfind(x,'ramp')),graphTable.stimInfo),:);
    graphTable = graphTable(cellfun(@(x) isempty(strfind(x,'_Sta')),graphTable.stimInfo),:);
    if strcmp(anaGrpList{1},'Chr')% activation
        graphTable = graphTable(strcmp(graphTable.Experiment_Type,'Photoactivation'),:);
    else
        graphTable = graphTable(strcmp(graphTable.Experiment_Type,'Visual_stimulation'),:);
    end
else
    graphTable.dataLabel = graphTable.stimInfo;
    graphTable.groupLabel = cell(size(graphTable,1),1);
    targetA = {'CTRL_DL_1500090_0028FCF_DL_1500090','w+ DL; DL; pJFRC49-10XUAS-IVS-eGFPKir2.1 in attP2 (DL)'
        'CTRL_DL_1500090_0028FCF_DL_1500090','CTRL_DL_1500090_0028FCF_DL_1500090'
        '17A04-p65ADZP(attp40); 68A06-ZpGdbd(attp2)','w+ DL; DL; pJFRC49-10XUAS-IVS-eGFPKir2.1 in attP2 (DL)'
        'GMR_OL0077B','w+ DL; DL; pJFRC49-10XUAS-IVS-eGFPKir2.1 in attP2 (DL)'
        'GMR_SS00315','w+ DL; DL; pJFRC49-10XUAS-IVS-eGFPKir2.1 in attP2 (DL)'
        '17A04-p65ADZP(attp40); 68A06-ZpGdbd(attp2)','UAS_Chrimson_Venus_X_0070'
        'GMR_OL0077B','UAS_Chrimson_Venus_X_0070'
        'GMR_SS00315','UAS_Chrimson_Venus_X_0070'
        'norpA','UAS_Chrimson_Venus_X_0070'};
    refKeyA = {'DL_Kir'
        'DL'
        'GF_Kir'
        'LC6_Kir'
        'LC4_Kir'
        'GF_Chr'
        'LC6_Chr'
        'LC4_Chr'
        'norpA_Chr'};
    refCt = numel(refKeyA);
    
    for iterR = 1:refCt
        pFindA = strcmp(pStr,targetA{iterR,1});
        pFindB = strcmp(pStr,targetA{iterR,2});
        pFindC = sum(sum(cat(3,pFindA,pFindB),3),2) == 2;
        pFindDa = pFindC & ~(sum(pFindA,2) == 2) & ~(sum(pFindB,2) == 2);
        pFindDb = sum(sum(cat(3,pFindA,pFindB),3),2) == 4;
        pFindD = pFindDa | pFindDb;
        graphTable.groupLabel(pFindD) = repmat(refKeyA(iterR),sum(pFindD),1);
    end
end
%%
plotTypeLogical = true(size(graphTable,1),1);
% if ~(strcmp(anaCol,'Photoactivation') || ~isempty(strfind(anaCol,'grating')) || strcmp(anaCol,'GF_longVshortVonVoff'))
%     plotTypeLogical(cellfun(@(x) isempty(strfind(x,'10to180')),graphTable.stimInfo)) = false;
%     plotTypeLogical(cellfun(@(x) ~isempty(strfind(x,'grating')),graphTable.stimInfo)) = false;
% end

if strcmp(anaCol,'all') || strcmp(anaCol,'CCX_screen')
    
elseif ~isempty(strfind(anaCol,'elevation_curve'))
    plotTypeLogical(cellfun(@(x) isempty(strfind(x,'lv40')),graphTable.stimInfo)) = false;
    if strcmp(anaCol,'elevation_curve_90')
        plotTypeLogical(cellfun(@(x) isempty(strfind(x,'azi90')),graphTable.stimInfo)) = false;
    else
        plotTypeLogical(cellfun(@(x) isempty(strfind(x,'azi0')),graphTable.stimInfo)) = false;
    end
elseif ~isempty(strfind(anaCol,'lv_tuning_curve'))
    if strcmp(anaCol,'lv_tuning_curve_90')
        plotTypeLogical(cellfun(@(x) isempty(strfind(x,'azi90')),graphTable.stimInfo)) = false;
    else
        plotTypeLogical(cellfun(@(x) isempty(strfind(x,'azi0')),graphTable.stimInfo)) = false;
    end
    plotTypeLogical(cellfun(@(x) isempty(strfind(x,'ele45')),graphTable.stimInfo)) = false;
elseif ~isempty(strfind(anaCol,'azimuth_sweep'))
    plotTypeLogical(cellfun(@(x) isempty(strfind(x,'ele45')),graphTable.stimInfo)) = false;
    if strcmp(anaCol,'azimuth_sweep_20')
        plotTypeLogical(cellfun(@(x) isempty(strfind(x,'lv20')),graphTable.stimInfo)) = false;
    else
        plotTypeLogical(cellfun(@(x) isempty(strfind(x,'lv40')),graphTable.stimInfo)) = false;
    end
end

grpCt = numel(anaGrpList);
plotTable = graphTable(plotTypeLogical,:);
outputTable = cell(grpCt,1);
for grpNdx = 1:grpCt
    grpRef = anaGrpList{grpNdx};
    groupLogical = strcmp(plotTable.groupLabel,grpRef);
    outputTable{grpNdx} = plotTable(groupLogical,:);
    if crossCompare
        uniqIDsGrp = outputTable{grpNdx}.dataLabel;
        uniqIDlistA = unique(uniqIDsGrp);
        if grpNdx > 1
            uniqNdxA = ismember(uniqIDlistA,uniqIDlistB);
        else
            uniqNdxA = true(size(uniqIDlistA));
        end
        uniqIDlistB = uniqIDlistA(uniqNdxA);
    end
end
%%
outputTable = cat(1,outputTable{:});
if crossCompare
    dataIDlist = uniqIDlistB;
else
    uniqIDsGrp = outputTable.dataLabel;
    dataIDlist = unique(uniqIDsGrp);
end
if isempty(dataIDlist)
    disp('no shared uniqIDs')
end

%% %%% sorting
dataCt = numel(dataIDlist);
rearranger = (1:dataCt);
reData = dataIDlist;
sortData = rearranger;
if true % preliminary sorting step
    splitCell = cellfun(@(x) strsplit(x,'_'),reData,'uniformoutput',false);
    if strcmp(anaCol,'elevation_curve')
        sortData = cellfun(@(x) str2double(x{5}(strfind(x{5},'ele')+3:end)),splitCell);
    end
    if ~isempty(strfind(anaCol,'lv_tuning_curve'))
        sortData = cellfun(@(x) str2double(x{3}(strfind(x{3},'lv')+2:end)),splitCell);
    end
    if ~isempty(strfind(anaCol,'azimuth_sweep'))
        sortData = cellfun(@(x) str2double(x{6}(strfind(x{6},'azi')+3:end)),splitCell);
    end
    [~,rearrangerB] = sort(sortData);
    rearranger = rearranger(rearrangerB);
    reData = reData(rearrangerB);
end
if isfield(graphOptions,'rearranger')
    %%%%% second sort step
    rearranger = graphOptions.rearranger;
end
dataIDlist = dataIDlist(rearranger);
outputTableOld = outputTable;
dataIDlistOld = dataIDlist;
loadingStructOld = graphOptions;

graphOptions.anaGrpList = anaGrpList;
save('Z:\pez3000_methods_paper\DLpsych_phys_figures\graphOptions','graphOptions');