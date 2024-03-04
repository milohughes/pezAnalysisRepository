function [stimStruct] = initializeVisualStimulusGeneralUDP_brighter
%initializeVisualStimulusGeneral This function will be common to all visual
%stimuli and initializes the parameters which need only be done once

% PTB-3 properly installed and working?
AssertOpenGL;
Screen('Preference','Verbosity',2);

%%%%% computer and directory variables and information
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');
variablesDir = fullfile(fileDir,'pez3000_variables');

%[~, comp_name] = system('hostname');
%comp_name = comp_name(1:end-1); %Remove trailing character.
comp_name = getenv('COMPUTERNAME');
compDataPath = fullfile(variablesDir,'computer_info.xlsx');
compData = dataset('XLSFile',compDataPath);
compRef = find(strcmp(compData.stimulus_computer_name,comp_name));
if isempty(compRef)
    disp('computer not valid')
    return
end
pezName = ['pez' num2str(compData.pez_reference(compRef))];
varName = [pezName '_stimuliVars.mat'];
varPath = fullfile(variablesDir,varName);
load(varPath)

% To place a dark grid over the background
% gainMatrixBrighter = gridBackground;

% Open onscreen window with black background clear color:
if ~isempty(Screen('Windows')),Screen('CloseAll'),end

screenidList = Screen('Screens')
for iterL = screenidList
    [width,~] = Screen('WindowSize', iterL);
    if width == 1024 || width == 1280
        screenid = iterL;
    end
end
[width,~]=Screen('WindowSize', screenid);%1024x768, old was 1280x720
if width ~= 1024
    Screen('Resolution',screenid,1024,768,120)
    [width,~]=Screen('WindowSize', screenid);
end
if width ~= 1024
    disp('screen size incorrect')
    stimStruct = 0;
    return
end

% Set the PTB to balance brightness post-processing
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask','General','UseVirtualFramebuffer');
PsychImaging('AddTask','AllViews','DisplayColorCorrection','GainMatrix');
win = PsychImaging('OpenWindow',screenid);

PsychColorCorrection('SetGainMatrix',win,gainMatrixBrighter,[],0);

% Create warpoperator for application of the image warp:
winRect = Screen('Rect',win);
warpoperator = CreateGLOperator(win);
warpmap = AddImageWarpToGLOperator(warpoperator, winRect);
warpoperator2 = CreateGLOperator(win);
warpmap2 = AddImageWarpToGLOperator(warpoperator2, winRect);

%Set up stationary wall image warp
Wallwarpoperator = CreateGLOperator(win);
Wallwarpmap = AddImageWarpToGLOperator(Wallwarpoperator, winRect);

% win = Screen('OpenWindow',screenid,[],[],[],[]);
% warpmap = [];
% warpoperator = [];
% win = [];
% [ifi]= Screen('GetFlipInterval',win,100,0.00005,20);
ifi = [];

stimStruct = struct('stimEleForProc',stimEleForProc,'stimAziForProc',...
    stimAziForProc,'win',win,'warpmap',warpmap,'warpmap2',warpmap2,'Wallwarpmap',Wallwarpmap,'warpoperator',...
    warpoperator,'warpoperator2',warpoperator2,'Wallwarpoperator',Wallwarpoperator,'stimRefROI',stimRefROI,...
    'ifi',ifi,'vertLinesIm',vertLinesIm);
end

