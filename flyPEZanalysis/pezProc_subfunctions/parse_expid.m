function expt_id_info = parse_expid(experiment_id)
expt_id_info = 'error';
if nargin == 0
    experiment_id = '0001000000520009';
end
if numel(experiment_id) ~= 16
    return
end
op_sys = system_dependent('getos');
if strcmp(op_sys,'Microsoft Windows 7')
    file_dir = '\\DM11\cardlab\Pez3000_Gui_folder\Gui_saved_variables';
else
    file_dir = '/Volumes/cardlab/Pez3000_Gui_folder/Gui_saved_variables';
end  

Collection = load([file_dir filesep 'Saved_Collection.mat']);
Genotypes  = load([file_dir filesep 'Saved_Genotypes.mat']);
Protocols  = load([file_dir filesep 'Saved_Protocols.mat']);

Exp_protocol       = load([file_dir filesep 'Saved_Exp_protocols.mat']);
Handling_protocols = load([file_dir filesep 'Saved_Handling_protocols.mat']);
Rearing_protocols  = load([file_dir filesep 'Saved_Rearing_protocols.mat']);

collectionNames = get(Collection.Saved_Collection,'ObsName');
collectionRef = strcmp(collectionNames,experiment_id(1:4));
genotypeNames = get(Genotypes.Saved_Genotypes ,'ObsName');
genotypeRef = strcmp(genotypeNames,experiment_id(5:12));
protocolNames = get(Protocols.Saved_Protocols ,'ObsName');
protocolRef = strcmp(protocolNames,experiment_id(13:16));
testA = max(collectionRef) == 0;
testB = max(genotypeRef) == 0;
testC = max(protocolRef) == 0;
if testA || testB || testC
    return
end

parsed_collection = Collection.Saved_Collection(collectionRef,:);
parsed_genotype   = Genotypes.Saved_Genotypes(genotypeRef,:);
parsed_protocol   = Protocols.Saved_Protocols(protocolRef,:);

parsed_expment = Exp_protocol.Exp_protocol(strcmp(get(Exp_protocol.Exp_protocol ,'ObsName'),parsed_protocol.Exp_protocol),:);
parsed_handl   = Handling_protocols.Handling_protocols(strcmp(get(Handling_protocols.Handling_protocols ,'ObsName'),parsed_protocol.Handling_protocol),:);
parsed_rearing = Rearing_protocols.Rearing_protocols(strcmp(get(Rearing_protocols.Rearing_protocols ,'ObsName'),parsed_protocol.Rearing_protocol),:);

parsed_collection = set(parsed_collection,'ObsName',experiment_id);
parsed_genotype = set(parsed_genotype,'ObsName',experiment_id);
parsed_protocol = set(parsed_protocol,'ObsName',experiment_id);
parsed_expment = set(parsed_expment,'ObsName',experiment_id);
parsed_handl = set(parsed_handl,'ObsName',experiment_id);
parsed_rearing = set(parsed_rearing,'ObsName',experiment_id);

expt_id_info = [parsed_collection parsed_genotype parsed_protocol parsed_expment parsed_handl parsed_rearing];
end
