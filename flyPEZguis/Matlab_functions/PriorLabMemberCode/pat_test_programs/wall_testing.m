    figure
    cax = gca;
    rmin = 0;       
    rmax = 90; 
    
    set(gca,'nextplot','add');
    
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
    
    for iterZ = 0:90:270
        wall_deg = (iterZ-7.5):(iterZ+7.5);
        th = wall_deg .*pi/180;
    
        xunit = cos(th);
        yunit = sin(th);
        if ~ischar(get(cax, 'Color'))
            patch('XData', xunit * rmax, 'YData', yunit * rmax, ...
                'EdgeColor', rgb('red'), 'FaceColor', rgb('red'), ...
                'HandleVisibility', 'off', 'Parent', cax);
        end    
    end
    
    off_angle = 45;
    th_angles = 0:off_angle:180;
    th = th_angles .* pi/180;

    cst = cos(th);
    snt = sin(th);    
    
    
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
    set(gca,'Xtick',[],'Ytick',[],'Xlim',[-110 110],'Ylim',[-110 110])
    box off
    axis equal
    
    off_th = th + (off_angle/2)*pi/180;
    cst = cos(off_th);
    snt = sin(off_th);
    cs = [-cst; cst];
    sn = [-snt; snt];
    
    %rinc = 22.5;
    rinc = 0;
    
    newx_max = reshape((rmax*cs),length(th)*2,1);
    newx_start = reshape((rinc*cs),length(th)*2,1);
    
    newy_max = reshape((rmax*sn),length(th)*2,1);
    newy_start = reshape((rinc*sn),length(th)*2,1);
    
    for iterA = 1:length(newx_start)
        line([newx_start(iterA), newx_max(iterA)],[newy_start(iterA),newy_max(iterA)], 'LineStyle', ls, 'Color', rgb('grey'), 'LineWidth', 1, ...
        'HandleVisibility', 'off', 'Parent', cax);
    end    