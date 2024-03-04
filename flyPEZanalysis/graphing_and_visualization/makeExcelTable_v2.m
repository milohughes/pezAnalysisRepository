function makeExcelTable_v2(runMode)
%makeExcelTable generates excel table that contains all exptID info
%   To make complete table in default location, set runMode to 1.  To
%   generate your own table, use makeGraphOptionsStruct to set the file and
%   sheet names and set runMode to 2.  
%%
if ~exist('runMode','var')
    runMode = 1;
end

[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');

analysisDir = fullfile(fileDir,'Data_pez3000_analyzed');
exptSumName = 'experimentSummary.mat';
exptSumPath = fullfile(analysisDir,exptSumName);
experimentSummary = load(exptSumPath);
experimentSummary = experimentSummary.experimentSummary;
if runMode == 1
    exptIDlist = experimentSummary.Properties.RowNames;
    sheetName = 'allIDs';
    excelPath = fullfile(analysisDir,'experimentIDinfo.xlsx');
else
    optionsPath = fullfile(fileDir,'Data_pez3000_analyzed\WRW_graphing_variables\graphOptions.mat');
    graphOptions = load(optionsPath);
    graphOptions = graphOptions.graphOptions;
    excelPath = graphOptions.excelPath;
    sheetName = graphOptions.exptSheet;
    try
        excelTable = readtable(excelPath,'ReadRowNames',true,'Sheet',sheetName);
    catch
        excelTable = readtable(excelPath,'ReadRowNames',false,'Sheet',sheetName);
        excelTable.Properties.RowNames = excelTable.Row;
    end
    exptIDlist = excelTable.Properties.RowNames;
    excelTable(cellfun(@(x) numel(x),exptIDlist) ~= 19,:) = [];
    exptIDlist = excelTable.Properties.RowNames;
    exptIDlist = cellfun(@(x) x(4:end),exptIDlist,'uniformoutput',false);
    exptIDlist = unique(exptIDlist);
end

exptIDlist = intersect(experimentSummary.Properties.RowNames,exptIDlist);
exptIDtable = experimentSummary(exptIDlist,:);
rowNames = exptIDtable.Properties.RowNames;
rowNames = cellfun(@(x) ['ID#' x(end-15:end)],rowNames,'uniformoutput',false);
exptIDtable.Properties.RowNames = rowNames;
try
    if runMode == 1
        writetable(exptIDtable,excelPath,'Sheet',sheetName,'WriteRowNames',true);
    else
        rangeRef = ['A1:BO' num2str(size(exptIDtable,1)+1)];
        writetable(exptIDtable,excelPath,'Sheet',[sheetName '_updated'],...
            'WriteRowNames',true,'Range',rangeRef)
    end

catch ME
    getReport(ME)
    disp('please close destination table and try again')
end

