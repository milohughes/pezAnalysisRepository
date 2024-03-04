function flyAnalyzer3000_v14(videoID,locator_name,tracker_name,runMode,debug)
persistent videoStatisticsMerged automatedAnnotations assessTable oldID
%%
if isempty(mfilename) || nargin == 0
    runMode = 1;
    
    tracker_name = 'flyTracker3000_v17';
    locator_name = 'flyLocator3000_v10';
    videoID = 'run027_pez3001_20161109_expt0048000018240308_vid0007';
    videoID = 'run036_pez3004_20150427_expt0061000004300453_vid0002';
    makeSampleFrame = 1;
else
    makeSampleFrame = 0;
end
strParts = strsplit(videoID,'_');
exptID = strParts{4}(5:end);
if ~isempty(mfilename)
    if ~isempty(oldID) && ~strcmp(oldID,exptID)
        assessTable = [];
    end
    oldID = exptID;
    analyzer_name = mfilename;
else
    analyzer_name = 'flyAnalyzer3000_v14';
    assessTable = [];
end
if ~exist('debug','var')
    debug = 0;
end
%%%% Establish data destination directory
%analysisDir = fullfile('\\tier2','card','Data_pez3000_analyzed');
analysisDir = fullfile('\\DM11','cardlab','Data_pez3000_analyzed');
expt_results_dir = fullfile(analysisDir,exptID);
analyzer_summary_dir = [expt_results_dir filesep exptID '_' analyzer_name '_visualMontage'];
if isdir(analyzer_summary_dir) == 0, mkdir(analyzer_summary_dir),end
analyzer_expt_ID = [videoID '_' analyzer_name '_data.mat'];%experiment ID
analyzer_data_dir = fullfile(expt_results_dir,[exptID '_' analyzer_name]);
if isdir(analyzer_data_dir) == 0, mkdir(analyzer_data_dir),end
analyzer_data_path = fullfile(analyzer_data_dir,analyzer_expt_ID);
analyzed_vis_path = fullfile(analyzer_summary_dir,[videoID '_' analyzer_name '_visualization.tif']);
if runMode > 2
    if exist(analyzer_data_path,'file')
        analysis_data_import = load(analyzer_data_path);
        dataname = fieldnames(analysis_data_import);
        analysis_data_import = analysis_data_import.(dataname{1});
        if strcmp(analysis_data_import.final_outcome{1},'analyzed')
            if debug, disp('previously analyzed'); end
            return
        end
    end
end

if isempty(assessTable)
    %%%%% Load assessment table
    assessmentPath = fullfile(expt_results_dir,[exptID '_rawDataAssessment.mat']);
    assessTable_import = load(assessmentPath);
    dataname = fieldnames(assessTable_import);
    assessTable = assessTable_import.(dataname{1});
    
    
    autoAnnoName = [exptID '_automatedAnnotations.mat'];
    autoAnnotationsPath = fullfile(expt_results_dir,autoAnnoName);
    if exist(autoAnnotationsPath,'file') == 2
        autoAnnoTable_import = load(autoAnnotationsPath);
        dataname = fieldnames(autoAnnoTable_import);
        automatedAnnotations = autoAnnoTable_import.(dataname{1});
    else
        if debug, disp('no auto annotations'); end
        return
    end
    
    vidInfoMergedName = [exptID '_videoStatisticsMerged.mat'];
    vidInfoMergedPath = fullfile(expt_results_dir,vidInfoMergedName);
    vidInfo_import = load(vidInfoMergedPath);
    dataname = fieldnames(vidInfo_import);
    videoStatisticsMerged = vidInfo_import.(dataname{1});
end
vidStats = videoStatisticsMerged(videoID,:);
if automatedAnnotations.jumpTest{videoID}
    raw_fot = automatedAnnotations.autoFrameOfTakeoff{videoID};
else
    raw_fot = NaN;
end

% runID = [strParts{1} '_' strParts{2} '_' strParts{3}];
% exptInfoMergedName = [exptID '_experimentInfoMerged.mat'];
% exptInfoMergedPath = fullfile(expt_results_dir,exptInfoMergedName);
% experimentInfoMerged = load(exptInfoMergedPath,'experimentInfoMerged');
% exptInfo = experimentInfoMerged.experimentInfoMerged;
% exptInfo = exptInfo(runID,:);

vidPath = assessTable.Video_Path{videoID};
roiPos = assessTable.Adjusted_ROI{videoID};
vidWidth = double(vidStats.frame_width);
vidHeight = double(vidStats.frame_height);
[roiPos,prismW] = roi2crop(roiPos,vidWidth,vidHeight);
pix2mm = @(x) x.*(5/prismW);%prism is 5mm and ~250 pixels wide
frm2secSqared = @(x) (x.*(double(vidStats.record_rate)/1000).^2)*1000;
deg2rad = @(x) x.*(pi/180);
% rad2deg = @(x) x.*(180/pi);

if isfield(vidStats.visual_stimulus_info{videoID},'azimuth')
    stim_azi = vidStats.visual_stimulus_info{videoID}.azimuth;
    stim_azi = deg2rad(stim_azi);
    stim_ele = vidStats.visual_stimulus_info{videoID}.elevation;
    stim_ele = deg2rad(stim_ele);
else
    stim_azi = deg2rad(vidStats.fly_detect_azimuth);
    stim_ele = 0;
end
frameRefcutrate = vidStats.cutrate10th_frame_reference{videoID};
% nFrames = double(vidStats.frame_count(videoID));
%%
%%%% Analyzer table
ana_varnames = {'XYZ_3D_filt','departure_az_ele_rad','final_frame_tracked',...
    'stimulus_azimuth','stimulus_elevation','departure_shape',...
    'shape_confidence','top_points_and_thetas','bot_points_and_thetas',...
    'wings','ten_sample_points','fly_length','final_outcome'};
analysis_record = cell2table(cell(1,numel(ana_varnames)),'VariableNames',...
    ana_varnames,'RowNames',{videoID});

locDir = fullfile(expt_results_dir,[exptID '_' locator_name]);
locator_data_path = fullfile(locDir,[videoID '_' locator_name '_data.mat']);
tracker_expt_ID = [videoID '_' tracker_name '_data.mat'];%experiment ID
tracker_data_dir = fullfile(expt_results_dir,[exptID '_' tracker_name]);
tracker_data_path = fullfile(tracker_data_dir,tracker_expt_ID);
% analysis_record.tracker_data_path = {tracker_data_path};
% analysis_record.analyzed_vis_path = {analyzed_vis_path};

recurMax = 2;
badAnal = false;
for iterF = 1:recurMax
    if iterF == 1
        %%%%% Load locator data
        if exist(locator_data_path,'file') == 2
            locator_record = load(locator_data_path);
            dataname = fieldnames(locator_record);
            locator_record = locator_record.(dataname{1});
        else
            analysis_record.final_outcome = {'no locator file'};
            badAnal = true;
            break
        end
        porf_test = locator_record.pass_or_fail{:};
        if porf_test ~= 1
            analysis_record.final_outcome = {'locator could not find fly'};
            badAnal = true;
            break
        end
        
        %%%%% If passed locator test, load tracking data
        if exist(tracker_data_path,'file') == 2
            tracker_data_import = load(tracker_data_path);
            dataname = fieldnames(tracker_data_import);
            tracker_record = tracker_data_import.(dataname{1});
        else
            analysis_record.final_outcome = {'no tracking file'};
            badAnal = true;
            break
        end
    end
    loc_flyLength = locator_record.fly_length{:};
    loc_flyTheta = locator_record.fly_theta{:};
    loc_flyCOM = locator_record.center_point{:};
    
    topCOM = tracker_record.top_centroid{1};
    botTrkPt = tracker_record.bot_centroid{1};
    topTheta = tracker_record.top_maj_theta{1};
    topMajRho = tracker_record.top_maj_rho{1};
    topMinRho = tracker_record.top_min_rho{1};
    botTheta = tracker_record.bot_theta{1};
    mvnt_frms = tracker_record.mvmnt_ref{1};
    wings_trk = tracker_record.wings_trk{1};
    range_trk = tracker_record.range_trk{1};
    if iterF == 1
        %     trkEnd = max(mvnt_frms)-1;
        trkEnd = find(range_trk ~= 0,1,'last')-1;
    end
    trkMin = 20;
    if trkEnd < trkMin
        analysis_record.final_outcome = {'tracking too short'};
        badAnal = true;
        break
    end
    
    
    %%
    %%%%% Define tracking variables
    trk_hort_ref = locator_record.tracking_hort{:};
    fly_length = locator_record.fly_length{:};
    
    %TEMPL_*** is identical, centered replicates!!! (taken from older, centered frame)
    %SAMPL_*** contains posible new positions and has unknown center!!! (taken from new frame)
    src_fac = 0.3;
    src_leg = round(fly_length*(src_fac));
    [ndxr_struct] = trackingIndexer_spoked4crop(src_leg,trk_hort_ref);
    im_leg = ndxr_struct.im_leg;
    posTest = [botTrkPt(:,1)-im_leg < roiPos(1),...
        botTrkPt(:,2)-im_leg < roiPos(3),...
        botTrkPt(:,1)+im_leg > roiPos(2),...
        botTrkPt(:,2)+im_leg > roiPos(4)];
    posTestVec = max(posTest,[],2);
    posTestVec = posTestVec(1:trkEnd);
    
    %%%%% Bottom, underside view smoothing.  Uses frames where movement was
    %%%%% detected and then interpolates.  Best for the types of tracking
    %%%%% errors I have observed
    mvntMin = 5;
    mvnt_frms = mvnt_frms(1:trkEnd);
    mvnt_frms(trkEnd) = trkEnd;
    moveTest = mvnt_frms > 0;
    mvnt_frms(~moveTest) = [];
%     if sum(moveTest) > mvntMin
        interpX = (1:trkEnd)';
        interpFunB = @(x) interp1(mvnt_frms,x(mvnt_frms),...
            interpX,'linear','extrap');
        botTheta(mvnt_frms) = unwrap(botTheta(mvnt_frms));
%     else
%         interpFunB = @(x) x;
%     end
    
    
    if max(posTestVec)
        %     if posTestVec(end)
        missRefs = find(posTestVec);
%         if isempty(missRefs)
%             lastRef = 1;
%         end
        
        missRefs = unique(cat(1,missRefs(:),mvnt_frms(:)));
%         botTheta(missRefs) = NaN;
%         botThetaArray = cat(2,circshift(botTheta,[1 0]),circshift(botTheta,[-1 0]),botTheta);
%         botThetaArray(isnan(botThetaArray)) = 0;
%         botTheta(isnan(botTheta)) = max(botTheta,[],2);
        interpX = (1:trkEnd)';
        interpFunC = @(x) interp1(missRefs,x(missRefs),...
            interpX,'linear','extrap');
        botTheta_filt = interpFunC(botTheta(1:trkEnd));
    else
        botTheta_filt = interpFunB(botTheta(1:trkEnd));
    end
    
    
    bot_xFilt = interpFunB(botTrkPt(1:trkEnd,1));
    bot_yFilt = interpFunB(botTrkPt(1:trkEnd,2));
    top_xFilt = interpFunB(topCOM(1:trkEnd,1));
    top_yFilt = interpFunB(topCOM(1:trkEnd,2));
    topTheta_filt = interpFunB(topTheta(1:trkEnd));
    topMajRho_filt = interpFunB(topMajRho(1:trkEnd));
    topMinRho_filt = interpFunB(topMinRho(1:trkEnd));
    wings_filt = interpFunB(wings_trk(1:trkEnd));
    
    top_centroid_filt = [top_xFilt top_yFilt];
    topDist = sqrt(sum(top_centroid_filt.^2,2));
    topDist = cat(1,0,0,diff(diff(topDist)));
    topDist = frm2secSqared(pix2mm(topDist));
%     plot(topDist,'.')
    
%     plot(interpX,top_yFilt(interpX),'.','markersize',14)
%     hold all
%     plot(mvnt_frms,topCOM(mvnt_frms,2),'.','markersize',10)
%     plot(mvnt_frms,testFilt,'.')
    % plot(bot_yFilt,'.')
    
    %%%%% Removing the parts of the top, side view where the minor axis is
    %%%%% more than 1.3 times its median size.  This tends to correlate with errors
    %%%%% associated with wing reflections during flight
    topTest = topMinRho_filt;
    topTest(topTest == 0) = NaN;
    median_rho = nanmedian(topTest);
    topTest = topTest./median_rho;
    topThresh = 1.3;
    badLogical = abs(topDist) > 300;
    badTopNdcs = find(badLogical)-1;
    
    goodLogical = topTest < topThresh;
    goodTopNdcs = find(goodLogical);
    goodTopNdcs(ismember(goodTopNdcs,badTopNdcs)) = [];
    
%     if sum(moveTest) > mvntMin
        interpFunT = @(x) interp1(goodTopNdcs,x,interpX,'linear','extrap');
        top_xFilt = interpFunT(top_xFilt(goodTopNdcs));
        top_yFilt = interpFunT(top_yFilt(goodTopNdcs));
        topTheta_filt = unwrap(interpFunT(topTheta_filt(goodTopNdcs)));
        topMajRho_filt = interpFunT(topMajRho_filt(goodTopNdcs));
        topMinRho_filt = interpFunT(topMinRho_filt(goodTopNdcs));
%     end
    top_centroid_filt = [top_xFilt top_yFilt];
    %     topDist = sqrt(sum(top_centroid_filt.^2,2));
    %     topDist = cat(1,0,0,diff(diff(topDist)));
    %     topDist = frm2secSqared(pix2mm(topDist));
    
%     plot(topDist,'.')

%     plot(interpX,top_yFilt(interpX),'.','markersize',16)
%     hold all
%     plot(interpX,top_xFilt(interpX),'.','markersize',14)
%     plot(mvnt_frms,topCOM(mvnt_frms,2),'.','markersize',12)
%     plot(mvnt_frms,topCOM(mvnt_frms,1),'.','markersize',10)

    bot_centroid_filt = [bot_xFilt(:),bot_yFilt(:)];
%     plot(interpX,bot_xFilt(interpX),'.','markersize',16)
%     hold all
%     plot(interpX,bot_yFilt(interpX),'.','markersize',14)
    botDist = sqrt(sum(bot_centroid_filt.^2,2));
    botDist = cat(1,0,0,diff(diff(botDist)));
    botDist = frm2secSqared(pix2mm(botDist));
%     plot(botDist,'.','markersize',14)
%     hold all
    badLogical = abs(botDist) > 300;
    badBotNdcs = find(badLogical)-1;
%     badBotNdcs = cat(1,badBotNdcs(:)+1,badBotNdcs(:)-1,badBotNdcs(:));
    badBotNdcs = unique(badBotNdcs);
    badBotNdcs(badBotNdcs < 1) = [];
    
    
    if sum(moveTest) > mvntMin
        badBotNdcs(badBotNdcs > max(interpX)) = [];
        goodBotNdcs = interpX(~ismember(interpX,badBotNdcs));
        interpFunT = @(x) interp1(goodBotNdcs,x,interpX,'linear','extrap');
        bot_xFilt = interpFunT(bot_xFilt(goodBotNdcs));
        bot_yFilt = interpFunT(bot_yFilt(goodBotNdcs));
    end
%     plot(interpX,bot_xFilt(interpX),'.','markersize',12)
%     plot(interpX,bot_yFilt(interpX),'.','markersize',10)
    
%     bot_centroid_filt = [bot_xFilt(:),bot_yFilt(:)];
%     botDist = sqrt(sum(bot_centroid_filt.^2,2));
%     botDist = cat(1,0,0,diff(diff(botDist)));
%     botDist = frm2secSqared(pix2mm(botDist));
%     plot(botDist,'.','markersize',10)
    %% %% Re-establish bottom-view centroid
    point_zero = loc_flyCOM-botTrkPt(1,:);
    [trk_theta_init,trk_rho] = cart2pol(point_zero(1),-point_zero(2));
    trk_theta_delta = trk_theta_init-loc_flyTheta;
    max_ratio = abs((loc_flyLength/2)-median_rho);
    actual_ratio = abs(topMajRho_filt-topMinRho_filt).*abs(sin(topTheta_filt));
    length_factor = actual_ratio./(max_ratio);
    pitch_factor = 1-(sin((-pi/2).*(1-length_factor))+1);
    trk_COM_adjust_rho = trk_rho.*pitch_factor;
    trk_COM_adjust_theta = botTheta_filt+trk_theta_delta;
    [com_x_adj,com_y_adj] = pol2cart(trk_COM_adjust_theta(:),trk_COM_adjust_rho(:));
    % fly_segment = (loc_flyLength/2-topMinRho_filt).*pitch_factor;
    % bot_rho = median_rho+fly_segment;
    bot_centroid_filt = [bot_xFilt(:),bot_yFilt(:)]+([com_x_adj,-com_y_adj]);
    
%     plot(interpX,bot_centroid_filt(interpX,2),'.','markersize',16)
%     hold all
%     plot(interpX,topCOM(interpX,1),'.','markersize',14)
%     plot(interpX,botTrkPt(interpX,1),'.','markersize',12)
%     plot(interpX,top_yFilt(interpX),'.','markersize',8)

%%
%%%% Formulate position changes in 3D, zeroed at frame_0001
XYZ_3D_filt = [bot_centroid_filt(:,1) bot_centroid_filt(:,2),...
    top_centroid_filt(:,2)];
zero_posXYZ_filt = [zeros(1,3);abs(diff(XYZ_3D_filt))];%zero all spacial coordinates
zero_posXYZ_filt = cumsum(zero_posXYZ_filt);%recreate the vector
zero_pos_filt = sqrt(sum(zero_posXYZ_filt.^2,2));%reduces dimensionality to one
smooth_dist_filt = (zero_pos_filt(1:trkEnd));%50

%%%%% determine frames used in visualization and deptarture trajectory
vis_count = 10;
if smooth_dist_filt(end) > 10%test if the fly moved more than 10 pixels
    pos_marks = linspace(0,smooth_dist_filt(end),vis_count);
    %     pos_mark_adj = cos(linspace(-pi/2,pi/2,8))*0.1+1;
    pos_mark_adj = 1;
    pos_mark_array = repmat(pos_marks.*pos_mark_adj,trkEnd,1);
    delta_net_array = repmat(smooth_dist_filt,1,vis_count);
    [~,vis_refs] = min(abs(delta_net_array-pos_mark_array));
    if vis_refs(end-1) > (vis_refs(end)*0.9) && range(vis_refs) > 10 && iterF < recurMax
        trkEnd = vis_refs(end-1);
    else
        break
    end
else
    vis_refs = round(linspace(1,trkEnd,vis_count));
end
end

if ~badAnal
    %%% determine departure trajectory
    trk_raw_xyz = XYZ_3D_filt(vis_refs,:)-repmat(XYZ_3D_filt(1,:),vis_count,1);
    XYZ_poly_zero = zeros(vis_count,3);
    dept_shape = NaN;
    shape_confidence = NaN;
    for iterZ = 1:2
        x_raw = trk_raw_xyz(:,1);
        y_raw = -trk_raw_xyz(:,1+iterZ);
        fitTest = [sum(abs(diff(x_raw)) > 0.0001),sum(abs(diff(y_raw)) > 0.0001)];
        if max(fitTest) < 2 %tests for min num distinct points to fit a line
            continue
        end
        p_line = polyfit(x_raw,y_raw,1);
        x_line = x_raw;
        y_line = polyval([p_line(1) 0],x_line);
        x_theta_adj = atan2(x_line(end),y_line(end));
        [thetas_raw,rhos_raw] = cart2pol(x_raw,y_raw);
        [x_rot,y_rot] = pol2cart(thetas_raw-x_theta_adj,rhos_raw);
        fitTest = [sum(abs(diff(x_rot)) > 0.0001),sum(abs(diff(y_rot)) > 0.0001)];
        if max(fitTest) < 3 %tests for min number points to fit 2nd-degree curve
            continue
        end
        [p_fit,S_fit] = polyfit(x_rot,y_rot,2);
        x_fit = linspace(0,x_rot(end),vis_count)';
        y_fit = polyval([p_fit(1:2) 0],x_fit);
        [thetas_fit,rhos_fit] = cart2pol(x_fit,y_fit);
        [x_poly,y_poly] = pol2cart(thetas_fit+x_theta_adj,rhos_fit);
        if iterZ == 1
            XYZ_poly_zero(:,1:2) = [x_poly y_poly];
            dept_shape = p_fit;
            shape_confidence = S_fit;
        else
            XYZ_poly_zero(:,3) = y_poly;
        end
    end
    deptLength = round(vis_count/2);% determines number of points to use for determining departure trajectory
    xyz_deprt = XYZ_poly_zero(end-deptLength:end,:)-XYZ_poly_zero(end-deptLength);
    xyz_mean = mean(diff(xyz_deprt));
    [az_deprt,ele_deprt,r_deprt] = cart2sph(xyz_mean(:,1),xyz_mean(:,2),xyz_mean(:,3));
    r_deprt = r_deprt*deptLength;
    
    
    analysis_record.XYZ_3D_filt = {XYZ_3D_filt};
    analysis_record.departure_az_ele_rad = {[az_deprt,ele_deprt,r_deprt]};
    analysis_record.final_frame_tracked = {trkEnd};
    analysis_record.stimulus_azimuth = {stim_azi};
    analysis_record.stimulus_elevation = {stim_ele};
    analysis_record.departure_shape = {dept_shape};
    analysis_record.shape_confidence = {shape_confidence};
    analysis_record.top_points_and_thetas = {[top_centroid_filt,topTheta_filt,topMajRho_filt,topMinRho_filt]};
    analysis_record.bot_points_and_thetas = {[bot_centroid_filt,botTheta_filt]};
    analysis_record.wings = {wings_filt};
    analysis_record.ten_sample_points = {vis_refs};
    analysis_record.fly_length = {loc_flyLength};
    analysis_record.final_outcome = {'analyzed'};
end
saveobj = analysis_record;
save(analyzer_data_path,'saveobj')

if makeSampleFrame && ~badAnal
    %%%%% Generate the visual sample frame
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
    if contains(vidPath,'tier2')
        vidPath = regexprep(vidPath,'card\','cardlab\');
        vidPath = regexprep(vidPath,'tier2\','dm11\');
    end
    slashPos = strfind(vidPath,'\');
    vidDir = vidPath(1:slashPos(end)-1);
    vidpathH = fullfile(vidDir,'highSpeedSupplement',[videoID '_supplement.mp4']);
    
    vidObjA = VideoReader(vidPath);
    if exist(vidpathH,'file')
        vidObjB = VideoReader(vidpathH);
    else
        vidObjB = vidObjA;
    end
    vidWidth = vidObjA.Width;
    vidHeight = vidObjA.Height;
    hH = vidHeight/2;
    tol = [0 0.999];
    video_init = read(vidObjA,[1 10]);
    frame_01_gray = uint8(mean(squeeze(video_init(:,:,1,:)),3));
    frm_half_gray = frame_01_gray(hH+1:end,:);
    [~,frm_graymap] = gray2ind(frm_half_gray,256);
    lowhigh_in = stretchlim(frm_half_gray,tol);
    lowhigh_in(1) = lowhigh_in(1)*0.1;
    frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],0.8);
    frm_remapB = uint8(frm_remap(:,1).*255);
    frm_half_gray = frame_01_gray(1:hH,:);
    [~,frm_graymap] = gray2ind(frm_half_gray,256);
    lowhigh_in = stretchlim(frm_half_gray,tol);
    lowhigh_in(1) = lowhigh_in(1)*0.1;
    frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],0.8);
    frm_remapT = uint8(frm_remap(:,1).*255);
    writeRefs = xi;
    frameFull = cell(1,vis_count+1);
    finc = hsv(round(vis_count*1.5));
    finc = finc(1:vis_count,:);
    finc = flipud(finc);
    if ~isnan(raw_fot)
        frm_refs = [vis_refs(:);raw_fot];
        finc = [finc;ones(1,3)];
    else
        frm_refs = [vis_refs(:);1];
        finc = [finc;zeros(1,3)];
    end
    for iterC = 1:vis_count+1
        frameRead = frameReferenceMesh(2,writeRefs(frm_refs(iterC)));
        readObjRef = frameReferenceMesh(3,writeRefs(frm_refs(iterC)));
        if readObjRef == 1
            frmRead = read(vidObjA,frameRead);
        else
            frmRead = read(vidObjB,frameRead);
        end
        frmRead = frmRead(:,:,1);
        vid_bot = frmRead(hH+1:end,:);
        vid_top = frmRead(1:hH,:);
        vid_bot = intlut(vid_bot,frm_remapB);
        vid_top = intlut(vid_top,frm_remapT);
        frameFull{iterC} = double([vid_top;vid_bot])./255;
    end
    %% color enhancement variables %
    level_gray = graythresh(frameFull{iterC})*1.3;
    BW1 = im2bw(frameFull{iterC},level_gray);
    BW2 = imdilate(BW1,strel('disk',3));
    BW2(BW1) = 0;
    BW2 = imfilter(double(BW2),fspecial('disk',3));
    frm_merge = zeros(vidHeight,vidWidth,3,vis_count+1);
    for iterC = 1:vis_count+1
        frm_merge(:,:,:,iterC) = cat(3,frameFull{iterC}*finc(iterC,1),...
            frameFull{iterC}*finc(iterC,2),frameFull{iterC}*finc(iterC,3));
    end
    BW3 = repmat(imadjust(abs(BW2-1),[0 1],[0 1]),[1 1 3]);
    frm_demo = max(frm_merge,[],4);
    if ~isnan(raw_fot)
        frm_demo = uint8((frm_demo.*BW3)*255);
    else
        frm_demo = uint8((frm_demo)*255);
    end
    visIm = frm_demo;
    imshow(visIm)
    imwrite(visIm,analyzed_vis_path,'tif')
end







