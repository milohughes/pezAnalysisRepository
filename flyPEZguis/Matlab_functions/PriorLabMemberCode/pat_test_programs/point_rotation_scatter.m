
function point_rotation_scatter
    %rotational code
    %135 - 225 :: facing neg x :: neg_x - pos_x
    %45 - 135  :: facing neg y :: neg_y - pos_x
    %315 - 45  :: facing pos x :: pos_x - pos_x
    %225 - 315 :: facing pos y :: pos_y - pos_x

    repositoryDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repositoryDir,'Support_Programs'))
    
    test_id = '0080000022700592';
    track_names = struct2dataset(dir(['Y:\Data_pez3000_analyzed' filesep test_id filesep test_id '_flyAnalyzer3000_v13']));
    track_names = track_names.name(3:end);
    
    rand_names = track_names(round(rand(4,1)*length(track_names)));
    figure
    for iterZ = 1:4
        track_data = load(['Y:\Data_pez3000_analyzed' filesep test_id filesep test_id '_flyAnalyzer3000_v13' filesep rand_names{iterZ}]);
        track_data = track_data.saveobj;        
        track_points = cell2mat(track_data.bot_points_and_thetas);
        if isempty(track_points)
            continue
        end

    %     auto_data = load('Y:\Data_pez3000_analyzed\0080000022700592\0080000022700592_automatedAnnotations.mat');
    %     auto_data = auto_data.automatedAnnotations;
    %     auto_data = auto_data(track_data.Properties.RowNames,:);
    %    stim_start = cell2mat(auto_data.visStimFrameStart);

        vid_stats = load(['Y:\Data_pez3000_analyzed' filesep test_id filesep test_id '_videoStatisticsMerged.mat']);
        vid_stats = vid_stats.videoStatisticsMerged;
        vid_stats = vid_stats(track_data.Properties.RowNames,:);

        frame_vector = unique(double([cell2mat(vid_stats.cutrate10th_frame_reference)';cell2mat(vid_stats.supplement_frame_reference)]));
    %    [~,start_point] = min(abs(frame_vector - stim_start));
        start_point = frame_vector(1);
        [~,end_point] = min(abs(frame_vector - (frame_vector(end)-300)));
    
        subplot(2,2,iterZ)
        set(gca,'ydir','reverse');
        set(gca,'nextplot','add','Xgrid','on','Ygrid','on');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
try
        org_cm_points_x = track_points(start_point:end_point,1);
        org_cm_points_y = track_points(start_point:end_point,2);
        org_cm_roation = track_points(start_point:end_point,3);
catch
    warning('range issue?')
end

        smoothed_x = smooth(org_cm_points_x,60);        %30 ms
        smoothed_y = smooth(org_cm_points_y,60);        %30 ms

        scatter(smoothed_x(1:50:end),smoothed_y(1:50:end));

        u = cos(org_cm_roation(1:50:end));
        v = -sin(org_cm_roation(1:50:end));

        quiver(smoothed_x(1:50:end),smoothed_y(1:50:end),u,v);    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        centers = [smoothed_x(1),smoothed_y(1)];
        out_radii = sqrt((max(smoothed_x) - min(smoothed_x))^2 + (max(smoothed_y) - min(smoothed_y))^2);
        make_circle_lines(out_radii,centers,'orange')    

        [stim_x,stim_y] = pol2cart(cell2mat(track_data.stimulus_azimuth)+2*pi+5*pi/180,out_radii,0);
        stim_y = stim_y * -1;
        plot(stim_x + smoothed_x(1),stim_y + smoothed_y(1),'o','color',rgb('green'),'markersize',5)

        line([smoothed_x(1) (stim_x + smoothed_x(1))],[smoothed_y(1) (stim_y + smoothed_y(1))],'color',rgb('dark green'),'parent',gca,'linewidth',0.75);

        [stim_x,stim_y] = pol2cart(cell2mat(track_data.stimulus_azimuth)+2*pi-5*pi/180,out_radii,0);
        stim_y = stim_y * -1;
        plot(stim_x + smoothed_x(1),stim_y + smoothed_y(1),'o','color',rgb('green'),'markersize',5)
        line([smoothed_x(1) (stim_x + smoothed_x(1))],[smoothed_y(1) (stim_y + smoothed_y(1))],'color',rgb('dark green'),'parent',gca,'linewidth',0.75);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end
function make_circle_lines(radii,centers,color)
%    distance = sqrt((trk_cm_x-org_cm_x)^2 + (trk_cm_y-org_cm_y)^2);
%    radii = distance ;       centers = [org_cm_x,org_cm_y];
    
    thetaResolution = 2;        theta=(0:thetaResolution:360)'*pi/180;
    x = bsxfun(@times,radii',cos(theta));   x = bsxfun(@plus,x,(centers(:,1))');
    x = cat(1,x,nan(1,length(radii)));      x = x(:);

    y = bsxfun(@times,radii',sin(theta));   y = bsxfun(@plus,y,(centers(:,2))');
    y = cat(1,y,nan(1,length(radii)));      y = y(:);
    line(x,y,'Parent',gca,'Color',rgb(color),'LineWidth',1);    
    
    
    ylimit = [min(y),max(y)];           xlimit = [min(x),max(x)];
%    set(gca,'Xlim',[min(x)-1 max(x)+1],'Ylim',[min(y)-1 max(y)+1]);
    line([centers(1) centers(1)],ylimit,'color',rgb('black'),'linewidth',0.8)
    line(xlimit,[centers(2) centers(2)],'color',rgb('black'),'linewidth',0.8)  
end