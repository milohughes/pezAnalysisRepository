function [ merged_im ] = textN2im_v2( raw_im,txt_cell,font_size,pos_refs,just,kerning,filterSize )
%textN2im Merges text from cell into image
%   'text_cell' must be a cell vector generated using cellstr.  'raw_im'
%   must be class 'double' ranging from 0 to 1.  'pos_refs' shall indicate
%   position of the text on the image, beginning at the top, left.  It must
%   be in the form [m,n], where m is the percentage of the first dimension
%   and n is the second.  'm' and 'n' must be between 0 and 1.
if nargin <= 5
    text_name = ['asciiImages_fontsize_' int2str(font_size)];
    textCrop = 0;
end
if nargin > 5
    text_name = ['evenspace_asciiImages_fontsize_' int2str(font_size)];
    textCrop = font_size-round(font_size*kerning);
end
if nargin <= 6
    filterSize = 0;
end
if nargin <= 4
    just = 'left';
end
if ~iscell(txt_cell)
    txt_cell = {txt_cell};
end
line_count = length(txt_cell);
func_name = mfilename('fullpath');
parent_dir = fileparts(func_name);
text_dir = fullfile(parent_dir,'textImages_labelmaker');
full_dir = fullfile(text_dir,text_name);
ascii_cell = importdata([full_dir '.mat']);

txt_im_lines = cell(line_count,1);
length_tally = zeros(line_count,1);
for i = 1:line_count
    txt_line = txt_cell{i};
    if isinteger(txt_line) == 1
        txt_line = int2str(txt_line);
    elseif isa(txt_line,'double') == 1
        txt_line = num2str(txt_line,2);
    elseif isempty(txt_line) == 1
        txt_line = ' ';
    end
    char_count = length(txt_line);
    txt_im_cell = cell(1,char_count);
    for j = 1:char_count
        char_ref = double(txt_line(j)-31);
        if char_ref < 1, char_ref = 1; end
        txt_im_cell{j} = ascii_cell{char_ref}(:,textCrop+1:end-textCrop);
    end
    txt_im_lines{i} = cat(2,txt_im_cell{:});
    length_tally(i) = size(txt_im_lines{i},2);
end

max_length = max(length_tally);
txt_height = size(txt_im_lines{1},1);
for i = 1:line_count
    txt_im_lines{i}(txt_height,max_length) = 0;
end
txt_block = cat(1,txt_im_lines{:});
if filterSize > 2
    txt_block = imfilter(txt_block,fspecial('disk',filterSize));
end

imAdjInput = stretchlim(txt_block,[0.01 0.999]);
txt_block = imadjust(txt_block,imAdjInput);

txt_dims = size(txt_block);
im_dims = size(raw_im);
im_dims = im_dims(1:2);
if min(im_dims-txt_dims) < 0
    error('Text is larger than the image. Use a smaller font')
end

switch just
    case 'left'
        x_pos1 = round(im_dims(2)*pos_refs(1));
        x_pos2 = x_pos1+txt_dims(2);
        y_pos2 = round(im_dims(1)*pos_refs(2));
        y_pos1 = y_pos2-txt_dims(1);
    case 'right'
        x_pos2 = round(im_dims(2)*pos_refs(1));
        x_pos1 = x_pos2-txt_dims(2);
        y_pos2 = round(im_dims(1)*pos_refs(2));
        y_pos1 = y_pos2-txt_dims(1);
    case 'center'
        x_pos1 = round(pos_refs(1)*(im_dims(2)-txt_dims(2)))+1;
        x_pos2 = x_pos1+txt_dims(2)-1;
        y_pos2 = round(im_dims(1)*pos_refs(2));
        y_pos1 = y_pos2-txt_dims(1);
end

merged_im = raw_im;
if x_pos1 < 0
    x_pos2 = abs(x_pos1)+x_pos2+1;
    x_pos1 = abs(x_pos1)+x_pos1+1;
end
if y_pos1 < 0
    y_pos2 = abs(y_pos1)+y_pos2+1;
    y_pos1 = abs(y_pos1)+y_pos1+1;
end
if x_pos2 > im_dims(2)
    x_pos1 = x_pos1-(x_pos2-im_dims(2));
    x_pos2 = x_pos2-(x_pos2-im_dims(2));
end
if y_pos2 > im_dims(1)
    y_pos1 = y_pos1-(y_pos2-im_dims(1));
    y_pos2 = y_pos2-(y_pos2-im_dims(1));
end
if isa(raw_im,'uint8') == 1
    txt_blockB = uint8(txt_block.*255);
    if size(raw_im,3) == 3
        txt_blockB = repmat(txt_blockB,[1 1 3]);
    end
    merged_im(y_pos1+1:size(txt_blockB,1)+y_pos1,x_pos1+1:size(txt_blockB,2)+x_pos1,:) = txt_blockB;
else
    merged_im(y_pos1+1:y_pos2,x_pos1+1:x_pos2) = txt_block;
end