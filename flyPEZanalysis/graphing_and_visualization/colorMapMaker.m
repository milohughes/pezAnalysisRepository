function colorMapVar = colorMapMaker(mapChoice,res)
%colorMapMaker Makes heatmap using custom inputs, for exploration
%   Detailed explanation goes here
%%
if ~exist('res','var')
    res = 256;
end
if res > 256
    error('Resolution too large')
end
if isempty(mfilename) || ~exist('mapChoice','var')
    cla
    mapChoice = 4;
%     mapChoice = {([1 0.75 0.5 0.25 0])
%                  ([0 0.25 0.5 0.75 1])
%                  ([0 0 0 0 0])};
end
if iscell(mapChoice)
    colorMapDef = mapChoice;
elseif mapChoice == 0
    colorMapDef = {[0 0 0 0.5 1 1]
        [1 0.5 0 0 0 0.5]
        [0 0.5 1 0.5 0 0]};
elseif mapChoice == 1
    colorMapDef = {[1 0 0 0.5 1]
        [1 0.5 0 0]
        [0 0 1 1 1 0.5 0]};
elseif mapChoice == 2
    colorMapDef = {[1 0 0 1]
        [1 0 0 0]
        [1 1 0 0]};
elseif mapChoice == 3
    colorMapDef = {([1 0.5 0 0 0.5])
                   ([0 0 1 0.5 0])
                   ([0.5 0 0 0.5 1])};
elseif mapChoice == 4
    colorMapDef = {[0 0 0.5 1]
        [0.5 0 0 0]
        [0.5 1 0.5 0]};

else
    error('invalid input')
end
colorMapVar = [];
for i = 1:3
    smallDef = colorMapDef{i};
%     smallDef(:,1) = round(smallDef(:,1));
%     if sum(isnan(smallDef(:))) > 0
%         smallDef(isnan(smallDef)) = (res-sum(smallDef(~isnan(smallDef(:,1)),1)))/sum(isnan(smallDef(:)));
%     end
    channel = [];
    for k = 2:numel(smallDef)
        legsize = 256/(numel(smallDef)-1);
        legA = smallDef(k-1);
        legB = smallDef(k);
        if k == numel(smallDef)
            legsize = 256-numel(channel)+1;
        elseif k > 2
            legsize = legsize+1;
        end
        leg = linspace(legA,legB,(legsize))';
        if k > 2
            leg(1) = [];
        end
        channel = cat(1,channel,leg);
    end
    colorMapVar = cat(2,colorMapVar,channel);
end
subsampleVec = round(linspace(1,256,res));
colorMapVar = colorMapVar(subsampleVec,:);
colormap(colorMapVar)
if isempty(mfilename) || ~exist('colorMapDef','var')
    clf
    plot(colorMapVar(:,1),'r')
    hold on
    plot(colorMapVar(:,2)+0.01,'g')
    plot(colorMapVar(:,3)+0.02,'b')
    colorbar
end
end

