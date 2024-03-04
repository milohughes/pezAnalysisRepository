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
function varargout = cfgPlTrn_test20140207(s) %#ok<STOUT>
%     if x == 1
%         hello;
%     else
%         bye;
%     end
% end
%
% function hello
%     disp('hello')
% end
%
% function bye
%     disp('bye')
% end

% delete(instrfind)
% instrreset
% clc
% global pulseGui

%idn = 'cfgPlTrn';

% classdef cfgPlTrn < handle
%     properties
pulseGui = struct;
pulseGui.pul_width = 5; % Single Pulse Duration: in ms
pulseGui.per1 = 20; % period 1 in ms
pulseGui.pul_dur = 100;
pulseGui.ramp_width = 200;
pulseGui.tot_dur = 400;
pulseGui.slope = 1; % pulse width 2 in ms
pulseGui.intercept = 0; % period 2 in ms
pulseGui.TotTime = 1000; % Total time in ms
pulseGui.trgMode = 0; % default pulseGui.trgMode value is 0 (0 represent single shot triggering and 1 represents continuous)
pulseGui.intensity = 100;
pulseGui.rampMaxInt = 45;
%t = []; st = [];
%     end
%
% s = serial('COM18');
% s.baudrate=250000;
% s.flowcontrol='none';
% % s.inputbuffersize=100*(128+3);
% % s.BytesAvailableFcnCount=100*(128+3);
% % s.bytesavailablefcnmode = 'terminator';
% set(s,'Terminator','CR/LF');
% set(s,'DataBits',8);
% set(s,'StopBits',2);
% fopen(s);
% disp('test')



%% Setting up figure and graph
pulseGui.fig = figure('NumberTitle', 'off', 'MenuBar', 'None',...
    'Name', 'Pulse Train Generator', 'position', [400 400 800 400],...
    'resize', 'off');

pulseGui.ax = axes('parent', pulseGui.fig, 'position', [0.08 0.32 0.84 0.6],...
    'nextPlot', 'replacechildren', 'FontWeight', 'Bold',...
    'color', [0.5 0.9 0.5]);
xl = xlabel(pulseGui.ax, 'Time (ms)', 'FontWeight', 'Bold');
yl = ylabel(pulseGui.ax, 'Light Intensity (%)', 'FontWeight', 'Bold');

%Radio Button Group - Mode Selection
pulseGui.h = uibuttongroup('visible', 'on', 'Position',[0.01 0.01 0.1 0.2],...
    'parent', pulseGui.fig, 'backgroundColor', get(pulseGui.fig, 'color'),...
    'SelectionChangeFcn', @selcbk);%, 'Visible', 'on');


pulseGui.ui16 = uicontrol('parent', pulseGui.h, 'style', 'radiobutton', 'string', 'Pulse',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui.fig, 'color'),...
    'units', 'normalized', 'position', [0.02 0.75 0.8 0.2],...
    'HandleVisibility', 'off');

pulseGui.ui17 = uicontrol('parent', pulseGui.h, 'style', 'radiobutton', 'string', 'Ramp',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui.fig, 'color'),...
    'units', 'normalized', 'position', [0.02 0.25 0.8 0.2],...
    'HandleVisibility', 'off');

set(pulseGui.h, 'SelectedObject', []); % No Selection

%Single Pulse Duration
pulseGui.ui1 = uicontrol('parent', pulseGui.fig, 'style', 'text', 'string', 'Single Pulse Width:',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui.fig, 'color'),...
    'units', 'normalized', 'position', [0.165 0.14 0.1 0.1]);

pulseGui.ui2 = uicontrol('parent', pulseGui.fig, 'style', 'edit', 'units', ...
    'normalized', 'position', [0.26 0.16 0.05 0.05],...
    'string', pulseGui.pul_width, 'Callback', @updatepul_width);

%Period 1
pulseGui.ui3 = uicontrol('parent', pulseGui.fig, 'style', 'text', 'string', 'Period:',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui.fig, 'color'),...
    'units', 'normalized', 'position', [0.17 0.11 0.1 0.05]);

pulseGui.ui4 = uicontrol('parent', pulseGui.fig, 'style', 'edit', 'units', 'normalized',...
    'position', [0.26 0.115 0.05 0.05], 'string', pulseGui.per1,...
    'CallBack', @updatePer1Val);

%Pulse Width 2
pulseGui.ui5 = uicontrol('parent', pulseGui.fig, 'style', 'text', 'string', 'Duration:',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui.fig, 'color'),...
    'units', 'normalized', 'position', [0.14 0.06 0.16 0.05]);

pulseGui.ui6 = uicontrol('parent', pulseGui.fig, 'style', 'edit', 'units', 'normalized',...
    'position', [0.26 0.07 0.05 0.05], 'string', pulseGui.pul_dur,...
    'CallBack', @updatepul_durVal);

%Pulse Intensity
pulseGui.ui7 = uicontrol('parent', pulseGui.fig, 'style', 'text', 'string', 'Intensity:',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui.fig, 'color'),...
    'units','normalized','position', [0.14 0.01 0.16 0.05]);

pulseGui.ui8 = uicontrol('parent', pulseGui.fig, 'style', 'edit', 'units', 'normalized',...
    'position', [0.26 0.01 0.05 0.05], 'string', pulseGui.intensity,...
    'CallBack', @intensity);

%Ramp Width
pulseGui.ui22 = uicontrol('parent', pulseGui.fig, 'style', 'text', 'string', 'Ramp Width:',...
    'FontWeight', 'Bold', 'backgroundColor',get(pulseGui.fig, 'color'),...
    'units', 'normalized', 'position', [0.32 0.155 0.1 0.05]);

pulseGui.ui23 = uicontrol('parent', pulseGui.fig, 'style', 'edit', 'units', 'normalized',...
    'position', [0.42 0.16 0.04 0.05], 'string',pulseGui.ramp_width,...
    'CallBack', @updateramp_widthVal);

%Total Duration
pulseGui.ui24 = uicontrol('parent', pulseGui.fig, 'style', 'text', 'string', 'Seq Duration:',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui.fig, 'color'),...
    'units', 'normalized', 'position', [0.32 0.005 0.1 0.05]);

pulseGui.ui25 = uicontrol('parent', pulseGui.fig, 'style', 'edit', 'units', 'normalized',...
    'position', [0.42 0.01 0.04 0.05], 'string', pulseGui.tot_dur,...
    'CallBack', @updatetot_durVal);

%Ramp Equation
pulseGui.ui18 = uicontrol('parent', pulseGui.fig, 'style', 'text', 'string', 'Ramp Eqn:',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui.fig, 'color'),...
    'units', 'normalized', 'position', [0.32 0.105 0.1 0.05]);

pulseGui.ui19 = uicontrol('parent', pulseGui.fig, 'style', 'edit', 'units', 'normalized',...
    'position', [0.42 0.11 0.03 0.05], 'string', pulseGui.slope,...
    'CallBack', @updateSlopeVal);

pulseGui.ui20 = uicontrol('parent', pulseGui.fig, 'style', 'text', 'string','x + ',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui.fig, 'color'),...
    'units', 'normalized', 'position', [0.45 0.105 0.025 0.05]);

pulseGui.ui21 = uicontrol('parent', pulseGui.fig, 'style', 'edit', 'units', 'normalized',...
    'position', [0.475 0.11 0.02 0.05], 'string', pulseGui.intercept,...
    'CallBack', @updateInterceptVal);

pulseGui.ui26 = uicontrol('parent', pulseGui.fig, 'style', 'text', 'string', 'Ramp Max Intensity',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui.fig, 'color'),...
    'units', 'normalized', 'position', [0.31 0.055 0.15 0.05]);

pulseGui.ui27 = uicontrol('parent', pulseGui.fig, 'style', 'edit', 'units', 'normalized',...
    'position', [0.46 0.06 0.04 0.05], 'string', pulseGui.rampMaxInt,...
    'CallBack', @rampMaxIntensity);

%Plot End Time
pulseGui.ui9 = uicontrol('parent', pulseGui.fig, 'style', 'text', 'string', 'Plot End Time:',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui.fig, 'color'),...
    'units', 'normalized', 'position', [0.55 0.1 0.1 0.05]);

pulseGui.ui10 = uicontrol('parent', pulseGui.fig, 'style', 'edit', 'units', 'normalized',...
    'position', [0.66 0.1 0.08 0.05], 'string', pulseGui.TotTime,...
    'CallBack', @updateTotTimeVal);

pulseGui.ui11 = uicontrol('parent', pulseGui.fig, 'style', 'pushbutton', 'units', 'normalized',...
    'position', [0.85 0.1 0.08 0.05], 'string', 'Download',...
    'FontWeight', 'Bold', 'CallBack', @download, 'ForegroundColor', [1 0.2 0.5]);

pulseGui.ui13 = uicontrol('parent', pulseGui.fig, 'style', 'text', 'string', 'Trg. Mode:',...
    'FontWeight', 'Bold', 'backgroundColor', get(pulseGui.fig, 'color'),...
    'units', 'normalized', 'position', [0.55 0.15 0.1 0.05]);

pulseGui.ui14 = uicontrol('parent', pulseGui.fig, 'style', 'togglebutton', 'units', 'normalized',...
    'position', [0.66 0.155 0.08 0.05], 'string', 'One shot',...
    'FontWeight', 'Bold', 'CallBack', @updateTrgMode);

pulseGui.ui12 = uicontrol('parent', pulseGui.fig, 'style', 'pushbutton', 'units', 'normalized',...
    'position', [0.75 0.155 0.08 0.05], 'string', 'Trigger',...
    'FontWeight', 'Bold', 'CallBack', @trg, 'ForegroundColor', [0 0 0]);

pulseGui.ui15 = uicontrol('parent', pulseGui.fig, 'style', 'pushbutton', 'units', 'normalized',...
    'position', [0.85 0.155 0.08 0.05], 'string', 'STOP',...
    'FontWeight', 'Bold', 'CallBack', @stop, 'ForegroundColor', [1 0.4 0.4]);

set(pulseGui.fig,'CloseRequestFcn',@closefcn)
%% GUI Functions

    function download(hObject, ~)
        set(pulseGui.ui11, 'Enable', 'off');
        pause(0.001);
        
        scale = 2;
        pulseGui.x = [];
        pulseGui.y = [];
        pulseGui.x(1:pulseGui.tot_dur*scale) = 0;
        pulseGui.y(1:pulseGui.tot_dur*scale) = 0;
        cnt1 = 0; cnt2 = 0; cnt3 = 0;
        for cnt = 1:pulseGui.tot_dur*scale
            pulseGui.x(cnt) = cnt/scale;
            
            cnt3=cnt3+1;
            cnt2=cnt2+1;
            cnt1=cnt1+1;
            
            if(cnt3/scale > pulseGui.tot_dur)
                cnt3 = 1;
                cnt2 = 1;
                cnt1 = 1;
            end
            
            if(cnt1/scale > pulseGui.per1)
                cnt1=1;
            end
            
            if(cnt3/scale <= pulseGui.ramp_width && cnt3/scale >= pulseGui.pul_dur)
                pulseGui.y(cnt) = pulseGui.slope*100*(pulseGui.x(cnt3)/pulseGui.TotTime) + pulseGui.intercept;
                if (pulseGui.y(cnt) > pulseGui.rampMaxInt)
                    pulseGui.y(cnt) = pulseGui.rampMaxInt;
                end
            elseif(cnt1/scale <= pulseGui.pul_width && cnt2/scale <= pulseGui.pul_dur)
                pulseGui.y(cnt) = pulseGui.intensity;
            else
                pulseGui.y(cnt) = 0;
            end
            
        end
        
        
        pulseGui.t = [];
        pulseGui.st = [];
        cnt = 1;
        wCnt = 1;
        while pulseGui.x(cnt) < pulseGui.tot_dur
            if(cnt == 1)
                cVal = pulseGui.y(cnt);
                pulseGui.t(wCnt) = floor(pulseGui.x(cnt));
                pulseGui.st(wCnt) = cVal;
            else
                pVal = cVal;
                cVal = pulseGui.y(cnt);
                if(pVal ~= cVal)
                    wCnt = wCnt+1;
                    pulseGui.t(wCnt) = floor(pulseGui.x(cnt));
                    pulseGui.st(wCnt) = cVal;
                end
            end
            cnt = cnt+1;
        end
        wCnt = wCnt+1;
        pulseGui.t(wCnt) = floor(pulseGui.tot_dur);
        pulseGui.st(wCnt) = 0;
        
        disp(size(pulseGui.t));
        
        if(numel(pulseGui.t) > 0)
            if(get(pulseGui.ui16,'Value') == get(pulseGui.ui16,'Max'))
                fwrite(s, sprintf('%s %s ','Z','p'));
                
                v = numel(pulseGui.t);
                fwrite(s, sprintf('%s ',num2str(v)));
                for cnt=1:numel(pulseGui.t)
                    z = pulseGui.t(cnt)
                    fwrite(s, sprintf('%s ',num2str(z)));
                    a = pulseGui.st(cnt)
                    fwrite(s, sprintf('%s ',num2str(a)));
                end
                pause(.001);
                fwrite(s, sprintf('\r'));
                %                     fwrite(s, sprintf('%s %s %s %s %s %s %s %s %s %s %s %s %s\r','Z','p','5','0','8','40','0','100','8','140','0','1000','0'));
                %                     fwrite(s, sprintf('%s %s\r','Z','m'));
            else
                fwrite(s, sprintf('%s %s ','Z','r'));
                %                     fwrite(s, sprintf('%s ',num2str(0.2*10)));
                %                     fwrite(s, sprintf('%s ',num2str(0)));
                %                     fwrite(s, sprintf('%s ',num2str(10000)));
                %                     fwrite(s, sprintf('%s ',num2str(10000)));
                %                     fwrite(s, sprintf('%s ',num2str(48000)));
                
                fwrite(s, sprintf('%s ',num2str(pulseGui.slope*10)));
                fwrite(s, sprintf('%s ',num2str(pulseGui.intercept)));
                fwrite(s, sprintf('%s ',num2str(pulseGui.ramp_width)));
                fwrite(s, sprintf('%s ',num2str(pulseGui.tot_dur)));
                fwrite(s, sprintf('%s ',num2str(pulseGui.rampMaxInt*100)));
                pause(.001);
                fwrite(s, sprintf('\r'));
            end
        end
        set(pulseGui.ui11, 'Enable', 'On');
        msgbox('Download Complete!');
    end


    function trg(~, ~)
        if(get(pulseGui.ui16,'Value') == get(pulseGui.ui16,'Max'))
            fwrite(s, sprintf('%s %s\r','Z','s'));
        else
            fwrite(s, sprintf('%s %s\r','Z','v'));
        end
        disp('sent');
        %             set(pulseGui.ui12, 'Enable', 'off');
        %             pulseGui.ser = serial(pulseGui.portNum);
        %             fopen(pulseGui.ser);
        %             cmd = [255 'z' 's'];
        %             fwrite(s, cmd);
        %             fclose(pulseGui.ser);
        %             set(pulseGui.ui12, 'Enable', 'on');
    end

    function stop(~, ~)
        set(pulseGui.ui15, 'Enable', 'off');
        fwrite(s, sprintf('%s %s\r','Z','t'));
        disp('stop')
        %             pulseGui.ser = serial(pulseGui.portNum);
        %             fopen(pulseGui.ser);
        %             cmd = [255 'z' 't'];
        %             fwrite(s, cmd);
        %             fclose(pulseGui.ser);
        set(pulseGui.ui15, 'Enable', 'on');
    end

    function updateTrgMode(~, ~)
        pulseGui.trgMode = get(pulseGui.ui14, 'value');
        if(pulseGui.trgMode == 1)
            set(pulseGui.ui14, 'String', 'Cont.');
        else
            set(pulseGui.ui14, 'String', 'One shot');
        end
        pulseGui.updateVal;
    end

    function selcbk(~, ~)
        if(get(pulseGui.ui16,'Value') == get(pulseGui.ui16,'Max'))
            %Pulse activated
            set(pulseGui.ui19, 'string', '0');
            set(pulseGui.ui21, 'string', '0');
            set(pulseGui.ui23, 'string', '0');
            set(pulseGui.ui27, 'string', '0');
            set(pulseGui.ui2, 'string', '5');
            set(pulseGui.ui4, 'string', '20');
            set(pulseGui.ui6, 'string', '100');
            set(pulseGui.ui8, 'string', '100');
            set(pulseGui.ui19, 'backgroundColor', get(pulseGui.fig, 'color'));
            set(pulseGui.ui21, 'backgroundColor', get(pulseGui.fig, 'color'));
            set(pulseGui.ui23, 'backgroundColor', get(pulseGui.fig, 'color'));
            set(pulseGui.ui27, 'backgroundColor', get(pulseGui.fig, 'color'));
            set(pulseGui.ui2, 'backgroundColor', 'w');
            set(pulseGui.ui4, 'backgroundColor', 'w');
            set(pulseGui.ui6, 'backgroundColor', 'w');
            set(pulseGui.ui8, 'backgroundColor', 'w');
            pulseGui.slope = 0;
            pulseGui.intercept = 0;
            pulseGui.rampMaxInt = 0;
            pulseGui.ramp_width = 0;
            pulseGui.pul_width = 5;
            pulseGui.intensity = 100;
            pulseGui.per1 = 20;
            pulseGui.pul_dur = 100;
        else
            %Ramp activated
            set(pulseGui.ui2, 'string', '0');
            set(pulseGui.ui4, 'string', '0');
            set(pulseGui.ui6, 'string', '0');
            set(pulseGui.ui8, 'string', '0');
            set(pulseGui.ui19, 'string', '1');
            set(pulseGui.ui21, 'string', '0');
            set(pulseGui.ui23, 'string', '200');
            set(pulseGui.ui27, 'string', '45');
            set(pulseGui.ui2, 'backgroundColor', get(pulseGui.fig, 'color'));
            set(pulseGui.ui4, 'backgroundColor', get(pulseGui.fig, 'color'));
            set(pulseGui.ui6, 'backgroundColor', get(pulseGui.fig, 'color'));
            set(pulseGui.ui8, 'backgroundColor', get(pulseGui.fig, 'color'));
            set(pulseGui.ui19, 'backgroundColor', 'w');
            set(pulseGui.ui21, 'backgroundColor', 'w');
            set(pulseGui.ui23, 'backgroundColor', 'w');
            set(pulseGui.ui27, 'backgroundColor', 'w');
            pulseGui.pul_width = 0;
            pulseGui.intensity = 0;
            pulseGui.rampMaxInt = 45;
            pulseGui.per1 = 0;
            pulseGui.pul_dur = 0;
            pulseGui.slope = 1;
            pulseGui.intercept = 0;
            pulseGui.ramp_width = 200;
        end
    end

    function updatepul_width(~, ~)
        val = str2double(get(pulseGui.ui2, 'string'));
        if(val > pulseGui.per1)
            val = pulseGui.per1;
        end
        pulseGui.pul_width = val;
        updateVal;
        pause(0.001);
        plotGraph;
    end

    function updatePer1Val(~, ~)
        val = str2double(get(pulseGui.ui4, 'string'));
        if(val > pulseGui.pul_dur)
            val = pulseGui.pul_dur;
        end
        pulseGui.per1 = val;
        updateVal;
        plotGraph;
    end

    function updatepul_durVal(~, ~)
        val = str2double(get(pulseGui.ui6, 'string'));
        if(val > pulseGui.tot_dur)
            val = pulseGui.tot_dur;
        end
        pulseGui.pul_dur = val;
        updateVal;
        plotGraph;
    end

    function intensity(~, ~)
        val = str2double(get(pulseGui.ui8, 'string'));
        if(val > 100)
            val = 100;
        end
        pulseGui.intensity = val;
        updateVal;
        plotGraph;
    end

    function rampMaxIntensity(~, ~)
        val = str2double(get(pulseGui.ui27, 'string'));
        if (val > 48)
            val = 48;
        end
        pulseGui.rampMaxInt = val;
        updateVal;
        plotGraph;
    end

    function updateramp_widthVal(~, ~)
        val = str2double(get(pulseGui.ui23, 'string'));
        if(val > pulseGui.tot_dur)
            val = pulseGui.tot_dur;
        end
        pulseGui.ramp_width = val;
        updateVal;
        plotGraph;
    end

    function updatetot_durVal(~, ~)
        val = str2double(get(pulseGui.ui25, 'string'));
        if(val > pulseGui.TotTime)
            val = pulseGui.TotTime;
        end
        pulseGui.tot_dur = val;
        updateVal;
        plotGraph;
    end

    function updateSlopeVal(~, ~)
        val = str2double(get(pulseGui.ui19, 'string'));
        pulseGui.slope = val;
        updateVal;
        plotGraph;
    end

    function updateInterceptVal(~, ~)
        val = str2double(get(pulseGui.ui21, 'string'));
        if(val > 100)
            val = 100;
        end
        pulseGui.intercept = val;
        updateVal;
        plotGraph;
    end

    function updateTotTimeVal(~, ~)
        val = str2double(get(pulseGui.ui10, 'string'));
        if(val < pulseGui.tot_dur)
            val = pulseGui.tot_dur;
        end
        pulseGui.TotTime = val;
        updateVal;
        plotGraph;
    end

%% Closing

    function closefcn(src,~)
        delete(pulseGui.fig)
%         set(pulseGui.fig, 'visible', 'off');
        %         fclose('all');
        % %        stop(ai);
        % %        delete(ai);
        %        delete(s);
        %        delete(src);
    end




    function plotGraph
        
        scale = 100;
        pulseGui.x = [];
        pulseGui.y = [];
        
        cnt1 = 0; cnt2 = 0; cnt3 = 0;
        
        pulseGui.x(1) = 0;
        pulseGui.y(1) = 0;
        
        pulseGui.x(2) = 0;
        pulseGui.y(2) = 0;
        
        for cnt = 3:pulseGui.TotTime*scale+2
            if((cnt/scale) > pulseGui.TotTime)
                break;
            end
            pulseGui.x(cnt) = cnt/scale;
            
            cnt3=cnt3+1;
            cnt2=cnt2+1;
            cnt1=cnt1+1;
            
            if(cnt3/scale > pulseGui.tot_dur)
                cnt3 = 1;
                cnt2 = 1;
                cnt1 = 1;
            end
            
            if(cnt1/scale > pulseGui.per1)
                cnt1=1;
            end
            
            if(cnt3/scale <= pulseGui.ramp_width && cnt3/scale >= pulseGui.pul_dur)
                pulseGui.y(cnt) = pulseGui.slope*100*(pulseGui.x(cnt3)/pulseGui.TotTime) + pulseGui.intercept;
                if(pulseGui.y(cnt) > pulseGui.rampMaxInt)
                    pulseGui.y(cnt) = pulseGui.rampMaxInt;
                end
                
            elseif(cnt1/scale <= pulseGui.pul_width && cnt2/scale <= pulseGui.pul_dur)
                pulseGui.y(cnt) = pulseGui.intensity;
            else
                pulseGui.y(cnt) = 0;
            end
        end
        
        plot(pulseGui.ax, pulseGui.x,pulseGui.y, '-r', 'LineWidth', 1);
        xlabel(pulseGui.ax, 'Time (ms)');
        ylabel(pulseGui.ax, 'Light Intensity (%)');
        
        par.pulseGui.pul_width = pulseGui.pul_width;
        par.pulseGui.pul_dur = pulseGui.pul_dur;
        par.pulseGui.intensity = pulseGui.intensity;
        par.pulseGui.rampMaxInt = pulseGui.rampMaxInt;
        par.pulseGui.ramp_width = pulseGui.ramp_width;
        par.pulseGui.slope = pulseGui.slope;
        par.pulseGui.per1 = pulseGui.per1;
        par.pulseGui.tot_dur = pulseGui.tot_dur;
        par.pulseGui.intercept = pulseGui.intercept;
        par.pulseGui.TotTime = pulseGui.TotTime;
        par.pulseGui.trgMode = pulseGui.trgMode; %#ok<STRNU>
        
        save('plsTrnParam.mat', '-struct', 'par');
    end

    function updateVal
        
        set(pulseGui.ui2, 'string', num2str(pulseGui.pul_width));
        set(pulseGui.ui4, 'string', num2str(pulseGui.per1));
        set(pulseGui.ui6, 'string', num2str(pulseGui.pul_dur));
        set(pulseGui.ui8, 'string', num2str(pulseGui.intensity));
        set(pulseGui.ui23, 'string', num2str(pulseGui.ramp_width));
        set(pulseGui.ui25, 'string', num2str(pulseGui.tot_dur));
        set(pulseGui.ui27, 'string', num2str(pulseGui.rampMaxInt));
        set(pulseGui.ui19, 'string', num2str(pulseGui.slope));
        set(pulseGui.ui21, 'string', num2str(pulseGui.intercept));
        set(pulseGui.ui10, 'string', num2str(pulseGui.TotTime));
        set(pulseGui.ui14, 'value', pulseGui.trgMode);
    end

    function readParam
        
        if(exist('plsTrnParam.mat', 'file'))
            par = load('plsTrnParam.mat');
            pulseGui.pul_width = par.pulseGui.pul_width;
            pulseGui.pul_dur = par.pulseGui.pul_dur;
            pulseGui.intensity = par.pulseGui.intensity;
            pulseGui.ramp_width = par.pulseGui.ramp_width;
            pulseGui.slope = par.pulseGui.slope;
            pulseGui.pulseGui.per1 = par.pulseGui.per1;
            pulseGui.pulseGui.tot_dur = par.pulseGui.tot_dur;
            pulseGui.intercept = par.pulseGui.intercept;
            pulseGui.TotTime = par.pulseGui.TotTime;
            pulseGui.trgMode = par.pulseGui.trgMode;
        end
        pulseGui.updateVal;
    end
end
