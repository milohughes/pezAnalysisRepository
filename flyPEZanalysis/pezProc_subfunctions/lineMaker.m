function I_lined = lineMaker(I)

filt_pad = [5 5];
se = strel('disk',3,0);
I_temp = padarray(I,filt_pad,'replicate');
I_temp = colfilt(I_temp,[5 5],'sliding',@iqr);
I_temp(isnan(I_temp) == 1) = 0;
I_temp = (imtophat(I_temp,se).^0.75)./0.33;
I_temp(I_temp > 1) = 1;
I_lined = imcrop(I_temp,[filt_pad+1 fliplr(size(I))-1]);
I_lined(I_lined == 0) = min(I_lined(I_lined > 0));