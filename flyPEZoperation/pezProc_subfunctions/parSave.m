function parSave(savepath,saveobj,savetype)
if ~exist('savetype','var')
    savetype = 'data';
end
switch savetype
    case 'data'
        save(savepath,'saveobj')
    case 'image'
        imwrite(savepath,saveobj,'jpg');
end
