clear all
close all
clc

% PTB-3 properly installed and working?
AssertOpenGL;

varDest = 'C:\Users\cardlab\Documents\MATLAB\visual_stimuli\stimuliVars.mat';
load(varDest)

% Open onscreen window with black background clear color:
if ~isempty(Screen('Windows')),Screen('CloseAll'),end

% Select display with max id for our onscreen window:
screenid = max(Screen('Screens'));
[width, height]=Screen('WindowSize', screenid);%1024x768, old was 1280x720
if width ~= 1024
    Screen('Resolution',screenid,1024,768,120)
end

% Set the PTB to balance brightness post-processing
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask','General','UseVirtualFramebuffer');
PsychImaging('AddTask','AllViews','DisplayColorCorrection','GainMatrix');
win = PsychImaging('OpenWindow',screenid,0,[],[0 0 720 1280]);
PsychColorCorrection('SetGainMatrix',win,gainMatrix,[],0);

% Create warpoperator for application of the image warp:
winRect = Screen('Rect',win);
warpoperator = CreateGLOperator(win);
warpmap = AddImageWarpToGLOperator(warpoperator, winRect);

%%
ellovervee = 240;
[stimThetaRefs,stimTotalDuration] = elloverveeFun(ellovervee);
stimSpecs = struct('ele',45,'azi',120);

stimStruct = struct('stimEleForProc',stimEleForProc,'stimAziForProc',...
    stimAziForProc,'win',win,'warpmap',warpmap,'warpoperator',...
    warpoperator,'stimSpecs',stimSpecs,'stimThetaRefs',stimThetaRefs);

missedFrms = stimulus_SingleOneColorDisk(stimStruct)
%%
% Open onscreen window with black background clear color:
if ~isempty(Screen('Windows')),Screen('CloseAll'),end
window = Screen(screenid,'OpenWindow');
Screen(window, 'PutImage', calibIm);
Screen(window, 'Flip');