function makePezIcon(h,iconsize,iconshape,iconshade,backshade)
%makeIcon Generates an icon for pushbutton with handle 'h'
%   'h' is handle to pushbutton,
%   iconsize is 0 to 1 with 1 relating to length of shortest side,
%   'iconshape' is string (see cases below), 'iconshade' is 0 to 1 with
%   '0' being black and '1' being white, 'backshade' is background shade
%   also 0 to 1.

% %% debug
% h = btnHmat(6);
% iconsize = 0.7;
% iconshape = 'stop';
% iconshade = 0.1;

backTop = backshade(1);
backBot = backshade(1);
set(h,'units','pixels')
iconPos = get(h,'position');
set(h,'units','normalized');
iconS = round(min(iconPos(3:4))*iconsize/4);
if strcmp('stop',iconshape)
    iconB = ones(iconS*2,iconS*2).*iconshade;
else
    iconY = repmat((1:iconS)*2,iconS*2,1);
    iconX = repmat((1:iconS*2)',1,iconS);
    iconTop = ones(iconS*2,iconS).*backTop;
    iconTop(iconX >= iconY) = iconshade;
    iconBot = ones(iconS*2,iconS).*backBot;
    iconBot(iconX >= iconY) = iconshade;
    iconB = [iconTop;flipud(iconBot)];
    switch iconshape
        case 'fwd'
        case 'rev'
            iconB = fliplr(iconB);
        case 'ffwd'
            iconB = [iconB iconB];
        case 'frev'
            iconB = fliplr([iconB iconB]);
        case 'slowfwd'
            iconTop = ones(iconS*2,iconS).*backTop;
            iconTop(round(iconS*.4):end,1:round(iconS*.35)) = iconshade;
            iconBot = ones(iconS*2,iconS).*backBot;
            iconBot(round(iconS*.4):end,1:round(iconS*.35)) = iconshade;
            iconB = cat(2,[iconTop;flipud(iconBot)],iconB);
        case 'slowrev'
            iconTop = ones(iconS*2,iconS).*backTop;
            iconTop(round(iconS*.4):end,1:round(iconS*.35)) = iconshade;
            iconBot = ones(iconS*2,iconS).*backBot;
            iconBot(round(iconS*.4):end,1:round(iconS*.35)) = iconshade;
            iconB = cat(2,[iconTop;flipud(iconBot)],iconB);
            iconB = fliplr(iconB);
    end
end
dimA = size(iconB);
padS = round((fliplr(iconPos(3:4))-dimA)/5);
dimM = round(dimA(1)/2);
padLR = ones(dimA(1),padS(2));
padLR(1:dimM,:) = backTop;
padLR(dimM+1:end,:) = backBot;
padTB = ones(padS(1),dimA(2)+padS(2)*2);
iconC = [padTB.*backTop
    [padLR iconB padLR]
    padTB.*backBot];
iconD = repmat(iconC,[1 1 3]);
set(h,'CData',iconD)





