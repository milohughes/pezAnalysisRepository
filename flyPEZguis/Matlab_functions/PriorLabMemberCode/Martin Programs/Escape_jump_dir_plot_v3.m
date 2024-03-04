ffunction Escape_jump_dir_plot_v3
    repositoryDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repositoryDir,'Support_Programs'))
    addpath(repositoryDir);
    
    
    save_flag = 1;
    save_filepath = '\\DM11\cardlab\Matlab_Save_Plots\Peekm\directionality';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    currdir = cd;
     directory = 'C:\Users\breadsp\Documents\Pez3000_Gui_Folder\Matlab_functions\IoSR-Surrey-MatlabToolbox-4bff1bb';
%    directory = 'C:\Users\cardlab.JANELIA\Desktop\drosophila_escape_response_assay\pezAnalysisRepository\Pez3000_Gui_folder\Matlab_functions\IoSR-Surrey-MatlabToolbox-4bff1bb';   
    cd(directory);
    addpath(directory,[directory filesep 'deps' filesep 'SOFA_API']);
    
    SOFAstart(0);    
    cd(currdir); % return to original directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    combine_data = [];
    
    temp_range = [22.5,24.0];                   humidity_cut_off = 40;
    azi_off = 22.5;                             remove_low = false;                             low_count = 5;
    
    sample_ids = [{'0069000009710523'}; {'0069000009710525'};  {'0069000022040523'};{'0069000022040525'};...
                  {'0108000024860730'}; {'0108000024850730'};  {'0108000024870730'};...
                  {'0069000013040523'};{ '0069000013040525'};...
                  {'0069000001640523'};{'0069000001640525'};{'0069000001660523'};{'0069000001660525'}];          

    
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
    
    jump_logic = cellfun(@(x) isempty(x), all_passing_data.frame_of_leg_push);
    all_passing_data(jump_logic,:) = [];       
    
    jump_logic = cellfun(@(x) isnan(x), all_passing_data.frame_of_leg_push);
    all_passing_data(jump_logic,:) = [];       
    
    no_tracking = cellfun(@(x) isempty(x), all_passing_data.bot_points_and_thetas);
    all_passing_data(no_tracking,:) = [];
    
    
    short_tracking = cellfun(@(x,y) length(x(:,1)) < y,all_passing_data.bot_points_and_thetas,all_passing_data.frame_of_take_off);
    all_passing_data(short_tracking,:) = [];
            
    time_of_leg = cellfun(@(x,y) (x-y)/6, all_passing_data.frame_of_take_off,all_passing_data.Start_Frame);
    
    %Add time domain filter
    all_passing_data = all_passing_data(time_of_leg >= 0 & time_of_leg <= 100,:);
    
    fly_top_pos = cellfun(@(x,y,z) x(y:z,:),all_passing_data.top_points_and_thetas,all_passing_data.frame_of_leg_push,all_passing_data.frame_of_take_off,'UniformOutput',false);
    
    ele_angle = cellfun(@(x) (x(end,2) - x(1,2)) /(x(end,1) - x(1,1))  ,fly_top_pos);
    escape_ele = atan(abs(ele_angle(:,1)));         
%    escape_ele = ((pi/2) - escape_ele) ./ (pi/2);

    circ_plot(escape_ele,'pat_special',[],(360/20),true,true,'linewidth',2,'color','r');    

    fly_bot_pos = cellfun(@(x,y,z) x(y:z,:),all_passing_data.bot_points_and_thetas,all_passing_data.frame_of_leg_push,all_passing_data.frame_of_take_off,'UniformOutput',false);
    
    org_azi_pos = cellfun(@(x) 360-(x(1,3).*180/pi) ,fly_bot_pos);
    pos_change = cell2mat(cellfun(@(x) [(x(end,1) - x(1,1)) ,(x(end,2) - x(1,2))]  ,fly_bot_pos,'UniformOutput',false));
    
    rot_pos = cell2mat(arrayfun(@(x,y,z) rotation([x y],[0 0],-z,'degrees'),pos_change(:,1),pos_change(:,2),org_azi_pos,'UniformOutput',false));    
    %rot_pos = cell2mat(arrayfun(@(x,y,z) rotation([x y],[0 0],z,'radians'),pos_change(:,1),pos_change(:,2),org_azi_pos,'UniformOutput',false));    
    normalized_azi_esc = atan2(rot_pos(:,2),rot_pos(:,1));
    
%     id_list = (cellfun(@(x) x(33:40),all_passing_data.Properties.RowNames,'UniformOutput',false));
%     gf_data = {'00000164';'00000166'};                      gf_logic = ismember(id_list,gf_data);
%     gf_data = normalized_azi_esc(gf_logic);                 dn_data = normalized_azi_esc(~gf_logic);
%     [p,U2] = watsons_U2_approx_p(gf_data,dn_data);


    parent_info = vertcat(combine_data.parsed_data);
    parent_a_name = parent_info.ParentA_name;
    
    [locA,locB] = ismember(cellfun(@(x) x(29:44),all_passing_data.Properties.RowNames,'UniformOutput',false),get(parent_info,'ObsNames'));
    parent_list = parent_a_name(locB(locA));
    [~,new_labels_combine] = convert_labels(parent_list,'DN_convert',parent_info,'geno_string');
    
 %   [~,~,parent_index] = unique(new_labels_combine,'stable');
 
    group_1 = normalized_azi_esc(cellfun(@(x) strcmp(x,'P1'),new_labels_combine));
    iterations = 1500;
    pval = zeros(iterations,1);    m = zeros(iterations,1);    
    for iterZ = 1:iterations
        rand_index = randperm(length(group_1),100);
        
        try
            [pval(iterZ), m(iterZ)] = circ_otest(group_1(rand_index));
        catch
            warning('crash')
        end
    end
    
    
    group_1 = normalized_azi_esc(cellfun(@(x) strcmp(x,'P4, P2'),new_labels_combine));
    group_1 = normalized_azi_esc(cellfun(@(x) strcmp(x,'P11'),new_labels_combine));
    [pval m] = circ_otest(group_1);
    

%    [pval,med,P] = circ_cmtest(normalized_azi_esc(parent_index==6),normalized_azi_esc(parent_index==3 | parent_index==5 ));

%    [cid, alpha, mu] = circ_clust(normalized_azi_esc');
    figure; 
    boxplot(normalized_azi_esc',cid);
    
    normalized_azi_esc(normalized_azi_esc < 0) = normalized_azi_esc(normalized_azi_esc < 0) + 2*pi;
    [theta,kappa] = circ_vmpar(normalized_azi_esc);
    [p,alpha] = circ_vmpdf(normalized_azi_esc,theta,kappa);
    figure
    scatter(alpha,p);

end
function [new_labels_sep,new_labels_combine] = convert_labels(old_labels,flag,exp_info,str_type)                         %flips 8 digit number into parent information
    switch flag
        case 'DN_convert'
            not_in_sheet_id = [    {'1500090'};  {'3015823'};  {'2502522'};   {'3020007'};   {'2135398'};      {'2135419'};    {'2135420'};     {'1500437'}; {'3026909'}];
            not_in_sheet_conv = [{'DL Wildtype'};{'SS01062'};  {'LC4(0315)'}; {'LC6(77B)'};  {'LPLC1(29B)'};  {'LPLC2(47B)'}; {'LPLC2(48B)'};  {'FCF_pBDP'};{' L1, L2'}];

%                [~,~,raw] = xlsread('C:\Users\breadsp\Documents\new_martin_counts.xlsx','Hiros List');
            [~,~,raw] = xlsread('Z:\Pez3000_Gui_folder\DN_name_conversion.xlsx','Hiros List');
            header_list = raw(1,1:end);
            header_list = regexprep(header_list,' ','_');
            dn_table = cell2table(raw(2:end,1:end));
            dn_table.Properties.VariableNames = header_list;

            switch str_type
                case 'geno_string'
                    [locA,locB] = ismember(old_labels,exp_info.ParentA_name);  %if sends name string
                case 'exp_str_8'
                    [locA,locB] = ismember(old_labels,cellfun(@(x) x(5:12),get(exp_info,'ObsNames'),'uniformoutput',false));   %if sends 8 digit geno string
                case 'exp_str_4'
                    [locA,locB] = ismember(old_labels,cellfun(@(x) x(5:12),get(exp_info,'ObsNames'),'uniformoutput',false));   %if sends 4 digit geno string

            end     
            old_id_list = exp_info(locB(locA),:).ParentA_ID;                
            old_id_name = exp_info(locB(locA),:).ParentA_name;                                        
            new_labels = old_id_name;
            new_labels_sep = old_id_name;
            new_labels_combine = old_id_name;

            [match_logic_sheet,match_pos_sheet] = ismember(str2double(old_id_list),dn_table.robot_ID);          %find records matching hiros table
            [match_logic_table,match_pos_table] = ismember(old_id_list,not_in_sheet_id);            %find records matching manual table                

%                new_labels(match_logic_sheet) = dn_table.old_name(match_pos_sheet(match_logic_sheet));
            new_labels_sep(match_logic_sheet) = dn_table.import_name(match_pos_sheet(match_logic_sheet));
            new_labels_combine(match_logic_sheet) = dn_table.new_name(match_pos_sheet(match_logic_sheet));                

            new_labels_sep(match_logic_table) = not_in_sheet_conv(match_pos_table(match_logic_table));
            new_labels_combine(match_logic_table) = not_in_sheet_conv(match_pos_table(match_logic_table));

%                [~,new_labels]  = make_sort_order(new_labels);                
    end
end    

