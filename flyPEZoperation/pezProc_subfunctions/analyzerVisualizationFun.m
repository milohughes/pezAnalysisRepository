function analysis_labeled = analyzerVisualizationFun(analysis_record,locator_record)

%%%% Analyzer variables
% ana1 = 'XYZ_3D_filt';
ana2 = 'net_dist_filt';
ana3 = 'speed';
ana4 = 'acceleration';
ana5 = 'frame_of_takeoff';
ana6 = 'departure_az_ele_rad';
% ana7 = 'final_frame_tracked';
ana8 = 'stimulus_azimuth';
ana9 = 'stimulus_elevation';
ana10 = 'departure_shape';
ana11 = 'shape_confidence';
ana12 = 'deprt_dist';
ana13 = 'deprt_speed';
ana14 = 'deprt_accel';
% ana15 = 'tracker_data_path';
% ana16 = 'analyzed_vis_path';
% ana17 = 'exptID';
% ana18 = 'XYZ_separate_velocity';
% ana19 = 'XYZ_separate_acceleration';
ana20 = 'top_points_and_thetas';
ana21 = 'bot_points_and_thetas';
ana22 = 'ten_sample_points';
% ana23 = 'fly_length';
% ana24 = 'final_outcome';

% XYZ_3D_filt = analysis_record.(ana1){1};
dist_vec_mm = analysis_record.(ana2){1};
speed_vec_frm = analysis_record.(ana3){1};
accel_vec_frm = analysis_record.(ana4){1};
raw_fot = analysis_record.(ana5){1};
az_deprt = analysis_record.(ana6){1}(1);
% ele_deprt = analysis_record.(ana6){1}(2);
% r_deprt = analysis_record.(ana6){1}(3);
% trk_end = analysis_record.(ana7){1};
stim_azi = analysis_record.(ana8){1};
analysis_record.(ana9);
dept_shape = analysis_record.(ana10){1};
shape_confidence = analysis_record.(ana11){1};
max_dist = analysis_record.(ana12){1};
max_speed = analysis_record.(ana13){1};
max_accel = analysis_record.(ana14){1};

% Xfirst = analysis_record.(ana18){1}(:,1);
% Yfirst = analysis_record.(ana18){1}(:,2);
% Zfirst = analysis_record.(ana18){1}(:,3);
% 
% Xsecond = analysis_record.(ana19){1}(:,1);
% Ysecond = analysis_record.(ana19){1}(:,2);
% Zsecond = analysis_record.(ana19){1}(:,3);

top_centroid_filt = analysis_record.(ana20){1}(:,1:2);
% trk_topTheta_filt = analysis_record.(ana20){1}(:,3);
% trk_topMajRho_filt = analysis_record.(ana20){1}(:,4);
% trk_topMinRho_filt = analysis_record.(ana20){1}(:,5);
bot_centroid_filt = analysis_record.(ana21){1}(:,1:2);
% trk_botTheta_filt = analysis_record.(ana21){1}(:,3);

vis_refs = analysis_record.(ana22){1};
% loc_flyLength = analysis_record.(ana23){1};

scrn_size = get(0,'ScreenSize');
% pix2mm = @(x) x.*(5/250);%prism is 5mm and ~250 pixels wide
% frm2sec = @(x) x.*6000;%eventually, get framerate from .cih file
%

[runPath,videoID,vidExt] = fileparts(locator_record.orig_video_path{1});
[~,runDir] = fileparts(runPath);


vidstatname = [runDir '_videoStatistics.mat'];
vidstatPath = fullfile(runPath,vidstatname);
vidstatPath = regexprep(vidstatPath,'arch','tier2');
vidStatsLoad = load(vidstatPath);
vidStats = vidStatsLoad.vidStats;

frameRefcutrate = vidStats.cutrate10th_frame_reference{videoID};

nFrames = numel(frameRefcutrate)*10;

loc_flyLength = locator_record.fly_length{:};
loc_flyTheta = locator_record.fly_theta{:};

vis_count = numel(vis_refs);
frameReffullrate = vidStats.supplement_frame_reference{videoID};
Y = (1:numel(frameRefcutrate));
x = frameRefcutrate;
xi = (1:numel(frameRefcutrate)*10);
yi = interp1(x,Y,xi,'nearest');
[~,xSuppl] = ismember(frameReffullrate,xi);
objRefVec = ones(1,numel(frameRefcutrate)*10);
objRefVec(xSuppl) = 2;
yi(xSuppl) = (1:numel(frameReffullrate));
frameReferenceMesh = [xi(:)';yi(:)';objRefVec(:)'];

vidPath = locator_record.orig_video_path{1};
vidPath = regexprep(vidPath,'arch','tier2');
vidpathH = fullfile(runPath,'highSpeedSupplement',[videoID '_supplement' vidExt]);
vidpathH = regexprep(vidpathH,'arch','tier2');
try
    vidObjA = VideoReader(vidPath);
    vidObjB = VideoReader(vidpathH);
catch
    disp(vidPath)
end

vidWidth = vidObjA.Width;
vidHeight = vidObjA.Height;
hH = vidHeight/2;
tol = [0.9 1];
video_init = read(vidObjA,[1 3]);
frame_01_gray = uint8(mean(squeeze(video_init(:,:,1,:)),3));
frm_half_gray = frame_01_gray(hH+1:end,:);
[~,frm_graymap] = gray2ind(frm_half_gray,256);
lowhigh_in = stretchlim(frm_half_gray,tol);
frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],0.9);
frm_remapB = uint8(frm_remap(:,1).*255);
frm_half_gray = frame_01_gray(1:hH,:);
[~,frm_graymap] = gray2ind(frm_half_gray,256);
lowhigh_in = stretchlim(frm_half_gray,tol);
frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],0.7);
frm_remapT = uint8(frm_remap(:,1).*255);
writeRefs = xi;
%
% color enhancement variables %
alphac = repmat(linspace(0,1,vis_count)',1,3);
basec = repmat([1.5 1 0.5],vis_count,1);
finc = alphac.^basec;
finc3d = repmat(finc,[1 1 vidHeight vidWidth]);
finc4d = permute(finc3d,[3 4 2 1]);
frm_merge = zeros(vidHeight,vidWidth,3,vis_count);
for iterC = 1:10
    frameRead = frameReferenceMesh(2,writeRefs(vis_refs(iterC)));
    readObjRef = frameReferenceMesh(3,writeRefs(vis_refs(iterC)));
    if isnan(frameRead)
        frmRead = read(vidObjA,vidObjA.NumberOfFrames);
    elseif readObjRef == 1
        frmRead = read(vidObjA,frameRead);
    else
        frmRead = read(vidObjB,frameRead);
    end
    frmRead = frmRead(:,:,1);
    vid_bot = frmRead(hH+1:end,:);
    vid_top = frmRead(1:hH,:);
    vid_bot = intlut(vid_bot,frm_remapB);
    vid_top = intlut(vid_top,frm_remapT);
    frameFull = double([vid_top;vid_bot])./255;
    frm_merge(:,:,:,iterC) = repmat(frameFull,[1 1 3]).*finc4d(:,:,:,iterC);
end
frm_demo = uint8(max(frm_merge,[],4).*255);
padSize = 2;
frm_demo = imcrop(frm_demo,[0 0 vidWidth-padSize*2 vidHeight-padSize*2]);
visual_frame = padarray(frm_demo,[padSize padSize],255);

%%%% Initialize image handle and tracking variables
close all
fig_posB = round([scrn_size(3)*0.01 scrn_size(4)*0.05,...
    scrn_size(3)*0.9 scrn_size(4)*0.85]);
h_frame = figure('Position',fig_posB,'Color',[0 0 0]);
colormap('gray')
font_size = 12;
txt_colr = [1 1 1];
back_colr = [0 0 0];
plotc = colormap(hsv(vis_count));
graphc = [0.95 0.95 0.95];
% raw_plotC = [0.75 0 0];

%%%%% Generate new image and label it
subplot(3,3,[1 4 7]), imshow(visual_frame)
botXadjust = vidHeight-vidWidth+1;
hold on
text(1,vidWidth*2+150,['Frames:  ' num2str(vis_refs)],...
    'HorizontalAlignment','left','FontWeight','bold',...
    'Color',[1 1 1],'FontSize',font_size)
text(1,-50,['Video ID:  ' videoID],...
    'HorizontalAlignment','left','FontWeight','bold',...
    'Color',[1 1 1],'FontSize',font_size,'Interpreter','none')

top_centroid = top_centroid_filt(vis_refs,:);
bot_centroid = bot_centroid_filt(vis_refs,:);
u_init = cos(loc_flyTheta)*(loc_flyLength/2); v_init = -sin(loc_flyTheta)*(loc_flyLength/2);
quiver(bot_centroid(1,1),bot_centroid(1,2)+botXadjust,u_init,v_init,...
    'MaxHeadSize',0.5,'LineWidth',2,'AutoScaleFactor',1,'Color',[1 0 0])
%     plot(trk_xy_fit(:,1),trk_xy_fit(:,2)+vidWidth,'.','MarkerSize',18,'Color',back_colr)
%     plot(trk_xz_fit(:,1),trk_xz_fit(:,2),'.','MarkerSize',18,'Color',back_colr)
for iterE = 1:vis_count
    vixPlotX = [bot_centroid(iterE,1);top_centroid(iterE,1)];
    vixPlotY = [bot_centroid(iterE,2)+botXadjust;top_centroid(iterE,2)];
    plot(vixPlotX,vixPlotY,'.','MarkerSize',14,'Color',plotc(iterE,:))
end
if ~isnan(stim_azi)
    u_stim = cos(stim_azi)*(loc_flyLength/2); v_stim = -sin(stim_azi)*(loc_flyLength/2);
    quiver(bot_centroid(1,1),bot_centroid(1,2)+botXadjust,u_stim,v_stim,...
        'MaxHeadSize',0,'LineWidth',2,'AutoScaleFactor',1,'Color',[1 1 1])
    u_demoC = cos(stim_azi-loc_flyTheta)*(loc_flyLength/2);
    v_demoC = -sin(stim_azi-loc_flyTheta)*(loc_flyLength/2);
    quiver(100,botXadjust,u_demoC,v_demoC,'MaxHeadSize',0,...
        'LineWidth',2,'AutoScaleFactor',1,'Color',[1 1 1])
    
end
u_deprt = cos(az_deprt)*(loc_flyLength/2); v_deprt = -sin(az_deprt)*(loc_flyLength/2);
quiver(bot_centroid(1,1),bot_centroid(1,2)+botXadjust,u_deprt,v_deprt,...
    'MaxHeadSize',0.5,'LineWidth',2,'AutoScaleFactor',1,'Color',[0 0 1])

u_demoA = cos(0)*(loc_flyLength/2); v_demoA = -sin(0)*(loc_flyLength/2);
quiver(100,botXadjust,u_demoA,v_demoA,'MaxHeadSize',0.5,...
    'LineWidth',2,'AutoScaleFactor',1,'Color',[1 0 0])
u_demoB = cos(az_deprt-loc_flyTheta)*(loc_flyLength/2);
v_demoB = -sin(az_deprt-loc_flyTheta)*(loc_flyLength/2);
quiver(100,botXadjust,u_demoB,v_demoB,'MaxHeadSize',0.5,...
    'LineWidth',2,'AutoScaleFactor',1,'Color',[0 0 1])

%%%% Generate line graphical readouts

plot_cell = {dist_vec_mm,speed_vec_frm,accel_vec_frm};
titles_cell = {'Distance (mm)'
    'Speed (mm/sec)'
    'Acceleration (mm/sec/sec)'};
y_label_cell = {'mm','mm/sec','mm/sec^2'};
plot_refs = {(2:3),(5:6),(8:9)};
%     y_lim_cell = {[0 500];[-5 20]};
lineX = [vis_refs;vis_refs];
for iterD = 1:3
    subplot(3,3,plot_refs{iterD});
    plot_var = plot_cell{iterD};
    plot_var(isnan(plot_var)) = [];
    sub_ylim = [min(plot_var(:)) max(plot_var(:))].*1.2;
    if max(sub_ylim) == 0
        sub_ylim = get(gca,'ylim');
    end
    %         if iterD == 1,sub_ylim = [-50 50]; end
    set(gca,'Color',back_colr,'XLim',[1 nFrames],...
        'XTick',[],'XColor',txt_colr,'YColor',txt_colr,...
        'TickDir','out','NextPlot','add','YGrid','on','YLim',sub_ylim)
    lineY = repmat([sub_ylim(1);sub_ylim(2)],1,vis_count);
    for iterF = 1:vis_count
        plot(lineX(:,iterF),lineY(:,iterF),'Color',...
            plotc(iterF,:).*0.75,'LineWidth',1)
    end
    plot(plot_var,'LineWidth',6,'Color',[0 0 0])
    plot(plot_var,'LineWidth',2,'Color',graphc)
    plot([raw_fot;raw_fot],sub_ylim','LineStyle',':','LineWidth',1,'Color',txt_colr);
    title(titles_cell{iterD},'FontWeight','bold','Color',txt_colr,...
        'FontSize',font_size)
    ylabel(y_label_cell{iterD},'Color',txt_colr,'FontSize',font_size)
end
set(gca,'XTick',(0:400:2400))
xlabel('frame','Color',txt_colr,'FontSize',font_size)
hold off

frame = getframe(h_frame);
uiwait(gcf,1)

analysis_labeled = frame.cdata(:,90:end-29,:);


% %%%%% Generate visual readout of locator results
% report_labels = {'Takeoff(Y/N):','Frame of takeoff:','Departure shape:',...
%     'Fit residuals:','Max distance:','Max speed:','Max accel:'};
% report_vals = cell(1,numel(report_labels));
% takeoff_ops = {'Yes','No'};
% takeoff_test = isnan(raw_fot);
% report_vals{1} = takeoff_ops{takeoff_test+1};
% if takeoff_test == 0
%     report_vals{2} = uint16(raw_fot);
%     report_vals{3} = dept_shape;
%     report_vals{4} = shape_confidence.R;
%     report_vals{5} = max_dist;
%     report_vals{6} = [int2str(round(max_speed)) ' mm/sec'];
%     report_vals{7} = [int2str(round(max_accel)) ' mm/sec^2'];
% end
% final_report = cat(1,report_labels,report_vals);
% report_block = zeros(size(analyzed_visual,1),280);
% char_blanks = repmat({' '},size(final_report));
% reports_title = 'ANALYSIS RESULTS';
% labels_cell = cat(1,final_report,char_blanks);
% labels_cell = cat(1,reports_title,char_blanks(:,1),labels_cell(:));
% report_block = textN2im(report_block,labels_cell,12,[0.1 0.3]);
% analysis_labeled = cat(2,repmat(uint8(report_block.*255),[1 1 3]),analyzed_visual);

close(gcf)
% imshow(analysis_labeled)
% uiwait(gcf)




