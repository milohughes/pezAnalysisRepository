function dataTable = loadDataTable
%loadDataTable Loads data table saved after getting data from visualizer

persistent loadedTable oldIDlist
%%
if isempty(mfilename)
    loadedTable = [];
    oldIDlist = [];
end
    
graphOptions = load('\\dm11\cardlab\Data_pez3000_analyzed\WRW_graphing_variables\graphOptions.mat');
graphOptions = graphOptions.graphOptions;
excelPath = graphOptions.excelPath;
sheetName = graphOptions.exptSheet;
excelTable = readtable(excelPath,'ReadRowNames',true,'Sheet',sheetName);
dataTable = [];
exptIDlist = excelTable.Properties.RowNames;
exptIDlist = cellfun(@(x) x(4:end),exptIDlist,'uniformoutput',false);
excelTable(cellfun(@(x) numel(x),exptIDlist) ~= 16,:) = [];
exptIDlist = excelTable.Properties.RowNames;
exptIDlist = cellfun(@(x) x(4:end),exptIDlist,'uniformoutput',false);
%%
if isempty(exptIDlist)
    return
end
if ~isempty(oldIDlist)
    if ~isequal(sort(oldIDlist),sort(exptIDlist))
        loadedTable = [];
    end
end
if isempty(loadedTable)
    analysisDir = fullfile('\\dm11','cardlab','Data_pez3000_analyzed');
    dataTable = cell(numel(exptIDlist),1);
    parfor iterE = 1:numel(exptIDlist)
        exptID = exptIDlist{iterE};
        expt_results_dir = fullfile(analysisDir,exptID);
        graphTablePath = fullfile(expt_results_dir,[exptID '_dataForVisualization.mat']);
        if ~exist(graphTablePath,'file')
            disp([exptID ' - no data for visualization file'])
            continue
        end
        graphTableLoading = load(graphTablePath);
        graphTable2Add = graphTableLoading.graphTable;
%         graphTable2Add = graphTable2Add(strcmp(graphTable2Add.finalStatus,'analyzed'),:);
        vids2keep = graphTable2Add.Properties.RowNames;
        if isempty(vids2keep)
            continue
        end
        graphTable2Add.unique_label = cell(size(graphTable2Add,1),1);
        graphTable2Add.sliceOp = zeros(size(graphTable2Add,1),1);
        dataTable{iterE} = graphTable2Add;
    end
    dataTable = cat(1,dataTable{:});
    loadedTable = dataTable;
end
oldIDlist = exptIDlist;
dataTable = loadedTable;
end

