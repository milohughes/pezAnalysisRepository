function toggleChildren(handle,onVoff)
%toggleChildren Toggles current figure children on (1) or off (0)
switch onVoff
    case 1
        returnCell = get(handle,'userdata');
        activateChildren(returnCell)
        set(handle,'userdata',[])
    case 0
        stateCell = cell(0,0);
        handleCell = cell(0,0);
        [handleCell,stateCell] = inactivateChildren(handle,handleCell,stateCell);
        set(handle,'userdata',[handleCell;stateCell])
end

function [handleCell,stateCell] = inactivateChildren(handle,handleCell,stateCell)
hList = allchild(handle);
numChild = numel(hList);
if numChild == 0
    if isprop(handle,'Enable')
        enableState = get(handle,'Enable');
        stateCell = [stateCell,{enableState}];
        handleCell = [handleCell,{handle}];
        if strcmp(enableState,'on')
            set(handle,'Enable','off')
        end
    end
elseif numChild > 0
    for iterC = 1:numChild
        [handleCell,stateCell] = inactivateChildren(hList(iterC),handleCell,stateCell);
    end
end

function activateChildren(returnCell)
for iterR = 1:size(returnCell,2)
    set(returnCell{1,iterR},'Enable',returnCell{2,iterR})
end