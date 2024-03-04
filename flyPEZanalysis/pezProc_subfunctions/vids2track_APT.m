function vids2track_APT

[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');

expIDdir = fullfile(fileDir,'Data_pez3000_analyzed');

% expIDlist = {expIDdir(4:end-13).name};
% expIDlist = {'0242000004301578'};
% expIDlist = {'0260000004301598';'0260000026731598';'0260000026721598';'0260000004301611'};
% expIDlist = {'0262000004301602';'0262000004301604';'0262000004301605';...
%     '0262000004301606';'0270000025791602';'0270000025791604';'0270000025791606';...
%     '0270000026011602';'0270000026011604';'0270000026011605';'0270000026011606';...
%     '0270000026031602';'0270000026031604';'0270000026031606';'0270000026041602';...
%     '0270000026041604';'0270000026041605';'0270000026041606';'0270000027001604';...
%     '0270000027001606';'0270000027021602'};
expIDlist = {'0283000004301629'};

%disp('Select a subset of expIDs to only update their tracking info.  Press "Continue" to track all or "Quit Debugging" to abort APT updates')
%keyboard
%%
for i = 1:length(expIDlist)
    exptID = expIDlist{i};
    %%
    disp(exptID)
    
    try
    trkdir = fullfile('/groups/card/cardlab/Data_pez3000_analyzed/',exptID,'APT_Results/'); %directory where trk files should go
    trkdir = replace(trkdir,'\','/');
    if ~exist(fullfile(expIDdir,exptID,'APT_Results'),'dir')
        mkdir(fullfile(expIDdir,exptID,'APT_Results'))
    end
    
    try
        load(fullfile(fileDir,'Pez3000_Gui_folder\Gui_saved_variables\APT2Track.mat'))
    catch
        movies2track = table;
    end
    
    load(fullfile(expIDdir,exptID,[exptID '_rawDataAssessment']))
    assessTable.APT_Tracking(~strcmp(assessTable.Analysis_Status,'Analysis complete'))=0;
    
    load(fullfile(expIDdir,exptID,[exptID '_dataForVisualization']))
    
    load(fullfile(expIDdir,exptID,[exptID '_videoStatisticsMerged'])) %#ok<*LOAD>
    vidstats = dataset2table(videoStatisticsMerged);
    
     ind = find(assessTable.APT_Tracking==1|assessTable.APT_Tracking==0);
   % ind = find(assessTable.APT_Tracking==1);
    for j = 1:length(ind) %if there is already APT tracking, change flag to 0
        assessTable.APT_Tracking(ind(j)) = 1;
        filenme = fullfile(expIDdir,exptID,'APT_Results', [assessTable.Properties.RowNames{ind(j)} '.trk']);
        if exist(filenme,'file')
            fileinfo = dir(filenme);
            if (assessTable.APT_RetrackFlag(ind(j))==0)
                assessTable.APT_Tracking(ind(j)) = 0;
            elseif fileinfo.date>datetime(assessTable.APT_RetrackFlag(ind(j)),'ConvertFrom','datenum')%if trk file is newer than date retrack flag was submitted, remove movie and set retrack to 0
                assessTable.APT_Tracking(ind(j)) = 0;
                assessTable.APT_RetrackFlag(ind(j)) = 0;     
            end
        end
    end
    
   % assessTable.APT_RetrackFlag(:) = now; %uncomment to add retrack flag to all tracked movies
    
    assessTable.APT_Tracking(assessTable.APT_RetrackFlag>0) = 1; %if retrack flag is set, set tracking flag
    save(fullfile(expIDdir,exptID,[exptID '_rawDataAssessment']),'assessTable')
    
    %Combine all assessment tables
    fullset = innerjoin(graphTable,assessTable,'Keys','Row'); %all videos from graph table for experiment list
    fullset.VideoName = fullset.Properties.RowNames;
    vidstats.VideoName = vidstats.Properties.RowNames;
    fullset = innerjoin(fullset,vidstats,'Keys','VideoName');
    fullset.Video_Path = replace(fullset.Video_Path,'\\tier2\card','\\dm11\cardlab');
    fullset.Video_Path = replace(fullset.Video_Path,'\','/');
    fullset.Video_Path = replace(fullset.Video_Path,'/dm11','groups/card');
    
    %Correction for some files that do not contain the video path
    vidind=find(~contains(fullset.Video_Path,'run'));
    if vidind>0
        fullset.Video_Path=fullset.VideoName;
        for  j=1:length(vidind)
            fullset.Video_Path{j} = fullfile('/groups/card/cardlab/Data_pez3000', fullset.VideoName{j}(16:23), fullset.VideoName{j}(1:23),[fullset.VideoName{j} '.mp4']);
            fullset.Video_Path = replace(fullset.Video_Path,'\','/');
        end
    end
    
    fullset(fullset.APT_Tracking==0,:)=[]; %remove all videos without APT Tracking flag
    movies2track_add = table;
    
    if height(fullset)>0
        %Set ROI for full list
        ROI = cell(height(fullset),1);
        frmct = zeros(height(fullset),1);
        for j = 1:height(fullset)
            adjusted_ROI = fullset.Adjusted_ROI{j,1};
            xlo = round(((adjusted_ROI(2,1)+adjusted_ROI(4,1))/2)-137.5);
            yhi = adjusted_ROI(2,2);
            xhi = xlo+275;
            ylo = yhi-275;
            ROI{j,1} = [xlo xhi ylo yhi];
            if fullset.record_rate==6000
                frmct(j) = floor(fullset.frame_count(j)/10);
            else
                frmct(j) = fullset.frame_count(j);
            end
        end
        
        movielist = fullset.Video_Path;
        
        trkfilename = fullset.VideoName;
        trkfile = cell(height(fullset),1);
        for j = 1:height(fullset)
            trkfile{j,1} = [trkdir trkfilename{j,1},'.trk'];
        end
        
        movies2track_add.movielist = movielist;
        movies2track_add.cropRois = ROI;
        movies2track_add.trk = trkfile;
        movies2track_add.f0 = ones(height(fullset),1);
        movies2track_add.f1 = frmct;
    end
    
    try %#ok<TRYNC>
        movies2track(contains(movies2track.movielist,exptID),:) = []; % removes all movies from experiment ID so that only ones with tracking flag are readded
    end
    
    movies2track = [movies2track; movies2track_add]; %#ok<AGROW>
    % [~,ia,~] = unique(movies2track.movielist);
    % movies2track = movies2track(ia,:); %only include videos not already on list
    
    save(fullfile(fileDir,'Pez3000_Gui_folder\Gui_saved_variables\APT2Track.mat'),'movies2track');
    
    catch
        disp('Could not add experiment ID to APT list')
    end
    
end

%% adds a check to remove videos that don't exist
movielist = replace(movies2track.movielist,'/groups/card/cardlab','Z:');
movielist = replace(movielist,'/','\');
ind = [];
for i = 1:length(movielist)
    if ~isfile(movielist{i})
        ind = [ind;i]; %#ok<AGROW>
    end
end

movies2track(ind,:)=[]; %#ok<NASGU>
save(fullfile(fileDir,'Pez3000_Gui_folder\Gui_saved_variables\APT2Track.mat'),'movies2track');
