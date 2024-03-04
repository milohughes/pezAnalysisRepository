function makeFolderIcon(h,iconsize,iconshape,iconshade)

%makeFolderIcon Generates an icon for pushbutton with handle 'h'
%   'h' is handle to pushbutton, iconsize is 0 to 1,
%   'iconshape' is string (see cases below), 'iconshade' is 0 to 1 with
%   '0' being black and '1' being white

% %% debug%
% h = hCnextFile;
% iconsize = 0.8;
% iconshape = 'next';
% iconshade = 0.1;

backTop = 0.93;
backBot = 0.85;
set(h,'units','pixels')
iconPos = get(h,'position');
set(h,'units','normalized');
iconS = round(min(iconPos(3:4))*iconsize/4);
iconY = repmat((1:iconS)*2,iconS*2,1);
iconX = repmat((1:iconS*2)',1,iconS);
iconTop = ones(iconS*2,iconS).*backTop;
iconTop(iconX >= iconY) = iconshade;
iconBot = ones(iconS*2,iconS).*backBot;
iconBot(iconX >= iconY) = iconshade;
iconB = [iconTop;flipud(iconBot)];
dimA = size(iconB);
padS = round((fliplr(iconPos(3:4))-dimA)/3);
dimM = round(dimA(1)/2);
padLR = ones(dimA(1),padS(2));
padLR(1:dimM,:) = backTop;
padLR(dimM+1:end,:) = backBot;
iconC = [padLR padLR iconB];
if strcmp(iconshape,'prev'),iconC = fliplr(iconC);end
iconD = repmat(iconC,[1 1 3]);
set(h,'CData',iconD)