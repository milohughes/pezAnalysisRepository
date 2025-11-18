function loomingStimulusScrambler

% LOAD IN STIMULUS YOU ARE WORKING WITH HERE
load("Z:\hhmiData\dm11\cardlab\pez3000_variables\...")

% SET BASED ON SETTINGS BELOW
scrambleOp = 1;

%%%%%%%%%%%%%%%%%%%%%% USABLE ON ANY VISUAL STIMULUS %%%%%%%%%%%%%%%%%%%%%%

%1 - average light intensity of entire dome
%2 - scramble light intensity of entire dome (120 fps)
%3 - scramble light intensity of entire dome (360 fps)

%%%%%%%%%%%%%%%%%%%%% ONLY USE THE FOLLOWING ON LOOMS %%%%%%%%%%%%%%%%%%%%%

%4 - average light intensity of loom final size
%5 - scramble light intensity of loom final size (120 fps)
%6 - scramble light intensity of loom final size (360 fps)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if scrambleOp == 1
    % AVERAGE IMAGE RESET
    stimulusStruct.imgReset(:,:,1) = ...
        round(mean(stimulusStruct.imgReset(:,:,1),"all"));
    stimulusStruct.imgReset(:,:,2) = ...
        round(mean(stimulusStruct.imgReset(:,:,2),"all"));
    stimulusStruct.imgReset(:,:,3) = ...
        round(mean(stimulusStruct.imgReset(:,:,3),"all"));
    
    % AVERAGE IMAGE FIN
    stimulusStruct.imgFin(:,:,1) = ...
        round(mean(stimulusStruct.imgFin(:,:,1),"all"));
    stimulusStruct.imgFin(:,:,2) = ...
        round(mean(stimulusStruct.imgFin(:,:,2),"all"));
    stimulusStruct.imgFin(:,:,3) = ...
        round(mean(stimulusStruct.imgFin(:,:,3),"all"));
    
    % AVERAGE IMAGE CELL
    for i = 1:height(stimulusStruct.imgCell)
        stimulusStruct.imgCell{i}(:,:,1) = ...
            round(mean(stimulusStruct.imgCell{i}(:,:,1),"all"));
        stimulusStruct.imgCell{i}(:,:,2) = ...
            round(mean(stimulusStruct.imgCell{i}(:,:,2),"all"));
        stimulusStruct.imgCell{i}(:,:,3) = ...
            round(mean(stimulusStruct.imgCell{i}(:,:,3),"all"));
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif scrambleOp == 2
    % SCRAMBLE IMAGE RESET
    hold_var = stimulusStruct.imgReset(:,:,1);
    hold_var = hold_var(randperm(numel(hold_var)));
    
    for i = 2:768
        hold_var(i,1:1024) = hold_var(1,(((i-1)*1024+1):(i*1024)));
    end
    
    hold_var = hold_var(:,1:1024);
    stimulusStruct.imgReset(:,:,1) = hold_var;
    stimulusStruct.imgReset(:,:,2) = hold_var;
    stimulusStruct.imgReset(:,:,3) = hold_var;

    % SCRAMBLE IMAGE FIN
    hold_var = stimulusStruct.imgFin(:,:,1);
    hold_var = hold_var(randperm(numel(hold_var)));
    
    for i = 2:768
        hold_var(i,1:1024) = hold_var(1,(((i-1)*1024+1):(i*1024)));
    end
    
    hold_var = hold_var(:,1:1024);
    stimulusStruct.imgFin(:,:,1) = hold_var;
    stimulusStruct.imgFin(:,:,2) = hold_var;
    stimulusStruct.imgFin(:,:,3) = hold_var;

    % SCRAMBLE IMAGE CELL
    for i = 1:height(stimulusStruct.imgCell)
        hold_var = stimulusStruct.imgCell{i}(:,:,1);
        hold_var = hold_var(randperm(numel(hold_var)));
        
        for j = 2:768
            hold_var(j,1:1024) = hold_var(1,(((j-1)*1024+1):(j*1024)));
        end
        
        hold_var = hold_var(:,1:1024);
        stimulusStruct.imgCell{i}(:,:,1) = hold_var;
        stimulusStruct.imgCell{i}(:,:,2) = hold_var;
        stimulusStruct.imgCell{i}(:,:,3) = hold_var;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif scrambleOp == 3
    %%% SCRAMBLE IMAGE RESET %%%
    
    % first value (i.e R of RGB)
    hold_var = stimulusStruct.imgReset(:,:,1);
    hold_var = hold_var(randperm(numel(hold_var)));
    
    for i = 2:768
        hold_var(i,1:1024) = hold_var(1,(((i-1)*1024+1):(i*1024)));
    end
    
    hold_var = hold_var(:,1:1024);
    stimulusStruct.imgReset(:,:,1) = hold_var;
    
    % second value (i.e G of RGB)
    hold_var = stimulusStruct.imgReset(:,:,2);
    hold_var = hold_var(randperm(numel(hold_var)));
    
    for i = 2:768
        hold_var(i,1:1024) = hold_var(1,(((i-1)*1024+1):(i*1024)));
    end
    
    hold_var = hold_var(:,1:1024);
    stimulusStruct.imgReset(:,:,2) = hold_var;
    
    % third value (i.e B of RGB)
    hold_var = stimulusStruct.imgReset(:,:,3);
    hold_var = hold_var(randperm(numel(hold_var)));
    
    for i = 2:768
        hold_var(i,1:1024) = hold_var(1,(((i-1)*1024+1):(i*1024)));
    end
    
    hold_var = hold_var(:,1:1024);
    stimulusStruct.imgReset(:,:,3) = hold_var;
    
    %%% SCRAMBLE IMAGE FIN %%%
    
    % first value (i.e R of RGB)
    hold_var = stimulusStruct.imgFin(:,:,1);
    hold_var = hold_var(randperm(numel(hold_var)));
    
    for i = 2:768
        hold_var(i,1:1024) = hold_var(1,(((i-1)*1024+1):(i*1024)));
    end
    
    hold_var = hold_var(:,1:1024);
    stimulusStruct.imgFin(:,:,1) = hold_var;
    
    % second value (i.e G of RGB)
    hold_var = stimulusStruct.imgFin(:,:,2);
    hold_var = hold_var(randperm(numel(hold_var)));
    
    for i = 2:768
        hold_var(i,1:1024) = hold_var(1,(((i-1)*1024+1):(i*1024)));
    end
    
    hold_var = hold_var(:,1:1024);
    stimulusStruct.imgFin(:,:,2) = hold_var;
    
    % third value (i.e B of RGB)
    hold_var = stimulusStruct.imgFin(:,:,3);
    hold_var = hold_var(randperm(numel(hold_var)));
    
    for i = 2:768
        hold_var(i,1:1024) = hold_var(1,(((i-1)*1024+1):(i*1024)));
    end
    
    hold_var = hold_var(:,1:1024);
    stimulusStruct.imgFin(:,:,3) = hold_var;
    
    %%% SCRAMBLE IMAGE CELL %%%
    for i = 1:height(stimulusStruct.imgCell)
        % first value (i.e R of RGB)
        disp(string(i))
        hold_var = stimulusStruct.imgCell{i}(:,:,1);
        hold_var = hold_var(randperm(numel(hold_var)));
        
        for j = 2:768
            hold_var(j,1:1024) = hold_var(1,(((j-1)*1024+1):(j*1024)));
        end
        
        hold_var = hold_var(:,1:1024);
        stimulusStruct.imgCell{i}(:,:,1) = hold_var;
    
        % second value (i.e G of RGB)
        hold_var = stimulusStruct.imgCell{i}(:,:,2);
        hold_var = hold_var(randperm(numel(hold_var)));
        
        for j = 2:768
            hold_var(j,1:1024) = hold_var(1,(((j-1)*1024+1):(j*1024)));
        end
        
        hold_var = hold_var(:,1:1024);
        stimulusStruct.imgCell{i}(:,:,2) = hold_var;
    
        % third value (i.e B of RGB)
        hold_var = stimulusStruct.imgCell{i}(:,:,3);
        hold_var = hold_var(randperm(numel(hold_var)));
        
        for j = 2:768
            hold_var(j,1:1024) = hold_var(1,(((j-1)*1024+1):(j*1024)));
        end
        
        hold_var = hold_var(:,1:1024);
        stimulusStruct.imgCell{i}(:,:,3) = hold_var;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif scrambleOp == 4
    % FIND BACKGROUND, FOREGROUND, VALUES AND LOCATIONS
    h_idx = height(stimulusStruct.imgReset);
    bckgrd_val = stimulusStruct.imgReset(1,1,1);
    bckgrd_flg = true;
    bckgrd_fin_start = 1;

    for i = 1:h_idx
        if ((stimulusStruct.imgFin(i,1,1)) == bckgrd_val) && bckgrd_flg
            bckgrd_fin_start = i;
            bckgrd_flg = false;
        end
    end
    
    % AVERAGE EVERY FRAME
    bckgrd_start = 1;
    for i = 1:height(stimulusStruct.imgCell)
        for j = 1:3
            for k = 1:h_idx
                bckgrd_flg = true;
                if ((stimulusStruct.imgCell{i}(k,1,j)) == bckgrd_val) && bckgrd_flg
                    bckgrd_start = k;
                    bckgrd_flg = false;
                end
            end

            t_imgCell = stimulusStruct.imgCell{i}(1:(bckgrd_start-1),:,j);
            t_imgCell((bckgrd_start):(bckgrd_fin_start-1),:) = bckgrd_val;
            t_imgCell(:,:) = round(mean(t_imgCell,"all"));
            t_imgCell(bckgrd_fin_start:h_idx,:) = bckgrd_val;
            stimulusStruct.imgCell{i}(:,:,j) = t_imgCell;
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif scrambleOp == 5
    % FIND BACKGROUND, FOREGROUND, VALUES AND LOCATIONS
    h_idx = height(stimulusStruct.imgReset);
    bckgrd_val = stimulusStruct.imgReset(1,1,1);
    bckgrd_flg = true;
    bckgrd_fin_start = 1;
    
    for i = 1:h_idx
        if ((stimulusStruct.imgFin(i,1,1)) == bckgrd_val) && bckgrd_flg
            bckgrd_fin_start = i;
            bckgrd_flg = false;
        end
    end
    
    % SCRAMBLE IMAGE CELL
    bckgrd_start = 1;
    for i = 1:height(stimulusStruct.imgCell)
        bckgrd_flg = true;
        for j = 1:h_idx
            if ((stimulusStruct.imgCell{i}(j,1,1)) == bckgrd_val) && bckgrd_flg
                bckgrd_start = j;
                bckgrd_flg = false;
            end
        end
    
        t_imgCell = stimulusStruct.imgCell{i}(1:(bckgrd_start-1),:,1);
        t_imgCell((bckgrd_start):(bckgrd_fin_start-1),:) = bckgrd_val;
        t_imgCell = t_imgCell(randperm(numel(t_imgCell)));
    
        for j = 2:(bckgrd_fin_start - 1)
            t_imgCell(j,1:1024) = t_imgCell(1,(((j-1)*1024+1):(j*1024)));
        end
    
        t_imgCell = t_imgCell(:,1:1024);
        t_imgCell(bckgrd_fin_start:h_idx,:) = bckgrd_val;
        stimulusStruct.imgCell{i}(:,:,1) = t_imgCell;
        stimulusStruct.imgCell{i}(:,:,2) = t_imgCell;
        stimulusStruct.imgCell{i}(:,:,3) = t_imgCell;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif scrambleOp == 6
    % FIND BACKGROUND, FOREGROUND, VALUES AND LOCATIONS
    h_idx = height(stimulusStruct.imgReset);
    bckgrd_val = stimulusStruct.imgReset(1,1,1);
    bckgrd_flg = true;
    bckgrd_fin_start = 1;
    
    for i = 1:h_idx
        if ((stimulusStruct.imgFin(i,1,1)) == bckgrd_val) && bckgrd_flg
            bckgrd_fin_start = i;
            bckgrd_flg = false;
        end
    end
    
    % SCRAMBLE IMAGE CELL
    bckgrd_start = 1;
    for i = 1:height(stimulusStruct.imgCell)
        for j = 1:3
            bckgrd_flg = true;
            for k = 1:h_idx
                if ((stimulusStruct.imgCell{i}(k,1,j)) == bckgrd_val) && bckgrd_flg
                    bckgrd_start = k;
                    bckgrd_flg = false;
                end
            end
    
            t_imgCell = stimulusStruct.imgCell{i}(1:(bckgrd_start-1),:,j);
            t_imgCell((bckgrd_start):(bckgrd_fin_start-1),:) = bckgrd_val;
            t_imgCell = t_imgCell(randperm(numel(t_imgCell)));
    
            for k = 2:(bckgrd_fin_start - 1)
                t_imgCell(k,1:1024) = t_imgCell(1,(((k-1)*1024+1):(k*1024)));
            end
    
            t_imgCell = t_imgCell(:,1:1024);
            t_imgCell(bckgrd_fin_start:h_idx,:) = bckgrd_val;
            stimulusStruct.imgCell{i}(:,:,j) = t_imgCell;
        end
    end
end
%%%%%% NOW MANUALLY SAVE THE STIMULUS STRUCTURE WHEREVER YOU WANT IT %%%%%%
keyboard;
% AND YOU'RE DONE! :)
end