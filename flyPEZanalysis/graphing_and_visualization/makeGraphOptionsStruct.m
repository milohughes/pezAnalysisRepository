function makeGraphOptionsStruct(excelPath,graphName)
%makeGraphOptionsStruct Makes and saves graphOptions variable
%   Requires excelFile

optionsPath = '\\dm11\cardlab\Data_pez3000_analyzed\WRW_graphing_variables\graphOptions.mat';
if exist(optionsPath,'file')
    graphOptionsLoading = load(optionsPath);
    graphOptions = graphOptionsLoading.graphOptions;
    if ~exist('graphName','var') && isfield(graphOptions,'graphName')
        graphName = graphOptions.graphName;
    end
    if (~exist('excelPath','var') && isfield(graphOptions,'excelPath')) || isempty(excelPath)
        excelPath = graphOptions.excelPath;
    end
end
if ~exist('excelPath','var')
    error('no excel path available')
end
optionsTable = readtable(excelPath,'Sheet','graph_control','Range','A1:B10',...
    'ReadRowNames',true);
graphOptions = struct;
graphOptions.excelPath = excelPath;
if ~exist('graphName','var')
    graphName = '';
end
graphOptions.graphName = graphName;
graphOptions.exptSheet = optionsTable.Option{'exptID_sheet'};
graphOptions.unique_label = optionsTable.Option{'unique_label'};
jump_thresh = optionsTable.Option{'jump_thresh'};
if ischar(jump_thresh)
    if strcmp(jump_thresh,'Inf')
        jump_thresh = Inf;
    else
        jump_thresh = str2double(jump_thresh);
    end
elseif ~isdouble(jump_thresh)
    error('unknown jump_thresh')
end
graphOptions.jump_thresh = jump_thresh;
graphOptions.useManual = str2double(optionsTable.Option{'annotations_option'});
graphOptions.sliceOption = str2double(optionsTable.Option{'slice_option'});

sheetName = graphOptions.unique_label;
if graphOptions.sliceOption == 1
    sheetName = cat(2,sheetName,'_multiStim');
elseif graphOptions.sliceOption == -1
    sheetName = cat(2,sheetName,'_LvS');
elseif graphOptions.sliceOption > 1
    sheetName = cat(2,sheetName,'_aziX',num2str(graphOptions.sliceOption));
end
graphOptions.sheetName = sheetName;
jumpOps = {'jumping','nonjumping','moving','nonmoving','all'};
subset2plot = jumpOps{str2double(optionsTable.Option{'subset_to_plot'})};
graphOptions.subset2plot = subset2plot;
graphOptions.keep_late_jumpers = str2double(optionsTable.Option{'keep_late_jumpers'});
graphOptions.keep_early_movers = str2double(optionsTable.Option{'keep_early_movers'});
graphOptions.azimuth_tolerance = str2double(optionsTable.Option{'azimuth_tolerance'});

save(optionsPath,'graphOptions')

end

