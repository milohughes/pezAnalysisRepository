% Reset stimulus computer
judp('send',portNum,hostIP,int8(86))

%% Stop stimulus timer2
judp('send',portNum,hostIP,int8(99))

%% Get communications variables
variablesDir = [filesep filesep 'dm11' filesep 'cardlab' filesep 'pez3000_variables'];
[~, comp_name] = system('hostname');
comp_name = comp_name(1:end-1); %Remove trailing character.
compDataPath = fullfile(variablesDir,'computer_info.xlsx');
compData = dataset('XLSFile',compDataPath);
compRef = find(strcmp(compData.control_computer_name,comp_name));%this computer
if isempty(compRef)
    disp('computer not valid')
    return
end
hostIP = compData.stimulus_computer_IP{compRef};
portNum = 21566;

%% Initialize visual stimulus computer
%command values: 0 - transforming initialization, 5 - standard (for calibration, etc)
commandVal = 5;
judp('send',portNum,hostIP,int8(commandVal))
rcvdMssg = judp('receive',portNum,50,15000);
char(rcvdMssg')

%% command values for basic frames
% 6 - crosshairs
% 7 - calibration
% 8 - grid
% 9 - full on, white
% 10 - full off, black
% 11 - RGB testing
% 50 - azimuth lines
% 51 - elevation lines
% 52 - full reflected projection
% 53 - full direct projection
% 54 - image from set file
commandVal = 7;
judp('send',portNum,hostIP,int8(commandVal))

%% file-based visual stimuli
% fileName = 'loom_10to180_lv160_blackonwhite_withReference.mat';
fileName = 'loom_10to180_lv40_blackonwhite.mat';
% fileName = 'loom_10to180_lv40_blackonwhite.mat';
% fileName = 'grating_10deg_1Hz_8sec_blackandwhite.mat';
judp('send',portNum,hostIP,int8([3 fileName]))
stimdurstr = judp('receive',portNum,50,15000);
stimdur = str2double(char(stimdurstr'));
disp(['duration: ' char(stimdurstr)' 'ms'])
%%

dispAziVal = 180;
dispEleVal = 45;
stim_data_matrix = [num2str(dispAziVal),';',num2str(dispEleVal)];
judp('send',portNum,hostIP,int8([4 stim_data_matrix]))

mssgDisp = judp('receive',portNum,50,stimdur+3000);
mssgDispCell = strsplit(char(mssgDisp'),';');
missedFrames = str2double(mssgDispCell{1});
disp(['Missed flip count: ' num2str(missedFrames)])
%%
ellovervee = 40;
aziVal = 0;
aziOffVal = 0;
eleVal = 45;
radiusBegin = 10;
radiusEnd = 180;
visParams = struct('ellovervee',ellovervee,'azimuth',aziOffVal,'elevation',...
    eleVal,'radius_begin',radiusBegin,'radius_end',radiusEnd);
elloverveeStr = '40';
visParams.ellovervee = str2double(elloverveeStr);
radiusbeginStr = '10';
visParams.radiusbegin = str2double(radiusbeginStr);
radiusendStr = '180';
visParams.radiusend = str2double(radiusendStr);
%Setup data to send to the slave computer for stim projection.
stim_data_string = [elloverveeStr,';',radiusbeginStr,';',radiusendStr];
disp('Writing out the elleovervee, radiusbegin, radiusend');
['1' stim_data_string]
judp('send',portNum,hostIP,[int8(1) int8(stim_data_string)])
stimdurstr = judp('receive',portNum,50,15000);
char(stimdurstr)'

%%
offset = 0;
azifly = 0;
dispAziVal = azifly+offset;
dispEleVal = 45;
stim_data_matrix = [num2str(dispAziVal),';',num2str(dispEleVal)];
judp('send',portNum,hostIP,int8([2 stim_data_matrix]))
mssgDisp = judp('receive',portNum,50,10000);
mssgDispCell = strsplit(char(mssgDisp'),';');
missedFrames = str2double(mssgDispCell{1});
whiteCt = str2double(mssgDispCell{2});
disp(['Missed flip count: ' num2str(missedFrames)])



