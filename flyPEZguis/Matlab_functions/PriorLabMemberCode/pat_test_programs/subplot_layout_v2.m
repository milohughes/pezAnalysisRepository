function subplot_layout_v2
    figure
    subplot(3,4,[1,2]);     
    subplot(3,4,[3,4]);     
    subplot(3,4,[5,6]);     
    subplot(3,4,[7,8]);     
    subplot(3,4,[9,10]);
    
    child_handels = get(gcf,'children');        %handles to each of the subplots
    old_pos = get(child_handels(1),'position');
    old_pos(1) = .3500;     old_pos(2) = .075;
    set(child_handels(1),'position',old_pos);
    
    old_pos = get(child_handels(3),'position'); old_pos(2) = old_pos(2) - .025; 
    old_pos(1) = .1;    set(child_handels(3),'position',old_pos);
    
    old_pos = get(child_handels(5),'position');
    old_pos(1) = .1;    set(child_handels(5),'position',old_pos);

    old_pos = get(child_handels(4),'position');
    old_pos(1) = old_pos(1) + 0.05;
    set(child_handels(4),'position',old_pos);
    

    old_pos = get(child_handels(2),'position');
    old_pos(2) = old_pos(2) - .025; old_pos(1) = old_pos(1) + 0.05;
    set(child_handels(2),'position',old_pos);
    

%    mTextBox = uicontrol('style','text','units','normalized');
%    set(mTextBox,'String','Take off Rates for Canton S Across Multiple Protocols')
%    set(mTextBox,'Position',[.13 .95 .775 .05],'fontsize',15,'horizontalalignment','center');

    set(gca,'nextplot','add');

%     hp = uipanel;
%     set(hp,'position',[.01 .05 .07 .95])
%     ha = axes('Parent',hp,'Visible','off');
%     ht = text('Parent',ha,'String','Take off Percentages','rotation',90,'fontsize',20);
%     set(ht,'position',[.5 .5 0],'HorizontalAlignment','center')
end
