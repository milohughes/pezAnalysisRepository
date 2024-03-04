function guiDispatcher_pez3000

clear all
close all
clc
set(0,'ShowHiddenHandles','on')
delete(get(0,'Children'))
set(0,'ShowHiddenHandles','off')

repositoryDir = fullfile(fileparts(mfilename('fullpath')),'MATLAB_functions');
addpath(fullfile(repositoryDir,'Support_Programs'))
addpath(fullfile(repositoryDir,'Current_Versions'))

%%%%% computer and directory variables and information
op_sys = system_dependent('getos');
if strfind(op_sys,'Microsoft Windows 7')
    dm11Dir = [filesep filesep 'dm11' filesep 'cardlab'];
else
    dm11Dir = [filesep 'Volumes' filesep 'cardlab'];
end
if ~exist(dm11Dir,'file')
    error('dm11 access failure')
end
guiVarDir = fullfile(dm11Dir,'Pez3000_Gui_folder','Gui_saved_variables');
version_pathA = fullfile(guiVarDir,'version_reference.txt');
version_pathB = fullfile(repositoryDir,'version_reference.txt');
versionTest
backC = [0.1 0.1 0.1];
hFig = figure('Position',[100 200 300 450],'color',backC,'NumberTitle','off',...
    'menubar','none','colormap',gray(256),'name','flyPez3000 GUI Dispatcher',...
    'handlevisibility','off');
panPos = [.05 .05 .9 .9];
hPan = uipanel('Parent',hFig,'Title','flyPez3000 GUI Dispatcher',...
    'foregroundColor',[.7 .7 1],'fontunits','normalized',...
    'FontSize',0.043,'backgroundcolor',backC,'Position',panPos);

guiOps = {'Experiment Design'
    'Experiment ID Manager'
    'pez3000 Monitor'
    'Raw Data Curation'
    'Analyzed Data Curation'
    'Manual Annotation'
    'Graphing and Visualization'};

btnCt = numel(guiOps);
btnC = [.9 .9 .9];
hBtn = zeros(btnCt,1);
for iterB = 1:btnCt
    posBtn = [.1 .8-(.8/btnCt)*(iterB-1) .8 .8/btnCt];
    hBtn(iterB) = uicontrol(hPan,'style','pushbutton','units','normalized',...
        'Position',posBtn,'string',guiOps{iterB},'fontunits','normalized',...
        'handlevisibility','callback','fontsize',0.4,...
        'backgroundcolor',btnC,'callback',@guiLauncher);
end
set(hFig,'CloseRequestFcn',@myCloseFun)
    function guiLauncher(hObj,~)
        versionTest
        switch find(hBtn == hObj)
            case 1
                Experiment_setup_gui_v2
            case 2
                print_daily_labels_v2
            case 3
                runMonitor_v1
            case 4
                pez3000_curator_v4
            case 5
                disp('under construction...')
            case 6
                Video_viewer_with_analysis_v3
            case 7
%                disp('under construction...')
                graph_layout_gui_v6
        end
    end
    function myCloseFun(~,~)
        hTimers = timerfindall;
        for iT = 1:size(hTimers,2)
            if strcmp(hTimers(iT).Running,'on')
                stop(hTimers(iT))
                java.lang.Thread.sleep(500);
            end
        end
        delete(hTimers)
        set(0,'ShowHiddenHandles','on')
        delete(get(0,'Children'))
        set(0,'ShowHiddenHandles','off')
    end
    function versionTest
        fidVer = fopen(version_pathA,'r');
        Ca = textscan(fidVer,'%s');
        Ca = char(cat(2,Ca{:}'));
        fidVer = fopen(version_pathB,'r');
        Cb = textscan(fidVer,'%s');
        Cb = char(cat(2,Cb{:}'));
        if ~strcmp(Ca,Cb)
            error('Please update Pez3000_Gui_folder')
        end
    end
end
