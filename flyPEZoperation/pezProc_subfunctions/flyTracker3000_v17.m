function tracker_record = flyTracker3000_v17(videoID,locator_name,runMode)

%%%%%%%%%% Display control
showMovie = 0;
debug = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%
tracker_record = [];
if isempty(mfilename) || nargin == 0
    runMode = 1;
    tracker_name = 'flyTracker3000_v17';
    locator_name = 'flyLocator3000_v10';
    videoID = 'run013_pez3001_20180420_expt0113000025020586_vid0002';
end
if ~isempty(mfilename)
    tracker_name = mfilename;
end
strParts = strsplit(videoID,'_');
runID = [strParts{1} '_' strParts{2} '_' strParts{3}];
exptID = strParts{4}(5:end);

%%%% Establish data destination directory
%analysisDir = fullfile('\\tier2','card','Data_pez3000_analyzed');
analysisDir = fullfile('\\DM11','cardlab','Data_pez3000_analyzed');
expt_results_dir = fullfile(analysisDir,exptID);
tracker_expt_ID = [videoID '_' tracker_name '_data.mat'];%experiment ID
tracker_data_dir = fullfile(expt_results_dir,[exptID '_' tracker_name]);
if ~isdir(tracker_data_dir), mkdir(tracker_data_dir),end
tracker_data_path = fullfile(tracker_data_dir,tracker_expt_ID);
if runMode > 2
    if exist(tracker_data_path,'file')
        if debug == 1
            disp('data already exists')
        end
        return
    end
end
%%%%% Load locator data
locDir = fullfile(expt_results_dir,[exptID '_' locator_name]);
locator_data_path = fullfile(locDir,[videoID '_' locator_name '_data.mat']);
if exist(locator_data_path,'file')
    locator_record = load(locator_data_path);
    dataname = fieldnames(locator_record);
    locator_record = locator_record.(dataname{1});
else
    if debug == 1
        disp('no locator file')
    end
    return
end
porf_test = locator_record.pass_or_fail{:};
if porf_test ~= 1
    if debug == 1
        disp('locator failed')
    end
    return
end

%%%%% Load assessment table
assessmentPath = fullfile(expt_results_dir,[exptID '_rawDataAssessment.mat']);
assessTable_import = load(assessmentPath);
dataname = fieldnames(assessTable_import);
assessTable = assessTable_import.(dataname{1});

% Tracker variables %
trk_varnames = {'top_centroid','bot_centroid','top_maj_theta','top_maj_rho','top_min_rho',...
    'bot_theta','mvmnt_ref','wings_trk','belly_trk','range_trk','change_trk','locator_path'};
tracker_record = cell2table(cell(1,numel(trk_varnames)),'VariableNames',...
    trk_varnames,'RowNames',{videoID});
tracker_record.locator_path = {locator_data_path};

%%%%% Read video file
vidPath = locator_record.orig_video_path{1};
vidPath = regexprep(vidPath,'arch','tier2');
if contains(vidPath,'tier2')
    vidPath = regexprep(vidPath,'card\','cardlab\');
    vidPath = regexprep(vidPath,'tier2\','dm11\');
end
slashPos = strfind(vidPath,'\');
pathlistKeep = vidPath(1:slashPos(end)-1);
%
vidstatname = [runID '_videoStatistics.mat'];
pathlistKeep = regexprep(pathlistKeep,'arch','tier2');
vidstatPath = fullfile(pathlistKeep,vidstatname);
vidStatsLoad = load(vidstatPath);
vidStats = vidStatsLoad.vidStats;

frameRefcutrate = vidStats.cutrate10th_frame_reference{videoID};
frameReffullrate = vidStats.supplement_frame_reference{videoID};

Y = (1:numel(frameRefcutrate));
xi = (1:numel(frameRefcutrate)*10);
yi = repmat(Y,10,1);
yi = yi(:);
[~,xSuppl] = ismember(frameReffullrate,xi);
objRefVec = ones(1,numel(frameRefcutrate)*10);
objRefVec(xSuppl) = 2;
yi(xSuppl) = (1:numel(frameReffullrate));
frameReferenceMesh = [xi(:)';yi(:)';objRefVec(:)'];

vidPathH = fullfile(pathlistKeep,'highSpeedSupplement',[videoID '_supplement.mp4']);
try
    vidObjA = VideoReader(vidPath);
    if exist(vidPathH,'file')
        vidObjB = VideoReader(vidPathH);
    else
        vidObjB = vidObjA;
    end
catch ME
    getReport(ME)
    disp(vidPath)
    if debug == 1
        disp('video file failed to open')
    end
    return
end

vidWidth = vidObjA.Width;
vidHeight = vidObjA.Height;
roiPos = assessTable.Adjusted_ROI{videoID};
roiPos = roi2crop(roiPos,vidWidth,vidHeight,-20);
%     tol = [0.9 1];
%     video_init = read(vidObjA,[1 10]);
%     frame_01_gray = uint8(mean(squeeze(video_init(:,:,1,:)),3));
%     frm_half_gray = frame_01_gray(vidWidth+1:end,:);
%     [~,frm_graymap] = gray2ind(frm_half_gray,256);
%     lowhigh_in = stretchlim(frm_half_gray,tol);
%     frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],0.9);
%     frm_remapB = uint8(frm_remap(:,1).*255);
%     frm_half_gray = frame_01_gray(1:vidWidth,:);
%     [~,frm_graymap] = gray2ind(frm_half_gray,256);
%     lowhigh_in = stretchlim(frm_half_gray,tol);
%     frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],0.7);
%     frm_remapT = uint8(frm_remap(:,1).*255);



writeRefs = xi;
video_3D = uint8(zeros(vidHeight,vidWidth,10));
for iterF = 1:10
    frameRead = frameReferenceMesh(2,writeRefs(iterF));
    readObjRef = frameReferenceMesh(3,writeRefs(iterF));
    if isnan(frameRead)
        frameW = read(vidObjA,vidObjA.NumberOfFrames);
    elseif readObjRef == 1
        frameW = read(vidObjA,frameRead);
    else
        frameW = read(vidObjB,frameRead);
    end
    frameW = frameW(:,:,1);
    video_3D(:,:,iterF) = frameW;
    %         vid_bot = frameW(vidWidth+1:end,:);
    %         vid_top = frameW(1:vidWidth,:);
    %         vid_bot = intlut(vid_bot,frm_remapB);
    %         vid_top = intlut(vid_top,frm_remapT);
    %         frameW = cat(1,vid_top,vid_bot);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vidWidth = vidObjA.Width;
vid_count = numel(writeRefs);
video_3D = read(vidObjA,[1 10]);
video_3D = squeeze(video_3D(:,:,1,:));

%%%%% Define tracking variables
trk_hort_ref = locator_record.tracking_hort{:};
trk_end_pt = locator_record.tracking_point{:};
cntr_pt_init = locator_record.center_point{:};
fly_length = locator_record.fly_length{:};
fly_theta = locator_record.fly_theta{:};

% parent_dir = 'C:\Users\williamsonw\Documents\pezAnalysisRepository';
% subfun_dir = fullfile(parent_dir,'pezProc_subfunctions');
% addpath(subfun_dir)

%%%%% Establishing background and re-mapper
frame_01_gray = uint8(mean(video_3D(:,:,1:10),3));%avg 1st 10 frames; est. background
frm_B_gray = frame_01_gray(end-vidWidth+1:end,:);
frm_T_gray = frame_01_gray(1:vidWidth,:);

frm_centr = round(size(frm_T_gray,2)/2);
lim_leg = fly_length/2;
if cntr_pt_init(1) < frm_centr(1)
    lim_boundA = round(cntr_pt_init(1));
    lim_boundB = round(cntr_pt_init(1)+lim_leg);
else
    lim_boundA = round(cntr_pt_init(1)-lim_leg);
    lim_boundB = round(cntr_pt_init(1));
end
level_gray_T = graythresh(frm_T_gray(:,lim_boundA:lim_boundB))*0.6;

frm_bot = double(frm_B_gray)./255;
frm_top = double(frm_T_gray)./255;


%%%%% Initializing top frame (side view)
se_top1 = strel('disk',3);
se_top2 = strel('disk',9);%22
se_top3 = strel('disk',9);%15
BW1_top = im2bw(frm_top,level_gray_T);
BW_top2 = imdilate(BW1_top,se_top1);
BW_top2 = imerode(BW_top2,se_top2);
BW_top = imdilate(BW_top2,se_top3);

stats = regionprops(BW_top,'Centroid','MajorAxisLength','MinorAxisLength',...
    'Orientation','ConvexArea');
pixel_count = [stats.ConvexArea]';
if isempty(pixel_count)
    if debug == 1
        disp('empty frame one')
    end
    return
end
pixel_val = max(pixel_count);
stat_ref = find(pixel_val == pixel_count,1,'first');
top_centroid = stats(stat_ref).Centroid;
maj_theta = pi/180*(stats(stat_ref).Orientation+180);
maj_rho = stats(stat_ref).MajorAxisLength/2;
min_rho = stats(stat_ref).MinorAxisLength/2;

%%%%% Initialize Wings and Belly
top_com_init = top_centroid;%for wing stuffs
min_rho_init = min_rho;%for wing stuffs
wingY = round((top_com_init(2)-min_rho_init*2-2:top_com_init(2)-min_rho_init*2+2));
wingY(wingY < 1) = 1;
wingX = (1:vidWidth);
wingLine = frm_top(wingY,wingX);
wingTestA = [wingLine(:)';wingLine(:)'.*0];
wingTest = std(wingTestA(:));
bellY = round(top_com_init(2)+min_rho_init*0.5);
bellX = round(top_com_init(1)-min_rho_init*2:top_com_init(1)+min_rho_init*2);
bellY(bellY < 1) = 1;
bellY(bellY > vidWidth) = vidWidth;
bellX(bellX < 1) = 1;
bellX(bellX > vidWidth) = vidWidth;
bellLine = frm_top(bellY,bellX);
bellInit = sum(bellLine);
bellyTest = sum(bellLine)/bellInit;
%%%%% Initializing variables used for tracking

%TEMPL_*** is identical, centered replicates!!! (taken from older, centered frame)
%SAMPL_*** contains posible new positions and has unknown center!!! (taken from new frame)
src_fac = 0.3;
src_leg = round(fly_length*(src_fac));
[ndxr_struct] = trackingIndexer_spoked4crop(src_leg,trk_hort_ref);
mastr_findr = ndxr_struct.mastr_findr;
spoke_length = ndxr_struct.spoke_length;
spoke_leg = ndxr_struct.spoke_leg;
im_leg = ndxr_struct.im_leg;
spoke_count = ndxr_struct.spoke_count;
sampl_ndxr_mastr = (ndxr_struct.sampl_mastr);
templ_ndxr_mastr = (ndxr_struct.templ_mastr);
templ_rendxr = (ndxr_struct.templ_rendxr);
spoke_ndxr_mastr = (ndxr_struct.spoke_mastr);
spoke_span = spoke_leg*2+1;
radians_per_spoke = 2*pi/spoke_count;
layer_ref = round(fly_theta/radians_per_spoke);
layer_ref(layer_ref > spoke_count) = layer_ref-spoke_count;
layer_ref(layer_ref <= 0 ) = layer_ref+spoke_count;

%%%%% Initialize bottom frame (under-side view)
inset_count = 4;
inset_bounds = [src_fac*2*(.95) src_fac*2*(1.05)];
trk_inset_ops = repmat(linspace(inset_bounds(1),inset_bounds(2),inset_count)',1,2);
trk_pos_ops = repmat((cntr_pt_init-trk_end_pt),inset_count,1).*trk_inset_ops;
trk_pos_ops = round(repmat(trk_end_pt,inset_count,1)+trk_pos_ops);

% imshow(frm_bot)
% hold on
% plot(cntr_pt_init(1),cntr_pt_init(2),'.','MarkerSize',14,'Color',[0 .7 .7])
% plot(trk_end_pt(1),trk_end_pt(2),'.','MarkerSize',14,'Color',[.7 0 .7])
% plot(trk_pos_ops(:,1),trk_pos_ops(:,2),'.','MarkerSize',14,'Color',[.7 0 0])
% hold off
% uiwait(gcf)

init_cumsum_ops = zeros(1,inset_count);
sampl_ssd = zeros(1,inset_count);
templ_ops_cell = cell(inset_count,1);
templ_vis_cell = cell(inset_count,1);
bot_crop_ops = cell(inset_count,1);
for iterA = 1:inset_count
    neg_dim = trk_pos_ops(iterA,:)-im_leg;
    pos_dim = trk_pos_ops(iterA,:)+im_leg;
    if max([neg_dim pos_dim]) > vidWidth, continue, end
    if min([neg_dim pos_dim]) < 1, continue, end
    bot_crop = frm_bot(neg_dim(2):pos_dim(2),neg_dim(1):pos_dim(1));
    
%     bot_open = imopen(bot_crop,se_bot1);
    bot_open = bot_crop;
    
    templ_ndxr_layer = templ_ndxr_mastr(spoke_ndxr_mastr(:,layer_ref),:);
    templ_singl = bot_open(templ_ndxr_layer);
    init_cumsum_ops(iterA) = sum(templ_singl);
    templ_vis = reshape(templ_singl,spoke_length,spoke_span);
%     sampl_vals = templ_vis;
%     model_vals = [ones(ceil(spoke_length*(1/2)),spoke_span)
%         zeros(floor(spoke_length*(1/2)),spoke_span)];
%     ss_total = sum((sampl_vals(:)-mean(sampl_vals(:))).^2);
%     ss_resid = sum((sampl_vals(:)-model_vals(:)).^2);
%     sampl_ssd(iterA) = 1-ss_resid/ss_total;
%     sampl_ssd(iterA) = mean(diag(cov(templ_vis')));
    sampl_ssd(iterA) = mean(var(templ_vis,[],2));
    templ_ops_cell{iterA} = templ_singl;
    bot_crop_ops{iterA} = bot_crop;
    templ_vis_cell{iterA} = templ_vis;
end
[max_ssd,max_corr_ref] = max(sampl_ssd);
if max_ssd == 0
    if debug == 1
        disp('max_ssd not found')
    end
    return
end
fly_pos = trk_pos_ops(max_corr_ref,:);
fly_pos_init = fly_pos;
templ_singl = templ_ops_cell{max_corr_ref};
templ_vis = reshape(templ_singl,spoke_length,spoke_span);

% imshow(cell2mat(templ_vis_cell),'InitialMagnification',300)

%% %%% Video analysis
% establish tracking variables
trk_layer = layer_ref;
trk_theta = trk_layer*radians_per_spoke;
templ_avg_count = 33;
templ_array = repmat(templ_singl,[1 templ_avg_count]);
templ_mean = mean(templ_array,2);
templ_mean_init = templ_mean;
templ_trk = templ_mean(templ_rendxr);
netDeltaTestA = sum((templ_singl(:)-mean(templ_singl(:))).^2);%ss_total
netDeltaTestB = sum((templ_singl(:)-templ_mean_init(:)).^2);%ss_resid
changeTest = 1-netDeltaTestB/netDeltaTestA;%sampl_ssd

% preallocate variables, initialize slaves
topLabels = zeros(vid_count,5);
botLabels = zeros(vid_count,3);
mvmnt_ref = zeros(vid_count,1);
belly_trk = zeros(vid_count,1);
range_trk = zeros(vid_count,1);
change_trk = zeros(vid_count,1);
wings_trk = zeros(vid_count,1);

% Establish figure for frame-getting
if showMovie == 1
    scrn_size = get(0, 'ScreenSize');
    fig_position = [scrn_size(3)/10 scrn_size(4)/10 scrn_size(3)*0.6 scrn_size(4)*0.7];
    h_fig = figure('Position',fig_position);
    h_axes1 = axes('Parent',h_fig);
    colormap('gray')
end

for frm_ref = 1:vid_count
    
    frameRead = frameReferenceMesh(2,writeRefs(frm_ref));
    if frm_ref > 1
        frmLast = frameReferenceMesh(2,writeRefs(frm_ref-1));
    else
        frmLast = 0;
    end
    if frmLast == frameRead
        cont_test = 0;
    else
        
        readObjRef = frameReferenceMesh(3,writeRefs(frm_ref));
        if isnan(frameRead)
            frameW = read(vidObjA,vidObjA.NumberOfFrames);
        elseif readObjRef == 1
            frameW = read(vidObjA,frameRead);
        else
            frameW = read(vidObjB,frameRead);
        end
        frameW = frameW(:,:,1);
        %     vid_bot = frameW(vidWidth+1:end,:);
        %     vid_top = frameW(1:vidWidth,:);
        %     vid_bot = intlut(vid_bot,frm_remapB);
        %     vid_top = intlut(vid_top,frm_remapT);
        %     frameW = cat(1,vid_top,vid_bot);
        
        %%%% Process frame for analysis
        %     frm_3D = read(local_obj,frm_ref);
        frm_raw = frameW;
        frm_gray = double(frm_raw)./255;
        frm_bot = frm_gray(end-vidWidth+1:end,:);
        
        %%%% Test whether anything changed from the previous frame
        neg_dim = fly_pos-im_leg;
        pos_dim = fly_pos+im_leg;
        bounds_testA = (max([neg_dim pos_dim]) > vidWidth);
        bounds_testB = (min([neg_dim pos_dim]) < 1);
        if logical(max(bounds_testA,bounds_testB))
            break
        end
        bot_crop = frm_bot(neg_dim(2):pos_dim(2),neg_dim(1):pos_dim(1));
        
%         bot_open = imopen(bot_crop,se_bot1);
        bot_open = bot_crop;
        
        sampl_ndxr_layer = sampl_ndxr_mastr(spoke_ndxr_mastr(:,trk_layer),:);
        sampl_trk = bot_open(sampl_ndxr_layer);
        ss_total = sum((sampl_trk-repmat(mean(sampl_trk),numel(templ_vis),1)).^2);
        ss_resid = sum((sampl_trk-templ_trk).^2);
        trk_ssd = 1-ss_resid./ss_total;
        [~,max_ref] = max(trk_ssd);
        mastr_refs = mastr_findr(max_ref,:);
        cont_test = sum([mastr_refs frm_ref == 1]);
        
        rangeTestA = sum((sampl_trk(:,1)-mean(sampl_trk(:,1))).^2);%ss_total
        rangeTestB = sum((sampl_trk(:,1)-sampl_trk(:,end)).^2);%ss_resid
        rangeTest = 1-rangeTestB./rangeTestA;
    end
    
    if  cont_test ~= 0
        mvmnt_ref(frm_ref) = frm_ref;
        
        rangeTestA = sum((sampl_trk(:,1)-mean(sampl_trk(:,1))).^2);%ss_total
        rangeTestB = sum((sampl_trk(:,1)-sampl_trk(:,end)).^2);%ss_resid
        rangeTest = 1-rangeTestB./rangeTestA;
    
        netDeltaTestA = sum((templ_singl(:)-mean(templ_singl(:))).^2);%ss_total
        netDeltaTestB = sum((templ_singl(:)-templ_mean_init(:)).^2);%ss_resid
        changeTest = 1-netDeltaTestB/netDeltaTestA;%sampl_ssd
        if changeTest < -1, break, end
        
        
        %%%% Respond to detected changes
        frm_top = frm_gray(1:vidWidth,:);
        
        %%%% Analyze top frame (side view)
        level_gray_T = graythresh(frm_top)*1.3;
        BW1_top = im2bw(frm_top,level_gray_T);
%         BW_top2 = imdilate(BW1_top,se_top1);
        BW_top2 = BW1_top;
        BW_top2 = imerode(BW_top2,se_top2);
        BW_top = imdilate(BW_top2,se_top3);
        stats = regionprops(BW_top,'Centroid','MajorAxisLength','MinorAxisLength',...
            'Orientation','ConvexArea');
        pixel_count = [stats.ConvexArea]';
        if ~isempty(pixel_count)
            pixel_val = max(pixel_count);
            stat_ref = find(pixel_val == pixel_count,1,'first');
            top_centroid = stats(stat_ref).Centroid;
            maj_theta = pi/180*(stats(stat_ref).Orientation+180);
            maj_rho = stats(stat_ref).MajorAxisLength/2;
            min_rho = stats(stat_ref).MinorAxisLength/2;
        end
        
        %%%% Wings, Belly, and Position tests
        wingLine = frm_top(wingY,wingX);
        wingTestA = [wingLine(:)';wingLine(:)'.*0];
        wingTest = std(wingTestA(:));
        bellLine = frm_top(bellY,bellX);
        bellyTest = sum(bellLine)/bellInit;
        netPointDelta = (fly_pos_init-fly_pos);
        netPosDelta = sqrt(netPointDelta(2)^2+netPointDelta(1)^2);
        if bellyTest < 0.5 || netPosDelta > 30
            netTest = 1;
        elseif  wingTest > 0.05
            netTest = 0;
        else
            netTest = 1;
        end
        if netTest
            templ_singl = sampl_trk(:,max_ref);
        end
        fly_pos = fly_pos+mastr_refs(1:2);
        posTest = [(fly_pos(1)-im_leg) < roiPos(1)
            (fly_pos(2)-im_leg) < roiPos(3)
            (fly_pos(1)+im_leg) > roiPos(2)
            (fly_pos(2)+im_leg) > roiPos(4)];
        if max(posTest)
            netTest = 0;
        end
        if netTest
            trk_layer = trk_layer+mastr_refs(3);
            trk_layer(trk_layer > spoke_count) = trk_layer-spoke_count;
            trk_layer(trk_layer <= 0 ) = trk_layer+spoke_count;
            trk_theta = trk_layer*radians_per_spoke;
            
            templ_vis = reshape(templ_singl,spoke_length,spoke_span);
            templ_array = circshift(templ_array,[0 1]);
            templ_array(:,1) = templ_singl;
            templ_mean = mean(templ_array(:,end-3:end),2);
            templ_trk = templ_mean(templ_rendxr);
        end
        
        if showMovie == 1
            sampl_vis = reshape(sampl_trk(:,max_ref),spoke_length,spoke_span);
            templ_vis_mean = reshape(templ_mean,spoke_length,spoke_span);
            
            %%%%% Generate new image
            spcrA = zeros(3,im_leg*2+1);
            vis_blocks = [spcrA;bot_crop;spcrA;bot_open;spcrA];
            spcrB = zeros(3,spoke_span);
            vis_trks = [sampl_vis;spcrB;templ_vis;spcrB;templ_vis_mean;spcrB];
            max_dim = max(size(vis_blocks,2),size(vis_trks,2));
            vis_blocks(end,max_dim) = 0;
            vis_trks(end,max_dim) = 0;
%             vis_full = [vis_blocks;vis_trks];
            vis_full = vis_trks;
            BW1_top = double(BW1_top);
            BW1_top(1+5:size(vis_full,1)+5,1+5:size(vis_full,2)+5) = vis_full;
            visual_frame = [frm_top BW_top
                frm_bot BW1_top];
            image(visual_frame,'CDataMapping','scaled','Parent',h_axes1);
            axis image, box off, axis off, hold on
            
            %%%% Visualize side-view labels
            theta_list = [maj_theta;maj_theta+pi
                maj_theta+pi/2;maj_theta-pi/2];
            rho_list = [maj_rho;maj_rho;min_rho;min_rho];
            u_trk = cos(theta_list).*rho_list;
            v_trk = -sin(theta_list).*rho_list;
            top_centroid_quivr = repmat(top_centroid,4,1);
            quiver(top_centroid_quivr(:,1)+vidWidth,top_centroid_quivr(:,2),u_trk,v_trk,...
                'MaxHeadSize',0,'LineWidth',2,'AutoScaleFactor',1,'Color',[0 .5 .8]);
            plot(top_centroid(1)+vidWidth,top_centroid(2),'.','MarkerSize',18,'Color',[0 .3 .7])
            
            %%%% Visualize bottom-view labels
            u_com = cos(trk_theta)*min_rho;
            v_com = -sin(trk_theta)*min_rho;
            
            %%%% Plot data on image
            quiver(fly_pos(1),fly_pos(2)+vidWidth,u_com,v_com,'MaxHeadSize',0,'LineWidth',2,...
                'AutoScaleFactor',1,'Color',[0 .5 .8]);
            plot(fly_pos(1),fly_pos(2)+vidWidth,'.','MarkerSize',18,'Color',[.7 0 0])
            
            text(15,15,['Wing:  ' num2str(wingTest,3)],...
                'HorizontalAlignment','left','FontWeight','bold',...
                'Color',[1 1 1],'FontSize',10,'Interpreter','none')
            text(15,45,['Belly:  ' num2str(bellyTest,3)],...
                'HorizontalAlignment','left','FontWeight','bold',...
                'Color',[1 1 1],'FontSize',10,'Interpreter','none')
            text(15,75,['Pos Change:  ' num2str(netPosDelta,3)],...
                'HorizontalAlignment','left','FontWeight','bold',...
                'Color',[1 1 1],'FontSize',10,'Interpreter','none')
            text(15,105,['Tmpl Change:  ' num2str(changeTest,3)],...
                'HorizontalAlignment','left','FontWeight','bold',...
                'Color',[1 1 1],'FontSize',10,'Interpreter','none')
            text(15,135,['Frame:  ' int2str(frm_ref)],...
                'HorizontalAlignment','left','FontWeight','bold',...
                'Color',[1 1 1],'FontSize',10,'Interpreter','none')
            hold off
            drawnow
        end

    end
    
    topLabels(frm_ref,:) = [top_centroid,maj_theta,maj_rho,min_rho];
    botLabels(frm_ref,:) = [fly_pos,trk_theta];
    wings_trk(frm_ref) = wingTest;
    belly_trk(frm_ref) = bellyTest;
    range_trk(frm_ref) = rangeTest;
    change_trk(frm_ref) = changeTest;
end
if showMovie == 1
    close(h_fig)
end
%%
tracker_record.top_centroid = {topLabels(:,1:2)};
tracker_record.bot_centroid = {botLabels(:,1:2)};
tracker_record.top_maj_theta = {topLabels(:,3)};
tracker_record.top_maj_rho = {topLabels(:,4)};
tracker_record.top_min_rho = {topLabels(:,5)};
tracker_record.bot_theta = {botLabels(:,3)};
tracker_record.mvmnt_ref = {mvmnt_ref};
tracker_record.wings_trk = {wings_trk};
tracker_record.belly_trk = {belly_trk};
tracker_record.range_trk = {range_trk};
tracker_record.change_trk = {change_trk};

saveobj = tracker_record;
save(tracker_data_path,'saveobj')
