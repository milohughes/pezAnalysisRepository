exp_dir = struct2dataset(dir('Z:\Data_pez3000_analyzed'));
exp_dir = exp_dir(cellfun(@(x) length(x) == 16,exp_dir.name),:).name;

%exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) == 92,exp_dir));
exp_dir = exp_dir(cellfun(@(x) str2double(x) == 44000004300572,exp_dir));

for iterZ = 1:length(exp_dir)
    
    raw_data = load(['Z:\Data_pez3000_analyzed' filesep exp_dir{iterZ} filesep exp_dir{iterZ} '_rawDataAssessment.mat']);
    raw_data = raw_data.assessTable;
    
    graph_data = load(['Z:\Data_pez3000_analyzed' filesep exp_dir{iterZ} filesep exp_dir{iterZ} '_dataForVisualization.mat']);
    graph_data = graph_data.graphTable;    
   
    logic_1 = cellfun(@(x) ~isempty(strfind(x,'Single')),raw_data.Fly_Count);
    logic_2 = cellfun(@(x) ~isempty(strfind(x,'None')),raw_data.Balancer);
    logic_3 = cellfun(@(x) ~isempty(strfind(x,'Good')),raw_data.Physical_Condition);
    logic_4 = cellfun(@(x) ~isempty(strfind(x,'Good')),raw_data.NIDAQ);
    
    pass_logic = logic_1 & logic_2 & logic_3 & logic_4;
    raw_data(pass_logic,:).Raw_Data_Decision = repmat({'Pass'},sum(pass_logic),1);  
    graph_data(pass_logic,:).finalStatus = repmat({'Tracking requested'},sum(pass_logic),1);  
    
    logic_5 =  cellfun(@(x) isempty(x),raw_data.Analysis_Status);
    raw_data(pass_logic & logic_5,:).Analysis_Status = repmat({'Tracking requested'},sum(pass_logic & logic_5),1);
   
    assessTable = raw_data;
    save(['Z:\Data_pez3000_analyzed' filesep exp_dir{iterZ} filesep exp_dir{iterZ} '_rawDataAssessment.mat'],'assessTable');    
    graphTable = graph_data;
    save(['Z:\Data_pez3000_analyzed' filesep exp_dir{iterZ} filesep exp_dir{iterZ} '_dataForVisualization.mat'],'graphTable');    
    disp(iterZ)
end