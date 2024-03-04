function sphere_testing

    rnd = 1;
    samples = 50;
    circ_dist = 100;
    
    figure;
    set(gca,'nextplot','add');

    points = [];
    offset = 2./samples;
    increment = pi * (3 - sqrt(5));

    for i = 1:samples
        y = ((i * offset) - 1) + (offset / 2);
        r = sqrt(1 - y.^2) * circ_dist;

        phi = mod((i + rnd), samples) * increment;

        x = cos(phi) * r * circ_dist;
        z = sin(phi) * r * circ_dist;

        plot3(x,y,z,'ko');
%        points.append([x,y,z])

    end
%% draw circles at 15 degree elevation cut off points
%figure
%set(gca,'nextplot','add')
bot_ring_width = 100;
for iterZ = 1:7
    ring_height = (((iterZ-1)/7)*bot_ring_width);
    ring_width = bot_ring_width - ring_height;
    x_ring = -ring_width:.01:ring_width;
    x_ring(end) = ring_width;
    y_bot = -sqrt(ring_width.^2 - x_ring.^2);
    y_top = sqrt(ring_width.^2 - x_ring.^2);


    plot3(x_ring,y_top,repmat(ring_height,1,length(x_ring)),'-k','linewidth',1.5);
    plot3(x_ring,y_bot,repmat(ring_height,1,length(x_ring)),'-k','linewidth',1.5);
    line([0 0],[-ring_width ring_width],[ring_height ring_height],'color',rgb('light gray'),'linewidth',.7);
    line([-ring_width ring_width],[0 0],[ring_height ring_height],'color',rgb('light gray'),'linewidth',.7);
end
axis equal
set(gca,'Ylim',[-bot_ring_width bot_ring_width],'Xlim',[-bot_ring_width bot_ring_width],'Zlim',[0 bot_ring_width])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  top hex ring size 1
    iterZ = 7;
    ring_height = (((iterZ-1)/7)*bot_ring_width);
    ring_width = bot_ring_width - ring_height;
    hex_width = bot_ring_width/7;
    center = [ring_width-hex_width,0];

    x_off = .5*hex_width;
    y_off = 1*hex_width;
    line([-x_off+center(1)    x_off+center(1)],[-y_off+center(2) -y_off+center(2)],[ring_height ring_height]);      line([ -x_off+center(1) -2*x_off+center(1)],[-y_off+center(2)    0.0+center(2)],[ring_height ring_height]);    
    line([-2*x_off+center(1) -x_off+center(1)],[   0.0+center(2)  y_off+center(2)],[ring_height ring_height]);      line([ -x_off+center(1)    x_off+center(1)],[ y_off+center(2)  y_off+center(2)],[ring_height ring_height]);    
    line([ x_off+center(1)  2*x_off+center(1)],[ y_off+center(2)    0.0+center(2)],[ring_height ring_height]);      line([2*x_off+center(1)    x_off+center(1)],[   0.0+center(2)  -y_off+center(2)],[ring_height ring_height]);           

 %%
    for iterZ = 6:-1:1
        prev_height = ring_height;

%        ring_height = (((iterZ-1)/7)*bot_ring_width);
        hex_width = bot_ring_width/7;

        x_off = .5*hex_width;
        y_off = .5*hex_width;
        new_y_pos = (prev_height - ring_height+hex_width/2)+(hex_width*(6-iterZ));

        center  = [0,-new_y_pos];
        draw_lines(x_off,y_off,center,ring_height,prev_height)

        center  = [0,new_y_pos];
        draw_lines(x_off,y_off,center,prev_height,ring_height)
        
        center  = [hex_width,hex_width];
        draw_lines_rotate(x_off,y_off,center,ring_height,prev_height)
    end     
end
function draw_lines(x_off,y_off,center,ring_height,prev_height)
    half_height = (prev_height-ring_height)/2 + ring_height;
        
    line([-x_off+center(1)    x_off+center(1)],[-y_off+center(2) -y_off+center(2)],[ring_height ring_height]); 
    line([ -x_off+center(1) -2*x_off+center(1)],[-y_off+center(2)    0.0+center(2)],[ring_height half_height]);    
    line([-2*x_off+center(1) -x_off+center(1)],[   0.0+center(2)  y_off+center(2)],[half_height prev_height]);  
    line([ -x_off+center(1)    x_off+center(1)],[ y_off+center(2)  y_off+center(2)],[prev_height prev_height]);    
    line([ x_off+center(1)  2*x_off+center(1)],[ y_off+center(2)    0.0+center(2)],[prev_height half_height]);  
    line([2*x_off+center(1)    x_off+center(1)],[   0.0+center(2)  -y_off+center(2)],[half_height ring_height]);           
end
function draw_lines_rotate(x_off,y_off,center,ring_height,prev_height)
    half_height = (prev_height-ring_height)/2 + ring_height;
    line([2*center(1) 3/2*center(1)],[-1/2*center(2) -3/2*center(2)],[ring_height ring_height])
    line([center(1) 3/2*center(1)],[-3/2*center(2) -3/2*center(2) ],[half_height ring_height])
    
    line([center(1) 3/2*center(1)],[0*center(2) 0*center(2) ],[prev_height half_height])
    line([3/2*center(1) 2*center(1)],[0*center(2) -1/2*center(2) ],[half_height ring_height])
    
    
    
    line([1*center(1) 3/2*center(1)],[3/2*center(2) 1.0*center(2)],[half_height ring_height]);
    
    
    line([ -x_off+center(1)    x_off+center(1)],[ y_off+center(2)  y_off+center(2)],[prev_height prev_height]);
    line([ x_off+center(1)  2*x_off+center(1)],[ y_off+center(2)    0.0+center(2)],[prev_height half_height]);
    line([2*x_off+center(1)    x_off+center(1)],[   0.0+center(2)  -y_off+center(2)],[half_height ring_height]);
    line([-x_off+center(1)    x_off+center(1)],[-y_off+center(2) -y_off+center(2)],[ring_height ring_height]);
    line([ -x_off+center(1) -2*x_off+center(1)],[-y_off+center(2)    0.0+center(2)],[ring_height half_height]);
    line([-2*x_off+center(1) -x_off+center(1)],[   0.0+center(2)  y_off+center(2)],[half_height prev_height]);
end

function random_other

for iterP = 1:4
    for iterZ = 7:-1:1
        ring_height = (((iterZ-1)/7)*bot_ring_width);
        ring_width = bot_ring_width - ring_height;
        hex_width = bot_ring_width/7;
        if iterP == 1
            center = [ring_width-hex_width,0];
        elseif iterP == 2
            center = [0,ring_width-hex_width];
        elseif iterP == 3
            center = [-ring_width+hex_width,0];
        elseif iterP == 4
            center = [0,-ring_width+hex_width];
        end

        x_off = .5*hex_width;
        y_off = 1*hex_width;
        line([-x_off+center(1)    x_off+center(1)],[-y_off+center(2) -y_off+center(2)],[ring_height ring_height]);      line([ -x_off+center(1) -2*x_off+center(1)],[-y_off+center(2)    0.0+center(2)],[ring_height ring_height]);    
        line([-2*x_off+center(1) -x_off+center(1)],[   0.0+center(2)  y_off+center(2)],[ring_height ring_height]);      line([ -x_off+center(1)    x_off+center(1)],[ y_off+center(2)  y_off+center(2)],[ring_height ring_height]);    
        line([ x_off+center(1)  2*x_off+center(1)],[ y_off+center(2)    0.0+center(2)],[ring_height ring_height]);      line([2*x_off+center(1)    x_off+center(1)],[   0.0+center(2)  -y_off+center(2)],[ring_height ring_height]);           
    end
end

%%        
figure;

x_off = 0:1.5:(5*1.5);
stop_val =  15;
for iterP = 0:1:(length(x_off)-1)
    for iterZ = 1:13
        if iterP == 0
            stop_val = 15;
        elseif iterP == 1
            stop_val = (7-(iterP-1)):(8+(iterP-1));     %iter P == 1
        else
            stop_val = (7-(iterP)):(8+(iterP-1));     %iter P == 1
        end
        
        if ismember(iterZ,stop_val) && x_off(iterP+1) ~= 0
            continue
        elseif iterZ > 6 && x_off(iterP+1) ~= 0
            center = [0+x_off(iterP+1) iterZ-(7-iterP)-(2*iterP)];
        else 
            center = [0+x_off(iterP+1) iterZ-(7-iterP)];
        end
        
        if iterZ < 8
            ring_height = ((iterZ-1)/(7-1))*8;
        else
             ring_height = ((13-iterZ)/(7-1))*8;
        end

        line([-0.5+center(1) 0.5+center(1)],[-1.0+center(2) -1.0+center(2)],[ring_height ring_height]);           line([-0.5+center(1) -1.0+center(1)],[-1.0+center(2) 0.0+center(2)],[ring_height ring_height]);    
        line([-1.0+center(1) -.5+center(1)],[0.0+center(2)  1.0+center(2)],[ring_height ring_height]);            line([-0.5+center(1) 0.5+center(1)],[ 1.0+center(2)  1.0+center(2)],[ring_height ring_height]);    
        line([ 0.5+center(1) 1.0+center(1)],[ 1.0+center(2) 0.0+center(2)],[ring_height ring_height]);            line([ 1.0+center(1)  .5+center(1)],[0.0+center(2)  -1.0+center(2)],[ring_height ring_height]);           

        x_data = [-0.5+center(1)  0.5+center(1)  1.0+center(1)  .5+center(1) -.5+center(1) -1.0+center(1)  -.5+center(1)];
        y_data = [-1.0+center(2) -1.0+center(2)  0.0+center(2) 1.0+center(2) 1.0+center(2) 0.0+center(2)  -1.0+center(2)];
        z_data = [ring_height       ring_height   ring_height    ring_height   ring_height   ring_height     ring_height];
        patch(x_data,y_data,z_data,rgb('red'),'facealpha',.5);  
        
        if x_off(iterP+1) ~= 0
            if iterZ <= 6
                center = [0-x_off(iterP+1) iterZ-(7-iterP)];
            else
                center = [0-x_off(iterP+1) (iterZ-(7-iterP))-(2*iterP)];
            end

            line([-0.5+center(1) 0.5+center(1)],[-1.0+center(2) -1.0+center(2)],[ring_height ring_height]);           line([-0.5+center(1) -1.0+center(1)],[-1.0+center(2) 0.0+center(2)],[ring_height ring_height]);    
            line([-1.0+center(1) -.5+center(1)],[0.0+center(2)  1.0+center(2)],[ring_height ring_height]);            line([-0.5+center(1) 0.5+center(1)],[ 1.0+center(2)  1.0+center(2)],[ring_height ring_height]);    
            line([ 0.5+center(1) 1.0+center(1)],[ 1.0+center(2) 0.0+center(2)],[ring_height ring_height]);            line([ 1.0+center(1)  .5+center(1)],[0.0+center(2) -1.0+center(2)],[ring_height ring_height]);           

            x_data = [-0.5+center(1)  0.5+center(1)  1.0+center(1)  .5+center(1) -.5+center(1) -1.0+center(1)  -.5+center(1)];
            y_data = [-1.0+center(2) -1.0+center(2)  0.0+center(2) 1.0+center(2) 1.0+center(2) 0.0+center(2)  -1.0+center(2)];
            z_data = [ring_height       ring_height   ring_height    ring_height   ring_height   ring_height     ring_height];
            patch(x_data,y_data,z_data,rgb('red'),'facealpha',.5);
        end
    end
    set(gca,'Ylim',[-8 8],'Xlim',[-8 8],'Zlim',[0 8])
end
end
