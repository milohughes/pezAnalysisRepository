function video_per_day    
    today_date = datevec(now);
    today_date = sprintf('%04s%02s%02s',num2str(today_date(1)),num2str(today_date(2)),num2str(today_date(3)));
        
    repositoryDir = fileparts(fileparts(fileparts(mfilename('fullpath'))));
    addpath(fullfile(repositoryDir,'Support_Programs'))

   
    op_sys = system_dependent('getos');
    if contains(op_sys,'Microsoft Windows')
        file_dir = ['\\DM11\cardlab\Data_pez3000\' today_date];
        analyized_path = '\\DM11\cardlab\Data_pez3000_analyzed';
        
%        file_dir = ['\\tier2\card\Data_pez3000\' today_date];
%        analyized_path = '\\tier2\card\Data_pez3000_analyzed';        
    else
        file_dir = ['/Volumes/cardlab/Data_pez3000' today_date];
        analyized_path = '/Volumes/cardlab/Data_pez3000_analyzed';        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% figure axis
    backColor = [0 0 0.2];       
    hFigC = figure('NumberTitle','off','Name','Experimental Design Gui',...
           'menubar','none','units','pix','Color',backColor,'pos',[1098 1192 1451 376],'colormap',gray(256),'CloseRequestFcn',@myCloseFun);

    refRate = 4;        %times to be executed per minute        (every 15 seconds? )
    tPlot = timer('TimerFcn',@update_data,'ExecutionMode','fixedRate',...
        'Period',round((60/refRate)*100)/100,'StartDelay',1,'Name','tPlay');
   
    hPanC = uipanel('Position',[0.000 0.0750 0.500 0.8000],'Visible','On','BackgroundColor',rgb('light grey'));
    hPanD = uipanel('Position',[0.500 0.0750 0.500 0.8000],'Visible','On','BackgroundColor',rgb('light grey'));
    hPanE = uipanel('Position',[0.000 0.9000 1.000 0.1000],'Visible','On','BackgroundColor',rgb('light grey'));
    hPanF = uipanel('Position',[0.000 0.000 1.000 0.0750],'Visible','On','BackgroundColor',rgb('light grey'));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                    
    run_names = [];         pez_names = [];         run_index  = 1;
    start_run = 0;          end_run = 0;            half_flag = 1; 
    skip_times  = 0;        start_cut = 0;          end_cut = 24;              filt_runs = [];
    
    run_info = struct('run_names',{},'Exp_ID',{},'Date_time',{},'Trigger_Count',{},'Video_Count',{},'Prev_Video_Count',{});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bar_width = 5;
    h_morning_runs = uicontrol(hPanE,'Style','pushbutton','string','Morning Runs :: 12:00 AM to 8:00 AM','Units','normalized','HorizontalAlignment','left','Interruptible','on',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'position',[0/bar_width 0 1/bar_width  1],'callback',@set_time_filter,'UserData',1);
    h_day_runs = uicontrol(hPanE,'Style','pushbutton','string','Day Runs :: 8:00 AM to 5:00 PM','Units','normalized','HorizontalAlignment','left','Interruptible','on',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'position',[1/bar_width 0 1/bar_width  1],'callback',@set_time_filter,'UserData',1);
    h_evening_runs = uicontrol(hPanE,'Style','pushbutton','string','Evening Runs :: 5:00 PM to 11:59 PM','Units','normalized','HorizontalAlignment','left','Interruptible','on',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4000,'position',[2/bar_width 0 1/bar_width  1],'callback',@set_time_filter,'UserData',1);

    uicontrol(hPanE,'Style','text','string','   Experiment Range','Units','normalized','HorizontalAlignment','left',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4525,'position',[3/bar_width+.02 0 1/10  1]);
    
    new_width = ((.95 - ((3/bar_width) + 1/10) - .01)) / 2;
    run_start = uicontrol(hPanE,'Style','popup','string','...','Units','normalized','HorizontalAlignment','left','Interruptible','on',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4525,'position',[(3/bar_width+(1/10)+.03) 0 new_width  .85],'callback',@change_runs,'UserData',1);    
    run_end = uicontrol(hPanE,'Style','popup','string','...','Units','normalized','HorizontalAlignment','left','Interruptible','on',...
        'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.4525,'position',[(3/bar_width+(1/10)+.04+new_width) 0 new_width  .85],'callback',@change_runs,'UserData',1);        
    
    exp_ids = zeros(4,1);
    set_curr_runs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
    get_initial_data
    limit_boxes
    update_data
    start(tPlot)   
    drawnow
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
    function set_curr_runs(~,~)
        exp_bar_width = 1/4;
        for iterQ = 1:4
            exp_ids(iterQ) = uicontrol(hPanF,'Style','text','string',' ','Units','normalized','HorizontalAlignment','left',...
                'BackgroundColor',[.8 .8 .8],'fontunits','normalized','fontsize',.500,'position',[0.00+exp_bar_width*(iterQ-1) 0.00 exp_bar_width 1]);        
        end        
    end
    function get_initial_data(~,~)
        run_names = struct2dataset(dir(fullfile(file_dir,'run*')));

        %remove pez 3 temp fix
%        run_names = run_names(cellfun(@(x) isempty(strfind(x,'pez3003')),run_names.name),:);
        set(run_start,'string',run_names.name,'value',1);
        set(run_end,'string',run_names.name,'value',length(run_names.datenum));
        for iterZ = run_index:length(run_names.datenum)
            
            if length(run_names) == 1
                run_info(iterZ).run_names = run_names.name;
                true_time = struct2dataset(dir(fullfile([file_dir filesep run_names.name filesep run_names.name '_runStatistics.mat'])));
                video_names = dir(fullfile([file_dir filesep run_names.name],'*.mp4'));
                trigger_img = dir(fullfile([file_dir filesep run_names.name filesep 'inspectionResults'],'*.tif'));
                pez_data = struct2dataset(dir(fullfile([file_dir filesep run_names.name],'*.mp4')));
            else
                run_info(iterZ).run_names = run_names.name(iterZ); %#ok<*SETNU>                
                true_time = struct2dataset(dir(fullfile([file_dir filesep run_names.name{iterZ} filesep run_names.name{iterZ} '_runStatistics.mat'])));
                video_names = dir(fullfile([file_dir filesep run_names.name{iterZ}],'*.mp4'));     
                trigger_img = dir(fullfile([file_dir filesep run_names.name{iterZ} filesep 'inspectionResults'],'*.tif'));
                pez_data = struct2dataset(dir(fullfile([file_dir filesep run_names.name{iterZ}],'*.mp4')));
            end
            curr_time = datevec(true_time.datenum);
            run_info(iterZ).Date_time = curr_time(4);
            
            run_info(iterZ).Video_Count = length(video_names);
            run_info(iterZ).Trigger_Count = length(trigger_img);
            
            if isempty(pez_data)
                continue
            elseif length(pez_data) == 1
                try
                    run_info(iterZ).Exp_ID = {pez_data.name(29:44)};
                catch
                    continue
                end
            else
                run_info(iterZ).Exp_ID = unique(cellfun(@(x) x(29:44),pez_data.name,'uniformoutput',false));
            end
            try
                file_data = load([analyized_path filesep run_info(iterZ).Exp_ID{1} filesep run_info(iterZ).Exp_ID{1} '_rawDataAssessment.mat']);
                run_info(iterZ).Prev_Video_Count = height(file_data.assessTable);
            catch
                run_info(iterZ).Prev_Video_Count = 0;
            end
        end              
        run_index = iterZ;
    end    
    function limit_boxes(~,~)
        curr_time = datevec(now);
        curr_hour = curr_time(4);
        if curr_hour < 17
            set(h_evening_runs,'enable','off')
        end
        if curr_hour < 8
            set(h_day_runs,'enable','off')
        end
    end
    function refresh_new_data(~,~)
        run_names = struct2dataset(dir(fullfile(file_dir,'run*')));
        set(run_start,'string',run_names.name);
        set(run_end,'string',run_names.name);
        
        for iterZ = run_index:length(run_names.datenum)
            run_info(iterZ).run_names = run_names.name(iterZ); %#ok<*SETNU>
            
            try
                true_time = struct2dataset(dir(fullfile([file_dir filesep run_names.name{iterZ} filesep run_names.name{iterZ} '_runStatistics.mat'])));
                video_names = dir(fullfile([file_dir filesep run_names.name{iterZ}],'*.mp4'));
                trigger_img = dir(fullfile([file_dir filesep run_names.name{iterZ} filesep 'inspectionResults'],'*.tif'));            
                pez_data = struct2dataset(dir(fullfile([file_dir filesep run_names.name{iterZ}],'*.mp4')));
            catch
                true_time = struct2dataset(dir(fullfile([file_dir filesep run_names.name filesep run_names.name '_runStatistics.mat'])));
                video_names = dir(fullfile([file_dir filesep run_names.name],'*.mp4'));
                trigger_img = dir(fullfile([file_dir filesep run_names.name filesep 'inspectionResults'],'*.tif'));            
                pez_data = struct2dataset(dir(fullfile([file_dir filesep run_names.name],'*.mp4')));
            end
            curr_time = datevec(true_time.datenum);
            run_info(iterZ).Date_time = curr_time(4);
            
            run_info(iterZ).Video_Count = length(video_names);
            run_info(iterZ).Trigger_Count = length(trigger_img);
            
            if isempty(pez_data)
                run_info(iterZ).Exp_ID = {'0000000000000000'};
            elseif length(pez_data) == 1
                run_info(iterZ).Exp_ID = {pez_data.name(29:44)};
            else
                run_info(iterZ).Exp_ID = unique(cellfun(@(x) x(29:44),pez_data.name,'uniformoutput',false));
            end
            try
                file_data = load([analyized_path filesep run_info(iterZ).Exp_ID{1} filesep run_info(iterZ).Exp_ID{1} '_rawDataAssessment.mat']);
                run_info(iterZ).Prev_Video_Count = height(file_data.assessTable);
            catch
                run_info(iterZ).Prev_Video_Count = 0;
            end
        end     
        run_index = iterZ - 4;
        if run_index < 1
            run_index = 1;
        end
    end
    function update_data(~,~)  
        filter_data
        update_pez_stats
        update_current_run_info
        if half_flag == 0
            hide_pannels('off')
            update_box_plot_triggers
            update_box_plot_vids
            hide_pannels('on')
        end
        refresh_new_data        
    end
    function filter_data(~,~)
        if skip_times == 0
            start_run = find(vertcat(run_info.Date_time) >= start_cut,1,'first');
            end_run = find(vertcat(run_info.Date_time) <= end_cut,1,'last');
        end
        set(run_start,'value',start_run);
        set(run_end,'value',end_run);
        
        filt_runs =  run_info(start_run:end_run);      
        bad_runs = vertcat(filt_runs.Video_Count) == 0;
        filt_runs = filt_runs(~bad_runs);
        
        try
            pez_names = cellfun(@(x) x(8:14),vertcat(filt_runs.run_names),'uniformoutput',false);
        catch
            pez_names = {filt_runs.run_names(8:14)};
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
    function change_runs(hObj,~)
        skip_times = 1;
        value = get(hObj,'Value');
        curr_data = get(hObj,'UserData');
        if hObj == run_start
            start_run = value;
        elseif hObj == run_end
            end_run = value;
        end
        
        set(hObj,'UserData',(1-curr_data));
        set(h_morning_runs,'BackgroundColor',[.8 .8 .8],'UserData',1)
        set(h_day_runs,'BackgroundColor',[.8 .8 .8],'UserData',1)
        set(h_evening_runs,'BackgroundColor',[.8 .8 .8],'UserData',1)
        drawnow
    end
    function set_time_filter(hObj,~)
        skip_times = 0;
        curr_data = get(hObj,'UserData');
        if curr_data == 1
            set(hObj,'BackgroundColor',rgb('light blue'),'UserData',0)
        else
            set(hObj,'BackgroundColor',[.8 .8 .8],'UserData',1)
        end
        if hObj == h_morning_runs && curr_data == 1
            start_cut = 0;                 end_cut = 7;            
            set(h_day_runs,'BackgroundColor',[.8 .8 .8],'UserData',1)
            set(h_evening_runs,'BackgroundColor',[.8 .8 .8],'UserData',1)
        end
        if hObj == h_day_runs && curr_data == 1
            start_cut = 8;                 end_cut = 17;            
            set(h_morning_runs,'BackgroundColor',[.8 .8 .8],'UserData',1)
            set(h_evening_runs,'BackgroundColor',[.8 .8 .8],'UserData',1)            
        end 
        if hObj == h_evening_runs && curr_data == 1
            start_cut = 18;                 end_cut = 24;
            set(h_morning_runs,'BackgroundColor',[.8 .8 .8],'UserData',1)
            set(h_day_runs,'BackgroundColor',[.8 .8 .8],'UserData',1)            
        end
        drawnow
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    function update_pez_stats(~,~)   
        header_list = [{'Pez_ID'},{'Runs'},{'Triggers'},{'Videos'},{'Video Pct'},{sprintf('  Tigger \n  per Run')},{sprintf('  Video \n  Per Run')}];
        x_pos = linspace(.25,6.75,length(header_list));
        y_height = 5.5;
        y_pos = repmat(y_height,1,length(header_list));
        
        hAxesC = axes('position',[0 0 1 1],'parent',hPanC,'box','off','Color',rgb('black'),'Ylim',[0 6],'Xlim',[0 8]);
        line([0 8],[1 1],'color',rgb('light red'),'linestyle',':','parent',hAxesC);        
        text(x_pos,y_pos,header_list,'parent',hAxesC,'Color',rgb('white'),'fontunits','normalized','fontsize',0.0500,'Interpreter','none','parent',hAxesC);
        
%        uni_pez = unique(pez_names);
        uni_pez = [{'pez3001'},{'pez3002'},{'pez3003'},{'pez3004'}];
        count_info = zeros(length(uni_pez)+1,6);
        for iterA = 1:length(uni_pez)
            pez_logic = ismember(pez_names,uni_pez{iterA});
            count_info(iterA,1) = sum(pez_logic);
            count_info(iterA,2) = sum(vertcat(filt_runs(pez_logic).Trigger_Count));
            count_info(iterA,3) = sum(vertcat(filt_runs(pez_logic).Video_Count));
        end
        count_info(iterA+1,1) =  sum(count_info(:,1));
        count_info(iterA+1,2) =  sum(count_info(:,2));
        count_info(iterA+1,3) =  sum(count_info(:,3));
        count_info(:,4) =  (count_info(:,3) ./ count_info(:,2))*100;
        count_info(:,5) =  count_info(:,2) ./ count_info(:,1);
        count_info(:,6) =  count_info(:,3) ./ count_info(:,1);
        
        for iterA = 1:(length(uni_pez))
            text(x_pos(1), (y_height-iterA),sprintf('%s',uni_pez{iterA}),'HorizontalAlignment','left','Color',rgb('white'),...
                'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesC);
            text(x_pos(2), (y_height-iterA),sprintf('%3.0f',count_info(iterA,1)),'HorizontalAlignment','left','Color',rgb('white'),...
                'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesC);
            text(x_pos(3)+0.10, (y_height-iterA),sprintf('%3.0f',count_info(iterA,2)),'HorizontalAlignment','left','Color',rgb('white'),...
                'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesC);
            text(x_pos(4)+0.10, (y_height-iterA),sprintf('%3.0f',count_info(iterA,3)),'HorizontalAlignment','left','Color',rgb('white'),...
                'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesC);
            
            text(x_pos(5), (y_height-iterA),sprintf('%3.3f%%',count_info(iterA,4)),'HorizontalAlignment','left','Color',rgb('white'),...
                'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesC);
            text(x_pos(6)+0.15, (y_height-iterA),sprintf('%3.3f',count_info(iterA,5)),'HorizontalAlignment','left','Color',rgb('white'),...
                'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesC);
            text(x_pos(7)+0.15, (y_height-iterA),sprintf('%3.3f',count_info(iterA,6)),'HorizontalAlignment','left','Color',rgb('white'),...
                'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesC);
        end
        text(x_pos(1), 0.5,sprintf('All Pezes'),'HorizontalAlignment','left','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesC);
        text(x_pos(2), 0.5,sprintf('%3.0f',count_info(iterA+1,1)),'HorizontalAlignment','left','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesC);
        text(x_pos(3)+0.10, 0.5,sprintf('%3.0f',count_info(iterA+1,2)),'HorizontalAlignment','left','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesC);
        text(x_pos(4)+0.10, 0.5,sprintf('%3.0f',count_info(iterA+1,3)),'HorizontalAlignment','left','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesC);    

        text(x_pos(5), 0.5,sprintf('%3.3f%%',count_info(iterA+1,4)),'HorizontalAlignment','left','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesC);
        text(x_pos(6)+0.15,0.5,sprintf('%3.3f',count_info(iterA+1,5)),'HorizontalAlignment','left','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesC);
        text(x_pos(7)+0.15, 0.5,sprintf('%3.3f',count_info(iterA+1,6)),'HorizontalAlignment','left','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesC);
    end
    function update_current_run_info(~,~)    
        header_list = [{'Pez_ID'},{'Status'},{'Time Left'},{sprintf('Trigger\n Count')},{sprintf('Video\nCount')},{sprintf('Time Since\n Last Video')}];
        x_pos = linspace(.25,6.75,length(header_list));
        y_height = 5.5;
        y_pos = repmat(y_height,1,length(header_list));
        
        hAxesD = axes('position',[0 0 1 1],'parent',hPanD,'box','off','Color',rgb('black'),'Ylim',[0 6],'Xlim',[0 8]);
        line([0 8],[1 1],'color',rgb('light red'),'linestyle',':','parent',hAxesD);
        text(x_pos,y_pos,header_list,'parent',hAxesD,'Color',rgb('white'),'fontunits','normalized','fontsize',0.0500,'Interpreter','none');
        

%        uni_pez = unique(pez_names);
        uni_pez = [{'pez3001'},{'pez3002'},{'pez3003'},{'pez3004'}];
        totals = zeros(4,1);
        for iterA = 1:length(uni_pez)
            logic_match = (find(ismember(pez_names,uni_pez{iterA}),1,'last'));
            skip_folder = 0;
            if sum(logic_match) == 0
%                skip_folder = 1;
                continue
%                pez_data =  [];
            end

            text(x_pos(1), (y_height-iterA),sprintf('%s',uni_pez{iterA}),'HorizontalAlignment','left','Color',rgb('white'),...
                'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
            
            if skip_folder == 0
                pez_folder = filt_runs(logic_match).run_names;            
                try
                    pez_data = struct2dataset(dir(fullfile([file_dir filesep pez_folder],'*.mp4')));
                    trigger_img = struct2dataset(dir(fullfile([file_dir filesep pez_folder filesep 'inspectionResults'],'*.tif')));                
                catch
                    pez_data = struct2dataset(dir(fullfile([file_dir filesep pez_folder{1}],'*.mp4')));
                    trigger_img = struct2dataset(dir(fullfile([file_dir filesep pez_folder{1} filesep 'inspectionResults'],'*.tif')));
                end

                set(exp_ids(iterA),'string',sprintf('Exp ID :: %s  ::   Video Count :: %3.0f',filt_runs(logic_match).Exp_ID{1},filt_runs(logic_match).Prev_Video_Count));
            end

            if skip_folder == 1
                video_size = 0;
                trigger_size  = 0;            
            elseif isempty(pez_data.name)
                video_size = 0;
                trigger_size  = 0;
            elseif ischar(pez_data.name)
                video_size = 1;
                trigger_size  = 1;
            else
                video_size = length(pez_data.name);
                trigger_size = length(trigger_img.name);                                            
            end
            totals(2) = totals(2)+trigger_size;
            totals(3) = totals(3)+video_size;
            
            text(x_pos(4)+.15, (y_height-iterA),sprintf('%3.0f',trigger_size),'HorizontalAlignment','left','Color',rgb('white'),...
                'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
                        
            text(x_pos(5)+.05, (y_height-iterA),sprintf('%3.0f',video_size),'HorizontalAlignment','left','Color',rgb('white'),...
                'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
            
            if length(filt_runs) == 1
                runStats = load([file_dir filesep pez_folder filesep pez_folder '_runStatistics']);                
            else
                runStats = load([file_dir filesep pez_folder{1} filesep pez_folder{1} '_runStatistics']);                
            end
            runStats = runStats.runStats;
            run_start_time = datevec(runStats.time_start);            
            run_start_time(5) = run_start_time(5) + 20;
            
            time_left = run_start_time - datevec(now);
            time_left_min = (time_left(4) * 3600 + time_left(5) * 60 + time_left(6)) / 60;
            
            if skip_folder == 1
                time_left_min = 0;
            end
            
            if time_left_min > 0
                status = 'running';
            else
                status = 'stopped';
            end
            text(x_pos(2)+.25, (y_height-iterA),sprintf('%s',status),'HorizontalAlignment','center','Color',rgb('white'),...
                'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
            
            if strcmp(status,'stopped')
                time_left_min = 0;
            end
            if time_left_min >  totals(1)
                totals(1) = time_left_min;
            end            
            
            text(x_pos(3)+.40, (y_height-iterA),sprintf('%3.2f minutes',time_left_min),'HorizontalAlignment','center','Color',rgb('white'),...
                'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
                
            if video_size == 0
                video_time = run_start_time;
                video_time(5) = video_time(5) - 20;
            else
                try
                    video_time = datevec(pez_data.datenum(end));
                catch
                    warning('no date string?')
                end
             end
             time_last = datevec(now) - video_time;
             time_in_seconds = time_last(4) * 3600 + time_last(5) * 60 + time_last(6);
             if strcmp(status,'stopped')
                text(x_pos(6)+.40, (y_height-iterA),sprintf('Run Done'),'HorizontalAlignment','center','Color',rgb('white'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
                time_in_seconds = 0;
             elseif time_in_seconds < 60
                text(x_pos(6)+.40, (y_height-iterA),sprintf('%2.2f seconds',time_in_seconds ),'HorizontalAlignment','center','Color',rgb('white'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
             else
                time_in_minutes = time_in_seconds / 60;
                text(x_pos(6)+.40, (y_height-iterA),sprintf('%2.2f minutes',time_in_minutes),'HorizontalAlignment','center','Color',rgb('white'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
             end
             if time_in_seconds >  totals(4)
                totals(4) = time_in_seconds;
            end
        end        
        text(x_pos(1), 0.5,sprintf('All Pezes'),'HorizontalAlignment','left','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
        if totals(1) == 0
            text(x_pos(6)+.40, .5,sprintf('Runs Done'),'HorizontalAlignment','center','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
        elseif totals(4) < 60
            text(x_pos(6)+.40, .5,sprintf('%2.2f seconds',totals(4)),'HorizontalAlignment','center','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
        else
            text(x_pos(6)+.40, .5,sprintf('%2.2f minutes',totals(4) / 60),'HorizontalAlignment','center','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
        end
        
        text(x_pos(3)+.40, .5,sprintf('%3.2f minutes',totals(1)),'HorizontalAlignment','center','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
        if totals(1) > 0
            text(x_pos(2)+.25, .5,sprintf('Running'),'HorizontalAlignment','center','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
        else
            text(x_pos(2)+.25, .5,sprintf('Stopped'),'HorizontalAlignment','center','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
        end
        text(x_pos(4)+.15, 0.5,sprintf('%3.0f',totals(2)),'HorizontalAlignment','left','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
        text(x_pos(5)+.05, 0.5,sprintf('%3.0f',totals(3)),'HorizontalAlignment','left','Color',rgb('green'),'Interpreter','none','fontunits','normalized','fontsize',0.0500,'parent',hAxesD);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    function myCloseFun(~,~)
        if ishandle(tPlot)
            if strcmp(tPlot.Running,'on'),stop(tPlot),end
            delete(tPlot)
        end
        delete(hFigC)
    end
end