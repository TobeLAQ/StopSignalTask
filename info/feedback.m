%% FEEDBACK %%
% go RT && nogo stoprate
meanrt(block) = 1000*mean(Seeker.RT((Seeker.block(:)==block && Seeker.condition~=1 && Seeker.resp~=0 && Seeker.correctness==1));
stoprate(block) = length(Seeker.block==block && Seeker.condition==1 && Seeker.correctness==1);
% make feedback figure for each block
xvals = 1:1:NBLOCKS;
fh = figure;
subplot(2,1,1);
plot(xvals, meanrt, '.', 'markersize', 30);
axis([1 NBLOCKS 100 900]);
title('Reaction Time');
subplot(2,1,2);
plot(xvals, stoprate, '.', 'markersiaze', 30);
axis([1 NBLOCKS 0 1]);
title('Stop Rate');
fname = sprintf('Results/feedback/feedback%dgroup%dsub%d',block,group_code,subject_code);
print(fh,'-djpeg','-r100',fname);
close(fh);
fbimage = imread(fname,'jpg');
tex = Screen('MakeTexture',w,fbimage);
Screen('DrawTexture',w,tex);
DrawFormattedText(w,'Your Grade','center',rect(4)*0.9,[2550 0]);
Screen('Flip',w);
