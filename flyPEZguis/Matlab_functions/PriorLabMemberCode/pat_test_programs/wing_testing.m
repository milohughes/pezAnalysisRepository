
load('Z:\Data_pez3000_analyzed\0087000022700665\0087000022700665_wing_click_points.mat')

y_data = cell2mat(Wing_Click_Points.Wing_Position_Y);
mod_y_data = cell2mat(arrayfun(@(x) (y_data(:,x) - y_data(:,1))*-1,1:1:10,'uniformoutput',false));
mod_y_data(mod_y_data<0) = 0;



max_y_pos = max(832-cell2mat(Wing_Click_Points.Wing_Position_Y),[],2);
min_y_pos = min(832-cell2mat(Wing_Click_Points.Wing_Position_Y),[],2);
duration = cell2mat(Wing_Click_Points.Frame_Vector_list);
frame_dur = cell2mat(arrayfun(@(x) (duration(:,x) - duration(:,1)),1:1:10,'uniformoutput',false));

figure
set(gca,'nextplot','add');
for iterZ = 1:19
    plot(frame_dur(iterZ,:),mod_y_data(iterZ,:),'-o');
end