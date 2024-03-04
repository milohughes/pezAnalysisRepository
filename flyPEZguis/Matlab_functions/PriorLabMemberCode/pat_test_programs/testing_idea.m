repositoryDir = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(repositoryDir,'Support_Programs'))

temp_range = [22.0,24.0];
remove_low = true;
low_count = 5;
combine_data = []; 

load_files = [{'0102000024150724'};{'0102000024150722'};{'0102000024150723'};{'0102000024150726'};{'0102000024150727'}];
%load_files = [{'0102000024160724'};{'0102000024160722'};{'0102000024160723'};{'0102000024160726'};{'0102000024160727'}];

steps = length(load_files);
for iterZ = 1:steps
    test_data =  Experiment_ID(load_files{iterZ});
    test_data.temp_range = temp_range;
    test_data.remove_low = remove_low;
    test_data.low_count = low_count;
    try
        test_data.load_data;
        test_data.make_tables;
        combine_data = [combine_data;test_data]; 
    catch
        warning('id with no graph table');
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
good_data = [vertcat(combine_data(:).Complete_usuable_data);vertcat(combine_data(:).Videos_Need_To_Work);vertcat(combine_data(:).Vid_Not_Tracked);vertcat(combine_data(:).Bad_Tracking)];
start_frame = cellfun(@(x) find(x.nidaq_data <= 225,1,'first')-2,good_data.photoactivation_info);

wing_frame = good_data.frame_of_wing_movement;
wing_frame(cellfun(@(x) isempty(x),good_data.frame_of_wing_movement)) = num2cell(good_data(cellfun(@(x) isempty(x),good_data.frame_of_leg_push),:).autoFot);

leg_frame = good_data.frame_of_leg_push;
leg_frame(cellfun(@(x) isempty(x),good_data.frame_of_leg_push)) = num2cell(good_data(cellfun(@(x) isempty(x),good_data.frame_of_leg_push),:).autoFot);

ontime_logic = (cellfun(@(x) isnan(x), wing_frame) | cell2mat(wing_frame) >= start_frame);
good_data = good_data(ontime_logic,:);      %removes pre stim flies
%leg_frame = leg_frame(ontime_logic);
%start_frame = start_frame(ontime_logic);
%%
good_data(cellfun(@(x) isempty(x),good_data.frame_of_leg_push),:) = [];
good_data(cellfun(@(x) isnan(x),good_data.frame_of_leg_push),:) = [];

start_frame = cellfun(@(x) find(x.nidaq_data <= 225,1,'first')-2,good_data.photoactivation_info);

wing_delay = (cell2mat(good_data.frame_of_wing_movement)-start_frame)/6;
wing_stroke = (cell2mat(good_data.wing_down_stroke)-start_frame)/6;
intensity_used = cellfun(@(x) str2double(x((strfind(x,'intensity')+9):end)),good_data.photoStimProtocol);
%%
figure;

%intensity_used(wing_delay > 500) = [];
%wing_delay(wing_delay > 500) = [];

for iterZ = 1:4
    subplot(2,2,iterZ);
    set(gca,'nextplot','add');
    match_logic = (intensity_used == (iterZ+1)*10);
    test_wing = wing_delay(match_logic);        wing_down = wing_stroke(match_logic);
    [test_wing,sort_idx]  = sort(test_wing);    wing_down = wing_down(sort_idx);
    
    y_pos = 1:1:length(test_wing);              y_pos  = y_pos  ./ max(y_pos);
    
    scatter(test_wing,y_pos,20,rgb('blue'));
    scatter(wing_down,y_pos,20,rgb('red'));
    set(gca,'Xlim',[0 100],'Ylim',[0 1]);
    ylimit = get(gca,'Ylim');
    
%    line([quantile(test_wing,.75) quantile(test_wing,.75)],ylimit,'color',rgb('green'),'linewidth',1.25,'parent',gca);
%    line([quantile(test_wing,.25) quantile(test_wing,.25)],ylimit,'color',rgb('green'),'linewidth',1.25,'parent',gca);
%    line([0 quantile(test_wing,.50)],[.5 .5],'color',rgb('red'),'linewidth',1.25,'parent',gca);
%    line([quantile(test_wing,.50) quantile(test_wing,.50)],[0 .5],'color',rgb('red'),'linewidth',1.25,'parent',gca);
end
%%
wing_leg = cellfun(@(x,y) ((x-y)/6),good_data.frame_of_leg_push,good_data.frame_of_wing_movement);
intensity_used = cellfun(@(x) str2double(x((strfind(x,'intensity')+9):end)),good_data.photoStimProtocol);
%good_data(wing_leg ==0 | intensity_used == 10,:) = [];

start_frame = cellfun(@(x) find(x.nidaq_data <= 225,1,'first')-2,good_data.photoactivation_info);

full_diff = cellfun(@(x,y) log((x-y)/6),good_data.frame_of_take_off,good_data.frame_of_wing_movement);
wing_leg = cellfun(@(x,y) ((x-y)/6),good_data.frame_of_leg_push,good_data.frame_of_wing_movement);
leg_down = cellfun(@(x,y) ((x-y)/6),good_data.wing_down_stroke,good_data.frame_of_leg_push);
wing_cycle = cellfun(@(x,y) ((x-y)/6),good_data.wing_down_stroke,good_data.frame_of_wing_movement);
down_jump = cellfun(@(x,y) ((x-y)/6),good_data.frame_of_take_off,good_data.wing_down_stroke);
intensity_used = cellfun(@(x) str2double(x((strfind(x,'intensity')+9):end)),good_data.photoStimProtocol);

wing_start = cellfun(@(x,y) ((x-y)/6),good_data.frame_of_wing_movement,num2cell(start_frame));
pez_list = cellfun(@(x) str2double(x(11:14)),good_data.Properties.RowNames);
gender_list = good_data.Gender;
%%
figure
outlier_logic = wing_start > 400 | intensity_used == 10;

%[y_data,x_data,~] = iosr.statistics.tab2box(intensity_used,(wing_leg));
%[y_data,x_data,pez_group] = iosr.statistics.tab2box(intensity_used,wing_start,pez_list);
[y_data,x_data,~] = iosr.statistics.tab2box(intensity_used(~outlier_logic),full_diff(~outlier_logic));

h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+','showviolin',true,...
        'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));

set(gca,'fontsize',15)
title('Wings up to Take off Differential in log scale','fontsize',20)
line([0 60],[log(7) log(7)],'color',rgb('green'),'linewidth',1.5);

[p,anovatab,stats]  = kruskalwallis(full_diff(~outlier_logic),intensity_used(~outlier_logic));
%%
figure
[y_data,x_data,~] = iosr.statistics.tab2box(gender_list(~outlier_logic),full_diff(~outlier_logic));

h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+','showviolin',true,...
        'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));

set(gca,'fontsize',15)
title('Wings up to Take off Differential in log scale','fontsize',20)
line([0 60],[log(7) log(7)],'color',rgb('green'),'linewidth',1.5);
%%
figure
[y_data,x_data,group] = iosr.statistics.tab2box(intensity_used(~outlier_logic),wing_start(~outlier_logic),gender_list(~outlier_logic));

h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+','showviolin',false,...
        'showScatter', false,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));
h.xSeparator = true;
h.groupLabels = group;
h.boxColor = {rgb('light red'),rgb('light blue')};
h.showLegend = true;

set(gca,'fontsize',15,'Ylim',[0 100],'Ytick',0:20:100)
title(sprintf('Delay between Lights On and \nStart of Wing Lift in milliseconds'),'fontsize',20)
%%
figure
[y_data,x_data,~] = iosr.statistics.tab2box(gender_list(~outlier_logic),wing_leg(~outlier_logic));

h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+','showviolin',false,...
        'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));

set(gca,'fontsize',15,'Ylim',[0 5],'Ytick',0:1:5)
title(sprintf('Delay between Start of Wing Lift and \nStart of Leg Extension in milliseconds'),'fontsize',20)
%%
figure
[y_data,x_data,~] = iosr.statistics.tab2box(gender_list(~outlier_logic),leg_down(~outlier_logic));

h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+','showviolin',false,...
        'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));

set(gca,'fontsize',15,'Ylim',[0 2],'Ytick',0:.5:2)
title(sprintf('Delay between Start of Leg Push and \nStart of Wing Downstroke in milliseconds'),'fontsize',20)
%%
figure
[y_data,x_data,~] = iosr.statistics.tab2box(gender_list(~outlier_logic),wing_cycle(~outlier_logic));

%h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+','showviolin',false,...
%        'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));
h = iosr.statistics.boxPlot(1,wing_cycle(~outlier_logic),'symbolColor','k','medianColor','k','symbolMarker','+','showviolin',false,...
        'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));

%set(gca,'fontsize',15,'Ylim',[0 6],'Ytick',0:1:6)
set(gca,'fontsize',15,'Ylim',[0 50],'Ytick',0:10:50)
title(sprintf('Delay between Start of Wing lift and \nStart of Wing Downstroke in milliseconds'),'fontsize',20)

%%
figure
[y_data,x_data,~] = iosr.statistics.tab2box(gender_list(~outlier_logic),down_jump(~outlier_logic));

%h = iosr.statistics.boxPlot(x_data,y_data,'symbolColor','k','medianColor','k','symbolMarker','+','showviolin',false,...
%        'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));

h = iosr.statistics.boxPlot(1,down_jump(~outlier_logic),'symbolColor','k','medianColor','k','symbolMarker','+','showviolin',false,...
        'showScatter', true,'boxAlpha',0.5,'scatterColor',rgb('red'),'scatterMarker','.','scatterSize',150,'linewidth',2,'linecolor',rgb('black'));


set(gca,'fontsize',15,'Ylim',[0 6],'Ytick',0:1:6)
title(sprintf('Delay between Start of Wing Downstroke and \nfull leg extension in milliseconds'),'fontsize',20)

%%

outlier_logic = wing_leg == 0 | intensity_used == 10;
new_y_label = [1,3,5,7,10,20];
figure
inter = 3/6;
subplot(3,1,1); hist(wing_leg(~outlier_logic),(0-inter/2):inter:6); title('wing lift to leg push'); set(gca,'Xlim',[0 6])
subplot(3,1,2); hist(leg_down(~outlier_logic),(0-inter/2):inter:6); title('leg push to wings down');set(gca,'Xlim',[0 6])
subplot(3,1,3); hist(wing_cycle(~outlier_logic),(0-inter/2):inter:6); title('wing lift to wings down'); set(gca,'Xlim',[0 6])


% hb = boxplot(full_diff,intensity_used);
% line([.5 5.5],[log(7) log(7)],'color',rgb('green'),'linewidth',1.5);
% line([.5 5.5],[log(50/6) log(50/6)],'color',rgb('black'),'linewidth',1.5);
% set(gca,'fontsize',15,'Ytick',log(new_y_label),'Yticklabels',new_y_label,'Ylim',[0.5 3.0]);
samp_sigma = std(leg_down);

test_y = linspace(0,2.5,1000);

half_norm_func = @(x,z) (sqrt(2) / (z*sqrt(pi))) * exp(-((x*x)/2*(z*z)));
%%

intensity_used = cellfun(@(x) str2double(x((strfind(x,'intensity')+9):end)),good_data.photoStimProtocol);
new_cut_values = [(2500 ./ intensity_used),repmat([250,500,1000],length(intensity_used),1)];

uni_intensity = unique(intensity_used);

jump_timing = (cell2mat(leg_frame) - start_frame)/6;
jump_timing = repmat(jump_timing,1,4);

for iterZ = 1:4
    change_jump = jump_timing(:,iterZ) > new_cut_values(:,iterZ);
    jump_timing(change_jump,iterZ) = NaN(sum(change_jump),1);
    
    jump_logic = ~isnan(jump_timing(:,iterZ));
    
    total_counts(iterZ,:) = arrayfun(@(x) length(jump_timing(intensity_used  == uni_intensity(x),iterZ)),1:1:length(uni_intensity));
    jump_counts(iterZ,:) = arrayfun(@(x) length(jump_timing(intensity_used  == uni_intensity(x) & jump_logic,iterZ)),1:1:length(uni_intensity));
end
%%
figure
jump_rates = (jump_counts ./ total_counts);
for iterZ = 1:5
    set(gca,'nextplot','add')
     hb(iterZ) = bar(((iterZ-1)*4+1):1:(iterZ*4),jump_rates(:,iterZ));
     line([(iterZ*4)+.5 (iterZ*4)+.5],[0 1],'color',rgb('black'),'linewidth',1.5,'parent',gca)     
%    hb(iterZ) = bar(((iterZ-1)*5+1):1:(iterZ*5),jump_rates(iterZ,:));
%    line([(iterZ*5)+.5 (iterZ*5)+.5],[0 1],'color',rgb('black'),'linewidth',1.5,'parent',gca)

end
set(hb(1),'facecolor',rgb('red'),'barwidth',.5)
set(hb(2),'facecolor',rgb('blue'),'barwidth',.5)
set(hb(3),'facecolor',rgb('orange'),'barwidth',.5)
set(hb(4),'facecolor',rgb('purple'),'barwidth',.5)
set(hb(5),'facecolor',rgb('dark green'),'barwidth',.5)
set(gca,'Xlim',[0.5 20.5],'fontsize',15,'Ytick',0:.2:1,'Xtick',[])

new_labels = arrayfun(@(x) sprintf('%4.0f%%\n intensity',x),uni_intensity,'uniformoutput',false);

hxLabel = get(gca,'XLabel');                                 set(hxLabel,'Units','data');
xLabelPosition = get(hxLabel,'Position');                    y = xLabelPosition(2);
y = repmat(y,length(new_labels),1);                          new_x_pos = 2.5:4:20;
y = y - .05;
hText = text(new_x_pos, y, new_labels,'parent',gca);                

set(gca,'Xtick',[],'fontsize',15);
set(hText,'Rotation',0,'HorizontalAlignment','center','Color',rgb('black'),'Interpreter','none','fontsize',15);

%h_len = legend('2500 / Intensity','250 ms duration','500 ms duration','1000 ms duration');
%set(h_len,'fontsize',15,'location','best');

% %%
% set(hb,'edgecolor',rgb('black'),'linewidth',1.25)
% set(hb(1),'facecolor',rgb('red'))
% set(hb(2),'facecolor',rgb('blue'))
% set(hb(3),'facecolor',rgb('orange'))        
% set(hb(4),'facecolor',rgb('purple'))
