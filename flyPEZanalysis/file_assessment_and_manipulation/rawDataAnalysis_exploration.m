
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


homeDir = 'C:\Users\cardlab\Documents\MATLAB';
listName = 'Single_fail_results.txt';
% listName = 'Multi_pass_results.txt';
listPath = fullfile(homeDir,listName);
listCell = importdata(listPath);
listCell(1) = [];
exptIDlist = unique(cellfun(@(x) x(29:44),listCell,'uniformoutput',false));
vidList = cellfun(@(x) x(1:52),listCell,'uniformoutput',false);
exptCt = numel(exptIDlist);
assessTablePart = cell(exptCt,1);
for iterE = 1:exptCt
    exptID = exptIDlist{iterE};
    exptResultsRefDir = fullfile(analysisDir,exptID);
    assessmentName = [exptID '_rawDataAssessment.mat'];
    assessmentPath = fullfile(exptResultsRefDir,assessmentName);
    if ~exist(assessmentPath,'file')
        continue
    end
    assessTable_import = load(assessmentPath);
    dataname = fieldnames(assessTable_import);
    assessTable = assessTable_import.(dataname{1});
    assessNames = assessTable.Properties.RowNames;
    exptNames = cellfun(@(x) max(strcmp(vidList,x)),assessNames);
    assessTablePart{iterE} = assessTable(exptNames,:);
    
end