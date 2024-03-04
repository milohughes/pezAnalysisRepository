figure
set(gca,'nextplot','add');
durations = [500,250,125,85,65,50];
intensitys = [5,10,20,30,40,50] ./ 100;
exposure = intensitys .* durations; 

temp_range = [22.0,24.0];
remove_low = false;
low_count = 7;
combine_data = []; 

load_files = [{'0099000023960701'};{'0099000023960704'};{'0099000023960705'};{'0099000023960707'};{'0099000023960708'};{'0099000023960709'}];

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
%%
all_data = vertcat(combine_data(:).Complete_usuable_data);
jumping_data = all_data(cellfun(@(x) ~isempty(x),all_data.frame_of_leg_push),:);
jumping_data = jumping_data(cellfun(@(x) ~isnan(x),jumping_data.frame_of_leg_push),:);
new_start_frame = cellfun(@(x) find(x.nidaq_data <= 225,1,'first')-2,jumping_data.photoactivation_info);
pre_stim_jump = cell2mat(jumping_data.frame_of_wing_movement) < new_start_frame;
jumping_data(pre_stim_jump,:) = []; new_start_frame(pre_stim_jump) = [];

full_diff = ((cell2mat(jumping_data.frame_of_leg_push) - cell2mat(jumping_data.frame_of_wing_movement)) ./ 6);
jumping_data(full_diff > 100,:) = []; new_start_frame(full_diff > 100) = [];
full_diff(full_diff > 100) = [];

pct_intensity = cellfun(@(x) str2double(x(strfind(x,'intensity')+9:end)),jumping_data.photoStimProtocol);
pct_intensity = pct_intensity ./ 100;

wing_stroke = ((cell2mat(jumping_data.wing_down_stroke) - new_start_frame)./6) .* pct_intensity;
%%
figure
all_f = [];
for iterZ = 1:6
    subplot(3,2,iterZ)

    scatter(wing_stroke(pct_intensity == intensitys(iterZ)),full_diff(pct_intensity == intensitys(iterZ)))
    title(sprintf('Intensity :: %4.0f, jumpers :: %4.0f',intensitys(iterZ)*100,sum((pct_intensity == intensitys(iterZ)))));
end
%%

for iterZ = 1:6
    subplot(3,2,iterZ)

    line([0 0],[0 exposure(iterZ)],'color',rgb('blue'));
    line([0 durations(iterZ)],[exposure(iterZ) exposure(iterZ)],'color',rgb('blue'));
    line([durations(iterZ) durations(iterZ)],[0 exposure(iterZ)],'color',rgb('blue'));
    line([durations(iterZ) durations(iterZ)+300],[0 0],'color',rgb('blue'));

    line([0 durations(iterZ)],[0 exposure(iterZ)],'color',rgb('red'));
    line([durations(iterZ) durations(iterZ)+300],[exposure(iterZ) exposure(iterZ)],'color',rgb('red'));
end