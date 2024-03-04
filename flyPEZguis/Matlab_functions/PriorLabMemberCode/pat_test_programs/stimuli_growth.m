
figure
angle_space = 10:1:180;
growth_data = -40./tan((angle_space).*pi/360);
growth_data(end) = 0;

x_data = -40./tan((10:5:180).*pi/360);
x_data(end) = 0;
x_data = [x_data,50:50:200];

subplot(2,1,1)
plot(growth_data,angle_space,'color',rgb('black'),'linewidth',1);
set(gca,'nextplot','add','Ylim',[0 210],'Xlim',[-500 250],'Xtick',x_data);
line([0 200],[180 180],'color',rgb('black'),'linewidth',1);

subplot(2,1,2)
plot(growth_data,[0,1./diff(growth_data)],'color',rgb('red'),'linewidth',1);
set(gca,'nextplot','add','Ylim',[0 3.1],'Xlim',[-500 250],'Xtick',x_data);
line([0 200],[0 0],'color',rgb('red'),'linewidth',1);

