function [APTproc,fullset] = APT_points(collections,stimfilt)
%% Load in Data Necessary for Evaluation


% expIDdir = dir('Z:/Data_pez3000_analyzed/');
expIDdir = dir('Z:\hhmiData\dm11\cardlab\Data_pez3000_analyzed\');

%Z:\Data_pez3000_analyzed in windows
for i = 1:size(collections,1) %gathers experiment ID list for all collections listed
    if exist('expIDlist','var')
        expIDlist = horzcat(expIDlist,{expIDdir(contains({expIDdir.name}, collections(i,:))).name});
    else
        expIDlist = {expIDdir(contains({expIDdir.name}, collections(i,:))).name};
    end
end

% Combine assessment tables for all experiment IDs
fullassessTable = [];  fullgraphTable = [];  vidstats = [];
stimazi = NaN(length(expIDlist),1); stimele = NaN(length(expIDlist),1); stimtype = cell(length(expIDlist),1);

limitops = [5 10 15 20 30 40 80 160 ; 200 250 300 350 450 600 1900 2000]; % first row is l/v, second is corresponding xlimits
xlimit = nan(length(expIDlist),1);

mssing = [];

for i = 1:length(expIDlist)
    
    if exist(fullfile('Z:/hhmiData/dm11/cardlab/Data_pez3000_analyzed/',expIDlist{:,i},[expIDlist{:,i} '_dataForVisualization.mat']),'file')
        load(fullfile('Z:/hhmiData/dm11/cardlab/Data_pez3000_analyzed/',expIDlist{:,i},[expIDlist{:,i} '_dataForVisualization']))
        
        graphTable.APTflag = zeros(height(graphTable),1);
        graphTable.VideoName = graphTable.Properties.RowNames;
        for j = 1:height(graphTable)
            if exist(fullfile('Z:/hhmiData/dm11/cardlab/Data_pez3000_analyzed/',graphTable.VideoName{j,1}(29:44),'APT_Results',[graphTable.VideoName{j,1} '.trk']),'file')
                graphTable.APTflag(j) = 1;
            end
        end
        graphTable(graphTable.APTflag==0,:)=[]; %remove all videos without APT Tracking
        if size(graphTable,1)>0
            
            load(fullfile('Z:/hhmiData/dm11/cardlab/Data_pez3000_analyzed/',expIDlist{:,i},[expIDlist{:,i} '_rawDataAssessment']))
            fullassessTable = [fullassessTable ; assessTable]; %#ok<*AGROW>
            
            load(fullfile('Z:/hhmiData/dm11/cardlab/Data_pez3000_analyzed/',expIDlist{:,i},[expIDlist{:,i} '_videoStatisticsMerged']))
            videoStatisticsMerged = dataset2table(videoStatisticsMerged);
            vidstats = [vidstats ; videoStatisticsMerged];
            
            
            % Removes data that does not meet +/- 22.5 degree stimulus criteria
            load(fullfile('Z:/hhmiData/dm11/cardlab/Data_pez3000_analyzed/',expIDlist{:,i},[expIDlist{:,i} '_experimentInfoMerged']))
            if ~contains(experimentInfoMerged.Stimuli_Type{1},'None') %if true, visual stimulus experiment
                stimazi(i) = str2double(experimentInfoMerged.Stimuli_Vars(1,1).Azimuth);
                stimele(i) = str2double(experimentInfoMerged.Stimuli_Vars(1,1).Elevation);
                stimtype{i} = replace(experimentInfoMerged.Stimuli_Type{1},'_', ' ');
                stimtype{i} = replace(stimtype{i},' blackonwhite','');
                if stimfilt
                    graphTable(graphTable.zeroFly_StimAtStimStart<deg2rad(stimazi(i)-22.5),:) = [];
                    graphTable(graphTable.zeroFly_StimAtStimStart>deg2rad(stimazi(i)+22.5),:) = [];
                end
                lv = str2double(extractAfter(stimtype{i},"lv"));
                if isnan(lv)
                    lv = str2double(extractBetween(stimtype{i},"lv",' '));
                end
                xlimit(i) = limitops(2,limitops(1,:)==lv); %finds corresponding xlim for lv value
            elseif size(experimentInfoMerged.Photo_Activation{1},2)==3 % if true, photoactivation experiment
                stimazi(i) = NaN;
                stimele(i) = NaN;
                stimtype{i} = experimentInfoMerged.Photo_Activation{1}{1,:};
                xlimit(i) = 90; %set to 90 frames (150ms) if not a visual stimulus
            else
                stimazi(i) = NaN;
                stimele(i) = NaN;
                stimtype{i} = 'No Stimulus';
                xlimit(i) = 90;
            end
            fullgraphTable = [fullgraphTable ; graphTable];
        else
            warning([sprintf('%s',expIDlist{:,i}) 'was not included'])
            mssing = [mssing ; i];
        end
    else
        warning([sprintf('%s',expIDlist{:,i}) 'was not included'])
        mssing = [mssing ; i];
    end
end

stimazi(mssing) = [];
stimele(mssing) = [];
stimtype(mssing) = [];
xlimit(mssing) = [];

%keyboard

%Combine all assessment tables
fullset = innerjoin(fullgraphTable,fullassessTable,'Keys','Row'); %all videos from graph table for experiment list
vidstats.VideoName = vidstats.Properties.RowNames;
fullset = innerjoin(fullset,vidstats,'Keys','VideoName');
fullset.Video_Path = replace(fullset.Video_Path,'\\tier2\card','\\dm11\cardlab');
fullset.Video_Path = replace(fullset.Video_Path,'\','/');
fullset.Video_Path = replace(fullset.Video_Path,'/dm11','groups/card');

expList = [];

%% Run through tracked points list once to find median fly point ratios
for i = 1:height(fullset)
    
    load(fullfile('Z:/hhmiData/dm11/cardlab/Data_pez3000_analyzed/',fullset.VideoName{i,1}(29:44),'APT_Results',[fullset.VideoName{i,1} '.trk']),'-mat')
    
    p1x = squeeze(pTrk(1,1,:)); p1x(pTrkocc(1,:)>0.5) = NaN;
    p2x = squeeze(pTrk(2,1,:)); p2x(pTrkocc(2,:)>0.5) = NaN;
    p9x = squeeze(pTrk(9,1,:)); p9x(pTrkocc(9,:)>0.5) = NaN;
    p10x = squeeze(pTrk(10,1,:)); p10x(pTrkocc(10,:)>0.5) = NaN;
    
    p1y = squeeze(pTrk(1,2,:)); p1y(pTrkocc(1,:)>0.5) = NaN;
    p2y = squeeze(pTrk(2,2,:)); p2y(pTrkocc(2,:)>0.5) = NaN;
    p9y = squeeze(pTrk(9,2,:)); p9y(pTrkocc(9,:)>0.5) = NaN;
    p10y = squeeze(pTrk(10,2,:)); p10y(pTrkocc(10,:)>0.5) = NaN;
    
    onetwo  = pTrkocc(1,:)<=0.5 & pTrkocc(2,:)<=0.5;                     %points 1 and 2 are both unoccluded
    onenine = pTrkocc(1,:)<=0.5 & pTrkocc(2,:)> 0.5 & pTrkocc(9,:)<=0.5; %points 1 and 9 are unoccluded, point 2 is occluded
    twonine = pTrkocc(1,:)> 0.5 & pTrkocc(2,:)<=0.5 & pTrkocc(9,:)<=0.5; %point 1 is occluded, points 2 and 9 are unoccluded
    twoten  = pTrkocc(1,:)> 0.5 & pTrkocc(9,:)> 0.5 & pTrkocc(2,:)<=0.5 & pTrkocc(10,:)<=0.5; %points 1 and 9 are occluded, points 2 and 10 are unoccluded
    
    flylength = sqrt((p2x-p1x).^2+(p2y-p1y).^2);
    flylength(flylength>190) = NaN; %sets threshold for fly length to reduce error
    flylength(flylength< 70) = NaN;
    avgflylength = mean(flylength,'omitnan'); %finds the average fly length from all frames where p1 and p2 are unoccluded
    
    xCpred = nan(length(p1x),1); %set up center positions as nan matrices
    yCpred = nan(length(p1y),1);
    
    xCpred(onetwo)  = (p1x(onetwo)+p2x(onetwo))./2;
    yCpred(onetwo)  = (p1y(onetwo)+p2y(onetwo))./2;
    
    xCpred(onenine) = p1x(onenine)+(avgflylength/2).*(p9x(onenine)-p1x(onenine))./(sqrt((p9x(onenine)-p1x(onenine)).^2+(p9y(onenine)-p1y(onenine)).^2));
    xCpred(twonine) = p2x(twonine)+(avgflylength/2).*(p9x(twonine)-p2x(twonine))./(sqrt((p9x(twonine)-p2x(twonine)).^2+(p9y(twonine)-p2y(twonine)).^2));
    xCpred(twoten)  = p2x(twoten)+(avgflylength/2).*(p10x(twoten)-p2x(twoten))./(sqrt((p10x(twoten)-p2x(twoten)).^2+(p10y(twoten)-p2y(twoten)).^2));
    
    yCpred(onenine) = p1y(onenine)+(avgflylength/2).*(p9y(onenine)-p1y(onenine))./(sqrt((p9x(onenine)-p1x(onenine)).^2+(p9y(onenine)-p1y(onenine)).^2));
    yCpred(twonine) = p2y(twonine)+(avgflylength/2).*(p9y(twonine)-p2y(twonine))./(sqrt((p9x(twonine)-p2x(twonine)).^2+(p9y(twonine)-p2y(twonine)).^2));
    yCpred(twoten) = p2y(twoten)+(avgflylength/2).*(p10y(twoten)-p2y(twoten))./(sqrt((p10x(twoten)-p2x(twoten)).^2+(p10y(twoten)-p2y(twoten)).^2));
    
    ratio29 (i) = median((sqrt((p9x-p2x).^2+(p9y-p2y).^2))./(sqrt((xCpred-p2x).^2+(yCpred-p2y).^2)),'omitnan');
    ratio19 (i) = median((sqrt((p9x-p1x).^2+(p9y-p1y).^2))./(sqrt((xCpred-p1x).^2+(yCpred-p1y).^2)),'omitnan');
    ratio210(i) = median((sqrt((p10x-p2x).^2+(p10y-p2y).^2))./(sqrt((xCpred-p2x).^2+(yCpred-p2y).^2)),'omitnan');
    
end

ratio29  = median(ratio29, 'omitnan');
ratio19  = median(ratio19, 'omitnan');
ratio210 = median(ratio210,'omitnan');

%% Setup points and calc center of mass
for i = 1:height(fullset)
    load(fullfile('Z:/hhmiData/dm11/cardlab/Data_pez3000_analyzed/',fullset.VideoName{i,1}(29:44),'APT_Results',[fullset.VideoName{i,1} '.trk']),'-mat')
    
    %set up points and remove predicted occlusions
    p1x = squeeze(pTrk(1,1,:)); p1x(pTrkocc(1,:)>0.5) = NaN;
    p2x = squeeze(pTrk(2,1,:)); p2x(pTrkocc(2,:)>0.5) = NaN;
    p3x = squeeze(pTrk(3,1,:)); p3x(pTrkocc(3,:)>0.5) = NaN;
    p4x = squeeze(pTrk(4,1,:)); p4x(pTrkocc(4,:)>0.5) = NaN;
    p5x = squeeze(pTrk(5,1,:)); p5x(pTrkocc(5,:)>0.5) = NaN;
    p6x = squeeze(pTrk(6,1,:)); p6x(pTrkocc(6,:)>0.5) = NaN;
    p7x = squeeze(pTrk(7,1,:)); p7x(pTrkocc(7,:)>0.5) = NaN;
    p8x = squeeze(pTrk(8,1,:)); p8x(pTrkocc(8,:)>0.5) = NaN;
    p9x = squeeze(pTrk(9,1,:)); p9x(pTrkocc(9,:)>0.5) = NaN;
    p10x = squeeze(pTrk(10,1,:)); p10x(pTrkocc(10,:)>0.5) = NaN;
    
    p1y = squeeze(pTrk(1,2,:)); p1y(pTrkocc(1,:)>0.5) = NaN;
    p2y = squeeze(pTrk(2,2,:)); p2y(pTrkocc(2,:)>0.5) = NaN;
    p3y = squeeze(pTrk(3,2,:)); p3y(pTrkocc(3,:)>0.5) = NaN;
    p4y = squeeze(pTrk(4,2,:)); p4y(pTrkocc(4,:)>0.5) = NaN;
    p5y = squeeze(pTrk(5,2,:)); p5y(pTrkocc(5,:)>0.5) = NaN;
    p6y = squeeze(pTrk(6,2,:)); p6y(pTrkocc(6,:)>0.5) = NaN;
    p7y = squeeze(pTrk(7,2,:)); p7y(pTrkocc(7,:)>0.5) = NaN;
    p8y = squeeze(pTrk(8,2,:)); p8y(pTrkocc(8,:)>0.5) = NaN;
    p9y = squeeze(pTrk(9,2,:)); p9y(pTrkocc(9,:)>0.5) = NaN;
    p10y = squeeze(pTrk(10,2,:)); p10y(pTrkocc(10,:)>0.5) = NaN;
    
    %start center point estimation
    onetwo  = pTrkocc(1,:)<=0.5 & pTrkocc(2,:)<=0.5;                     %points 1 and 2 are both unoccluded
    onenine = pTrkocc(1,:)<=0.5 & pTrkocc(2,:)> 0.5 & pTrkocc(9,:)<=0.5; %points 1 and 9 are unoccluded, point 2 is occluded
    twonine = pTrkocc(1,:)> 0.5 & pTrkocc(2,:)<=0.5 & pTrkocc(9,:)<=0.5; %point 1 is occluded, points 2 and 9 are unoccluded
    twoten  = pTrkocc(1,:)> 0.5 & pTrkocc(9,:)> 0.5 & pTrkocc(2,:)<=0.5 & pTrkocc(10,:)<=0.5; %points 1 and 9 are occluded, points 2 and 10 are unoccluded
    
    flylength = sqrt((p2x-p1x).^2+(p2y-p1y).^2);
    flylength(flylength>190) = NaN; %sets threshold for fly length to reduce error
    flylength(flylength< 70) = NaN;
    avgflylength = mean(flylength,'omitnan'); %finds the average fly length from all frames where p1 and p2 are unoccluded
    
    xCpred = nan(length(p1x),1); %set up center positions as nan matrices
    yCpred = nan(length(p1y),1);
    
    xCpred(onetwo) = (p1x(onetwo)+p2x(onetwo))./2;
    yCpred(onetwo) = (p1y(onetwo)+p2y(onetwo))./2;
    
    if ~isnan(avgflylength) %if avgflylength can be calculated, use that to find center when pts 1 or 2 are occluded. If not, use pt ratios to estimate center
        xCpred(onenine) = p1x(onenine)+(avgflylength/2).*(p9x(onenine)-p1x(onenine))./(sqrt((p9x(onenine)-p1x(onenine)).^2+(p9y(onenine)-p1y(onenine)).^2));
        xCpred(twonine) = p2x(twonine)+(avgflylength/2).*(p9x(twonine)-p2x(twonine))./(sqrt((p9x(twonine)-p2x(twonine)).^2+(p9y(twonine)-p2y(twonine)).^2));
        xCpred(twoten)  = p2x(twoten)+(avgflylength/2).*(p10x(twoten)-p2x(twoten))./(sqrt((p10x(twoten)-p2x(twoten)).^2+(p10y(twoten)-p2y(twoten)).^2));
        
        yCpred(onenine) = p1y(onenine)+(avgflylength/2).*(p9y(onenine)-p1y(onenine))./(sqrt((p9x(onenine)-p1x(onenine)).^2+(p9y(onenine)-p1y(onenine)).^2));
        yCpred(twonine) = p2y(twonine)+(avgflylength/2).*(p9y(twonine)-p2y(twonine))./(sqrt((p9x(twonine)-p2x(twonine)).^2+(p9y(twonine)-p2y(twonine)).^2));
        yCpred(twoten) = p2y(twoten)+(avgflylength/2).*(p10y(twoten)-p2y(twoten))./(sqrt((p10x(twoten)-p2x(twoten)).^2+(p10y(twoten)-p2y(twoten)).^2));
    else
        xCpred(onenine) = p1x(onenine)+(p9x(onenine)-p1x(onenine))./ratio19;
        xCpred(twonine) = p2x(twonine)+(p9x(twonine)-p2x(twonine))./ratio29;
        xCpred(twoten)  = p2x(twoten)+(p10x(twoten)-p2x(twoten))./ratio210;
        
        yCpred(onenine) = p1y(onenine)+(p9y(onenine)-p1y(onenine))./ratio19;
        yCpred(twonine) = p2y(twonine)+(p9y(twonine)-p2y(twonine))./ratio29;
        yCpred(twoten) = p2y(twoten)+(p10y(twoten)-p2y(twoten))./ratio210;
    end
    
    vidname = fullset.VideoName{i};
    expID = vidname(29:44);
    expIDname = ['e' expID]; %add letter to beginning of exp ID to use it as a variable name
    expList = unique([expList ; expIDname],'rows'); %all experiment IDs that made it through the video filtering steps
    
    APTproc.data(i).p1x = p1x; APTproc.data(i).p1y = p1y;
    APTproc.data(i).p2x = p2x; APTproc.data(i).p2y = p2y;
    APTproc.data(i).p3x = p3x; APTproc.data(i).p3y = p3y;
    APTproc.data(i).p4x = p4x; APTproc.data(i).p4y = p4y;
    APTproc.data(i).p5x = p5x; APTproc.data(i).p5y = p5y;
    APTproc.data(i).p6x = p6x; APTproc.data(i).p6y = p6y;
    APTproc.data(i).p7x = p7x; APTproc.data(i).p7y = p7y;
    APTproc.data(i).p8x = p8x; APTproc.data(i).p8y = p8y;
    APTproc.data(i).p9x = p9x; APTproc.data(i).p9y = p9y;
    APTproc.data(i).p10x = p10x; APTproc.data(i).p10y = p10y;
    APTproc.data(i).xCpred = xCpred; APTproc.data(i).yCpred = yCpred;
    
    APTproc.expIDname{i} = expIDname;
    
end

APTproc.expList = expList;
APTproc.stimazi = stimazi;
APTproc.stimele = stimele;
APTproc.stimtype = stimtype;
APTproc.xlimit = xlimit;

% keyboard