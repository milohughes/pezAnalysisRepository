
figure
top_plot = subplot(3,1,1);      set(top_plot,'nextplot','add')
mid_plot = subplot(3,1,2);      set(mid_plot,'nextplot','add')
bot_plot = subplot(3,1,3);      set(bot_plot,'nextplot','add')

index = 1;
for iterZ = 20:10:40
    ttc = -atan(iterZ./(-500:1:0))*360/pi;         ttc(end) = 180;
    plot(top_plot,-500:1:0,ttc);
    
    ttc_diff= diff(ttc);
    cut_off = find(ttc_diff > .2,1,'first');
    plot(mid_plot,(-500+cut_off):1:0,ttc_diff(cut_off:end));
    
    ttc_diff = diff(diff(ttc));
    cut_off = find(ttc_diff > .005,1,'first');
    plot(bot_plot,(-499+cut_off):1:0,ttc_diff(cut_off:end));
    
end