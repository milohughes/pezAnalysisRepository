function [ output_args ] = multiAxesPosGen(rows,cols)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
%%
xCt = 11;
%escape plots
axWH = [haxPos(3)/ceil(xCt/rows) haxPos(4)/rows];
    startPosY = repmat(fliplr(axWH(2)*(0:rows-1)),ceil(xCt/rows),1);
    startPosX = repmat(axWH(1)*(0:ceil(xCt/rows)-1),1,rows);
    
    if xCt > 8, rows = 3; else rows = 2; end
    axWH = [haxPos(3)/ceil(xCt/rows) haxPos(4)/rows];
    startPosY = repmat(fliplr(axWH(2)*(0:rows-1)),ceil(xCt/rows),1);
    startPosX = repmat(axWH(1)*(0:ceil(xCt/rows)-1),1,rows);
    
    axWH = [haxPos(3)/2 haxPos(4)/ceil(xCt/2)];
        startPosY = repmat(fliplr(axWH(2)*(0:ceil(xCt/2)-1)),1,2);
        startPosX = repmat([0,axWH(1)],ceil(xCt/2),1);
end

