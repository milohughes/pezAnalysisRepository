function flyTracker3000_v17_jaaba(videoID)

%%%%%%%%%% Display control
showMovie = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%

if isempty(mfilename) || nargin == 0
    videoID = 'run016_pez3003_20150303_expt0058000003260437_vid0001';
end
runMode = 1;
tracker_name = 'flyTracker3000_v17_jaaba';
locator_name = 'flyLocator3000_v10';
strParts = strsplit(videoID,'_');
runID = [strParts{1} '_' strParts{2} '_' strParts{3}];
exptID = strParts{4}(5:end);

%%%% Establish data destination directory
analysisDir = fullfile('\\tier2','card','Data_pez3000_analyzed');
expt_results_dir = fullfile(analysisDir,exptID);
tracker_expt_ID = [videoID '_' tracker_name '_data.mat'];%experiment ID
tracker_data_dir = fullfile(expt_results_dir,[exptID '_' tracker_name]);
if ~isdir(tracker_data_dir), mkdir(tracker_data_dir),end
tracker_data_path = fullfile(tracker_data_dir,tracker_expt_ID);
if runMode > 2
    if exist(tracker_data_path,'file')
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
    return
end
porf_test = locator_record.pass_or_fail{:};
if porf_test ~= 1, return, end

% Tracker variables %
trk_varnames = {'top_centroid','top_maj_theta','top_maj_rho','top_min_rho','locator_path'};
tracker_record = cell2table(cell(1,numel(trk_varnames)),'VariableNames',...
    trk_varnames,'RowNames',{videoID});
tracker_record.locator_path = {locator_data_path};


autoAnnoName = [exptID '_automatedAnnotations.mat'];
autoAnnotationsPath = fullfile(expt_results_dir,autoAnnoName);
if exist(autoAnnotationsPath,'file') == 2
    autoAnnoTable_import = load(autoAnnotationsPath);
    dataname = fieldnames(autoAnnoTable_import);
    automatedAnnotations = autoAnnoTable_import.(dataname{1});
else
    disp('no auto annotations')
    return
end


%%%%% Read video file
vidPath = locator_record.orig_video_path{1};
vidPath = regexprep(vidPath,'arch','tier2');
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
writeRefs = xi;

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
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vidWidth = vidObjA.Width;
vid_count = numel(writeRefs);
video_3D = read(vidObjA,1);
video_3D = video_3D(:,:,1);

%%%%% Define tracking variables
cntr_pt_init = locator_record.center_point{:};
fly_length = locator_record.fly_length{:};

% parent_dir = 'C:\Users\williamsonw\Documents\pezAnalysisRepository';
% subfun_dir = fullfile(parent_dir,'pezProc_subfunctions');
% addpath(subfun_dir)

%%%%% Establishing background and re-mapper
frame_01_gray = uint8(video_3D(1:vidWidth,:,1));%avg 1st 10 frames; est. background
backoff = 10;
tol = [0 0.9999];
gammaAdj = 0.75;
tI = log(double(frame_01_gray)+backoff);
frame_01_gray = uint8(255*(tI/log(255+backoff)-log(backoff)/log(255+backoff)));
[~,frm_graymap] = gray2ind(frame_01_gray,256);
lowhigh_in = stretchlim(frame_01_gray,tol);
lowhigh_in(1) = 0.01;
frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],gammaAdj);
frm_remap = uint8(frm_remap(:,1).*255);

frame_01_gray = intlut(frame_01_gray,frm_remap);

frm_T_gray = frame_01_gray;

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
if isempty(pixel_count),return,end
pixel_val = max(pixel_count);
stat_ref = find(pixel_val == pixel_count,1,'first');
top_centroid = stats(stat_ref).Centroid;
maj_theta = pi/180*(stats(stat_ref).Orientation+180);
maj_rho = stats(stat_ref).MajorAxisLength/2;
min_rho = stats(stat_ref).MinorAxisLength/2;


%%%%% Video analysis

% preallocate variables, initialize slaves
topLabels = NaN(vid_count,5);
% Establish figure for frame-getting
if showMovie == 1
    scrn_size = get(0, 'ScreenSize');
    fig_position = [scrn_size(3)/10 scrn_size(4)/10 scrn_size(3)*0.6 scrn_size(4)*0.7];
    h_fig = figure('Position',fig_position);
    h_axes1 = axes('Parent',h_fig);
    colormap('gray')
end
for frm_ref = 1:vid_count
    if automatedAnnotations.jumpTest{videoID}
        if writeRefs(frm_ref) >= automatedAnnotations.autoFrameOfTakeoff{videoID}
            break
        end
    end
    
    frameRead = frameReferenceMesh(2,writeRefs(frm_ref));
    if frm_ref > 1
        frmLast = frameReferenceMesh(2,writeRefs(frm_ref-1));
    else
        frmLast = 0;
    end
    if frmLast ~= frameRead
        
        readObjRef = frameReferenceMesh(3,writeRefs(frm_ref));
        if isnan(frameRead)
            frameW = read(vidObjA,vidObjA.NumberOfFrames);
        elseif readObjRef == 1
            frameW = read(vidObjA,frameRead);
        else
            frameW = read(vidObjB,frameRead);
        end
        frameW = frameW(:,:,1);
        frame_01_gray = frameW(1:vidWidth,:);
        
        tI = log(double(frame_01_gray)+backoff);
        frame_01_gray = uint8(255*(tI/log(255+backoff)-log(backoff)/log(255+backoff)));
        frame_01_gray = intlut(frame_01_gray,frm_remap);

        frm_top = double(frame_01_gray)/255;
 
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
        if showMovie == 1
            %%%%% Generate new image
            visual_frame = [frm_top BW_top];
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
            

            text(15,135,['Frame:  ' int2str(frm_ref)],...
                'HorizontalAlignment','left','FontWeight','bold',...
                'Color',[1 1 1],'FontSize',10,'Interpreter','none')
            hold off
            drawnow
        end
    end
    if isempty(pixel_count)
        break
    end
    topLabels(frm_ref,:) = [top_centroid,maj_theta,maj_rho,min_rho];
end
if showMovie == 1
    close(h_fig)
end
%%
tracker_record.top_centroid = {topLabels(:,1:2)};
tracker_record.top_maj_theta = {topLabels(:,3)};
tracker_record.top_maj_rho = {topLabels(:,4)};
tracker_record.top_min_rho = {topLabels(:,5)};
saveobj = tracker_record;
save(tracker_data_path,'saveobj')
