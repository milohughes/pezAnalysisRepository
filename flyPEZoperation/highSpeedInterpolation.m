function highspeedrefs = highSpeedInterpolation(deltaPix,refcutrate)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

targetCt = 500;
expFac = 1;
contBool = true;
magState = 1;
sumThresh = 2;
downFac = 10;
expThresh = [0.1 3];
expAdj = [0.05 0.001];
while contBool
    dScaled = (deltaPix./range(deltaPix)).^expFac;
    dScaled = dScaled.*(downFac-1);
    dRound = round(dScaled);
    sumVal = sum(dRound(dRound > sumThresh));
    if sumVal > targetCt
        expFac = expFac+expAdj(1);
        if magState == 1
            magState = 2;
        elseif magState == 3
            contBool = true;
            magState = 1;
            while contBool
                dScaled = (deltaPix./range(deltaPix)).^expFac;
                dScaled = dScaled.*(downFac-1);
                dRound = round(dScaled);
                sumVal = sum(dRound(dRound > sumThresh));
                if sumVal > targetCt
                    expFac = expFac+expAdj(2);
                    if magState == 1
                        magState = 2;
                    elseif magState == 3
                        break
                    end
                else
                    expFac = expFac-expAdj(2);
                    if magState == 1
                        magState = 3;
                    elseif magState == 2
                        break
                    end
                end
                if expFac < expThresh(1) || expFac > expThresh(2)
                    contBool = false;
                end
            end
            break
        end
    else
        expFac = expFac-expAdj(1);
        if magState == 1
            magState = 3;
        elseif magState == 2
            contBool = true;
            magState = 1;
            while contBool
                dScaled = (deltaPix./range(deltaPix)).^expFac;
                dScaled = dScaled.*(downFac-1);
                dRound = round(dScaled);
                sumVal = sum(dRound(dRound > sumThresh));
                if sumVal > targetCt
                    expFac = expFac+expAdj(2);
                    if magState == 1
                        magState = 2;
                    elseif magState == 3
                        break
                    end
                else
                    expFac = expFac-expAdj(2);
                    if magState == 1
                        magState = 3;
                    elseif magState == 2
                        break
                    end
                end
                if expFac < expThresh(1) || expFac > expThresh(2)
                    contBool = false;
                end
            end
            break
        end
    end
    if expFac < expThresh(1) || expFac > expThresh(2)
        contBool = false;
    end
end
dScaled = (deltaPix./range(deltaPix)).^expFac;
dScaled = dScaled.*(downFac-1);
dRound = round(dScaled);
dThreshRefs = find(dRound > sumThresh);
dThresh = dRound(dThreshRefs);
fillCt = numel(dThresh);
spotCell = cell(1,fillCt);
for iterFill = 1:fillCt
    spotRate = dThresh(iterFill);
    spotRef = refcutrate(dThreshRefs(iterFill));
    spotSpan = round((1:spotRate).*((downFac-1)/spotRate));
    spotCell{iterFill} = spotRef+spotSpan;
end
highspeedrefs = cell2mat(spotCell);

end

