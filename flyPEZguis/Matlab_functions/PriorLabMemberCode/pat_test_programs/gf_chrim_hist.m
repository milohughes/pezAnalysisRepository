figure; 
gf_mean = 1;    %in base 2 scale
gf_sigma = .5;  %in base 2 scale

old_x_cords = linspace(-7,7,1000);
new_y_cords = normpdf(old_x_cords,gf_mean,gf_sigma);

plot(old_x_cords,new_y_cords,'-r','linewidth',1);
set(gca,'Xlim',[-7 7]);