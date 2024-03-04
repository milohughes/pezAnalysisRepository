function draw_circles(cax)
    if nargin == 0
        cax = newplot(gca);
    end
    rmin = 0;       
    rmax = 90; 
    
    axGridColor = rgb('black');
    
    tc = axGridColor;
%    rticks = (90/22.5) + 1;
    rticks = (90/22.5) + 0;
    ls = get(cax, 'GridLineStyle');

    th = 0 : pi / 50 : 2 * pi;
    xunit = cos(th);
    yunit = sin(th);
    % now really force points on x/y axes to lie on them exactly
    inds = 1 : (length(th) - 1) / 4 : length(th);
    xunit(inds(2 : 2 : 4)) = zeros(2, 1);
    yunit(inds(1 : 2 : 5)) = zeros(3, 1);
    % plot background if necessary
    if ~ischar(get(cax, 'Color'))
        patch('XData', xunit * rmax, 'YData', yunit * rmax, ...
            'EdgeColor', tc, 'FaceColor', get(cax, 'Color'), ...
            'HandleVisibility', 'off', 'Parent', cax);
    end

    % draw radial circles
    rinc = (rmax - rmin) / rticks;

    for i = (rmin + rinc) : rinc : rmax
        hhh = line(xunit * i, yunit * i, 'LineStyle', ls, 'Color', tc, 'LineWidth', 1, ...
            'HandleVisibility', 'off', 'Parent', cax);
    end  
    set(hhh, 'LineStyle', '-'); % Make outer circle solid
    
    % plot spokes
%    th_angles = 0:22.5:180;
    off_angle = 45;

    th_angles = 0:off_angle:180;

    th = th_angles .* pi/180;
    off_th = th + (off_angle/2)*pi/180;
    cst = cos(off_th);
    snt = sin(off_th);
    cs = [-cst; cst];
    sn = [-snt; snt];
    
    newx_max = reshape((rmax*cs),length(th)*2,1);
    newx_start = reshape((rinc*cs),length(th)*2,1);
    
    newy_max = reshape((rmax*sn),length(th)*2,1);
    newy_start = reshape((rinc*sn),length(th)*2,1);
    
    for iterA = 1:length(newx_start)
        line([newx_start(iterA), newx_max(iterA)],[newy_start(iterA),newy_max(iterA)], 'LineStyle', ls, 'Color', rgb('grey'), 'LineWidth', 1, ...
        'HandleVisibility', 'off', 'Parent', cax);
    end
    
    cst = cos(th);
    snt = sin(th);    
        
    % annotate spokes in degrees
    rt = 1.1 * rmax;
    for i = 1 : length(th)
        text(rt * cst(i), rt * snt(i), int2str(th_angles(i)),...
            'HorizontalAlignment', 'center', ...
            'HandleVisibility', 'off', 'Parent', cax);
        if i == length(th)
            loc = int2str(0);
        else
            loc = int2str(180 + th_angles(i));
        end
        text(-rt * cst(i), -rt * snt(i), loc, 'HorizontalAlignment', 'center', ...
            'HandleVisibility', 'off', 'Parent', cax);
    end    
    %set(cax, 'DataAspectRatio', [1, 1, 1]), axis(cax, 'off');
    set(cax,'nextplot','add','Xlim',[-rmax*1.2 rmax*1.2],'Ylim',[-rmax*1.1 rmax*1.1])
    set(gca,'Xtick',[],'Ytick',[],'box','off')
%    axis equal
    
end
 