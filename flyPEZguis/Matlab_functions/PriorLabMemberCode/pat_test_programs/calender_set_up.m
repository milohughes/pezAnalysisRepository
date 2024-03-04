
function calender_set_up
    repositoryDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repositoryDir,'Support_Programs')) 
    
    op_sys = system_dependent('getos');
    username= getenv('USERNAME');
    if contains(op_sys,'Microsoft Windows')
        calender_save_path = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables\save_calender_data.mat';
    else
        calender_save_path = '/Volumes/cardlab/Pez3000_Gui_folder/Gui_saved_variables/save_calender_data.mat';
    end
    save_calender_data = [];
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% sets labels and background
    backColor = [0 0 0.2];
   
    FigPos = [9   814   820   532];
    hFigA = figure('NumberTitle','off','Name','Calender Gui',...
           'menubar','none','Color',backColor,'pos',FigPos,'colormap',gray(256));
    set(hFigA,'CloseRequestFcn',@check_available)

    hPanA = uipanel(hFigA,'Position',[0 .8 1 .2],'Visible','On','BackgroundColor',rgb('light grey'));      
    hPanB = uipanel(hFigA,'Position',[0 .4 1 .4],'Visible','On','BackgroundColor',rgb('light grey'));      
    hPanC = uipanel(hFigA,'Position',[0 0 1 .4],'Visible','On','BackgroundColor',[0.9400    0.9400    0.9400]);
    
    uicontrol(hPanA,'Style','text','Units','normalized','position',[0 0.5 .5 .5],...
                'String',sprintf('\nNumber Of Genotypes'),'fontunits','normalized','fontsize',0.40,'ForegroundColor',rgb('black'));
    uicontrol(hPanA,'Style','text','Units','normalized','position',[0.5 0.5 .5 .5],...
                'String',sprintf('\nNumber Of Protocols'),'fontunits','normalized','fontsize',0.40,'ForegroundColor',rgb('black'));            
            
    uicontrol(hPanB,'Style','text','Units','normalized','position',[0 0.75 .5 .25],...
                'String',sprintf('\nNumber Of Runs for 100 Videos'),'fontunits','normalized','fontsize',0.350,'ForegroundColor',rgb('black'));
    uicontrol(hPanB,'Style','text','Units','normalized','position',[0.5 0.75 .5 .25],...
                'String',sprintf('\nNumber Of Runs for 30 Jumpers'),'fontunits','normalized','fontsize',0.350,'ForegroundColor',rgb('black'));            

    total_runs = uicontrol(hPanB,'Style','text','Units','normalized','position',[0 0.5 .5 .25],...
                'String','13','fontunits','normalized','fontsize',0.350,'ForegroundColor',rgb('black'));
    jump_runs = uicontrol(hPanB,'Style','text','Units','normalized','position',[0.5 0.5 .5 .25],...
                'String','15','fontunits','normalized','fontsize',0.350,'ForegroundColor',rgb('black'));
            
    uicontrol(hPanB,'Style','text','Units','normalized','position',[0 0.25 .5 .25],...
                'String',sprintf('\nNumber Of Days for 100 Videos'),'fontunits','normalized','fontsize',0.350,'ForegroundColor',rgb('black'));
    uicontrol(hPanB,'Style','text','Units','normalized','position',[0.5 0.25 .5 .25],...
                'String',sprintf('\nNumber Of Days for 30 Jumpers'),'fontunits','normalized','fontsize',0.350,'ForegroundColor',rgb('black'));            

    total_days = uicontrol(hPanB,'Style','text','Units','normalized','position',[0 0 .5 .25],...
                'String','13','fontunits','normalized','fontsize',0.350,'ForegroundColor',rgb('black'));
    jump_days = uicontrol(hPanB,'Style','text','Units','normalized','position',[0.5 0 .5 .25],...
                'String','15','fontunits','normalized','fontsize',0.350,'ForegroundColor',rgb('black'));
            
            
    geno_list = arrayfun(@(x) sprintf('                                        %4.0f',x),1:1:20,'UniformOutput',false);
    proto_list = arrayfun(@(x) sprintf('                                        %4.0f',x),1:1:25,'UniformOutput',false);
    geno_count = 1;
    proto_count = 1;
    set_run_counts;
    
    uicontrol(hPanA,'Style','popup','Units','normalized','position',[0 0 .5 .35],...
                'String',geno_list,'fontunits','normalized','fontsize',0.50,'ForegroundColor',rgb('black'),'callback',@get_geno_count);
    uicontrol(hPanA,'Style','popup','Units','normalized','position',[0.5 0 .5 .35],...
                'String',proto_list,'fontunits','normalized','fontsize',0.50,'ForegroundColor',rgb('black'),'callback',@get_proto_count);
           
    day_of_week = [{'Sunday'},{'Monday'},{'Tuesday'},{'Wednesday'},{'Thursday'},{'Friday'},{'Saturday'}];
    time_of_day = [{'Morning'},{'Afternoon'},{'Evening'}];
    for iterZ = 1:4
        uicontrol(hPanC,'Style','checkbox','Units','normalized','position',[(.075+(1/4)*(iterZ-1)) 0.75 1/4 .25],...
                'String',day_of_week{iterZ},'fontunits','normalized','fontsize',0.3500,'ForegroundColor',rgb('black'));
    end
    for iterZ = 5:7
        days_checked(iterZ) = uicontrol(hPanC,'Style','checkbox','Units','normalized','position',[(.170+(1/4)*(iterZ-5)) .5 1/4 .25],...
                'String',day_of_week{iterZ},'fontunits','normalized','fontsize',0.3500,'ForegroundColor',rgb('black'));
    end
    for iterZ = 1:3
        time_of_day_checked(iterZ) = uicontrol(hPanC,'Style','checkbox','Units','normalized','position',[(.170+(1/4)*(iterZ-1)) 0 1/4 .5],...
                'String',time_of_day{iterZ},'fontunits','normalized','fontsize',0.17500,'ForegroundColor',rgb('black'));
    end

    
    function get_geno_count(hObj,~)
        geno_count = get(hObj,'value');
        set_run_counts;
    end
    function get_proto_count(hObj,~)
        proto_count = get(hObj,'value');
        set_run_counts;
    end
    function set_run_counts(~,~)
        per_run = 20*.1;
        runs_per_line = 30/per_run;
        run_count = geno_count * proto_count * runs_per_line;        
        set(jump_runs,'string',sprintf('%6.0f',run_count));
        set(jump_days,'string',sprintf('%6.0f',run_count/20));

        per_run = 20*.4;
        runs_per_line = 100/per_run;
        run_count = geno_count * proto_count * runs_per_line;
        set(total_runs,'string',sprintf('%6.0f',run_count));
        
        set(total_days,'string',sprintf('%6.0f',run_count/20));
    end
    function check_available(~,~)
        if exist(calender_save_path,'file')
            save_calender_data = load(calender_save_path);
            save_calender_data = save_calender_data.save_calender_data;
        else
            num_of_days = str2double(get(jump_days,'string'));
            for iterD = 1:num_of_days 
                save_template(iterD) = struct('Date',[],'Day_of_week',[],'morning_8am',[],'morning_9am',[],'morning_10am',[],'morning_11am',[],'mid_day_12pm',[],...
                        'afternoon_1pm',[],'afternoon_2pm',[],'afternoon_3pm',[],'afternoon_4pm',[],'evening_5pm',[],'evening_6pm',[]);
            end
        end

        
    end
end