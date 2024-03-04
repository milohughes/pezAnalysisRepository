function templateMaker3000_gradePointsAndGenders


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, one must plase run folders into a file named 'raw_videos' 
% within the 'speciesFolder' below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
speciesFolder = 'Drosophila_melanogaster';


%%%%% computer and directory variables and information
op_sys = system_dependent('getos');
if strfind(op_sys,'Microsoft Windows 7')
    archDir = [filesep filesep 'arch' filesep 'card'];
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

[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
addpath(fullfile(repositoryDir,'pezProc_subfunctions'))

run_list_dir = fullfile(archDir,'pez3000_flyTemplates',speciesFolder,'raw_videos');
workingTemplateDir = fullfile(archDir,'pez3000_flyTemplates',speciesFolder,'work_in_progress');
if ~isdir(workingTemplateDir), mkdir(workingTemplateDir), end
runFolderList = dir(fullfile(run_list_dir,'run*'));
runFolderList = {runFolderList(:).name}';
expt_count = numel(runFolderList);
vidNameList = cell(expt_count,1);
vidPathList = cell(expt_count,1);
for i = 1:expt_count
    vidNameList{i} = dir(fullfile(run_list_dir,runFolderList{i},'*.mp4'));
    vidNameList{i} = {vidNameList{i}(:).name};
    vidPathList{i} = cellfun(@(x) fullfile(run_list_dir,runFolderList{i},x),vidNameList{i},'uniformoutput',false);
end
vidNameList = cat(2,vidNameList{:})';
vidPathList = cat(2,vidPathList{:})';
vidCt = numel(vidNameList);

%% Initial selection of 'ideal' frames to generate average fly
scrn_size = get(0, 'ScreenSize');
if exist([workingTemplateDir filesep 'template_wip_reviewed.mat'],'file') == 0
    if exist([workingTemplateDir filesep 'template_wip.mat'],'file') == 0
        error('file not found')
    else
        template_making = load([workingTemplateDir filesep 'template_wip.mat']);
        template_init_data = template_making.template_init_data;
        fly_count = template_making.fly_count;
    end
else
    template_making = load([workingTemplateDir filesep 'template_wip_reviewed.mat']);
    template_init_data = template_making.template_init_data;
    fly_count = template_making.fly_count;
end
%%
vid_rand_index = randperm(vidCt);
instructions = cellstr(char('On the midline, select the extreme anterior first',...
    'then select the extreme posterior, and then <return>'));
fig_position = [scrn_size(3)/3 scrn_size(4)/10 scrn_size(4)*0.5 scrn_size(4)*0.5];

h_fig = figure('Position',fig_position);
h_axes = axes('Parent',h_fig);
colormap('gray')


workingFlag = 1;
initName = vidNameList{vid_rand_index(1)};
while workingFlag == 1
    vidRef = vid_rand_index(1);
    if max(strcmp(initName,vidNameList{vidRef}))
        disp('First Video')
    end
    
    testA = max(strcmp(template_init_data(1).video_name,vidNameList{vidRef}));
    testB = max(strcmp(template_init_data(2).video_name,vidNameList{vidRef}));
    if ~testA && ~testB
        vid_rand_index = circshift(vid_rand_index,[0 -1]);
        continue
    end
    if testA
        vidBool = strcmp(template_init_data(1).video_name,vidNameList{vidRef});
        pts = template_init_data(1).points{vidBool};
        I = template_init_data(1).images{vidBool};
        gend = 'female';
    elseif testB
        vidBool = strcmp(template_init_data(2).video_name,vidNameList{vidRef});
        pts = template_init_data(2).points{vidBool};
        I = template_init_data(2).images{vidBool};
        gend = 'male';
    else
        error('test fail')
    end
    imAdjInput = stretchlim(I,[0.01 0.999]);
    I_adj = imadjust(I,imAdjInput);
    image(I_adj,'CDataMapping','scaled','Parent',h_axes);
    axis image
    box off
    axis off
    vidWidth = size(I,1);
    updates1 = cellstr(char(['Video count: ' int2str(vidCt)]));
    updates2 = cellstr(char(['Female count: ' int2str(fly_count(1))],...
        ['Male count: ' int2str(fly_count(2))]));
    text(15,vidWidth+35,updates1,'FontSize',10,'Color',[0 0 1],'Parent',h_axes)
    text(round(vidWidth*0.65),vidWidth+35,updates2,'FontSize',10,...
        'Color',[0 0 1],'Parent',h_axes)
    text(1,-25,instructions,'FontSize',12,'Color',[0 0 1],'Parent',h_axes)
    hold on
    plot(pts(1,1),pts(1,2),'.','color',[.8 0 0],'markersize',20)
%     plot(pts(2,1),pts(2,2),'.','color',[0 0 .8],'markersize',20)
    hold off
    choice = questdlg(gend,...
        'Options',...
        'Good','Wrong gender','Point problem','Good');
    switch choice
        case 'Good'
            vid_rand_index = circshift(vid_rand_index,[0 -1]);
        case 'Wrong gender'
            if testA
                
                fly_count(1) = fly_count(1)-1;
                %remove female stuff
                template_init_data(1).points{vidBool} = [];
                template_init_data(1).images{vidBool} = [];
                template_init_data(1).video_name{vidBool} = [];
                %update male stuff
                fly_count(2) = fly_count(2)+1;
                template_init_data(2).points{fly_count(2)} = pts;
                template_init_data(2).images{fly_count(2)} = I;
                template_init_data(2).video_name{fly_count(2)} = vidNameList{vidRef};
            elseif testB
                
                fly_count(2) = fly_count(2)-1;
                %remove female stuff
                template_init_data(2).points{vidBool} = [];
                template_init_data(2).images{vidBool} = [];
                template_init_data(2).video_name{vidBool} = [];
                %update male stuff
                fly_count(1) = fly_count(1)+1;
                template_init_data(1).points{fly_count(1)} = pts;
                template_init_data(1).images{fly_count(1)} = I;
                template_init_data(1).video_name{fly_count(1)} = vidNameList{vidRef};
            end
        case 'Point problem'
            I_filt = hotFilter(I);
            image(I_filt,'CDataMapping','scaled','Parent',h_axes);
            axis image
            box off
            axis off
            text(15,vidWidth+35,updates1,'FontSize',10,'Color',[0 0 1],'Parent',h_axes)
            text(round(vidWidth*0.65),vidWidth+35,updates2,'FontSize',10,...
                'Color',[0 0 1],'Parent',h_axes)
            text(1,-25,instructions,'FontSize',12,'Color',[0 0 1],'Parent',h_axes)
            
            if testA
                vidBool = strcmp(template_init_data(1).video_name,vidNameList{vidRef});
                count_x = 0;
                while count_x ~= 2
                    [x, y] = getpts(gcf);
                    count_x = size(x,1);
                end
                template_init_data(1).points{vidBool} = [x y];
            elseif testB
                vidBool = strcmp(template_init_data(2).video_name,vidNameList{vidRef});
                count_x = 0;
                while count_x ~= 2
                    [x, y] = getpts(gcf);
                    count_x = size(x,1);
                end
                template_init_data(2).points{vidBool} = [x y];
            end
    end
    if isempty(choice)
        workingFlag = 0;
        continue
    end
    
    save([workingTemplateDir filesep 'template_wip_reviewed'],'template_init_data','fly_count')
    vid_rand_index = circshift(vid_rand_index,[0 -1]);
end
close all
