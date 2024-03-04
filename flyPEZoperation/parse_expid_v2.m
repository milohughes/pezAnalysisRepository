function expt_id_info = parse_expid_v2(experiment_id)
    expt_id_info = 'error';
    if nargin == 0
        experiment_id = '0001000000520009';
    end
    if numel(experiment_id) ~= 16
        return
    end

%%%%% computer and directory variables and information
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');
file_dir = fullfile(fileDir,'Pez3000_Gui_folder','Gui_saved_variables');


    Collection = load([file_dir filesep 'Saved_Collection.mat']);
    Genotypes  = load([file_dir filesep 'Saved_Genotypes.mat']);
    Protocols  = load([file_dir filesep 'Saved_Protocols_new_version.mat']);

    collectionNames = get(Collection.Saved_Collection,'ObsName');
    collectionRef = strcmp(collectionNames,experiment_id(1:4));
    genotypeNames = get(Genotypes.Saved_Genotypes ,'ObsName');
    genotypeRef = strcmp(genotypeNames,experiment_id(5:12));
    protocolNames = get(Protocols.Saved_Protocols_new_version ,'ObsName');
    protocolRef = strcmp(protocolNames,experiment_id(13:16));
    testA = max(collectionRef) == 0;
    testB = max(genotypeRef) == 0;
    testC = max(protocolRef) == 0;
    if testA || testB || testC
        return
    end

    parsed_collection = Collection.Saved_Collection(collectionRef,:);
    parsed_genotype   = Genotypes.Saved_Genotypes(genotypeRef,:);
    parsed_protocol   = Protocols.Saved_Protocols_new_version(protocolRef,:);

    parsed_collection = set(parsed_collection,'ObsName',experiment_id);
    parsed_genotype = set(parsed_genotype,'ObsName',experiment_id);
    parsed_protocol = set(parsed_protocol,'ObsName',experiment_id);

    expt_id_info = [parsed_collection parsed_genotype parsed_protocol];
end
