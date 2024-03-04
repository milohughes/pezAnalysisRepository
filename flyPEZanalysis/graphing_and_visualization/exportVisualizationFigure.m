function exportVisualizationFigure(saveName,saveOption,writeDir)
%exportVisualizationFigure ryan style figure export
%   imbeds table with relevant info and calls export_fig. saveOption can
%   have the following values:
%   1 - .pdf  ;  2 - .eps  ;  3 - .png
if saveOption == 0
    return
end
optionsPath = 'Z:\Data_pez3000_analyzed\WRW_graphing_variables\graphOptions.mat';
graphOptionsLoading = load(optionsPath);
graphOptions = graphOptionsLoading.graphOptions;
if ~exist('writeDir','var')
    writeDir = fullfile(fileparts(graphOptions.excelPath),'exploratory_figs');
end
if exist('aziGrpCt','var')
    saveName = cat(2,saveName,'_binCt-',num2str(aziGrpCt));
    set(htit,'string',saveName)
end
if ~isdir(writeDir), mkdir(writeDir), end
if saveOption == 1
    writePath = fullfile(writeDir,[saveName '.pdf']);
    export_fig(writePath,'-nocrop')
else
    figColor = get(gcf,'color');
    set(gcf,'color','none')
    if saveOption == 2
        callers = dbstack;
        if numel(callers) > 1 && strcmp(callers(2).name,'graphing_pez3000.m')
            textObjects = findobj('Type','Text');
            for it = 1:numel(textObjects)
                set(textObjects(it),'rotation',0,'fontname','arial')
            end
        end
        lineObjs = findobj('type','line');
        if ~isempty(lineObjs)
            for iterL = 1:numel(lineObjs)
                if strcmp(get(lineObjs(iterL),'LineStyle'),'none')
                    set(lineObjs(iterL),'markersize',8)
                else
                    set(lineObjs(iterL),'linewidth',1)
                end
            end
        end
        writePath = fullfile(writeDir,[saveName '.eps']);
        export_fig(writePath,'-nocrop')
    elseif saveOption == 3
        writePath = fullfile(writeDir,[saveName '.png']);
        export_fig(writePath,'-nocrop','-m3')
    end
    set(gcf,'color',figColor)
end

suplFig = figure;
set(gcf,'pos',[2000 750 750 300])
tables2insert = graphOptions;
d = struct2cell(tables2insert);
rnames = fieldnames(tables2insert);
cellBool = false(numel(d),1);
for iterD = 1:numel(d)
    if isa(d{iterD},'double')
        d{iterD} = num2str(d{iterD});
    elseif iscell(d{iterD})
        cellBool(iterD) = true;
    end
end
d(cellBool) = [];
rnames(cellBool) = [];
callers = dbstack;
if numel(callers) > 1
    d = cat(1,d,{callers(2).name});
    rnames = cat(1,rnames,{'graphing_function'});
else
    disp('run as function to save function name in supplement')
end
t = uitable(suplFig,'Data',d,'ColumnWidth',{500},'RowName',rnames,'units','normalized','ColumnName',[]);
t.Position(3) = t.Extent(3);
t.Position(4) = t.Extent(4);
text(0,1.1,saveName,'horizontalalignment','left','fontsize',10,'interpreter','none')
set(gca,'pos',t.Position,'color','none','ycolor','none','xcolor','none')
drawnow
suplIm = getframe(suplFig);
imwrite(suplIm.cdata,fullfile(writeDir,[saveName '.jpg']));
close(suplFig)
