function udpInitializationListener

[~, comp_name] = system('hostname');
comp_name = comp_name(1:end-1); %Remove trailing character.
switch comp_name
        %%% pez3001 %%%
    case 'peekm-ww3'
        host = '169.254.190.99';
        
        %%% pez3002 %%%
    case 'cardlab-ww5'
        host = '169.254.59.249';
        
        %%% pez3003 %%%
    case 'CARDG-WW9'
        host = '169.254.43.17';
    otherwise
        return
end
port = 21566;
packetlength = 50;
stimStruct = [];
stimTrigStruct = [];
ellovervee = 40;
aziOffVal = 0;
eleVal = 45;
radiusBegin = 10;
radiusEnd = 180;
visParams = struct('ellovervee',ellovervee,'azimuth',aziOffVal,'elevation',...
    eleVal,'radiusbegin',radiusBegin,'radiusend',radiusEnd);

tInit = timer('TimerFcn',@initFun,'ExecutionMode','fixedRate',...
    'Period',5,'StartDelay',0.1);
tStim = timer('TimerFcn',@stimFun,'ExecutionMode','fixedRate',...
    'Period',5,'StartDelay',0.1);
start(tInit)
disp('upd initialized')
disp(['timers counted: ' num2str(numel(timerfindall))])
    function initFun(~,~)
        try
            mssg = judp('receive',port,packetlength,5000)';
        catch
            return
        end
        mssg = char(mssg);
        if strcmp(mssg,'stop')
            stop(tInit)
            return
        elseif strcmp(mssg,'start')
            try
                judp('send',port, host,int8('success'))
                stop(tInit)
                disp('visual stimulus listener started')
                start(tStim)
            catch ME
                getReport(ME)
                return
            end
        elseif strcmp(mssg,char(99))
            initFun([],[])
        end
        drawnow
    end

    function stimFun(~,~)
        try
            mssgA = judp('receive',port,packetlength,5000);
            stimRead(mssgA)
        catch
%             judp('send',port, host,int8('error'))
            return
        end
    end
    function stimRead(mssgA)
        if strcmp(char(mssgA),'start')
            judp('send',port, host,int8('success'))
            stimFun([],[])
            return
        end
        if numel(mssgA) ~= 1, stimFun([],[]), return, end
        mssgA = double(mssgA);
        switch mssgA
            case 0
                stimStruct = initializeVisualStimulusGeneralUDP_brighter;
                java.lang.Thread.sleep(1500);
%                 disp(['init general complete ',datestr(clock,'MMSSFFF')])
                if ~isstruct(stimStruct)
                    judp('send',port, host,int8('error'))
                else
                    judp('send',port, host,int8('success'))
                    HideCursor
                end
            case 1
                stimStruct = initializeVisualStimulusGeneralUDP;
                java.lang.Thread.sleep(1500);
%                 disp(['init general complete ',datestr(clock,'MMSSFFF')])
                if ~isstruct(stimStruct)
                    judp('send',port, host,int8('error'))
                else
                    judp('send',port, host,int8('success'))
                    HideCursor
                end
            case 2
                varDest = 'C:\Users\cardlab\Documents\Photron_flyPez3000\visual_stimuli';
                varName = [comp_name '_stimuliVars.mat'];
                varPath = fullfile(varDest,varName);
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
            case 3
                try
                mssg = char(judp('receive',port,packetlength,5000));
                mssgCell = strsplit(mssg',';');
                visParams.ellovervee = str2double(mssgCell{1});
                visParams.radiusbegin = str2double(mssgCell{2});
                visParams.radiusend = str2double(mssgCell{3});
                
%                 disp(['initBonW',datestr(clock,'MMSSFFF')])
                stimTrigStruct = initializeBlackDiskOnWhiteUDP(stimStruct,visParams);
                stimdurstr = num2str(round(stimTrigStruct.stimTotalDuration));
                for iterSend = 1:3
                    judp('send',port,host,int8(stimdurstr))
%                     disp(['message sent',datestr(clock,'MMSSFFF')])
                    java.lang.Thread.sleep(500);
                end
                catch ME
                    getReport(ME)
                    Screen('CloseAll');
                    Priority(oldPriority);
                    psychrethrow(psychlasterror);
                end
            case 4
                try
                    mssg = char(judp('receive',port,packetlength,5000));                    catch
                    stimFun([],[])
                    return
                end
                stop(tStim)
                mssgCell = strsplit(mssg',';');
                stimTrigStruct(1).aziVal = str2double(mssgCell{1});
                stimTrigStruct(1).eleVal = str2double(mssgCell{2});
                [missedFrames,whiteCt] = presentDiskStimulusUDP(stimTrigStruct);
                rtrnMssg = [num2str(missedFrames),';',num2str(whiteCt)];
                for iterSend = 1:3
                    judp('send',port,host,int8(rtrnMssg))
                    java.lang.Thread.sleep(500);
                end
                start(tStim)
            case 5
                Screen(stimTrigStruct.window,'PutImage',stimTrigStruct.crosshairsIm);
                Screen(stimTrigStruct.window,'Flip');
            case 6
                Screen(stimTrigStruct.window,'PutImage',stimTrigStruct.calibImB);
                Screen(stimTrigStruct.window,'Flip');
            case 7
                Screen(stimTrigStruct.window,'PutImage',stimTrigStruct.gridIm);
                Screen(stimTrigStruct.window,'Flip');
            case 8
                fullOnIm = uint8(stimTrigStruct.gainMatrix.*255);
                Screen(stimTrigStruct.window,'PutImage',fullOnIm);
                Screen(stimTrigStruct.window,'Flip');
            case 9
                fullOffIm = uint8(stimTrigStruct.gainMatrix.*0);
                Screen(stimTrigStruct.window,'PutImage',fullOffIm);
                Screen(stimTrigStruct.window,'Flip');
            case 10
                fullOffIm = uint8(stimTrigStruct.gainMatrix.*0);
                Screen(stimTrigStruct.window,'PutImage',fullOffIm);
                Screen(stimTrigStruct.window,'Flip');
                RGBtesting
                Screen(stimTrigStruct.window,'PutImage',fullOffIm);
                Screen(stimTrigStruct.window,'Flip');
            case 11
                try
                    mssg = char(judp('receive',port,packetlength,5000));
                catch
                    stimFun([],[])
                    return
                end
                stop(tStim)
                mssgCell = strsplit(mssg',';');
                stimTrigStruct(1).aziVal = str2double(mssgCell{1});
                stimTrigStruct(1).eleVal = str2double(mssgCell{2});
                diskSizeMeasurement(stimTrigStruct,visParams);
                start(tStim)
            case 99
                ShowCursor;
                sca
                disp('visual stimulus listener stopped')
                stop(tStim)
                start(tInit)
                return
            otherwise
                stimFun([],[])
                return
        end
        drawnow
    end

    function window = simpleVisStimInitial
        AssertOpenGL;
        if ~isempty(Screen('Windows')),Screen('CloseAll'),end
        % Select display with max id for our onscreen window:
        screenid = max(Screen('Screens'));
        [width,~]=Screen('WindowSize', screenid);%1024x768, old was 1280x720
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