%test_data_1 =  Experiment_ID('0069000016860523');       test_data_2 =  Experiment_ID('0069000016860525');
%test_data_1 =  Experiment_ID('0069000001640523');       test_data_2 =  Experiment_ID('0069000001640525');
test_data_1 =  Experiment_ID('0058000003330437');       test_data_2 =  Experiment_ID('0071000005440528');

test_data_1.load_data;      test_data_1.make_tables;
test_data_2.load_data;      test_data_2.make_tables;

test_data_1.get_tracking_data;            test_data_1.display_data
test_data_2.get_tracking_data;            test_data_2.display_data

all_data = [test_data_1.Complete_usuable_data;test_data_2.Complete_usuable_data];
all_data(cellfun(@(x) isempty(x), all_data.frame_of_leg_push),:) = [];
all_data(cellfun(@(x) isnan(x), all_data.frame_of_leg_push),:) = [];

%%
%wing_cycle = cellfun(@(x,y) log10((x-y)./6 /log10(2)),all_data.wing_down_stroke,all_data.frame_of_wing_movement);
wing_cycle = cellfun(@(x,y) (x-y)./6,all_data.wing_down_stroke,all_data.frame_of_wing_movement);
leg_delay = cellfun(@(x,y) (x-y)/6,all_data.frame_of_leg_push,all_data.start_frame);
remove_data = wing_cycle > 300 | leg_delay > 350;

pez_temp = all_data.temp_degC;
pez_temp(remove_data) = [];
wing_cycle(remove_data) = [];
leg_delay(remove_data) = [];

figure
%scatter3(wing_cycle,pez_temp,leg_delay);
k_group = kmeans([wing_cycle(wing_cycle<50),leg_delay(wing_cycle<50)],3,'start','sample');
color_grid = repmat(rgb('black'),sum(wing_cycle<50),1);
color_grid(k_group == 1,:) = repmat(rgb('red'),sum(k_group == 1),1);
color_grid(k_group == 2,:) = repmat(rgb('blue'),sum(k_group == 2),1);
color_grid(k_group == 3,:) = repmat(rgb('green'),sum(k_group == 3),1);


scatter(wing_cycle(wing_cycle<50),leg_delay(wing_cycle<50),25,color_grid);