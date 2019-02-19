A = readtable('ApicSelect.txt');
for i = 1 : height(A)
    OutputDir = sprintf('F:/motor inhibition &memory/StopSignalTask_procedure/AllPicSelect/set%d', A.PicSet(i));
    ObjDir = sprintf('F:/motor inhibition &memory/StopSignalTask_procedure/PictureSet/set%d/%s', A.PicSet(i), char(A.PicNam(i)));
    sourcefile=strcat(ObjDir);
    copyfile(sourcefile, OutputDir);
end