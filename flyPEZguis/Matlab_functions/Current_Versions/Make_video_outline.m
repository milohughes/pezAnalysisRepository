function Make_video_outline 
    op_sys = system_dependent('getos');
    if contains(op_sys,'Windows')
        archDir = [filesep filesep 'dm11' filesep 'cardlab'];
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    data_path = [dm11Dir filesep 'Data_pez3000'];
    analysis_path = [dm11Dir filesep 'Data_pez3000_analyzed'];

    [~,localUserName] = dos('echo %USERNAME%');
    localUserName = localUserName(1:end-1);
    repositoryName = 'pezAnalysisRepository';
    repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
    subfun_dir = fullfile(repositoryDir,'pezProc_subfunctions');
    saved_var_dir = fullfile(repositoryDir,'pezProc_saved_variables');
    addpath(repositoryDir,subfun_dir,saved_var_dir)
    addpath(fullfile(repositoryDir,'Pez3000_Gui_folder','Matlab_functions','Support_Programs'))
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    exp_id = '0216000004301405';
     
    videoID = 'run002_pez3002_20191021_expt0216000004301405_vid0002';
    vid_name = videoID;
    vid_date = vid_name(16:23);
    vid_run = vid_name(1:23);        
    fullPath_parital = fullfile(data_path,filesep,vid_date,filesep,vid_run,filesep,[videoID,'.mp4']);
    destPath = ['C:\Users\BREADSP\Documents' filesep videoID];
    
    assess_table = load([analysis_path filesep exp_id filesep exp_id '_rawDataAssessment']);        
    assess_table = assess_table.assessTable;
    
    roi = assess_table(vid_name,:).Adjusted_ROI{1};

    writeObj = VideoWriter(destPath,'MPEG-4');
    writeObj.FrameRate = 5;    %slow video playback down to 10 frames per second  (default is 30)
    open(writeObj)

    montDims = [834 (384*2)];
%    baseFrame = uint8(zeros(fliplr(montDims)));
    baseFrame = uint8(zeros(montDims));
    frmFullA = repmat(baseFrame,[1,1,3]);

    vid_obj = VideoReader(fullPath_parital);
    cutRateOps = 1:10:(vid_obj.Duration * vid_obj.FrameRate);
    for iterF = cutRateOps
        frmA = read(vid_obj,iterF);
        fprintf('reading frame :: %4.0f\n',iterF);

        tI = log(double(frmA)+15);
        frmAdj = uint8(255*(tI/log(265)-log(15)/log(265)));
        [~,frm_graymap] = gray2ind(frmAdj,256);
        tol = [0 0.9999];
        gammaAdj = 0.75;
        lowhigh_in = stretchlim(frmAdj,tol);
        lowhigh_in(1) = 0.01;
        frm_remap = imadjust(frm_graymap,lowhigh_in,[0 1],gammaAdj);
        frm_remap = uint8(frm_remap(:,1).*255);
        frmA = intlut(frmAdj,frm_remap);
        
        frmFullA(1:832,1:384,:) = frmA(:,:,:);
                
%        [bw_top,bw_bot,h_fig] = segmentImage(frmA,roi);
        color_img = segmentImage(frmA,roi);
        frmFullA(1:832,385:(384+384),:) = color_img;
        
%         outline_img_1 = frmA(:,:,1);        outline_img_1(~bw_top) = 0;
%         outline_img_2 = frmA(:,:,2);        outline_img_2(~bw_bot) = 0;        
%         new_outline = zeros(size(frmA));
%         new_outline(:,:,1) = outline_img_1;
%         new_outline(:,:,2) = outline_img_2;
%         frmFullA(1:832,385:(384+384),:) = new_outline;
%         
%         h_groups = get(get(h_fig,'Children'),'Children');
%         top_outline = zeros(size(frmA));
%         top_outline = add_lines(top_outline,get(h_groups(1),'Children'),2);
%         top_outline = add_lines(top_outline,get(h_groups(2),'Children'),1);
%         
%         [~,max_loc_y] = max(sum(outline_img_1,2));        [~,max_loc_x] = max(sum(outline_img_1,1));
%         top_cm = [max_loc_x,max_loc_y];
%         
%         [~,max_loc_y] = max(sum(outline_img_2,2));        [~,max_loc_x] = max(sum(outline_img_2,1));
%         bot_cm = [max_loc_x,max_loc_y];
%         
%         for iterX = -5:1:5
%             top_outline(round(bot_cm(2)+iterX),round(bot_cm(1)+iterX),2) = 256;
%             top_outline(round(bot_cm(2)-iterX),round(bot_cm(1)+iterX),2) = 256;
%             
%             top_outline(round(top_cm(2)+iterX),round(top_cm(1)+iterX),1) = 256;
%             top_outline(round(top_cm(2)-iterX),round(top_cm(1)+iterX),1) = 256;
%         end
%         close(h_fig)
        
%        frmFullA(1:832,((2*384)+1):end,:) = top_outline;

        frmFullA(1:832,385,:) = ones(832,1,3)*256;
        frmFullA(roi(8,2),1:(384*2),:) = ones(1,(384*2),3)*256;
%        frmFullA(1:832,(385+384),:) = ones(832,1,3)*256;        
                
        writeVideo(writeObj,frmFullA)
    end
    close(writeObj)
end
%function [bw_top,bw_bot,h_fig] = segmentImage(RGB,roi)
function B = segmentImage(RGB,roi)
    %segmentImage Segment image using auto-generated code from imageSegmenter App
    %  [BW,MASKEDIMAGE] = segmentImage(RGB) segments image RGB using
    %  auto-generated code from the imageSegmenter App. The final segmentation
    %  is returned in BW, and a masked image is returned in MASKEDIMAGE.

    % Auto-generated by imageSegmenter app on 21-Oct-2019
    %----------------------------------------------------
    
    top_view = RGB(1:max(roi(7,2),roi(8,2)),:,:);
    [L,Centers] = imsegkmeans(RGB,3,'NumAttempts',10,'MaxIterations',500);
    B = labeloverlay(RGB,L,'Transparency',.75);
%    imshow(B(:,:,:))

    top_view = find(RGB(1:max(roi(7,2),roi(8,2)),:,:) == max(max(max((RGB(1:max(roi(7,2),roi(8,2)),:,:))))));   
    bot_view = find(RGB(roi(1,2):roi(2,2),:,1) == max(max(max((RGB(roi(1,2):roi(2,2),:,1))))))+384*(roi(1,2)-1);

    % Convert RGB image into L*a*b* color space.
    X = rgb2lab(RGB);

    % Graph Cut
    foregroundInd = top_view;
    backgroundInd = 1 ;
    
    

%    L = superpixels(X,849,'IsInputLab',true);
    L = superpixels(X,1647,'IsInputLab',true);

    % Convert L*a*b* range to [0 1]
    scaledX = X;
    scaledX(:,:,1) = X(:,:,1) / 100;
    scaledX(:,:,2:3) = (X(:,:,2:3) + 100) / 200;
    BW = lazysnapping(scaledX,L,foregroundInd,backgroundInd);

    % Create masked image.
    maskedImage = RGB;
    maskedImage(repmat(~BW,[1 1 3])) = 0;

    mask_top = false(size(maskedImage(:,:,1)));
    mask_bot = false(size(maskedImage(:,:,1)));
    mask_top(1:384,1:384) = true;
    mask_bot(roi(1,2):roi(2,2),roi(1,1):roi(3,1)) = true;
    maskedImage(min(roi(7,2),roi(8,2)):1:roi(1,2),1:384,:) = 0;     %zero out data between roi views
    
%     bw_top = activecontour(maskedImage(:,:,1), mask_top, 1000, 'Chan-Vese');
%     bw_bot = activecontour(maskedImage(:,:,1), mask_bot, 1000, 'Chan-Vese');
%     
%     h_fig = figure;
% %    figure; imshow(RGB)
%     
%     visboundaries(gca,bw_top,'color',rgb('red'),'LineStyle','-');
%     set(gca,'nextplot','add')
%     visboundaries(gca,bw_bot,'color',rgb('green'),'LineStyle','-');
end
function top_outline = add_lines(top_outline,curr_line,indx)
    top_lines_1_x = get(curr_line(1),'XData');  top_lines_1_y = get(curr_line(1),'YData');
    top_lines_2_x = get(curr_line(2),'XData');  top_lines_2_y = get(curr_line(2),'YData');
        
    for iterL = 1:length(top_lines_1_y)
        if ~isnan(top_lines_1_y(iterL))
            top_outline(top_lines_1_y(iterL),top_lines_1_x(iterL),indx) = top_outline(top_lines_1_y(iterL),top_lines_1_x(iterL),indx) + 256;
        end
    end

    for iterL = 1:length(top_lines_2_y)
        if ~isnan(top_lines_2_y(iterL))
            top_outline(top_lines_2_y(iterL),top_lines_2_x(iterL),indx) = top_outline(top_lines_2_y(iterL),top_lines_2_x(iterL),indx) + 256;
        end
    end
end