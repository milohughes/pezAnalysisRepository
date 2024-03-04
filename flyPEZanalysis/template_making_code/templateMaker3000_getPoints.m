function templateMaker3000_getPoints


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% First, one must plase run folders into a file named 'raw_videos' 
% within the 'speciesFolder' below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%% computer and directory variables and information
op_sys = system_dependent('getos');
if strfind(op_sys,'Microsoft Windows 7')
%    archDir = [filesep filesep 'arch' filesep 'card'];
    archDir = [filesep filesep 'tier2' filesep 'card'];
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
parentDir = fullfile(archDir,'Data_pez3000');
guiVarDir = fullfile(dm11Dir,'Pez3000_Gui_folder','Gui_saved_variables');
variablesDir = fullfile(dm11Dir,'pez3000_variables');
housekeepingDir = fullfile(dm11Dir,'Pez3000_Gui_folder','defaults_and_housekeeping_variables');
analysisDir = fullfile(dm11Dir,'Data_pez3000_analyzed');
exptSumName = 'experimentSummary.mat';
exptSumPath = fullfile(analysisDir,exptSumName);
experimentSummary = load(exptSumPath);
experimentSummary = experimentSummary.experimentSummary;

[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
addpath(fullfile(repositoryDir,'pezProc_subfunctions'))

exptList = experimentSummary.Properties.RowNames;
tmplTest = strcmp(experimentSummary.Experiment_Type,'Template_making');
tmplList = exptList(tmplTest);
disp([num2str(numel(tmplList)) ' entries'])
%%%%% There should be two folders per species.  One for male, one for
%%%%% female
for iterS = 1:numel(tmplList)
    exptID = tmplList{iterS};
    exptResultsRefDir = fullfile(analysisDir,exptID);
    exptInfoMergedName = [exptID '_experimentInfoMerged.mat'];
    exptInfoMergedPath = fullfile(exptResultsRefDir,exptInfoMergedName);
    load(exptInfoMergedPath)
    exptInfo = experimentInfoMerged(1,:);
    speciesFolder = exptInfo.ParentB_genotype{1};
    speciesFolder = regexprep(speciesFolder,' ','_');
    disp([num2str(iterS) '  -  ' exptID '  -  ' speciesFolder])
end

%%%%%%%%
template_reference = 8;
%%%%%%%%



exptID = tmplList{template_reference};
exptResultsRefDir = fullfile(analysisDir,exptID);
exptInfoMergedName = [exptID '_experimentInfoMerged.mat'];
exptInfoMergedPath = fullfile(exptResultsRefDir,exptInfoMergedName);
load(exptInfoMergedPath)

assessmentTag = '_rawDataAssessment.mat';
assessmentName = [exptID assessmentTag];
assessmentPath = fullfile(exptResultsRefDir,assessmentName);
load(assessmentPath)
vidPathList = assessTable.Video_Path;
vidNameList = assessTable.Properties.RowNames;
exptInfo = experimentInfoMerged(1,:);
maleTest = exptInfo.Males{1};
femaleTest = exptInfo.Females{1};
speciesFolder = exptInfo.ParentB_genotype{1};
speciesFolder = regexprep(speciesFolder,' ','_');
disp(speciesFolder)
genderops = {'Male','Female'};
disp(genderops{logical([maleTest femaleTest])});
% run_list_dir = fullfile(archDir,'pez3000_flyTemplates',speciesFolder,'raw_videos');
workingTemplateDir = fullfile(archDir,'pez3000_flyTemplates',speciesFolder,'work_in_progress');
if ~isdir(workingTemplateDir), mkdir(workingTemplateDir), end
vidCt = numel(vidNameList);
disp(num2str(vidCt))
disp(' ')
disp(' ')
%% Initial selection of 'ideal' frames to generate average fly
scrn_size = get(0, 'ScreenSize');

if exist([workingTemplateDir filesep 'template_wip.mat'],'file') == 0
    template_init_data = struct('images',cell(1,1),'points',cell(1,1),'video_name',cell(1,1));
    template_init_data(2) = template_init_data;
    fly_count = zeros(2,1);
else
    template_making = load([workingTemplateDir filesep 'template_wip.mat']);
    template_init_data = template_making.template_init_data;
    fly_count = template_making.fly_count;
end

% vid_rand_index = randperm(vidCt);
vid_rand_index = (1:vidCt);
instructions = cellstr(char('On the midline, select the extreme anterior first',...
    'then select the extreme posterior, and then <return>'));
fig_position = [scrn_size(3)/3 scrn_size(4)/10 scrn_size(4)*0.5 scrn_size(4)*0.5];

h_fig = figure('Position',fig_position);
h_axes = axes('Parent',h_fig);
colormap('gray')

initName = vidNameList{vid_rand_index(1)};
closeBool = 0;
workingFlag = 1;
while workingFlag == 1
    vidRef = vid_rand_index(1);
    if max(strcmp(initName,vidNameList{vidRef}))
        closeBool = closeBool+1;
        if closeBool == 2
            workingFlag = 0;
            continue
        end
    end
    testA = max(strcmp(template_init_data(1).video_name,vidNameList{vidRef}));
    testB = max(strcmp(template_init_data(2).video_name,vidNameList{vidRef}));
    if testA || testB
        vid_rand_index = circshift(vid_rand_index,[0 -1]);
        continue
    end
    obj = VideoReader(vidPathList{vidRef});
    vidHeight = obj.Height;
    vidWidth = obj.Width;
    I = read(obj,1);
    I = double(I(:,:,1))./255;
    I = I((vidHeight-vidWidth+1):vidHeight,:);
    imAdjInput = stretchlim(I,[0.01 0.999]);
    I_adj = imadjust(I,imAdjInput);
    image(I_adj,'CDataMapping','scaled','Parent',h_axes);
    axis image
    box off
    axis off
    updates1 = cellstr(char(['Video count: ' int2str(vidCt)]));
    updates2 = cellstr(char(['Female count: ' int2str(fly_count(1))],...
        ['Male count: ' int2str(fly_count(2))]));
    text(15,vidWidth+35,updates1,'FontSize',10,'Color',[0 0 1],'Parent',h_axes)
    text(round(vidWidth*0.65),vidWidth+35,updates2,'FontSize',10,...
        'Color',[0 0 1],'Parent',h_axes)
    text(1,-25,instructions,'FontSize',12,'Color',[0 0 1],'Parent',h_axes)
    
    choice = questdlg('Is this fly in full view and in focus?',...
        'Options',...
        'Good fly','Next fly','Prev fly','Next fly');
    switch choice
        case 'Good fly'
        case 'Next fly'
            vid_rand_index = circshift(vid_rand_index,[0 -1]);
            continue
        case 'Prev fly'
            vid_rand_index = circshift(vid_rand_index,[0 1]);
            continue
    end
    if isempty(choice)
        workingFlag = 0;
        continue
    end
    I_filt = hotFilter(I);
    image(I_filt,'CDataMapping','scaled','Parent',h_axes);
    axis image
    box off
    axis off
    text(15,vidWidth+35,updates1,'FontSize',10,'Color',[0 0 1],'Parent',h_axes)
    text(round(vidWidth*0.65),vidWidth+35,updates2,'FontSize',10,...
        'Color',[0 0 1],'Parent',h_axes)
    text(1,-25,instructions,'FontSize',12,'Color',[0 0 1],'Parent',h_axes)
    
    if maleTest && femaleTest
        error('ambiguous gender')
    elseif femaleTest
        choice = 'Good Female';
    elseif maleTest
        choice = 'Good Male';
    end
    
    switch choice
        case 'Good Female'
            fly_count(1) = fly_count(1)+1;
            count_x = 0;
            while count_x ~= 2
                [x, y] = getpts(gcf);
                count_x = size(x,1);
            end
            template_init_data(1).points{fly_count(1)} = [x y];
            template_init_data(1).images{fly_count(1)} = I;
            template_init_data(1).video_name{fly_count(1)} = vidNameList{vidRef};
        case 'Good Male'
            fly_count(2) = fly_count(2)+1;
            count_x = 0;
            while count_x ~= 2
                [x, y] = getpts(gcf);
                count_x = size(x,1);
            end
            template_init_data(2).points{fly_count(2)} = [x y];
            template_init_data(2).images{fly_count(2)} = I;
            template_init_data(2).video_name{fly_count(2)} = vidNameList{vidRef};
        case 'Next Video'
    end
    if isempty(choice)
        workingFlag = 0;
        continue
    end
    save([workingTemplateDir filesep 'template_wip'],'template_init_data','fly_count')
    vid_rand_index = circshift(vid_rand_index,[0 -1]);
end
close all
