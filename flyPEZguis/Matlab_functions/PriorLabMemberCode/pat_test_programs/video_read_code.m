%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% vidName is name of the video you are loading
        vid_name = vidName{1};
        vid_date = vid_name(16:23);
        vid_run = vid_name(1:23);        
        data_path = '\\DM11\cardlab\Data_pez3000'; 
        fullPath_parital = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,[vidName{1},'.mp4']);
        fullPath_supplement = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,'highSpeedSupplement',[vidName{1},'_supplement.mp4']);

        
        vidObj_partail = VideoReader(fullPath_parital);
        try
            vidObj_supplement = VideoReader(fullPath_supplement);
            vidObjCell{1} = vidObj_partail;
            vidObjCell{2} = vidObj_supplement;
        catch
            vidObjCell{1} = vidObj_partail;
            vidObjCell{2} =  vidObj_partail;
            
        end
        vidWidth = vidObj_partail.Width;
        vidHeight = vidObj_partail.Height;
        vidFrames_partial = vidObj_partail.NumberOfFrames; %#ok<VIDREAD>
        
        frameRefcutrate = double(temp_vidStats.cutrate10th_frame_reference{1});
        frameReffullrate = double(temp_vidStats.supplement_frame_reference{1});
        Y = (1:numel(frameRefcutrate));
        x = frameRefcutrate;
        xi = (1:(vidFrames_partial*10));
        yi = repmat(Y,10,1);
        yi = yi(:);
        [~,xSuppl] = ismember(frameReffullrate,xi);
        objRefVec = ones(1,(vidFrames_partial*10));
        objRefVec(xSuppl) = 2;
        yi(xSuppl) = (1:length(frameReffullrate));
        
        frameReferenceMesh = [xi(:),yi(:),objRefVec(:)];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        frmData = read(vidObjCell{frameReferenceMesh(frmNum,3)},frameReferenceMesh(frmNum,2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% frameReferenceMesh is an Nx3 matrix where N is number of frames in the video
%% column 1 is frame number
%% column 2 is frame of either supplment or curate vector
%% column 3 is which vector to load from 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% vidObjCell is a cell array of video reader objects for both partial and supplement

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% frmData is the image of the video calculated for the frame frnNum
