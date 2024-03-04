function udpInitializationListener_v2

%%%%% computer and directory variables and information
[~,localUserName] = dos('echo %USERNAME%');
localUserName = localUserName(1:end-1);
repositoryName = 'pezAnalysisRepository';
repositoryDir = fullfile('C:','Users',localUserName,'Documents',repositoryName);
fileDir = fscanf(fopen(fullfile(repositoryDir,'flyPEZanalysis','pezFilePath.txt')),'%s');
variablesDir = fullfile(fileDir,'pez3000_variables');

%[~, comp_name] = system('hostname');
comp_name = getenv('COMPUTERNAME');
%comp_name = comp_name(1:end-1); %Remove trailing character.
compDataPath = fullfile(variablesDir,'computer_info.xlsx');
compData = dataset('XLSFile',compDataPath);
compRef = find(strcmp(compData.stimulus_computer_name,comp_name));
if isempty(compRef)
    disp('computer not valid')
    return
end
pezName = ['pez' num2str(compData.pez_reference(compRef))];
host = compData.control_computer_IP{compRef};
varName = [pezName '_stimuliVars.mat'];
varPath = fullfile(variablesDir,varName);
imReadPath = fullfile(variablesDir,[pezName '_im2show.tif']);
port = 21566;
packetlength = 50;
stimStruct = [];
stimTrigStruct = [];
stimTrigStruct2 = [];
ellovervee = 40;
aziOffVal = 0;
eleVal = 45;
radiusBegin = 10;
radiusEnd = 180;
visParams = struct('ellovervee',ellovervee,'azimuth',aziOffVal,'elevation',...
    eleVal,'radiusbegin',radiusBegin,'radiusend',radiusEnd);

waitdur = 3000;
tStim = timer('TimerFcn',@stimFun,'ExecutionMode','fixedRate',...
    'Period',waitdur/1000,'StartDelay',0.1);
start(tStim)
disp('upd initialized')
disp(['timers counted: ' num2str(numel(timerfindall))])

    function stimFun(~,~)
        try
            mssgA = judp('receive',port,packetlength,waitdur);
            stop(tStim)
            try
                stimRead(mssgA')
            catch ME
                judp('send',port, host,int8('error'))
                getReport(ME)
            end
            start(tStim)
        catch
            drawnow
        end
    end
    function closeFun(~,~)
        ShowCursor;
        sca
        stop(tStim)
        delete(tStim)
        disp('visual stimulus listener stopped')
    end
    function stimRead(mssgA)
        mssgCase = double(mssgA(1));
        switch mssgCase
            case 0
                stimStruct = initializeVisualStimulusGeneralUDP_brighter;
                java.lang.Thread.sleep(1500);
                if ~isstruct(stimStruct)
                    judp('send',port, host,int8('error'))
                else
                    judp('send',port, host,int8('success'))
                    HideCursor
                end
            case 1
                
            case 2
                mssgInfo = char(mssgA(2:end));
                mssgCell = strsplit(mssgInfo,';');
                stimTrigStruct(1).aziVal = str2double(mssgCell{1});
                stimTrigStruct(1).eleVal = str2double(mssgCell{2});
                judp('send',port, host,int8('start stim'))
                [missedFrames,whiteCt] = presentGeneralStimulusUDP_offaxis2(stimTrigStruct2);
                rtrnMssg = [num2str(missedFrames),';',num2str(whiteCt)];
                judp('send',port,host,int8(rtrnMssg))
                [stimTrigStruct2] = presentGeneralStimulusUDP_offaxis(stimTrigStruct);
            case 3
                mssgInfo = char(mssgA(2:end));
                stimTrigStruct = initializeFramesFromFileUDP(stimStruct,mssgInfo);
                if isfield(stimTrigStruct,'stimAzi')
                    [stimTrigStruct2] = presentGeneralStimulusUDP_offaxis(stimTrigStruct);
                end
                stimdurstr = num2str(round(stimTrigStruct.stimTotalDuration));
                judp('send',port,host,int8(stimdurstr))
            case 4
                mssgInfo = char(mssgA(2:end));
                mssgCell = strsplit(mssgInfo,';');
                stimTrigStruct(1).aziVal = str2double(mssgCell{1});
                stimTrigStruct(1).eleVal = str2double(mssgCell{2});
                if length(mssgCell) == 4
                    stimTrigStruct(1).aziVal2 = str2double(mssgCell{3});
                    stimTrigStruct(1).eleVal2 = str2double(mssgCell{4});
                end
                if isfield(stimTrigStruct,'flipReference')
                    [missedFrames,whiteCt] = presentGeneralStimulusUDP_flipRef(stimTrigStruct);
                elseif isfield(stimTrigStruct,'numLoops')
                    [missedFrames,whiteCt] = presentGeneralStimulusUDP_multiLoop(stimTrigStruct);
                else
                    [missedFrames,whiteCt] = presentGeneralStimulusUDP(stimTrigStruct);
                end
                rtrnMssg = [num2str(missedFrames),';',num2str(whiteCt)];
                judp('send',port,host,int8(rtrnMssg))
            case 5
                stimTrigStruct = load(varPath);
                window = simpleVisStimInitial;
                if window == 0
                    judp('send',port, host,int8('error'))
                else
                    stimTrigStruct.window = window;
                    judp('send',port, host,int8('success'))
                end
                fullOffIm = uint8(stimTrigStruct.gainMatrix.*0);
                Screen(stimTrigStruct.window,'PutImage',fullOffIm);
                Screen(stimTrigStruct.window,'Flip');
            case 6
                Screen(stimTrigStruct.window,'PutImage',stimTrigStruct.crosshairsIm);
                Screen(stimTrigStruct.window,'Flip');
            case 7
                Screen(stimTrigStruct.window,'PutImage',stimTrigStruct.calibImB);
                Screen(stimTrigStruct.window,'Flip');
            case 8
                Screen(stimTrigStruct.window,'PutImage',stimTrigStruct.gridIm);
                Screen(stimTrigStruct.window,'Flip');
            case 9
                fullOnIm = uint8(stimTrigStruct.gainMatrix.*255);
                Screen(stimTrigStruct.window,'PutImage',fullOnIm);
                Screen(stimTrigStruct.window,'Flip');
            case 10
                fullOffIm = uint8(stimTrigStruct.gainMatrix.*0);
                Screen(stimTrigStruct.window,'PutImage',fullOffIm);
                Screen(stimTrigStruct.window,'Flip');
            case 11
                fullOffIm = uint8(stimTrigStruct.gainMatrix.*0);
                Screen(stimTrigStruct.window,'PutImage',fullOffIm);
                Screen(stimTrigStruct.window,'Flip');
                RGBtesting
                Screen(stimTrigStruct.window,'PutImage',fullOffIm);
                Screen(stimTrigStruct.window,'Flip');
            case 12
                mssgInfo = char(mssgA(2:end));
                mssgCell = strsplit(mssgInfo,';');
                stimTrigStruct(1).aziVal = str2double(mssgCell{1});
                stimTrigStruct(1).eleVal = str2double(mssgCell{2});
                diskSizeMeasurement(stimTrigStruct,visParams);
            case 50 % azimuth lines
                Screen(stimTrigStruct.window,'PutImage',stimTrigStruct.vertLinesIm);
                Screen(stimTrigStruct.window,'Flip');
            case 51 % elevation lines
                latsOnlyIm = stimTrigStruct.latsOnlyIm;
                latsOnlyIm = repmat(uint8(latsOnlyIm.*255),[1 1 3]);
                Screen(stimTrigStruct.window,'PutImage',latsOnlyIm);
                Screen(stimTrigStruct.window,'Flip');
            case 52 % full reflected projection
                shaderBot = stimTrigStruct.shaderBot;
                shaderBot(shaderBot > 0) = 1;
                shaderBot = repmat(uint8(shaderBot.*255),[1 1 3]);
                Screen(stimTrigStruct.window,'PutImage',shaderBot);
                Screen(stimTrigStruct.window,'Flip');
            case 53 % full direct projection
                shaderTop = stimTrigStruct.shaderTop;
                shaderTop(shaderTop > 0) = 1;
                shaderTop = repmat(uint8(shaderTop.*255),[1 1 3]);
                Screen(stimTrigStruct.window,'PutImage',shaderTop);
                Screen(stimTrigStruct.window,'Flip');
            case 54 % image from set file
                fileIm = imread(imReadPath);
                if isa(fileIm,'double')
                    fileIm = repmat(uint8(fileIm.*255),[1 1 3]);
                end
                Screen(stimTrigStruct.window,'PutImage',fileIm);
                Screen(stimTrigStruct.window,'Flip');
            case 86
                ShowCursor;
                sca
                PsychStartup
            case 99
                tStim.TimerFcn = @closeFun;
            otherwise
        end
    end

    function window = simpleVisStimInitial
        AssertOpenGL;
     %   Screen('Preference','Verbosity',2);
        if ~isempty(Screen('Windows')),Screen('CloseAll'),end
        % Select display with max id for our onscreen window:
        screenidList = Screen('Screens');
        for iterL = screenidList
            [width,~] = Screen('WindowSize', iterL);
            if width == 1024
                screenid = iterL;
            end
        end
        [width,~] = Screen('WindowSize', screenid);%1024x768, old was 1280x720
        if width ~= 1024
            disp('screen size error')
            window = 0;
        else
            window = Screen(screenid,'OpenWindow');
            HideCursor
        end
    end

    function RGBtesting
        win = stimTrigStruct.window;
        stimRefROI = stimTrigStruct.stimRefROI;
        stimIm = {uint8(cat(3,zeros(5)+255,zeros(5),zeros(5)))
            uint8(cat(3,zeros(5),zeros(5)+255,zeros(5)))
            uint8(cat(3,zeros(5),zeros(5),zeros(5)+255))};
        stimImBlack = uint8(cat(3,zeros(3),zeros(3),zeros(3)));
        stimtexBlack = Screen('MakeTexture',win,stimImBlack);
        stimImWhite = uint8(cat(3,zeros(3),zeros(3),zeros(3))+255);
        stimtexWhite = Screen('MakeTexture',win,stimImWhite);
        Screen('DrawTexture',win,stimtexWhite,[],stimRefROI);
        Screen('Flip',win);
        for iterRGB = 1:3
            stimtex = Screen('MakeTexture',win,stimIm{iterRGB});
            Screen('DrawTexture',win,stimtex,[],stimRefROI);
            Screen('Flip',win);
            Screen('DrawTexture',win,stimtexWhite,[],stimRefROI);
            Screen('Flip',win);
        end
        Screen('DrawTexture',win,stimtexBlack,[],stimRefROI);
        Screen('Flip',win);
        Screen('Close')
    end

end