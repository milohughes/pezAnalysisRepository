
function point_rotation(stim_pos,test_pos)
    %rotational code
    %135 - 225 :: facing neg x :: neg_x - pos_x
    %45 - 135  :: facing neg y :: neg_y - pos_x
    %315 - 45  :: facing pos x :: pos_x - pos_x
    %225 - 315 :: facing pos y :: pos_y - pos_x

    repositoryDir = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repositoryDir,'Support_Programs'))
    
    track_data = load('Y:\Data_pez3000_analyzed\0080000022700592\0080000022700592_flyAnalyzer3000_v13\run008_pez3002_20160627_expt0080000022700592_vid0006_flyAnalyzer3000_v13_data.mat');
    track_data = track_data.saveobj;
    
    auto_data = load('Y:\Data_pez3000_analyzed\0080000022700592\0080000022700592_automatedAnnotations.mat');
    auto_data = auto_data.automatedAnnotations;
    auto_data = auto_data(track_data.Properties.RowNames,:);
    stim_start = cell2mat(auto_data.visStimFrameStart);
    
    track_points = cell2mat(track_data.bot_points_and_thetas);
    last_track = length(track_points(:,1))-600;

    figure
    subplot(2,2,1)
    set(gca,'ydir','reverse');
    set(gca,'nextplot','add','Xgrid','on','Ygrid','on');
    
    if nargin  > 0
        org_cm_x = stim_pos(1);     org_cm_y = stim_pos(2);     org_angle = stim_pos(3);
        trk_cm_x = test_pos(1);     trk_cm_y = test_pos(2);     trk_angle = test_pos(3);    
    else
        org_cm_x = track_points(stim_start,1);     org_cm_y = track_points(stim_start,2);     org_angle = track_points(stim_start,3);
        trk_cm_x = track_points(last_track,1);     trk_cm_y = track_points(last_track,2);     trk_angle = track_points(last_track,3);
    end
    org_head_x =cos(org_angle)*25+org_cm_x;          org_head_y = -sin(org_angle)*25+org_cm_y;
%    trk_head_x =cos(trk_angle)*25+trk_cm_x;          trk_head_y = -sin(trk_angle)*25+trk_cm_y;

    trk_head_x =cos(org_angle)*25+trk_cm_x;          trk_head_y = -sin(org_angle)*25+trk_cm_y;
    
    out_radii = sqrt((trk_cm_x-org_cm_x)^2 + (trk_cm_y-org_cm_y)^2);
    inn_radii = sqrt((org_head_x-org_cm_x)^2 + (org_head_y-org_cm_y)^2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    plot(org_cm_x,org_cm_y,'.r','markersize',30);    plot(org_head_x,org_head_y,'.r','markersize',15);
    line([org_cm_x org_head_x],[org_cm_y org_head_y],'color',rgb('red'),'linewidth',1);
    
    plot(trk_cm_x,trk_cm_y,'.b','markersize',30);    plot(trk_head_x,trk_head_y,'.b','markersize',15);
    line([trk_cm_x trk_head_x],[trk_cm_y trk_head_y],'color',rgb('blue'),'linewidth',1);
    
    centers = [org_cm_x,org_cm_y];
    make_circle_lines(inn_radii,centers,'green')
    make_circle_lines(out_radii,centers,'orange')
    
    title('raw data no transformation or rotation');    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    subplot(2,2,2)
    set(gca,'ydir','reverse');
    set(gca,'nextplot','add','Xgrid','on','Ygrid','on');
    
    trk_head_x = trk_head_x - org_cm_x;         trk_head_y = trk_head_y - org_cm_y;
    trk_cm_x = trk_cm_x - org_cm_x;             trk_cm_y = trk_cm_y - org_cm_y;

    org_head_x = org_head_x - org_cm_x;         org_head_y = org_head_y - org_cm_y;
    org_cm_x = org_cm_x - org_cm_x;             org_cm_y = org_cm_y - org_cm_y;

    plot(org_cm_x,org_cm_y,'.r','markersize',30);    plot(org_head_x,org_head_y,'.r','markersize',15);
    line([org_cm_x org_head_x],[org_cm_y org_head_y],'color',rgb('red'),'linewidth',1);
    
    plot(trk_cm_x,trk_cm_y,'.b','markersize',30);    plot(trk_head_x,trk_head_y,'.b','markersize',15);
    line([trk_cm_x trk_head_x],[trk_cm_y trk_head_y],'color',rgb('blue'),'linewidth',1);
    
    centers = [0,0];    
    make_circle_lines(inn_radii,centers,'green')
    make_circle_lines(out_radii,centers,'orange')
    
    title(sprintf('data aligend so that orgional CM is 0,0\n red is orginal, blue is tracked point'));
    
    line([0 trk_cm_x],[0 trk_cm_y])
    line([org_head_x trk_head_x],[org_head_y trk_head_y])    
        
%    move_back =  org_head_x - trk_head_x;
%    move_down = org_head_y - trk_head_y;
%    total_move = sqrt((org_head_y - trk_head_y)^2 + (org_head_x - trk_head_x)^2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
    org_angle = org_angle * 180/pi;
%    rot_angle = sort(org_angle:-90:1);
%    rot_angle = [rot_angle,min(rot_angle)+270];
        
    new_cm_pos = rotation([org_cm_x org_cm_y],[0,0],org_angle,'degrees');       %org pos is 135
    new_head_pos = rotation([org_head_x org_head_y],[0,0],org_angle,'degrees');       %org pos is 135
    new_head_pos = (round((new_head_pos).*10000))./10000;

    trk_cm_pos = rotation([trk_cm_x trk_cm_y],[0,0],org_angle,'degrees');       %est 240
    trk_cm_pos = (round((trk_cm_pos).*10000))./10000;
    trk_head_pos = rotation([trk_head_x trk_head_y],[0,0],org_angle,'degrees');       %org pos is 135
    trk_head_pos = (round((trk_head_pos).*10000))./10000;

    subplot(2,2,3)
    set(gca,'ydir','reverse');
    set(gca,'nextplot','add','Xgrid','on','Ygrid','on');

    plot(new_cm_pos(1),new_cm_pos(2),'.r','markersize',30);    plot(new_head_pos(1),new_head_pos(2),'.r','markersize',15);
    line([new_cm_pos(1) new_head_pos(1)],[new_cm_pos(2) new_head_pos(2)],'color',rgb('red'),'linewidth',1);

    plot(trk_cm_pos(1),trk_cm_pos(2),'.b','markersize',30);    plot(trk_head_pos(1),trk_head_pos(2),'.b','markersize',15);
    line([trk_cm_pos(1) trk_head_pos(1)],[trk_cm_pos(2) trk_head_pos(2)],'color',rgb('blue'),'linewidth',1);

    title(sprintf('data aligend so that orgional CM is 0,0 and rotated around 0,0\n red is orginal, blue is tracked point'));

    centers = [0,0];   
    make_circle_lines(inn_radii,centers,'green')
    make_circle_lines(out_radii,centers,'orange')

    line([0 trk_cm_pos(1)],[0 trk_cm_pos(2)])
    line([new_head_pos(1) trk_head_pos(1)],[new_head_pos(2) trk_head_pos(2)])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
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