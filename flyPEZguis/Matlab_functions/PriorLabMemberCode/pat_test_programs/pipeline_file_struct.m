function pipeline_file_struct
    all_files = [];
    master_folder = 'Z:\';
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dir_files = struct2dataset(dir(master_folder));   
    dir_files = trim_dir(dir_files);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for iterZ = 1:10
        tic
        normal_files = dir_files(~dir_files.isdir,:);
        all_files = get_normal_files(normal_files,all_files);    
        dir_files = dir_files(dir_files.isdir,:);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
        dir_files = trim_dir(dir_files);
        
        folder_names = cellfun(@(x,y) [x filesep y],dir_files.folder,dir_files.name,'UniformOutput',false);
        test_files = [];
        parfor iterF = 1:length(folder_names)
            test_files = [test_files;{struct2dataset(dir(folder_names{iterF}))}];
        end
        dir_files = test_files;
        
        dir_files(cellfun(@(x) isempty(x),dir_files),:) = [];
        dir_files(cellfun(@(x) size(x,1) <= 2,dir_files),:) = [];
        
        dir_files = vertcat(dir_files{:});
        fprintf('Finished Iteration :: %4.0f, taking %04.4f seconds\n',iterZ,toc);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
function file_struct = trim_dir(file_struct)
    file_struct(cellfun(@(x) strcmp(x,'..'),file_struct.name),:) = []; 
    file_struct(cellfun(@(x) strcmp(x,'.'),file_struct.name),:) = [];
end
function all_files = get_normal_files(file_struct,all_files)
    file_info = [file_struct.folder,file_struct.name,num2cell(file_struct.bytes)];
    all_files = [all_files;file_info];
end
