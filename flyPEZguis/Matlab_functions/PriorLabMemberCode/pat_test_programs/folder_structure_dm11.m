function folder_table = folder_structure_dm11
%    network_path = '\\dm11\cardlab\Jan';
%    network_path = '\\dm11\cardlab';
%    network_path = '\\dm11\cardlab\\Data_pez3000_analyzed';
    network_path = '\\dm11\cardlab\\Data_pez3000';
    folder_list = struct2dataset(dir(network_path));
    folder_list = sort_folders(folder_list);

    is_file_logic = ~folder_list.isdir;
    file_dataset = folder_list(is_file_logic,:);        %first pass
    folder_list = folder_list(folder_list.isdir,:);

%    remove_pez_data = cellfun(@(x) contains(x,'Data_pez3000'),folder_list.name);
%    folder_list(remove_pez_data,:) = [];

%    folder_list = folder_list(cellfun(@(x) str2double(x) < 20190401 & str2double(x) >= 20190901,folder_list.name),:);
%    folder_list = folder_list(cellfun(@(x) str2double(x) < 20191001 & str2double(x) >= 20190901,folder_list.name),:);
    folder_list = folder_list(cellfun(@(x) str2double(x) >= 20191001 ,folder_list.name),:);
%    folder_list = folder_list(cellfun(@(x) str2double(x(1:4)) >= 161 & str2double(x(1:4)) <= 220,folder_list.name),:);
    
    master_folder_count = size(folder_list,1);

    file_dataset = get_subfolder_info(folder_list,file_dataset,1,master_folder_count);
    folder_cell_logic = cellfun(@(x) iscell(x),file_dataset.folder);
    string_folders = cellfun(@(x) x{1}, file_dataset(folder_cell_logic,:).folder,'UniformOutput',false);
    file_dataset(folder_cell_logic,:).folder = string_folders;
    
    
    main_folder_info = file_dataset(cellfun(@(x) length(strfind(x,'\')) <= 4,file_dataset.folder),:);
    sub_folder_info = file_dataset(cellfun(@(x) length(strfind(x,'\')) > 5,file_dataset.folder),:);
    folder_index = cellfun(@(x) strfind(x,'\'),sub_folder_info.folder,'UniformOutput',false);
    sub_folder_info.folder = cellfun(@(x,y) x(1:(y(6)-1)),sub_folder_info.folder,folder_index,'UniformOutput',false);
    
    all_folders = [main_folder_info; sub_folder_info];
    
    folder_cell_logic = cellfun(@(x) iscell(x),all_folders.folder);
    string_folders = cellfun(@(x) x{1}, all_folders(folder_cell_logic,:).folder);
    all_folders(folder_cell_logic,:).folder = string_folders;
    
    folder_table = tabulate(all_folders.folder);
    for iterZ = 1:length(folder_table)
         folder_table(iterZ,3) = {sum(all_folders(ismember(all_folders.folder,folder_table(iterZ,1)),:).bytes)};
    end
end
function folder_list = sort_folders(folder_list)
    try         %many entries are a cell
        folder_list(cellfun(@(x) strcmp(x,'.') | strcmp(x,'..'),folder_list.name),:) = [];
    catch       %single entry is a string
        folder_list(strcmp(folder_list.name,'.'),:) = [];
        folder_list(strcmp(folder_list.name,'..'),:) = [];
    end
    if ~isempty(folder_list)  
%        remove_pez_data = cellfun(@(x) contains(x,'Data_pez3000'),folder_list.name);
%        folder_list(remove_pez_data,:) = [];

        
        [~,sort_idx] = sort(lower(folder_list.name));
        folder_list = folder_list(sort_idx,:);

%         try
%             folder_list(cellfun(@(x) contains(x,'Data_pez3000'),folder_list.name),:) = [];      %remove video and analysis files for speed                
%         catch
%             folder_list(contains(folder_list.name,'Data_pez3000'),:) = [];      %remove video and analysis files for speed        
%         end
    end
end


function [file_dataset,prev_folder] = get_subfolder_info(subfolder_list,file_dataset,folder_index,master_folder_count)
    prev_folder = unique(subfolder_list.folder);
    if iscell(prev_folder)
        prev_folder =  prev_folder{1};
    end
    total_folders = length(subfolder_list);
    for iterZ = 1:total_folders
        if isempty(subfolder_list)      %if no files do nothing
        else                            %find files inside folder
            try
                subfolder_list = struct2dataset(dir(fullfile(prev_folder,subfolder_list(iterZ,:).name{1})));
            catch
                warning('erorr')
            end
            subfolder_list = sort_folders(subfolder_list);
            if isempty(subfolder_list)                  %folder is empty
                folder_name = fullfile(prev_folder,'empty');
            else
                folder_name = subfolder_list.folder{1};
            end
            fprintf('Analyizing folder: %s\n', folder_name);
        end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% find the files and add to list, then remove for looping
        is_file_logic = ~subfolder_list.isdir;
        if sum(is_file_logic) == 0
        elseif sum(is_file_logic) == 1
            data_to_add = subfolder_list(is_file_logic,:);
            data_to_add.name = {data_to_add.name};
            data_to_add.folder = {data_to_add.folder};
            data_to_add.date = {data_to_add.date};
            file_dataset = [file_dataset;data_to_add];                         %#ok<AGROW>
        else
            try
                file_dataset = [file_dataset;subfolder_list(is_file_logic,:)]; %#ok<AGROW>
            catch
                warning('diff type');
            end
        end
        subfolder_list = subfolder_list(subfolder_list.isdir,:);
        
        if size(subfolder_list,1) > 1 
            [file_dataset,prev_folder]  = get_subfolder_info(subfolder_list,file_dataset,folder_index,master_folder_count);      %recersive calling inside the folder
            prev_folder = fileparts(prev_folder);
            subfolder_list = struct2dataset(dir(prev_folder));
            subfolder_list = sort_folders(subfolder_list);
            subfolder_list = subfolder_list(subfolder_list.isdir,:);
            if strcmp(prev_folder,'\\dm11\cardlab\Data_pez3000')
%                subfolder_list = subfolder_list(cellfun(@(x) str2double(x) < 20190401 & str2double(x) >= 20190301,subfolder_list.name),:);
%                subfolder_list = subfolder_list(cellfun(@(x) str2double(x) < 20191001 & str2double(x) >= 20190901,subfolder_list.name),:);
                subfolder_list = subfolder_list(cellfun(@(x) str2double(x) >= 20191001,subfolder_list.name),:);
            elseif strcmp(prev_folder,'\\dm11\cardlab\Data_pez3000_analyzed')                
                subfolder_list = subfolder_list(cellfun(@(x) str2double(x(1:4)) >= 161 & str2double(x(1:4)) <= 220,subfolder_list.name),:);
            end
        else
%            prev_folder = fileparts(prev_folder);
            subfolder_list = struct2dataset(dir(prev_folder));
            subfolder_list = sort_folders(subfolder_list);
            subfolder_list = subfolder_list(subfolder_list.isdir,:);
        end
    end
end