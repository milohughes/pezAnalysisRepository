%Interface selection GUI
%Please run this program. After the interface selection being chosen, it will launch the
%main GUI

function SDK_Sample_EN_run

clc

fid = fopen('log_IP.csv','r');
fid2 = fopen('log_IP_normal.csv','r');

%GUI uicontrol objects
run_uicontrol_interface

%Callback settings
run_callback_set_interface

%handles
run_handles_interface

%Last IP memory check
if(fid ~= -1)
    ip_auto = fscanf(fid,'%i');
    set(K.Detect_auto1_edit,'String',ip_auto(1));
    set(K.Detect_auto2_edit,'String',ip_auto(2));
    set(K.Detect_auto3_edit,'String',ip_auto(3));
end

if(fid2 ~= -1)
    ip_normal = fscanf(fid2,'%i');
    set(K.Detect_normal1_edit,'String',ip_normal(1));
    set(K.Detect_normal2_edit,'String',ip_normal(2));
    set(K.Detect_normal3_edit,'String',ip_normal(3));
    set(K.Detect_normal4_edit,'String',ip_normal(4));
end
guidata(K.int,handles);

if(fid ~= -1)
    fclose(fid);
end

if(fid2 ~= -1)
    fclose(fid2);
end

end
%END MAIN

%**************************************************************************
%**************************************************************************
%Callback functions

%Gigabit radio
function Gigabit_radio_Callback(source, eventdata)
    handles = guidata(gcbo);
    IEEE_radio = handles.IEEE_radio;
    PCI_radio = handles.PCI_radio;
    ip_address_panel = handles.ip_address_panel;
    
    set(IEEE_radio,'Value',0);
    set(PCI_radio,'Value',0);
    set(source,'Value',1);
    set(ip_address_panel,'Visible','on');
end

%IEEE radio
function IEEE_radio_Callback(source, eventdata)
    handles = guidata(gcbo);
    Gigabit_radio = handles.Gigabit_radio;
    PCI_radio = handles.PCI_radio;
    ip_address_panel = handles.ip_address_panel;

    set(Gigabit_radio,'Value',0);
    set(PCI_radio,'Value',0);
    set(source,'Value',1);
    set(ip_address_panel,'Visible','off');
end

%PCI radio
function PCI_radio_Callback(source, eventdata)
    handles = guidata(gcbo);
    IEEE_radio = handles.IEEE_radio;
    Gigabit_radio = handles.Gigabit_radio;
    ip_address_panel = handles.ip_address_panel;

    set(IEEE_radio,'Value',0);
    set(Gigabit_radio,'Value',0);
    set(source,'Value',1);
    set(ip_address_panel,'Visible','off');
end

% Detect_normal4_edit KeyPressFcn
function Detect_normal4_edit_KeyPressFcn(source,eventdata)
    handles = guidata(gcbo);
    if(strcmp(eventdata.Key,'return'))
        drawnow
        OK_button_Callback
    end
end

% Detect_auto3_edit KeyPressFcn
function Detect_auto3_edit_KeyPressFcn(source,eventdata)
    handles = guidata(gcbo);
    if(strcmp(eventdata.Key,'return'))
        drawnow
        OK_button_Callback
    end
end

%OK button
function OK_button_Callback(source,eventdata)
    handles = guidata(gcbo);
    Gigabit_radio = handles.Gigabit_radio;
    IEEE_radio = handles.IEEE_radio;
    PCI_radio = handles.PCI_radio;
    Detect_auto_radio = handles.Detect_auto_radio;
    Detect_normal_radio = handles.Detect_normal_radio;
    Detect_auto1_edit = handles.Detect_auto1_edit;
    Detect_auto2_edit = handles.Detect_auto2_edit;
    Detect_auto3_edit = handles.Detect_auto3_edit;
    Detect_normal1_edit = handles.Detect_normal1_edit;
    Detect_normal2_edit = handles.Detect_normal2_edit;
    Detect_normal3_edit = handles.Detect_normal3_edit;
    Detect_normal4_edit = handles.Detect_normal4_edit;

    Gigabit_radio_value = get(Gigabit_radio,'Value');
    IEEE_radio_value = get(IEEE_radio,'Value');
    PCI_radio_value = get(PCI_radio,'Value');
    Detect_auto_radio_value = get(Detect_auto_radio,'Value');
    Detect_normal_radio_value = get(Detect_normal_radio,'Value'); 
    Detect_auto1_edit_string = get(Detect_auto1_edit,'String');
    Detect_auto2_edit_string = get(Detect_auto2_edit,'String');
    Detect_auto3_edit_string = get(Detect_auto3_edit,'String');
    Detect_normal1_edit_string = get(Detect_normal1_edit,'String');
    Detect_normal2_edit_string = get(Detect_normal2_edit,'String');
    Detect_normal3_edit_string = get(Detect_normal3_edit,'String');
    Detect_normal4_edit_string = get(Detect_normal4_edit,'String');
    Detect_auto1_edit_num = str2num(Detect_auto1_edit_string);
    Detect_auto2_edit_num = str2num(Detect_auto2_edit_string);
    Detect_auto3_edit_num = str2num(Detect_auto3_edit_string);
    Detect_normal1_edit_num = str2num(Detect_normal1_edit_string);
    Detect_normal2_edit_num = str2num(Detect_normal2_edit_string);
    Detect_normal3_edit_num = str2num(Detect_normal3_edit_string);
    Detect_normal4_edit_num = str2num(Detect_normal4_edit_string); 
        
    if( Gigabit_radio_value == 0 && IEEE_radio_value == 0 && PCI_radio_value == 0 )
            msgbox('Please choose an interface from the interface select box','No interface chosen','Help');
    else
        
        if( Gigabit_radio_value == 1)
            nInterfaceCode = 2;
            
            if( Detect_auto_radio_value == 0 && Detect_normal_radio_value == 0 ) 
                 msgbox('Please choose a detection method','No detection method chosen','Help');
            else
                
                if( Detect_auto_radio_value == 1 )
                        nDetectParam = 1;
                        fname = 'log_IP.csv';
                        fid = fopen( fname,'w');
                        %Detect auto hex IP calculation
                        if (Detect_auto1_edit_num < 16)
                           Detect_auto1_hex = strcat('0',dec2hex(Detect_auto1_edit_num));
                        else
                           Detect_auto1_hex = dec2hex(Detect_auto1_edit_num);
                        end

                        if (Detect_auto2_edit_num < 16)
                           Detect_auto2_hex = strcat('0',dec2hex(Detect_auto2_edit_num));
                        else
                           Detect_auto2_hex = dec2hex(Detect_auto2_edit_num);
                        end

                        if (Detect_auto3_edit_num < 16)
                           Detect_auto3_hex = strcat('0',dec2hex(Detect_auto3_edit_num));
                        else
                           Detect_auto3_hex = dec2hex(Detect_auto3_edit_num);
                        end
                        
                        fprintf( fid,'%d\n',  Detect_auto1_edit_num);
                        fprintf( fid,'%d\n',  Detect_auto2_edit_num);
                        fprintf( fid,'%d\n',  Detect_auto3_edit_num);
                        fclose( fid );
                        Detect_auto_hex = strcat(Detect_auto1_hex,Detect_auto2_hex,Detect_auto3_hex,'00');
                        IPList = hex2dec(Detect_auto_hex);
                    
                    if( isempty(Detect_auto1_edit_string)==1 ||isempty(Detect_auto2_edit_string)==1||isempty(Detect_auto3_edit_string)==1)
                        msgbox('Please enter an IP address.','No IP address','Warn');
                    else
                        delete(gcf);
                        SDK_Sample_EN(nInterfaceCode,IPList,nDetectParam)
                    end
                else 
                    %Detect normal selected
                    fname_normal = 'log_IP_normal.csv';
                    fid2 = fopen( fname_normal,'w');
                    nDetectParam = 0;
                    %Detect auto hex IP calculation
                        if (Detect_normal1_edit_num < 16)
                           Detect_normal1_hex = strcat('0',dec2hex(Detect_normal1_edit_num));
                        else
                           Detect_normal1_hex = dec2hex(Detect_normal1_edit_num);
                        end

                        if (Detect_normal2_edit_num < 16)
                           Detect_normal2_hex = strcat('0',dec2hex(Detect_normal2_edit_num));
                        else
                           Detect_normal2_hex = dec2hex(Detect_normal2_edit_num);
                        end

                        if (Detect_normal3_edit_num < 16)
                           Detect_normal3_hex = strcat('0',dec2hex(Detect_normal3_edit_num));
                        else
                           Detect_normal3_hex = dec2hex(Detect_normal3_edit_num);
                        end
                        
                        if (Detect_normal4_edit_num < 16)
                           Detect_normal4_hex = strcat('0',dec2hex(Detect_normal4_edit_num));
                        else
                           Detect_normal4_hex = dec2hex(Detect_normal4_edit_num);
                        end
                        
                        fprintf( fid2,'%d\n',  Detect_normal1_edit_num);
                        fprintf( fid2,'%d\n',  Detect_normal2_edit_num);
                        fprintf( fid2,'%d\n',  Detect_normal3_edit_num);
                        fprintf( fid2,'%d\n',  Detect_normal4_edit_num);
                        fclose( fid2 );
                        Detect_normal_hex = strcat(Detect_normal1_hex,Detect_normal2_hex,Detect_normal3_hex,Detect_normal4_hex);
                        IPList = hex2dec(Detect_normal_hex);
                        
                    if( isempty(Detect_normal1_edit_string)==1 ||isempty(Detect_normal2_edit_string)==1||isempty(Detect_normal3_edit_string)==1 ||isempty(Detect_normal4_edit_string)==1)
                        msgbox('Please enter an IP address.','No IP address','Warn');
                    else
                        delete(gcf);
                        SDK_Sample_EN(nInterfaceCode,IPList,nDetectParam)
                    end     
                end        
            end
            
        elseif (IEEE_radio_value == 1)
            nInterfaceCode = 3;
            IPList = 1;
            nDetectParam = 1;
            delete(gcf);            
            SDK_Sample_EN(nInterfaceCode,IPList,nDetectParam)
        else
            %PCI interface
            nInterfaceCode = 256;
            IPList = 1;
            nDetectParam = 1;
            delete(gcf);
            SDK_Sample_EN(nInterfaceCode,IPList,nDetectParam)
        end 
    end
end

%Detect auto radio
function Detect_auto_radio_Callback(source,eventdata)
    handles = guidata(gcbo);
    Detect_normal_radio = handles.Detect_normal_radio;
    Detect_normal1_edit = handles.Detect_normal1_edit;
    Detect_normal2_edit = handles.Detect_normal2_edit;
    Detect_normal3_edit = handles.Detect_normal3_edit;
    Detect_normal4_edit = handles.Detect_normal4_edit;
    Detect_auto1_edit = handles.Detect_auto1_edit;
    Detect_auto2_edit = handles.Detect_auto2_edit;
    Detect_auto3_edit = handles.Detect_auto3_edit;

    set(source,'Value',1);
    set(Detect_normal_radio,'Value',0);
    set(Detect_normal1_edit,'Enable','off','BackgroundColor',[ 0.7529 0.7529 0.7529 ]);
    set(Detect_normal2_edit,'Enable','off','BackgroundColor',[ 0.7529 0.7529 0.7529 ]);
    set(Detect_normal3_edit,'Enable','off','BackgroundColor',[ 0.7529 0.7529 0.7529 ]);
    set(Detect_normal4_edit,'Enable','off','BackgroundColor',[ 0.7529 0.7529 0.7529 ]);
    
    set(Detect_auto1_edit,'Enable','on','BackgroundColor',[ 1 1 1 ]);
    set(Detect_auto2_edit,'Enable','on','BackgroundColor',[ 1 1 1 ]);
    set(Detect_auto3_edit,'Enable','on','BackgroundColor',[ 1 1 1 ]);
end

%Detect normal radio
function Detect_normal_radio_Callback(source,eventdata)
    handles = guidata(gcbo);
    Detect_auto_radio = handles.Detect_auto_radio;
    Detect_normal1_edit = handles.Detect_normal1_edit;
    Detect_normal2_edit = handles.Detect_normal2_edit;
    Detect_normal3_edit = handles.Detect_normal3_edit;
    Detect_normal4_edit = handles.Detect_normal4_edit;
    Detect_auto1_edit = handles.Detect_auto1_edit;
    Detect_auto2_edit = handles.Detect_auto2_edit;
    Detect_auto3_edit = handles.Detect_auto3_edit;

    set(source,'Value',1);
    set(Detect_auto_radio,'Value',0);
    
    set(Detect_auto1_edit,'Enable','off','BackgroundColor',[ 0.7529 0.7529 0.7529 ]);
    set(Detect_auto2_edit,'Enable','off','BackgroundColor',[ 0.7529 0.7529 0.7529 ]);
    set(Detect_auto3_edit,'Enable','off','BackgroundColor',[ 0.7529 0.7529 0.7529 ]);
    
    set(Detect_normal1_edit,'Enable','on','BackgroundColor',[ 1 1 1 ]);
    set(Detect_normal2_edit,'Enable','on','BackgroundColor',[ 1 1 1 ]);
    set(Detect_normal3_edit,'Enable','on','BackgroundColor',[ 1 1 1 ]);
    set(Detect_normal4_edit,'Enable','on','BackgroundColor',[ 1 1 1 ]);
end