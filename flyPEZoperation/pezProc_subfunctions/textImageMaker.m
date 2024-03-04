function textImageMaker

clear all
close all
clc

func_name = mfilename('fullpath');
parent_dir = fileparts(func_name);
dest_dir = fullfile(parent_dir,'textImages');
if isdir(dest_dir) == 0, mkdir(dest_dir), end
font_sizes = (8:11);
text_asc = char(32:127);
char_count = length(text_asc);
font_count = length(font_sizes);

for j = 1:font_count
    font_size = font_sizes(j);
    spacing = round(font_size/8);
    blank_im = ones(font_size*1.5,font_size*2);
    ascii_cell = cell(char_count,1);
    for i = 1:char_count
        imshow(blank_im)
        text(font_size,font_size*0.75,text_asc(i),'FontSize',font_size,...
            'HorizontalAlignment','center')
        text_frame = getframe;
        text_im = double(text_frame.cdata(:,:,1)./255);
        if i == 1
            ascii_cell{i} = abs(text_im(:,1:round(font_size/2))-1);
            continue
        end
        width_finder = min(text_im);
        text_begin = find(width_finder == 0,1,'first')-spacing;
        text_end = find(width_finder == 0,1,'last')+spacing;
        text_im = text_im(:,text_begin:text_end);
        text_im = abs(text_im-1);
        ascii_cell{i} = text_im;
    end
    dest_name = ['asciiImages_fontsize_' int2str(font_size)];
    full_dest = fullfile(dest_dir,dest_name);
    save(full_dest,'ascii_cell')
end