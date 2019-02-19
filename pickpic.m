pic = readtable('info\ApicSelect.txt');
OutputDir = 'C:\Users\AnqiLi\OneDrive\StopSignalTask\Pic';
for i = 1:height(pic)
    fname = sprintf('%s%d%s','.\PictureSet\set',pic.PicSet(i),'\',char(pic.PicNam(i)));
    im = strcat(fname);
    copyfile(im, OutputDir);
    s = sprintf('%d%s',pic.PicSet(i),char(pic.PicNam(i)));
    movefile([OutputDir '\' char(pic.PicNam(i))],[OutputDir '\' s]);
end