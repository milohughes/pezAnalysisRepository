function Pauses = findPauses_parsed(data,winnowed_sine,ipiTrains,pulse_cut_offs)


%ipi best if ipiStatsLomb.culled_ipi

pulsesong = zeros(size(data.d,1),1);


sineStart = round(winnowed_sine.start);
sineStop = round(winnowed_sine.stop);


%grab times of pulse song, set to 1

ipiStart = cell2mat(ipiTrains.t);
ipiDur = cell2mat(ipiTrains.d);

in_range_logic = ipiStart >= pulse_cut_offs(1) & ipiStart <= pulse_cut_offs(2);
ipiStart = ipiStart(in_range_logic);
ipiDur = ipiDur(in_range_logic);

for i = 1:numel(ipiStart)
    pulsesong(ipiStart(i):(ipiStart(i)+ipiDur(i))) = 1;
end

%sineBout start and stop times are from above (sineStart, sineStop)
%add second column with type of event identifier (1== sineStart, 2 ==
%sineStop)
sineBoutStart = sineStart;%sine start and stop times
sineBoutStop = sineStop;
sineBoutStart(:,2) = 1;%sine start and stop indicators
sineBoutStop(:,2) = 2;


%get pulseBout start and stop times
%add column with type of event identifier (3 == pulseStart, 4 == pulseStop)
pulseBoutDiff = diff(pulsesong);
pulseBoutStart = find(pulseBoutDiff == 1) + 1;%pulse start and stop times
pulseBoutStop = find(pulseBoutDiff == -1);
pulseBoutStart(:,2) = 3;%pulse start and stop indicators
pulseBoutStop(:,2) = 4;

AllEvents = [sineBoutStart;sineBoutStop;pulseBoutStart;pulseBoutStop];%pool them all together
AllEventsSorted = sortrows(AllEvents,1);%sort by time

%make arrays to hold event info
numDiffEvents = size(sineStart,1) + size(pulseBoutStart,1) - 1;
PauseType = cell(numDiffEvents,1);%type of pause (sine-sine, pulse-sine, sine-pulse, pulse-pulse)
PauseDelta = zeros(numDiffEvents,1);%duration of pause
PauseTime = zeros(numDiffEvents-1,1);%start time of pause

for i = 1:size(AllEventsSorted,1) - 1
    %get type of transition
    type_first = AllEventsSorted(i,2);
    type_next = AllEventsSorted(i+1,2);
    if (type_first == 2 && type_next == 1)
        type = 'sine-sine';
        PauseType{i} = type;
        PauseDelta(i) = abs(AllEventsSorted(i+1,1) - AllEventsSorted(i,1));%get duration of pause
        PauseTime(i) = AllEventsSorted(i);
    elseif (type_first == 2 && type_next == 3)
        type = 'sine-pulse';
        PauseType{i} = type;
        PauseDelta(i) = abs(AllEventsSorted(i+1,1) - AllEventsSorted(i,1));%get duration of pause
        PauseTime(i) = AllEventsSorted(i);
    elseif (type_first == 4 && type_next == 1)
        type = 'pulse-sine';
        PauseType{i} = type;
        PauseDelta(i) = abs(AllEventsSorted(i+1,1) - AllEventsSorted(i,1));%get duration of pause
        PauseTime(i) = AllEventsSorted(i);
    elseif (type_first == 4 && type_next == 3)
        type = 'pulse-pulse';
        PauseType{i} = type;
        PauseDelta(i) = abs(AllEventsSorted(i+1,1) - AllEventsSorted(i,1));%get duration of pause
        PauseTime(i) = AllEventsSorted(i);
    end
end

%clear out empty cell elements and zeros in arrays
PauseType(cellfun('isempty',PauseType))=[];
PauseDelta(PauseDelta ==0) = [];
PauseTime(PauseTime ==0) = [];

%get start time of pause
sineSineDelta = PauseDelta(strcmp('sine-sine',PauseType));
sinePulseDelta = PauseDelta(strcmp('sine-pulse',PauseType));
pulsePulseDelta = PauseDelta(strcmp('pulse-pulse',PauseType));
pulseSineDelta = PauseDelta(strcmp('pulse-sine',PauseType));


% %get pauses between bouts
% 
% shifted_bout_starts = circshift(bouts.Start,-1);
% bouts_pauses = shifted_bout_starts - bouts.Stop; 
% bouts_pauses  = bouts_pauses(1:end-1);
% 
% Pauses.Bouts = bouts_pauses;
Pauses.PauseDelta = PauseDelta;
Pauses.Type = PauseType;
Pauses.Time = PauseTime;
Pauses.sinesine = sineSineDelta;
Pauses.sinepulse = sinePulseDelta;
Pauses.pulsesine = pulseSineDelta;
Pauses.pulsepulse = pulsePulseDelta;

