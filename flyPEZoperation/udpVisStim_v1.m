function udpVisStim_v1

ellovervee = 40;
aziOffVal = 0;
eleVal = 45;
radiusBegin = 10;
radiusEnd = 180;
visParams = struct('ellovervee',ellovervee,'azimuth',aziOffVal,'elevation',...
    eleVal,'radiusbegin',radiusBegin,'radiusend',radiusEnd);
% computer-specific information
[~, comp_name] = system('hostname');
comp_name = comp_name(1:end-1); %Remove trailing character.
switch comp_name
    %%% pez3001 %%%
    case 'peekm-ww3'
        host = '10.103.40.22';
        
    %%% pez3002 %%%
    case 'cardlab-ww5'
        host = '10.103.40.50';
        
    %%% pez3003 %%%
    case 'CARDG-WW9'
        host = '10.103.40.30';
    otherwise
end
port = 21566;
packetlength = 50;
stimStruct = [];
stimTrigStruct = [];
disp('visual stimulus listener started')
listenFun

    function listenFun
        while true
            try
                mssgA = double(judp('receive',port,packetlength,5000));
            catch
                continue
            end
            if numel(mssgA) ~= 1, listenFun, return, end
            switch mssgA
                case 1
                    stimStruct = initializeVisualStimulusGeneralUDP;
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
                case 3
                    mssg = char(judp('receive',port,packetlength,5000));
                    mssgCell = strsplit(mssg',';');
                    visParams.ellovervee = str2double(mssgCell{1});
                    visParams.radiusbegin = str2double(mssgCell{2});
                    visParams.radiusend = str2double(mssgCell{3});
                    stimTrigStruct = initializeBlackDiskOnWhiteUDP(stimStruct,visParams);
                    stimdurstr = num2str(round(stimTrigStruct.stimTotalDuration));
                    judp('send',port,host,int8(stimdurstr))
                case 4
                    try
                        mssg = char(judp('receive',port,packetlength,5000));
                    catch
                        listenFun
                        return
                    end
                    mssgCell = strsplit(mssg',';');
                    stimTrigStruct(1).aziVal = str2double(mssgCell{1});
                    stimTrigStruct(1).eleVal = str2double(mssgCell{2});
                    [missedFrames,whiteCt] = presentDiskStimulusUDP(stimTrigStruct);
                    rtrnMssg = [num2str(missedFrames),';',num2str(whiteCt)];
                    judp('send',port,host,int8(rtrnMssg))
                case 5
                    Screen(stimTrigStruct.window,'PutImage',stimTrigStruct.crosshairsIm);
                    Screen(stimTrigStruct.window,'Flip');
                case 6
                    Screen(stimTrigStruct.window,'PutImage',stimTrigStruct.calibImB);
                    Screen(stimTrigStruct.window,'Flip');
                case 7
                    Screen(stimTrigStruct.window,'PutImage',stimTrigStruct.gridIm);
                    Screen(stimTrigStruct.window,'Flip');
                case 99
                    ShowCursor
                    sca
                    return
                otherwise
                    litenFun
                    return
            end
        end
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
end