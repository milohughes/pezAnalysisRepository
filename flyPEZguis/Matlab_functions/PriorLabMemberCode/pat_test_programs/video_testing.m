vidObj_partail = VideoReader('\\DM11\cardlab\Data_pez3000\20171204\run015_pez3001_20171204\run015_pez3001_20171204_expt0108000024150730_vid0001.mp4');
vidStats = load('Z:\Data_pez3000_analyzed\0108000024150730\0108000024150730_videoStatisticsMerged.mat');
vidStats = vidStats.videoStatisticsMerged;
test_vid = vidStats('run015_pez3001_20171204_expt0108000024150730_vid0001',:);

frmData = 0;
for iterZ = 1:10
    frmData = frmData + sum(read(vidObj_partail,iterZ),3);
end

[I,J] = find(frmData > 2500);

figure; 
scatter(J,I,25,rgb('red'));
set(gca,'Ydir','reverse','nextplot','add','ylim',[0 832],'Xlim',[0 384])


roi = cell2mat(test_vid.roi);

line([roi(1,1) roi(2,1)],[roi(1,2) roi(2,2)]);
line([roi(3,1) roi(3,1)],[roi(1,2) roi(2,2)]);
line([roi(1,1) roi(3,1)],[roi(1,2) roi(1,2)]);
line([roi(1,1) roi(3,1)],[roi(2,2) roi(2,2)]);
line([roi(7,1) roi(8,1)],[roi(7,2) roi(8,2)]);

ellipse_t = fit_ellipse( J(I<384),I(I<384),gca );

[I,J] = find(frmData > 50 & frmData < 500);
scatter(J,I,25,rgb('green'));
