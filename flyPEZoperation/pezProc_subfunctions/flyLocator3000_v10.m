function locator_data = flyLocator3000_v10(videoID,runMode)
%flyLocator3000_v10 This function assesses the first frame of a 'pez video'
%   First, the number of flies is assessed.  Then, the position of a single
%   fly is determined.  The results are automatically saved on the server
%   under the cardlab,pezProcessing,<your ID>_<this function's name>
%   directory.
persistent fine_struct tmplGeno tmplGenoRot
%% %%% visualization control %%%
show_coarse = 0;
showFinal = 0;
debug = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
locator_data = [];
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
subfun_dir = fullfile(repositoryDir,'pezProc_subfunctions');
saved_var_dir = fullfile(repositoryDir,'pezProc_saved_variables');
addpath(subfun_dir,saved_var_dir)
addpath(fullfile(repositoryDir,'Pez3000_Gui_folder','Matlab_functions','Support_Programs'))

%%%%% Loading templates
speciesFolder = 'Drosophila_melanogaster';
%archDir = '\\tier2\card';
archDir = '\\Dm11\cardlab';
templateDir = fullfile(archDir,'pez3000_flyTemplates',speciesFolder);

if isempty(mfilename) || nargin == 0
    runMode = 1;
    locator_name = 'flyLocator3000_v10';
    videoID = 'run002_pez3002_20180525_expt0113000025020586_vid0016';
    fine_struct = [];
end
if isempty(fine_struct)
    highresPath = fullfile(templateDir,[speciesFolder '_highResTemplate.mat']);
    fine_struct = importdata(highresPath);
    
    tmplName = '_flyDetectTemplate.mat';
    tmplLoading = load(fullfile(templateDir,[speciesFolder tmplName]));
    tmplGeno = tmplLoading.geno;
    
    tmplName = '_flyDetectTemplate_hortRot.mat';
    tmplLoading = load(fullfile(templateDir,[speciesFolder tmplName]));
    tmplGenoRot = tmplLoading.geno;
end
if ~isempty(mfilename)
    locator_name = mfilename;
end
strParts = strsplit(videoID,'_');
exptID = strParts{4}(5:end);

%%%% Establish data destination directories and file names
%analysisDir = fullfile('\\tier2','card','Data_pez3000_analyzed');
analysisDir = fullfile('\\DM11','cardlab','Data_pez3000_analyzed');
expt_results_dir = fullfile(analysisDir,exptID);
locator_visual_summary_dir = [expt_results_dir filesep exptID '_' locator_name '_summaryFigures'];
if ~isdir(locator_visual_summary_dir), mkdir(locator_visual_summary_dir),end
visual_result_path = fullfile(locator_visual_summary_dir,[videoID '_frame_one_labeled.jpg']);
locator_expt_ID = [videoID '_' locator_name '_data.mat'];%experiment ID
locator_data_dir = fullfile(expt_results_dir,[exptID '_' locator_name]);
if ~isdir(locator_data_dir), mkdir(locator_data_dir),end
locator_data_path = fullfile(locator_data_dir,locator_expt_ID);
if runMode > 2
    if exist(locator_data_path,'file')
        locator_record = load(locator_data_path);
        dataname = fieldnames(locator_record);
        locator_record = locator_record.(dataname{1});
        porf_test = locator_record.pass_or_fail{:};
        if porf_test == 1 %locator ran previously and passed
            return
        end
    end
end
%% Locator variables %
loc_varnames = {'pass_or_fail','template_R_square','template_threshold',...
    'gender_ref','gender_R_square','gender_threshold','fly_count','center_point',...
    'tracking_point','fly_length','fly_theta','tracking_hort','orig_video_path',...
    'gender_guess','end_points'};
locator_data = cell2table(cell(1,numel(loc_varnames)),'VariableNames',...
    loc_varnames,'RowNames',{videoID});

%%%%% Load assessment table
assessmentPath = fullfile(expt_results_dir,[exptID '_rawDataAssessment.mat']);
assessTable_import = load(assessmentPath);
dataname = fieldnames(assessTable_import);
assessTable = assessTable_import.(dataname{1});

runRef = videoID(1:23);
dateRef = runRef(end-7:end);
vidPath = fullfile('Z:\Data_pez3000',dateRef,runRef,[videoID '.mp4']);
locator_data.orig_video_path{1} = vidPath;
video_obj = VideoReader(vidPath);
vidHeight = video_obj.Height;
vidWidth = video_obj.Width;
roiPos = round(assessTable.Adjusted_ROI{videoID});
if isempty(roiPos)
    locator_data.pass_or_fail = {2};
    frame_one_visual = zeros(vidHeight,vidWidth);
    if debug == 1
        disp('empty roi')
    end
    closeFun
    return
end
[roiPos,prismW] = roi2crop(roiPos,vidWidth,vidHeight,-20);
frame_01 = read(video_obj,1);
frame_01 = frame_01(:,:,1);
frame_01_dbl = double((frame_01))./255;
frm_bot_square = frame_01_dbl((vidHeight-vidWidth+1):vidHeight,:);
imAdjInput = stretchlim(frm_bot_square,[0.01 0.999]);
frm_bot_adjust = imadjust(frm_bot_square,imAdjInput);

fly_count = 1;%%% this is presumed since data has been curated
locator_data.fly_count = {fly_count};

tmplLeg = (tmplGeno.source_dim-1)/2;
hortRefs = tmplGeno.hort_refs;
dwnFac = tmplGeno.dwnsampl_factor;

%%
imAdjInput = stretchlim(frm_bot_square,[0.2 1]);
imAdjInput(2) = imAdjInput(2)/2;
frm_morphed = imadjust(frm_bot_square,imAdjInput);

se1 = strel('disk',5);
se2 = strel('disk',5);
morph1 = imerode(frm_morphed,se1);
morph2 = imdilate(morph1,se2);
frm_morphed = double(morph2);
frm_morphed = imadjust(frm_morphed);

% imshow(frm_morphed)
if max(frm_morphed(:)) == 0
    locator_data.pass_or_fail = {2};
    frame_one_visual = frm_morphed;
    if debug == 1
        disp('empty frame')
    end
    closeFun
    return
end
frm_filtlined = lineMaker(frm_morphed);
frm_linedsml = imresize(frm_filtlined,dwnFac);
frm_linedsml(frm_linedsml <= 0) = min(frm_linedsml(frm_linedsml > 0));

frm_oneA = repmat(uint8(frm_bot_square*255),[1 1 3]);
frm_oneB = repmat(uint8(frm_filtlined*255),[1 1 3]);
I_flycounter = repmat(uint8(frm_morphed.*255),[1 1 3]);
frm_oneC = repmat(uint8(frm_bot_adjust.*255),[1 1 3]);
frm_oneB(:,:,1) = max(frm_oneB(:,:,1),uint8(frm_bot_adjust*255));
frm_oneD = cat(2,[frm_oneA;frm_oneC],[I_flycounter;frm_oneB]);

block_dim = 1;

initTmpl = tmplGeno.template_3D;
initNdxr = tmplGeno.indexer_3D;
rotOpsTmpl = size(initTmpl,2);
spokeL = size(initTmpl,1)/rotOpsTmpl;
sizeCt = size(initTmpl,3);
preTmpl = reshape(initTmpl(:,1,:),spokeL,rotOpsTmpl,sizeCt);
preTmpl = squeeze(mean(preTmpl,2));
preNdxR = reshape(initNdxr(:,1,:),spokeL,rotOpsTmpl,sizeCt);
preReNdxR = repmat((1:sizeCt),spokeL,1);

headTmplB = initTmpl(:,:,(hortRefs == 1));
layerFindr = repmat((1:size(headTmplB,3)),size(headTmplB,2),1);
layerFindr = layerFindr(:)';
headTmplA = reshape(headTmplB,size(headTmplB,1),size(headTmplB,2)*size(headTmplB,3));
tailTmplB = initTmpl(:,:,(hortRefs == 2));
tailTmplA = reshape(tailTmplB,size(tailTmplB,1),size(tailTmplB,2)*size(tailTmplB,3));

headNdxrB = initNdxr(:,:,(hortRefs == 1));
headNdxrA = reshape(headNdxrB,size(headNdxrB,1),size(headNdxrB,2)*size(headNdxrB,3));
tailNdxrB = initNdxr(:,:,(hortRefs == 2));
tailNdxrA = reshape(tailNdxrB,size(tailNdxrB,1),size(tailNdxrB,2)*size(tailNdxrB,3));
reNdxrPost = ones(size(tailNdxrA,1),1);

% tmplGenoRot = fine_struct.geno;
initTmplRot = tmplGenoRot.template_3D;
rotOpsTmplRot = (1:size(initTmplRot,2));
rotOpsTmplRot = -(rotOpsTmplRot-1)*3*(pi/180);

headTmplRot = initTmplRot(:,:,(hortRefs == 1));
tailTmplRot = initTmplRot(:,:,(hortRefs == 2));

initNdxrRot = tmplGenoRot.indexer_3D;
headNdxrRot = initNdxrRot(:,:,(hortRefs == 1));
tailNdxrRot = initNdxrRot(:,:,(hortRefs == 2));
reNdxrRot = ones(size(tailNdxrRot,1),1);


%% %%% The underside view fly detection begins here
roiBlock = frm_bot_adjust(roiPos(3):roiPos(4),...
    roiPos(1):roiPos(2));
roiBlock(prismW,prismW) = 0;
% imshow(roiBlock)
% return
roiBlkSml = imresize(roiBlock,dwnFac);

lrgDims = [roiPos(2)-roiPos(1),roiPos(4)-roiPos(3)];
smlDims = floor(lrgDims*dwnFac);
xOpsVec = (tmplLeg+1:block_dim:smlDims(2)-tmplLeg);
yOpsVec = (tmplLeg+1:block_dim:smlDims(1)-tmplLeg);
xOpsEdges = repmat(xOpsVec,1,numel(yOpsVec));
yOpsEdges = repmat(yOpsVec,numel(xOpsVec),1);
xOpsEdges = xOpsEdges(:);
yOpsEdges = yOpsEdges(:);

ptOps = [xOpsEdges(:),yOpsEdges(:)];
blkValPre = zeros(size(ptOps,1),1);
for iterTm = 1:size(ptOps,1)
    negDim = ptOps(iterTm,:)-tmplLeg;
    posDim = ptOps(iterTm,:)+tmplLeg;
    if max(negDim < 1), continue, end
    if max(posDim > fliplr(size(roiBlkSml))), continue, end
    blkPre = roiBlkSml(negDim(2):posDim(2),negDim(1):posDim(1));
    preNdxT = blkPre(preNdxR);
    blkNdxtPreB = squeeze(mean(preNdxT,2));
    blkMeanPreC = mean(blkNdxtPreB);
    preReNdxT = blkMeanPreC(preReNdxR);
    ss_totalPre = sum((blkNdxtPreB-preReNdxT).^2);
    ss_residPre = sum((blkNdxtPreB-preTmpl).^2);
    mvPre = max(1-ss_residPre./ss_totalPre);
    blkValPre(iterTm) = mvPre;
end
maxValPre = max(blkValPre);
if maxValPre < 0.5
    locator_data.pass_or_fail = {2};
    frame_one_visual = frm_oneD;
    if debug == 1
        disp(['maxValPre: ' num2str(maxValPre,3)])
    end
    closeFun
    return
end

[~,ptidx] = sort(blkValPre,'descend');
ptTryCt = 50;
ptTryVec = [-2,0,2];
xOffs = repmat(ptTryVec,[3,1,ptTryCt]);
yOffs = repmat(ptTryVec',[1,3,ptTryCt]);

xOps = ptOps(ptidx(1:ptTryCt),1);
yOps = ptOps(ptidx(1:ptTryCt),2);

xPlotEdges = xOps(:);
yPlotEdges = yOps(:);

xOps = repmat(xOps,numel(xOffs)/ptTryCt,1)+xOffs(:);
yOps = repmat(yOps,numel(yOffs)/ptTryCt,1)+yOffs(:);
ptOps = [xOps,yOps];
[~,uniqTest] = unique(cellstr(num2str(ptOps)),'stable');
ptOps = ptOps(uniqTest,:);

% Initialize the following to visualize fly-finding templates
% and the winning blocks (see commented-out sections below)
iDemo = 0;

headVals = posFinder(headNdxrA,headTmplA);
tailVals = posFinder(tailNdxrA,tailTmplA);
[headMax,headNdx] = max(headVals(:,1));
headPos = ptOps(headNdx,:);
[tailMax,tailNdx] = max(tailVals(:,1));
tailPos = ptOps(tailNdx,:);

%%%%%%%%%% Determines how similar the sampled image must be to the template
%%%%%%%%%% in order to continue locating
maxThresh = 0.4;

%%%% Independent test to see if points are too close together
headState = (headMax > maxThresh);
tailState = (tailMax > maxThresh);
if headState && tailState
    distTest = ptOps(headNdx)-ptOps(tailNdx);
    distTest = sqrt(sum(distTest.^2));
    distThresh = tmplLeg*(.75);
    if distTest < distThresh
        if headMax > tailMax
            headPos = ptOps(headNdx,:);
            ptDiff = repmat(headPos,size(ptOps,1),1)-ptOps;
            distDiff = sqrt(sum(ptDiff.^2,2));
            refPosOps = find(distDiff > distThresh);
            if ~isempty(refPosOps)
                tailVals = tailVals(refPosOps,:);
                [tailMax,tailNdx] = max(tailVals(:,1));
                tailPos = ptOps(refPosOps(tailNdx),:);
            else
                tailMax = 0;
            end
        else
            tailPos = ptOps(tailNdx,:);
            ptDiff = repmat(tailPos,size(ptOps,1),1)-ptOps;
            distDiff = sqrt(sum(ptDiff.^2,2));
            refPosOps = find(distDiff > distThresh);
            if ~isempty(refPosOps)
                headVals = headVals(refPosOps,:);
                [headMax,headNdx] = max(headVals(:,1));
                headPos = ptOps(refPosOps(headNdx),:);
            else
                headMax = 0;
            end
        end
    end
end

%%%% Determine theta
headState = (headMax > maxThresh);
tailState = (tailMax > maxThresh);
rotInset = 0;
if headState && tailState
    if headMax < tailMax
        headState = false;
    end
end
if headState
    headSize = layerFindr(headVals(headNdx,2));
    xPlot = headPos(1);
    yPlot = headPos(2);
    testY = max(headPos <= tmplLeg+1+rotInset);
    testX = max(fliplr(headPos) >= smlDims-tmplLeg-rotInset);
    testZ = headMax < maxThresh;
    if ~max([testX,testY,testZ])
        flyTheta = rotFinder(headPos,headNdxrRot(:,:,headSize),...
            headTmplRot(:,:,headSize));
    else
        flyTheta = NaN;
    end
elseif tailState
    tailSize = layerFindr(tailVals(tailNdx,2));
    xPlot = tailPos(1);
    yPlot = tailPos(2);
    testX = max(tailPos <= tmplLeg+1+rotInset);
    testY = max(fliplr(tailPos) >= smlDims-tmplLeg-rotInset);
    testZ = tailMax < maxThresh;
    if ~max([testX,testY,testZ])
        flyTheta = rotFinder(tailPos,tailNdxrRot(:,:,tailSize),...
            tailTmplRot(:,:,tailSize));
    else
        flyTheta = NaN;
    end
else
    locator_data.pass_or_fail = {2};
    frame_one_visual = frm_oneD;
    if debug == 1
        disp('maxThresh not reached')
    end
    closeFun
    return
end

% The following is to visualize the fly-finding templates
% and the winning blocks
iDemo = imresize(iDemo,(size(roiBlkSml)));
roiBlkSml = [roiBlkSml;iDemo];
%%
if show_coarse == 1
    close all
    imshow(roiBlkSml,'initialmagnification',300)
    hold on
    plot(xOpsEdges,yOpsEdges,'.','color',[.3 0 .5])
    plot(xPlotEdges,yPlotEdges,'.','color',[0 .8 0],'markersize',22)
    if ~isnan(flyTheta)
        
        text(5,5,['heading: ' num2str(round(flyTheta/(pi/180))) ' deg'],'color',[1 1 1])
        u = cos(flyTheta).*tmplLeg*2+1;
        v = -sin(flyTheta).*tmplLeg*2+1;
        if headState
            plot(xPlot,yPlot,'.','color',[1 0 0],'markersize',33)
        else
            plot(xPlot,yPlot,'.','color',[0 0 1],'markersize',33)
        end
        quiver(smlDims(1)/2,smlDims(2)/2,u,v,...
            'MaxHeadSize',1,'LineWidth',1.5,'AutoScaleFactor',1,'Color',[1 1 1]);
    end
    figPos = get(gcf,'position');
    set(gcf,'position',[1998 126 figPos(3:4)])
    drawnow
end


%% %%%%%% FlyDetect Subfunctions %%%%%%%
    function blkVal = posFinder(ndxr,tmpl)
        blkVal = zeros(size(ptOps,1),2);
        blkVal(:,1) = blkVal(:,1)-1;
        for iterF = 1:size(ptOps,1)
            negDim = ptOps(iterF,:)-tmplLeg;
            posDim = ptOps(iterF,:)+tmplLeg;
            if max(negDim < 1), continue, end
            if max(posDim > fliplr(size(roiBlkSml))), continue, end
            blk = roiBlkSml(negDim(2):posDim(2),negDim(1):posDim(1));
            blkNdxt = blk(ndxr);
            blkMeanPostA = mean(blkNdxt(:,1));
            blkMeanPostB = blkMeanPostA(reNdxrPost);
            ss_totalPost = sum((blkNdxt(:,1)-blkMeanPostB).^2);
            ss_residPost = sum((blkNdxt-tmpl).^2);
            [mvPost,miPost] = max(1-ss_residPost./ss_totalPost);
            blkVal(iterF,:) = [mvPost,miPost];
        end
        
        % The following is to visualize the fly-finding templates
        % and the winning blocks
        [~,maxPos] = max(blkVal(:,1));
        miB = blkVal(maxPos,2);
        if ~isnan(miB)
            negDim = ptOps(maxPos,:)-tmplLeg;
            posDim = ptOps(maxPos,:)+tmplLeg;
            if max(negDim < 1), return, end
            if max(posDim > fliplr(size(roiBlkSml))), return, end
            blk = roiBlkSml(negDim(2):posDim(2),negDim(1):posDim(1));
            blkNdxt = blk(ndxr);
            blkDemo = reshape(blkNdxt(:,miB),spokeL,rotOpsTmpl);
            tmplDemo = reshape(tmpl(:,miB),spokeL,rotOpsTmpl);
            demoBlk = imresize([blkDemo;tmplDemo],3);
            iDemo(size(demoBlk,1),end) = 0;
            demoBlk(size(iDemo,1),end) = 0;
            iDemo = [iDemo,zeros(size(demoBlk,1),10),demoBlk];
        end
    end

    function theta = rotFinder(pt,ndxr,tmpl)
        negDim = pt-tmplLeg;
        posDim = pt+tmplLeg;
        blk = roiBlkSml(negDim(2):posDim(2),negDim(1):posDim(1));
        blkNdxt = blk(ndxr);
        blkMeanA = mean(blkNdxt(:,1));
        blkMeanB = blkMeanA(reNdxrRot);
        ss_total = sum((blkNdxt(:,1)-blkMeanB).^2);
        ss_resid = sum((blkNdxt-tmpl).^2);
        [~,mi] = max(1-ss_resid./ss_total);
        tryRot = flipud(rotOpsTmplRot(:));
        theta = tryRot(mi);
        
        % The following is to visualize the fly-finding templates
        % and the winning blocks
        blkDemo = reshape(blkNdxt(:,mi),spokeL,120);
        tmplDemo = reshape(tmpl(:,mi),spokeL,120);
        demoBlk = imresize([blkDemo;tmplDemo],2);
        iDemo(end,size(demoBlk,2)) = 0;
        demoBlk(end,size(iDemo,2)) = 0;
        iDemo = [iDemo;zeros(size(demoBlk));demoBlk];
    end

%%
coarse_row_refs = yPlot+roiPos(3)*dwnFac;
coarse_col_refs = xPlot+roiPos(1)*dwnFac;

geno = fine_struct.geno;
form = fine_struct.form;

indexer = geno.indexer_3D;
template = geno.template_3D;
spoke_count = size(indexer,2);
source_dim = geno.source_dim;
source_leg = (source_dim-1)/2;
frm_small = imresize(frm_bot_adjust,dwnFac);
I_pad = padarray(frm_small,[source_leg+1 source_leg+1]);
coarse_pos = zeros(2,2);
trg_found = zeros(2,2);
coarse_radians = zeros(2,1);
u = zeros(2,1);
v = zeros(2,1);
best_fit = zeros(2,1);
length_guesses = zeros(2,1);
form_ref_tally = zeros(2,1);
hort_ref_tally = zeros(2,1);
for iterA = 1:2
    coarse_row_ref = double(coarse_row_refs+source_leg);
    coarse_col_ref = double(coarse_col_refs+source_leg);
    pt_mag = 1;
    pt_count = block_dim*2+1;
    pt_leg = (pt_count-1)/2;
    adj1 = linspace(-pt_leg*pt_mag,pt_leg*pt_mag,pt_count);
    adj2_1 = repmat(adj1,pt_count,1);
    adj2_2 = repmat(adj1,1,pt_count);
    adj_ops = [adj2_1(:) adj2_2(:)];
    trial_count = pt_count^2;
    pos_ops = repmat([coarse_col_ref coarse_row_ref],[trial_count 1])+adj_ops;
    
%     pos_ops = [ptOps(:,1)+roiPos(1)*dwnFac ptOps(:,2)+roiPos(3)*dwnFac]+source_leg;
%     trial_count = size(pos_ops,1);
    
    val_list = zeros(trial_count,1);
    theta_result_list = zeros(trial_count,1);
    layer_list = zeros(trial_count,1);
    crop_dims = [pos_ops-source_leg repmat(source_dim-1,trial_count,1),...
        repmat(source_dim-1,trial_count,1)];
    for iterB = 1:trial_count
        I_source = imcrop(I_pad,crop_dims(iterB,:));
        temp_test = I_source(indexer);
        hone_diff = abs(template-temp_test);
        hone_sum = squeeze(sum(hone_diff));
        hone_min = min(hone_sum(:));
        val_list(iterB) = hone_min(1);
        [theta_result_list(iterB),layer_list(iterB)] = find(val_list(iterB) == hone_sum,1);
    end
    min_vals = min(val_list);
    best_fit(iterA) = min_vals(1);
    best_trial = find(best_fit(iterA) == val_list,1);
    trg_found(iterA,:) = pos_ops(best_trial,:)-source_leg;
    spoke_ref = theta_result_list(best_trial);
    coarse_radians(iterA) = (spoke_ref-1)/spoke_count*2*pi;%direction fly is facing
    
    % uses small fly length (used in template-making) over fly_length_guess as ratio to adjust inset
    best_layer_ref = layer_list(best_trial);
    form_ref = geno.form_refs(best_layer_ref);
    hort_ref = geno.hort_refs(best_layer_ref);
    full_size_ref = geno.size_refs(best_layer_ref);
    fly_length_guess = geno.size_options(full_size_ref);
    hort_multiplier = [-1 1];
    hort_factor = hort_multiplier(hort_ref);
    tmpl_inset_mag = geno.hort_inset(hort_ref);
    fly_length_factor = fly_length_guess/min(geno.size_options);
    inset_adjusted = tmpl_inset_mag*fly_length_factor*hort_factor*(-1);
    [adj_x,adj_y] = pol2cart(coarse_radians(iterA),inset_adjusted);
    coarse_pos(iterA,:) = trg_found(iterA,:)+[adj_x -adj_y];
    u(iterA) = cos(coarse_radians(iterA))*(fly_length_guess)/2*hort_factor;
    v(iterA) = -sin(coarse_radians(iterA))*(fly_length_guess)/2*hort_factor;
    length_guesses(iterA) = fly_length_guess;
    form_ref_tally(iterA) = form_ref;
    hort_ref_tally(iterA) = hort_ref;
end

hort_master_ref = find(min(best_fit) == best_fit,1,'first');
hort_ref = hort_ref_tally(hort_master_ref);
hort_multiplier = [1 -1];
hort_factor = hort_multiplier(hort_ref);
fly_length_guess = length_guesses(hort_master_ref);
radians_init = coarse_radians(hort_master_ref);
trg_outset = coarse_pos(hort_master_ref,:);

%%%%%%%% Establish the midline points
sml_point_form = zeros(4,2,2);
corr_form = zeros(4,2);
radians_form = zeros(4,2);
sml_length_form = zeros(4,2);
combo_cell = cell(1,2);
for iterC = 1:2
    form_ref = iterC;
    full = form(form_ref).full;
    full_XData = full.XData;
    full_YData = full.YData;
    full_image = full.image;
    
    full_segment = full.full_segment.*hort_factor;
    full_segment_count = full.full_segment_count;
    trg_segment = fly_length_guess/full_segment_count.*hort_factor.*(-1);
    
    degree_swing = 10;
    degree_count = 5;
    theta_hex = [linspace(-pi+pi/6,pi,12)';linspace(-pi+pi/4,pi,8)'
        linspace(-pi+pi/3,pi,6)';0];
    rhos_hex = [repmat(4,12,1);repmat(3,8,1);repmat(2,6,1);0];
    [x1_shift,y1_shift] = pol2cart(theta_hex,rhos_hex);
    end_hone_count = length(x1_shift);
    
    I_tally = cell(4,1);
    dim_tallyA = zeros(4,1);
    init1_ops = cell(4,1);
    init2_ops = cell(4,1);
    
    for iterD = 1:4
        
        switch iterD
            case 1
                segment_multiplier = 2;
                trg_dest1 = full.init_dests(hort_ref,:);
                trg_dest2 = trg_dest1;
                trg_dest2(1) = trg_dest2(1)+full_segment*segment_multiplier;
                
                crop_factor = 0.15;
                crop_pt_init = full.init_dests(hort_ref,:);
                crop_pt_C = round(crop_pt_init(1)+full_segment*0.3);
                crop_pt_R = round(crop_pt_init(2));
                crop_leg_R = round((full_YData(2)-1)/2*0.85);
                
                trg_init1_1 = repmat(trg_outset,end_hone_count,1)+[x1_shift -y1_shift];
                trg_init1_2x = repmat(trg_init1_1(:,1)',degree_count,1);
                trg_init1_2y = repmat(trg_init1_1(:,2)',degree_count,1);
                trg_init1_opsX = [trg_init1_2x(:) trg_init1_2y(:)];
                
                theta_ops = linspace(-pi/180*degree_swing,pi/180*degree_swing,...
                    degree_count)+radians_init;
                rhos_ops = repmat(trg_segment*2,degree_count,1);
                [x2_shift,y2_shift] = pol2cart(theta_ops(:),rhos_ops(:));
                init2_shift = repmat([x2_shift -y2_shift],end_hone_count,1);
                trg_init2_opsX = trg_init1_opsX+init2_shift;
                trg_step_count = end_hone_count;
                pt_selection_ID = 1;
            case 2
                segment_multiplier = 3;
                degree_swing = 12;
                degree_count = 17;
                theta_range = linspace(-pi/180*degree_swing,pi/180*degree_swing,degree_count)+radians_init;
                
                trg_step_count = 5;
                trg_steps = linspace(trg_segment*2.75,trg_segment*3.25,trg_step_count);
                
                trg_init1 = sml_point_form(1,:,iterC);
                trg_init1_opsX = repmat(trg_init1,...
                    trg_step_count*degree_count,1);
                
                theta_ops = repmat(theta_range,1,trg_step_count);
                rhos_ops = repmat(trg_steps,degree_count,1);
                [x2_shift,y2_shift] = pol2cart(theta_ops(:),rhos_ops(:));
                trg_init2_opsX = trg_init1_opsX+[x2_shift -y2_shift];
                
                trg_dest1 = full.init_dests(hort_ref,:);
                trg_dest2 = trg_dest1;
                trg_dest2(1) = trg_dest2(1)+full_segment*segment_multiplier;
                crop_factor = 0.33;
                crop_pt_init = full.init_dests(hort_ref,:);
                crop_pt_C = round(crop_pt_init(1)+full_segment*full_segment_count*1/2);
                crop_pt_R = round(crop_pt_init(2));
                crop_leg_R = round((full_YData(2)-1)/2);
                pt_selection_ID = 2;
            case 3
                trg_step_count = 9;
                trg_steps = linspace(trg_segment*2.5,trg_segment*3.5,trg_step_count);
                
                trg_init1 = sml_point_form(2,:,iterC);
                trg_init1_opsX = repmat(trg_init1,...
                    trg_step_count*degree_count,1);
                
                theta_ops = repmat(theta_range,1,trg_step_count);
                rhos_ops = repmat(trg_steps,degree_count,1);
                [x2_shift,y2_shift] = pol2cart(theta_ops(:),rhos_ops(:));
                trg_init2_opsX = trg_init1_opsX+[x2_shift -y2_shift];
                
                
                trg_dest1 = full.init_dests(hort_ref,:);
                trg_dest1(1) = trg_dest1(1)+full_segment*segment_multiplier;
                trg_dest2 = trg_dest1;
                trg_dest2(1) = trg_dest2(1)+full_segment*segment_multiplier;
                crop_factor = 0.33;
                crop_pt_init = full.init_dests(hort_ref,:);
                crop_pt_C = round(crop_pt_init(1)+full_segment*full_segment_count*3/4);
                crop_pt_R = round(crop_pt_init(2));
                crop_leg_R = round((full_YData(2)-1)/2);
            case 4
                degree_count = 1;
                crop_factor = 0.15;
                crop_pt_init = full.init_dests(hort_ref,:);
                crop_pt_C = round(crop_pt_init(1)+full_segment*full_segment_count-full_segment*0.15);
                crop_pt_R = round(crop_pt_init(2));
                crop_leg_R = round((full_YData(2)-1)/2*0.85);
                
                trg_init2_opsX = repmat(sml_point_form(3,:,iterC),end_hone_count,1)+[x1_shift -y1_shift];
                trg_init1_opsX = repmat(sml_point_form(2,:,iterC),end_hone_count,1);
                trg_step_count = end_hone_count;
        end
        crop_leg_C = round(source_dim*crop_factor);
        out_pts = [trg_dest1;trg_dest2];
        point_count = trg_step_count*degree_count;
        vals_list = zeros(point_count,1);
        trg_cell = cell(1,point_count);
        full_cell = cell(1,point_count);
        for j = 1:point_count
            in_pts = [trg_init1_opsX(j,:)
                trg_init2_opsX(j,:)];
            trg_tform = cp2tform(in_pts,out_pts,'nonreflective similarity');
            trg_regis = imtransform(frm_linedsml,trg_tform,'XData',full_XData,...
                'YData',full_YData,'FillValues',0.01);
            trg_crop = trg_regis(crop_pt_R-crop_leg_R:crop_pt_R+crop_leg_R,...
                crop_pt_C-crop_leg_C:crop_pt_C+crop_leg_C);
            full_crop = full_image(crop_pt_R-crop_leg_R:crop_pt_R+crop_leg_R,...
                crop_pt_C-crop_leg_C:crop_pt_C+crop_leg_C);
            sampl_vals = trg_crop;
            model_vals = full_crop;
            ss_total = sum((sampl_vals(:)-mean(sampl_vals(:))).^2);
            ss_resid = sum((sampl_vals(:)-model_vals(:)).^2);
            vals_list(j) = 1-ss_resid/ss_total;
            trg_cell{j} = trg_crop;
            full_cell{j} = full_crop;
        end
        
        init_val = max(vals_list(:));
        init_ref = find(init_val(1) == vals_list,1);
        trg_points = [trg_init1_opsX(init_ref,:);trg_init2_opsX(init_ref,:)];
        trg_point_diff = diff(trg_points);
        sml_point_form(iterD,:,iterC) = trg_points(pt_selection_ID,:);
        corr_form(iterD,iterC) = init_val;
        [radians,rho_frag] = cart2pol(trg_point_diff(1),-trg_point_diff(2));
        radians = radians+(pi*(hort_ref-2));
        if radians < 0, radians = radians+2*pi; end
        radians_form(iterD,iterC) = radians;
        trg_segment = rho_frag/segment_multiplier*hort_factor*(-1);
        sml_length_form(iterD,iterC) = trg_segment;
        
        I_tally{iterD} = [trg_cell{init_ref} ones(size(trg_crop,1),1) full_cell{init_ref}];
        dim_tallyA(iterD) = size(I_tally{iterD},2);
        init1_ops{iterD} = trg_init1_opsX;
        init2_ops{iterD} = trg_init2_opsX;
        
    end
    max_dimA = max(dim_tallyA);
    spacerA = ones(1,max_dimA);
    for iterE = 1:4
        I_tally{iterE}(end,max_dimA) = 0;
        I_tally{iterE} = [spacerA;I_tally{iterE};spacerA];
    end
    I_show_array = cat(1,I_tally{:});
    I_showA = frm_linedsml;
    max_dim = max(size(I_showA,1),size(I_tally,1));
    I_showA(max_dim,end) = 0;
    I_show_array(max_dim,end) = 0;
    spacer = ones(max_dim,2);
    I_combo = [I_showA spacer I_show_array];
    
    I_combo_RGB = repmat(uint8(I_combo.*255),[1 1 3]);
    ops1 = cat(1,init1_ops{1:3});
    ops2 = cat(1,init2_ops{1:3});
    mid_pts1 = sml_point_form(1:3,:);
    mid_pts2 = sml_point_form(4,:);
    I_combo_RGB = pointsN2im(ops1,I_combo_RGB,1,[0.4 0 0]);
    I_combo_RGB = pointsN2im(ops2,I_combo_RGB,1,[0.4 0 0]);
    I_combo_RGB = pointsN2im(init2_ops{4},I_combo_RGB,1,[0 0 0.4]);
    I_combo_RGB = pointsN2im(mid_pts1,I_combo_RGB,1,[0 1 0]);
    I_combo_RGB = pointsN2im(mid_pts2,I_combo_RGB,1,[0 1 0]);
    combo_cell{iterC} = I_combo_RGB;
end

combo_cell{1}(end-1:end,:,:) = 255;
composite_array = cat(1,combo_cell{:});
compo_rescale_factor = size(frm_oneD,1)/size(composite_array,1);
composite_full = imresize(composite_array,compo_rescale_factor,'nearest');
composite_full(:,1:4,:) = 255;

points_form = sml_point_form./dwnFac;
length_form = (sml_length_form./dwnFac).*full_segment_count;
found_test = max(mean(corr_form(1:2,:)));
found_thresh = 0.033;

locator_data.template_R_square = {found_test};
locator_data.template_threshold = {found_thresh};
frm_oneE = cat(2,frm_oneD,composite_full);
if found_test < found_thresh
    locator_data.pass_or_fail = {2};
    frame_one_visual = frm_oneE;
    if debug == 1
        disp('found_thresh not reached')
    end
    closeFun
    return
end
locator_data.pass_or_fail = {1};

[wobble_val,wobble_ind] = max(corr_form(3:4,:));
wobble_ind = wobble_ind+2;
corr_form(3,:) = wobble_val;
corr_form(4,:) = [];
points_form(3,:,1) = points_form(wobble_ind(1),:,1);
points_form(3,:,2) = points_form(wobble_ind(2),:,2);
points_form(4,:,:) = [];
radians_form(3,:) = radians_form(wobble_ind);
radians_form(4,:) = [];
radians_form(1,:) = radians_form(2,:);
length_form(3,:) = length_form(wobble_ind);
length_form(4,:) = [];
length_form(1,:) = length_form(2,:);

if hort_ref == 2
    points_form = cat(3,flipud(points_form(:,:,1)),...
        flipud(points_form(:,:,2)));
    radians_form = flipud(radians_form);
    length_form = flipud(length_form);
    corr_form = flipud(corr_form);
end

%%%% Determine gender and confidence
[form_test,form_winr] = max(mean(corr_form(2:3,:)));
form_thresh = 0.1;

locator_data.gender_R_square = {form_test};
locator_data.gender_threshold = {form_thresh};
if form_test < form_thresh
    locator_data.gender_ref = {3};
else
    locator_data.gender_ref = {form_winr};
end

%%%%% Define tracking variables
[~,form_winrB] = max(mean(corr_form));
locator_data.gender_guess = {form_winrB};
points_winr = points_form(:,:,form_winrB);
frm_centr = [round(median(roiPos(1:2,1))) round(median(roiPos(1:2,2)))];
end_pts = points_winr;
end_pts(2,:) = [];
[~,trk_hort_ref] = min(pdist2(end_pts,frm_centr));
locator_data.tracking_hort = {trk_hort_ref};
trk_end_pt = end_pts(trk_hort_ref,:);
locator_data.tracking_point = {trk_end_pt};
heading_ref = find(corr_form(:,form_winrB) > found_thresh,1,'first');
if isempty(heading_ref) == 1
    heading_ref = find(corr_form(:,form_winrB) == max(corr_form(:,form_winrB)),1,'first');
end
cntr_pt_init = points_winr(2,:);
locator_data.center_point = {cntr_pt_init};
fly_length = abs(length_form(heading_ref,form_winrB));
locator_data.fly_length = {fly_length};
fly_theta = radians_form(heading_ref,form_winrB);
locator_data.fly_theta = {fly_theta};
winr_vis = points_winr;
winr_vis(:,2) = winr_vis(:,2)+vidWidth;
cntr_vis = cntr_pt_init;
cntr_vis(2) = cntr_vis(2)+vidWidth;
trk_vis = trk_end_pt;
trk_vis(2) = trk_vis(2)+vidWidth;

u = cos(fly_theta)*(fly_length)/2;
v = -sin(fly_theta)*(fly_length)/2;
arrow_end = cntr_vis+[u v];
arrow_ptsX = linspace(cntr_vis(1),arrow_end(1),10);
arrow_ptsY = linspace(cntr_vis(2),arrow_end(2),10);
arrow_pts = [arrow_ptsX' arrow_ptsY'];
frm_oneF = pointsN2im(winr_vis,frm_oneE,4,[0 1 0]);
frm_oneF = pointsN2im(cntr_vis,frm_oneF,4,[0 0 1]);
frm_oneF = pointsN2im(trk_vis,frm_oneF,4,[1 0 0]);
frm_oneF = pointsN2im(arrow_pts,frm_oneF,2,[0 0 1]);

frame_one_visual = frm_oneF;
closeFun

    function closeFun
        %%%%% Generate visual readout of locator results
        report_labels = {'Decision:','Template R-square:','Template threshold:',...
            'Gender:','Gender R-square:','Gender threshold:','Fly length:'};
        report_vals = cell(1,numel(report_labels));
        fail_ops = {'Trackable Fly','Fly Not Found'};
        report_vals{1} = fail_ops{locator_data.pass_or_fail{:}};
        report_vals{2} = locator_data.template_R_square{:};
        report_vals{3} = locator_data.template_threshold{:};
        form_winr = locator_data.gender_ref{:};
        form_winrB = locator_data.gender_guess{:};
        if ~isempty(form_winr)
            form_ops = {'Female','Male','Unknown'};
            report_vals{4} = form_ops{form_winr};
            if form_winr == 3
                report_vals{4} = [form_ops{form_winr} ', guessing ' form_ops{form_winrB}];
            end
            report_vals{5} = locator_data.gender_R_square{:};
            report_vals{6} = locator_data.gender_threshold{:};
            fly_length = locator_data.fly_length{:};
            prismW = mean(roiPos(2,:)-roiPos(1,:)-30);%minus 30 to account for roi swell in pezControl_v9
            length_in_mm = round(fly_length*100*(5/prismW))/100;%prism is 5mm wide
            report_vals{7} = [num2str(length_in_mm,2) ' mm'];
        end
        final_report = cat(1,report_labels,report_vals);
        report_block = zeros(size(frame_one_visual,1),280);
        char_blanks = repmat({' '},size(final_report));
        reports_title = 'FLY LOCATOR RESULTS';
        labels_cell = cat(1,final_report,char_blanks);
        labels_cell = cat(1,reports_title,char_blanks(:,1),labels_cell(:));
        if ~isempty(locator_data.template_R_square{1})
            report_block = textN2im(report_block,labels_cell,12,[0.1 0.3]);
            frame_one_labeled = cat(2,repmat(uint8(report_block.*255),[1 1 3]),frame_one_visual);
        else
            frame_one_labeled = frame_one_visual;
        end
        if showFinal
            close all
            imshow(frame_one_labeled)
            set(gcf,'position',[1998 126 1734 854])
            drawnow
        end
        imwrite(frame_one_labeled,visual_result_path,'jpg');
        
        saveobj = locator_data;
        save(locator_data_path,'saveobj')
    end
end
