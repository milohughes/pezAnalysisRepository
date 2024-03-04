function Calender_Gui_v1    
    repositoryDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repositoryDir,'Support_Programs'))
           
    op_sys = system_dependent('getos');
    username= getenv('USERNAME');
    if contains(op_sys,'Microsoft Windows')
        calender_save_path = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables\save_calender_data.mat';
        run_path = '\\DM11\cardlab\Data_pez3000';
    else
        calender_save_path = '/Volumes/cardlab/Pez3000_Gui_folder/Gui_saved_variables/save_calender_data.mat';
        run_path = '/Volumes/cardlab/Data_pez3000';
    end
    save_calender_data = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets labels and background
    backColor = [0 0 0.2];
   
    FigPos = [211,142,1200,1400];
            
    pop_up_fig = figure('position',[[1431,1068,642,420]],'Visible','Off');
    back_pannel = uipanel(pop_up_fig,'Position',[0 0 1 1],'Visible','On','BackgroundColor',rgb('light grey'));      %TOP LEFT PANNEL
        
    hFigA = figure('NumberTitle','off','Name','Calender Gui',...
           'menubar','none','Color',backColor,'pos',FigPos,'colormap',gray(256));

    curr_month = calendar;
    curr_month = curr_month((end-1):-1:1,:);
    hPanMonth = uipanel(hFigA,'Position',[0 6/7 1 1/7],'Visible','On','BackgroundColor',rgb('light grey'));      %TOP LEFT PANNEL
    curr_date = datevec(now());
    month_str = month(datetime(curr_date(1),curr_date(2),1),'name');
    calender_month = uicontrol(hPanMonth,'Style','text','Units','normalized','position',[0 0 1 1],...
                'String',month_str,'fontunits','normalized','fontsize',0.5000,'ForegroundColor',rgb('black'));
            
    weekday_list = [{'Sunday'},{'Monday'},{'Tuesday'},{'Wednesday'},{'Thursday'},{'Friday'},{'Saturday'}];
    
    for iterC = 1:1:7       %days in the week
        hPanDay = uipanel(hFigA,'Position',[(iterC-1)*1/7 5/7 1/7 1/7],'Visible','On','BackgroundColor',rgb('light grey'));      %TOP LEFT PANNEL
        uicontrol(hPanDay,'Style','text','Units','normalized','position',[0 0 1 1],...
                'String',sprintf('\n\n%s',weekday_list{iterC}),'fontunits','normalized','fontsize',0.1500,'ForegroundColor',rgb('black'));
    end
    for iterR = 1:1:5           %weeks in a month
        for iterC = 1:1:7       %days in the week
            hPanA = uipanel(hFigA,'Position',[(iterC-1)*1/7 (iterR-1)*1/7 1/7 1/7],'Visible','On','BackgroundColor',rgb('light grey'));      %TOP LEFT PANNEL
            if curr_month(iterR,iterC) > 0
                date_str = num2str(curr_month(iterR,iterC));
            else
                 date_str = '';
            end
            calender_date(iterR,iterC) = uicontrol(hPanA,'Style','pushbutton','Units','normalized','position',[0 0 1 1],...
                'String',sprintf('%s',date_str),'fontunits','normalized','fontsize',0.300,'ForegroundColor',rgb('black'),'callback',@openday);
        end
    end
    
    hCprevMonth = uicontrol(hPanMonth,'style','pushbutton','units','normalized',...
        'string',' ','Position',[0 0 .1 1],'fontunits','normalized','fontsize', 0.4598,'callback',@setprevmonth,'Enable','on');
    hCnextMonth = uicontrol(hPanMonth,'style','pushbutton','units','normalized',...
        'string',' ','Position',[.9 0 .1 1],'fontunits','normalized','fontsize', 0.4598,'callback',@setnextmonth,'Enable','on');
    iconshade = 0.1;

    makeFolderIcon(hCnextMonth,0.75,'next',iconshade)
    makeFolderIcon(hCprevMonth,0.75,'prev',iconshade)
    
    function setnextmonth(~,~)
        if curr_date(2) < 12
            curr_date(2) = curr_date(2)+1;
        elseif curr_date(2) == 12
            curr_date(1) = curr_date(1)+1;
            curr_date(2) = 1;
        end
        month_str = month(datetime(curr_date(1),curr_date(2),1),'name');
        set(calender_month,'String',month_str);
        add_date_values;
    end
    function setprevmonth(~,~)
        if curr_date(2) > 1
            curr_date(2) = curr_date(2)-1;
        elseif curr_date(2) == 1
            curr_date(1) = curr_date(1)-1;
            curr_date(2) = 12;
        end
        month_str = month(datetime(curr_date(1),curr_date(2),1),'name');
        set(calender_month,'String',month_str);
        add_date_values;
    end
    function add_date_values(~,~)
        curr_month = calendar(curr_date(1),curr_date(2));
        curr_month = curr_month((end-1):-1:1,:);
        
        for iterZ = 1:1:5           %weeks in a month
            for iterQ = 1:1:7       %days in the week

                if curr_month(iterZ,iterQ) > 0
                    date_str = num2str(curr_month(iterZ,iterQ));
                else
                     date_str = '';
                end
                set(calender_date(iterZ,iterQ),'String',sprintf('%s',date_str));
            end
        end
    end
    function openday(hObj,~)
        date_clicked = get(hObj,'String');
        if exist(calender_save_path,'file')
            save_calender_data = load(calender_save_path);
            save_calender_data = save_calender_data.save_calender_data;
        else
            save_calender_data = cell2table(cell(1,5));
            save_calender_data.Properties.VariableNames = [{'Date'},{'Moring_Cycle'},{'Morning_User'},{'Afternoon_Cycle'},{'Afternoon_User'}];
            save_calender_data.Date = {[curr_date(1),curr_date(2),str2double(date_clicked)]};
            save_calender_data.Moring_Cycle = {'8am to 12pm'};
            save_calender_data.Afternoon_Cycle = {'1pm to 5pm'};
            save_calender_data.Morning_User = {''};
            save_calender_data.Afternoon_User = {''};            
        end
        set(pop_up_fig,'visible','on');
        col_list = [{'Pez3001'},{'Pez3002'},{'Pez3003'},{'Pez3004'},{'All_Pezes'}];
        time_vect = [arrayfun(@(x) sprintf('%2.0fam',x),8:1:11,'UniformOutput',false),arrayfun(@(x) sprintf('%2.0fpm',x),0:1:7,'UniformOutput',false)];
        time_vect(5) = {'12pm'};
        time_vect(end+1) = {'Total for Day'};
        
        testing_date = save_calender_data.Date{1};
        date_string = sprintf('%04.0f%02.0f%02.0f',testing_date(1),testing_date(2),testing_date(3));
        set(pop_up_fig,'name',date_string)
        if exist([run_path filesep date_string],'dir') > 1
            exp_run = struct2dataset(dir([run_path filesep date_string]));
            exp_run = exp_run(cellfun(@(x) contains(x,'run'),exp_run.name),:);
            count_summary = zeros(13,5);        %7 am to 7pm
            for iterZ = 1:length(exp_run.name)
                vid_list = struct2dataset(dir([run_path filesep date_string filesep exp_run.name{iterZ}]));
                vid_list = vid_list(cellfun(@(x) contains(x,'.mp4'),vid_list.name),:);
                hour_run = cellfun(@(x) str2double(x((end-7):(end-6))), vid_list.date);
                pez_index = unique(cellfun(@(x) str2double(x(14)), vid_list.name));
                [C,IA,IC] = unique(hour_run);
                for iterU = 1:length(IA)
                    try
                        count_summary(C(iterU)-7,pez_index) = count_summary(C(iterU)-7,pez_index) + length(vid_list.name(IC == iterU));
                    catch
                        warning('error')
                    end
                        
                end
            end
            count_summary(:,5) = sum(count_summary,2);
            count_summary(end,:) = sum(count_summary,1);
            summary_table = uitable(back_pannel,'units','normalized','position',[0 0 1 1]);
            set(summary_table,'RowName',time_vect,'ColumnName',col_list,'ColumnEditable',false(1,16));
            set(summary_table,'Data',count_summary,'FontSize',10);        
        end
    end
end
