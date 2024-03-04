function I_filt = hotFilter(I)
height = size(I,1);
width = size(I,2);
blk_ct1 = round(height/96);
blk_ct2 = round(width/96);
block_filt = @(x) (x.data-prctile(x.data(:),2))./(prctile(x.data(:),98)-prctile(x.data(:),2));
h_log = fspecial('log',[48 48],0.1);
I_filt = filter2(h_log,I);
I_filt = (I_filt-min(I_filt(:)))./range(I_filt(:));
I_filt = adapthisteq(I_filt,'NumTiles',[blk_ct1 blk_ct2],'ClipLimit',.01,'Distribution','rayleigh','Alpha',1);
I_filt = blockproc(I_filt,[24 24],block_filt,'BorderSize',[32 32],...
    'PadPartialBlocks',true,'PadMethod','symmetric');
I_filt(I_filt <= 0) = 0.01;
I_filt(I_filt > 1) = 1;
