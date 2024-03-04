valid_id_list = struct2dataset(dir('Z:\Data_pez3000_analyzed'));
valid_id_list = valid_id_list(cellfun(@(x) length(x) == 16,valid_id_list.name),:).name;
valid_id_list = valid_id_list(cellfun(@(x) ~isnan(str2double(x)),valid_id_list));

collect_indx = [];
collect_ids = (cellfun(@(x) x(1:4),valid_id_list,'UniformOutput',false));
uni_collect = unique(collect_ids);

[collect_list,collect_indx,~] = listdlg_ver_pat('PromptString','Select a collection ID:','SelectionMode','single',...
                           'ListString',uni_collect,'position',[888 233 191 420]);


if ~isempty(collect_indx)                     
    matching_valid_list = valid_id_list(ismember(collect_ids,uni_collect(collect_indx)));
    geno_ids = (cellfun(@(x) x(5:12),matching_valid_list,'UniformOutput',false));
    uni_geno = unique(geno_ids);
else
    uni_geno = ' ';
end

[~,geno_indx,~] = listdlg_ver_pat('PromptString','Select a Genotype ID:','SelectionMode','single',...
                           'ListString',uni_geno,'position',[1088 233 191 420]);

uicontrol(collect_list);                       