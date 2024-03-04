leg_path = '\\DM11\cardlab\Leg_Tracking_Data\Martin_leg_tracking_filter_v1.mat';
all_save_data = load(leg_path);
all_save_data = all_save_data.all_save_data;


all_save_data = struct2dataset(all_save_data);
new_dataset = dataset();
new_dataset.VidQuality = all_save_data.VidQuality;
new_dataset.Jump_Flag = all_save_data.Jump_Flag;
new_dataset.Fly_Orientation = all_save_data.Fly_Orientation;

new_table = dataset2table(new_dataset);
new_table.Properties.RowNames  = all_save_data.VideoName;

new_table.Click_Points = repmat(struct('Frame_Index',nan(41,2),'Left_Leg_Front',nan(41,2),'Left_Leg_Mid',nan(41,2),'Left_Leg_Hind',nan(41,2),...
                         'Right_Leg_Front',nan(41,2),'Right_Leg_Mid',nan(41,2),'Right_Leg_Hind',nan(41,2),'Center_of_Mass',nan(41,2)),length(all_save_data),1);


for iterZ = 1:length(all_save_data)
    click_points = all_save_data.Track_Points{iterZ};
    new_table.Click_Points(iterZ).Frame_Index = click_points.Frame_Number;
    new_table.Click_Points(iterZ).Left_Leg_Mid = [click_points.Left_Leg_x,click_points.Left_Leg_y];
    new_table.Click_Points(iterZ).Right_Leg_Mid = [click_points.Right_Leg_x,click_points.Right_Leg_y];
    new_table.Click_Points(iterZ).Center_of_Mass = [click_points.Center_x,click_points.Center_y];
end

all_save_data = new_table;
save('\\DM11\cardlab\Leg_Tracking_Data\Martin_leg_tracking_filter_v2.mat','all_save_data');