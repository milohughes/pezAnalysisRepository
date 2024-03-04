fname = 'Y:\Data_pez3000\20140502\run043_pez3001_20140502\run043_pez3001_20140502_runStatistics.mat'
[x,y,z] = fileparts(fname)
ys = strsplit(y,'_')
autoname = [ys{1} '_' ys{2} '_' ys{3} '_autoAnalysisResults.mat'];
autopath = fullfile(x,'inspectionResults',autoname)
load(autopath)
load(fname)
exptid = '0019000004940101';
runStats(1).time_start = '02-May-2014 14:11:11';
runStats.experimentID = exptid;
runStats.empty_count = sum((autoResults.empty_count));
runStats.single_count = sum((autoResults.single_count));
runStats.multi_count = sum((autoResults.multi_count));
runStats.diode_failures = sum(~strcmp(autoResults.diode_decision{1},'good photodiode'));
runStats.manager_notes = [];
% runStats.time_stop = [];
runStats.tunnel_fly_count = 0;
runStats.prism_fly_count = 0

%%
save(fname,'runStats')