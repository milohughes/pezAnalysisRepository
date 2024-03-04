function Escape_jump_dir_plot
    repositoryDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repositoryDir,'Support_Programs'))
    addpath(repositoryDir);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    currdir = cd;
    directory = 'C:\Users\breadsp\Documents\Pez3000_Gui_Folder\Matlab_functions\IoSR-Surrey-MatlabToolbox-4bff1bb';
    cd(directory);
    addpath(directory,[directory filesep 'deps' filesep 'SOFA_API']);
    
    SOFAstart(0);    
    cd(currdir); % return to original directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    combine_data = [];
    
    temp_range = [22.5,24.0];                   humidity_cut_off = 40;
    azi_off = 22.5;                             remove_low = false;                             low_count = 5;
    
   
    %sample_ids = [{'0069000001640523'};{'0069000001640525'};{'0069000001660523'};{'0069000001660525'}];     %gf
    %sample_ids = [{'0069000013040523'};{ '0069000013040525'}];                                              %double line
    %sample_ids = [{'0069000016860523'};{'0069000016860525'}];                                               %tripple line
    %sample_ids = {'0108000024860730'};                           %dnp11 -- 49010
    %sample_ids = {'0108000024850730'};                           %dnp11 -- 49024
    %sample_ids = {'0108000024870730'};                           %dnp11 -- 49051
    
    selection = 'DNp11';
    %selection = 'DNp11 - Silenced';

    %selection = 'Control - Silenced';
    %selection = 'Giant Fiber';
    
    if strcmp(selection,'DNp11')
        sample_ids = [{'0108000024860730'}; {'0108000024850730'};  {'0108000024870730'}]; 
        title_string = sprintf('Escape Azimuth for DNp011');
    elseif strcmp(selection,'DNp02,DNp04')
        sample_ids = [{'0069000013040523'};{ '0069000013040525'}];                        
        title_string = sprintf('Escape Azimuth for DNp02,DNp04');        
    elseif strcmp(selection,'DNp02,DNp04,DNp06')
        sample_ids = [{'0069000016860523'};{'0069000016860525'}];                        
        title_string = sprintf('Escape Azimuth for DNp02,DNp04,DNp06');        
    elseif strcmp(selection,'Giant Fiber')
        sample_ids = [{'0069000001640523'};{'0069000001640525'};{'0069000001660523'};{'0069000001660525'}];          
        title_string = sprintf('Escape Azimuth for Giant Fiber');                        
    elseif strcmp(selection,'DNp11 - Silenced')   %lv40 azi 0
        sample_ids = [{'0112000024890581'};{'0112000024890584'}];          
        title_string = sprintf('Escape Azimuth for DN Silenced');
    elseif strcmp(selection,'Control - Silenced')   %lv40 azi 180
        sample_ids = [{'0112000023700592'};{'0112000023700734'}];          
        title_string = sprintf('Escape Azimuth for SS1062 Silenced');
    end
    
    steps = length(sample_ids);
    parfor iterZ = 1:steps

        test_data =  Experiment_ID(sample_ids{iterZ});
        test_data.temp_range = temp_range;
        test_data.humidity_cut_off = humidity_cut_off;
        test_data.remove_low = remove_low;
        test_data.low_count = low_count;
        test_data.azi_off = azi_off;
        try
            test_data.load_data;
            test_data.make_tables;
            combine_data = [combine_data;test_data];  
        catch
            warning('id with no graph table');
        end
    end
    steps = length(combine_data);
    for iterZ = 1:steps
        combine_data(iterZ).get_tracking_data;
    end 
    for iterZ = 1:steps
        combine_data(iterZ).display_data
    end 
    all_passing_data = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work)];
%     stim_start_frame = passing_data.Start_Frame;
%     stim_start_frame = cell2table(stim_start_frame);
%     passing_data = passing_data.Properties.RowNames;
%     stim_start_frame.Properties.RowNames = passing_data;
%         
%     for iterZ = 1:length(sample_ids)
%         geno_ids = sample_ids{iterZ};
%         manual_data = load(['Z:\Data_pez3000_analyzed' filesep geno_ids filesep geno_ids '_manualAnnotations']);
%         all_manual = [all_manual;manual_data.(cell2mat(fieldnames(manual_data)))]; %#ok<*AGROW>
%         
%         graph_data = load(['Z:\Data_pez3000_analyzed' filesep geno_ids filesep geno_ids '_dataForVisualization']);
%         all_graph = [all_graph;graph_data.(cell2mat(fieldnames(graph_data)))]; %#ok<*AGROW>
%                     
%         load_list = struct2dataset(dir(['Z:\Data_pez3000_analyzed' filesep geno_ids filesep geno_ids '_flyAnalyzer3000_v14']));
%         load_list = load_list(cellfun(@(x) contains(x,'.mat'),load_list.name),:);
%         for iterL = 1:length(load_list)
%             track_data = load(['Z:\Data_pez3000_analyzed' filesep geno_ids filesep geno_ids '_flyAnalyzer3000_v14' filesep load_list.name{iterL}]);
%             all_track_data = [all_track_data;track_data.(cell2mat(fieldnames(track_data)))];            
%         end
%     end
%     all_passing_data = [all_manual(passing_data,:),stim_start_frame(passing_data,:),all_graph(passing_data,:),all_track_data(passing_data,:)];
    
            
    
    jump_logic = cellfun(@(x) isempty(x), all_passing_data.frame_of_leg_push);
    all_passing_data(jump_logic,:) = [];       
    
    jump_logic = cellfun(@(x) isnan(x), all_passing_data.frame_of_leg_push);
    all_passing_data(jump_logic,:) = [];       
    
    no_tracking = cellfun(@(x) isempty(x), all_passing_data.bot_points_and_thetas);
    all_passing_data(no_tracking,:) = [];
    
    
    short_tracking = cellfun(@(x,y) length(x(:,1)) < y,all_passing_data.bot_points_and_thetas,all_passing_data.frame_of_take_off);
    all_passing_data(short_tracking,:) = [];
    
        
    fly_bot_change_pos = cellfun(@(x,y,z) x([1,y],:),all_passing_data.bot_points_and_thetas,all_passing_data.frame_of_leg_push,'UniformOutput',false);
    com_rot_change = cell2mat(cellfun(@(x) rotation(x(2,1:2) - x(1,1:2),[0 0],-x(1,3),'radians'), fly_bot_change_pos,'UniformOutput',false));
%    time_of_leg = cellfun(@(x,y) (x-y)/6, all_passing_data.frame_of_leg_push,all_passing_data.Start_Frame);
    time_of_leg = cellfun(@(x,y) (x-y)/6, all_passing_data.frame_of_take_off,all_passing_data.Start_Frame);
    
    figure
    iosr.statistics.boxPlot(1,time_of_leg,'symbolColor','k','medianColor','k','symbolMarker','+',...
           'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));            

    
%     figure
%     subplot(2,2,1); 
%     circ_plot(cart2pol(com_rot_change((time_of_leg>  0 & time_of_leg <=  50),1),com_rot_change((time_of_leg>  0 & time_of_leg <=  50),2)),'hist');
%     
%     subplot(2,2,2);    
%     circ_plot(cart2pol(com_rot_change((time_of_leg> 50 & time_of_leg <= 75),1),com_rot_change((time_of_leg> 50 & time_of_leg <= 75),2)),'hist');
%     
%     subplot(2,2,3);   
%     circ_plot(cart2pol(com_rot_change((time_of_leg> 75 & time_of_leg <= 125),1),com_rot_change((time_of_leg> 75 & time_of_leg <= 125),2)),'hist');
%     
%     subplot(2,2,4);  
%     circ_plot(cart2pol(com_rot_change((time_of_leg>125 & time_of_leg <= 200),1),com_rot_change((time_of_leg>125 & time_of_leg <= 200),2)),'hist');
    
    
    figure;
    all_passing_data = all_passing_data(time_of_leg >= 0 & time_of_leg <= 100,:);
    
    
    fly_bot_pos = cellfun(@(x,y,z) x(y:z,:),all_passing_data.bot_points_and_thetas,all_passing_data.frame_of_leg_push,all_passing_data.frame_of_take_off,'UniformOutput',false);
    fly_top_pos = cellfun(@(x,y,z) x(y:z,:),all_passing_data.top_points_and_thetas,all_passing_data.frame_of_leg_push,all_passing_data.frame_of_take_off,'UniformOutput',false);
    
    ele_angle = cellfun(@(x) (x(end,2) - x(1,2)) /(x(end,1) - x(1,1))  ,fly_top_pos);
    org_azi_pos = cellfun(@(x) 360-(x(1,3).*180/pi) ,fly_bot_pos);
    %org_azi_pos = cellfun(@(x) x(1,3) ,fly_bot_pos);
    pos_change = cell2mat(cellfun(@(x) [(x(end,1) - x(1,1)) ,(x(end,2) - x(1,2))]  ,fly_bot_pos,'UniformOutput',false));
    
    rot_pos = cell2mat(arrayfun(@(x,y,z) rotation([x y],[0 0],-z,'degrees'),pos_change(:,1),pos_change(:,2),org_azi_pos,'UniformOutput',false));    
    %rot_pos = cell2mat(arrayfun(@(x,y,z) rotation([x y],[0 0],z,'radians'),pos_change(:,1),pos_change(:,2),org_azi_pos,'UniformOutput',false));    
    normalized_azi_esc = atan2(rot_pos(:,2),rot_pos(:,1));

    figure; 
    scatter(rot_pos(:,1),rot_pos(:,2));

    fig_range = 100;
    set(gca,'Xlim',[-fig_range fig_range],'Ylim',[-fig_range fig_range]);
    line([-fig_range fig_range],[0 0],'color',rgb('black'))
    line([0 0],[-fig_range fig_range],'color',rgb('black'))
    
    
    figure;
%    circ_plot(normalized_azi_esc,'hist',[],20,true,true);
    circ_plot(normalized_azi_esc,'pat_special',[],20,true,true,'linewidth',2,'color','r',.25);
    set(gca,'Xlim',[-.275 .275],'Ylim',[-.275 .275]);   
    title(title_string);
    
    escape_ele = atan(abs(ele_angle(:,1)));         
    escape_ele = ((pi/2) - escape_ele) ./ (pi/2);

    [x_data,y_data] = pol2cart(normalized_azi_esc,escape_ele);
    figure; 
    set(gca,'nextplot','add');
    zz = exp(1i*linspace(0, 2*pi, 101));

    plot(real(zz), imag(zz));
    set(gca, 'XLim', [-1.1 1.1], 'YLim', [-1.1 1.1])
    axis square;
    set(gca,'box','off')
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    text(1.2, 0, '0'); text(-.05, 1.2, '\pi/2');  text(-1.35, 0, '\pi');  text(-.075, -1.2, '-\pi/2');
    th = 0 : pi / 50 : 2 * pi;
    xunit = cos(th);
    yunit = sin(th);
    % now really force points on x/y axes to lie on them exactly
    inds = 1 : (length(th) - 1) / 4 : length(th);
    xunit(inds(2 : 2 : 4)) = zeros(2, 1);
    yunit(inds(1 : 2 : 5)) = zeros(3, 1);    
    rmin = 0;       rmax = 1;           rticks = (90/15); %each ring is 15 degrees
    rinc = (rmax - rmin) / rticks;

    for i = (rmin + rinc) : rinc : rmax
        line(xunit * i, yunit * i, 'LineStyle', '-', 'Color', rgb('light gray'), 'LineWidth', 1, ...
            'HandleVisibility', 'off', 'Parent', gca);
    end    
    
    scatter(x_data,y_data);    
end
