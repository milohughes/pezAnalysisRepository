function read_erica_data
    addpath('Z:\Erica\test_courtship\BatchSongAnalysis')
    addpath('Z:\Erica\test_courtship\BatchSongAnalysis\chronux')
    addpath('Z:\Erica\test_courtship\BatchSongAnalysis\SplitVec')    

%    genotype_of_interest = 'SS47120';
%    genotype_of_interest = 'SS45772';
    genotype_of_interest = 'SS01062';
%    channel_path = 'Z:\Erica\test_courtship\activation\20171205103909_1644000G5X_out';
    channel_path = 'Z:\Erica\activation\20171220110327_1644000G5X_out';

%    pulse_interval_info = csvread('Z:\Erica\test_courtship\activation\courtshiperica.txt');
    pulse_interval_info = csvread('Z:\Erica\activation\courtshiperica_update.txt');
    pulse_count = length(pulse_interval_info(:,1));
    pulse_header_list = arrayfun(@(x,y,z) sprintf('pulse_%.0f_pct_%.0f_dur_%2.0f',x,y,z),(1:1:pulse_count)',pulse_interval_info(:,1),pulse_interval_info(:,2),'uniformoutput',false);
    
    all_data = [];    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    file_dir = dir('Z:\Erica\test_courtship\activation\20171205103909_1644000G5X_Results_LLR=0_20171205205409');
    file_dir = dir('Z:\Erica\activation\20171220110327_1644000G5X_Results_LLR=0_20180102133200');
    file_dir = struct2dataset(file_dir);
    file_dir = file_dir(cellfun(@(x) ~isempty(strfind(x,'channel')),file_dir.name),:);

    file_dir = file_dir(cellfun(@(x) ~isempty(strfind(x,genotype_of_interest)),file_dir.name),:);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    channel_dir = dir(channel_path);
    channel_dir = struct2dataset(channel_dir);
    channel_dir = channel_dir(cellfun(@(x) ~isempty(strfind(x,'channel')),channel_dir.name),:);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    geno_index = cellfun(@(x) strfind(x,'channel'),file_dir.name,'uniformoutput',false);
    geno_index = cellfun(@(x,y) x(y:end),file_dir.name,geno_index,'uniformoutput',false);
    geno_index = cellfun(@(x) x(1:strfind(x,genotype_of_interest)-2),geno_index,'uniformoutput',false);

    channel_index = cellfun(@(x) strfind(x,'channel'),channel_dir.name,'uniformoutput',false);
    channel_index = cellfun(@(x,y) x(y:end),channel_dir.name,channel_index,'uniformoutput',false);
    channel_index = regexprep(channel_index,'.mat','');

    [locA,~] = ismember(channel_index,geno_index);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load_list = channel_dir.name(locA);

    for iterZ = 1:length(load_list)
        dummy_load_var = load([channel_path filesep load_list{iterZ}]);
        dummy_load_var = struct2dataset(dummy_load_var);
        all_data = [all_data;dummy_load_var];        
    end
    all_data = set(all_data,'ObsNames',load_list);
    
    parsed_data = cell2dataset([cell(1,pulse_count);repmat({struct('Stats2Plot',[],'AllStats',[])},size(all_data,1),(length(pulse_interval_info(:,2))))]);
    parsed_data = set(parsed_data,'VarNames',pulse_header_list);
    pulse_header_list = get(parsed_data,'VarNames');
    parsed_data = set(parsed_data,'ObsNames',load_list);
    
    all_data = [all_data,parsed_data];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
    for iterZ = 1:size(all_data,1)
        fprintf('Analyzing file :: %s ', load_list{iterZ})        
        tic
        test_rate = all_data.Data(iterZ).fs;
        pulse_cut_offs = [1;cumsum(pulse_interval_info(:,2)).*test_rate];
        [Data,sines,Pulses,pulses,IpiTrains,Pauses,Bouts,pulseMFFT,sineMFFT,culled_ipi,culled_End2Peakipi,culled_End2Startipi,PulseModelMFFT,ipiDist] = AnalyzeChannel_parsed(all_data.Pulses(iterZ),all_data.Sines(iterZ),all_data.Data(iterZ),50);

        for iterP = 1:(length(pulse_cut_offs)-1);
            cut_offs = [pulse_cut_offs(iterP)-1 pulse_cut_offs(iterP+1)];
            [Stats2Plot, AllStats] = parse_song_stats(Data,cut_offs,sines,Pulses,pulses,IpiTrains,Pauses,Bouts,pulseMFFT,sineMFFT,culled_ipi,culled_End2Peakipi,culled_End2Startipi,PulseModelMFFT,ipiDist);

            all_data.(pulse_header_list{iterP})(iterZ).Stats2Plot = Stats2Plot;
            all_data.(pulse_header_list{iterP})(iterZ).AllStats = AllStats;
        end
        fprintf('    Took %4.4f seconds\n',toc)        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    filt_header_list = pulse_header_list(cellfun(@(x) isempty(strfind(x,'pct_0')),pulse_header_list));
    percent_used = cellfun(@(y,z) z(y:(y+5)),cellfun(@(x) strfind(x,'pct_'),filt_header_list,'uniformoutput',false),filt_header_list,'uniformoutput',false);
    pct_count = length(percent_used);
    
    figure
    for iterZ = 1:pct_count
        index = (iterZ-1)*(6-1)+iterZ;
        subplot(pct_count,6,index); pulses_per_minute(all_data,pulse_header_list,percent_used{iterZ},'PulseTrainsPerMin');   
        subplot(pct_count,6,index+1); pulses_per_minute(all_data,pulse_header_list,percent_used{iterZ},'PulsesPerMin');   
        subplot(pct_count,6,index+2); pulses_per_minute(all_data,pulse_header_list,percent_used{iterZ},'SineTrainsPerMin');
        subplot(pct_count,6,index+3); pulses_per_minute(all_data,pulse_header_list,percent_used{iterZ},'SinePerMin');   
        subplot(pct_count,6,index+4); pulses_per_minute(all_data,pulse_header_list,percent_used{iterZ},'BoutsPerMin');   
        subplot(pct_count,6,index+5); pulses_per_minute(all_data,pulse_header_list,percent_used{iterZ},'SongPerMin');   
    end   
end
function pulses_per_minute(all_data,pulse_header_list,pct_str,variable_string)
    pct_10_index = find(cellfun(@(x) ~isempty(strfind(x,pct_str)),pulse_header_list),1,'first');
    pct_10_var = struct2dataset(vertcat(all_data.(pulse_header_list{pct_10_index})(:)));        
    pct_10_ctrl_before = struct2dataset(vertcat(all_data.(pulse_header_list{pct_10_index-1})(:)));    
%    pct_10_ctrl_after = struct2dataset(vertcat(all_data.(pulse_header_list{pct_10_index+1})(:)));        
    
    pct_10_var = struct2dataset(vertcat(pct_10_var.Stats2Plot));                                
    pct_10_ctrl_before = struct2dataset(vertcat(pct_10_ctrl_before.Stats2Plot));
%    pct_10_ctrl_after = struct2dataset(vertcat(pct_10_ctrl_after.Stats2Plot));

    manwhity_test = ranksum(pct_10_ctrl_before.(variable_string),pct_10_var.(variable_string));
        
    set(gca,'nextplot','add')
    scatter(rand(length(pct_10_ctrl_before.(variable_string)),1)*.5 -.25,pct_10_ctrl_before.(variable_string),50,rgb('black'));          %-0.25 to 0.25
    if manwhity_test > 0.05
        scatter(rand(length(pct_10_var.(variable_string)),1)*.5 +.75,pct_10_var.(variable_string),50,rgb('blue'));                       %0.75 to 1.25
    else    %significant difference
         scatter(rand(length(pct_10_var.(variable_string)),1)*.5 +.75,pct_10_var.(variable_string),50,rgb('red'));                       %0.75 to 1.25
    end
    set(gca,'Xtick',0:1:1,'box','off','xlim',[-.25 1.25],'XtickLabel',{'Before','During'})
    curr_ylim = get(gca,'ylim');
    line([.5 .5],curr_ylim,'color',rgb('gray'),'linewidth',.7,'parent',gca);

    line([0.4 0.4],[quantile(pct_10_ctrl_before.(variable_string),.25) quantile(pct_10_ctrl_before.(variable_string),.75)],'color',rgb('gray'),'linewidth',1.2)
    line([.35 0.45],[quantile(pct_10_ctrl_before.(variable_string),.5) quantile(pct_10_ctrl_before.(variable_string),.50)],'color',rgb('gray'),'linewidth',1.2)
    if manwhity_test > 0.05
        line([.6 .6],[quantile(pct_10_var.(variable_string),.25) quantile(pct_10_var.(variable_string),.75)],'color',rgb('blue'),'linewidth',1.2)
        line([0.55 .65],[quantile(pct_10_var.(variable_string),.5) quantile(pct_10_var.(variable_string),.50)],'color',rgb('blue'),'linewidth',1.2)
    else
        line([.6 .6],[quantile(pct_10_var.(variable_string),.25) quantile(pct_10_var.(variable_string),.75)],'color',rgb('red'),'linewidth',1.2)
        line([0.55 .65],[quantile(pct_10_var.(variable_string),.5) quantile(pct_10_var.(variable_string),.50)],'color',rgb('red'),'linewidth',1.2)        
    end
    
    title(sprintf('%s :: %s',pct_str,variable_string),'Interpreter','none','HorizontalAlignment','center','fontsize',14);
end