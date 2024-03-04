test_data =  Experiment_ID('0087000022700665');
%test_data =  Experiment_ID('0070000004300529');
test_data.load_data;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure

white_data = test_data.Complete_usuable_data;
gender_logic = strcmp(white_data.Fly_Count,'Single');

white_data = white_data(gender_logic,:);

complete_data = white_data(cellfun(@(x) ~isempty(x),white_data.frame_of_leg_push),:);
jumping_data = complete_data(cellfun(@(x) ~isnan(x),complete_data.frame_of_leg_push),:);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
jump_height = 100;
subplot(2,2,1)

jump_rate = (height(jumping_data) ./ height(complete_data))*100;
gender_list = [{'Male'},{'Female'}];
jumpers = zeros(2,1);       totals = zeros(2,1);
for iterG = 1:length(gender_list)
    jumpers(iterG) = sum(strcmp(jumping_data.Gender,gender_list{iterG}));
    totals(iterG) = sum(strcmp(complete_data.Gender,gender_list{iterG}));
end

male_jump_rate = (jumpers(1) ./ totals(1))*100;
female_jump_rate = (jumpers(2) ./ totals(2))*100;

plot([-1 0 1],[male_jump_rate,jump_rate,female_jump_rate],'o','markersize',15);
set(gca,'Xlim',[-1.5 1.5],'Ylim',[0 jump_height],'Xtick',[-1,0,1],'Xticklabel',[{'Males only'},{'All Flies'},{'Females Only'}]);
text([-1 0 1],repmat(.95*jump_height,3,1),num2cell([jumpers(1) height(jumping_data) jumpers(2)]),'horizontalalignment','center');
text([-1 0 1],repmat(.88*jump_height,3,1),num2cell([totals(1) height(complete_data) totals(2)]),'horizontalalignment','center');
line([-1.5 1.5],[(jump_rate+5) (jump_rate+5)],'color',rgb('black'),'linewidth',1.2,'parent',gca);
line([-1.5 1.5],[(jump_rate-5) (jump_rate-5)],'color',rgb('black'),'linewidth',1.2,'parent',gca);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,2,2)

jump_pez_names = cellfun(@(x) x(8:14),jumping_data.Properties.RowNames,'uniformoutput',false);
total_pez_names = cellfun(@(x) x(8:14),complete_data.Properties.RowNames,'uniformoutput',false);

uni_pez = [{'pez3001'},{'pez3002'},{'pez3003'},{'pez3004'}];
jumpers = zeros(length(uni_pez),1);       totals = zeros(length(uni_pez),1);
for iterG = 1:length(uni_pez)
    jumpers(iterG) = sum(strcmp(jump_pez_names,uni_pez{iterG}));
    totals(iterG) = sum(strcmp(total_pez_names,uni_pez{iterG}));
end

pez_1_rate = (jumpers(1) ./ totals(1))*100;     pez_2_rate = (jumpers(2) ./ totals(2))*100;
pez_3_rate = (jumpers(3) ./ totals(3))*100;     pez_4_rate = (jumpers(4) ./ totals(4))*100;

plot([-2 -1 0 1 2],[pez_1_rate,pez_2_rate,jump_rate,pez_3_rate,pez_4_rate],'o','markersize',15);
set(gca,'Xlim',[-2.5 2.5],'Ylim',[0 jump_height],'Xtick',[-2 -1,0,1 2],'Xticklabel',[{'Pez 3001 Only'},{'Pez 3002 Only'},{'All Flies'},{'Pez 3003 Only'},{'Pez 3004 Only'}]);
text([-2 -1 0 1 2],repmat(.95*jump_height,5,1),num2cell([jumpers(1) jumpers(2) height(jumping_data) jumpers(3) jumpers(4)]),'horizontalalignment','center');
text([-2 -1 0 1 2],repmat(.88*jump_height,5,1),num2cell([totals(1) totals(2) height(complete_data) totals(3) totals(4)]),'horizontalalignment','center');
line([-2.5 2.5],[(jump_rate+5) (jump_rate+5)],'color',rgb('black'),'linewidth',1.2,'parent',gca);
line([-2.5 2.5],[(jump_rate-5) (jump_rate-5)],'color',rgb('black'),'linewidth',1.2,'parent',gca);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,2,3)
jump_frame = sort(cell2mat(jumping_data.frame_of_take_off)./6);


plot(sort(jump_frame),'o');
p = polyfit(1:1:length(jump_frame),jump_frame',1);
set(gca,'nextplot','add');
new_y = polyval(p,1:1:length(jump_frame));
plot(1:1:length(jump_frame),new_y','-k');
set(gca,'Ylim',[0 2100]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot(2,2,4)
full_diff = cellfun(@(x,y) ((x-y)/6),jumping_data.frame_of_take_off,jumping_data.frame_of_wing_movement);
full_diff(full_diff >= 90) = [];


pf_truncpoiss = @(x,lambda) poisspdf(x,lambda);
start = mean(full_diff);
[lambdaHat,lambdaCI] = mle(full_diff, 'pdf',pf_truncpoiss, 'start',start, 'lower',0);

options = statset('MaxIter',500);
obj = gmdistribution.fit(full_diff,2,'Options',options);
new_x = linspace(0,80,10000);
y_all=pdf(obj,new_x');

set(gca,'nextplot','add');

[hist_val,hist_x] = hist(full_diff,0:2.5:90);        
hist_val = hist_val ./ max(hist_val);
y_all = y_all ./ max(y_all);

[AX,H1,H2] = plotyy(hist_x,hist_val,new_x,y_all,'bar','line');
set(H1,'Barwidth',1,'facecolor',rgb('light blue'),'edgecolor',rgb('black'));
set(H2,'linewidth',1.2,'color',rgb('black'));
set(AX,'Xlim',[-5 95]);