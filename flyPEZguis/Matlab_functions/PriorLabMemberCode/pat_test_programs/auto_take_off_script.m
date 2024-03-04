[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
subfun_dir = fullfile(repositoryDir,'pezProc_subfunctions');
saved_var_dir = fullfile(repositoryDir,'pezProc_saved_variables');
assessment_dir = fullfile(repositoryDir,'file_assessment_and_manipulation');
addpath(repositoryDir,subfun_dir,saved_var_dir,assessment_dir)
addpath(repositoryDir,subfun_dir,saved_var_dir,assessment_dir)
addpath(fullfile(repositoryDir,'Pez3000_Gui_folder','Matlab_functions','Support_Programs'))
addpath(fullfile(repositoryDir,'graphing_and_visualization'))

minimum_collectionID = '0142';

disp('Takeoff analysis')
takeoffAnalysis3000_v2(1,[],minimum_collectionID)