function manualAnnotations = fixManAnno(manualAnnotations,videoStatisticsMerged)


videoList = manualAnnotations.Properties.RowNames;
vars2check = {'frame_of_wing_movement','frame_of_leg_push','wing_down_stroke','frame_of_take_off'};
for iterV = 1:numel(videoList)
    videoID = videoList{iterV};
    frameRefcutrate = double(videoStatisticsMerged.cutrate10th_frame_reference{videoID});
    frameReffullrate = double(videoStatisticsMerged.supplement_frame_reference{videoID});
    
    if isempty(frameRefcutrate)&& isempty(frameReffullrate)
        frameRefcutrate = 1:videoStatisticsMerged.frame_count(videoID);
        frameReffullrate = 1:videoStatisticsMerged.frame_count(videoID).*10;
    end
    
    Y = (1:numel(frameRefcutrate));
    xi = (1:numel(frameRefcutrate)*10);
    yi = repmat(Y,10,1);
    yi = yi(:);
    [~,xSuppl] = ismember(frameReffullrate,xi);
    objRefVec = ones(1,numel(frameRefcutrate)*10);
    objRefVec(xSuppl) = 2;
    yi(xSuppl) = (1:numel(frameReffullrate));
    frmRefArrayGood = [xi(:) yi(:) objRefVec(:)];
    
    x = frameRefcutrate;
    yi = interp1(x,Y,xi,'nearest');
    yi(xSuppl) = (1:length(frameReffullrate));
    yi(isnan(yi)) = numel(frameRefcutrate);
    frmRefArrayBad = [xi(:),yi(:),objRefVec(:)];
    
    for iterVar = 1:numel(vars2check)
        foa = manualAnnotations.(vars2check{iterVar}){videoID};
        if isnan(foa), continue, end
        if isempty(foa), continue, end
        if foa == 0, continue, end
        badRefs = frmRefArrayBad(foa,:);
        if badRefs(3) == 2, continue, end
        goodRefs = frmRefArrayGood(foa,:);
        if badRefs(2) == goodRefs(2)
            testVec = frmRefArrayGood(:,2) == goodRefs(2) & frmRefArrayGood(:,3) == 1;
            newfoa = find(testVec,1,'last');
        elseif badRefs(2) == goodRefs(2)+1
            testRefs = frmRefArrayBad(foa+5,:);
            if testRefs(3) == 2
                for iterP = 1:5
                    newfoa = foa+iterP;
                    if frmRefArrayBad(newfoa,3) == 2
                        break
                    end
                end
                newfoa = foa+iterP;
            else
                testVec = frmRefArrayGood(:,2) == badRefs(2) & frmRefArrayGood(:,3) == 1;
                newfoa = find(testVec,1,'last');
            end
        else
            error('unknown manual annotations problem')
        end
        
        manualAnnotations.(vars2check{iterVar}){videoID} = newfoa;
    end
end


