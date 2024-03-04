function vidMontage_by_experimentID_PA(totalComps,thisComp)
if isempty(mfilename) || nargin == 0
    totalComps = 1;
    thisComp = 1;
end
%%%%% computer and directory variables and information
op_sys = system_dependent('getos');
if strfind(op_sys,'Microsoft Windows 7')
    archDir = [filesep filesep 'tier2' filesep 'card'];
    dm11Dir = [filesep filesep 'dm11' filesep 'cardlab'];
else
    archDir = [filesep 'Volumes' filesep 'card'];
    if ~exist(archDir,'file')
        archDir = [filesep 'Volumes' filesep 'card-1'];
    end
    dm11Dir = [filesep 'Volumes' filesep 'cardlab'];
end
if ~exist(archDir,'file')
    error('Archive access failure')
end
if ~exist(dm11Dir,'file')
    error('dm11 access failure')
end
% parentDir = fullfile(archDir,'Data_pez3000');
analysisDir = fullfile(dm11Dir,'Data_pez3000_analyzed');

[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
subfun_dir = fullfile(repositoryDir,'pezProc_subfunctions');
saved_var_dir = fullfile(repositoryDir,'pezProc_saved_variables');
addpath(repositoryDir,subfun_dir,saved_var_dir)
addpath(fullfile(repositoryDir,'Pez3000_Gui_folder','Matlab_functions','Support_Programs'))
installVideoUtils

guiVarDir = fullfile(dm11Dir,'Pez3000_Gui_folder','Gui_saved_variables');
groupData = load(fullfile(guiVarDir,'Saved_Group_IDs.mat'));
groupData = groupData.Saved_Group_IDs;
[groupNames,refsFirst,refsFull] = unique(groupData.Group_Desc);
groupNames = strtrim(groupNames)
groupUsers = groupData.User_ID(refsFirst);
groupExpts = cell(numel(refsFirst),1);
for iterGrp = 1:numel(refsFirst)
    groupExpts(iterGrp) = {groupData.Experiment_ID(refsFull == iterGrp)};
end
groupData = [groupNames,groupUsers,groupExpts];
groupTableData = groupData(:,1:2);
% exptIDlist = groupData(strcmp(groupTableData(:,1),'CCX_activation_group'),3);
exptIDlist = groupData(strcmp(groupTableData(:,1),'OL_lines_collection_19_chrimson_only'),3);
exptIDlist = exptIDlist{1};

%%
maxFlies = 12;
framesBeforeStim = 30;
framesAfterStim = 30;
tol = [0.01 0.999];
gammaAdj = 0.7;
infoCell = {'ParentB_genotype'};
labelCell = {'genotype'};
exptRefBreaks = round(linspace(1,numel(exptIDlist),totalComps+1));
for iterE = exptRefBreaks(thisComp):exptRefBreaks(thisComp+1)
    %     iterE = 1
    disp(num2str(iterE))
    exptID = exptIDlist{iterE};
    disp(exptID)
    exptResultsRefDir = fullfile(analysisDir,exptID);
    assessmentName = [exptID '_rawDataAssessment.mat'];
    assessmentPath = fullfile(exptResultsRefDir,assessmentName);
    if exist(assessmentPath,'file') == 2
        assessTable_import = load(assessmentPath);
        dataname = fieldnames(assessTable_import);
        assessTable = assessTable_import.(dataname{1});
    else
        continue
    end
    
    autoAnnoName = [exptID '_automatedAnnotations.mat'];
    autoAnnotationsPath = fullfile(analysisDir,exptID,autoAnnoName);
    if exist(autoAnnotationsPath,'file') == 2
        autoAnnoTable_import = load(autoAnnotationsPath);
        dataname = fieldnames(autoAnnoTable_import);
        automatedAnnotations = autoAnnoTable_import.(dataname{1});
    else
        continue
    end
    
    assessNames = assessTable.Properties.RowNames;
    autoNames = automatedAnnotations.Properties.RowNames;
    nameCell = {assessNames,autoNames};
    nameCounts = [numel(nameCell{1}),numel(nameCell{2})];
    [~,minNdx] = min(nameCounts);
    masterList = nameCell{minNdx};
    masterList = masterList(strcmp(assessTable.Raw_Data_Decision(masterList),'Pass'));
    masterList = masterList(strcmp(assessTable.Analysis_Status(masterList),'Analysis complete'));
    
    activationProtocols = unique(automatedAnnotations.photoStimProtocol(masterList));
    activationProtocols = sort(activationProtocols);
    for protocolRef = 1:numel(activationProtocols)
        masterListB = masterList(strcmp(automatedAnnotations.photoStimProtocol(masterList),activationProtocols{protocolRef}));
        photoStimName = activationProtocols{protocolRef};
        vidsAvailable = numel(masterListB);
        if vidsAvailable > maxFlies
            vidsAvailable = maxFlies;
        end
        if vidsAvailable == 0
            continue
        end
        vidInfoMergedName = [exptID '_videoStatisticsMerged.mat'];
        vidInfoMergedPath = fullfile(exptResultsRefDir,vidInfoMergedName);
        vidInfo_import = load(vidInfoMergedPath);
        dataname = fieldnames(vidInfo_import);
        videoStatisticsMerged = vidInfo_import.(dataname{1});
        
        exptInfoMergedName = [exptID '_experimentInfoMerged.mat'];
        exptInfoMergedPath = fullfile(exptResultsRefDir,exptInfoMergedName);
        experimentInfoMerged = load(exptInfoMergedPath,'experimentInfoMerged');
        exptInfo = experimentInfoMerged.experimentInfoMerged;
        exptInfo = exptInfo(1,:);
        
        montDir = fullfile(analysisDir,exptID);
        destName = [exptID '_montage' num2str(protocolRef) '.mp4'];
        destPath = fullfile(montDir,destName);
        
        vidRefs = randperm(numel(masterListB));
        vidList = masterListB(vidRefs(1:vidsAvailable));
        vidCount = numel(vidList);
        
        locator_name = 'flyLocator3000_v9';
        locator_data_dir = fullfile(exptResultsRefDir,[exptID '_' locator_name]);
        locatorIDlist = cellfun(@(x) [x '_' locator_name '_data.mat'],vidList,'uniformoutput',false);
        locatorPathList = cellfun(@(x) fullfile(locator_data_dir,x),locatorIDlist,'uniformoutput',false);
        
        analyzer_name = 'pezAnalyzer3000_v11';
        analyzer_data_dir = fullfile(exptResultsRefDir,[exptID '_' analyzer_name]);
        analyzerIDlist = cellfun(@(x) [x '_' analyzer_name '_data.mat'],vidList,'uniformoutput',false);
        analyzerPathList = cellfun(@(x) fullfile(analyzer_data_dir,x),analyzerIDlist,'uniformoutput',false);
        
        vidObjCutrate = cell(vidCount,1);
        frameReferenceVec = cell(vidCount,1);
        frm_remapCell = cell(vidCount,1);
        frmBounds = cell(vidCount,1);
        flyPosX = cell(vidCount,1);
        flyPosY = cell(vidCount,1);
        for iterM = 1:vidCount
            videoID = vidList{iterM};
            vidPath = assessTable.Video_Path{videoID};
            vidStats = videoStatisticsMerged(videoID,:);
            
            frameRefcutrate = vidStats.cutrate10th_frame_reference{videoID};
            Y = (1:numel(frameRefcutrate));
            yi = repmat(Y,10,1);
            frameReferenceVec{iterM} = yi(:);
            
            stimStart = automatedAnnotations.photoStimFrameStart{videoID};
            stimLength = automatedAnnotations.photoStimFrameCount{videoID};
            stimFrames = (stimStart-framesBeforeStim:stimStart+stimLength+framesAfterStim);
            stimFrames(stimFrames < 1) = 1;
            frameCt = vidStats.frame_count(videoID);
            rateFactor = double(vidStats.record_rate(videoID))/1000;
            stimFrames(stimFrames > frameCt) = frameCt;
            frmBounds{iterM} = stimFrames;
            
            locatorRecord = load(locatorPathList{iterM});
            dataname = fieldnames(locatorRecord);
            locatorRecord = locatorRecord.(dataname{1});
            %         flyPosX = round(locatorRecord.center_point{1}(1));
            flyPosY{iterM} = round(mean(assessTable.Adjusted_ROI{videoID}(end-1:end)));
            
            vidObjCutrate{iterM} = VideoReader(vidPath);
            video_init = read(vidObjCutrate{iterM},[1 10]);
            frame_01_gray = uint8(mean(squeeze(video_init(:,:,1,:)),3));
            frame_01_gray = frame_01_gray(1:flyPosY{iterM},:);
            [~,frm_graymap] = gray2ind(frame_01_gray,256);
            lowhigh_in = stretchlim(frame_01_gray,tol);
            lowhigh_in(1) = 0.02;
            frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],gammaAdj);
            frm_remapCell{iterM} = uint8(frm_remap(:,1).*255);
            
            analyzerRecord = load(analyzerPathList{iterM});
            dataname = fieldnames(analyzerRecord);
            analyzerRecord = analyzerRecord.(dataname{1});
            flyPosX{iterM} = smooth(analyzerRecord.top_points_and_thetas{1}(:,1),256);
            if abs(flyPosX{iterM}(1)) > size(frame_01_gray)
                flyPosX{iterM} = repmat(round(locatorRecord.center_point{1}(1)),1,numel(flyPosX{iterM}));
            end
            %         analysis_labeled = analyzerVisualizationFun(analyzerRecord,locatorRecord);
        end
        montFrmCt = numel(stimFrames);
        iterFops = (1:10:montFrmCt);
        if exist(destPath,'file')
            try
                writeTestObj = VideoReader(destPath);
                writeCt = get(writeTestObj,'NumberOfFrames');
                if numel(iterFops) == writeCt
                    continue
                end
            catch
            end
        end
        
        
        
        
        [video_pulse,maxInt] = photoactivationTraceMaker(photoStimName,exptID,montFrmCt,framesBeforeStim,rateFactor);
        
        montDims = [1920 300];
        spacingRefs = linspace(1,montDims(1),vidCount+1);
        spacingMids = round(diff(spacingRefs)/2+spacingRefs(1:end-1));
        baseFrame = uint8(zeros(fliplr(montDims)));
        
        textBase = baseFrame(1:100,:);
        infoA = exptInfo.(infoCell{1});
        labelOps = {[labelCell{1} ': ']
            strtrim(infoA{1})
            'exptID: '
            exptID
            'light intensity:       uW/mm2'%9 spaces
            'time lapsed:       ms'%9 spaces
            'current frame: '};
        fontSz = 20;
        labelPos = {[0.05 0.4]
            [0.15 0.4]
            [0.65 0.4]
            [0.75 0.4]
            [0.05 0.9]
            [0.4 0.9]
            [0.65 0.9]};
        labelCt = numel(labelOps);
        for iterL = 1:labelCt
            textBase = textN2im_v2(textBase,labelOps(iterL),fontSz,...
                labelPos{iterL},'left');
        end
        %%
        graphBase = baseFrame;
        graphBaseT = graphBase;
        baseXa = round(0.13*montDims(1));
        baseXb = round(0.93*montDims(1));
        baseYa = round(0.2*montDims(2));
        baseYb = round(0.7*montDims(2));
        %     graphBase(baseYb-1:baseYb+1,baseXa:baseXb) = 200;
        %     graphBase(baseYa:baseYb,baseXa-1:baseXa+1) = 200;
        
        xOutput = (1:baseXb-baseXa)+baseXa;
        xNput = round(linspace(baseXa,baseXb,numel(video_pulse)));
        yNput = (video_pulse-min(video_pulse))/range(video_pulse);
        yNput = abs(yNput-1)*(baseYb-baseYa)+baseYa;
        [~,NputRefs] = unique(xNput);
        yOutput = interp1(xNput(NputRefs),yNput(NputRefs),xOutput,'linear','extrap');
        yOutput = round(yOutput);
        graphBase(sub2ind(size(graphBase),yOutput,xOutput)) = 200;
        graphBase(sub2ind(size(graphBase),yOutput+1,xOutput)) = 200;
        graphBase(sub2ind(size(graphBase),yOutput+2,xOutput)) = 200;
        graphBase(sub2ind(size(graphBase),yOutput-1,xOutput)) = 200;
        graphBase(sub2ind(size(graphBase),yOutput-2,xOutput)) = 200;
        labelOps = {'0'
            num2str(maxInt)
            '1'
            num2str(montFrmCt)
            '% power'
            'frame'};
        fontSz = 20;
        labelPos = {[baseXa/montDims(1)-0.02 baseYb/montDims(2)+0.05]
            [baseXa/montDims(1)-0.02 baseYa/montDims(2)+0.05]
            [baseXa/montDims(1)+0.01 baseYb/montDims(2)+0.2]
            [baseXb/montDims(1) baseYb/montDims(2)+0.2]
            [baseXa/montDims(1)-0.02 mean([baseYa/montDims(2)+0.05,baseYb/montDims(2)+0.05])]
            [mean([baseXa/montDims(1)+0.01,baseXb/montDims(1)]) baseYb/montDims(2)+0.2]};
        labelCt = numel(labelOps);
        for iterL = 1:labelCt
            graphBaseT = textN2im_v2(graphBaseT,labelOps(iterL),fontSz,...
                labelPos{iterL},'right');
        end
        graphBaseT = graphBaseT*0.8;
        graphBase = cat(3,max(graphBase,graphBaseT),graphBaseT,graphBaseT);
        %     imshow(graphBase)
        %%
        writeObj = VideoWriter(destPath,'MPEG-4');
        open(writeObj)
        
        for iterF = iterFops
            frmFullA = baseFrame;
            frmFullB = baseFrame;
            for iterM = 1:vidCount
                frmRef = frmBounds{iterM}(iterF);
                frameRead = frameReferenceVec{iterM}(frmRef);
                frmA = read(vidObjCutrate{iterM},frameRead);
                %             frmA = vidObjCutrate{iterM}.getFrameAtNum(frameRead-1);
                frmA = frmA(:,:,1);
                %             frmA = uint8(frmA(:,:,1)*255);
                %%
                if frmRef > numel(flyPosX{iterM})
                    xRefA = spacingMids(iterM)-round(flyPosX{iterM}(end));
                else
                    xRefA = spacingMids(iterM)-round(flyPosX{iterM}(frmRef));
                end
                
                yRefA = round(montDims(2)-montDims(2)/8)-flyPosY{iterM};
                if xRefA < 1
                    frmA(:,1:abs(xRefA)+1) = [];
                    xRefA = 1;
                end
                if yRefA < 1
                    frmA(1:abs(yRefA)+1,:) = [];
                    yRefA = 1;
                end
                xRefB = xRefA+size(frmA,2)-1;
                yRefB = yRefA+size(frmA,1)-1;
                if xRefB > montDims(1)
                    frmA(:,end-(xRefB-montDims(1))+1:end) = [];
                    xRefB = montDims(1);
                end
                if yRefB > montDims(2)
                    frmA(end-(yRefB-montDims(2))+1:end,:) = [];
                    yRefB = montDims(2);
                end
                frmFullA(yRefA:yRefB,xRefA:xRefB) = frmA;
                frmFullB = max(frmFullA,frmFullB);
            end
            %%
            formatSa = ['%0' num2str(numel(num2str(round(montFrmCt/rateFactor)))) 's'];
            formatSb = ['%0' num2str(numel(num2str(montFrmCt))) 's'];
            labelOps = {sprintf('%04s',num2str(round(video_pulse(iterF))))
                sprintf(formatSa,num2str(round(iterF/rateFactor)))
                sprintf(formatSb,num2str(iterF))};
            labelPos = {[0.23 0.9]
                [0.565 0.9]
                [0.85 0.9]};
            textFrm = textBase;
            kern = 0.5;
            for iterL = 1:3
                textFrm = textN2im_v2(textFrm,labelOps(iterL),fontSz,...
                    labelPos{iterL},'right',kern);
            end
            frmFullB(1:2,:) = 100;
            frmFullC = [textFrm*0.8;frmFullB];
            frmFullC(end-1:end,:) = 100;
            frmFullD = [repmat(frmFullC,[1 1 3]);graphBase];
            frmFullD(baseYa+size(frmFullC,1):baseYb+size(frmFullC,1),xNput(iterF),:) = 235;
            frmFullD(baseYa+size(frmFullC,1):baseYb+size(frmFullC,1),xNput(iterF)+1,:) = 235;
            %         imshow(frmFullD)
            %         drawnow
            
            writeVideo(writeObj,frmFullD)
        end
        close(writeObj)
    end
end
end
function [video_pulse,maxInt] = photoactivationTraceMaker(photoStimName,exptID,frameCt,stimStart,rateFactor)

savedPhotostimDir = [filesep filesep 'DM11' filesep 'cardlab' filesep,...
    'pez3000_variables' filesep 'photoactivation_stimuli'];
calibrationPath = [filesep filesep 'DM11' filesep 'cardlab' filesep,...
    'pez3000_variables' filesep 'Pez3_Chrimson_LED_calibration_20140709.xlsx'];
calibTable = readtable(calibrationPath,'Sheet','data');

nameParts = strsplit(photoStimName,'_');
methodName = nameParts{1};

if str2double(exptID(13:16)) < 100
    %         photoStimStruct.photoStimProtocol = {photoStimName};
    %         photoStimStruct.photoStimFrameStart = {find(nidaqData > .5,1,'first')};
    %         photoStimStruct.photoStimFrameCount = {round(2000*(1.028)*rateFactor)};
    %         if numel(find(nidaqData > .4 & nidaqData < 0.6))/2 > 10
    %             photoStimStruct.stimDecision = 'Unsure';
    %         else
    %             photoStimStruct.stimDecision = 'Good';
    %         end
    return
elseif exist(fullfile(savedPhotostimDir,[photoStimName '.mat']),'file')
    load(fullfile(savedPhotostimDir,[photoStimName '.mat']));
elseif exist(fullfile(savedPhotostimDir,'photoactivation_archive',[photoStimName '.mat']),'file')
    load(fullfile(savedPhotostimDir,'photoactivation_archive',[photoStimName '.mat']));
else
    if strcmp('pulse',methodName)
        var_pul_width_begin = str2double(nameParts{3}(numel('widthBegin')+1:end));
        var_pul_width_end = str2double(nameParts{4}(numel('widthEnd')+1:end));
        var_pul_count = str2double(nameParts{5}(numel('cycles')+1:end));
        var_intensity = str2double(nameParts{6}(numel('intensity')+1:end));
        if var_pul_count == 1
            if strcmp(photoStimName,'pulse_Namikis_width1000_period1000_cycles1_intensity2')
                var_pul_width_begin = 1000;
                var_pul_width_end = 1000;
                var_pul_count = 1;
                var_intensity = 2;
                var_tot_dur = var_pul_width_begin;
            else
                var_tot_dur = var_pul_width_begin;
            end
        elseif strcmp(photoStimName,'pulse_General_widthBegin5_widthEnd150_cycles5_intensity30')
            var_tot_dur = 1000;
        elseif strcmp(photoStimName,'pulse_Williamsonw_widthBegin5_widthEnd75_cycles5_intensity30')
            var_tot_dur = 500;
        else
            var_tot_dur = 500;
        end
    elseif strcmp('ramp',methodName)
        var_ramp_width = str2double(nameParts{3}(numel('rampWidth')+1:end));
        var_tot_dur = str2double(nameParts{6}(numel('totalDur')+1:end));
        var_ramp_init = str2double(nameParts{4}(numel('initVal')+1:end));
        var_intensity = str2double(nameParts{5}(numel('finalVal')+1:end));
    elseif strcmp('combo',methodName)
        var_pul_width_begin = str2double(nameParts{3}(numel('pulseWidthBegin')+1:end));
        var_pul_width_end = str2double(nameParts{4}(numel('pulseWidthEnd')+1:end));
        var_pul_count = str2double(nameParts{5}(numel('cycles')+1:end));
        var_ramp_width = str2double(nameParts{6}(numel('rampWidth')+1:end));
        var_tot_dur = str2double(nameParts{9}(numel('totalDur')+1:end));
        var_ramp_init = str2double(nameParts{7}(numel('initVal')+1:end));
        var_intensity = str2double(nameParts{8}(numel('finalVal')+1:end));
    elseif strcmp('Alternating',methodName)
        %             photoStimStruct.stimDecision = 'Unsure';
        return
    else
        error('invalid name')
    end
end

oldProtocols = {'pulse_Testing_widthBegin5_widthEnd150_period150_cycles6_intensity20'
    'pulse_Testing_widthBegin5_widthEnd150_period150_cycles6_intensity30'
    'pulse_Testing_widthBegin5_widthEnd150_period150_cycles6_intensity40'
    'combo_Testing_pulseWidth5_period150_cycles6_rampWidth800_initVal5_finalVal50_totalDur900'
    'combo_Testing_pulseWidth100_period150_cycles6_rampWidth800_initVal5_finalVal50_totalDur900'
    'combo_Testing_pulseWidth25_period150_cycles6_rampWidth800_initVal5_finalVal50_totalDur900'};
if max(strcmp(oldProtocols,photoStimName))
    %         photoStimStruct.photoStimProtocol = {photoStimName};
    %         photoStimStruct.photoStimFrameStart = {find(nidaqData > .5,1,'first')};
    %         if ~exist('var_tot_dur','var')
    %             var_tot_dur = 900;
    %         end
    %         photoStimStruct.photoStimFrameCount = {round(var_tot_dur*(1.028)*rateFactor)};
    %         if numel(find(nidaqData > .4 & nidaqData < 0.6))/2 > 10
    %             photoStimStruct.stimDecision = 'Unsure';
    %         else
    %             photoStimStruct.stimDecision = 'Good';
    %         end
    return
end

if strcmp('ramp',methodName)
    pulseGui_x = (1:var_tot_dur);
    var_slope = (var_ramp_init-var_intensity)/(0-var_ramp_width);
    pulseGui_y = var_slope.*pulseGui_x+var_ramp_init;
else
    if exist('var_pul_count','var')
        cycles = var_pul_count;
    else
        cycles = str2double(photoStimName(strfind(photoStimName,'cycles')+numel('cycles')));
    end
    xA = linspace(var_pul_width_begin,var_pul_width_end,cycles);
    if cycles == 1
        xOff = 0;
    else
        xOff = (var_tot_dur-sum(xA))/(cycles-1);
    end
    if xOff < 0
        xOff = 0;
    end
    xB = zeros(1,cycles)+xOff;
    xC = [xB;xA];
    xC = repmat(cumsum(xC(:)),1,2)'-xOff;
    pulseGui_x = round(xC(:));
    
    yA = repmat([0;var_intensity;var_intensity;0],1,cycles);
    if strcmp('combo',methodName)
        var_slope = (var_ramp_init-var_intensity)/(0-var_ramp_width);
        yA(2,:) = var_slope.*xB(2,:)+var_ramp_init;
        yA(3,:) = yA(2,:);
        yA(yA > var_intensity) = var_intensity;
    end
    pulseGui_y = round(yA(:));
    if max(pulseGui_x > var_tot_dur)
        pulseGui_y(pulseGui_x >= var_tot_dur) = [];
        pulseGui_x(pulseGui_x >= var_tot_dur) = [];
        pulseGui_xB = [pulseGui_x;var_tot_dur;var_tot_dur];
        pulseGui_yB = [pulseGui_y;var_intensity;0];
        pulseGui_x = pulseGui_xB;
        pulseGui_y = pulseGui_yB;
    end
    pulseRef = (2:2:numel(pulseGui_x));
    pulseGui_xPart = pulseGui_x(pulseRef);
    pulseGui_yPart = pulseGui_y(pulseRef);
    pulseGui_x = (1:var_tot_dur);
    pulseGui_y = zeros(1,var_tot_dur);
    for iterP = 1:numel(pulseRef)-1
        xrefA = pulseGui_xPart(iterP);
        xrefB = pulseGui_xPart(iterP+1);
        pulseGui_y(xrefA+1:xrefB) = pulseGui_yPart(iterP);
    end
end

pulseOpsX = pulseGui_x;
pulseOpsY = pulseGui_y;
pulseGui_xReal = (pulseOpsX*(1.028)*rateFactor);
video_x = (1:max(pulseGui_xReal));
video_pulse = interp1(pulseGui_xReal,pulseOpsY,video_x,'nearest','extrap');
video_pulse = video_pulse/max(video_pulse);
video_pulse(video_pulse < 0) = 0;
video_pulse = [zeros(stimStart,1);video_pulse(:)];
video_pulse(frameCt) = 0;

prctI = [0;calibTable.prct_intensity];
uWdata = [0;calibTable.uW_per_mm2];
interpX = linspace(0,var_intensity,100);
interpY = interp1(prctI,uWdata,interpX,'pchip','extrap');

video_pulse = interpY(round(video_pulse*99)+1);
maxInt = var_intensity;
% plot(video_pulse)

end
