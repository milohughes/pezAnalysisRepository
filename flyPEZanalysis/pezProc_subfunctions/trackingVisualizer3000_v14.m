function trackingVisualizer3000_v14(exptID)
persistent rescreenResults

%%
%%%%% ENTER FUNCTION NAMES:
analyzer_name = 'flyAnalyzer3000_v14';
debug = 0;

if isempty(mfilename) || nargin == 0
    exptID = '0113000025020586';
    
    %     exptID = '0076000004300570'; % grating new at 2000 fps (10th frame)
    %     exptID = '0057000004300308'; % DL Ele_45 Azi_0 (looking at turn vel)
    %     exptID = '0021000004300112'; % DL Ele_45 Azi_157(looking at turn vel)
    
    %     exptID = '0058000003370437';%LC16 - turning and backing
    %     exptID = '0041000004300282';% grating with normal rec rate (6000 fps)
    %     exptID = '0041000004300400';% grating with unusual rec rate (500 fps)
    debug = 1;
end

%%%% Establish data destination directory
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');

analysisDir = fullfile(fileDir,'Data_pez3000_analyzed');
expt_results_dir = fullfile(analysisDir,exptID);
graphTablePath = fullfile(expt_results_dir,[exptID '_dataForVisualization.mat']);
% if ~exist(graphTablePath,'file')
%     disp([exptID ' - no data for visualization file'])
%     return
% else
%     graphTableLoading = load(graphTablePath);
%     graphTable = graphTableLoading.graphTable;
%     if max(strcmp(graphTable.Properties.VariableNames,'IRlights'))
%         return
%     end
% end
if isempty(mfilename)
    rescreenResults = [];
end
if isempty(rescreenResults)
  %  rescreenResults = load('\\dm11\cardlab\WryanW\rescreen_results_full.mat');
    %rescreenResults = rescreenResults.rescreen_results_full;
end

autoAnnoName = [exptID '_automatedAnnotations.mat'];
autoAnnotationsPath = fullfile(expt_results_dir,autoAnnoName);
if exist(autoAnnotationsPath,'file') == 2
    autoAnnoTable_import = load(autoAnnotationsPath);
    dataname = fieldnames(autoAnnoTable_import);
    automatedAnnotations = autoAnnoTable_import.(dataname{1});
else
    if debug
        disp('no auto annotations')
    end
    return
end

manAnnoName = [exptID '_manualAnnotations.mat'];
manAnnotationsPath = fullfile(expt_results_dir,manAnnoName);
if exist(manAnnotationsPath,'file') == 2
    manAnnoTable_import = load(manAnnotationsPath);
    dataname = fieldnames(manAnnoTable_import);
    manualAnnotations = manAnnoTable_import.(dataname{1});
else
    if debug
        disp('no manual annotations')
    end
    return
end

%%%%% Load manual jump direction table
manJumpDirTable = load(fullfile(fileDir,'Jump_Angle_Tracking','Escape_Angle_Data.mat'));
manJumpDirTable = manJumpDirTable.all_save_data;
%%%%% Load assessment table
assessmentPath = fullfile(expt_results_dir,[exptID '_rawDataAssessment.mat']);
assessTable_import = load(assessmentPath);
dataname = fieldnames(assessTable_import);
assessTable = assessTable_import.(dataname{1});

vidInfoMergedName = [exptID '_videoStatisticsMerged.mat'];
vidInfoMergedPath = fullfile(expt_results_dir,vidInfoMergedName);
vidInfo_import = load(vidInfoMergedPath);
dataname = fieldnames(vidInfo_import);
videoStatisticsMerged = vidInfo_import.(dataname{1});

manualAnnotations = fixManAnno(manualAnnotations,videoStatisticsMerged);

exptInfoMergedName = [exptID '_experimentInfoMerged.mat'];
exptInfoMergedPath = fullfile(expt_results_dir,exptInfoMergedName);
experimentInfoMerged = load(exptInfoMergedPath,'experimentInfoMerged');
exptInfo = experimentInfoMerged.experimentInfoMerged;

if isempty(mfilename)
    saveTable = false;
else
    saveTable = true;
end
videoIDlist = assessTable.Properties.RowNames;
badVids = ~strcmp(assessTable.Analysis_Status,'Analysis complete');
videoIDlist(badVids) = [];
if isempty(videoIDlist)
    return
end
vidCt = numel(videoIDlist);

autoJumpTest = zeros(vidCt,1);
autoFot = zeros(vidCt,1);
manualJumpTest = zeros(vidCt,1);
manualFot = zeros(vidCt,1);
manual_wingup_wingdwn_legpush = cell(vidCt,1);
jumpEnd = zeros(vidCt,1);
jumpStart_theta = zeros(vidCt,1);
stimStart_flyTheta = zeros(vidCt,1);
stimStart_jumpTheta = zeros(vidCt,1);
botTheta_filt = cell(vidCt,1);
trkEnd = zeros(vidCt,1);
stimStart = zeros(vidCt,1);
zeroFly_XYZT_fac1000 = cell(vidCt,1);
relPosition_FB_LR_T_fac1000 = cell(vidCt,1);
rawFly_XYZT_atFrmOne = cell(vidCt,1);
roiAdjusted = cell(vidCt,1);
flyLength = zeros(vidCt,1);
mm_per_pixel = zeros(vidCt,1);
flipBool = false(vidCt,1);
zeroFly_Trajectory = cell(vidCt,1);
zeroFly_Jump = cell(vidCt,1);
rawFly_Jump = zeros(vidCt,1);
zeroFly_Departure = cell(vidCt,1);
zeroFly_StimAtStimStart = zeros(vidCt,1);
zeroFly_StimAtJump = zeros(vidCt,1);
zeroFly_StimAtFrmOne = zeros(vidCt,1);
timestamp = cell(vidCt,1);
temp_degC = zeros(vidCt,1);
humidity = zeros(vidCt,1);
IRlights = zeros(vidCt,1);
manualJumpDir = zeros(vidCt,1);
stim_azi = zeros(vidCt,1); %pez azimuth at which stimulus was displayed
graphTable = table(autoJumpTest,autoFot,manualJumpTest,manualFot,...
    manual_wingup_wingdwn_legpush,jumpEnd,jumpStart_theta,stimStart_flyTheta,stimStart_jumpTheta,trkEnd,stimStart,zeroFly_XYZT_fac1000,...
    relPosition_FB_LR_T_fac1000,rawFly_XYZT_atFrmOne,roiAdjusted,flyLength,...
    mm_per_pixel,flipBool,zeroFly_Trajectory,zeroFly_Jump,rawFly_Jump,zeroFly_Departure,...
    zeroFly_StimAtStimStart,zeroFly_StimAtJump,zeroFly_StimAtFrmOne,timestamp,...
    temp_degC,humidity,IRlights,manualJumpDir,botTheta_filt,stim_azi,'RowNames',videoIDlist);
%%
frms_per_ms = double(max(videoStatisticsMerged.record_rate))/1000;
fc = 150; % cutoff frequency
fs = frms_per_ms*1000; % sample rate
filtHz = fc/(fs/2);
d1 = designfilt('lowpassiir','FilterOrder',1,...
    'HalfPowerFrequency',filtHz,'DesignMethod','butter');
analyzer_data_dir = fullfile(expt_results_dir,[exptID '_' analyzer_name]);
% badVids = false(vidCt,1);
for iterV = 1:vidCt
    videoID = videoIDlist{iterV};
    strParts = strsplit(videoID,'_');
    runID = [strParts{1} '_' strParts{2} '_' strParts{3}];
    vidStats = videoStatisticsMerged(videoID,:);
    
    analyzer_expt_ID = [videoID '_' analyzer_name '_data.mat'];%experiment ID
    analyzer_data_path = fullfile(analyzer_data_dir,analyzer_expt_ID);
    %%%% Analyzer table
    %     if exist(analyzer_data_path,'file') == 2
    analysis_data_import = load(analyzer_data_path);
    dataname = fieldnames(analysis_data_import);
    analysis_record = analysis_data_import.(dataname{1});
    %         if ~strcmp(analysis_record.final_outcome{1},'analyzed')
    %             badVids(iterV) = true;
    %             continue
    %         end
    %     else
    %         badVids(iterV) = true;
    %         continue
    %     end
    XYZ_3D_filt = analysis_record.XYZ_3D_filt{1};
    zero_netXYZ = XYZ_3D_filt-repmat(XYZ_3D_filt(1,:),size(XYZ_3D_filt,1),1);
    for iterFilt = 1:3
        zero_netXYZ(:,iterFilt) = filtfilt(d1,zero_netXYZ(:,iterFilt));
    end
    roiPos = assessTable.Adjusted_ROI{videoID};
    graphTable.roiAdjusted(videoID) = {roiPos};
    vidWidth = double(vidStats.frame_width);
    vidHeight = double(vidStats.frame_height);
    graphTable.timestamp(videoID) = vidStats.trigger_timestamp(1);
    graphTable.temp_degC(videoID) = double(vidStats.temp_degC);
    graphTable.humidity(videoID) = double(vidStats.humidity_percent);
    graphTable.IRlights(videoID) = double(vidStats.IR_light_internsity);
    
    [~,prismW] = roi2crop(roiPos,vidWidth,vidHeight);
    graphTable.mm_per_pixel(videoID) = 5/prismW;
    
    manFot = manualAnnotations.frame_of_take_off{videoID};
    if ~isempty(manFot)
        if ~isnan(manFot)
            manJumpTest = true;
        else
            manJumpTest = false;
        end
        %if max(strcmp(rescreenResults.Properties.RowNames,videoID))
         %   manJumpTest = logical(rescreenResults.rescreen_results(videoID));
        %end
    else
        manJumpTest = NaN;
    end
    
    auto_fot = automatedAnnotations.autoFrameOfTakeoff{videoID};
    autoJumpTest = automatedAnnotations.jumpTest{videoID};
    if isempty(auto_fot)
        autoJumpTest = false;
    end
    trk_end = analysis_record.final_frame_tracked{1};
    jumpEnd = NaN;
    if autoJumpTest && (auto_fot <= trk_end)
        jumpEnd = auto_fot;
    end
    
    %%%%%%%%%%%%%%%%%%%%%% Compiling data to output %%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%% Jump-related information
    graphTable.manualJumpTest(videoID) = manJumpTest;
    graphTable.manualFot(videoID) = NaN;
    graphTable.manual_wingup_wingdwn_legpush(videoID) = {[NaN NaN NaN]};
    if ~isnan(manFot)
        if ~isempty(manFot)
            if manFot > 1
                if manJumpTest
                    if manFot <= trk_end
                        jumpEnd = manFot;
                    end
                    graphTable.manualFot(videoID) = manFot;
                    fowu = manualAnnotations.frame_of_wing_movement{videoID};
                    fowd = manualAnnotations.wing_down_stroke{videoID};
                    folp = manualAnnotations.frame_of_leg_push{videoID};
                    graphTable.manual_wingup_wingdwn_legpush(videoID) = {[fowu fowd folp]};
                end
            end
        end
    end
    graphTable.jumpEnd(videoID) = jumpEnd;
    graphTable.trkEnd(videoID) = trk_end;
    graphTable.autoFot(videoID) = NaN;
    graphTable.autoJumpTest(videoID) = autoJumpTest;
    if autoJumpTest
        graphTable.autoFot(videoID) = auto_fot;
    end
    
    %%%%% Referencing and indexing information %%%%%
    
    %%% Stimulus information
    stimStart = NaN;
    
    visStimType = exptInfo.Stimuli_Type{1};
    visStimTest = false;
    if ~strcmp('None',visStimType)
        if ~strcmp('Template_making',visStimType)
            visStimTest = true;
        end
    end
    activationStrCell = exptInfo.Photo_Activation{1};
    if ischar(activationStrCell)
        activationStrCell = {activationStrCell};
    end
    if ~strcmp('None',activationStrCell{1})
        photoStimTest = true;
    else
        photoStimTest = false;
    end
    if photoStimTest && visStimTest
        exptType = 'Combo';
    elseif photoStimTest
        exptType = 'Photoactivation';
    elseif visStimTest
        exptType = 'Visual_stimulation';
    elseif strcmp('Template_making',visStimType)
        exptType = 'Template_making';
    elseif strcmp('None',visStimType) && strcmp('None',activationStrCell{1})
        exptType = 'None';
    else
        exptType = 'Unknown';
    end
    if strcmp(exptType,'Visual_stimulation')
        stimStart = automatedAnnotations.visStimFrameStart{videoID};
    elseif strcmp(exptType,'Photoactivation')
        stimStart = automatedAnnotations.photoStimFrameStart{videoID};
    elseif strcmp(exptType,'Combo')
        stimStart = automatedAnnotations.visStimFrameStart{videoID};
    elseif max(strcmp({'None','Template_making'},exptType))
        stimStart = 1;
    else
        if debug && iterV == 1
            disp('wrong or unknown expt type')
        end
    end
    if isempty(stimStart)
        stimStart = 1;
    end
    if stimStart < 1, stimStart = 1; end
    %%%%%%%%%%%%%%%%%%%%%% CORRECTION FOR NIDAQ/CAMERA ERROR %%%%%%%%%%%%%%
    dateIDnum = datenum(datevec(strParts{3},'yyyymmdd'));
    dateBugWasFixed = datenum(datevec('20161206','yyyymmdd'));
    if dateIDnum < dateBugWasFixed
        if strcmp(deblank(vidStats.device_name{1}),'FASTCAM SA-X2 type 480K-M2')
            stimStart = stimStart+round(10*frms_per_ms);
        elseif strcmp(deblank(vidStats.device_name{1}),'FASTCAM SA4 model 500K-M1')
            stimStart = stimStart+round(3*frms_per_ms);
        else
            error('unknown camera')
        end
    end
    graphTable.stimStart(videoID) = stimStart;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%% determine departure trajectory
    if strcmp(assessTable.Fly_Detect_Accuracy{videoID},'Good')
        if strcmp(exptType,'Visual_stimulation')
            stim_azi = analysis_record.stimulus_azimuth{1};
        else
            stim_azi = deg2rad(vidStats.fly_detect_azimuth);
        end
    else
        stim_azi = NaN;
    end
    az_traj = analysis_record.departure_az_ele_rad{1}(1);
    ele_traj = analysis_record.departure_az_ele_rad{1}(2);
    r_traj = analysis_record.departure_az_ele_rad{1}(3);
    
    
    botTheta_filt = analysis_record.bot_points_and_thetas{1}(:,3);
    graphTable.rawFly_XYZT_atFrmOne(videoID,:) = {[analysis_record.bot_points_and_thetas{1}(1,1:2),...
        analysis_record.top_points_and_thetas{1}(1,2) botTheta_filt(1)]};
    botTheta_filt = filtfilt(d1,unwrap(botTheta_filt));
    jumpFrmCt = round(frms_per_ms*5);
    if stimStart <= trk_end
        fly_theta_at_stim_start = botTheta_filt(stimStart);%sets init theta to fly heading at stim start
    else
        fly_theta_at_stim_start = NaN;
    end
    flyLength = analysis_record.fly_length{1};
    graphTable.flyLength(videoID) = flyLength;
    jumpStart = jumpEnd-jumpFrmCt;
    jumpStart(jumpStart < 1) = 1;
    
    %%%% declare jump related variable that might not work out
    zeroFlyJump = [NaN NaN];       zeroFlyStimJump = NaN;
    ele_deprt = NaN;               rho_deprt = NaN;
    ele_jump = NaN;                rho_jump = NaN;
    zeroFlyDept = [NaN NaN];       rawjump = NaN;
    jump_theta = NaN;              stimStartFlyJump = NaN;
    if ~isnan(jumpEnd)
        postJump = jumpEnd+round(str2double(exptInfo.Record_Rate{runID})/1000*1.5);
        jump_theta = botTheta_filt(jumpStart);%sets init theta to fly heading before jump
        xyzDiffPre = zero_netXYZ(jumpEnd,:)-zero_netXYZ(jumpStart,:);
        [az_jump,ele_jump,rho_jump] = cart2sph(xyzDiffPre(1),-xyzDiffPre(2),-xyzDiffPre(3));
        uv_zeroFlyJump = [cos(az_jump-jump_theta) -sin(az_jump-jump_theta)].*rho_jump;
        uv_stimFlyJump = [cos(az_jump-fly_theta_at_stim_start) -sin(az_jump-fly_theta_at_stim_start)].*rho_jump;
        [theta,rho] = cart2pol(uv_zeroFlyJump(1),-uv_zeroFlyJump(2));
        [thetastim,~] = cart2pol(uv_stimFlyJump(1),-uv_stimFlyJump(2));
        zeroFlyJump = [theta,rho]; %Jump direction in reference to fly direction at Jump Start
        stimStartFlyJump = thetastim; %Jump direction in reference to fly direction at Stim Start
        rawjump = zeroFlyJump(1) + jump_theta;
        if postJump <= trk_end
            xyzDiffPost = zero_netXYZ(postJump,:)-zero_netXYZ(jumpEnd,:);
            %%%%% line below: z must be negative because tracking was done in image space
            [az_deprt,ele_deprt,rho_deprt] = cart2sph(xyzDiffPost(1),-xyzDiffPost(2),-xyzDiffPost(3));
            uv_zeroFlyDept = [cos(az_deprt-jump_theta) -sin(az_deprt-jump_theta)].*rho_deprt;
            theta = cart2pol(uv_zeroFlyDept(1),-uv_zeroFlyDept(2));
            zeroFlyDept = [theta,sqrt(sum(xyzDiffPost(1:2).^2))];
        end
        uv_zeroFlyStimJump = [cos(stim_azi-jump_theta) -sin(stim_azi-jump_theta)];
        zeroFlyStimJump = cart2pol(uv_zeroFlyStimJump(1),-uv_zeroFlyStimJump(2));
    end
    
    uv_zeroFlyDepart = [cos(az_traj-fly_theta_at_stim_start) -sin(az_traj-fly_theta_at_stim_start)].*r_traj;
    [theta,rho] = cart2pol(uv_zeroFlyDepart(1),-uv_zeroFlyDepart(2));
    zeroFlyTraj = [theta,rho];
    
    uv_zeroFlyStimInit = [cos(stim_azi-fly_theta_at_stim_start) -sin(stim_azi-fly_theta_at_stim_start)];
    zeroFlyStimInit = cart2pol(uv_zeroFlyStimInit(1),-uv_zeroFlyStimInit(2));
    
    uv_zeroFlyStimFrmOne = [cos(stim_azi-botTheta_filt(1)) -sin(stim_azi-botTheta_filt(1))];
    zeroFlyStimFrmOne = cart2pol(uv_zeroFlyStimFrmOne(1),-uv_zeroFlyStimFrmOne(2));
    
    [zeroFlyXY_theta,zeroFlyXY_rho] = cart2pol(zero_netXYZ(1:trk_end,1),-zero_netXYZ(1:trk_end,2));
    zeroFlyXY_theta = zeroFlyXY_theta-fly_theta_at_stim_start;
    zeroFlyBotTheta = (botTheta_filt(1:trk_end)-fly_theta_at_stim_start);
    
    %%% no 'flipping' if grating is used %%%
    stimInfo = exptInfo.Stimuli_Type{1};
    splitCell = strsplit(stimInfo,'_');
    if zeroFlyStimInit < 0 && isempty(strfind(splitCell{1},'grating'))
        zeroFlyXY_theta = zeroFlyXY_theta*(-1);
        zeroFlyStimInit = zeroFlyStimInit*(-1);
        zeroFlyStimFrmOne = zeroFlyStimFrmOne*(-1);
        zeroFlyTraj = zeroFlyTraj.*[-1 1];
        zeroFlyStimJump = zeroFlyStimJump*(-1);
        zeroFlyJump = zeroFlyJump.*[-1 1];
        stimStartFlyJump = stimStartFlyJump*(-1);
        zeroFlyDept = zeroFlyDept.*[-1 1];
        zeroFlyBotTheta = zeroFlyBotTheta*(-1);
        graphTable.flipBool(videoID) = true;
    end
    
    [zeroFlyX,zeroFlyY] = pol2cart(zeroFlyXY_theta,zeroFlyXY_rho);
    zeroFly_XY = [zeroFlyX(:),zeroFlyY(:)];
    zeroFly_XYZ = [zeroFly_XY zero_netXYZ(1:trk_end,3)];
    graphTable.zeroFly_XYZT_fac1000(videoID) = {int16([zeroFly_XYZ zeroFlyBotTheta]*1000)};
    
    %%%% Azimuth, x/y rho, elevation, 3-D rho
    graphTable.zeroFly_Trajectory(videoID,:) = {cat(2,zeroFlyTraj(1),...
        zeroFlyTraj(2),ele_traj,r_traj)};
    graphTable.zeroFly_Jump(videoID,:) = {cat(2,zeroFlyJump(1),...
        zeroFlyJump(2),ele_jump,rho_jump)};
    graphTable.zeroFly_Departure(videoID,:) = {cat(2,zeroFlyDept(1),...
        zeroFlyDept(2),ele_deprt,rho_deprt)};
    graphTable.zeroFly_StimAtStimStart(videoID) = zeroFlyStimInit;
    graphTable.zeroFly_StimAtJump(videoID) = zeroFlyStimJump;
    graphTable.zeroFly_StimAtFrmOne(videoID) = zeroFlyStimFrmOne;
    graphTable.rawFly_Jump(videoID) = rawjump;
    graphTable.jumpStart_theta(videoID) = jump_theta;
    graphTable.stimStart_flyTheta(videoID) = fly_theta_at_stim_start;
    graphTable.stimStart_jumpTheta(videoID) = stimStartFlyJump;
    graphTable.botTheta_filt(videoID) =  {botTheta_filt};
    graphTable.stim_azi(videoID) = stim_azi;
    
    %%% Lateral motion, longitudinal motion, and turning
    dataXYpos = zeroFly_XYZ(:,1:2);
    dataTpos = unwrap(zeroFlyBotTheta);
    [posT,posR] = cart2pol(dataXYpos(:,1),-dataXYpos(:,2));
    [relXpos,relYpos] = pol2cart(posT-dataTpos,posR);
    graphTable.relPosition_FB_LR_T_fac1000(videoID) = {int16([relXpos relYpos dataTpos]*1000)};
    
    % Add manual jump direction
    if strcmp(videoID,manJumpDirTable.Properties.RowNames)==0
        graphTable.manualJumpDir(videoID) = NaN;
        graphTable.manualJumpTheta(videoID) = NaN;
    else
        graphTable.manualJumpDir(videoID) = manJumpDirTable.Manual_Jump_Azi(videoID);
        graphTable.manualJumpTheta(videoID) = -manJumpDirTable.Leg_Push_Bot_View(videoID).phi + 2*pi;
    end
end


if saveTable
    save(graphTablePath,'graphTable')
end
