function posTestVec = findEdgeGaps_tracking(videoID)
%%
if isempty(mfilename) || nargin == 0
    videoID = 'run007_pez3003_20140429_expt0019000000410102_vid0003';
end
tracker_name = 'flyTracker3000_v17';
locator_name = 'flyLocator3000_v10';

strParts = strsplit(videoID,'_');
runID = [strParts{1} '_' strParts{2} '_' strParts{3}];
exptID = strParts{4}(5:end);

%%%% Establish data destination directory
%analysisDir = fullfile('\\tier2','card','Data_pez3000_analyzed');
analysisDir = fullfile('\\DM11','cardlab','Data_pez3000_analyzed');


expt_results_dir = fullfile(analysisDir,exptID);
tracker_expt_ID = [videoID '_' tracker_name '_data.mat'];%experiment ID
tracker_data_dir = fullfile(expt_results_dir,[exptID '_' tracker_name]);
tracker_data_path = fullfile(tracker_data_dir,tracker_expt_ID);
tracker_data_import = load(tracker_data_path);
dataname = fieldnames(tracker_data_import);
tracker_record = tracker_data_import.(dataname{1});

%%%%% Load locator data
locDir = fullfile(expt_results_dir,[exptID '_' locator_name]);
locator_data_path = fullfile(locDir,[videoID '_' locator_name '_data.mat']);
locator_record = load(locator_data_path);
dataname = fieldnames(locator_record);
locator_record = locator_record.(dataname{1});

%%%%% Load assessment table
assessmentPath = fullfile(expt_results_dir,[exptID '_rawDataAssessment.mat']);
assessTable_import = load(assessmentPath);
dataname = fieldnames(assessTable_import);
assessTable = assessTable_import.(dataname{1});

%%%%% Read video file
vidPath = locator_record.orig_video_path{1};
%vidPath = regexprep(vidPath,'arch','tier2');

slashPos = strfind(vidPath,'\');
pathlistKeep = [filesep filesep 'DM11' filesep 'cardlab' filesep vidPath(slashPos(4):slashPos(end)-1)];
%pathlistKeep = vidPath(1:slashPos(end)-1);
%
vidstatname = [runID '_videoStatistics.mat'];
pathlistKeep = regexprep(pathlistKeep,'arch','tier2');
vidstatPath = fullfile(pathlistKeep,vidstatname);
vidStatsLoad = load(vidstatPath);
vidStats = vidStatsLoad.vidStats;
vidWidth = double(vidStats.frame_width(videoID));
vidHeight = double(vidStats.frame_height(videoID));

roiPos = assessTable.Adjusted_ROI{videoID};
roiPos = [roiPos(2:3,1) roiPos(1:2,2)-(vidHeight-vidWidth+1)];
roiSwell = -15;%%% contracts the roi to the original position
roiPos = roiPos+[-roiSwell -roiSwell
    roiSwell roiSwell];
roiPos(roiPos < 1) = 1;
roiPos(roiPos > vidWidth) = vidWidth;

%%%%% Define tracking variables
trk_hort_ref = locator_record.tracking_hort{:};
fly_length = locator_record.fly_length{:};

%TEMPL_*** is identical, centered replicates!!! (taken from older, centered frame)
%SAMPL_*** contains posible new positions and has unknown center!!! (taken from new frame)
src_fac = 0.3;
src_leg = round(fly_length*(src_fac));
[ndxr_struct] = trackingIndexer_spoked4crop(src_leg,trk_hort_ref);
im_leg = ndxr_struct.im_leg;

botLabels = tracker_record.bot_centroid{videoID}(:,1:2);

posTest = [(botLabels(:,1)-im_leg) < roiPos(1),...
    (botLabels(:,2)-im_leg) < roiPos(3),...
    (botLabels(:,1)+im_leg) > roiPos(2),...
    (botLabels(:,2)+im_leg) > roiPos(4)];

posTestVec = max(posTest,[],2);
% sum(posTestVec)
% posTestVec = posTestVec & tracker_record.mvmnt_ref{videoID} ~= 0;
% sum(posTestVec)



