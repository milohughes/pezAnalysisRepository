    function pez_summary_azi(~,~)                                                       %if preforming azimuth sweep, rolls up the data by azimuth
        [azimuth_cat_1,azimuth_cat_2,~,jump_logic,geno_summary,summary_data] = get_gender_info;
        

        parent_list = cellfun(@(x,y) sprintf('%s_%s',x,y),geno_summary.Parent_A_DN,geno_summary.Parent_B_Convert,'UniformOutput',false);
        [total_table_1,jump_table_1] = make_summary_tables(parent_list,azimuth_cat_1,jump_logic);
        [total_table_2,jump_table_2] = make_summary_tables(parent_list,azimuth_cat_2,jump_logic);
        
        total_table = [total_table_1,total_table_2];
%        total_table = total_table_1;
        [~,sort_idx] = sort(total_table.Properties.VariableNames);         total_table = total_table(:,sort_idx);
        
        jump_table = [jump_table_1,jump_table_2];
%        jump_table = jump_table_1;
        [~,sort_idx] = sort(jump_table.Properties.VariableNames);          jump_table = jump_table(:,sort_idx);                       
        
        [total_gender,jump_gender] = make_summary_tables(parent_list,summary_data.Gender,jump_logic);
    end
    function [azimuth_cat_1,azimuth_cat_2,azimuth_cat_3,jump_logic,geno_summary,summary_data] = get_gender_info(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_info = correct_exp_info(exp_info);
        
        parent_list = cellfun(@(x,y) sprintf('%s_%s',x,y),exp_info.ParentA_name,exp_info.ParentB_name,'UniformOutput',false);
        uni_parent = unique(parent_list);
        summary_data = [];
        
        for iterZ = 1:length(uni_parent)
            parent_logic = ismember(parent_list,uni_parent{iterZ});
            good_data = [vertcat(combine_data(parent_logic).Complete_usuable_data);vertcat(combine_data(parent_logic).Videos_Need_To_Work);...
                    vertcat(combine_data(parent_logic).Out_Of_Range)];            
%            good_data = [vertcat(combine_data(parent_logic).Complete_usuable_data);vertcat(combine_data(parent_logic).Videos_Need_To_Work)];

            movement = good_data.Stim_Fly_Saw_At_Trigger - good_data.Stim_Pos_At_Trigger;
            movement(movement > 180) = movement(movement > 180) - 360;
            movement(movement < -180) = movement(movement < -180) + 360;
            
%            good_data(abs(movement) > 30,:) = [];       %delete flies that move over 30 degrees
 
            summary_data = [summary_data;good_data];
        end
        [~,jump_logic] = get_jump_info(summary_data);
        
        geno_string = cellfun(@(x) x(33:40),summary_data.Properties.RowNames,'uniformoutput',false);
        [locA,locB] = ismember(geno_string,cellfun(@(x) x(5:12),get(exp_info,'ObsNames'),'UniformOutput',false));
        full_parent_B = exp_info.ParentB_name(locB(locA));
        Parent_B = convert_background_labels(full_parent_B);
                
        geno_summary = cell2table([convert_labels(geno_string,exp_info,'exp_str_4'),full_parent_B,Parent_B]);
        geno_summary.Properties.RowNames = summary_data.Properties.RowNames;
        geno_summary.Properties.VariableNames = [{'Exp_ID'},{'Parent_A'},{'Parent_A_Convert'},{'Parent_A_DN'},{'Parent_B'},{'Parent_B_Convert'}];
        
        %azi_index = (0-azi_off):(2*azi_off):(180+azi_off);
        azi_index_1 = -22.5:45:(180+22.5);
        azi_index_2 = 0:45:(180+45);
        azi_index_3 = -22.5:45:(360+22.5);
        
        azimuth_cat_1 = ones(height(summary_data),1) * -10;
        azimuth_cat_2 = ones(height(summary_data),1) * -10;
        azimuth_cat_2(abs(summary_data.Stim_Fly_Saw_At_Trigger) == 0) = 22.5;
        
        for iterZ = 1:(length(azi_index_1)-1)
            azi_logic = abs(summary_data.Stim_Fly_Saw_At_Trigger) > (azi_index_1(iterZ)) & abs(summary_data.Stim_Fly_Saw_At_Trigger) <= (azi_index_1(iterZ+1));
            azimuth_cat_1(azi_logic) = azi_index_1(iterZ) + 22.5;
            
            azi_logic = abs(summary_data.Stim_Fly_Saw_At_Trigger) > (azi_index_2(iterZ)) & abs(summary_data.Stim_Fly_Saw_At_Trigger) <= (azi_index_2(iterZ+1));
            azimuth_cat_2(azi_logic) = azi_index_2(iterZ) + 22.5;
        end
        
        
        for iterZ = 1:(length(azi_index_3)-1)
            azi_logic = abs(summary_data.Stim_Fly_Saw_At_Trigger) > (azi_index_3(iterZ)) & abs(summary_data.Stim_Fly_Saw_At_Trigger) <= (azi_index_3(iterZ+1));                        
            azimuth_cat_3(azi_logic) = azi_index_3(iterZ)+22.5;
        end        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% for azimuth sweep and gender counting summaries
    function [total_table,jump_table] = make_summary_tables(group_1,group_2,jump_logic)
        [count_table,~,~,count_labels] = crosstab(group_1,group_2);
        total_table = cell2table(num2cell(count_table));
        filt_labels = count_labels(cellfun(@(x) ~isempty(x),count_labels(:,2)),2);
        
        if sum(cellfun(@(x) contains(x,{'Male';'Female';'Unknown'}),filt_labels)) >= 1
            total_table.Properties.VariableNames = filt_labels;
        else
            filt_labels = str2double(filt_labels);
            filt_labels(filt_labels < 0) =  filt_labels(filt_labels < 0)+360;

            total_table.Properties.VariableNames = cellfun(@(x) sprintf('Azimuth_%03.0f',x),num2cell(filt_labels),'UniformOutput',false);
        end
        total_table.Properties.RowNames = count_labels(cellfun(@(x) ~isempty(x),count_labels(:,1)),1);
        
        [count_table,~,~,count_labels] = crosstab(group_1(jump_logic),group_2(jump_logic));
        jump_table = cell2table(num2cell(count_table));

        filt_labels = count_labels(cellfun(@(x) ~isempty(x),count_labels(:,2)),2);

        if sum(cellfun(@(x) contains(x,{'Male';'Female';'Unknown'}),filt_labels)) >= 1
            jump_table.Properties.VariableNames = filt_labels;
        else
            filt_labels = str2double(filt_labels);
            filt_labels(filt_labels < 0) =  filt_labels(filt_labels < 0)+360;        
            jump_table.Properties.VariableNames = cellfun(@(x) sprintf('Azimuth_%03.0f',x),num2cell(filt_labels),'UniformOutput',false);
        end
        jump_table.Properties.RowNames = count_labels(cellfun(@(x) ~isempty(x),count_labels(:,1)),1);
        
        missing_records = total_table(~ismember(total_table.Properties.RowNames,jump_table.Properties.RowNames),:);
        if ~isempty(missing_records)
            missing_records.Variables = zeros(height(missing_records),width(missing_records));
            jump_table = [jump_table;missing_records];
            jump_table = jump_table(total_table.Properties.RowNames,:);
        end        
        jump_table = jump_table(total_table.Properties.RowNames,total_table.Properties.VariableNames);
    end
    function add_error_bars(curr_plot,jumpers, total)                   %draws error bars on the graph
        wsi = get_error_bars(jumpers,total);
                
        for iterZ = 1:length(jumpers)
            line([iterZ iterZ],[wsi(iterZ,1) wsi(iterZ,2)],'parent',curr_plot,'linewidth',.7,'color',rgb('black'));
        end        
    end
    
%% take off percent functions
    function take_off_azimuth_angles(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_info = correct_exp_info(exp_info);
        
        parent_list = cellfun(@(x,y) sprintf('%s_%s',x,y),exp_info.ParentA_name,exp_info.ParentB_name,'UniformOutput',false);
        uni_parent = unique(parent_list);
        summary_data = [];
                
        for iterZ = 1:length(uni_parent)
            result_data = [];
            
            parent_logic = ismember(parent_list,uni_parent{iterZ});
            good_data = [vertcat(combine_data(parent_logic).Complete_usuable_data);vertcat(combine_data(parent_logic).Videos_Need_To_Work);...
                    vertcat(combine_data(parent_logic).Out_Of_Range)];            
            bad_data = [vertcat(combine_data(parent_logic).Multi_Blank);vertcat(combine_data(parent_logic).Pez_Issues);...
                    vertcat(combine_data(parent_logic).Failed_Location)];            
            bad_track = [vertcat(combine_data(parent_logic).Vid_Not_Tracked);vertcat(combine_data(parent_logic).Bad_Tracking)];
                    
            [~,jump_logic] = get_jump_info(good_data);
            figure;
            index = 1;
            for iterAngle = 0:45:180
                bad_data_count = sum(abs(round(bad_data.VidStat_Stim_Azi.*180/pi - bad_data.fly_detect_azimuth)) == iterAngle);
                track_error_count = sum(abs(round(bad_track.VidStat_Stim_Azi.*180/pi - bad_track.fly_detect_azimuth)) == iterAngle);
                hist_counts = hist(abs(abs(good_data(abs(good_data.Stim_Pos_At_Trigger) == iterAngle,:).Stim_Fly_Saw_At_Trigger) - iterAngle),-7.5:15:60);                
                hist_counts(2) = hist_counts(2) + hist_counts(1);                       hist_counts(1) = [];

                jump_counts = hist(abs(abs(good_data(abs(good_data.Stim_Pos_At_Trigger) == iterAngle & jump_logic,:).Stim_Fly_Saw_At_Trigger) - iterAngle),-7.5:15:60);                
                jump_counts(2) = jump_counts(2) + jump_counts(1);                       jump_counts(1) = [];
                
                result_data = [result_data;[bad_data_count,track_error_count,hist_counts,jump_counts]];
                
                subplot(3,3,index)
                %circ_plot(abs(good_data(abs(good_data.Stim_Pos_At_Trigger) == iterAngle,:).Stim_Fly_Saw_At_Trigger).*pi/180,'pat_special',[],(360/12),true,true,'linewidth',2,'color','r',.5);
                circ_plot((good_data(abs(good_data.Stim_Pos_At_Trigger) == iterAngle,:).Stim_Fly_Saw_At_Trigger).*pi/180,'pat_special',[],(360/22.5),true,true,'linewidth',2,'color','r',.5);
                index = index + 1;
            end                        
        end
    end
    function take_off_azimuth_sweeep(~,~)
        
        
        angle_type = 1;
        [azimuth_cat_1,azimuth_cat_2,azimuth_cat_3,jump_logic,geno_summary,all_data] = get_gender_info;

        if angle_type == 1 
            azimuth_cat = azimuth_cat_3';
        elseif angle_type == 2
            azimuth_cat = [azimuth_cat_1,azimuth_cat_2];
        end
               
        %parent_list = geno_summary.Parent_A_DN;
        parent_list = cellfun(@(x,y) sprintf('%s_%s',x,y),geno_summary.Parent_A_DN,geno_summary.Parent_B_Convert,'UniformOutput',false);
        uni_parent = unique(parent_list);
        split_factors = length(uni_parent);
        %azi_interest = 0:30:180;
        azi_interest = unique(azimuth_cat);
        
        figure
        [x_plot,y_plot] = split_fig(split_factors);
        for iterZ = 1:split_factors
            subplot(x_plot,y_plot,iterZ)
            parent_logic = ismember(parent_list,uni_parent{iterZ});
            summary_data = all_data(parent_logic,:);
            filt_jump_logic = jump_logic(parent_logic);
            filt_azimuth = azimuth_cat(parent_logic,:);
            
            if angle_type == 1 
                [totals,~,~,total_label] = crosstab(filt_azimuth,summary_data.Gender);
                [jumpers,~,~,jump_label] = crosstab(filt_azimuth(filt_jump_logic),summary_data(filt_jump_logic,:).Gender);

                total_table = cell2table(num2cell(totals));
                total_table.Properties.RowNames = total_label(cellfun(@(x) ~isempty(x),total_label(:,1)),1);
                total_table.Properties.VariableNames = total_label(cellfun(@(x) ~isempty(x),total_label(:,2)),2);

                jump_table = cell2table(num2cell(jumpers));
                jump_table.Properties.RowNames = jump_label(cellfun(@(x) ~isempty(x),jump_label(:,1)),1);
                jump_table.Properties.VariableNames = jump_label(cellfun(@(x) ~isempty(x),jump_label(:,2)),2);
            elseif angle_type == 2
                [totals_1,~,~,total_label_1] = crosstab(filt_azimuth(:,1),summary_data.Gender);
                [totals_2,~,~,total_label_2] = crosstab(filt_azimuth(:,2),summary_data.Gender);
                
                total_table = cell2table(num2cell([totals_1;totals_2]));
                total_table.Properties.RowNames = [total_label_1(cellfun(@(x) ~isempty(x),total_label_1(:,1)),1);total_label_2(cellfun(@(x) ~isempty(x),total_label_2(:,1)),1)];
                total_table.Properties.VariableNames = total_label_1(cellfun(@(x) ~isempty(x),total_label_1(:,2)),2);
                
                [jumpers_1,~,~,jump_label_1] = crosstab(filt_azimuth(filt_jump_logic,1),summary_data(filt_jump_logic,:).Gender);
                [jumpers_2,~,~,jump_label_2] = crosstab(filt_azimuth(filt_jump_logic,2),summary_data(filt_jump_logic,:).Gender);
                
                jump_table = cell2table(num2cell([jumpers_1;jumpers_2]));
                jump_table.Properties.RowNames = [jump_label_1(cellfun(@(x) ~isempty(x),jump_label_1(:,1)),1);jump_label_2(cellfun(@(x) ~isempty(x),jump_label_2(:,1)),1)];
                jump_table.Properties.VariableNames = jump_label_1(cellfun(@(x) ~isempty(x),jump_label_1(:,2)),2);
                
            end
            [~,sort_idx] = sort(str2double(total_table.Properties.RowNames));           total_table = total_table(sort_idx,:);
            [~,sort_idx] = sort(str2double(jump_table.Properties.RowNames));            jump_table = jump_table(sort_idx,:);
            
            missing_data = total_table(~ismember(total_table.Properties.RowNames,jump_table.Properties.RowNames),:);
            if ~isempty(missing_data)
                missing_data.Variables = 0;
                jump_table = [jump_table;missing_data];
                [locA,locB] = ismember(total_table.Properties.RowNames,jump_table.Properties.RowNames);
                jump_table = jump_table(locB(locA),:);                
            end


            female_jump_rate = jump_table.Female ./ total_table.Female;
            male_jump_rate = jump_table.Male ./ total_table.Male;
            total_jump_rate = sum(jump_table.Variables,2) ./ sum(total_table.Variables,2);
            
            wsi_male = get_error_bars(jump_table.Male,total_table.Male);
            wsi_female = get_error_bars(jump_table.Female,total_table.Female);
            
         
            set(gca,'nextplot','add')
            plot(azi_interest,total_jump_rate','-k','LineWidth',2.5);
            plot(azi_interest,male_jump_rate','-bo','LineWidth',1.2,'MarkerSize',10);
            plot(azi_interest,female_jump_rate','-ro','LineWidth',1.2,'MarkerSize',10);
            
            y_cord_path = [wsi_male(:,1)' wsi_male(end,2) wsi_male(end:-1:1,2)' wsi_male(1,1)];
            x_cord_path = [azi_interest' azi_interest(end) azi_interest(end:-1:1)' azi_interest(1)];            
            patch(x_cord_path,y_cord_path,rgb('light blue'),'facealpha',.25)
            
            y_cord_path = [wsi_female(:,1)' wsi_female(end,2) wsi_female(end:-1:1,2)' wsi_female(1,1)];
            x_cord_path = [azi_interest' azi_interest(end) azi_interest(end:-1:1)' azi_interest(1)];            
            patch(x_cord_path,y_cord_path,rgb('light red'),'facealpha',.25)            
         
            set(gca,'Ylim',[0 1],'Ytick',0:.2:1,'Ygrid','on','XTick',azi_interest,'Xlim',[-7.5 187.5]);
            title(sprintf('%s',uni_parent{iterZ}),'Interpreter','none','HorizontalAlignment','center');
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function pathway_by_gender(~,~)
        new_y_data = [1 2.5 5 10 20 50 100 250 500 1000];
        line_cut = log(7);
        
        [~,~,azimuth_cat,~,geno_summary,summary_data] = get_gender_info;
        done_logic = cellfun(@(x) ~isempty(x), summary_data.frame_of_leg_push);
        azimuth_cat = azimuth_cat(done_logic);        geno_summary = geno_summary(done_logic,:);
        jump_data = summary_data(done_logic,:);
        
        done_logic = cellfun(@(x) ~isnan(x), jump_data.frame_of_leg_push);
        azimuth_cat = azimuth_cat(done_logic);        geno_summary = geno_summary(done_logic,:);
        jump_data = jump_data(done_logic,:);        
        
        %parent_list = geno_summary.Parent_A_DN;
        parent_list = cellfun(@(x,y) sprintf('%s_%s',x,y),geno_summary.Parent_A_DN,geno_summary.Parent_B_Convert,'UniformOutput',false);
        uni_parent = unique(parent_list);
        
        split_factors = length(uni_parent);
%        figure
        [x_plot,y_plot] = split_fig(split_factors);
        for iterZ = 1:split_factors
            %subplot(x_plot,y_plot,iterZ)
            figure
            matching_data = jump_data(ismember(parent_list,uni_parent(iterZ)),:);
            pathway = cellfun(@(x,y) log((x - y) /6),matching_data.frame_of_take_off,matching_data.frame_of_wing_movement);
            time_to_contact = cellfun(@(x,y,z) (x-y - z)/6, matching_data.frame_of_leg_push,matching_data.Start_Frame,matching_data.Stimuli_Duration);
            filt_azimith = azimuth_cat(ismember(parent_list,uni_parent(iterZ)));
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % if seperate by azimuth
%             [y_data,x_data,~] = iosr.statistics.tab2box(azimuth_cat(ismember(parent_list,uni_parent(iterZ))),pathway);
%             [x_data,sort_idx] = sort(x_data);
%             y_data = y_data(:,sort_idx);
%             
%             h = iosr.statistics.boxPlot(x_data',y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
%                         'showScatter', true,'boxAlpha',1,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));                    
%             set(gca,'Xlim',[-15 195],'Ylim',[0 6],'Ytick',log(new_y_data),'YTickLabel',new_y_data,'Ygrid','on');
%             line([-15 195],[line_cut line_cut],'color',rgb('green'),'linewidth',.8,'parent',gca);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % if seperate by gender
            [y_data,x_data,~] = iosr.statistics.tab2box(filt_azimith',pathway,matching_data.Gender);
 %           [y_data,x_data,~] = iosr.statistics.tab2box(filt_azimith',time_to_contact,matching_data.Gender);
            [x_data,sort_idx] = sort(x_data);
            y_data = y_data(:,sort_idx,:);
            
%            [p, h, stats] = ranksum(y_data(:,1),y_data(:,2));

            for iterR = 1:length(x_data)
                [p(iterR), h, stats] = ranksum(y_data(:,iterR,1),y_data(:,iterR,2));
            end
            
%            [y_data,x_data,~] = iosr.statistics.tab2box(matching_data.Gender,time_to_contact);
            [y_data,x_data,~] = iosr.statistics.tab2box(matching_data.Gender,pathway);
            [x_data,sort_idx] = sort(x_data);
            y_data = y_data(:,sort_idx,:);
            
            [p(iterR+1), h, stats] = ranksum(y_data(:,1),y_data(:,2));
            
            h = iosr.statistics.boxPlot(1:1:length(x_data),y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                        'showScatter', true,'boxAlpha',1,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));                    
%            set(gca,'Ylim',[0 6],'Ytick',log(new_y_data),'YTickLabel',new_y_data,'Ygrid','on','XTickLabel',x_data);            
            set(gca,'Ylim',[-500 200],'Ytick',-500:100:200,'Ygrid','on','XTickLabel',x_data);            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            title_str = sprintf('%s',uni_parent{iterZ});
            title(sprintf('%s',title_str),'Interpreter','none','HorizontalAlignment','center','fontsize',12);
        end
    end
    function pathway_by_geno_v2(hObj,~)
        selection = get(hObj,'UserData');
        plot_type = selection - mod(selection,1);
        selection = round(mod(selection,1)*10);
        plot_display = 1;
        
        if selection  == 1
            parent_list = result_table.Parent_A;
        elseif selection  == 2
            parent_list = result_table.Parent_B;
            lplc2_logic = cellfun(@(x) contains(x,'LPLC2'),result_table.Parent_A);
            loom_logic = cellfun(@(x) contains(x,'loom_010to180_lv040'),result_table.Protocol_Used);
        end
                        
        new_y_data = [1 2.5 5 10 20 50 100 250 500 1000];
        
        uni_parent = unique(parent_list);
        
        split_factors = length(uni_parent);
        figure
        [x_plot,y_plot] = split_fig(split_factors);
        
        for iterZ = 1:split_factors
            subplot(x_plot,y_plot,iterZ)
            drawnow;
            matching_data = result_table(ismember(parent_list,uni_parent(iterZ)),:);
%            matching_data = result_table(ismember(parent_list,uni_parent(iterZ)) & lplc2_logic & loom_logic,:);
            jump_data = matching_data.Video_data;

            matching_data.Protocol_Used = regexprep(matching_data.Protocol_Used,' Ele','\nEle');
            total_counts = cellfun(@(x) height(x), jump_data);
            
            if plot_type == 1       %full pathway
                pathway = cellfun(@(x) log((cell2mat(x.frame_of_take_off) - cell2mat(x.frame_of_wing_movement)) /6),jump_data,'UniformOutput',false);
                line_cut = log(7);
                %upper_y_lim = 5.25;
                upper_y_lim = 6.25;
%                upper_y_lim = 8;
            elseif plot_type == 2   %wing cycle
                pathway = cellfun(@(x) log((cell2mat(x.wing_down_stroke) - cell2mat(x.frame_of_wing_movement)) /6),jump_data,'UniformOutput',false);
                line_cut = log(3.5);
                upper_y_lim = 5.25;                
            elseif plot_type == 3   %leg push cycle
                pathway = cellfun(@(x) log((cell2mat(x.frame_of_take_off) - cell2mat(x.frame_of_leg_push)) /6),jump_data,'UniformOutput',false);
            end
%            pathway = cellfun(@(x) x(x<= log(100)),pathway,'UniformOutput',false);
            
            short_count = cellfun(@(x) sum(x < line_cut), pathway);
            total_counts = cellfun(@(x) length(x), pathway);
            short_pct = (short_count ./ total_counts)*100;
            
            if selection == 1
                plot_labels = cellfun(@(x,y) sprintf('%s\n%s',x,y),matching_data.Parent_B,matching_data.Protocol_Used,'UniformOutput',false);
            elseif selection == 2
                plot_labels = cellfun(@(x,y) sprintf('%s\n%s',x,y),matching_data.Parent_A,matching_data.Protocol_Used,'UniformOutput',false);
            end             
                        
            group_labels = cellfun(@(x,y) repmat({x},length(y),1),plot_labels,pathway,'UniformOutput',false);
            group_labels = vertcat(group_labels{:});
                
            group_labels  = cellfun(@(x) regexprep(x,'\n',''),group_labels,'UniformOutput',false);
            sort_list  = cellfun(@(x) regexprep(x,'\n',''),plot_labels,'UniformOutput',false);
            sort_list = unique(sort_list);
            
            title_str = sprintf('%s',uni_parent{iterZ});
            
            pathway = vertcat( pathway{:});
            [group_labels,sort_idx] = sort(group_labels);    
            [plot_labels,sort_labels] = sort(plot_labels);
            total_counts = total_counts(sort_labels);
            short_pct = short_pct(sort_labels);
            pathway = pathway(sort_idx);
            
            if plot_display == 1       %boxplot
                [y_data,x_data,~] = iosr.statistics.tab2box(group_labels,pathway);
                [locA,locB] = ismember(x_data,sort_list);

                %if any record has only 1 value, double it so plot works
                missing_value = length(y_data) - sum(isnan(y_data));
                missing_index = find(missing_value == 1);
                y_data(2,missing_index) = y_data(1,missing_index);   

                plot_data = -10*ones(size(y_data,1),length(plot_labels),1);
                plot_data(:,locB(locA)) = y_data;

                try
                h = iosr.statistics.boxPlot(1:1:length(plot_labels),plot_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                        'showScatter', true,'boxAlpha',1,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));                    
                catch
                    warning('why problem')
                end

                set(gca,'Xlim',[.5 (length(plot_labels)+.5)],'Ylim',[0 upper_y_lim],'Ytick',log(new_y_data),'YTickLabel',new_y_data,'Ygrid','on');

                add_plot_labels(gca,plot_labels,0,'center',0,10);
                title(sprintf('%s',title_str),'Interpreter','none','HorizontalAlignment','center','fontsize',12);
                text(1:1:length(total_counts),repmat(.95*upper_y_lim,length(total_counts),1),arrayfun(@(x,y) sprintf('%3.0f\n(%2.2f%%)',x,y),total_counts,short_pct,'UniformOutput',false),...
                    'Interpreter','none','HorizontalAlignment','center','fontsize',10);
                line([.5 (length(plot_labels)+.5)],[line_cut line_cut],'color',rgb('green'),'linewidth',.8,'parent',gca);
            elseif plot_display == 2       %histogram
                [f,x] = hist(pathway,0:.25:7);
                f = f ./ sum(f);
                hb = bar(x,f,'hist');
                title(sprintf('%s',title_str),'Interpreter','none','HorizontalAlignment','center','fontsize',12);
                set(gca,'Xlim',[0 upper_y_lim],'Xtick',log(new_y_data),'XTickLabel',new_y_data,'Ygrid','on');
                set(gca,'Ylim',[0 .25],'Ytick',0:.05:.25);
                line([line_cut line_cut],[0 .25],'color',rgb('green'),'linewidth',.8,'parent',gca);
                
            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function gender_compare_graphs(~,~)
        [~,~,~,~,geno_summary,summary_data] = get_gender_info;
        remove_data = cellfun(@(x) contains(x,'Unknown'),summary_data.Gender);
        geno_summary(remove_data,:) = [];
        summary_data(remove_data,:) = [];

        org_position = summary_data.fly_detect_azimuth + 360;
        start_position = summary_data.Fly_Pos_At_Stim_Start;
        pos_change = start_position - org_position;
        pos_change(pos_change < -180) = pos_change(pos_change < -180) + 360;
        pos_change(pos_change >  180) = pos_change(pos_change >  180) - 360;
        
        [y_data,x_data,group_data] = iosr.statistics.tab2box(geno_summary.Parent_A_DN,pos_change,summary_data.Gender);
             
        figure
        h = iosr.statistics.boxPlot(1:1:length(x_data),y_data,'symbolColor','k','medianColor','k','symbolMarker','+',...
                 'showScatter', false,'boxAlpha',.1,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));                    
        h.boxColor = [{rgb('blue')};{rgb('red')}];
        h.showLegend = true;
        h.groupLabels = group_data;
             
       
        set(gca,'XTickLabel',x_data,'TickLabelInterpreter','none','Ylim',[-75 75],'Ytick',-75:15:75);
        ylabel('amount of rotation in degrees');
        title('Amount fly rotation between trigger frame and stimuli start seperated by genotype and gender')
    end
    function fly_pos_dir(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_info = correct_exp_info(exp_info);        
        
        %fly position vecter from lights on to end of tracking
        bot_data_info = cellfun(@(x,y) x(y:end,:),filt_data.bot_points_and_thetas,filt_data.Start_Frame,'UniformOutput',false);
        frame_1_cords = cell2mat(cellfun(@(x) x(1,:),bot_data_info,'UniformOutput',false));
        trigger_pos = (filt_data.fly_detect_azimuth.*pi/180) + 2*pi;
        
        not_track_enough = cellfun(@(x) length(x), bot_data_info) < 900;            %fly leaves before 150 milliseconds
        move_to_far = abs((frame_1_cords(:,3) - trigger_pos).*180/pi) > 90;         %removes data where tracking says fly moved more then 90 degrees (possible bad tracking)
        frame_1_cords(move_to_far | not_track_enough,:) = [];              trigger_pos(move_to_far | not_track_enough,:) = [];
        bot_data_info(move_to_far| not_track_enough,:) = [];               in_range_data = filt_data(~(move_to_far | not_track_enough),:);
        
        [~,matching_exp_info] = ismember(cellfun(@(x) x(29:44),in_range_data.Properties.RowNames,'UniformOutput',false),get(exp_info,'ObsNames'));
        new_name_list = get(exp_info(matching_exp_info,:),'ObsNames');
        new_name_list = cellfun(@(x) x(5:12),new_name_list,'UniformOutput',false);
        new_name_list = convert_labels(new_name_list,exp_info,'exp_str_8');
        parent_B = exp_info(matching_exp_info,:).ParentB_name;

        food_type = exp_info(matching_exp_info,:).Food_Type;
        food_type = cellfun(@(x) regexprep(x,'Standard .(Cornmeal.)','Cornmeal'),food_type,'UniformOutput',false);

        figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        ctl_corn_logic = cellfun(@(x,y) contains(x,'SS01062') & contains(y,'Cornmeal'),new_name_list(:,4),food_type);
        scatter_fly_pos_light_on(1,ctl_corn_logic,frame_1_cords);
        scatter_fly_pos_delay_ms(5,ctl_corn_logic,bot_data_info,50);        %50 ms delay (lights off)
        scatter_fly_pos_delay_ms(9,ctl_corn_logic,bot_data_info,100);       %100 ms delay 
        scatter_fly_pos_delay_ms(13,ctl_corn_logic,bot_data_info,150);       %150 ms delay 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
        ctl_retinal_logic = cellfun(@(x,y) contains(x,'SS01062') & contains(y,'Retinal'),new_name_list(:,4),food_type);
        scatter_fly_pos_light_on(2,ctl_retinal_logic,frame_1_cords);        
        scatter_fly_pos_delay_ms(6,ctl_retinal_logic,bot_data_info,50);        %50 ms delay (lights off)
        scatter_fly_pos_delay_ms(10,ctl_retinal_logic,bot_data_info,100);       %100 ms delay 
        scatter_fly_pos_delay_ms(14,ctl_retinal_logic,bot_data_info,150);       %150 ms delay         
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
        exp_corn_logic = cellfun(@(x,y) contains(x,'SS57049') & contains(y,'Cornmeal'),new_name_list(:,4),food_type);
        scatter_fly_pos_light_on(3,exp_corn_logic,frame_1_cords);
        scatter_fly_pos_delay_ms(7,exp_corn_logic,bot_data_info,50);        %50 ms delay (lights off)        
        scatter_fly_pos_delay_ms(11,exp_corn_logic,bot_data_info,100);        %50 ms delay (lights off)        
        scatter_fly_pos_delay_ms(15,exp_corn_logic,bot_data_info,150);        %50 ms delay (lights off)        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                        
        exp_retinal_logic = cellfun(@(x,y) contains(x,'SS57049') & contains(y,'Retinal'),new_name_list(:,4),food_type);
        scatter_fly_pos_light_on(4,exp_retinal_logic,frame_1_cords);        
        scatter_fly_pos_delay_ms(8,exp_retinal_logic,bot_data_info,50);        %50 ms delay (lights off)        
        scatter_fly_pos_delay_ms(12,exp_retinal_logic,bot_data_info,100);        %50 ms delay (lights off)        
        scatter_fly_pos_delay_ms(16,exp_retinal_logic,bot_data_info,150);        %50 ms delay (lights off)                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    end
    function scatter_fly_pos_light_on(plot_indx,geno_logic,frame_1_cords)
        frame_1_cords = frame_1_cords(geno_logic,:);
        
        subplot(4,4,plot_indx)
        set(gca,'nextplot','add');
        for iterP = 1:length(frame_1_cords)
            plot(frame_1_cords(iterP,1),frame_1_cords(iterP,2),'ko')
            u = cos(frame_1_cords(iterP,3))*25;             v = -sin(frame_1_cords(iterP,3))*25;
            quiver(frame_1_cords(iterP,1),frame_1_cords(iterP,2),u,v,'LineWidth',1.2,'AutoScaleFactor',1,'color',rgb('red'),'MaxHeadSize',5);
        end
        set(gca,'Xlim',[0 384],'Ylim',[0 384],'Ydir','reverse');
        line([0 384],[192 192],'linewidth',.8,'color',rgb('black'));
        line([192 192],[0 384],'linewidth',.8,'color',rgb('black'));
        title('fly position at lights on');
    end
    function scatter_fly_pos_delay_ms(plot_index,geno_logic,bot_data_info,time_off)
        subplot(4,4,plot_index)
        frame_100_cords = cell2mat(cellfun(@(x) x(1+(time_off*6),:),bot_data_info(geno_logic,:),'UniformOutput',false));   %50 ms after lights off
        %frame_100_cords = cell2mat(cellfun(@(x) x,bot_data_info(geno_logic,:),'UniformOutput',false));   %50 ms after lights off
        frame_1_cords = cell2mat(cellfun(@(x) x(1,:),bot_data_info(geno_logic,:),'UniformOutput',false));   %50 ms after lights off
        set(gca,'nextplot','add');
   
        movement_diff = frame_100_cords - frame_1_cords;
        rotated_move = arrayfun(@(x,y,z) rotation([x y],[0 0],-z),movement_diff(:,1),movement_diff(:,2),frame_1_cords(:,3),'UniformOutput',false); 
        rotated_move = cell2mat(rotated_move);
        
        set(gca,'nextplot','add');
        for iterP = 1:length(rotated_move)
            plot(rotated_move(iterP,1),rotated_move(iterP,2),'ko')
        end
        title('Rotated Fly Position 50ms after lights off (100 ms total)');                
        set(gca,'Xlim',[-192 192],'Ylim',[-192 192]);
        line([-192 192],[0 0],'linewidth',.8,'color',rgb('black'));
        line([0 0],[-192 192],'linewidth',.8,'color',rgb('black'));   
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function movement_scatter_plot(~,~)
        exp_info = vertcat(combine_data(:).parsed_data);
        exp_info = correct_exp_info(exp_info);
        
        testing_data = filt_data;
        diffWin = 9;
        
        sample_ids = [{'0128000024880799'},{'0128000025320799'}];       %1062 and 57742 x retinal        
        testing_data = testing_data(cellfun(@(x) contains(x,sample_ids),testing_data.Properties.RowNames),:);
        
        testing_data = testing_data(cellfun(@(x,y) length(x(:,1)) > y + 300,testing_data.bot_points_and_thetas,testing_data.Start_Frame),:);        %has tracking to end of lights off
        exp_id = cellfun(@(x) x(29:44),testing_data.Properties.RowNames,'UniformOutput',false);
        for iterZ = 1:height(testing_data)
            roiPos = testing_data(iterZ,:).Adjusted_ROI{1};
%            prismW = mean(roiPos(2,:)-roiPos(1,:)-30);%minus 30 to account for roi swell in pezControl_v9
            prismW = roiPos(8,1) - roiPos(7,1);
            pix2mm = @(x) x.*(5/prismW);%prism is 5mm and ~250 pixels wide
            
            record_rate = double(testing_data(iterZ,:).record_rate);
            frm2sec = @(x) x/(record_rate/1000);
            frm2secSqared = @(x) (x.*(record_rate/1000).^2)*1000;
            
            
            botLabels = testing_data(iterZ,:).bot_points_and_thetas{1};
            topLabels = testing_data(iterZ,:).top_points_and_thetas{1};
            start_frame = testing_data(iterZ,:).Start_Frame{1};
            
            XYZ_3D_filt = [botLabels(:,1) botLabels(:,2), topLabels(:,2)];
            zero_posXYZ_filt = [zeros(1,3);abs(diff(XYZ_3D_filt))];         %zero all spacial coordinates
            zero_posXYZ_filt = cumsum(zero_posXYZ_filt);                    %recreate the vector
            zero_pos_filt = sqrt(sum(zero_posXYZ_filt.^2,2));               %reduces dimensionality to one
            zero_netXYZ = XYZ_3D_filt-repmat(XYZ_3D_filt(1,:),size(XYZ_3D_filt,1),1);
            smooth_dist_filt = (zero_pos_filt(1:testing_data(iterZ,:).final_frame_tracked{1}));
           
            [dist_vec_filt,speed_vec_filt,accel_vec_filt] = golayDifferentiate(smooth_dist_filt,diffWin);
    
            dist_vec_mm = (pix2mm(dist_vec_filt));%33
            speed_vec_frm = (frm2sec(pix2mm(speed_vec_filt)));%33
%            speed_vec_frm = speed_vec_filt .* (6000 / 50);      %mm/sec
            accel_vec_frm = (frm2secSqared(pix2mm(accel_vec_filt)));%33            

%             filtWin = 9;
%             botLabels(:,1) = smooth(botLabels(:,1),filtWin)';
%             botLabels(:,2) = smooth(botLabels(:,2),filtWin)';
%             botLabels(:,3) = smooth(unwrap(botLabels(:,3)),filtWin)';
%             
%             filtered_pos(iterZ) = {botLabels};
%             filtered_vel(iterZ) = {[Xfirst(:),Yfirst(:),Tfirst(:)]};
%             filtered_accel(iterZ) = {[Xsecond(:),Ysecond(:),Tsecond(:)]};
             filtered_pos(iterZ) = {dist_vec_mm};
             filtered_vel(iterZ) = {speed_vec_frm};
             filtered_accel(iterZ) = {accel_vec_frm};
        end
        
        empty_records = cellfun(@(x) isempty(x),filtered_pos);
        filtered_pos(empty_records) = [];
        filtered_vel(empty_records) = [];
        exp_id(empty_records) = [];

        uni_ids = unique( exp_id);
        for iterID = 1:length(uni_ids)
            figure
            id_logic = ismember(exp_id,uni_ids{iterID});
            filt_pos = filtered_pos(id_logic);
            filt_vel = filtered_vel(id_logic);
            for iterZ = 1:10
                subplot(4,5,iterZ)
                dataPos = filt_pos{iterZ};
                plot((1:1:length(dataPos))./6000,dataPos);       %mm/sec
                subplot(4,5,iterZ+10)  
                dataVel = filt_vel{iterZ};
                plot(dataVel);
            end
        end

        for iterV = 1:length(filtered_pos)
            dataVel = filtered_vel{iterV};
            dataPos = filtered_pos{iterV};
            
            start_frame = testing_data(iterV,:).Start_Frame{1};
            compFiltWin = 50*6;
            if length(dataPos) > (start_frame+(100*6)+1)
                result_data(iterV,1) = mean(dataPos(1:(start_frame-1)),'omitnan');               %position pre stim
                result_data(iterV,2) = mean(dataPos(start_frame:(start_frame+(50*6))),'omitnan');
                result_data(iterV,3) = mean(dataPos((start_frame+(50*6))+1:(start_frame+(100*6))+1),'omitnan');      %position after

                result_data(iterV,4) = mean(dataVel(1:(start_frame-1)),'omitnan');              %velocity pre stim
                result_data(iterV,5) = mean(dataVel(start_frame:(start_frame+(50*6))),'omitnan');
                result_data(iterV,6) = mean(dataVel((start_frame+(50*6))+1:(start_frame+(100*6))+1),'omitnan');      %velocity after            
            else
                result_data(iterV,1) = mean(dataPos(1:(start_frame-1)),'omitnan');               %position pre stim
                result_data(iterV,2) = mean(dataPos(start_frame:(start_frame+(50*6))),'omitnan');
                result_data(iterV,3) = mean(dataPos((start_frame+(50*6))+1:end),'omitnan');      %position after

                result_data(iterV,4) = mean(dataVel(1:(start_frame-1)),'omitnan');              %velocity pre stim
                result_data(iterV,5) = mean(dataVel(start_frame:(start_frame+(50*6))),'omitnan');
                result_data(iterV,6) = mean(dataVel((start_frame+(50*6))+1:end),'omitnan');      %velocity after            
                
            end
        end
%% Figure for publishing !!!!!!!!!!!!!!!!!!!!!!!!!!!
        saveFig = 1;
        plotMode = 1; % 1 - show dots, 2 - hide dots
        dataMode = 2;
        % 1 - forward v back
        % 2 - turning

        dataCt = 3;
        px = cell(dataCt,1);
        py = cell(dataCt,1);
        eYall = zeros(3,dataCt); mYall = zeros(3,dataCt);
        for iterP = 1:2
%        for iterL = 1:dataCt
        if iterP == 1
            for iterL = 1:3

                ydata =  result_data(:,iterL);
                x = (rand(numel(ydata),1)-0.5)*0.25+(iterL);%+datarefs(iterL);
                px{iterL} = x;
                py{iterL} = ydata;
            end            
        else
            for iterL = 4:6

                ydata =  result_data(:,iterL);
                x = (rand(numel(ydata),1)-0.5)*0.25+(iterL-3);%+datarefs(iterL);
                px{iterL} = x;
                py{iterL} = ydata;
            end
        end
        px(cellfun(@(x) isempty(x),px)) = [];
        py(cellfun(@(x) isempty(x),py)) = [];
        
        figure
        uni_id = unique(exp_id);
        for iterZ = 1:length(uni_id)
            subplot(4,2,iterZ)
            exp_id_logic = ismember(exp_id,uni_id{iterZ});
            backC = [1 1 1];
            set(gcf,'units','normalized')
%             hax = zeros(1,dataCt);
%             hax(1) = axes;
%             haxPos = get(hax(1),'position');
%             growShiftAx = [-0.2,-0.2,0.1,-0.05];%grow width, grow height, shift X, shift Y
%             haxPos = [haxPos(1)-haxPos(3)*growShiftAx(1)/2,haxPos(2)-haxPos(4)*growShiftAx(2)/2,...
%                 haxPos(3)*(1+growShiftAx(1)),haxPos(4)*(1+growShiftAx(2))]+[growShiftAx(3:4) 0 0];
            hold on
            fontC = [0 0 0];
            filt_px = cellfun(@(x) x(exp_id_logic),px,'UniformOutput',false);
            filt_py = cellfun(@(x) x(exp_id_logic),py,'UniformOutput',false);
            
            %standard error of the median
            for iterL  = 1:dataCt
                ydata =  filt_py{iterL};
                q1 = prctile(ydata,25); q2 = prctile(ydata,50);
                q3 = prctile(ydata,75); n = numel(ydata);
                eBar = ([q2 - 1.57*(q3 - q1)/sqrt(n);q2 + 1.57*(q3 - q1)/sqrt(n)]);
                mBar = ([q2;q2]);

                eYall(:,iterL) = [eBar' NaN]';
                mYall(:,iterL) = [mBar' NaN]';            
            end
            
            %x = cat(1,px{:});            ydata = cat(1,py{:});
            x = cat(1,filt_px{:});        ydata = cat(1,filt_py{:});
            [p,anovatab,stats] = kruskalwallis(ydata,round(x),'off');
            
            if plotMode == 1
                plot(x,ydata,'.','color','k','markersize',10)
            end
            matching_info = exp_info(ismember(get(exp_info,'ObsNames'),uni_id{iterZ}),:);
            title_str = cellfun(@(x,y,z) sprintf('%s X %s\n%s',x,y,z),matching_info.ParentA_name,matching_info.ParentB_name,matching_info.Food_Type,'UniformOutput',false);
            
            title(sprintf('%s',title_str{1}),'Interpreter','none','HorizontalAlignment','center');
%            set(gca,'Ylim',[-10 10],'Xlim',[.5 (dataCt+.5)],'XTick',1:1:dataCt,'XTickLabel',[{'Pre Stimuli'},{'Lights On (50 ms)'},{'50 ms after lights off'}],'TickLabelInterpreter','none');
%            set(gca,'Ytick',-10:5:10,'Ygrid','on');
            
            medianX = repmat((1:dataCt),3,1);
            medianX = medianX+repmat([-.3;.3;0],1,dataCt);
            errorX = repmat((1:dataCt),3,1)-.3;
            plot([medianX;errorX],[mYall;eYall],'color','r','linewidth',4);
            
            plot(get(gca,'xlim'),[0 0],'color','k','linewidth',1)
        end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [sub_plot_handles,stim_logic_vect,title_str_vect,rotation_prob_summary] = make_sub_plot_windows(stim_saw_trigger,rotation_prob_summary,rotation_amount,jump_logic)
        stim_logic_vect = [];
        title_str_vect = [];
        create_matrix = true;
        if isempty(rotation_prob_summary)
            create_matrix = false;
        end
        angle_index = -120:30:120;
        for iterZ = 1:length(angle_index)
            new_y_pos = 0;
            stim_angle = angle_index(iterZ);
            stim_logic = stim_saw_trigger >= (angle_index(iterZ)-15) & stim_saw_trigger < (angle_index(iterZ)+15);
            switch angle_index(iterZ)
                case -120
                     index = 21;
                     new_y_pos = .1100+3*(.1243 * (1/3));
                case -90
                    index = 22;
                case -60
                    index = 23;
                    new_y_pos = .1100+3*(.1243 * (1/3));
                case -30
                    index = 24;
                    new_y_pos = .1100+3*(.1243 * (2/3));
                case 0
                    index = 15;
                case 30
                    index = 4;
                    new_y_pos = .8007-3*(.1243 * (2/3));
                case 60
                    index = 3;
                    new_y_pos = .8007-3*(.1243 * (1/3));
               case 90
                    index = 2;
               case 120
                    index = 1;
                    new_y_pos = .8007-3*(.1243 * (1/3));
            end
            if create_matrix
                rotation_prob_summary = get_rotation_counts(rotation_prob_summary,iterZ,stim_angle,rotation_amount,stim_logic,jump_logic);
            end            
            title_str = sprintf('Simuli Shown :: %03.0f degrees',stim_angle);
            
            curr_plot = subplot(5,5,index);
            curr_pos = get(curr_plot,'position');
            if new_y_pos ~= 0
                curr_pos(2) = new_y_pos;
                set(curr_plot,'Position',curr_pos);
            else
                set(curr_plot,'Position',curr_pos);
            end
            sub_plot_handles(iterZ) = curr_plot;
            stim_logic_vect = [stim_logic_vect;{stim_logic}];
            title_str_vect = [title_str_vect;{title_str}];
        end
    end
    function rotation_prob_summary = get_rotation_counts(rotation_prob_summary,index,azi_angle,rotation_amount,stim_logic,jump_logic)
        summary_info = [];
        summary_info = [summary_info,sum(abs(rotation_amount(stim_logic & jump_logic)) < 15 & abs(rotation_amount(stim_logic & jump_logic)) >= 0)];
        summary_info = [summary_info,sum(abs(rotation_amount(stim_logic & jump_logic)) < 45 & abs(rotation_amount(stim_logic & jump_logic)) >= 15)];
        summary_info = [summary_info,sum(abs(rotation_amount(stim_logic & jump_logic)) < 180 & abs(rotation_amount(stim_logic & jump_logic)) >= 45)];

        summary_info = [summary_info,sum(abs(rotation_amount(stim_logic & ~jump_logic)) < 15 & abs(rotation_amount(stim_logic & ~jump_logic)) >= 0)];
        summary_info = [summary_info,sum(abs(rotation_amount(stim_logic & ~jump_logic)) < 45 & abs(rotation_amount(stim_logic & ~jump_logic)) >= 15)];
        summary_info = [summary_info,sum(abs(rotation_amount(stim_logic & ~jump_logic)) < 180 & abs(rotation_amount(stim_logic & ~jump_logic)) >= 45)];
       
        total_vids = sum(summary_info);
        total_jump = sum(stim_logic & jump_logic);
        
        rotation_prob_summary(index,:) = [azi_angle,total_vids,total_jump,summary_info];
    end
    function pct_no_move = show_pdf_dist(rotation_amount,logic_vect,plot_color,plot_handle,pdf_index)
        [f,x_index] = pdf_cdf_testing(rotation_amount(logic_vect),pdf_index,rgb('dark green'),'hide');
        prob_less_20 = trapz(x_index(x_index < -20),f(x_index < -20));
        prob_greater_20 = trapz(x_index(x_index > 20),f(x_index > 20));
        
        pct_no_move = 1- prob_less_20 - prob_greater_20;
        
%        f = f ./ max(f);        %normalize 0-1;
        plot(x_index,f,'-','color',plot_color,'linewidth',1.2,'parent',plot_handle);
    end  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function fly_pos_at_jump(~,~)
        angle_index = -120:30:120;
%        summary_table = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work)];
        summary_table = vertcat(combine_data(:).Complete_usuable_data);
        [jump_data,stay_data] = split_jump_stay_data(summary_table);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find fly position at jump or end of track
        jump_data(cellfun(@(x,y) size(x,1) <= y,jump_data.bot_points_and_thetas,jump_data.frame_of_leg_push),:) = [];        %has tracking time of jump
        jump_position_at_leg = cellfun(@(x,y) x(y,3) .* 180/pi,jump_data.bot_points_and_thetas,jump_data.frame_of_leg_push);
        stay_position_at_leg = cellfun(@(x,y) x(y,3) .* 180/pi,stay_data.bot_points_and_thetas,stay_data.final_frame_tracked);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find fly position at start of stimuli
        jump_position_at_stim = cellfun(@(x,y) x(y,3) .* 180/pi,jump_data.bot_points_and_thetas,jump_data.Start_Frame);
        stay_position_at_stim = cellfun(@(x,y) x(y,3) .* 180/pi,stay_data.bot_points_and_thetas,stay_data.Start_Frame);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% find fly position of stimuli
        jump_stimuli_pos = (cell2mat(jump_data.stimulus_azimuth) + 2*pi).*180/pi;
        stay_stimuli_pos = (cell2mat(stay_data.stimulus_azimuth) + 2*pi).*180/pi;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% normalize angles 0 to 360
        jump_stimuli_pos = rem(rem(jump_stimuli_pos,360)+360,360);              stay_stimuli_pos = rem(rem(stay_stimuli_pos,360)+360,360);
        jump_position_at_stim = rem(rem(jump_position_at_stim,360)+360,360);    stay_position_at_stim = rem(rem(stay_position_at_stim,360)+360,360);
        jump_position_at_leg  = rem(rem(jump_position_at_leg,360)+360,360);     stay_position_at_leg = rem(rem(stay_position_at_leg,360)+360,360);
        
        jump_pathway = cellfun(@(x,y) (x-y)/6, jump_data.wing_down_stroke,jump_data.frame_of_wing_movement);
        stay_pathway = nan(length(stay_position_at_stim),1);
        
        jump_logic = [true(length(jump_position_at_stim),1); false(length(stay_position_at_stim),1)];
        all_pathway = [jump_pathway;stay_pathway];
        short_logic = all_pathway < 3.66;
        
        all_stimuli_pos = [jump_stimuli_pos;stay_stimuli_pos];
        all_data_start = [jump_position_at_stim;stay_position_at_stim];
        all_data_response = [jump_position_at_leg;stay_position_at_leg];

        stim_saw_trigger = (all_stimuli_pos - all_data_start);
        stim_saw_trigger(stim_saw_trigger<-180) = stim_saw_trigger(stim_saw_trigger<-180) + 360;
        stim_saw_trigger(stim_saw_trigger> 180) = stim_saw_trigger(stim_saw_trigger >180) - 360;
        
        stim_saw_jump = (all_stimuli_pos - all_data_response);
        stim_saw_jump(stim_saw_jump<-180) = stim_saw_jump(stim_saw_jump<-180) + 360;
        stim_saw_jump(stim_saw_jump> 180) = stim_saw_jump(stim_saw_jump >180) - 360;
        
        rotation_amount = (stim_saw_jump - stim_saw_trigger);
        rotation_amount(rotation_amount > 180) = rotation_amount(rotation_amount > 180) - 360;
        rotation_amount(rotation_amount <-180) = rotation_amount(rotation_amount <-180) + 360;
        
        rotation_prob_summary = zeros(7,(6+3));
        figure
        [sub_plot_handles,stim_logic_vect,title_str_vect,rotation_prob_summary] = make_sub_plot_windows(stim_saw_trigger,rotation_prob_summary,rotation_amount,jump_logic);
            
        all_pct_no_move_jump = [];              all_pct_no_move_stay = [];
        over_all_jump_rate = [];                twenty_degree_jump_rate = [];           more_then_20 = [];
        for iterZ = 1:length(angle_index)
            stim_logic = stim_logic_vect{iterZ};
            title_str = title_str_vect{iterZ};
            set(sub_plot_handles(iterZ),'nextplot','add')
            pct_no_move_jump = show_pdf_dist(rotation_amount,(stim_logic & jump_logic),rgb('dark green'),sub_plot_handles(iterZ),-180:5:180);
            pct_no_move_stay = show_pdf_dist(rotation_amount,(stim_logic & ~jump_logic),rgb('red'),sub_plot_handles(iterZ),-180:5:180);
            
            all_pct_no_move_jump = [all_pct_no_move_jump,pct_no_move_jump];
            all_pct_no_move_stay = [all_pct_no_move_stay,pct_no_move_stay];
            
            over_all_jump_rate = [over_all_jump_rate,sum(stim_logic & jump_logic) / sum(stim_logic)];
            twenty_degree_jump_rate = [twenty_degree_jump_rate,sum(abs(rotation_amount(stim_logic & jump_logic)) <= 20) / sum(abs(rotation_amount(stim_logic)) <= 20)];
            more_then_20 = [more_then_20,sum(abs(rotation_amount(stim_logic & jump_logic)) > 20) / sum(abs(rotation_amount(stim_logic)) > 20)];
            
            %set(sub_plot_handles(iterZ),'Ytick',[],'Ylim',[0 1],'Xlim',[-180 180],'Xtick',-180:45:180); 
            set(sub_plot_handles(iterZ),'Ytick',[],'Xlim',[-180 180],'Xtick',-180:45:180); 
            title(sprintf('%s  \nVid count :: %4.0f  Jump Pct :: %2.2f%%',title_str,sum(stim_logic),(sum(stim_logic & jump_logic)/sum(stim_logic))*100),...
                        'Interpreter','none','HorizontalAlignment','center','parent',sub_plot_handles(iterZ));
            drawnow();
        end
        subplot(5,5,11:12)
        set(gca,'nextplot','add')
        plot(angle_index,all_pct_no_move_jump,'-go');
        plot(angle_index,all_pct_no_move_stay,'-ro');
        title('percent of populate that moved less then 20 degrees');
        set(gca,'Ylim',[0 1],'Ytick',0:.25:1,'Xtick',angle_index,'Ygrid','on','fontsize',13);
        
        subplot(5,5,24:25)
        set(gca,'nextplot','add')
        plot(angle_index,twenty_degree_jump_rate,'-go');
        plot(angle_index,over_all_jump_rate,'-ko','linewidth',1.3);
        plot(angle_index,more_then_20,'-ro');
        title('Jump rate of sub 20 degree move vs population');
        set(gca,'Ylim',[0 1],'Ytick',0:.25:1,'Xtick',angle_index,'Ygrid','on','fontsize',13);
        

        [~,sort_idx] = sort(rotation_prob_summary(:,1));
        rotation_prob_summary = rotation_prob_summary(sort_idx,:);
    end  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function escape_angle(~,~)
        summary_table = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work);vertcat(combine_data(:).Out_Of_Range)];
        [jump_data,~] = split_jump_stay_data(summary_table);
        jump_frame = jump_data.autoFrameOfTakeoff;
        jump_frame(cellfun(@(x) ~isempty(x),jump_data.frame_of_take_off)) = jump_data(cellfun(@(x) ~isempty(x),jump_data.frame_of_take_off),:).frame_of_take_off;
        
        tracking_jump = jump_data(cellfun(@(x,y) length(x(:,3)) >= y, jump_data.bot_points_and_thetas,jump_frame),:);
        tracking_jump = tracking_jump(cellfun(@(x) x >= 100,tracking_jump.frame_of_take_off),:);

% 
%         no_wall_logic = cellfun(@(x) contains(x,'loom_5to90_lv40_blackonwhite.mat'),tracking_jump.Stimuli_Used);
%         tracking_jump = tracking_jump(no_wall_logic,:);
        
        figure
        fly_pos_at_leg = cellfun(@(x,y) x(y,3), tracking_jump.bot_points_and_thetas,tracking_jump.frame_of_leg_push);
        stimuli_pos = (tracking_jump.VidStat_Stim_Azi)+2*pi;
        
        stim_fly_saw = stimuli_pos - fly_pos_at_leg;
        stim_fly_saw  = rem(rem(stim_fly_saw ,2*pi)+2*pi,2*pi); 
        stim_fly_saw = stim_fly_saw .* 180/pi;
        
        org_wall_position = get_wall_pos(tracking_jump);
        wall_position = org_wall_position - fly_pos_at_leg.*180/pi;
        wall_position = rem(rem(wall_position ,360)+360,360);
        
        [~,stim_edge,stim_bin] = histcounts(stim_fly_saw,-22.5:45:(360+22.5));
        rebined_stim = stim_edge(stim_bin);
        rebined_stim = rebined_stim +22.5;              rebined_stim(rebined_stim == 360) = 0;
        
        [~,wall_edge,wall_bin] = histcounts(wall_position,-22.5:45:(360+22.5));
        rebined_wall = wall_edge(wall_bin);
        rebined_wall = rebined_wall +22.5;              rebined_wall(rebined_wall == 360) = 0;
        
        rebined_wall(org_wall_position == 360) = 450;
        
        [cross_tab,~,~,cross_labels,cross_idx] = crosstab(rebined_stim,rebined_wall);
        
        
        %stim_testing = [0,45,90,270,315];
        stim_testing = [90,270];
        wall_testing = [0:45:315,450];
        
        for iterZ = 1:length(stim_testing)
            figure;
            stim_logic = rebined_stim == stim_testing(iterZ);
            for iterW = 1:length(wall_testing)
                subplot(3,3,iterW)
                wall_logic = rebined_wall == wall_testing(iterW);
                sample_data = tracking_jump(stim_logic & wall_logic,:);
                angle_vect = get_jump_angle(sample_data,'All',gca,1); 
            end
        end  
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    function total_rotation = caculate_movement(summary_table,start_angle,end_angle)        
        time_to_start_angle = floor(-40/tan(10*pi/360) + 40/tan(start_angle*pi/360));
        time_to_start_angle = time_to_start_angle* -6;        %convert into frames
        
        time_to_end_angle = floor(-40/tan(10*pi/360) + 40/tan(end_angle*pi/360));
        time_to_end_angle = time_to_end_angle* -6;        %convert into frames
        
        summary_table(cellfun(@(x,y) size(x,1) < (y+time_to_start_angle),summary_table.bot_points_and_thetas,summary_table.Start_Frame),:) = [];        %has tracking at least start of stimuli
        
        not_done_logic = cellfun(@(x) isempty(x), summary_table.frame_of_leg_push);
        missing_data = summary_table(not_done_logic,:).autoFrameOfTakeoff;
        missing_logic = cell2mat(summary_table(not_done_logic,:).jumpTest);
        missing_data(~missing_logic) = {NaN};
        summary_table(not_done_logic,:).frame_of_leg_push = missing_data;
        
        
        already_jumped = cell2mat(summary_table.frame_of_leg_push) < cell2mat(summary_table.Start_Frame)+time_to_start_angle;
        summary_table(already_jumped,:) = [];
        
        cut_frame = cell2mat(summary_table.Start_Frame)+time_to_end_angle;
        
        %if fly jumped in time window, change cut frame to leg frame
        jump_count = sum(cell2mat(summary_table.frame_of_leg_push) < cut_frame);
        cut_frame(cell2mat(summary_table.frame_of_leg_push) < cut_frame) = cell2mat(summary_table(cell2mat(summary_table.frame_of_leg_push) < cut_frame,:).frame_of_leg_push);
        
        %if tracking ended in time window, change cut frame to last frame tracked
        lost_tracking = sum(cell2mat(summary_table.final_frame_tracked) < cut_frame);
        cut_frame(cell2mat(summary_table.final_frame_tracked) < cut_frame) = cell2mat(summary_table(cell2mat(summary_table.final_frame_tracked) < cut_frame,:).final_frame_tracked);
        
%        org_pos_rot = cellfun(@(x,y) x((y+time_to_start_angle),:),summary_table.bot_points_and_thetas,summary_table.Start_Frame,'UniformOutput',false);
        org_pos_rot = cellfun(@(x,y) x(y,:),summary_table.bot_points_and_thetas,summary_table.Start_Frame,'UniformOutput',false);
        new_pos_rot = cellfun(@(x,y) x(y,:),summary_table.bot_points_and_thetas,num2cell(cut_frame),'UniformOutput',false);
        org_pos_rot = cell2mat(org_pos_rot);            org_pos_rot(:,3) = org_pos_rot(:,3).*180/pi;        
        new_pos_rot = cell2mat(new_pos_rot);            new_pos_rot(:,3) = new_pos_rot(:,3).*180/pi;        
        
        total_rotation = new_pos_rot(:,3) - org_pos_rot(:,3);
        total_rotation(total_rotation >  180) = total_rotation(total_rotation >  180) - 360;
        total_rotation(total_rotation < -180) = total_rotation(total_rotation < -180) + 360;
    end
    function get_rotation_amount(test_data,jump_flag)
        if jump_flag == 0
            jump_logic = cell2mat(test_data.jumpTest) == 0;
        elseif jump_flag == 1
            jump_logic = cell2mat(test_data.jumpTest) == 1;
        end
        total_rotation = caculate_movement(test_data(jump_logic,:),0,180);

        male_logic = cellfun(@(x) strcmp(x,'Male'),test_data(jump_logic,:).Gender);
        female_logic = cellfun(@(x) strcmp(x,'Female'),test_data(jump_logic,:).Gender);
        
        pdf_cdf_testing(total_rotation(male_logic),-180:5:180,rgb('blue'));
        set(gca,'nextplot','add','Ytick',[])
        pdf_cdf_testing(total_rotation(female_logic),-180:5:180,[255,20,147]./256);
                
        [~,p_value] = kstest2(total_rotation(male_logic),total_rotation(female_logic));
        if jump_flag == 0
            title(sprintf('Rotation Amount for Flies that Stayed on Prism\n P value :: %2.4f',p_value),'HorizontalAlignment','center');
        elseif jump_flag == 1
            title(sprintf('Rotation Amount for Flies that Jumped\n P value :: %2.4f',p_value),'HorizontalAlignment','center');            
        end
        
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 