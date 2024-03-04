
analysis_path = '\\tier2\card\Data_pez3000_analyzed';
new_file_path = struct2dataset(dir(analysis_path));        
exp_dir =  new_file_path.name;                                         
exp_dir = exp_dir(cellfun(@(x) length(x) == 16,exp_dir));       
exp_dir = exp_dir(cellfun(@(x) str2double(x(1:4)) >= 50,exp_dir));
vid_filter = {'frame_count','temp_degC','fly_detect_azimuth','visual_stimulus_info','photoactivation_info'};        

all_vid_data = [];

parfor iterZ = 1:length(exp_dir)
    videoStats = load([analysis_path filesep exp_dir{iterZ} filesep exp_dir{iterZ} '_videoStatisticsMerged']);
    videoStats = dataset2table(videoStats.videoStatisticsMerged(:,vid_filter));
    
    all_vid_data = [all_vid_data;videoStats];

end
%%
pez_names = cellfun(@(x) x(8:14),all_vid_data.Properties.RowNames,'uniformoutput',false);
uni_pez = unique(pez_names);
figure
%uni_pez = [{'pez3001'},{'pez3002'},{'pez3003'},{'pez3004'}];

for iterZ = 1:4
    subplot(2,2,iterZ)
    pez_logic = ismember(pez_names,uni_pez{iterZ});
    filt_data = all_vid_data(pez_logic,:);
    
    date_list = cellfun(@(x) str2double(x(16:21)),filt_data.Properties.RowNames);
    hb = boxplot(filt_data.temp_degC,date_list);
    median_data = (cell2mat(get(hb(6,:),'YData')));
    median_data = median_data(:,1);
    uni_date = unique(date_list);
    
    uni_date = arrayfun(@(x) num2str(x),uni_date,'uniformoutput',false);
    date_conv = cellfun(@(x) str2double(x(1:4)) + str2double(x(5:6))/12,uni_date);
    scatter(date_conv,median_data);
    set(gca,'Ylim',[20 25],'nextplot','add','Xlim',[2014.5 2017]);
    
%     p = polyfit(date_conv,median_data,1);
%     new_x = 2015.5:.1:2017;
%     new_y = polyval(p,new_x);
%     plot(new_x,new_y,'-r','linewidth',1);
    
    line([2014.5 2017],[min(median_data) min(median_data)],'color',rgb('grey'),'linewidth',.75);
    line([2014.5 2017],[max(median_data) max(median_data)],'color',rgb('grey'),'linewidth',.75);
    
    med_temp = median(filt_data.temp_degC);
    prob_range = sum(filt_data.temp_degC >= 22.5 & filt_data.temp_degC <= 24.0);
    prob_range = (prob_range / height(filt_data))*100;
    title(sprintf('median temperature by month for pez :: %s',uni_pez{iterZ}));
    ylabel('temperature')
    xlabel('Month experiment was run (YYYY + MM/12)');
    
%    [f,x] = hist(filt_data.temp_degC,20:.1:26);
%    bar(x,f,'barwidth',1,'facecolor',rgb('light blue'))
%    title(sprintf('count :: %5.0f      median temp :: %4.2f        \n Percent in usuable range :: %2.4f%%',sum(pez_logic),med_temp,prob_range));
%    xlabel('temperature')
%    ylabel('count')
%    set(gca,'Xlim',[20 26]);
    
%    ylimit = get(gca,'Ylim');
%    line([22.5 22.5],ylimit,'parent',gca,'linewidth',1)
%    line([24.0 24.0],ylimit,'parent',gca,'linewidth',1)
end