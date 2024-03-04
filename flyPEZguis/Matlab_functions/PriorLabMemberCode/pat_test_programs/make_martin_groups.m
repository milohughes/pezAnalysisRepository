function make_martin_groups
    [~,~,martin_file] = xlsread('Z:\Martin\flypez_analysis\thesis_analysis\experimental_group_tables\peekm_mega_combo.xlsx',1);
    header_list = martin_file(1,2:end);
    row_list = martin_file(:,1);
    row_list = cellfun(@(x) regexprep(x,'ID#',''),row_list,'UniformOutput',false);

    martin_file =  cell2table(martin_file(2:end,2:end));
    martin_file.Properties.RowNames = row_list(2:end);
    martin_file.Properties.VariableNames = header_list;

    lc4dn_cschr_group = martin_file(cellfun(@(x) ~contains(x,'omit'),martin_file.lc4dn_cschr),:).Properties.RowNames;
    lc4dn_kir_group = martin_file(cellfun(@(x) ~contains(x,'omit'),martin_file.lc4dn_kir),:).Properties.RowNames;
    lplc_cschr_group = martin_file(cellfun(@(x) ~contains(x,'omit'),martin_file.lplc_cschr),:).Properties.RowNames;
    lplc_kir_group = martin_file(cellfun(@(x) ~contains(x,'omit'),martin_file.lplc_kir),:).Properties.RowNames;
    dn_58_azi_sweep_group = martin_file(cellfun(@(x) ~contains(x,'omit'),martin_file.dn_58_azi_sweep),:).Properties.RowNames;
    triple_line_LC4_LPLC2_GF = martin_file(cellfun(@(x) ~contains(x,'omit'),martin_file.triple_line_LC4_LPLC2_GF),:).Properties.RowNames;
    P2_P4_P6 = martin_file(cellfun(@(x) ~contains(x,'omit'),martin_file.P2_P4_P6),:).Properties.RowNames;
    single_LC4DNs = martin_file(cellfun(@(x) ~contains(x,'omit'),martin_file.single_LC4DNs),:).Properties.RowNames;
    DL_lv40 = martin_file(cellfun(@(x) ~contains(x,'omit'),martin_file.DL_lv40),:).Properties.RowNames;

    
    group_ids = load('Z:\Pez3000_Gui_folder\Gui_saved_variables\Saved_Group_IDs_table.mat');    
    group_ids = group_ids.Saved_Group_IDs;
    
    [entries,group_ids] = save_group_ids(lc4dn_cschr_group,{'lc4dn_cschr'},{'Peekm'},group_ids);   group_ids = [group_ids;entries];  
    [entries,group_ids] = save_group_ids(lc4dn_kir_group,{'lc4dn_kir'},{'Peekm'},group_ids);       group_ids = [group_ids;entries];
    [entries,group_ids] = save_group_ids(lplc_cschr_group,{'lplc_cschr'},{'Peekm'},group_ids);     group_ids = [group_ids;entries];
    [entries,group_ids] = save_group_ids(lplc_kir_group,{'lplc_kir'},{'Peekm'},group_ids);         group_ids = [group_ids;entries];
    [entries,group_ids] = save_group_ids(dn_58_azi_sweep_group,{'dn_58_azi_sweep'},{'Peekm'},group_ids);         group_ids = [group_ids;entries];
    [entries,group_ids] = save_group_ids(triple_line_LC4_LPLC2_GF,{'triple_line_LC4_LPLC2_GF'},{'Peekm'},group_ids);         group_ids = [group_ids;entries];
    [entries,group_ids] = save_group_ids(P2_P4_P6,{'P2_P4_P6'},{'Peekm'},group_ids);         group_ids = [group_ids;entries];
    [entries,group_ids] = save_group_ids(single_LC4DNs,{'single_LC4DNs'},{'Peekm'},group_ids);         group_ids = [group_ids;entries];
    [entries,group_ids] = save_group_ids(DL_lv40,{'DL_lv40'},{'Peekm'},group_ids);         group_ids = [group_ids;entries];

    
    Saved_Group_IDs = group_ids;
    save('Z:\Pez3000_Gui_folder\Gui_saved_variables\Saved_Group_IDs_table.mat','Saved_Group_IDs');
end
function [entries,group_ids] = save_group_ids(group_res,group_name,user_name,group_ids)
    group_ids(ismember(group_ids.Properties.RowNames,group_name),:) = [];    
    group_exp_id = cellfun(@(x,y) ['       ' ,num2str(x)],group_res,'uniformoutput',false);

    col_list = [{'User_ID'},{'Experiment_IDs'},{'Status'}];
    entry = cell(1,3);                       
    entry(1,1) = user_name;                entry(1,2) = {group_exp_id};                  entry(1,3) = {'Active'};
    entries = cell2table(entry);           entries.Properties.RowNames = group_name;     entries.Properties.VariableNames = col_list;
end