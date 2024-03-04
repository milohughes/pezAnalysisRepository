% homeDirA = 'C:\';
% homeDirA = '\\dm11\cardlab\Data_pez3000\20131029';
% homeDirA = 'Z:\Data_pez3000\20131029\run005_pez3001_20131029';
homeDirA = '\\tier2\card';
saveName = 'tier2_assessment_20141105';
saveDir = 'C:\Users\cardlab\Documents';
savePath = fullfile(saveDir,[saveName '.mat']);
%
if ~exist(savePath,'file')
    [fileNames,fileSizes] = getAllFiles(homeDirA);
    save(savePath,'fileNames','fileSizes')
else
    load(savePath)
end
nonAviLogical = cellfun(@(x) isempty(strfind(x,'.avi')),fileNames);
fileNames(nonAviLogical) = [];
fileSizes(nonAviLogical) = [];
%%
aviSizeTally = 0;
for iterAvi = 1:numel(fileNames)
    [~,~,ext] = fileparts(fileNames{iterAvi});
    if strcmp(ext,'.avi')
        aviSizeTally = aviSizeTally+fileSizes{iterAvi};
    end
end
%%
rawSize = aviSizeTally;
sizeStrings = {'bytes','kB','MB','GB','TB'};
for iterSz = 1:5
    if rawSize >= 1024
        rawSize = rawSize/1024;
    else
        aviSize = [num2str(round(rawSize*100)/100) ' ' sizeStrings{iterSz}];
        break
    end
end
%%
% clc
% clearvars -except names sizes
fileCt = numel(fileNames);
layerCt = 3;%number of subdirectory layers deep to assess
if strcmp(homeDirA(end),filesep)
    homeDirA = homeDirA(1:end-1);
end
parentCt = numel(strsplit(homeDirA,filesep));%number of directories above the initial one
cellParts = cell(fileCt,layerCt);
cellSizes = cell(fileCt,layerCt);
cellPaths = cell(fileCt,layerCt);
parfor iterF = 1:fileCt
    partXcell = strsplit(fileNames{iterF},filesep);
    for iterP = 1:layerCt
        partRef = (iterP-1)+parentCt;
        if numel(partXcell) > partRef
            cellParts{iterF,iterP} = partXcell{partRef};
            cellSizes{iterF,iterP} = fileSizes{iterF};
            cellPaths{iterF,iterP} = fullfile(partXcell{1:partRef});
        else
            cellParts{iterF,iterP} = 'not_a_file';
            cellSizes{iterF,iterP} = 0;
            cellPaths{iterF,iterP} = 'not_a_file';
        end
    end
end

%%
sizeStrings = {'bytes','kB','MB','GB','TB'};
for iterX = 1:size(cellParts,2)
    sizeXcell = cellSizes(:,iterX);
    [Cx,iax,icx] = unique(cellParts(:,iterX));
    xCt = numel(Cx);
    sizesXstring = cell(xCt,1);
    sizesXval = cell(xCt,1);
    for iterA = 1:xCt
        rawSize = sum(cell2mat(sizeXcell(iterA == icx)));
        sizesXval{iterA} = rawSize;
        for iterSz = 1:5
            if rawSize >= 1024
                rawSize = rawSize/1024;
            else
                sizesXstring{iterA} = [num2str(round(rawSize*100)/100) ' ' sizeStrings{iterSz}];
                break
            end
        end
    end
    namesX = cellPaths(iax,iterX);
    xTable = table(namesX,sizesXstring,sizesXval);
    xTable.Properties.VariableNames = {'Directory','Total_Size','Raw_Size_Value'};
    if iterX == 1
        saveTable = xTable;
    else
        saveTable = [saveTable;xTable];
    end
end
%
writetable(saveTable,fullfile(saveDir,[saveName '.xlsx']),'FileType','spreadsheet')

%%
% extFinder = {'.jpg','.mp4','.tif','.avi','.mov','.mts'};
% for iterF = 1:numel(extFinder)
%     findCell = strfind(fileNames,extFinder{iterF});
%     findBoolB = cellfun(@(x) ~isempty(x),findCell);
%     if iterF == 1
%         findBool = findBoolB;
%     else
%         findBool = max(findBool,findBoolB);
%     end
% end
% mediaList = fileNames(findBool);
% mediaListPath = fullfile(saveDir,[saveName '.txt']); %path to save event log
% fidSave = fopen(mediaListPath,'w');
% for iterW = 1:numel(mediaList)
%     fprintf(fidSave,'%s\r\n',mediaList{iterW});
% end
% fclose(fidSave);


