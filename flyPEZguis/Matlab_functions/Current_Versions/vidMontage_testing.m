function [frmFullD,all_markers,all_stimuli,test_data,vidCount] = vidMontage_testing(expIDlist,varargin)
%%%%% computer and directory variables and information
% exptIDlist = list of experiment ids to use
% stim_type = type of stimuli presented (loom or chrimsion)
% test_data = experiment ID classifier for expIDList, filtered to videos with good tracking
% logical_filter = logical index to show specific videos
% sort_order = order videos are plotted, default is random
% view_opt = top or bottem view of the video
% rotate_opt = should bottem view be rotated
% video_index = indexing variable for looping multiple videos
% Show_Tracked = logical flag to show center of mass movement
% Show_Stimuli = Logical flag to display stimuli location
% Show_Wall = Logical flag to display wall location
% Show_Grid = Logical flag to show grid overlay

frmFullD = [];
all_markers = [];
all_stimuli = [];
test_data = [];
vidCount = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets pathing directory, toggels between mac and pc
    op_sys = system_dependent('getos');
    if contains(op_sys,'Windows')
        archDir = [filesep filesep 'dm11' filesep 'cardlab'];
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data_path = [dm11Dir filesep 'Data_pez3000'];
    montDir = [dm11Dir filesep 'Montage_vid_test'];

    [~,localUserName] = dos('echo %USERNAME%');
    localUserName = localUserName(1:end-1);
    repositoryName = 'pezAnalysisRepository';
    repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
    subfun_dir = fullfile(repositoryDir,'pezProc_subfunctions');
    saved_var_dir = fullfile(repositoryDir,'pezProc_saved_variables');
    addpath(repositoryDir,subfun_dir,saved_var_dir)
    addpath(fullfile(repositoryDir,'Pez3000_Gui_folder','Matlab_functions','Support_Programs'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parse user inputs, if not provided sets defaults
    p = inputParser;

    addRequired(p,'exptIDlist');                        addOptional(p,'test_data',[]);
    %addOptional(p,'azi_off',22.5);                      %addOptional(p,'graph_logic',false);
    addOptional(p,'azi_off',180);
    addOptional(p,'graph_logic',true);
    
    addOptional(p,'frame_count',1:10:500);              addOptional(p,'Logic_Filter','none');    
    addOptional(p,'sort_order','none');                 addOptional(p,'view_opt','bottom');
    addOptional(p,'rotate_opt','rotate');               addOptional(p,'rotate_amt',270);
    addOptional(p,'video_index',1);
    
    addOptional(p,'Show_Center',true);                  addOptional(p,'Show_Stimuli',true);
    addOptional(p,'Show_Wall',true);                    addOptional(p,'Show_Border',true);
    
    addOptional(p,'Center_Size',8);                     addOptional(p,'Stimuli_Size',8);
    addOptional(p,'Center_Color','red');                addOptional(p,'Stimuli_Color','yellow');
    addOptional(p,'Border_Color','red');
        
    addOptional(p,'Download_Frames','All');             addOptional(p,'Download_Range',100);
    addOptional(p,'save_path','');                      addOptional(p,'filename','');            
    
    p.KeepUnmatched = true;
    parse(p,expIDlist,varargin{:});    
    
    exptID = p.Results.exptIDlist{1};
    sort_order = lower(p.Results.sort_order);
    logical_filter = p.Results.Logic_Filter;
    rotate_opt = lower(p.Results.rotate_opt);
    view_opt = lower(p.Results.view_opt);
    video_index = p.Results.video_index;
    test_data = p.Results.test_data;
    frame_count = p.Results.frame_count;
    Show_Wall = p.Results.Show_Wall;
    Show_Stimuli = p.Results.Show_Stimuli;
    azi_off = p.Results.azi_off;
    graph_logic = p.Results.graph_logic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets default variables
    maxFlies = 30;
    framesBeforeStim = (50*6);          framesAfterStim = (100*6)-1;
    labelCell = {'genotype'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% checks to see need to load data
    disp(exptID)    
    if isempty(test_data)
        test_data = get_id_list(exptID,azi_off,graph_logic);
    end
    if length(test_data) == 1
        [primary_stimuli,secondary_stimuli] = get_stim_info(test_data);    
    else
        [primary_stimuli,secondary_stimuli] = get_stim_info(test_data(1));
    end
        
    if contains(primary_stimuli,'Intensity') && contains(secondary_stimuli,'None') 
        stim_type = 'chrim';
    elseif contains(primary_stimuli,'Intensity') && contains(lower(secondary_stimuli),'loom') 
        stim_type = 'combo';
    elseif contains(primary_stimuli,'loom') && contains(secondary_stimuli,'None') 
        stim_type = 'loom';        
    elseif contains(primary_stimuli,'wall') && contains(lower(secondary_stimuli),'loom') 
        stim_type = 'loom';
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% filters video list
    usable_data = [vertcat(test_data.Complete_usuable_data);vertcat(test_data.Videos_Need_To_Work)];
    
    
    if ischar(logical_filter)
        logical_filter = true(height(usable_data),1);
    end
    usable_data = usable_data(logical_filter,:);
    if strcmp(p.Results.Logic_Filter,'jumpers_only_man')
        not_done_logic = cellfun(@(x) isempty(x), usable_data.frame_of_leg_push);
        missing_data = usable_data(not_done_logic,:).autoFrameOfTakeoff;
        missing_logic = cell2mat(usable_data(not_done_logic,:).jumpTest);
        missing_data(~missing_logic) = {NaN};
        usable_data(not_done_logic,:).frame_of_leg_push = missing_data;
        
        usable_data(cellfun(@(x) isempty(x), usable_data.frame_of_leg_push),:) = [];
        usable_data(cellfun(@(x) isnan(x), usable_data.frame_of_leg_push),:) = [];
    elseif strcmp(p.Results.Logic_Filter,'jumpers_only_auto')       
        usable_data = usable_data(cell2mat(usable_data.jumpTest) == 1,:);
    elseif strcmp(p.Results.Logic_Filter,'Centered_Flies')
        %condition 1: no rotation, filter for alignment
        roi_pos = cell2mat(cellfun(@(x,y) [x(1,1),x(3,1),x(1,2),x(2,2)],usable_data.Adjusted_ROI,'UniformOutput',false));
        fly_pos = cell2mat(cellfun(@(x,y) x(y,:), usable_data.bot_points_and_thetas,usable_data.Start_Frame,'UniformOutput',false));
        
        boundry = 60;
        offset = 832-384;
        fly_pos(:,2) = fly_pos(:,2) + offset;      
        center_x = (roi_pos(:,2) - roi_pos(:,1))/2 + roi_pos(:,1);
        center_y = (roi_pos(:,4) - roi_pos(:,3))/2 + roi_pos(:,3);
                
        
        x_off  = fly_pos(:,1) - center_x;
        y_off = fly_pos(:,2) - center_y;
        
        in_range_vids = abs(x_off) <= boundry & abs(y_off) <= boundry;
        usable_data = usable_data(in_range_vids,:);                
    end
    if strcmp(sort_order,'time_of_jump') && strcmp(p.Results.Logic_Filter,'jumpers_only_man')
        usable_data(cellfun(@(x) isempty(x), usable_data.frame_of_leg_push),:) = [];
        usable_data(cellfun(@(x) isnan(x), usable_data.frame_of_leg_push),:) = [];
    elseif strcmp(sort_order,'time_of_jump') && strcmp(p.Results.Logic_Filter,'jumpers_only_auto')
        usable_data = usable_data(cell2mat(usable_data.jumpTest) == 1,:);
    end
    masterList = usable_data.Properties.RowNames;
    vidsAvailable = length(masterList);    
    if vidsAvailable == 0       %no videos to make so exit function
        return
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% sorts and filters list to size of maxFlies    
    parent_info = vertcat(test_data.parsed_data);
         
    if strcmp(sort_order,'random')
        vidRefs = randperm(numel(masterList));
        vidList = masterList(vidRefs(1:vidsAvailable));
        vidCount = numel(vidList);
%         if vidCount > maxFlies
%             vidList = vidList(randperm(numel(vidList),maxFlies));
%             vidCount = maxFlies;
%         end        
    elseif strcmp(sort_order,'time_of_jump') && strcmp(p.Results.Logic_Filter,'jumpers_only_man')
        sort_value = cellfun(@(x,y) (x-y), usable_data.frame_of_take_off,usable_data.Start_Frame);
        [~,vidRefs] = sort(sort_value);
        vidList = masterList(vidRefs);
        vidCount = numel(vidList);
        usable_data = usable_data(vidRefs,:);
    elseif strcmp(sort_order,'time_of_jump') && strcmp(p.Results.Logic_Filter,'jumpers_only_auto')
        sort_value = cellfun(@(x,y) (x-y), usable_data.autoFrameOfTakeoff,usable_data.Start_Frame);
        [~,vidRefs] = sort(sort_value);
        vidList = masterList(vidRefs);
        vidCount = numel(vidList);
        usable_data = usable_data(vidRefs,:);
    elseif strcmp(sort_order,'none')
        vidRefs = 1:1:(numel(masterList));
        vidList = masterList(vidRefs);
        vidCount = numel(vidList);
    end
    
    index_counts = ((video_index-1)*30 +1) :(video_index*30);
    
    if max(index_counts) > maxFlies && video_index == 1
        index_counts = ((video_index-1)*30 +1) : maxFlies;
    elseif max(index_counts) >  vidCount
        index_counts = ((video_index-1)*30 +1) :  vidCount;        
    end
    vidList = vidList(index_counts);
    vidCount = numel(vidList);
    
    [~,sort_idx] = sort(cell2mat(usable_data(vidList,:).Start_Frame));
    vidList = vidList(sort_idx);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets parent strings, and save pathing
    parent_string = cellfun(@(x,y) sprintf('%s_%s',x,y),parent_info.ParentA_name,parent_info.ParentB_name,'UniformOutput',false);
    parent_string = parent_string{1};
    full_string_list = cellfun(@(x,y,z) sprintf('%s_%s_%s',x,y,z),parent_info.Stimuli_Type,parent_info.Elevation,parent_info.Azimuth,'UniformOutput',false);
    full_string_list = full_string_list{1};
        
    video_stim_length = cellfun(@(x) str2double(x(strfind(x,'End')+3:strfind(x,'End')+4)),usable_data.Stimuli_Used);
    if strcmp(view_opt,'bottom') && strcmp(rotate_opt,'rotate')
        destName = [full_string_list '_montage_' sprintf('%02.f_',video_index) view_opt '_aligned_view.mp4'];
    else
        destName = [full_string_list '_montage_' sprintf('%02.f_',video_index) view_opt '_view.mp4'];
    end
    if ~exist([montDir filesep parent_string],'dir')
        mkdir([montDir filesep parent_string])
    end
    destPath = fullfile(montDir,parent_string,destName);   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% loops over each video and creates the framerefmatrix
    vidObjCutrate = cell(vidCount,1);
    vidObjSupplement = cell(vidCount,1);
    frameReferenceMesh = cell(vidCount,1);
    writeRefs = cell(vidCount,1);
    frmBounds = cell(vidCount,1);
    jumpBounds = cell(vidCount,1);
    flyPosX = cell(vidCount,1);
    flyPosY = cell(vidCount,1);
    for iterM = 1:vidCount
        videoID = vidList{iterM};
        
        frameRefcutrate = usable_data.cutrate10th_frame_reference{videoID};
        frameReffullrate = usable_data.supplement_frame_reference{videoID};
        
        Y = (1:numel(frameRefcutrate));
        xi = (1:numel(frameRefcutrate)*10);
        yi = repmat(Y,10,1);
        yi = yi(:);
        [~,xSuppl] = ismember(frameReffullrate,xi);
        objRefVec = ones(1,numel(frameRefcutrate)*10);
        objRefVec(xSuppl) = 2;
        yi(xSuppl) = (1:numel(frameReffullrate));
        writeRefs{iterM} = xi(:)';
        frameReferenceMesh{iterM} = [yi(:)';objRefVec(:)'];
        
        stimStart = usable_data.Start_Frame{videoID};
        if strcmpi(stim_type,'chrim')
            stimLength = video_stim_length(iterM)*6;      %50 ms pulse
        else
            stimLength = unique(cell2mat(usable_data.Stimuli_Duration));      %frames in looming stimuli
            if length(stimLength) > 1
                stimLength = max(stimLength);
            end
            stimLength =  stimLength + (50*6);      %holds last frame for 50 milliseconds not part of duration            
        end
        
        try
            nidaq_data = usable_data(videoID,:).visual_stimulus_info{1}.nidaq_data;     %check for looming nidaq
        catch
            nidaq_data = usable_data(videoID,:).photoactivation_info{1}.nidaq_data;     %if not found use chrim nidaq
        end
        stimFrames = (stimStart-(framesBeforeStim):(stimStart+stimLength+framesAfterStim));

        stimFrames(stimFrames < 1) = 1;
        frameCt = usable_data.frame_count(videoID);
        rateFactor = double(usable_data.record_rate(videoID))/1000;
%        stimFrames(stimFrames > frameCt) = frameCt;
%         if strcmp(sort_order,'time_of_jump')    %100ms prior to leg, 50 ms after leg push
%             leg_frame = usable_data.frame_of_leg_push{iterM};
%             stimFrames = (leg_frame-(100*6)):((leg_frame -1)+ (50*6));
%         end
        if ~isempty(usable_data(videoID,:).frame_of_leg_push{1})
            jumpRange = (usable_data(videoID,:).frame_of_leg_push{1} - str2double(p.Results.Download_Range)) : (usable_data(videoID,:).frame_of_leg_push{1} + 200);
            jumpRange = unique(jumpRange);
        else
            jumpRange = 0;
        end
        stimFrames(stimFrames > length(nidaq_data)) = [];   %remove frames if video already ended        
        
        frmBounds{iterM} = stimFrames;      %every frame of video        
        jumpBounds{iterM} = jumpRange;      %every frame of video        
        
 
        
        top_data = usable_data(videoID,:).top_points_and_thetas{1};         %fly center of mass top view
        bottom_data = usable_data(videoID,:).bot_points_and_thetas{1};      %fly center of mass bot view
        if strcmp(view_opt,'top')
            flyPosX{iterM} = top_data(stimStart,1);
            flyPosY{iterM} = top_data(stimStart,2);            
        elseif  strcmp(view_opt,'bottom')
            flyPosX{iterM} = bottom_data(stimStart,1);
            flyPosY{iterM} = bottom_data(stimStart,2);
        end
                
        vid_name = videoID;
        vid_date = vid_name(16:23);
        vid_run = vid_name(1:23);        
        fullPath_parital = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,[videoID,'.mp4']);
        fullPath_supplement = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,'highSpeedSupplement',[videoID,'_supplement.mp4']);
        
        matlab.video.read.UseHardwareAcceleration('off');
        try
            vidObjSupplement{iterM} = VideoReader(fullPath_supplement); %#ok<*TNMLP>
            vidObjCutrate{iterM} = VideoReader(fullPath_parital);
        catch
            warning('error?')
        end  
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% creates stimuli/chrim traces to display
    try
        %montFrmCt = numel(stimFrames);
        montFrmCt = stimLength+framesAfterStim+framesBeforeStim;    %max number of frames to show
        %not all videos will reach this number
    catch
        warning('why error?')
    end
    photoStimName = usable_data.Stimuli_Used{videoID};
    if contains(photoStimName,'intensity')
        Show_Stimuli = false;       %dont show stimuli for chrim data
        [video_pulse,maxInt] = photoactivationTraceMaker(photoStimName,exptID,montFrmCt,framesBeforeStim,rateFactor);
    elseif contains(photoStimName,'offaxis')
        [video_pulse,maxInt] = offaxisTraceMaker(framesBeforeStim,stimLength,montFrmCt);
    else
        [video_pulse,maxInt] = loomTraceMaker(photoStimName,montFrmCt,framesBeforeStim);
    end
    if ~contains(photoStimName,'wall')      %cant show a wall if none exists
        Show_Wall = false;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% sets label part of image
    montDims = [192*10 (192*5)];
    baseFrame = uint8(zeros(fliplr(montDims)));
    
    textBase = baseFrame(1:100,:);
    parsed_data = vertcat(test_data.parsed_data);
    Parent_A = unique(parsed_data.ParentA_name);
    
    Parent_B = convert_background_labels(unique(parsed_data.ParentB_name));
    food_used = parsed_data.Food_Type{1};
    infoA = cellfun(@(x,y) sprintf('%s X %s',x,y),Parent_A,Parent_B,'UniformOutput',false);
    if strcmpi(stim_type,'chrim')
    labelOps = {[labelCell{1} ': ']
        strtrim(infoA{1})
        'exptID: '
        exptID
        'Food_Used: '
        food_used
        'light intensity:       uW/mm2'%9 spaces
        'time lapsed:       ms'%9 spaces
        'current frame: '};
    else
       labelOps = {[labelCell{1} ': ']
        strtrim(infoA{1})
        'exptID: '
        exptID
        'Food_Used: '
        food_used
        'Stimuli Size:       degrees'%9 spaces
        'time lapsed:       ms'%9 spaces
        'current frame: '};
    end
    fontSz = 15;
    labelPos = {[0.05 0.4]
        [0.13 0.4]
        [0.75 0.4]
        [0.85 0.4]
        [0.48 0.4]
        [0.55 0.4]
        [0.05 0.9]
        [0.40 0.9]
        [0.75 0.9]};
    labelCt = numel(labelOps);
    for iterL = 1:labelCt
        textBase = textN2im_v2(textBase,labelOps(iterL),fontSz,...
            labelPos{iterL},'left');
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets stimuli display part of the image
    montDims = [192*10 (192*1)];    
    graphBase = uint8(zeros(fliplr(montDims)));
        
    graphBaseT = graphBase;
%    video_pulse = video_pulse(1:1:length(stimFrames));
    
    baseXa = round(0.13*montDims(1));    
    baseXb = round(0.93*montDims(1));
    baseYa = round(0.2*montDims(2));
    baseYb = round(0.7*montDims(2));

    xOutput = (1:baseXb-baseXa)+baseXa;
    xNput = round(linspace(baseXa,baseXb,numel(video_pulse)));

    yNput = (video_pulse-min(video_pulse))/range(video_pulse);
    yNput = abs(yNput-1)*(baseYb-baseYa)+baseYa;
    [~,NputRefs] = unique(xNput);
    yOutput = interp1(xNput(NputRefs),yNput(NputRefs),xOutput,'linear','extrap');
    yOutput = round(yOutput);

    graphBase(sub2ind(size(graphBase),yOutput,xOutput)) = 200;
    graphBase(sub2ind(size(graphBase),yOutput+1,xOutput)) = 200;
    graphBase(sub2ind(size(graphBase),yOutput+2,xOutput)) = 200;
    graphBase(sub2ind(size(graphBase),yOutput-1,xOutput)) = 200;
    graphBase(sub2ind(size(graphBase),yOutput-2,xOutput)) = 200;
    
    if contains(photoStimName,'intensity')
        labelOps = {'0'
            num2str(maxInt)
            %'1'
            (num2str(-1*round(framesBeforeStim/6)))
            '0'
            num2str(round(stimLength/6))
            num2str(round(montFrmCt/6 + -1*round(framesBeforeStim/6)))
            '% power'
            'Milliseconds'};
    else
                labelOps = {'0'
            num2str(maxInt)
            %'1'
            (num2str(-1*round(framesBeforeStim/6)))
            '0'
            num2str(round(stimLength/6)-50)
            num2str(round(stimLength/6))
            num2str(round(montFrmCt/6 + -1*round(framesBeforeStim/6)))
            'Stimuli Size'
            'Milliseconds'};
    end
    
    graph_fontSz = 20;
    start_of_trace = xOutput(1);
    start_of_stim = xOutput(find(yOutput < yOutput(1),1,'first'));
    light_on_pulse = yOutput((start_of_stim-start_of_trace)+1:end);
    end_of_stim = xOutput((find(light_on_pulse  > light_on_pulse (1),1,'first')) + start_of_stim - start_of_trace);
    labelPos = {[baseXa/montDims(1)-0.02 baseYb/montDims(2)+0.05]
        [baseXa/montDims(1)-0.02 baseYa/montDims(2)+0.05]
        %[baseXa/montDims(1)+0.01 baseYb/montDims(2)+0.2]
        [(start_of_trace-25)/montDims(1) baseYb/montDims(2)+0.2]             %start of trace
        [(start_of_stim-5)/montDims(1)  baseYb/montDims(2)+0.2]
        [(end_of_stim-115)/montDims(1) baseYb/montDims(2)+0.2]
        [(end_of_stim+5)/montDims(1) baseYb/montDims(2)+0.2]
        [baseXb/montDims(1) baseYb/montDims(2)+0.2]
        [baseXa/montDims(1)-0.02 mean([baseYa/montDims(2)+0.05,baseYb/montDims(2)+0.05])]
        [mean([baseXa/montDims(1)+0.01,baseXb/montDims(1)]) baseYb/montDims(2)+0.2]};
    labelCt = numel(labelOps);
    for iterL = 1:labelCt
        %graphBaseT = textN2im_v2(graphBaseT,labelOps(iterL),graph_fontSz,labelPos{iterL},'right');
        if ismember(iterL,[1,2,7])      %photo info
             graphBaseT = textN2im_v2(graphBaseT,labelOps(iterL),graph_fontSz,labelPos{iterL},'right');
        else
            graphBaseT = textN2im_v2(graphBaseT,labelOps(iterL),graph_fontSz,labelPos{iterL},'center');
        end
    end
    graphBaseT = graphBaseT*0.8;
    graphBase = cat(3,max(graphBase,graphBaseT),graphBaseT,graphBaseT);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  opens the file to save video to
    if length(frame_count) > 1
        writeObj = VideoWriter(destPath,'MPEG-4');
        writeObj.FrameRate = 10;    %slow video playback down to 10 frames per second  (default is 30)
        open(writeObj)
    end
    vidCount= sum(cellfun(@(x) ~isempty(x),vidObjCutrate));
    
    if length(frame_count) > 1
        frame_rate = p.Results.Download_Range;
        if iscell(frame_rate)
            frame_rate = str2double(frame_rate);
        end
        if ischar(frame_rate)
            frame_rate = str2double(frame_rate);
        end
        
        if strcmpi(p.Results.Download_Frames,'all')
            cutRateOps = 1:frame_rate:montFrmCt;       %every 10 frames
        else            
            cutRateOps = 1:5:(str2double(p.Results.Download_Range) + 201);
        end
    else
        cutRateOps = 301;                    %only display single frame
    end
    
    all_markers = [];                       
    all_stimuli = cell(vidCount,1);         all_wall_pos = cell(vidCount,1);
    for iterF = cutRateOps
        frmFullA = baseFrame;               frmFullB = baseFrame;
        border_color = cell(length(vidCount),1);
        for iterM = 1:vidCount
            tic
            tracking_done = 0;
            videoID = vidList{iterM};
            try
                if strcmp(p.Results.Download_Frames,'Jumpers')
                    frmRef = jumpBounds{iterM}(iterF);
                else
                    frmRef = frmBounds{iterM}(iterF);
                end
                border_color(iterM) = {'black'};
            catch
                frmRef = max(frmBounds{iterM});
%                warning('frame of of range')
                border_color(iterM) = {'red'};
            end
            frameRead = frameReferenceMesh{iterM}(1,(frmRef));
            readObjRef = frameReferenceMesh{iterM}(2,(frmRef));
            
            if readObjRef == 1
                frmA = read(vidObjCutrate{iterM},frameRead);
            else
                frmA = read(vidObjSupplement{iterM},frameRead);
            end

            %%
            tI = log(double(frmA)+15);
            frmAdj = uint8(255*(tI/log(265)-log(15)/log(265)));
            [~,frm_graymap] = gray2ind(frmAdj,256);
            tol = [0 0.9999];
            gammaAdj = 0.75;
            lowhigh_in = stretchlim(frmAdj,tol);
            lowhigh_in(1) = 0.01;
            frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],gammaAdj);
            frm_remap = uint8(frm_remap(:,1).*255);
            frmA = intlut(frmAdj,frm_remap);
            
            %frmA = frmA(:,:,1);            
            
            vidWidth = vidObjCutrate{iterM}.Width;
            vidHeight = vidObjCutrate{iterM}.Height;
            offset = vidHeight - vidWidth;

            top_data = usable_data(videoID,:).top_points_and_thetas{1};
            try
                top_data = top_data(frmRef,1:2);
                %tracking_done = 0;
            catch
                tracking_done = 1;
            end
                        
%            stim_pos = frmBounds{iterM}(1) + framesBeforeStim;
            stim_pos = usable_data(videoID,:).Start_Frame{1};
%            x_center = round(flyPosX{iterM}(stim_pos));            
            x_center = round(flyPosX{iterM});
            rotate_amount = 0;
            rotate_amt = p.Results.rotate_amt;
            if strcmp(view_opt,'top')
                Show_Wall = false;
                all_wall_pos{iterM} = [{0},{0}];
                if flyPosY{iterM} > (192/2)
                    if tracking_done == 0
                        top_data(2) = (192/2) -(flyPosY{iterM} - top_data(2));
                    end
                    frmA(((round(flyPosY{iterM})+(192/2)+1):end),:,:) = [];
                    frmA(1:(round(flyPosY{iterM}) - (192/2)),:,:) = [];
                else
                    frmA = [zeros(192-round(flyPosY{iterM}),size(frmA,2),size(frmA,3));frmA];    
                end 
                if x_center <= 192/2
                   frmA =  frmA(:,1:x_center+(192/2),:);
                   zero_pad = zeros(size(frmA,1),192-size(frmA,2),size(frmA,3));
                   frmA = [frmA,zero_pad];
                   %need padding
                elseif  x_center > (size(frmA,2) - 192/2)
                    frmA = frmA(:,(x_center - (192/2)) : end,:);
                    zero_pad = zeros(size(frmA,1),192-size(frmA,2),size(frmA,3));
                    frmA = [zero_pad,frmA];
                else
                    try
                        frmA = frmA(:,(x_center - (192/2)) : (x_center-1 + (192/2)),:);
                    catch
                        warning('error')
                    end
                end
                top_data(1) = (top_data(1) - x_center)  +(192/2);
                marker_data = round(top_data);
                
                
                %frmA = insertMarker(frmA,[round(top_data(2))-192 round(top_data(1))],'o','color',rgb('red'),'size',50);                
            elseif strcmp(view_opt,'bottom') && strcmp(rotate_opt,'none')
                bottom_data = usable_data(videoID,:).bot_points_and_thetas{1};
                if tracking_done == 0
                    bot_data = bottom_data(frmRef,1:2);
                    bot_data(2) = offset + bot_data(2);
                end

                bot_y_pos = round(bottom_data(stim_pos,2));                
                bot_y_pos = offset + bot_y_pos;
                                
                if bot_y_pos +(192/2) > 832      %cuts off at bottom
                    frmA(1: (bot_y_pos-(192/2)),:,:) = [];
                    zero_pad = zeros(192-size(frmA,1),size(frmA,2),size(frmA,3));
                    frmA = [zero_pad;frmA];    
                else
                    frmA = frmA((bot_y_pos-(192/2)) : (bot_y_pos+(190/2)) ,:,:);
                end
                bot_data(2) = 192/2+(bot_data(2) - bot_y_pos);                
            elseif strcmp(view_opt,'bottom') && strcmp(rotate_opt,'rotate')
                bottom_data = usable_data(videoID,:).bot_points_and_thetas{1};
                if tracking_done == 0
                    bot_data = bottom_data(frmRef,1:2);
                    bot_data(2) = offset + bot_data(2);
                end

                bot_y_pos = round(bottom_data(stim_pos,2));
                bot_y_pos = offset + bot_y_pos;                
                
%                rotate_amount = 270-(bottom_data(stim_pos,3).*180/pi);
                rotate_amount = rotate_amt-(bottom_data(stim_pos,3).*180/pi);
                
                if bot_y_pos + 250 > 832      %cuts off at bottom
                    frmA = frmA((bot_y_pos - 250) : end,:,:);
                    zero_pad = zeros(501-size(frmA,1),size(frmA,2),size(frmA,3));
                    frmA = [frmA;zero_pad];      
                    if tracking_done == 0
                        bot_data(2) = 250-(bot_y_pos-bot_data(2));
                    end
                else
                    frmA = frmA((bot_y_pos-250) : (bot_y_pos+250) ,:,:);
                    if tracking_done == 0
                        bot_data(2) = bot_data(2)-(bot_y_pos-250);
                    end
                end                
            end
            stimuli_pos = (usable_data(videoID,:).VidStat_Stim_Azi + 2*pi) .* 180/pi + rotate_amount;

            stim_range = stimuli_pos.*pi/180;
            [stim_x,stim_y] = pol2cart(stim_range,172/2);     %-96 to 96 circle
            stim_y = stim_y *-1;
            stim_x = stim_x+(192/2);        %translate into 0 - 192
            stim_y = stim_y+(192/2);        %translate into 0 - 192


            all_stimuli{iterM} = [{stim_x},{stim_y}];

            if strcmp(view_opt,'bottom') && strcmp(rotate_opt,'rotate')
                if x_center - 250 <= 0
                    zero_pad = zeros(size(frmA,1),250-x_center,size(frmA,3));
                    if tracking_done == 0
                        bot_data(1) = 250-x_center+bot_data(1);
                    end
                    frmA = [zero_pad,frmA];
                    if size(frmA,2) < 501
                        zero_pad = zeros(size(frmA,1),501-size(frmA,2),size(frmA,3));
                        frmA = [frmA,zero_pad];
                    else
                        frmA(:,502:end,:) = [];
                    end
                else
                    frmA(:,1:(x_center - 249),:) = [];
                    if tracking_done == 0
                        bot_data(1) = bot_data(1) - (x_center - 249);
                    end
                    zero_pad = zeros(size(frmA,1),501-size(frmA,2),size(frmA,3));
                    frmA = [frmA,zero_pad];
                end
                if Show_Wall == true
                    wall_width_loc = get_wall_pos(photoStimName);
                    wall_width_loc = str2double(wall_width_loc);
                    % switch 180 and 0 for wall positions
                    if wall_width_loc == 0
                        wall_width_loc = 180;
                    elseif wall_width_loc == 180
                        wall_width_loc = 0;
                    end
                    switch wall_width_loc
                        case 0
                            wall_y = ((250-15):(250+15))';
                            wall_x = ones(length(wall_y),1)*(501-20);
                        case 270
                            wall_x = ((250-15):(250+15))';
                            wall_y = ones(length(wall_x),1)*(501-20);
                        case 180
                            wall_y = ((250-15):(250-15))';
                            wall_x = ones(length(wall_y),1)*20;
                        case 90
                            wall_x = ((250-15):(250+15))';
                            wall_y = ones(length(wall_x),1)*20;
                    end                     
                    rot_wall_data = rotation([wall_x-251 wall_y-251],[0 0],-rotate_amount,'degree');
                end                
                
                frmA_rot = imrotate(frmA,rotate_amount);
                rot_size = round(size(frmA_rot)/2);
                frmA = frmA_rot((rot_size(1)-(192/2)):((rot_size(1)+(192/2))-1),(rot_size(1)-(192/2)):((rot_size(1)+(192/2))-1),:);                
                if tracking_done == 0
                    rot_bot_data = rotation(bot_data-251,[0 0],-rotate_amount,'degree');

                    
                    rot_bot_data = rot_bot_data + rot_size(1);
                    rot_bot_data(1) = rot_bot_data(1) - (rot_size(1)-(192/2));
                    rot_bot_data(2) = rot_bot_data(2) - (rot_size(1)-(192/2));
                    
                    marker_data = rot_bot_data;
                end
                if Show_Wall == true
                    rot_wall_data = rot_wall_data + rot_size(1);
                    rot_wall_data(:,1) = rot_wall_data(:,1) - (rot_size(1)-(192/2));
                    rot_wall_data(:,2) = rot_wall_data(:,2) - (rot_size(1)-(192/2));
                    all_wall_pos{iterM} = [{rot_wall_data(:,1)},{rot_wall_data(:,2)}];
                else
                    all_wall_pos{iterM} = [{0},{0}];
                end
            elseif strcmp(view_opt,'bottom') && strcmp(rotate_opt,'none')
                marker_data = bot_data;
                if x_center - (192/2) <= 0
                    frmA = frmA(:,1:(x_center+(192/2)),:);
                    frmA = [zeros(size(frmA,1),192-size(frmA,2),size(frmA,3)),frmA]; %#ok<*AGROW>
                elseif x_center + (192/2) > 384
                    frmA = frmA(:,(x_center-(192/2):end),:);
                    frmA = [frmA,zeros(size(frmA,1),192-size(frmA,2),size(frmA,3))];
                    if tracking_done == 0
                        marker_data(1) = marker_data(1) - (x_center-(192/2));
                    end
                else
                    frmA = frmA(:,(x_center-(192/2)):(x_center+(192/2)),:);
                    if tracking_done == 0
                        marker_data(1) = marker_data(1) - (x_center-(192/2));                        
                    end
                end
                if Show_Wall == true
                    wall_width_loc = get_wall_pos(photoStimName);
                    wall_width_loc = str2double(wall_width_loc);
                    % switch 180 and 0 for wall positions
                    if wall_width_loc == 0
                        wall_width_loc = 180;
                    elseif wall_width_loc == 180
                        wall_width_loc = 0;
                    end
                    switch wall_width_loc
                        case 0
                            wall_y = ((96-15):(96+15))';
                            wall_x = ones(length(wall_y),1)*(192-20);                            
                        case 270
                            wall_x = ((96-15):(96+15))';
                            wall_y = ones(length(wall_x),1)*(192-20);
                        case 180
                            wall_y = ((96-15):(96+15))';
                            wall_x = ones(length(wall_y),1)*20;
                        case 90
                            wall_x = ((96-15):(96+15))';
                            wall_y = ones(length(wall_x),1)*20;
                    end                    
                    all_wall_pos{iterM} = [{wall_x},{wall_y}];
                else
                    all_wall_pos{iterM} = [{0},{0}];
                end
            end
            dim_test = size(frmA);
            if dim_test(2) > 192
                frmA(:,end,:) = [];
            end
            if tracking_done == 1 && usable_data.jumpTest{iterM} == 1
                frmA = uint8(zeros(192,192,3));
            elseif tracking_done == 1
%                warning('fly lost tracking but stays');
            end
            
            x_pos = mod(iterM,10);
            y_pos = (floor((iterM)/10));
            if x_pos == 0
                y_pos = y_pos - 1;
                x_pos = 10;
            end
            
%            frmA = insertMarker(frmA,[round(marker_data(1)) round(marker_data(2))],'o','size',5,'color','red');
            
            try
                frmFullA(((192*(y_pos))+1):(192*(y_pos+1)),((192*(x_pos-1))+1):((192*(x_pos)))) = frmA(:,:,1);
                all_stimuli{iterM}{1} = all_stimuli{iterM}{1} + (192*(x_pos-1));
                all_stimuli{iterM}{2} = all_stimuli{iterM}{2} + (192*(y_pos));
                
                all_wall_pos{iterM}{1} = all_wall_pos{iterM}{1} + (192*(x_pos-1));
                all_wall_pos{iterM}{2} = all_wall_pos{iterM}{2} + (192*(y_pos));
                
                
                if tracking_done == 0
                    marker_data(1) = (192*(x_pos-1)) + marker_data(1);       marker_data(2) = (192*(y_pos)) + marker_data(2);
                end
            catch
                warning('mistake')
            end
            if tracking_done == 0
                all_markers = [all_markers;round(marker_data)];            
            end
%            all_tracking_center
%            all_tracking_start_pt
            %frmFullA(yRefA:yRefB,xRefA:xRefB) = frmA;            
            frmFullB = max(frmFullA,frmFullB);
            if iterF == min(cutRateOps)
                org_img = frmFullB;
            end
        end
        %%
        formatSa = ['%0' num2str(numel(num2str(round(montFrmCt/rateFactor)))) 's'];
        formatSb = ['%0' num2str(numel(num2str(montFrmCt))) 's'];
        labelOps = {sprintf('%04s',num2str(round(video_pulse(iterF))))
            sprintf(formatSa,num2str(round(iterF/rateFactor)))
            sprintf(formatSb,num2str(iterF))};
%        labelPos = {[0.23 0.9],      [0.565 0.9],         [0.85 0.9]};
        labelPos = {[0.175 0.9],      [0.510 0.9],         [0.90 0.9]};
        textFrm = textBase;
        kern = 0.5;
        for iterL = 1:3
            textFrm = textN2im_v2(textFrm,labelOps(iterL),fontSz,...
                labelPos{iterL},'right',kern);
        end

        frmFullC = [textFrm*0.8;frmFullB];        frmFullC(end-1:end,:) = 100;        frmFullC((1060-192):end,:,:) = []; 
        frmFullC = repmat(frmFullC,[1 1 3]);
        
        org_frame = [textFrm*0.8;org_img];        org_frame(end-1:end,:) = 100;       org_frame((1060-192):end,:,:) = []; 
        org_frame = repmat(org_frame,[1 1 3]);
        frmFullC(:,:,2) = frmFullC(:,:,2) + (org_frame(:,:,2) - frmFullC(:,:,2)) .* 0.5;     %cut the green brightness in half
        
        %frmFullD = [repmat(frmFullC,[1 1 3]);graphBase];
        frmFullD = [frmFullC;graphBase];
        
        frmFullD(baseYa+size(frmFullC,1):baseYb+size(frmFullC,1),xNput(iterF),:) = 235;
        frmFullD(baseYa+size(frmFullC,1):baseYb+size(frmFullC,1),xNput(iterF)+1,:) = 235;
        

        if p.Results.Show_Center == true
            frmFullD = insertMarker(frmFullD,[all_markers(:,1) all_markers(:,2)+100],'o','size',p.Results.Center_Size,'color',p.Results.Center_Color);       %need to offset y_cord by size ot textfrm (100)
        end
        for iterM = 1:length(all_stimuli)
            
            x_pos = mod(iterM,10);
            y_pos = (floor((iterM)/10));
            if x_pos == 0
                y_pos = y_pos - 1;
                x_pos = 10;
            end

            if Show_Stimuli == true
                frmFullD = insertMarker(frmFullD,[all_stimuli{iterM}{1}' all_stimuli{iterM}{2}'+100],'o','size',p.Results.Stimuli_Size,'color',p.Results.Stimuli_Color);       %need to offset y_cord by size ot textfrm (100)
            end
            
            frmFullD = insertMarker(frmFullD,[185+192*(x_pos-1) 75+190+192*(y_pos)],'s','size',3,'color',border_color{iterM});       %need to offset y_cord by size ot textfrm (100)
            if p.Results.Show_Border == true
%                 frmFullD = insertShape(frmFullD, 'line', [192*(x_pos-1) 100+192*(y_pos) 192*(x_pos) 100+192*(y_pos)],'LineWidth',1,'color',p.Results.Border_Color);
%                 frmFullD = insertShape(frmFullD, 'line', [192*(x_pos-1) 100+192*(y_pos+1)   192*(x_pos) 100+192*(y_pos+1)],'LineWidth',1,'color',p.Results.Border_Color);
%             
%                 frmFullD = insertShape(frmFullD, 'line', [0+192*(x_pos-1)  100+192*(y_pos) 0+192*(x_pos-1)  100+192*(y_pos+1)],'LineWidth',2,'color',p.Results.Border_Color);
%                 frmFullD = insertShape(frmFullD, 'line', [192*(x_pos)  100+192*(y_pos) 192*(x_pos)  100+192*(y_pos+1)],'LineWidth',2,'color',p.Results.Border_Color);
                
                frmFullD = insertShape(frmFullD, 'line', [192*(x_pos-1) 100+192*(y_pos) 192*(x_pos) 100+192*(y_pos)],'LineWidth',1,'color',border_color{iterM});
                frmFullD = insertShape(frmFullD, 'line', [192*(x_pos-1) 100+192*(y_pos+1)   192*(x_pos) 100+192*(y_pos+1)],'LineWidth',1,'color',border_color{iterM});
            
                frmFullD = insertShape(frmFullD, 'line', [0+192*(x_pos-1)  100+192*(y_pos) 0+192*(x_pos-1)  100+192*(y_pos+1)],'LineWidth',2,'color',border_color{iterM});
                frmFullD = insertShape(frmFullD, 'line', [192*(x_pos)  100+192*(y_pos) 192*(x_pos)  100+192*(y_pos+1)],'LineWidth',2,'color',border_color{iterM});                
            end
            
            
            if Show_Wall == true
                wall_min_x = min(all_wall_pos{iterM}{1});                   wall_max_x = max(all_wall_pos{iterM}{1});
                wall_min_y = min(all_wall_pos{iterM}{2})+100;               wall_max_y = max(all_wall_pos{iterM}{2})+100;
                
                if wall_max_y > 100+192*(y_pos+1)
                    all_wall_pos{iterM}{2} = (all_wall_pos{iterM}{2}+100) - ((wall_max_y - (100+192*(y_pos+1)))+20);
                elseif wall_min_y < 100+192*(y_pos)
                    all_wall_pos{iterM}{2} = (all_wall_pos{iterM}{2}+100) + ((100+192*(y_pos) -  wall_min_y)+20);
                else
                    all_wall_pos{iterM}{2} = (all_wall_pos{iterM}{2}+100);
                end    
                if wall_max_x >  192*(x_pos)
                     all_wall_pos{iterM}{1} = (all_wall_pos{iterM}{1}) - ((wall_max_x - 192*(x_pos))+20);
                elseif wall_min_x < 192*(x_pos-1)
                    all_wall_pos{iterM}{1} = (all_wall_pos{iterM}{1}) + (192*(x_pos-1)-wall_min_x)+20;
                end                                
                frmFullD = insertShape(frmFullD, 'line', [all_wall_pos{iterM}{1}(1) all_wall_pos{iterM}{2}(1) all_wall_pos{iterM}{1}(end) all_wall_pos{iterM}{2}(end)],'LineWidth',1,'color','magenta');
            end               
        end
        if frame_count == 1
        else
            try
                fprintf('Writting frame %5.0f out of %5.0f took %4.4f\n',iterF,max(cutRateOps),toc);
                writeVideo(writeObj,frmFullD)
                clear frmA frmFullA frmFullB frmFullC
            catch
                warning('why')
            end
        end
    end
    if length(frame_count) > 1
        close(writeObj)
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [primary_stimuli,secondary_stimuli] = get_stim_info(sample_data)
    chrim_logic = cellfun(@(x) contains(x,'None'),sample_data.parsed_data.Stimuli_Type);
    stimuli_used = sample_data.parsed_data.Stimuli_Type;
    stimuli_used(chrim_logic) = cellfun(@(y) y{1}, sample_data.parsed_data(chrim_logic,:).Photo_Activation,'UniformOutput',false);
    sample_data.parsed_data.Stimuli_Type = stimuli_used;    
    
    [primary_stimuli,secondary_stimuli] = get_stimuli_info(sample_data.parsed_data);
end
function [primary_stimuli,secondary_stimuli] = get_stimuli_info(parsed_data)
    stim_list = parsed_data.Stimuli_Type;

    has_chrim_logic = cellfun(@(x) contains(x,'intensity'),stim_list);          %_pulse  to end
    has_loom_logic = cellfun(@(x) contains(x,'loom'),stim_list);                %loom to .mat
    has_wall_logic = cellfun(@(x) contains(x,'wall'),stim_list);                %wall to _loom


    Elevation = str2double(parsed_data.Stimuli_Vars.Elevation);
    Azimuth = str2double(parsed_data.Stimuli_Vars.Azimuth);

    if sum(has_chrim_logic) > 0
        chrim_stim = cellfun(@(x) x(strfind(x,'pulse'):end),stim_list(has_chrim_logic),'UniformOutput',false);
        chrim_stim = convert_proto_string(chrim_stim,0,0);
        chrim_stim = cellfun(@(x) strtrim(x),chrim_stim,'UniformOutput',false);
    end        
    if sum(has_loom_logic) > 0
        loom_stim = cellfun(@(x) x(strfind(x,'loom'):(strfind(x,'.mat')-1)),stim_list(has_loom_logic),'UniformOutput',false);
        loom_stim = convert_proto_string(loom_stim, Elevation(has_loom_logic),Azimuth(has_loom_logic));
        loom_stim = cellfun(@(x) strtrim(x),loom_stim,'UniformOutput',false);            
    end

    if sum(has_wall_logic) > 0
        wall_stim = cellfun(@(x) x(strfind(x,'wall'):(strfind(x,'_loom')-1)),stim_list(has_wall_logic),'UniformOutput',false);
        wall_stim = convert_proto_string(wall_stim,0,0);
        wall_stim = cellfun(@(x) strtrim(x),wall_stim,'UniformOutput',false);
    end

    primary_stimuli   = repmat({'None'},length(stim_list),1);
    secondary_stimuli = repmat({'None'},length(stim_list),1);

    if sum(has_loom_logic) > 0
        primary_stimuli(~has_chrim_logic & has_loom_logic & ~has_wall_logic)  = loom_stim(~has_chrim_logic(has_loom_logic)  & ~has_wall_logic(has_loom_logic));      %looming stimuli only
    end
    if sum( has_wall_logic) > 0
        primary_stimuli(~has_chrim_logic & ~has_loom_logic & has_wall_logic)  = wall_stim(~has_chrim_logic(has_wall_logic)  & ~has_loom_logic(has_wall_logic));      %wall stimuli only
    end
    if sum(has_chrim_logic) > 0
        primary_stimuli(has_chrim_logic & ~has_loom_logic & ~has_wall_logic)  = chrim_stim(~has_loom_logic(has_chrim_logic) & ~has_wall_logic(has_chrim_logic));     %chrim pulse only
    end

    if sum(has_chrim_logic) > 0 && sum(has_loom_logic) > 0
        primary_stimuli(has_chrim_logic & has_loom_logic & ~has_wall_logic)   = chrim_stim(has_loom_logic(has_chrim_logic) & ~has_wall_logic(has_chrim_logic));    %chrim first loom_second
        secondary_stimuli(has_chrim_logic & has_loom_logic & ~has_wall_logic) = loom_stim(has_chrim_logic(has_loom_logic)  & ~has_wall_logic(has_loom_logic));     %chrim first loom_second
    end
    if sum(has_wall_logic) > 0 && sum( has_loom_logic) > 0
        primary_stimuli(~has_chrim_logic & has_loom_logic & has_wall_logic)   = wall_stim(has_loom_logic(has_wall_logic) & has_loom_logic(has_wall_logic));        %wall first loom_second
        secondary_stimuli(~has_chrim_logic & has_loom_logic & has_wall_logic) = loom_stim(has_wall_logic(has_loom_logic) & has_wall_logic(has_loom_logic));        %wall first loom_second
    end
end
function new_protocol_labels = convert_proto_string(proto_string,elevation,azimuth)    %converts proto string into readable text

    wall_string  = cell(length(proto_string),1);
    loom_string  = cell(length(proto_string),1);
    chrim_string = cell(length(proto_string),1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    wall_logic = cellfun(@(x) contains(x,'wall'),proto_string);
    if sum(wall_logic) > 0
        test_string = proto_string(wall_logic);

        width_index = cellfun(@(x) strfind(x,'_w'),test_string);
        height_index = cellfun(@(x) strfind(x,'_h'),test_string);
        at_index = cellfun(@(x) strfind(x,'at'),test_string,'UniformOutput',false);
        score_index = cellfun(@(x) strfind(x,'_'),test_string,'UniformOutput',false);
        score_index = cell2mat(score_index);        
        score_index = num2cell(score_index(:,2));

        wall_width = cellfun(@(x,y,z) x((y+2):(z(1)-1)),test_string,num2cell(width_index),at_index,'UniformOutput',false);
        wall_height = cellfun(@(x,y,z) x((y+2):(z(2)-1)),test_string,num2cell(height_index ),at_index,'UniformOutput',false);

        wall_width_loc = cellfun(@(x,y,z) x((z(1)+2):(y-1)),test_string,num2cell(height_index ),at_index,'UniformOutput',false);
        wall_height_loc = cellfun(@(x,y,z) x((z(2)+2):(y-1)),test_string,score_index,at_index,'UniformOutput',false);

        wall_string(wall_logic) = cellfun(@(x,y,z,a) sprintf('wall_w%03sat%03s_h%03sat%03s',x,y,z,a),wall_width,wall_width_loc,wall_height,wall_height_loc,'UniformOutput',false);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
    chrim_logic = cellfun(@(x) contains(x,'intensity'),proto_string);
    if sum(chrim_logic) > 0
        photo_str = proto_string(chrim_logic);
        intensity_index = cellfun(@(x) strfind(x,'intensity'),photo_str);
        duration_start = cellfun(@(x) strfind(x,'Begin'),photo_str);
        duration_end = cellfun(@(x) strfind(x,'_widthEnd'),photo_str);
        intensity_used = cellfun(@(x,y) str2double(x(y+9:end)),photo_str,num2cell(intensity_index));
        duration_used = cellfun(@(x,y,z) str2double(x(y+5:z-1)),photo_str,num2cell(duration_start),num2cell(duration_end));
        chrim_string(chrim_logic) = cellfun(@(x,y) sprintf('Intensity_%03.0fPct_%03.0fms',x,y),num2cell(intensity_used),num2cell(duration_used),'uniformoutput',false);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    loom_logic = cellfun(@(x) contains(x,'loom'),proto_string);
    if sum(loom_logic) > 0
        test_string = proto_string(loom_logic);
        cut_point = cellfun(@(x) strfind(x,'.mat'),test_string,'UniformOutput',false);
        missing_mat = cellfun(@(x) isempty(x),cut_point);
        cut_point(missing_mat) = cellfun(@(x) length(x),cut_point(missing_mat),'UniformOutput',false);

        no_cut_point  = cellfun(@(x) x <= 1, cut_point);
        has_cut_point = cellfun(@(x) x > 1, cut_point);
        test_string(has_cut_point) = cellfun(@(x,y) x(strfind(x,'loom'):(y-1)),test_string(has_cut_point),cut_point(has_cut_point),'UniformOutput',false);
        test_string( no_cut_point) = cellfun(@(x) x(strfind(x,'loom'):end),test_string( no_cut_point),'UniformOutput',false);

        test_string = cellfun(@(x) regexprep(x,'_blackonwhite',''),test_string,'UniformOutput',false);

        try
            to_index = cellfun(@(x) strfind(x,'to'),test_string);
            lv_index = cellfun(@(x) strfind(x,'lv'),test_string);

            start_angle = cellfun(@(x,y) x(6:(y-1)),test_string,num2cell(to_index),'uniformoutput',false);
            ending_angle = cellfun(@(x,y,z) x((y+2):(z-2)),test_string,num2cell(to_index),num2cell(lv_index),'uniformoutput',false);

            loverv = cellfun(@(x,y) x((y+2):end),test_string,num2cell(lv_index),'uniformoutput',false);
            loom_string(loom_logic) = cellfun(@(x,y,z,a,b) sprintf('loom_%03sto%03s_lv%03s  Azi :: %03.0f  Ele :: %03.0f',x,y,z,a,b), start_angle,ending_angle,loverv,num2cell(azimuth(loom_logic)),num2cell(elevation(loom_logic)),'uniformoutput',false);                
        catch
            loom_string(loom_logic) = test_string;
        end        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
    new_protocol_labels = cellfun(@(x,y,z) sprintf('%s %s %s',x,y,z),wall_string,loom_string,chrim_string,'UniformOutput',false);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [video_pulse,ending_angle] = loomTraceMaker(StimName,frameCt,start_frame)
    has_loom_logic = contains(StimName,'loom');                %loom to .mat
        
    if sum(has_loom_logic) > 0
        StimName = StimName(strfind(StimName,'loom'):(strfind(StimName,'.mat')-1));
    end

    to_index = strfind(StimName,'to');
    lv_index = strfind(StimName,'lv');
    score_index = max(strfind(StimName,'_'));
    start_angle = str2double(StimName(6:(to_index-1)));
    ending_angle = str2double(StimName((to_index+2):(lv_index-2)));
    loverv = str2double(StimName((lv_index+2):(score_index-1)));
    if isnan(loverv)
        loverv = str2double(StimName((lv_index+2):end));
    end
    
%    total_frames = round((loverv/tan(start_angle*pi/360) - loverv/tan(ending_angle*pi/360))*6);
    total_frames = round((loverv/tan(start_angle*pi/360)))*6;
    time_to_contact_vector = ((1:1:total_frames) - total_frames(end))/6;
    stim_size_angle = -atan((loverv ./ time_to_contact_vector)) .*360/pi;
    stim_size_angle(end) = 180;
    stim_size_angle = stim_size_angle(1:find(stim_size_angle <= ending_angle,1,'last'));

    value_pre_stim = zeros(1,start_frame);
    hold_value = repmat(ending_angle,1,(50*6));
    
    post_stim_frame = frameCt - length([value_pre_stim,stim_size_angle,hold_value]);
    post_stim_frame = zeros(1,post_stim_frame);
    video_pulse = [value_pre_stim,stim_size_angle,hold_value,post_stim_frame];
end
function [video_pulse,ending_angle] = offaxisTraceMaker(start_frame,stim_duration,total_frames)
    

        


    value_pre_stim = zeros(1,start_frame);
    value_during_stim = ones(1,stim_duration);
    post_stim_value = zeros(1,total_frames - (start_frame + stim_duration));
    video_pulse = [value_pre_stim,value_during_stim,post_stim_value];
    ending_angle = 1;
end
function [video_pulse,maxInt] = photoactivationTraceMaker(photoStimName,exptID,frameCt,stimStart,rateFactor)

savedPhotostimDir = [filesep filesep 'DM11' filesep 'cardlab' filesep,...
    'pez3000_variables' filesep 'photoactivation_stimuli'];
calibrationPath = [filesep filesep 'DM11' filesep 'cardlab' filesep,...
    'pez3000_variables' filesep 'Pez3_Chrimson_LED_calibration_20140709.xlsx'];
calibTable = readtable(calibrationPath,'Sheet','data');

nameParts = strsplit(photoStimName,'_');
methodName = nameParts{1};

if str2double(exptID(13:16)) < 100
    %         photoStimStruct.photoStimProtocol = {photoStimName};
    %         photoStimStruct.photoStimFrameStart = {find(nidaqData > .5,1,'first')};
    %         photoStimStruct.photoStimFrameCount = {round(2000*(1.028)*rateFactor)};
    %         if numel(find(nidaqData > .4 & nidaqData < 0.6))/2 > 10
    %             photoStimStruct.stimDecision = 'Unsure';
    %         else
    %             photoStimStruct.stimDecision = 'Good';
    %         end
    return
elseif exist(fullfile(savedPhotostimDir,[photoStimName '.mat']),'file')
    load(fullfile(savedPhotostimDir,[photoStimName '.mat']));
elseif exist(fullfile(savedPhotostimDir,'photoactivation_archive',[photoStimName '.mat']),'file')
    load(fullfile(savedPhotostimDir,'photoactivation_archive',[photoStimName '.mat']));
else
    if strcmp('pulse',methodName)
        var_pul_width_begin = str2double(nameParts{3}(numel('widthBegin')+1:end));
        var_pul_width_end = str2double(nameParts{4}(numel('widthEnd')+1:end));
        var_pul_count = str2double(nameParts{5}(numel('cycles')+1:end));
        var_intensity = str2double(nameParts{6}(numel('intensity')+1:end));
        if var_pul_count == 1
            if strcmp(photoStimName,'pulse_Namikis_width1000_period1000_cycles1_intensity2')
                var_pul_width_begin = 1000;
                var_pul_width_end = 1000;
                var_pul_count = 1;
                var_intensity = 2;
                var_tot_dur = var_pul_width_begin;
            else
                var_tot_dur = var_pul_width_begin;
            end
        elseif strcmp(photoStimName,'pulse_General_widthBegin5_widthEnd150_cycles5_intensity30')
            var_tot_dur = 1000;
        elseif strcmp(photoStimName,'pulse_Williamsonw_widthBegin5_widthEnd75_cycles5_intensity30')
            var_tot_dur = 500;
        else
            var_tot_dur = 500;
        end
    elseif strcmp('ramp',methodName)
        var_ramp_width = str2double(nameParts{3}(numel('rampWidth')+1:end));
        var_tot_dur = str2double(nameParts{6}(numel('totalDur')+1:end));
        var_ramp_init = str2double(nameParts{4}(numel('initVal')+1:end));
        var_intensity = str2double(nameParts{5}(numel('finalVal')+1:end));
    elseif strcmp('combo',methodName)
        var_pul_width_begin = str2double(nameParts{3}(numel('pulseWidthBegin')+1:end));
        var_pul_width_end = str2double(nameParts{4}(numel('pulseWidthEnd')+1:end));
        var_pul_count = str2double(nameParts{5}(numel('cycles')+1:end));
        var_ramp_width = str2double(nameParts{6}(numel('rampWidth')+1:end));
        var_tot_dur = str2double(nameParts{9}(numel('totalDur')+1:end));
        var_ramp_init = str2double(nameParts{7}(numel('initVal')+1:end));
        var_intensity = str2double(nameParts{8}(numel('finalVal')+1:end));
    elseif strcmp('Alternating',methodName)
        %             photoStimStruct.stimDecision = 'Unsure';
        return
    else
        error('invalid name')
    end
end

oldProtocols = {'pulse_Testing_widthBegin5_widthEnd150_period150_cycles6_intensity20'
    'pulse_Testing_widthBegin5_widthEnd150_period150_cycles6_intensity30'
    'pulse_Testing_widthBegin5_widthEnd150_period150_cycles6_intensity40'
    'combo_Testing_pulseWidth5_period150_cycles6_rampWidth800_initVal5_finalVal50_totalDur900'
    'combo_Testing_pulseWidth100_period150_cycles6_rampWidth800_initVal5_finalVal50_totalDur900'
    'combo_Testing_pulseWidth25_period150_cycles6_rampWidth800_initVal5_finalVal50_totalDur900'};
if max(strcmp(oldProtocols,photoStimName))
    %         photoStimStruct.photoStimProtocol = {photoStimName};
    %         photoStimStruct.photoStimFrameStart = {find(nidaqData > .5,1,'first')};
    %         if ~exist('var_tot_dur','var')
    %             var_tot_dur = 900;
    %         end
    %         photoStimStruct.photoStimFrameCount = {round(var_tot_dur*(1.028)*rateFactor)};
    %         if numel(find(nidaqData > .4 & nidaqData < 0.6))/2 > 10
    %             photoStimStruct.stimDecision = 'Unsure';
    %         else
    %             photoStimStruct.stimDecision = 'Good';
    %         end
    return
end

if strcmp('ramp',methodName)
    pulseGui_x = (1:var_tot_dur);
    var_slope = (var_ramp_init-var_intensity)/(0-var_ramp_width);
    pulseGui_y = var_slope.*pulseGui_x+var_ramp_init;
else
    if exist('var_pul_count','var')
        cycles = var_pul_count;
    else
        cycles = str2double(photoStimName(strfind(photoStimName,'cycles')+numel('cycles')));
    end
    xA = linspace(var_pul_width_begin,var_pul_width_end,cycles);
    if cycles == 1
        xOff = 0;
    else
        xOff = (var_tot_dur-sum(xA))/(cycles-1);
    end
    if xOff < 0
        xOff = 0;
    end
    xB = zeros(1,cycles)+xOff;
    xC = [xB;xA];
    xC = repmat(cumsum(xC(:)),1,2)'-xOff;
    pulseGui_x = round(xC(:));
    
    yA = repmat([0;var_intensity;var_intensity;0],1,cycles);
    if strcmp('combo',methodName)
        var_slope = (var_ramp_init-var_intensity)/(0-var_ramp_width);
        yA(2,:) = var_slope.*xB(2,:)+var_ramp_init;
        yA(3,:) = yA(2,:);
        yA(yA > var_intensity) = var_intensity;
    end
    pulseGui_y = round(yA(:));
    if max(pulseGui_x > var_tot_dur)
        pulseGui_y(pulseGui_x >= var_tot_dur) = [];
        pulseGui_x(pulseGui_x >= var_tot_dur) = [];
        pulseGui_xB = [pulseGui_x;var_tot_dur;var_tot_dur];
        pulseGui_yB = [pulseGui_y;var_intensity;0];
        pulseGui_x = pulseGui_xB;
        pulseGui_y = pulseGui_yB;
    end
    pulseRef = (2:2:numel(pulseGui_x));
    pulseGui_xPart = pulseGui_x(pulseRef);
    pulseGui_yPart = pulseGui_y(pulseRef);
    pulseGui_x = (1:var_tot_dur);
    pulseGui_y = zeros(1,var_tot_dur);
    for iterP = 1:numel(pulseRef)-1
        xrefA = pulseGui_xPart(iterP);
        xrefB = pulseGui_xPart(iterP+1);
        pulseGui_y(xrefA+1:xrefB) = pulseGui_yPart(iterP);
    end
end

pulseOpsX = pulseGui_x;
pulseOpsY = pulseGui_y;
pulseGui_xReal = (pulseOpsX*(1.028)*rateFactor);
video_x = (1:max(pulseGui_xReal));
video_pulse = interp1(pulseGui_xReal,pulseOpsY,video_x,'nearest','extrap');
video_pulse = video_pulse/max(video_pulse);
video_pulse(video_pulse < 0) = 0;
video_pulse = [zeros(stimStart,1);video_pulse(:)];
video_pulse(frameCt) = 0;

prctI = [0;calibTable.prct_intensity];
uWdata = [0;calibTable.uW_per_mm2];
interpX = linspace(0,var_intensity,100);
interpY = interp1(prctI,uWdata,interpX,'pchip','extrap');

video_pulse = interpY(round(video_pulse*99)+1);
maxInt = var_intensity;
% plot(video_pulse)

end
function wall_width_loc = get_wall_pos(photoStimName)
    test_string = {photoStimName};

    height_index = cellfun(@(x) strfind(x,'_h'),test_string);
    at_index = cellfun(@(x) strfind(x,'at'),test_string,'UniformOutput',false);
    wall_width_loc = cellfun(@(x,y,z) x((z(1)+2):(y-1)),test_string,num2cell(height_index ),at_index,'UniformOutput',false);    
    wall_width_loc = cell2mat(wall_width_loc);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Parent_B = convert_background_labels(Parent_B)                            %conversion for background, makes shorter string
    Parent_B(cellfun(@(x) contains(x,'DL_UAS_Kir21_3_0090'),Parent_B)) = {'DL_UAS_Kir21'};
    Parent_B(cellfun(@(x) contains(x,'pJFRC315-10XUAS-IVS-tdtomato::Kir2.1 in su(Hw)attP5'),Parent_B)) = {'tdtomato_Kir21_in_su(Hw)attP5'};
    Parent_B(cellfun(@(x) contains(x,'pJFRC315-10XUAS-IVS-tdtomato::Kir2.1 in VK00027'),Parent_B)) = {'tdtomato_Kir21_in_VK00027'};
    Parent_B(cellfun(@(x) contains(x,'pJFRC49-10XUAS-IVS-eGFPKir2.1 in VK00005 '),Parent_B)) = {'eGFPKir2.1_in_VK00005'};
    Parent_B(cellfun(@(x) contains(x,'FCF_DL_1500090'),Parent_B)) = {'CTRL_DL_1500090'};

    Parent_B(cellfun(@(x) contains(x,'w+ DL; DL; pJFRC49-10XUAS-IVS-eGFPKir2.1 in attP2 (DL)'),Parent_B)) = {'DL_UAS_Kir21'};
    Parent_B(cellfun(@(x) contains(x,'UAS_Chrimson_Venus_X_0070VZJ_K_45195'),Parent_B)) = {'UAS_Chrimson_Venus_X_0070'};
    Parent_B(cellfun(@(x) contains(x,'CTRL_DL_1500090_0028FCF_DL_1500090'),Parent_B)) = {'CTRL_DL_1500090'};
end
function  test_data = get_id_list(exptID,azi_off,graph_logic)
    temp_range = [22.5,24.5];
    humidity_cut_off = 40;          
    remove_low = false;             low_count = 5;
    %azi_off = 180;      %for pat wall

    test_data =  Experiment_ID(exptID);
    test_data.temp_range = temp_range;
    test_data.humidity_cut_off = humidity_cut_off;
    test_data.remove_low = remove_low;
    test_data.low_count = low_count;
    test_data.azi_off = azi_off;
    test_data.ignore_graph_table = graph_logic;
    test_data.load_data;
    test_data.make_tables;
    test_data.get_tracking_data;
    test_data.display_data;
end