
dateDir = 'Y:\Data\20130118';
exptDirs = dir(dateDir);
exptDirs = {exptDirs(3:end).name};
for itA = 1:numel(exptDirs)
    datafiles = dir(fullfile(dateDir,exptDirs{itA},'*.wvd'));
    for itB = 1:numel(datafiles)
%         datafiles(itB).name
        fname = fullfile(dateDir,exptDirs{itA},datafiles(itB).name);
        fid = fopen(fname,'r');
        header_val = fread(fid,1,'long');
        fseek(fid,header_val,'bof');
        diode_data = fread(fid,'float');
        fclose(fid);
        find(diode_data > 3,1,'first')
        plot(diode_data)
        uiwait(gcf)
    end
end

