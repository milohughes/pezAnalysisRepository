% %% Project: Depth-Q Projector - Fly Pez 3000
% % Adapted by Samantha Watkins
% % Date Last Modified:
% % Original Project:
%
% % Project: Deterministic Controller
% %  Principal Investigator: Charles Zucker
% %  Principal Scientist: Jayaram Chandrasekar
% %  Author: Lakshmi Ramasamy, PhD & Jinyang Liu, PhD
% %  Date Created: July 18th 2013
% %  Date Last Modified: July 24th 2013
%
function photoactivationGenerator_v2

clear all
close all
clc

var_pul_width_begin = 60000; % Single Pulse Duration: in ms
var_pul_width_end = 60000; % Single Pulse Duration: in ms
var_pul_count = 1; % period 1 in ms
var_ramp_width = 60000;
var_slope = 1; % pulse width 2 in ms
var_ramp_init = 0; % period 2 in ms
var_tot_dur = 60000; % Total time in ms
var_intensity = 50;
vPulse = [];
zPulse = [];
aPulse = [];
saveDir = [filesep filesep 'DM11' filesep 'cardlab' filesep,...
    'pez3000_variables' filesep 'photoactivation_stimuli'];

% Setting up figure and graph
pulseGui_fig = figure('NumberTitle', 'off', 'MenuBar', 'None',...
    'Name', 'Pulse Train Generator', 'position', [200 200 800 400],...
    'resize', 'off');

pulseGui_ax = axes('parent', pulseGui_fig, 'position', [0.08 0.38 0.84 0.55],...
    'nextPlot', 'replacechildren', 'FontWeight', 'Bold',...
    'color', [0.5 0.9 0.5]);
xlabel(pulseGui_ax, 'Time (ms)', 'FontWeight', 'Bold');
ylabel(pulseGui_ax, 'Light Intensity (%)', 'FontWeight', 'Bold');

%Radio Button Group - Mode Selection
pulseGui_h = uibuttongroup('visible', 'on', 'Position',[0.01 0.01 0.1 0.2],...
    'parent', pulseGui_fig, 'backgroundColor', get(pulseGui_fig, 'color'),...
    'SelectionChangeFcn', @selcbk);
pulseGui_pulse = uicontrol('parent', pulseGui_h, 'style', 'radiobutton', 'string', 'Pulse',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui_fig, 'color'),...
    'units', 'normalized', 'position', [0.02 0.75 0.8 0.2],...
    'HandleVisibility', 'off');
pulseGui_ramp = uicontrol('parent', pulseGui_h, 'style', 'radiobutton', 'string', 'Ramp',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui_fig, 'color'),...
    'units', 'normalized', 'position', [0.02 0.45 0.8 0.2],...
    'HandleVisibility', 'off');
pulseGui_combo = uicontrol('parent', pulseGui_h, 'style', 'radiobutton', 'string', 'Combo',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui_fig, 'color'),...
    'units', 'normalized', 'position', [0.02 0.15 0.8 0.2],...
    'HandleVisibility', 'off');

set(pulseGui_h, 'SelectedObject', []); % No Selection

%Single Pulse Duration, Initial
uicontrol('parent', pulseGui_fig, 'style', 'text', 'string', 'Pulse Width Begin:',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui_fig, 'color'),...
    'units', 'normalized', 'position', [0.13 0.16 0.13 0.05],'HorizontalAlignment','right');
pulseGui_pulseW_begin = uicontrol('parent', pulseGui_fig, 'style', 'edit', 'units', ...
    'normalized', 'position', [0.27 0.165 0.05 0.05],...
    'string', var_pul_width_begin,'CallBack',@updatePlot,'enable','off');

%Single Pulse Duration, Final
uicontrol('parent', pulseGui_fig, 'style', 'text', 'string', 'Pulse Width End:',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui_fig, 'color'),...
    'units', 'normalized', 'position', [0.13 0.11 0.13 0.05],'HorizontalAlignment','right');
pulseGui_pulseW_end = uicontrol('parent', pulseGui_fig, 'style', 'edit', 'units', ...
    'normalized', 'position', [0.27 0.115 0.05 0.05],...
    'string', var_pul_width_end,'CallBack',@updatePlot,'enable','off');

%Period 1
uicontrol('parent', pulseGui_fig, 'style', 'text', 'string', 'Pulse Count:',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui_fig, 'color'),...
    'units', 'normalized', 'position', [0.13 0.06 0.13 0.05],'HorizontalAlignment','right');
pulseGui_pulCount = uicontrol('parent', pulseGui_fig, 'style', 'edit', 'units', 'normalized',...
    'position', [0.27 0.065 0.05 0.05], 'string', var_pul_count,...
    'CallBack',@updatePlot,'enable','off');

%Pulse Intensity
uicontrol('parent', pulseGui_fig, 'style', 'text', 'string', 'Peak Intensity:',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui_fig, 'color'),...
    'units','normalized','position', [0.13 0.01 0.13 0.05],'HorizontalAlignment','right');
pulseGui_peak = uicontrol('parent', pulseGui_fig, 'style', 'edit', 'units', 'normalized',...
    'position', [0.27 0.015 0.05 0.05], 'string', var_intensity,...
    'CallBack',@updatePlot,'enable','off');

%Ramp Width
uicontrol('parent', pulseGui_fig, 'style', 'text', 'string', 'Ramp Width:',...
    'FontWeight', 'Bold', 'backgroundColor',get(pulseGui_fig, 'color'),...
    'units', 'normalized', 'position', [0.39 0.155 0.1 0.05],'HorizontalAlignment','right');
pulseGui_rampW = uicontrol('parent', pulseGui_fig, 'style', 'edit', 'units', 'normalized',...
    'position', [0.5 0.165 0.05 0.05], 'string',var_ramp_width,...
    'CallBack',@updatePlot,'enable','off');

%Total Duration
uicontrol('parent', pulseGui_fig, 'style', 'text', 'string', 'Seq Duration:',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui_fig, 'color'),...
    'units', 'normalized', 'position', [0.39 0.005 0.1 0.05],'HorizontalAlignment','right');
pulseGui_seqDur = uicontrol('parent', pulseGui_fig, 'style', 'edit', 'units', 'normalized',...
    'position', [0.5 0.015 0.05 0.05], 'string', var_tot_dur,...
    'CallBack',@updatePlot,'enable','off');

%Ramp Equation
uicontrol('parent', pulseGui_fig, 'style', 'text', 'string', 'Init Intensity:',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui_fig, 'color'),...
    'units', 'normalized', 'position', [0.39 0.105 0.1 0.05],'HorizontalAlignment','right');
pulseGui_slopeInitH = uicontrol('parent', pulseGui_fig, 'style', 'edit', 'units', 'normalized',...
    'position', [0.5 0.115 0.05 0.05], 'string', var_ramp_init,...
    'CallBack',@updatePlot,'enable','off');

%Save and load variables
uicontrol('parent', pulseGui_fig, 'style', 'pushbutton', 'units', 'normalized',...
    'position', [0.6 0.05 0.12 0.05], 'string', 'Load',...
    'FontWeight', 'Bold', 'CallBack', @loadFun);
pulseGui_saveH = uicontrol('parent', pulseGui_fig, 'style', 'pushbutton', 'units', 'normalized',...
    'position', [0.76 0.05 0.12 0.05], 'string', 'Save',...
    'FontWeight', 'Bold', 'CallBack', @saveFun,'enable','off');

uicontrol(pulseGui_fig,'Style','text','string','UserName:','Units','normalized',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui_fig, 'color'),...
    'HorizontalAlignment','left','position',[0.6 0.15 0.1 0.05],...
    'fontunits','normalized','HandleVisibility','off');
userPath = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables\Saved_User_names.mat';
if exist(userPath,'file')
    userLoading = load(userPath);
    Saved_User_names = userLoading.Saved_User_names;
    saved_variable = Saved_User_names.User_ID;
    saved_variable = [{'select one';'General';'Testing'};saved_variable(:)];
end
hUser = uicontrol(pulseGui_fig,'Style','popupmenu','Units','normalized','HorizontalAlignment','left',...
    'fontsize',8,'string',saved_variable,'position',[0.7 0.155 0.18 0.05],'fontunits','normalized');

%%
% GUI Functions
    function loadFun(~,~)
        [FileName,PathName] = uigetfile([saveDir filesep '*.mat'],'Select the MATLAB code file');
        if FileName ~= 0
            varPath = fullfile(PathName,FileName);
            if exist(varPath,'file')
                varLoad = load(varPath);
%                 fieldnames(varLoad)
                underRef = strfind(FileName,'_');
                userName = FileName(underRef(1)+1:underRef(2)-1);
                userRef = find(strcmp(saved_variable,userName));
                set(hUser,'value',userRef)
                methodName = FileName(1:underRef(1)-1);
                if strcmp('pulse',methodName)
                    set(pulseGui_h,'SelectedObject',pulseGui_pulse)
                    selcbk
                    set(pulseGui_pulseW_begin,'string',varLoad.var_pul_width_begin)
                    set(pulseGui_pulseW_end,'string',varLoad.var_pul_width_end)
                    set(pulseGui_pulCount,'string',varLoad.var_pul_count)
                    set(pulseGui_seqDur,'string',varLoad.var_tot_dur)
                    set(pulseGui_peak,'string',varLoad.var_intensity)
                    updatePlot
                elseif strcmp('ramp',methodName)
                    set(pulseGui_h,'SelectedObject',pulseGui_ramp)
                    selcbk
                    set(pulseGui_rampW,'string',varLoad.var_ramp_width)
                    set(pulseGui_slopeInitH,'string',varLoad.var_ramp_init)
                    set(pulseGui_seqDur,'string',varLoad.var_tot_dur)
                    set(pulseGui_peak,'string',varLoad.var_intensity)
                    updatePlot
                elseif strcmp('combo',methodName)
                    set(pulseGui_h,'SelectedObject',pulseGui_combo)
                    selcbk
                    set(pulseGui_pulseW_begin,'string',varLoad.var_pul_width_begin)
                    set(pulseGui_pulseW_end,'string',varLoad.var_pul_width_end)
                    set(pulseGui_pulCount,'string',varLoad.var_pul_count)
                    set(pulseGui_rampW,'string',varLoad.var_ramp_width)
                    set(pulseGui_slopeInitH,'string',varLoad.var_ramp_init)
                    set(pulseGui_seqDur,'string',varLoad.var_tot_dur)
                    set(pulseGui_peak,'string',varLoad.var_intensity)
                    updatePlot
                else
                    disp('invalid file')
                end
            end
        end
    end
    function saveFun(~,~)
        if vPulse > 20
            error('max pulse count exceeded')
        end
        userVal = get(hUser,'value');
        if userVal == 1
            disp('Select user first')
            return
        end
        refStr = saved_variable{userVal};
        refStr = regexprep(refStr,' ','');
        if get(pulseGui_h,'SelectedObject') == pulseGui_pulse
            savePath = fullfile(saveDir,['pulse_' refStr '_widthBegin' num2str(var_pul_width_begin),...
                '_widthEnd' num2str(var_pul_width_end),'_cycles' num2str(var_pul_count),...
                '_intensity' num2str(var_intensity)]);
            save(savePath,'vPulse','zPulse','aPulse','var_pul_width_begin',...
                'var_pul_count','var_tot_dur','var_intensity','var_pul_width_end')
        elseif get(pulseGui_h,'SelectedObject') == pulseGui_ramp
            savePath = fullfile(saveDir,['ramp_' refStr '_rampWidth' num2str(var_ramp_width),...
                '_initVal' num2str(var_ramp_init) '_finalVal' num2str(var_intensity),...
                '_totalDur' num2str(var_tot_dur)]);
            save(savePath,'var_slope','var_ramp_init',...
                'var_ramp_width','var_tot_dur','var_intensity')
        elseif get(pulseGui_h,'SelectedObject') == pulseGui_combo
            savePath = fullfile(saveDir,['combo_' refStr '_pulseWidthBegin' num2str(var_pul_width_begin),...
                '_pulseWidthEnd' num2str(var_pul_width_end),'_cycles' num2str(var_pul_count),...
                '_rampWidth' num2str(var_ramp_width) '_initVal' num2str(var_ramp_init),...
                '_finalVal' num2str(var_intensity) '_totalDur' num2str(var_tot_dur)]);
            save(savePath,'vPulse','zPulse','aPulse','var_pul_width_begin',...
                'var_pul_count','var_tot_dur','var_intensity',...
                'var_ramp_init','var_ramp_width','var_pul_width_end')
        end
    end

    function selcbk(~, ~)
        set(pulseGui_saveH,'enable','off')
        if get(pulseGui_h,'SelectedObject') == pulseGui_pulse
            %Pulse activated
            set(pulseGui_slopeInitH,'enable','off');
            set(pulseGui_rampW,'enable','off');
            set(pulseGui_pulseW_begin,'enable','on');
            set(pulseGui_pulseW_end,'enable','on');
            set(pulseGui_pulCount,'enable','on')
            set(pulseGui_peak,'enable','on')
            set(pulseGui_seqDur,'enable','on')
        elseif get(pulseGui_h,'SelectedObject') == pulseGui_ramp
            %Ramp activated
            set(pulseGui_pulseW_begin,'enable','off');
            set(pulseGui_pulseW_end,'enable','off');
            set(pulseGui_pulCount,'enable','off');
            set(pulseGui_peak,'enable','on');
            set(pulseGui_slopeInitH,'enable','on');
            set(pulseGui_rampW,'enable','on');
            set(pulseGui_seqDur,'enable','on')
        elseif get(pulseGui_h,'SelectedObject') == pulseGui_combo
            %Combo activated
            set(pulseGui_pulseW_begin,'enable','on');
            set(pulseGui_pulseW_end,'enable','on');
            set(pulseGui_pulCount,'enable','on');
            set(pulseGui_peak,'enable','on');
            set(pulseGui_slopeInitH,'enable','on');
            set(pulseGui_rampW,'enable','on');
            set(pulseGui_seqDur,'enable','on')
        end
    end

    function updatePlot(~,~)
        set(pulseGui_saveH,'enable','on')
        var_pul_width_begin = str2double(get(pulseGui_pulseW_begin,'string')); % Single Pulse Duration: in ms
        var_pul_width_end = str2double(get(pulseGui_pulseW_end,'string')); % Single Pulse Duration: in ms
        var_pul_count = str2double(get(pulseGui_pulCount,'string')); % period 1 in ms
        var_ramp_width = str2double(get(pulseGui_rampW,'string'));
        var_tot_dur = str2double(get(pulseGui_seqDur,'string'));
        var_ramp_init = str2double(get(pulseGui_slopeInitH,'string')); % period 2 in ms
        var_intensity = str2double(get(pulseGui_peak,'string'));
        
%         if var_tot_dur > 2000, var_tot_dur = 2000; end
%         if var_tot_dur < 100, var_tot_dur = 100; end
        if var_intensity > 100, var_intensity = 100; end
        if var_intensity < 0, var_intensity = 0; end
        if var_ramp_init > 100, var_ramp_init = 100; end
        if var_ramp_init < 0, var_ramp_init = 0; end
        if var_ramp_width > var_tot_dur
            var_ramp_width = var_tot_dur;
        end
        if var_pul_width_end > var_tot_dur
            var_pul_width_end = var_tot_dur;
        end
        if var_pul_width_begin > var_pul_width_end
            var_pul_width_begin = var_pul_width_end;
        end
        var_slope = (var_ramp_init-var_intensity)/(0-var_ramp_width);
        
        if get(pulseGui_h,'SelectedObject') == pulseGui_ramp
            pulseGui_x = [0 var_ramp_width var_tot_dur];
            pulseGui_y = [var_ramp_init var_intensity var_intensity];
        else
            cycles = var_pul_count;
            xA = linspace(var_pul_width_begin,var_pul_width_end,cycles);
            if cycles == 1
                xOff = 0;
            else
                xOff = (var_tot_dur-sum(xA))/(cycles-1);
            end
            xOff(xOff < 0) = 0;
            xB = zeros(1,cycles)+xOff;
            xC = [xB;xA];
            xC = repmat(cumsum(xC(:)),1,2)'-xOff;
            pulseGui_x = round(xC(:));
            yA = repmat([0;var_intensity;var_intensity;0],1,cycles);
            if get(pulseGui_h,'SelectedObject') == pulseGui_combo
                yA(2,:) = var_slope.*xB(2,:)+var_ramp_init;
                yA(3,:) = yA(2,:);
                yA(yA > var_intensity) = var_intensity;
            end
            pulseGui_y = round(yA(:));
            if max(pulseGui_x > var_tot_dur)
                pulseGui_y(pulseGui_x >= var_tot_dur) = [];
                pulseGui_x(pulseGui_x >= var_tot_dur) = [];
                pulseGui_x = [pulseGui_x;var_tot_dur;var_tot_dur];
                pulseGui_y = [pulseGui_y;var_intensity;0];
            end
%             if var_pul_count == var_pul_width_begin
%                 ptRefs = [(2:4:size(pulseGui_y,1));(3:4:size(pulseGui_y,1))];
%                 ptRefs = [1 ptRefs(:)',size(pulseGui_y,1)];
%                 pulseGui_x = pulseGui_x(ptRefs);
%                 pulseGui_y = pulseGui_y(ptRefs);
%                 ptRefs = (2:2:size(pulseGui_y,1));
%             else
                ptRefs = [(2:2:size(pulseGui_y,1))];
%             end
            vPulse = numel(ptRefs)
            zPulse = pulseGui_x(ptRefs)
            aPulse = pulseGui_y(ptRefs)
        end
            
        plot(pulseGui_ax,pulseGui_x,pulseGui_y,'-r','LineWidth', 1);
        set(pulseGui_ax,'yLim',[-1 101],'xLim',[-1 var_tot_dur])
        
        set(pulseGui_pulseW_begin,'string',var_pul_width_begin);
        set(pulseGui_pulseW_end,'string',var_pul_width_end);
        set(pulseGui_pulCount,'string',var_pul_count);
        set(pulseGui_rampW,'string',var_ramp_width);
        set(pulseGui_seqDur,'string',var_tot_dur);
        set(pulseGui_slopeInitH,'string',var_ramp_init);
        set(pulseGui_peak,'string',var_intensity);
    end
end
