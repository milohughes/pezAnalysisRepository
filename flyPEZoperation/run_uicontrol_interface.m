%Interface selection uicontrol

%Get screen size
Screen_size = get(0,'Screensize');
wS = Screen_size(3);
hS = Screen_size(4);

%handle figure
K.int = figure('NumberTitle','off','Name','SDK Sample EN','menubar','none',...
    'units','pix','Color',[.9 .9 .9],...
    'pos',[50 50 600 200]);

%Get Figure position for centering
Fig_Pos = get(K.int,'Position');
w = Fig_Pos(3);
h = Fig_Pos(4);

%Center GUI
set(K.int,'Position',[(wS-w)/2 (hS-h)/2 600 200]);

%Logo
K.axo = axes('Units','pix', 'Position', [13 5 82 20]);
logo = imread('logo.bmp');
image(logo,'Parent',K.axo,'HitTest','off');
axis off

%**************************************************************************
%**************************************************************************
%Button and panel

%main panel
K.main_panel = uipanel('Position',[.02 .18 .96 .72]);

%interface select
K.interface_select_panel = uipanel('Parent',K.main_panel,'Position',[.02 .18 .4 .80],'Title','Interface Select Box',...,
    'FontSize',12,'FontWeight','bold');

%ip adress
K.ip_address_panel = uipanel('Parent',K.main_panel,'Position',[.45 .18 .53 .80],'Visible','Off','Title','IP Address',...,
    'FontSize',12,'FontWeight','bold');

%OK pushbutton
K.OK_button = uicontrol(K.int, 'Style','pushbutton','String','OK','Units','normalized','Position',[.825 .02 .15 .12]);

%Gigabit radio
K.Gigabit_radio = uicontrol(K.interface_select_panel,'Style','radiobutton', 'String','Gigabit Ethernet',...,
    'Value',0,'Units','normalized','Position',[.05 .65 .7 .15]);
            
%IEEE radio
K.IEEE_radio = uicontrol(K.interface_select_panel,'Style','radiobutton', 'String','IEEE1394',...,
    'Value',0,'Units','normalized','Position',[.05 .4 .7 .15]);              

%PCI radio
K.PCI_radio = uicontrol(K.interface_select_panel,'Style','radiobutton', 'String','PCI',...,
    'Value',0,'Units','normalized','Position',[.05 .15 .7 .15]);   

%Detect Auto radio
K.Detect_auto_radio = uicontrol(K.ip_address_panel,'Style','radiobutton', 'String','Detect Auto',...,
    'Value',0,'Units','normalized','Position',[.05 .65 .5 .15]);   

%Detect Normal radio
K.Detect_normal_radio = uicontrol(K.ip_address_panel,'Style','radiobutton', 'String','Detect Normal',...,
    'Value',0,'Units','normalized','Position',[.05 .4 .5 .15]); 

%Detect Auto 1 edit
K.Detect_auto1_edit = uicontrol(K.ip_address_panel,'Style','edit',...,
    'BackgroundColor',[1 1 1],'Unit','normalized','Position',[.4 .62 .1 .2]);   

%Detect Auto 2 edit
K.Detect_auto2_edit = uicontrol(K.ip_address_panel,'Style','edit',...,
    'BackgroundColor',[1 1 1],'Unit','normalized','Position',[.52 .62 .1 .2]);  

%Detect Auto 3 edit
K.Detect_auto3_edit = uicontrol(K.ip_address_panel,'Style','edit',...,
    'BackgroundColor',[1 1 1],'Unit','normalized','Position',[.64 .62 .1 .2]);  

%Detect Auto 1 txt
K.Detect_auto1_txt = uicontrol(K.ip_address_panel,'Style','text','String','.',...,
    'Unit','normalized','Position',[.5 .582 .01 .2]); 

%Detect Auto 2 txt
K.Detect_auto2_txt = uicontrol(K.ip_address_panel,'Style','text','String','.',...,
    'Unit','normalized','Position',[.62 .582 .01 .2]); 

%Detect Auto 3 txt
K.Detect_auto3_txt = uicontrol(K.ip_address_panel,'Style','text','String','.',...,
    'Unit','normalized','Position',[.74 .582 .01 .2]); 

%Detect Auto 4 txt
K.Detect_auto4_txt = uicontrol(K.ip_address_panel,'Style','text','String','XXX',...,
    'Unit','normalized','Position',[.75 .582 .075 .2]); 

%Detect Normal 1 edit
K.Detect_normal1_edit = uicontrol(K.ip_address_panel,'Style','edit',...,
    'BackgroundColor',[1 1 1],'Unit','normalized','Position',[.4 .39 .1 .2]);  

%Detect Normal 2 edit
K.Detect_normal2_edit = uicontrol(K.ip_address_panel,'Style','edit',...,
    'BackgroundColor',[1 1 1],'Unit','normalized','Position',[.52 .39 .1 .2]);  

%Detect Normal 3 edit
K.Detect_normal3_edit = uicontrol(K.ip_address_panel,'Style','edit',...,
    'BackgroundColor',[1 1 1],'Unit','normalized','Position',[.64 .39 .1 .2]); 

%Detect Normal 4 edit
K.Detect_normal4_edit = uicontrol(K.ip_address_panel,'Style','edit',...,
    'BackgroundColor',[1 1 1],'Unit','normalized','Position',[.76 .39 .1 .2]); 

%Detect Normal 1 txt
K.Detect_normal1_txt = uicontrol(K.ip_address_panel,'Style','text','String','.',...,
    'Unit','normalized','Position',[.5 .35 .01 .2]); 

%Detect Normal 2 txt
K.Detect_normal2_txt = uicontrol(K.ip_address_panel,'Style','text','String','.',...,
    'Unit','normalized','Position',[.62 .35 .01 .2]); 

%Detect Normal 3 txt
K.Detect_normal3_txt = uicontrol(K.ip_address_panel,'Style','text','String','.',...,
    'Unit','normalized','Position',[.74 .35 .01 .2]); 
