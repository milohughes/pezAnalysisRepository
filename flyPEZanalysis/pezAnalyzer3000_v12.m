function flyAnalyzer3000_v12(videoID,locator_name,tracker_name,runMode)

if isempty(mfilename) || nargin == 0
    runMode = 2;
    analyzer_name = 'flyAnalyzer3000_v12';
    tracker_name = 'flyTracker3000_v17';
    locator_name = 'flyLocator3000_v10';
    videoID = 'run007_pez3003_20140429_expt0019000000410102_vid0003';
end
if ~isempty(mfilename)
    tracker_name = mfilename;
end
strParts = strsplit(videoID,'_');
analysisDir = fullfile('\\dm11','cardlab','Data_pez3000_analyzed');
runnameKeep = [strParts{1} '_' strParts{2} '_' strParts{3}];
exptID = strParts{4}(5:end);
expt_results_dir = fullfile(analysisDir,exptID);
locDir = fullfile(expt_results_dir,[exptID '_' locator_name]);
locator_data_path = fullfile(locDir,[videoID '_' locator_name '_data.mat']);
if exist(locator_data_path,'file')
    locator_record = load(locator_data_path);
    dataname = fieldnames(locator_record);
    locator_record = locator_record.(dataname{1});
else
    return
end
porf_test = locator_record.pass_or_fail{:};
if porf_test ~= 1, return, end

%     %%%% Establish general data destination directory
%     expt_results_dir = fullfile(analysisDir,exptID);
%     analyzer_summary_dir = [expt_results_dir filesep exptID '_' analyzer_name '_visualMontage'];
%     if isdir(analyzer_summary_dir) == 0, mkdir(analyzer_summary_dir),end
%     analyzer_expt_ID = [videoID '_' analyzer_name '_data.mat'];%experiment ID
%     analyzer_data_dir = fullfile(expt_results_dir,[exptID '_' analyzer_name]);
%     if isdir(analyzer_data_dir) == 0, mkdir(analyzer_data_dir),end
%     analyzer_data_path = fullfile(analyzer_data_dir,analyzer_expt_ID);

%             analysis_record = pezAnalyzer3000_v12(locator_record,tracker_record,videoID,runDir,runPath,analyzer_data_path);
%             analysis_record.tracker_data_path = {tracker_data_path};
%             analyzed_vis_path = fullfile(analyzer_summary_dir,[videoID '_' analyzer_name '_visualization.jpg']);
%             analysis_record.analyzed_vis_path = {analyzed_vis_path};
%             analysis_record.exptID = {exptID};
%             parSave(analyzer_data_path,analysis_record,'data')
%         if ~isempty(analysis_record.XYZ_3D_filt{1})
%             visIm = analyzerVisualizationFun(analysis_record,locator_record,tracker_record);
%         end
%         parSave(visIm,analyzed_vis_path,'image');

%%%% Analyzer variables
ana_varnames = {'XYZ_3D_filt','net_dist_filt','speed','acceleration','departure_az_ele_rad',...
    'final_frame_tracked','stimulus_azimuth','stimulus_elevation','departure_shape',...
    'shape_confidence','deprt_dist','deprt_speed','deprt_accel','XYZ_separate_velocity',...
    'XYZ_separate_acceleration','top_points_and_thetas','bot_points_and_thetas',...
    'ten_sample_points','fly_length','final_outcome'};


% scrn_size = get(0,'ScreenSize');
pix2mm = @(x) x.*(5/250);%prism is 5mm and ~250 pixels wide
frm2sec = @(x) x.*6000;%eventually, get framerate from .cih file
keep_previous_ana = true;
runAnaTest = true;
analysis_data = dataset([{cell(1,numel(ana_varnames))},ana_varnames],'ObsNames',videoID);
if exist(analysis_data_path,'file') == 2
    analysis_data_import = load(analysis_data_path);
    dataname = fieldnames(analysis_data_import);
    analysis_data_import = analysis_data_import.(dataname{1});
    if ~isempty(analysis_data_import.XYZ_3D_filt{1})
        if keep_previous_ana
            analysis_data = analysis_data_import;
            runAnaTest = false;
        end
    end
end
analysis_record = analysis_data(videoID,:);
if runAnaTest
    completeAnaTest = true;
    
%     analyzed_vis_name = fullfile(analyzer_results_dir,[exptID '_' videoID '.jpg']);

    vidstatname = [runDir '_videoStatistics.mat'];
    vidstatPath = fullfile(runPath,vidstatname);
    vidstatPath = regexprep(vidstatPath,'arch','tier2');
    vidStatsLoad = load(vidstatPath);
    vidStats = vidStatsLoad.vidStats;
    
    if max(strcmp(fieldnames(vidStats.visual_stimulus_info{videoID}),'parameters'))
        stim_azi = vidStats.visual_stimulus_info{videoID}.parameters.azimuth;
        stim_azi = stim_azi*(pi/180);
    else
        stim_azi = NaN;
    end
    frameRefcutrate = vidStats.cutrate10th_frame_reference{videoID};
    
    nFrames = numel(frameRefcutrate)*10;
    smoothing_window = 31;
    smoother = @(x) smooth(x,(smoothing_window/nFrames),'loess');
    
    loc_flyLength = locator_record.fly_length{:};
    loc_flyTheta = locator_record.fly_theta{:};
    loc_flyCOM = locator_record.center_point{:};
    
    trkA = 'top_centroid';
    trkB = 'bot_centroid';
    trkC = 'top_maj_theta';
    trkD = 'top_maj_rho';
    trkE = 'top_min_rho';
    trkF = 'bot_theta';
    trkH = 'mvmnt_ref';
    trkI = 'wings_trk';
    trkJ = 'belly_trk';
    trkL = 'range_trk';
    trkM = 'change_trk';
    trk_varnames = {trkA,trkB,trkC,trkD,trkE,trkF,trkH,trkI,trkJ,trkL,trkM};
    trk_topCOM = tracker_record.(trk_varnames{1}){:};
    trk_botTrkPt = tracker_record.(trk_varnames{2}){:};
    trk_topTheta = tracker_record.(trk_varnames{3}){:};
    trk_topMajRho = tracker_record.(trk_varnames{4}){:};
    trk_topMinRho = tracker_record.(trk_varnames{5}){:};
    trk_botTheta = tracker_record.(trk_varnames{6}){:};
    mvnt_frms = tracker_record.(trk_varnames{7}){:};
    wings_trk = tracker_record.(trk_varnames{8}){:};
    belly_trk = tracker_record.(trk_varnames{9}){:};
    range_trk = tracker_record.(trk_varnames{10}){:};
    change_trk = tracker_record.(trk_varnames{11}){:};
    
    rawTrkEnd = max(mvnt_frms);
    if rawTrkEnd == 1
        completeAnaTest = false;
        analysis_record.(ana24) = {'no movement detected'};
    end
    
    [topXa,topYa] = pol2cart(trk_topTheta(:),trk_topMajRho(:));
    [topXb,topYb] = pol2cart(trk_topTheta(:)+pi/2,trk_topMinRho(:));
    topU = [topXa,topXa.*(-1),topXb,topXb.*(-1)];
    topV = -[topYa,topYa.*(-1),topYb,topYb.*(-1)];
    topTestOOBarray = [repmat(trk_topCOM(:,1),1,4)+topU,...
        repmat(trk_topCOM(:,2),1,4)+topV];
    topTestOOBvec = min(topTestOOBarray,[],2);
    topOOBref = find(topTestOOBvec < 1,1,'first')-1;
    if topOOBref == 0
        completeAnaTest = false;
        analysis_record.(ana24) = {'fly out of bounds at frame one'};
    end
else
    completeAnaTest = false;
end
if completeAnaTest
    if isempty(topOOBref), topOOBref = nFrames; end
    topTrkEnd = min(rawTrkEnd,topOOBref);
    min_rho = median(trk_topMinRho(1:topTrkEnd));
    topTest = trk_topMinRho(1:topTrkEnd)./min_rho;
    topThresh = 1.3;
    goodTopNdcs = find(topTest < topThresh);
    topTrkEnd = min(max(goodTopNdcs),topTrkEnd);
    goodTopNdcs(topTrkEnd:end) = [];
    
    interpX = [(1:topTrkEnd)';NaN(nFrames-topTrkEnd,1)];
    interpStr = 'linear';
    trk_topCOM(:,1) = interp1(goodTopNdcs,trk_topCOM(goodTopNdcs,1),interpX,interpStr);
    trk_topCOM(:,2) = interp1(goodTopNdcs,trk_topCOM(goodTopNdcs,2),interpX,interpStr);
    trk_topTheta = interp1(goodTopNdcs,trk_topTheta(goodTopNdcs),interpX,interpStr);
    trk_topMajRho = interp1(goodTopNdcs,trk_topMajRho(goodTopNdcs),interpX,interpStr);
    trk_topMinRho = interp1(goodTopNdcs,trk_topMinRho(goodTopNdcs),interpX,interpStr);
    
    trk_end = find(change_trk < (-1),1,'first')-1;
    if isempty(trk_end)
        trk_end = topTrkEnd;
    else
        trk_end = min(trk_end,topTrkEnd);
    end
    trk_topCOM(trk_end+1:end,:) = [];
    trk_botTrkPt(trk_end+1:end,:) = [];
    
    trk_botTheta_filt = smoother(unwrap(trk_botTheta(1:trk_end)));
    %         trk_botTheta_filt(trk_end+1:nFrames) = NaN;
    trk_topTheta_filt = smoother(unwrap(trk_topTheta(1:trk_end)));
    %         trk_topTheta_filt(trk_end+1:nFrames) = NaN;
    trk_topMajRho_filt = smoother(trk_topMajRho(1:trk_end));
    %         trk_topMajRho_filt(trk_end+1:nFrames) = NaN;
    trk_topMinRho_filt = smoother(trk_topMinRho(1:trk_end));
    %         trk_topMinRho_filt(trk_end+1:nFrames) = NaN;
    top_xFilt = smoother(trk_topCOM(1:trk_end,1));
    top_yFilt = smoother(trk_topCOM(1:trk_end,2));
    trk_topCOM_filt = [top_xFilt(:) top_yFilt(:)];
    %         trk_topCOM_filt(trk_end+1:nFrames,:) = NaN;
    bot_xFilt = smoother(trk_botTrkPt(1:trk_end,1));
    bot_yFilt = smoother(trk_botTrkPt(1:trk_end,2));
    trk_botTrkPt_filt = [bot_xFilt(:) bot_yFilt(:)];
    %         trk_botTrkPt_filt(trk_end+1:nFrames,:) = NaN;
    
    %%%% Re-establish bottom-view centroid
    point_zero = loc_flyCOM-trk_botTrkPt(1,:);
    [trk_theta_init,trk_rho] = cart2pol(point_zero(1),-point_zero(2));
    trk_theta_delta = trk_theta_init-loc_flyTheta;
    
    max_ratio = abs((loc_flyLength/2)-min_rho);
    actual_ratio = abs(trk_topMajRho_filt-trk_topMinRho_filt).*abs(sin(trk_topTheta_filt));
    length_factor = actual_ratio./(max_ratio);
    pitch_factor = 1-(sin((-pi/2).*(1-length_factor))+1);
    trk_COM_adjust_rho = trk_rho.*pitch_factor;
    trk_COM_adjust_theta = trk_botTheta_filt+trk_theta_delta;
    [com_x_adj,com_y_adj] = pol2cart(trk_COM_adjust_theta(:),trk_COM_adjust_rho(:));
    fly_segment = (loc_flyLength/2-trk_topMinRho_filt).*pitch_factor;
    bot_rho = min_rho+fly_segment;
    trk_botCOM_fromfilt = trk_botTrkPt_filt+([com_x_adj,-com_y_adj]);
    
    %%%% Formulate position changes in 3D, zeroed at frame_0001
    XYZ_3D_raw = [trk_botCOM_fromfilt(:,1) trk_botCOM_fromfilt(:,2),...
        trk_topCOM(:,2)];
    zero_posXYZ = [zeros(1,3);(diff(XYZ_3D_raw))];%zero all spacial coordinates
    zero_pos_vec = sqrt(sum(zero_posXYZ.^2,2));%reduces dimensionality to one
    
    top_centroid_filt = [top_xFilt(1:trk_end) top_yFilt(1:trk_end)];
    bot_centroid_filt = trk_botCOM_fromfilt(1:trk_end,:);
    XYZ_3D_filt = [bot_centroid_filt(:,1) bot_centroid_filt(:,2),...
        top_centroid_filt(:,2)];
    zero_posXYZ_filt = [zeros(1,3);abs(diff(XYZ_3D_filt))];%zero all spacial coordinates
    zero_pos_filt = sqrt(sum(zero_posXYZ_filt.^2,2));%reduces dimensionality to one
    zero_netXYZ = XYZ_3D_filt-repmat(XYZ_3D_filt(1,:),size(XYZ_3D_filt,1),1);
    net_dist_vec = sqrt(sum(zero_netXYZ.^2,2));
    net_dist_filt = smooth(net_dist_vec(1:trk_end),50);
    
    
    %%% Use diff and smooth to get speed and acceleration
    diffWin = 11;
    [Xzero,Xfirst,Xsecond] = golayDifferentiate(zero_netXYZ(:,1),diffWin);
    [Yzero,Yfirst,Ysecond] = golayDifferentiate(zero_netXYZ(:,2),diffWin);
    [Zzero,Zfirst,Zsecond] = golayDifferentiate(zero_netXYZ(:,3),diffWin);
    
    [dist_vec_filt,speed_vec_filt,accel_vec_filt] = golayDifferentiate(net_dist_vec,diffWin);
    dist_vec_mm = pix2mm(dist_vec_filt);
    speed_vec_frm = frm2sec(pix2mm(speed_vec_filt));
    accel_vec_frm = frm2sec(pix2mm(accel_vec_filt));
    max_dist = max(dist_vec_mm);
    max_speed = max(speed_vec_frm);
    max_accel = max(accel_vec_frm);
    
    %%%%% Use the following if frame of takeoff has been determined
    accel_thresh = max(accel_vec_filt);
    if max(accel_vec_filt) >= accel_thresh
        [max_accel,raw_fot] = findpeaks(accel_vec_filt,'MINPEAKHEIGHT',accel_thresh*0.9,...
            'MINPEAKDISTANCE',1,'NPEAKS',1);
        if isempty(max_accel)
            [max_accel,raw_fot] = max(accel_vec_filt);
            [max_speed,speed_fot] = max(speed_vec_filt);
        elseif numel(speed_vec_filt(raw_fot:end)) > 2
            [max_speed,speed_fot] = findpeaks(speed_vec_filt(raw_fot:end),'NPEAKS',1);
        else
            [max_speed,speed_fot] = max(speed_vec_filt);
        end
    else
        max_accel = NaN;
        raw_fot = NaN;
    end
    
    %%%%%%%%%%%%%%%%%%%%% Only used for visualization
    vis_count = 10;
    pos_marks = linspace(0,net_dist_filt(end),vis_count);
    pos_mark_adj = linspace(0.3,1,vis_count).^2;
    pos_mark_array = repmat(pos_marks.*pos_mark_adj,trk_end,1);
    delta_net_array = repmat(net_dist_filt,1,vis_count);
    [~,vis_refs] = min(abs(delta_net_array-pos_mark_array));
    
%     
%     frameReffullrate = vidStats.supplement_frame_reference{videoID};
%     Y = (1:numel(frameRefcutrate));
%     x = frameRefcutrate;
%     xi = (1:numel(frameRefcutrate)*10);
%     yi = interp1(x,Y,xi,'nearest');
%     [~,xSuppl] = ismember(frameReffullrate,xi);
%     objRefVec = ones(1,numel(frameRefcutrate)*10);
%     objRefVec(xSuppl) = 2;
%     yi(xSuppl) = (1:numel(frameReffullrate));
%     frameReferenceMesh = [xi(:)';yi(:)';objRefVec(:)'];
%     
%     vidpath = fullfile(pathlistKeep{iterQ},[videoID '.mp4']);
%     vidpathH = fullfile(pathlistKeep{iterQ},'highSpeedSupplement',[videoID '_supplement.mp4']);
%     try
%         vidObjA = VideoReader(vidpath);
%         vidObjB = VideoReader(vidpathH);
%     catch
%         disp(vidpath)
%     end
%     vidWidth = vidObjA.Width;
%     vidHeight = vidObjA.Height;
%     hH = vidHeight/2;
%     tol = [0.9 1];
%     video_init = read(vidObjA,[1 10]);
%     frame_01_gray = uint8(mean(squeeze(video_init(:,:,1,:)),3));
%     frm_half_gray = frame_01_gray(hH+1:end,:);
%     [~,frm_graymap] = gray2ind(frm_half_gray,256);
%     lowhigh_in = stretchlim(frm_half_gray,tol);
%     frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],0.9);
%     frm_remapB = uint8(frm_remap(:,1).*255);
%     frm_half_gray = frame_01_gray(1:hH,:);
%     [~,frm_graymap] = gray2ind(frm_half_gray,256);
%     lowhigh_in = stretchlim(frm_half_gray,tol);
%     frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],0.7);
%     frm_remapT = uint8(frm_remap(:,1).*255);
%     writeRefs = xi;
%     % color enhancement variables %
%     alphac = repmat(linspace(0,1,vis_count)',1,3);
%     basec = repmat([1.5 1 0.5],vis_count,1);
%     finc = alphac.^basec;
%     finc3d = repmat(finc,[1 1 vidHeight vidWidth]);
%     finc4d = permute(finc3d,[3 4 2 1]);
%     frm_merge = zeros(vidHeight,vidWidth,3,vis_count);
%     for iterC = 1:10
%         frameRead = frameReferenceMesh(2,writeRefs(vis_refs(iterC)));
%         readObjRef = frameReferenceMesh(3,writeRefs(vis_refs(iterC)));
%         if isnan(frameRead)
%             frameW = read(vidObjA,vidObjA.NumberOfFrames);
%         elseif readObjRef == 1
%             frameW = read(vidObjA,frameRead);
%         else
%             frameW = read(vidObjB,frameRead);
%         end
%         frameW = frameW(:,:,1);
%         vid_bot = frameW(hH+1:end,:);
%         vid_top = frameW(1:hH,:);
%         vid_bot = intlut(vid_bot,frm_remapB);
%         vid_top = intlut(vid_top,frm_remapT);
%         frameFull = double([vid_top;vid_bot])./255;
%         frm_merge(:,:,:,iterC) = repmat(frameFull,[1 1 3]).*finc4d(:,:,:,iterC);
%     end
%     frm_demo = uint8(max(frm_merge,[],4).*255);
%     padSize = 2;
%     frm_demo = imcrop(frm_demo,[0 0 vidWidth-padSize*2 vidHeight-padSize*2]);
%     visual_frame = padarray(frm_demo,[padSize padSize],255);
%     %%%%%%%%%%%%%%%%%%
    
    trk_raw_xyz = XYZ_3D_filt(vis_refs,:)-repmat(XYZ_3D_filt(1,:),vis_count,1);
    XYZ_poly_zero = zeros(vis_count,3);
    for iterZ = 1:2
        x_raw = trk_raw_xyz(:,1);
        y_raw = -trk_raw_xyz(:,1+iterZ);
        p_line = polyfit(x_raw,y_raw,1);
        x_line = x_raw;
        y_line = polyval([p_line(1) 0],x_line);
        x_theta_adj = atan2(x_line(end),y_line(end));
        [thetas_raw,rhos_raw] = cart2pol(x_raw,y_raw);
        [x_rot,y_rot] = pol2cart(thetas_raw-x_theta_adj,rhos_raw);
        [p_fit,S_fit] = polyfit(x_rot,y_rot,2);
        x_fit = linspace(0,x_rot(end),vis_count)';
        y_fit = polyval([p_fit(1:2) 0],x_fit);
        [thetas_fit,rhos_fit] = cart2pol(x_fit,y_fit);
        [x_poly,y_poly] = pol2cart(thetas_fit+x_theta_adj,rhos_fit);
        if iterZ == 1,
            XYZ_poly_zero(:,1:2) = [x_poly y_poly];
            dept_shape = p_fit;
            shape_confidence = S_fit;
        else
            XYZ_poly_zero(:,3) = y_poly;
        end
        
    end
    xyz_deprt = XYZ_poly_zero(end-5:end,:)-XYZ_poly_zero(end-5);
    xyz_mean = mean(diff(xyz_deprt));
    [az_deprt,ele_deprt,r_deprt] = cart2sph(xyz_mean(:,1),xyz_mean(:,2),xyz_mean(:,3));
    
%     %%%% Initialize image handle and tracking variables
%     close all
%     fig_posB = round([scrn_size(3)*0.01 scrn_size(4)*0.05,...
%         scrn_size(3)*0.9 scrn_size(4)*0.85]);
%     h_frame = figure('Position',fig_posB,'Color',[0 0 0]);
%     colormap('gray')
%     font_size = 12;
%     txt_colr = [1 1 1];
%     back_colr = [0 0 0];
%     plotc = colormap(hsv(vis_count));
%     graphc = [0.95 0.95 0.95];
%     raw_plotC = [0.75 0 0];
%     
%     %%%%% Generate new image and label it
%     subplot(3,3,[1 4 7]), imshow(visual_frame)
%     botXadjust = vidHeight-vidWidth+1;
%     hold on
%     text(1,vidWidth*2+150,['Frames:  ' num2str(vis_refs)],...
%         'HorizontalAlignment','left','FontWeight','bold',...
%         'Color',[1 1 1],'FontSize',font_size)
%     text(1,-50,['Video ID:  ' videoID],...
%         'HorizontalAlignment','left','FontWeight','bold',...
%         'Color',[1 1 1],'FontSize',font_size,'Interpreter','none')
%     
%     top_centroid = top_centroid_filt(vis_refs,:);
%     bot_centroid = bot_centroid_filt(vis_refs,:);
%     u_init = cos(loc_flyTheta)*(loc_flyLength/2); v_init = -sin(loc_flyTheta)*(loc_flyLength/2);
%     quiver(bot_centroid(1,1),bot_centroid(1,2)+botXadjust,u_init,v_init,...
%         'MaxHeadSize',0.5,'LineWidth',2,'AutoScaleFactor',1,'Color',[1 0 0])
%     %     plot(trk_xy_fit(:,1),trk_xy_fit(:,2)+vidWidth,'.','MarkerSize',18,'Color',back_colr)
%     %     plot(trk_xz_fit(:,1),trk_xz_fit(:,2),'.','MarkerSize',18,'Color',back_colr)
%     for iterE = 1:vis_count
%         vixPlotX = [bot_centroid(iterE,1);top_centroid(iterE,1)];
%         vixPlotY = [bot_centroid(iterE,2)+botXadjust;top_centroid(iterE,2)];
%         plot(vixPlotX,vixPlotY,'.','MarkerSize',14,'Color',plotc(iterE,:))
%     end
%     if ~isnan(stim_azi)
%         u_stim = cos(stim_azi)*(loc_flyLength/2); v_stim = -sin(stim_azi)*(loc_flyLength/2);
%         quiver(bot_centroid(1,1),bot_centroid(1,2)+botXadjust,u_stim,v_stim,...
%             'MaxHeadSize',0,'LineWidth',2,'AutoScaleFactor',1,'Color',[1 1 1])
%         u_demoC = cos(stim_azi-loc_flyTheta)*(loc_flyLength/2);
%         v_demoC = -sin(stim_azi-loc_flyTheta)*(loc_flyLength/2);
%         quiver(100,botXadjust,u_demoC,v_demoC,'MaxHeadSize',0,...
%             'LineWidth',2,'AutoScaleFactor',1,'Color',[1 1 1])
%         
%     end
%     u_deprt = cos(az_deprt)*(loc_flyLength/2); v_deprt = -sin(az_deprt)*(loc_flyLength/2);
%     quiver(bot_centroid(1,1),bot_centroid(1,2)+botXadjust,u_deprt,v_deprt,...
%         'MaxHeadSize',0.5,'LineWidth',2,'AutoScaleFactor',1,'Color',[0 0 1])
%     
%     u_demoA = cos(0)*(loc_flyLength/2); v_demoA = -sin(0)*(loc_flyLength/2);
%     quiver(100,botXadjust,u_demoA,v_demoA,'MaxHeadSize',0.5,...
%         'LineWidth',2,'AutoScaleFactor',1,'Color',[1 0 0])
%     u_demoB = cos(az_deprt-loc_flyTheta)*(loc_flyLength/2);
%     v_demoB = -sin(az_deprt-loc_flyTheta)*(loc_flyLength/2);
%     quiver(100,botXadjust,u_demoB,v_demoB,'MaxHeadSize',0.5,...
%         'LineWidth',2,'AutoScaleFactor',1,'Color',[0 0 1])
%     
%     %%%% Generate line graphical readouts
%     
%     plot_cell = {dist_vec_mm,speed_vec_frm,accel_vec_frm};
%     titles_cell = {'Distance (mm)'
%         'Speed (mm/sec)'
%         'Acceleration (mm/sec/sec)'};
%     y_label_cell = {'mm','mm/sec','mm/sec^2'};
%     plot_refs = {(2:3),(5:6),(8:9)};
%     %     y_lim_cell = {[0 500];[-5 20]};
%     lineX = [vis_refs;vis_refs];
%     for iterD = 1:3
%         subplot(3,3,plot_refs{iterD});
%         plot_var = plot_cell{iterD};
%         plot_var(isnan(plot_var)) = [];
%         sub_ylim = [min(plot_var(:)) max(plot_var(:))].*1.2;
%         if max(sub_ylim) == 0
%             sub_ylim = get(gca,'ylim');
%         end
%         %         if iterD == 1,sub_ylim = [-50 50]; end
%         set(gca,'Color',back_colr,'XLim',[1 nFrames],...
%             'XTick',[],'XColor',txt_colr,'YColor',txt_colr,...
%             'TickDir','out','NextPlot','add','YGrid','on','YLim',sub_ylim)
%         lineY = repmat([sub_ylim(1);sub_ylim(2)],1,vis_count);
%         for iterF = 1:vis_count
%             plot(lineX(:,iterF),lineY(:,iterF),'Color',...
%                 plotc(iterF,:).*0.75,'LineWidth',1)
%         end
%         plot(plot_var,'LineWidth',6,'Color',[0 0 0])
%         plot(plot_var,'LineWidth',2,'Color',graphc)
%         plot([raw_fot;raw_fot],sub_ylim','LineStyle',':','LineWidth',1,'Color',txt_colr);
%         title(titles_cell{iterD},'FontWeight','bold','Color',txt_colr,...
%             'FontSize',font_size)
%         ylabel(y_label_cell{iterD},'Color',txt_colr,'FontSize',font_size)
%     end
%     set(gca,'XTick',(0:400:2400))
%     xlabel('frame','Color',txt_colr,'FontSize',font_size)
%     hold off
%     
%     frame = getframe(h_frame);
%     %     uiwait(gcf)
%     
%     analyzed_visual = frame.cdata(:,90:end-29,:);
%     
%     
%     %%%%% Generate visual readout of locator results
%     report_labels = {'Takeoff(Y/N):','Frame of takeoff:','Departure shape:',...
%         'Fit residuals:','Max distance:','Max speed:','Max accel:'};
%     report_vals = cell(1,numel(report_labels));
%     takeoff_ops = {'Yes','No'};
%     takeoff_test = isnan(raw_fot);
%     report_vals{1} = takeoff_ops{takeoff_test+1};
%     if takeoff_test == 0
%         report_vals{2} = uint16(raw_fot);
%         report_vals{3} = dept_shape;
%         report_vals{4} = shape_confidence.R;
%         report_vals{5} = max_dist;
%         report_vals{6} = [int2str(round(max_speed)) ' mm/sec'];
%         report_vals{7} = [int2str(round(max_accel)) ' mm/sec^2'];
%     end
%     final_report = cat(1,report_labels,report_vals);
%     report_block = zeros(size(analyzed_visual,1),280);
%     char_blanks = repmat({' '},size(final_report));
%     reports_title = 'ANALYSIS RESULTS';
%     labels_cell = cat(1,final_report,char_blanks);
%     labels_cell = cat(1,reports_title,char_blanks(:,1),labels_cell(:));
%     report_block = textN2im(report_block,labels_cell,12,[0.1 0.3]);
%     analysis_labeled = cat(2,repmat(uint8(report_block.*255),[1 1 3]),analyzed_visual);
%     imwrite(analysis_labeled,analyzed_vis_name,'jpg');
%     
%     %                 close(gcf),imshow(analysis_labeled),uiwait(gcf)

    
    
    analysis_record.XYZ_3D_filt = {XYZ_3D_filt};
    analysis_record.net_dist_filt = {dist_vec_mm};
    analysis_record.speed = {speed_vec_frm};
    analysis_record.acceleration = {accel_vec_frm};
    analysis_record.departure_az_ele_rad = {[az_deprt,ele_deprt,r_deprt]};
    analysis_record.final_frame_tracked = {trk_end};
    analysis_record.stimulus_azimuth = {stim_azi};
    analysis_record.stimulus_elevation = {xxx};
    analysis_record.departure_shape = {dept_shape};
    analysis_record.shape_confidence = {shape_confidence};
    analysis_record.deprt_dist = {max_dist};
    analysis_record.deprt_speed = {max_speed};
    analysis_record.deprt_accel = {max_accel};
    analysis_record.XYZ_separate_velocity = {[Xfirst,Yfirst,Zfirst]};
    analysis_record.XYZ_separate_acceleration = {[Xsecond,Ysecond,Zsecond]};
    analysis_record.top_points_and_thetas = {[top_centroid_filt,trk_topTheta_filt,trk_topMajRho_filt,trk_topMinRho_filt]};
    analysis_record.bot_points_and_thetas = {[bot_centroid_filt,trk_botTheta_filt]};
    analysis_record.ten_sample_points = {vis_refs};
    analysis_record.fly_length = {loc_flyLength};
    analysis_record.final_outcome = {'analyzed'};
    
end
% toc
% analysis_data(videoID,:) = analysis_record;
% save(analysis_data_path,'analysis_data')
%     end
% end
% delete(h_wait)
%%
% set(0,'ShowHiddenHandles','on')
% delete(get(0,'Children'))