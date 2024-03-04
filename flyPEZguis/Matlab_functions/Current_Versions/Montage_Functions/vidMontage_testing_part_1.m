function [textBase,graphBase,destPath,usable_data,flyPosX,flyPosY,vidObjCutrate,vidObjSupplement,montFrmCt,vidList,frmBounds,frameReferenceMesh] = ...
        vidMontage_testing_part_1(expIDlist,stim_type,varargin)
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

    addRequired(p,'exptIDlist');
    addRequired(p,'stim_type');

    addOptional(p,'test_data',[]);
    addOptional(p,'logical_filter','none');
    addOptional(p,'sort_order','random');
    addOptional(p,'view_opt','bottom');
    addOptional(p,'rotate_opt','rotate');
    addOptional(p,'video_index',1);
    addOptional(p,'Show_Tracked',true);
    addOptional(p,'Show_Stimuli',true);
    addOptional(p,'Show_Wall',true);
    addOptional(p,'Show_Grid',true);
    p.KeepUnmatched = true;
    parse(p,expIDlist,stim_type,varargin{:});

    exptID = p.Results.exptIDlist{1};
    sort_order = p.Results.sort_order;
    stim_type = p.Results.stim_type;
    logical_filter = p.Results.logical_filter;
    rotate_opt = p.Results.rotate_opt;
    view_opt = p.Results.view_opt;
    video_index = p.Results.video_index;
    test_data = p.Results.test_data;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets default variables
    maxFlies = 30;
    framesBeforeStim = (50*6);          framesAfterStim = (250*6)-1;
    labelCell = {'genotype'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% checks to see need to load data
    disp(exptID)    
    if isempty(test_data)
        test_data = get_id_list(exptID);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
%% filters video list
    usable_data = [vertcat(test_data.Complete_usuable_data);vertcat(test_data.Videos_Need_To_Work)];
    if ischar(logical_filter)
        logical_filter = true(height(usable_data),1);
    end
    usable_data = usable_data(logical_filter,:);

    if strcmp(sort_order,'time_of_jump')
        usable_data(cellfun(@(x) isempty(x), usable_data.frame_of_leg_push),:) = [];
        usable_data(cellfun(@(x) isnan(x), usable_data.frame_of_leg_push),:) = [];
    end
    masterList = usable_data.Properties.RowNames;
    vidsAvailable = length(masterList);    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
%% sorts and filters list to size of maxFlies    
    parent_info = vertcat(test_data.parsed_data);
         
    if strcmp(sort_order,'random')
        vidRefs = randperm(numel(masterList));
        vidList = masterList(vidRefs(1:vidsAvailable));
        vidCount = numel(vidList);
        if vidCount > maxFlies
            vidList = vidList(randperm(numel(vidList),maxFlies));
            vidCount = maxFlies;
        end        
    elseif strcmp(sort_order,'time_of_jump')
        sort_value = cellfun(@(x,y) (x-y), usable_data.frame_of_take_off,usable_data.Start_Frame);
        [~,vidRefs] = sort(sort_value);
        vidList = masterList(vidRefs);
        vidCount = numel(vidList);
        usable_data = usable_data(vidRefs,:);
    else
        vidRefs = sort_order;
        vidList = masterList(vidRefs);
        vidCount = numel(vidList);
    end
    
    index_counts = ((video_index-1)*30 +1) :(video_index*30);
    
    if max(index_counts) > maxFlies
        index_counts = ((video_index-1)*30 +1) : maxFlies;        
    elseif max(index_counts) >  vidCount
        index_counts = ((video_index-1)*30 +1) :  vidCount;        
    end
    vidList = vidList(index_counts);
    vidCount = numel(vidList);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets parent strings, and save pathing
    parent_string = cellfun(@(x,y) sprintf('%s_%s',x,y),parent_info.ParentA_name,parent_info.ParentB_name,'UniformOutput',false);
    parent_string = parent_string{1};
    full_string_list = cellfun(@(x,y,z) sprintf('%s_%s_%s',x,y,z),parent_info.Stimuli_Type,parent_info.Elevation,parent_info.Azimuth,'UniformOutput',false);
    full_string_list = full_string_list{1};
    
    video_stim_length = cellfun(@(x) str2double(x(strfind(x,'End')+3:strfind(x,'End')+4)),usable_data.Stimuli_Used);
    if strcmp(view_opt,'bottom') && strcmp(rotate_opt,'rotate')
%        destName = [exptID '_montage_' sprintf('%02.f_',video_index) view_opt '_alignend_270_view.mp4'];
        destName = [full_string_list '_montage_' sprintf('%02.f_',video_index) view_opt '_aligned_090_view.mp4'];
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
        if strcmp(stim_type,'Chrim')
            stimLength = video_stim_length(iterM)*6;      %50 ms pulse
        else
            stimLength = unique(cell2mat(usable_data.Stimuli_Duration));      %frames in looming stimuli
            if length(stimLength) > 1
                stimLength = max(stimLength);
            end
            stimLength =  stimLength + (50*6);      %holds last frame for 50 milliseconds not part of duration            
        end
        
        nidaq_data = usable_data(videoID,:).visual_stimulus_info{1}.nidaq_data;
        stimFrames = (stimStart-(framesBeforeStim):(stimStart+stimLength+framesAfterStim));

        stimFrames(stimFrames < 1) = 1;
        frameCt = usable_data.frame_count(videoID);
        rateFactor = double(usable_data.record_rate(videoID))/1000;
        stimFrames(stimFrames > frameCt) = frameCt;
%         if strcmp(sort_order,'time_of_jump')    %100ms prior to leg, 50 ms after leg push
%             leg_frame = usable_data.frame_of_leg_push{iterM};
%             stimFrames = (leg_frame-(100*6)):((leg_frame -1)+ (50*6));
%         end
        frmBounds{iterM} = stimFrames;      %every frame of video        
        
        stimFrames(stimFrames > length(nidaq_data)) = [];   %remove frames if video already ended
        
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
    montFrmCt = numel(stimFrames);
    photoStimName = usable_data.Stimuli_Used{videoID};
    if contains(photoStimName,'Instensity')
        [video_pulse,maxInt] = photoactivationTraceMaker(photoStimName,exptID,montFrmCt,framesBeforeStim,rateFactor);
    else
        [video_pulse,maxInt] = loomTraceMaker(photoStimName,montFrmCt,framesBeforeStim);
    end
    if ~contains(photoStimName,'wall')      %cant show a wall if none exists
        p.Results.Show_Wall = false;
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
    if strcmp(stim_type,'Chrim')
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
    video_pulse = video_pulse(1:1:length(stimFrames));
    
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
    
    if contains(photoStimName,'Instensity')
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
        [end_of_stim/montDims(1) baseYb/montDims(2)+0.2]
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
end
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
function  test_data = get_id_list(exptID)
    temp_range = [22.5,24.0];
    humidity_cut_off = 40;          azi_off = 22.5;
    remove_low = false;             low_count = 5;

    test_data =  Experiment_ID(exptID);
    test_data.temp_range = temp_range;
    test_data.humidity_cut_off = humidity_cut_off;
    test_data.remove_low = remove_low;
    test_data.low_count = low_count;
    test_data.azi_off = azi_off;
    test_data.ignore_graph_table = true;
    test_data.load_data;
    test_data.make_tables;
    test_data.get_tracking_data;
    test_data.display_data;
end
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