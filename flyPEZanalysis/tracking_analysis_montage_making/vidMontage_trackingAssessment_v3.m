function vidMontage_trackingAssessment(totalComps,thisComp)
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

% guiVarDir = fullfile(dm11Dir,'Pez3000_Gui_folder','Gui_saved_variables');
% groupData = load(fullfile(guiVarDir,'Saved_Group_IDs.mat'));
% groupData = groupData.Saved_Group_IDs;
% [groupNames,refsFirst,refsFull] = unique(groupData.Group_Desc);
% groupNames = strtrim(groupNames);
% groupUsers = groupData.User_ID(refsFirst);
% groupExpts = cell(numel(refsFirst),1);
% for iterGrp = 1:numel(refsFirst)
%     groupExpts(iterGrp) = {groupData.Experiment_ID(refsFull == iterGrp)};
% end
% groupData = [groupNames,groupUsers,groupExpts];
% groupTableData = groupData(:,1:2);
% % exptIDlist = groupData(strcmp(groupTableData(:,1),'CCX_activation_group'),3);
% exptIDlist = groupData(strcmp(groupTableData(:,1),'OL_lines_collection_19_chrimson_only'),3);
% exptIDlist = exptIDlist{1};
exptIDlist = {'0019000004840101'};
%%

%%
rowCt = 4;
colCt = 7;
montPosR = repmat((1:rowCt),colCt,1);
montPosC = repmat((1:colCt)',1,rowCt);
montPos = [montPosR(:) montPosC(:)];
maxFlies = size(montPos,1);
tol = [0.01 0.999];
gammaAdj = 0.7;

writeVid = 1;

exptRefBreaks = round(linspace(1,numel(exptIDlist),totalComps+1));
for iterE = 1
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
    automatedAnnotations = automatedAnnotations(assessNames,:);
    passTest = strcmp(assessTable.Raw_Data_Decision(assessNames),'Pass');
    autoNames = automatedAnnotations.Properties.RowNames;
    analyzer_name = 'flyAnalyzer3000_v12';
    analyzer_data_dir = fullfile(exptResultsRefDir,[exptID '_' analyzer_name]);
    analyzerIDlist = cellfun(@(x) [x '_' analyzer_name '_data.mat'],autoNames,'uniformoutput',false);
    analyzerPathList = cellfun(@(x) fullfile(analyzer_data_dir,x),analyzerIDlist,'uniformoutput',false);
    completeTest = cellfun(@(x) exist(x,'file'),analyzerPathList);
    exptTable = readtable(['Y:\WryanW\labmeetingPrep_20140907\' exptID 'table.txt'],'ReadRowNames',true);
    
    %%%%%%%%%%%%%%%%%%%%%%
    masterList = exptTable(logical(exptTable.jumpTest),:).Properties.RowNames;
    %%%%%%%%%%%%%%%%%%%%%%
    
    
%     masterList = autoNames(passTest & completeTest);
    vidsAvailable = numel(masterList)
    if vidsAvailable == 0
        continue
    end
    vidRefBrksPre = (1:maxFlies:vidsAvailable);
    vidRefBrks = [vidRefBrksPre vidsAvailable+1];
    montCt = numel(vidRefBrks)-1;
%     montDir = fullfile(analysisDir,exptID,[exptID '_flyAnalyzer3000_v12_visualMontage']);
    montDir = fullfile('Y:\WryanW\labmeetingPrep_20140907',[exptID '_flyAnalyzer3000_v12_visualMontage']);
    if ~isdir(montDir), mkdir(montDir), end
    montNames = cellfun(@(x) [exptID '_trackingMontage' sprintf('%03s',num2str(x)) '.mp4'],...
        num2cell(1:montCt)','uniformoutput',false);
    
    
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
    
    for iterB = 1%:montCt
        autoVarNames = automatedAnnotations.Properties.VariableNames;
        newVarNames = {'montageName','montagePosition','montageDecision'};
        if ~max(strcmp(autoVarNames,newVarNames{1}))
            automatedAnnotations2append = cell2table(cell(numel(autoNames),numel(newVarNames)),...
                'VariableNames',newVarNames);
            automatedAnnotations = [automatedAnnotations automatedAnnotations2append];
        end
        
        vidRefs = (vidRefBrks(iterB):vidRefBrks(iterB+1)-1);
        vidList = masterList(vidRefs);
        vidCount = numel(vidList);
        
        makeMonty = false;
        currTest = strcmp(automatedAnnotations.montageName,montNames{iterB});
        currList = autoNames(passTest & completeTest & currTest);
        if ~isequal(currList(:),vidList(:))
            makeMonty = true;
        end

        
        
        vidStats = videoStatisticsMerged(vidList,:);
        frameCtList = vidStats.frame_count;
%         if sum(diff(frameCtList)) ~= 0
%             error('frame count mismatch')
%         end
        frameCt = min(frameCtList);
        rateFactor = 1;%between 1 and 10
        frmRefs = (1:rateFactor:floor(frameCt/rateFactor));
        iterFops = (1:rateFactor*10:frameCt);
        montFrmCt = numel(iterFops);
        destPath = fullfile(montDir,montNames{iterB});
        if exist(destPath,'file')
            try
                writeTestObj = VideoReader(destPath);
                writeCt = get(writeTestObj,'NumberOfFrames');
                if montFrmCt ~= writeCt
                    error('bad existing montage')
                end
                delete(writeTestObj)
            catch
                makeMonty = true;
            end
        else
            makeMonty = true;
        end
        
        
        analyzer_name = 'flyAnalyzer3000_v12';
        analyzer_data_dir = fullfile(exptResultsRefDir,[exptID '_' analyzer_name]);
        analyzerIDlist = cellfun(@(x) [x '_' analyzer_name '_data.mat'],vidList,'uniformoutput',false);
        analyzerPathList = cellfun(@(x) fullfile(analyzer_data_dir,x),analyzerIDlist,'uniformoutput',false);
        
        vidObj = cell(vidCount,1);
        frm_remapTB = cell(vidCount,2);
        xyThTop = cell(vidCount,1);
        xyThBot = cell(vidCount,1);
        flyLength = cell(vidCount,1);
        finalFrm = cell(vidCount,1);
        for vRef = 1:vidCount
            videoID = vidList{vRef};
            automatedAnnotations.montageName{videoID} = montNames{iterB};
            
            vidPath = assessTable.Video_Path{videoID};
            
            vidObj{vRef} = VideoReader(vidPath);
            frmW = vidObj{vRef}.Width;
            video_init = read(vidObj{vRef},[1 10]);
            video_init = uint8(mean(squeeze(video_init(:,:,1,:)),3));
            % top part remapping prep
            frame_01_gray = video_init(1:frmW,:);
            [~,frm_graymap] = gray2ind(frame_01_gray,256);
            lowhigh_in = stretchlim(frame_01_gray,tol);
            lowhigh_in(1) = 0.02;
            frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],gammaAdj);
            frm_remapTB{vRef,1} = uint8(frm_remap(:,1).*255);
            % bottom part remapping prep
            frame_01_gray = video_init(end-frmW+1:end,:);
            [~,frm_graymap] = gray2ind(frame_01_gray,256);
            lowhigh_in = stretchlim(frame_01_gray,tol);
            lowhigh_in(1) = 0.02;
            frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],gammaAdj);
            frm_remapTB{vRef,2} = uint8(frm_remap(:,1).*255);
            
            analyzerRecord = load(analyzerPathList{vRef});
            dataname = fieldnames(analyzerRecord);
            analyzerRecord = analyzerRecord.(dataname{1});
%             xyThTop{iterM} = smooth(analyzerRecord.top_points_and_thetas{1}(:,1),256);
            xyThTop{vRef} = analyzerRecord.top_points_and_thetas{1};
            xyThBot{vRef} = analyzerRecord.bot_points_and_thetas{1};
            flyLength{vRef} = analyzerRecord.fly_length{1};
            finalFrm{vRef} = analyzerRecord.final_frame_tracked{1};
        end
        
        sizeRange = round([max(cell2mat(flyLength)) min(cell2mat(flyLength))]*2);
        destTheta = 90;
        
        [~,newOrder] = sort(cell2mat(finalFrm));
        vidReferenceVec = (1:vidCount);
        vidReferenceVec = vidReferenceVec(newOrder);
        savedPos = cell2mat(automatedAnnotations.montagePosition(vidList(vidReferenceVec)));
%         if ~isequal(montPos(:),savedPos(:))
            makeMonty = true;
%         end
        if ~makeMonty
            continue
        end
        if writeVid
            try
                writeObj = VideoWriter(destPath,'MPEG-4');
                disp(['writing to ' destPath])
            catch
                disp(['FAIL - couldn not write to ' destPath])
                continue
            end
            open(writeObj)
        end
        for iterF = 1:montFrmCt
            montyCell = cell(rowCt,colCt);
            %%
            for iterM = 1:vidCount
                
                vRef = vidReferenceVec(iterM);
                videoID = vidList{vRef};
                automatedAnnotations.montagePosition{videoID} = montPos(iterM,:);
                frmA = read(vidObj{vRef},frmRefs(iterF));
                inputImB = frmA(end-frmW+1:end,:,1);
                inputImB = intlut(inputImB,frm_remapTB{vRef,2});
                objSize = flyLength{vRef}*2;
                fillFlag = 2;
                origPos = xyThBot{vRef}(iterFops(1),1:2);
                origTheta = round(xyThBot{vRef}(iterFops(1),3)*(180/pi));
                if max(strcmp({'run042_pez3002_20140609_expt0019000006790129_vid0016',...
                        'run074_pez3004_20140612_expt0019000006790129_vid0003',...
                        'run031_pez3001_20140702_expt0019000010260129_vid0011',...
                        'run049_pez3003_20140505_expt0019000004280129_vid0012',...
                        'run069_pez3003_20140717_expt0019000013540129_vid0005'},videoID))
                    origTheta = origTheta+180;
                end
                outputImBot = flyRotate_and_center(inputImB,origPos,origTheta,destTheta,objSize,sizeRange,fillFlag);
                outputIm = outputImBot;
                montyCell{montPos(iterM,1),montPos(iterM,2)} = outputIm;
            end
            if iterM < maxFlies
                montyDiff = maxFlies-iterM;
                for iterFill = 1:montyDiff
                    montyCell{montPos(iterM+iterFill,1),montPos(iterM+iterFill,2)} = montyCell{1}.*0;
                end
            end
            montyFrm = cell2mat(montyCell);
             
            
%             drawnow
            %%
            smlDim = round(size(montyFrm)/4)*2;
            montyFrmSml = imresize(montyFrm,smlDim(1:2));
            if writeVid
                writeVideo(writeObj,montyFrmSml)
            else
                imshow(montyFrm)
            end
        end
        if writeVid
            close(writeObj)
        end
%         save(autoAnnotationsPath,'automatedAnnotations')
    end
end
end
