function subplot_layout
    figure
    subplot(5,4,[1,2]);     
    subplot(5,4,[3,4]);     
    subplot(5,4,[5,6]);     
    subplot(5,4,[7,8]);     
    for iterA = 9:15
        subplot(5,4,iterA)
    end

    subplot(5,4,17:20)

    child_handels = get(gcf,'children');

    for iterA = 2:4
        plot_pos = get(child_handels(iterA),'position');
        plot_pos(1) = plot_pos(1) + 0.1;
        set(child_handels(iterA),'position',plot_pos);
    end

    mTextBox = uicontrol('style','text','units','normalized');
    set(mTextBox,'String','Take off Rates for Canton S Across Multiple Protocols')
    set(mTextBox,'Position',[.13 .95 .775 .05],'fontsize',15,'horizontalalignment','center');

    set(gca,'nextplot','add');

    hp = uipanel;
    set(hp,'position',[.01 .05 .07 .95])
    ha = axes('Parent',hp,'Visible','off');
    ht = text('Parent',ha,'String','Take off Percentages','rotation',90,'fontsize',20);
    set(ht,'position',[.5 .5 0],'HorizontalAlignment','center')
end