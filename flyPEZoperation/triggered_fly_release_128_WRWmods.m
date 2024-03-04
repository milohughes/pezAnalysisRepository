%triggered_fly_release is a gui that controls the motor settings and
%actions of the FlyPez. In addition, an updating display of the linear
%photodiode array is plotted.

%For each computer, s=serial('COMX') will have to be changed to the
%appropriate value of X, which can be found in the device manager.

%Using a USB nidaq device, triggers on a digital
%line will call the release fly function.


function varargout = triggered_fly_release_128_WRWmods(varargin) %#ok<STOUT>
delete(instrfind)
instrreset
clc
global gui

idn = 'triggered_fly_release';
open1 = 80;
block1 = 90;
light1 = 20;
shadow = 225;
gap = 2;
setTempFan = 26;
gatestart = 0;
gateend = 0;
x = 114;
x2 = 94;
y = 0:270;

%Setup the USB nidaq trigger over the PFIO port. The analog object gives
%callback functionality that the digital object lacks.
% ai = analoginput('nidaq','Dev2');
% addchannel(ai,0);
% set(ai,'SampleRate',10);
% set(ai,'SamplesPerTrigger',10)
% set(ai,'TriggerType','HwDigital')
% set(ai,'HwDigitalTriggerSource', 'PFI0'); %Hookup the digital line to the PFI0 Line.
% set(ai,'TriggerCondition','PositiveEdge');
% set(ai,'TriggerConditionValue',4.5);
% set(ai,'TriggerFcn',@hReleaseButtonCallback);
% set(ai,'TriggerRepeat',Inf)
% start(ai);

% Setup the serial
delete(instrfindall)

s=serial('COM4');
set(s,'baudrate',250000,'inputbuffersize',100*(128+3),...
    'BytesAvailableFcnCount',100*(128+3),'bytesavailablefcn',...
    @receiveData,'Terminator','CR/LF','StopBits',2);
fopen(s);

%% Setting up figure and graph
gui.fig = figure('tag','TAOS1402','numbertitle','off','menubar','none','name',idn,'visible','off', ...
                 'position',[400,50,600,800]);
gui.axes1 = axes('xtick',[1, 128],'ytick',[0, 127],'xticklabel',[0, 128],'yticklabel',[0, 127], ...
                 'xlim',[1 128],'ylim',[0 275],'position',[.05 .13 .90 .3],'nextplot','add');
gui.fig = get(gui.axes1,'parent');


       %     gui.axes1=get(hline5,'parent');
set(gui.fig,'CloseRequestFcn',@closefcn);

%% Graph Threshold Values
gui.shadowth = uicontrol('Parent',gui.fig,'Style','edit','Units','normalized','HandleVisibility','callback',...
                       'String',num2str(shadow),'Position',[0.3 0.06 0.08 0.04],'Callback',@hshadowth,'background','w');
gui.shadowtxt = uicontrol('Parent',gui.fig,'Style','text','Units','normalized','String', 'Set Shadow Threshold here:',...
                          'Position',[0.04 0.03 0.25 0.06]);
gui.gapth = uicontrol('Parent',gui.fig,'Style','edit','Units','normalized','HandleVisibility','callback',...
                       'String',gap,'Position',[0.68 0.06 0.08 0.04],'Callback',@hgapth,'background','w'); %Add correct initial value
gui.gaptxt = uicontrol('Parent',gui.fig,'Style','text','Units','normalized','String','Set Gap Threshold here:',...
                       'Position',[0.45 0.03 0.21 0.06]);
                   
%% Random buttons
gui.release = uicontrol('Parent', gui.fig,'Units','normalized','HandleVisibility','callback', ...
                      'Position',[0.63 0.88 0.14 0.05],'String','Release fly','Callback', @hReleaseButtonCallback);
gui.find=uicontrol('Parent', gui.fig,'Units','normalized','HandleVisibility','callback', ...
                      'Position',[0.80 0.88 0.14 0.05],'String','Find gates','Callback', @hFindButtonCallback);
gui.auto = uicontrol('Parent', gui.fig,'Style','togglebutton','Units','normalized','HandleVisibility','callback', ...
                      'BackGroundColor','green', ...
                      'Value',0,'Position',[0.63 0.94 0.14 0.05],'String','Manual release','Callback', @hAutoButtonCallback);
gui.image = uicontrol('Parent', gui.fig,'Style','togglebutton','Units','normalized','HandleVisibility','callback', ...
                      'BackGroundColor','green', ...
                      'Value',0,'Position',[0.80 0.94 0.14 0.05],'String','Image data','Callback', @hImageButtonCallback);


%% Manually Selecting Gate Mode
gui.buttons = uibuttongroup('Title','Gate Mode','Position',[0.05 0.82 .55 .08]);
% Create three radio buttons in the button group.
u0 = uicontrol('Style','Radio','Units','normalized','String','Running',...
    'pos',[0.0 0.25 0.20 0.50],'parent',gui.buttons,'HandleVisibility','off');
u1 = uicontrol('Style','Radio','Units','normalized','String','Opened',...
    'pos',[0.2 0.25 0.20 0.50],'parent',gui.buttons,'HandleVisibility','off');
u2 = uicontrol('Style','Radio','Units','normalized','String','Blocked',...
    'pos',[0.4 0.25 0.20 0.50],'parent',gui.buttons,'HandleVisibility','off');
u3 = uicontrol('Style','Radio','Units','normalized','String','Closed',...
    'pos',[0.6 0.25 0.20 0.50],'parent',gui.buttons,'HandleVisibility','off');
u4 = uicontrol('Style','Radio','Units','normalized','String','Cleaning',...
    'pos',[0.8 0.25 0.20 0.50],'parent',gui.buttons,'HandleVisibility','off');
% Initialize some button group properties. 
set(gui.buttons,'SelectionChangeFcn',@selcbk);
set(gui.buttons,'SelectedObject',u0);

%% Light Control
gui.light = uipanel('Title','Light Control','Position',[0.05 0.65 .5 .183]);
gui.front = uicontrol('Parent',gui.light,'Style','text','Units','normalized','String','Front',...
                      'Position',[0 0.75 0.1 0.1]);
gui.intfront = uicontrol('Parent',gui.light,'Style','slider','Units','normalized','HandleVisibility','callback',...
                         'Min',0,'Max',100,'Value',light1,'Position',[0.1 0.72 0.41 0.18],'Callback',@hintfront);
gui.lightfront = uicontrol('Parent', gui.light,'Style','edit','Units','normalized','HandleVisibility','callback', ...
                    'String',num2str(get(gui.intfront,'Value')),'Position',[0.51 0.72 0.08 0.18],...
                    'Callback',@hlightfront,'background','w');     
gui.back = uicontrol('Parent',gui.light,'Style','text','Units','normalized','String','Back',...
                     'Position',[0 0.45 0.1 0.1]);
gui.intback = uicontrol('Parent', gui.light,'Style','slider','Units','normalized','HandleVisibility','callback',...
                        'Min',0,'Max',100,'Value',light1,'Position',[0.1 0.4 0.41 0.18],'Callback',@hintback);
gui.lightback = uicontrol('Parent', gui.light,'Style','edit','Units','normalized','HandleVisibility','callback',...
                          'String',num2str(get(gui.intback,'Value')),'Position',[0.51 0.4 0.08 0.18],...
                          'Callback',@hlightback,'background','w');
gui.frontlights = uicontrol('Parent', gui.light,'Units','normalized','HandleVisibility','callback', ...
                      'String','Set Front Lights','Position',[0.6 0.7 0.28 0.23],'Callback', @hfrontLights);
gui.backlights = uicontrol('Parent',gui.light,'Units','normalized','HandleVisibility','callback',...
                           'String','Set Back Lights','Position',[0.6 0.38 0.28 0.23],'Callback', @hbackLights);

%% Fan Control                
gui.fan = uipanel('Title','Fan Intensity Control','Position',[0.5 0.65 .45 .183]);
gui.fanslide = uicontrol('Parent',gui.fan,'Style','slider','Units','normalized','HandleVisibility','callback',...
                         'Min',0,'Max',100,'Value',50,'Position',[0.09 0.6 0.41 0.18],'Callback',@hfanslide);
gui.fanedit = uicontrol('Parent', gui.fan,'Style','edit','Units','normalized','HandleVisibility','callback', ...
                    'String',num2str(get(gui.fanslide,'Value')),'Position',[0.5 0.6 0.09 0.18],'Callback',@hfanEdit,...
                    'background','w');                     
gui.setfan = uicontrol('Parent', gui.fan,'Units','normalized','HandleVisibility','callback', ...
                      'String','Set Fan','Position',[0.7 0.7 0.18 0.23],'Callback', @hSetFanCallback);
gui.fanbutton = uicontrol('Parent', gui.fan,'Style','togglebutton','Units','normalized','HandleVisibility','callback', ...
                     'BackGroundColor','green',...
                     'Value',0,'Position',[0.7 0.42 0.18 0.23],'String','Fan On','Callback',@hfan);                 

%% Gate Position Control
gui.panel = uipanel('Title','Gate position control','Position',[0.05 0.58 .9 .125]);

gui.text1 = uicontrol('Parent', gui.panel,'Style','text','Units','normalized','HandleVisibility','callback', ...
                      'String','Open position','Position',[0.08 0.8 0.19 0.15]);
gui.text2 = uicontrol('Parent', gui.panel,'Style','text','Units','normalized','HandleVisibility','callback', ...
                      'String','Block position','Position',[0.48 0.8 0.19 0.15]);
gui.open1slider = uicontrol('Parent', gui.panel,'Style','slider','Units','normalized','HandleVisibility','callback', ...
                      'Min',0,'Max',100,'Value',open1,'SliderStep',[.01 .1],'Position',[0.05 0.45 0.25 0.22], ...
                      'Callback', @hOpen1Callback);
gui.open1edit = uicontrol('Parent', gui.panel,'Style','edit','Units','normalized','HandleVisibility','callback', ...
                    'String',num2str(get(gui.open1slider,'Value')),'Position',[0.3 0.45 0.05 0.22],...
                    'Callback',@hOpen1EditCallback,'background','w');
gui.block1slider=uicontrol('Parent', gui.panel,'Style','slider','Units','normalized','HandleVisibility','callback', ...
                      'Min',0,'Max',100,'Value',block1,'SliderStep',[.01 .1],'Position',[0.45 0.45 0.25 0.22], ...
                      'Callback', @hBlock1Callback);
gui.block1edit = uicontrol('Parent', gui.panel,'Style','edit','Units','normalized','HandleVisibility','callback', ...
                    'String',num2str(get(gui.block1slider,'Value')),'Position',[0.70 0.45 0.05 0.22],...
                    'Callback',@hBlock1EditCallback,'background','w');
gui.setgate1 = uicontrol('Parent', gui.panel,'Units','normalized','HandleVisibility','callback', ...
                      'String','Set Gate 1','Position',[0.80 0.45 0.14 0.25],'Callback', @hSetGate1Callback);

%% Gate State Indicators                  
gui.gates = uipanel('Title','Gate State','Position',[0.05 0.45 .9 .15]);
gui.gate1 = uibuttongroup('Parent', gui.gates,'Title','Gate 1','Position',[0.04 0.05 .28 .9]);
set(gui.gate1,'SelectionChangeFcn',@gateselcbk);

gui.state1o = uicontrol('Style','Radio','Units','normalized','String','Opened',...
    'pos',[0.05 0.68 0.90 0.28],'parent',gui.gate1,'HandleVisibility','off');
gui.state1b = uicontrol('Style','Radio','Units','normalized','String','Blocked',...
    'pos',[0.05 0.36 0.90 0.28],'parent',gui.gate1,'HandleVisibility','off');
gui.state1c = uicontrol('Style','Radio','Units','normalized','String','Closed',...
    'pos',[0.05 0.04 0.90 0.28],'parent',gui.gate1,'HandleVisibility','off');
gui.state1h = uicontrol('Style','Radio','Units','normalized','String','Cleaning',...
    'pos',[0.5 0.68 0.5 0.28],'parent',gui.gate1,'HandleVisibility','off');

%% Sweeper Calibration
gui.calibrate = uipanel('Title','Sweeper Control','Position',[0.46 0.45 0.25 0.15]);
gui.calbutton = uicontrol('Parent',gui.calibrate,'Style','togglebutton','Units','normalized','HandleVisibility','callback', ...
                          'String','Calibrate','Position',[0.25 0.6 0.5 0.3],'Callback',@hCalibrate);
gui.sweep = uicontrol('Parent', gui.calibrate,'Units','normalized','HandleVisibility','callback',...
                      'Position',[0.25 0.2 0.5 0.3],'String','Sweep','Callback',@hSweepGateCallback);                      

%% Fly Count Display
gui.cpanel = uipanel('Title','Fly Count','Position',[0.7 0.45 .25 .15]);
gui.count = uicontrol('Parent', gui.cpanel,'Style','text','Units','normalized','HandleVisibility','callback', ...
                      'String','0','Position',[0.40 0.80 0.20 0.15]);
gui.file = uicontrol('Parent', gui.cpanel,'Style','togglebutton','Units','normalized','HandleVisibility','callback', ...
		     'BackGroundColor','green', ...
		     'Value',0,'Position',[0.25 0.40 0.50 0.30],'String','Recording off','Callback', @hRecordingButtonCallback);
set(gui.fig,'Color', get(gui.panel,'Backgroundcolor'));

%% Temperature and Humidity Panel/Display
gui.environment = uipanel('Title','System Environment','Position',[0.05 0.90 0.3 0.08]);
gui.temp = uicontrol('Parent',gui.environment,'Style','edit','Units','normalized',...
                     'Position',[0.1 0.025 .3 0.6],'HandleVisibility','off','FontSize',16);
gui.tempedit = uicontrol('Parent',gui.environment,'Style','text','Units','normalized',...
                         'Position',[0 0.7 0.5 0.3],'String','Temperature');
gui.humidity = uicontrol('Parent',gui.environment,'Style','edit','Units','normalized',...
                     'Position',[0.55 0.025 .3 0.6],'HandleVisibility','off','FontSize',16);
gui.humidityedit = uicontrol('Parent',gui.environment,'Style','text','Units','normalized',...
                         'Position',[0.45 0.7 0.5 0.3],'String','Humidity, %');

%% Set Temperature Trigger of Fan
gui.temptrigger = uicontrol('Style','text','Units','normalized','Position',[0.35 0.94 0.2 0.04],...
                            'String','Fan Temperature Trigger, C');
gui.temptriggeredit = uicontrol('Style','edit','Units','normalized','Position',[0.4 0.90 0.1 0.04],...
                            'HandleVisibility','on','String','26','Callback',@setTemperature,'background','w',...
                            'FontSize',16);

%% Graph Thresholds

    function hshadowth(hObject, ~) %Add code to send data to the MCU
        [entry,status] = str2num(get(hObject,'string'));
        shadow = round(entry); %Set limitations 0 - 275        
        fwrite(s,sprintf('%s %u\r','E',shadow));
    end

    function hgapth(hObject,~) %Add code to send data to the MCU
        [entry,status] = str2num(get(hObject,'string'));
        gap = round(entry);        
        fwrite(s,sprintf('%s %u\r','K',gap));        
    end

%% Find Gates

    function hFindButtonCallback(~, ~)   
        if (get(gui.buttons,'SelectedObject') ~= u0)
            set(gui.buttons,'SelectedObject', u0);
        end
        fwrite(s,sprintf('%s\r','F'));                %Find Gates
    end


%% Fan Control
    function hfanslide(hObject, ~)
        slider_value = round(get(hObject,'Value'));
        set(hObject,'Value',slider_value);
        set(gui.fanedit,'String',num2str(slider_value));
    end

    function hfanEdit(hObject, ~)
        [entry,status] = str2num(get(hObject,'string'));
        if (status)
            value = round(entry);
            if (value >= 0 && value <= 100)
                set(hObject,'String',num2str(value));
                set(gui.fanslide,'Value',value);
            else
                set(hObject,'String',num2str(get(gui.fanslide,'Value')));
            end
        else
            set(hObject,'String',num2str(get(gui.fanslide,'Value')));
        end
    end

    function hSetFanCallback(~, ~)
        fwrite(s,sprintf('%s %u\r','U',get(gui.fanslide,'Value')));
    end

    function hfan(hObject, ~)
        button_state = get(hObject,'Value');
        if button_state == get(hObject,'Max')
            % Toggle button is pressed - turn on fan
            fwrite(s,sprintf('%s\r','Y'));
            set(hObject,'BackgroundColor','red');
            set(hObject,'String','Fan Off');
        elseif button_state == get(hObject,'Min')
            %Toggle button is not pressed - turn off fan
            fwrite(s,sprintf('%s\r','P'));
            set(hObject,'BackgroundColor','green');
            set(hObject,'String','Fan On');
        end
    end

%% Fan Temperature Trigger

    function setTemperature(hObject, ~)
        [entry,status] = str2num(get(hObject,'string'));
        setTempFan = round(entry);     
        fwrite(s,sprintf('%s %u\r','Q',setTempFan));
    end

%% Light Control

    function hintfront(hObject, ~)
        slider_value = round(get(hObject,'Value'));
        set(hObject,'Value',slider_value);
        set(gui.lightfront,'String',num2str(slider_value));
    end
    
    function hlightfront(hObject, ~)
        [entry,status] = str2num(get(hObject,'string'));
        if (status)
            value = round(entry);
            if (value >= 0 && value <= 100)
                set(hObject,'String',num2str(value));
                set(gui.intfront,'Value',value);
            else
                set(hObject,'String',num2str(get(gui.intfront,'Value')));
            end
        else
            set(hObject,'String',num2str(get(gui.intfront,'Value')));
        end
    end

    %----------------------------------------------------------------------
    
    function hintback(hObject, ~)
        slider_value = round(get(hObject,'Value'));
        set(hObject,'Value',slider_value);
        set(gui.lightback,'String',num2str(slider_value));
    end

    function hlightback(hObject, ~)
        [entry,status] = str2num(get(hObject,'string'));
        if (status)
            value = round(entry);
            if (value >= 0 && value <= 100)
                set(hObject,'String',num2str(value));
                set(gui.intback,'Value',value);
            else
                set(hObject,'String',num2str(get(gui.intback,'Value')));
            end
        else
            set(hObject,'String',num2str(get(gui.intback,'Value')));
        end
    end

    %----------------------------------------------------------------------

    function hfrontLights(~, ~)
        fwrite(s,sprintf('%s %u\r','I',get(gui.intfront,'Value')));
    end

    %----------------------------------------------------------------------
    
    function hbackLights(~, ~)
        fwrite(s,sprintf('%s %u\r','L',get(gui.intback,'Value')));
    end

%% Sweeper Motor Functions
    
    function hCalibrate(hObject, eventdata)
        fwrite(s,sprintf('%s\r','J')); %Add MCU Code for this
    end
    %----------------------------------------------------------------------
        
    function hSweepGateCallback(~, ~)
        fwrite(s,sprintf('%s\r','S'));                %Sweep Gate 2
    end

%% Fly Release Function

    function hReleaseButtonCallback(~, ~)
        if (get(gui.buttons,'SelectedObject') ~= u0)
            set(gui.buttons,'SelectedObject', u0)
        end
	fwrite(s,sprintf('%s\r','R'));                %Prepares firmware for character command
    end

%% Image Transfer Function

    function hImageButtonCallback(hObject, ~)
        button_state = get(hObject,'Value');
        if button_state == get(hObject,'Max')
            % Toggle button is pressed - send linear array data
            fwrite(s,sprintf('%s\r','V'));
            set(hObject,'BackgroundColor','red');
        elseif button_state == get(hObject,'Min')
            % Toggle button is not pressed - stop sending linear array data
            fwrite(s,sprintf('%s\r','N'));
            set(hObject,'BackgroundColor','green');
        end
    end

%% Auto Function
    
    function hAutoButtonCallback(hObject, ~)
        button_state = get(hObject,'Value');
        if button_state == get(hObject,'Max')
            % Toggle button is pressed - turn on auto release
            fwrite(s,sprintf('%s\r','A'));
            set(hObject,'BackgroundColor','red');
            set(hObject,'String','Auto release');
        elseif button_state == get(hObject,'Min')
            % Toggle button is not pressed - turn off auto release
            fwrite(s,sprintf('%s\r','M'));
            set(hObject,'BackgroundColor','green');
            set(hObject,'String','Manual release');
        end
    end

%% Set Gate Position Functions

    function selcbk(source,eventdata)
        if (eventdata.NewValue == u3)
            fwrite(s,sprintf('%s\r','C'));            %Closes Gate1
        elseif (eventdata.NewValue == u2)
            fwrite(s,sprintf('%s\r','B'));            %Blocks Gate1
        elseif (eventdata.NewValue == u1)
            fwrite(s,sprintf('%s\r','O'));            %Opens Gate1
        elseif (eventdata.NewValue == u4)
            fwrite(s,sprintf('%s\r','H'));            %Cleaning Gate1
        else
            fwrite(s,sprintf('%s\r','G'));            %Running
        end
    end
    
    function hOpen1Callback(hObject, ~, ~)
        slider_value = round(get(hObject,'Value'));
        set(hObject,'Value',slider_value);
        set(gui.open1edit,'String',num2str(slider_value));
    end

    %----------------------------------------------------------------------

    function hOpen1EditCallback(hObject, ~, ~)
        [entry,status] = str2num(get(hObject,'string'));
        if (status)
            value = round(entry);
            if (value >= 0 && value <= 100)
                set(hObject,'String',num2str(value));
                set(gui.open1slider,'Value',value);
            else
                set(hObject,'String',num2str(get(gui.open1slider,'Value')));
            end
        else
            set(hObject,'String',num2str(get(gui.open1slider,'Value')));
        end
    end

    %----------------------------------------------------------------------

    function hBlock1Callback(hObject, ~, ~)
        slider_value = round(get(hObject,'Value'));
        set(hObject,'Value',slider_value);
        set(gui.block1edit,'String',num2str(slider_value));
    end

    %----------------------------------------------------------------------

    function hBlock1EditCallback(hObject, ~, ~)
        [entry,status] = str2num(get(hObject,'string'));
        if (status)
            value = round(entry);
            if (value >= 0 && value <= 100)
                set(hObject,'String',num2str(value));
                set(gui.block1slider,'Value',value);
            else
                set(hObject,'String',num2str(get(gui.block1slider,'Value')));
            end
        else
            set(hObject,'String',num2str(get(gui.block1slider,'Value')));
        end
    end

    %----------------------------------------------------------------------

    % Set open and blocked position with slider bar.

    function hSetGate1Callback(~, ~)   
        fwrite(s,sprintf('%s %u %u\r','D',get(gui.open1slider,'Value'),get(gui.block1slider,'Value')));
    end

    %----------------------------------------------------------------------

    function gateselcbk(source,eventdata)
        if (eventdata.NewValue ~= eventdata.OldValue)
            set(source,'SelectedObject',eventdata.OldValue);
        end
    end

%% Fly Count Recording Function
    
    function hRecordingButtonCallback(hObject, ~)
        button_state = get(hObject,'Value');
        if button_state == get(hObject,'Max')
            % Toggle button is pressed-take appropriate action
            fwrite(s,sprintf('%s\r','T'));
            set(hObject,'BackgroundColor','red');
            set(hObject,'String','Recording on');
            fileN = sprintf('%s_%s.%s','flycount',datestr(now,30),'txt');
            set(gui.count,'String','0');
            gui.logfileID = fopen(fileN,'w');
        elseif button_state == get(hObject,'Min')
            % Toggle button is not pressed-take appropriate action
            %fwrite(s,sprintf('%s\r','M'));
            set(hObject,'BackgroundColor','green');
            set(hObject,'String','Recording off');
            fclose(gui.logfileID);
        end
    end

%% Communication to MCU

    function receiveData(obj,evnt)
        token = fscanf(s,'%s',4);
        %display(token);
        if (strcmp('$FR,', token) == true)
            name = fscanf(s);
            set(gui.fig,'name',name);
            set(gui.fig,'Visible','on');
        elseif(strcmp('$GS,', token) == true)
            gatepos = fscanf(s);
            [open1,block1] = strread(gatepos,'%u%u','delimiter',',');
            set(gui.open1slider,'Value',open1);
            set(gui.block1slider,'Value',block1);
            set(gui.open1edit,'String',num2str(open1));
            set(gui.block1edit,'String',num2str(block1));
        elseif(strcmp('$LS,',token) == true) %Add this to MCU code
            light1 = fscanf(s);
            set(gui.intslide,'Value',light1);
            set(gui.lightedit,'String',num2str(light1));
        elseif(strcmp('$GF,',token) == true)
            gateFind = fscanf(s);
            [gatestart, gateend, gap] = strread(gateFind,'%u%u%u','delimiter',',');


            disp(gatestart)
            disp(gateend)
            disp(gap)
        elseif(strcmp('$GE,',token) == true)
            gatestate = fscanf(s);
            [gate, state] = strread(gatestate,'%u%s','delimiter',',');
            if (gate == 1)
                if (strcmp('O', state) == true)
                    set(gui.gate1,'SelectedObject',gui.state1o);
                elseif (strcmp('B', state) == true)
                    set(gui.gate1,'SelectedObject',gui.state1b);
                elseif (strcmp('H', state) == true)
                    set(gui.gate1,'SelectedObject',gui.state1h);
                else
                    set(gui.gate1,'SelectedObject',gui.state1c);
                end
            end
        elseif(strcmp('$FC,',token) == true)
            inpline = fscanf(s);
            [cnt,sec] = strread(inpline,'%u%u','delimiter',',');
            set(gui.count,'String',num2str(cnt));
            fprintf(gui.logfileID,'%s %s\r\n',num2str(cnt),num2str(sec));
        elseif(strcmp('$ID,', token) == true)
            data = fread(s,128);
            junk = fscanf(s);
            cla;
            gui.hline1=plot(0:127,2*data(1:128),'linewidth',2,'color','k');
            gui.axes1=get(gui.hline1,'parent');
            gui.hline4=plot(0:127,repmat(shadow,1,128),'linewidth',1,'color','b');
            gui.axes1=get(gui.hline4,'parent');
            plot(repmat(gatestart,1,270),0:269,'linewidth',1,'color','r');
            plot(repmat(gateend,1,270),0:269,'linewidth',1,'color','r');
            plot(repmat(gateend+gap,1,270),0:269,'linewidth',1,'color','k');
%             gui.hline2 = plot(repmat(94,1,128),0:127,'linewidth',1,'color','r');
%             gui.axes1=get(gui.hline2,'parent');
%              plot(x,y);
%              plot(x2,y); 
        elseif(strcmp('$TD,',token) == true)
            input = fscanf(s);           
            [h,t] = strread(input,'%u%u','delimiter',',');
            t = t/10;
            h = h/10;
            set(gui.humidity,'String',num2str(h));
            set(gui.temp,'String',num2str(t));
        end
    end

%% Closing

    function closefcn(src,~)
        fclose('all');
%        stop(ai);
%        delete(ai);
        delete(s);
        delete(src);
    end
end