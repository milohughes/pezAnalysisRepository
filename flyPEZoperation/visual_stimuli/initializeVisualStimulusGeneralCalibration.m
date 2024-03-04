function [stimStruct] = initializeVisualStimulusGeneralCalibration
%initializeVisualStimulusGeneral This function will be common to all visual
%stimuli and initializes the parameters which need only be done once

% PTB-3 properly installed and working?
AssertOpenGL;
Screen('Preference','Verbosity',2);

% [~, comp_name] = system('hostname');
% comp_name = comp_name(1:end-1); %Remove trailing character.
comp_name = 'peekm-ww3';
varDest = 'C:\Users\cardlab\Documents\Photron_flyPez3000\visual_stimuli';
varName = [comp_name '_stimuliVars.mat'];
varPath = fullfile(varDest,varName);
load(varPath)

% To place a dark grid over the background
% gainMatrix = gridBackground;

% Open onscreen window with black background clear color:
if ~isempty(Screen('Windows')),Screen('CloseAll'),end

screenid = max(Screen('Screens'));
[width,~] = Screen('WindowSize',screenid);
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

gainMatrix(gainMatrix > 0) = 1;
PsychColorCorrection('SetGainMatrix',win,gainMatrix,[],0);

% Create warpoperator for application of the image warp:
winRect = Screen('Rect',win);
warpoperator = CreateGLOperator(win);
warpmap = AddImageWarpToGLOperator(warpoperator, winRect);

% win = Screen('OpenWindow',screenid,[],[],[],[]);
% warpmap = [];
% warpoperator = [];
% win = [];
% [ifi]= Screen('GetFlipInterval',win,100,0.00005,20);
ifi = [];
stimStruct = struct('stimEleForProc',stimEleForProc,'stimAziForProc',...
    stimAziForProc,'win',win,'warpmap',warpmap,'warpoperator',...
    warpoperator,'stimRefROI',stimRefROI,'ifi',ifi,'vertLinesIm',vertLinesIm);
end

