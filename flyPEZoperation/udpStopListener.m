function udpStopListener
%%%%% computer and directory variables and information
variablesDir = [filesep filesep 'dm11' filesep 'cardlab' filesep 'pez3000_variables'];
[~, comp_name] = system('hostname');
comp_name = comp_name(1:end-1); %Remove trailing character.
compDataPath = fullfile(variablesDir,'computer_info.xlsx');
compData = dataset('XLSFile',compDataPath);
compRef = find(strcmp(compData.stimulus_computer_name,comp_name));
if isempty(compRef)
    disp('computer not valid')
    return
end
host = compData.stimulus_computer_IP{compRef};
port = 21566;
judp('send',port,host,int8(99))
disp('timer function interrupted')

