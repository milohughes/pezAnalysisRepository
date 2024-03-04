function outcome = makeMontageFrame_v2(montyDir,sampleFrameDir,vidName)
outcome = 'good';
dwnSampl = 1;%can be reduced to slightly improve speed at the cost of quality
if nargin == 0
    vidName = 'run010_pez3003_20140312_expt0008000002590057_vid0016.mp4';
%     installVideoUtils
end
% installVideoUtils
%%%%% computer and directory variables and information
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');
parentDir = fullfile(fileDir,'Data_pez3000');

strParts = strsplit(vidName,'_');
runDir = [strParts{1} '_' strParts{2} '_' strParts{3}];
exptID = strParts{4}(5:end);
runPath = fullfile(parentDir,strParts{3},runDir);
vidStatsPath = fullfile(runPath,[runDir '_videoStatistics.mat']);
if ~exist(vidStatsPath,'file')
    outcome = 'Video statistics does not exist';
    return
end
vidStats_loading = load(vidStatsPath);
datanameLoad = fieldnames(vidStats_loading);
vidStats = vidStats_loading.(datanameLoad{1});
vidPath = fullfile(runPath,vidName);
[~,videoID,vidExt] = fileparts(vidPath);
if ~exist(vidPath,'file')
    outcome = 'Video not found';
    return
end
try
    downloadOpRestrictedTest = strcmp(vidStats.download_option{videoID},'Restricted full rate');
    downloadOpCutrateTest = strcmp(vidStats.download_option{videoID},'Save Cut Rate');
    downloadOpFullrateTest = strcmp(vidStats.download_option{videoID},'Save Full Rate');
catch 
    outcome = 'Unexpected video statistics data';
    return
end
if downloadOpRestrictedTest
    vidNameSupp = [videoID '_supplement' vidExt];
    vidSuppPath = fullfile(runPath,'highSpeedSupplement',vidNameSupp);
    if ~exist(vidSuppPath,'file')
        outcome = 'Supplement does not exist';
        return
    end
    try
        vidObj = VideoReader(vidSuppPath);
    catch
        outcome = 'Supplement does not exist';
        return
    end
    suppFrmCt = vidObj.NumberOfFrames;
    suppTargetCt = numel(vidStats.supplement_frame_reference{videoID});
    if suppFrmCt ~= suppTargetCt
        outcome = 'Unexpected supplement frame count';
        return
    end
end
try
    vidObj = VideoReader(vidPath);
catch
    outcome = 'Corrupt video file';
    return
end
% vidObj = VideoPlayer(vidPath);
recFrmCt = vidObj.NumberOfFrames;
% recFrmCt = vidObj.NumFrames;
if downloadOpCutrateTest || downloadOpRestrictedTest
    masterFrmRefs = vidStats.cutrate10th_frame_reference{videoID};
elseif downloadOpFullrateTest
    masterFrmRefs = (1:vidStats.frame_count(videoID));
else
    outcome = 'Unknown download option';
    return
end
recTargetCt = numel(masterFrmRefs);
if recFrmCt ~= recTargetCt
    outcome = 'Unexpected cutrate frame count';
    return
end

vidH = vidObj.Height;
% vidH = vidObj.FrameHeight;
vidW = vidObj.Width;
% vidW = vidObj.FrameWidth;

roiPos = vidStats.roi{videoID};
stagePos = vidStats.prism_base{videoID};
avgPrismL = mean([roiPos(3)-roiPos(1),roiPos(4)-roiPos(2)]);

%top indexer
dim1b = mean(stagePos(:,2))*1.1;
dim1a = dim1b-avgPrismL/2;
if dim1a < 1, dim1a = 1; end
dwnAa = round(linspace(dim1a,dim1b,round(dwnSampl*(dim1b-dim1a))))';
dim2a = roiPos(1);
dim2b = roiPos(3);
dwnBa = round(linspace(dim2a,dim2b,round(dwnSampl*(dim2b-dim2a))));
dwnAb = repmat(dwnAa,1,numel(dwnBa));
dwnBb = repmat(dwnBa,numel(dwnAa),1);
dwnC = dwnAb+(dwnBb-1).*vidH;
topS = size(dwnC);

%bottom indexer
dim1b = roiPos(4);
dim1a = roiPos(2);
dwnAa = round(linspace(dim1a,dim1b,round(dwnSampl*(dim1b-dim1a))))';
dim2a = roiPos(1);
dim2b = roiPos(3);
if dim2b > vidW, dim2b = vidW; end
dwnBa = round(linspace(dim2a,dim2b,round(dwnSampl*(dim2b-dim2a))));
dwnAb = repmat(dwnAa,1,numel(dwnBa));
dwnBb = repmat(dwnBa,numel(dwnAa),1);
dwnC = [dwnC;dwnAb+(dwnBb-1).*vidH];

dwnS = size(dwnC);

rowCt = 2;
colCt = 5;
montyRefs = round(linspace(1,recFrmCt,rowCt*colCt));
montyIm = uint8(zeros(dwnS.*[rowCt colCt]));
frmRef = cell(rowCt*colCt,1);
labelPos = cell(rowCt*colCt,1);
for iterR = 1:rowCt
    for iterC = 1:colCt
        baseRef = (iterR-1)*colCt+iterC;
        frmRead = read(vidObj,montyRefs(baseRef));
%         frmRead = vidObj.getFrameAtNum(montyRefs(baseRef)-1);
%         frmRead = uint8(frmRead(:,:,1).*255);
        frmRead = frmRead(:,:,1);
        colRef = ((iterC-1)*dwnS(2)+1:(iterC)*dwnS(2));
        rowRef = ((iterR-1)*dwnS(1)+1:(iterR)*dwnS(1));
        montyFrm = frmRead(dwnC);
        montyFrm(1:3,:) = 50;
        montyFrm(end-2:end,:) = 50;
        montyFrm(:,1:3) = 50;
        montyFrm(:,end-2:end) = 50;
        
        try
            montyFrm(topS(1)-1:topS(1)+1,:) = 30;
        catch
            montyFrm(1:topS(1)+1,:) = 30;
        end
        
        montyIm(rowRef,colRef) = montyFrm;
        frmRef{baseRef} = masterFrmRefs(montyRefs(baseRef));
        labelPos{baseRef} = [colRef(1)+15 rowRef(1)+60]./fliplr(dwnS.*[rowCt colCt]);
    end
end
imAdjInput = stretchlim(montyIm,[0.01 0.999]);
imData = repmat(imadjust(montyIm,imAdjInput),[1 1 3]);
for iterT = 1:rowCt*colCt
        imData = textN2im_v2(imData,{num2str(frmRef{iterT})},26,labelPos{iterT},'left');
end

montyFileName = [videoID '_montage_v2.tif'];
montyPath = fullfile(montyDir,montyFileName);
imwrite(imData,montyPath);
% imshow(imData)

% Generate the earliest recorded frame
trigFrmAvail = false;
trigFrmDir = fullfile(runPath,'triggerFrames');
if isdir(trigFrmDir)
    trigName = [runDir '_triggerFrame' videoID(end-3:end) '.tif'];
    trigPath = fullfile(trigFrmDir,trigName);
    if exist(trigPath,'file')
        imFrm = imread(trigPath);
        imLabel = 'Trigger Frame';
        trigFrmAvail = true;
    end
end
if ~trigFrmAvail
%     imFrm = vidObj.getFrameAtNum(0);
    imFrm = read(vidObj,1);
%     imFrm = uint8(imFrm.*255);
    imLabel = 'First Recorded Frame';
end
backName = [runDir '_backgroundFrame' videoID(end-3:end) '.tif'];
backPath = fullfile(runPath,'backgroundFrames',backName);
if exist(backPath,'file')
    backFrm = imread(backPath);
    backFrm = repmat(backFrm(:,:,1),[1 1 3]);
    backFrm(:,:,2:3) = zeros(size(backFrm(:,:,2:3)));
else
    backFrm = zeros(size(imFrm(:,:,1)));
    backFrm = uint8(repmat(backFrm,[1 1 3]));
end
imFrm = imFrm(:,:,1)-backFrm(:,:,1);
imFrm(imFrm < 0) = 0;
imAdjInput = stretchlim(imFrm,[0.01 0.999]);
imData = repmat(imadjust(imFrm,imAdjInput),[1 1 3]);
imData = max(imData,backFrm);
imData = imresize(imData,1.5);
imData = textN2im_v2(imData,{imLabel},30,[.02 .05],'left');
imData = imresize(imData,(2/3));
% imshow(imData)

sampleFrameName = [videoID '_sampleFrame.tif'];
sampleFramePath = fullfile(sampleFrameDir,sampleFrameName);
imwrite(imData,sampleFramePath);

delete(vidObj)