%  Remember-Know Paradigm
%  test = Generate the result file
% by LAQ

function RK(group_code, subject_code)
%% load result of StopSignalTask
openfile = dir(sprintf('Results/StopSignal_formal_Group%03d_Sub%03d*', group_code, subject_code));
filename=sprintf('%s%s','Results/',openfile.name);
load(filename(:),'Seeker');

%% Keyboard Setting
KbName('UnifyKeyNames');
% KbName('KeyNamesWindows');
Rem = KbName('1!'); % Key 1
Know = KbName('2@'); % Key 2
Unsure= KbName('3#'); % Key 3
New= KbName('4$'); % Key 4
Task_Duration = ones(1,2);
Task_Duration(1) = GetSecs;

%% Generate the Testing File
test_old =  table(); test_lure = table();
test_new = readtable('info/test_new');
test_old = Seeker(Seeker.lag == 0, :);
test_old.old_simil_new = ones(height(test_old),1);
oldvariables = test_old.Properties.VariableNames;
newvariables = {'PicID','PicNam','PicSet','ShortDescription','old_simil_new','similarlevel','similar_score'};
[~,LOCB] = ismember(newvariables,oldvariables);
test_old = test_old(:,LOCB);
test_lure = test_old;
%% change the picture name for similar
for i = 1:height(test_lure)
    a = cell2mat(test_lure.PicNam(i));
    b = strrep(a,'a','b');
    test_lure.PicNam(i) = {b};
    test_lure.old_simil_new(i) = 2;
end
test = table();
test = [test_old; test_lure; test_new];

%% RANDOM TRIALS
test.order = randperm(height(test))';
test = sortrows(test,'order','ascend');

%% DEVIDE BLOCK
NBLOCKS = 4;
h = height(test);
j = NBLOCKS;
for k = 1:j
    test.block((k-1)*h/j+1:(k*h/j),1) = k;
end
%% Define Onsettime
% test.onsettime = zeros(height(test),1);
% test.onsettime(1:end) = (test.order(1:end)-(test.block(1:end)-1)*h/j)*4.5;
%%
try
    %*********GET SRCEEN READY*********%
    pixelSize = 32;
    scrn = 0;
    HideCursor;
    w = Screen('OpenWindow',scrn,255);  % open a white screen
    ifi = Screen('GetFlipInterval',w); % flip interval
    vbl = Screen('Flip',w);
    rect = Screen (w,'rect');
    Priority(MaxPriority(w));   % raise priority for better timing
    black = BlackIndex(w);
    white = WhiteIndex(w);
    xcenter = rect(3)/2;
    ycenter = rect(4)/2;
    theFont = 'Arial';
    fixTimeSecs = 0.5; % fixtion duration
    fixTimeFrames = round(fixTimeSecs / ifi);
    isiTimeSecs = 6; % stimulation duration
    isiTimeFrames = round(isiTimeSecs / ifi);
    totalcnt = 1;  % this is the overall counter
%     test.testresponse = zeros(height(test),1);
%     test.RT = zeros(height(test),1);
%     test.absolutetime= zeros(height(test),1);
    %*************BLOCK LOOP*************%
    for block = 1:NBLOCKS % change number of blocks
        if block ==1
            sq=imread('MateStop/RK_ins.jpg','jpg');
        else
            sq=imread('MateStop/RK_next.jpg','jpg');
        end
        tex=Screen('MakeTexture',w,sq);
        Screen('DrawTexture',w,tex);
        vbl = Screen('Flip', w, vbl  - 0.5 * ifi);
        KbWait;
        anchor=GetSecs;
        %*******************TRIAL LOOP************%
        for totalcnt = (h/j*(block-1)+1) : (h/j*block)
            % Draw the Fixation Point
            Screen('DrawDots', w, [xcenter; ycenter], 10, black, [], 2);
            vbl = Screen('Flip', w, vbl  - 0.5 * ifi);
            bnchor = GetSecs; % trial onsettime start
            % here can add trigger
            % Draw the stimulation
            fname = sprintf('%s%d%s','.\PictureSet\set',test.PicSet(totalcnt),'\',char(test.PicNam(totalcnt)));
            im = imread(fname);
            tex=Screen('MakeTexture', w, im);
            Screen('DrawTexture', w, tex, [], [], 0);
            vbl = Screen('Flip', w, vbl + (fixTimeFrames - 0.5) * ifi);
            start_time = vbl;
            noresp = true;
            notone = true;
            FlushEvents('keyDown');
            while(GetSecs-start_time < isiTimeSecs && noresp)
                % ********Check the keyboard. The person should press******%
                escapeKey = KbName('ESCAPE');
                [keyIsDown,~,keyCode] = KbCheck;
                flag = 0;
                if keyIsDown
                    if find(keyCode) == Rem || find(keyCode) == Know || find(keyCode) == Unsure || find(keyCode) == New
                        test.response(totalcnt) = find(keyCode)-48;
                        test.RT(totalcnt) = GetSecs-start_time;
                        noresp = false;
                        test.absolutetime(totalcnt) = GetSecs-anchor; %absolute time since beginning of block
                        test.trialtime(totalcnt) = GetSecs-bnchor; % time for each trial
                        totalcnt = totalcnt + 1;  %%% this update the overall counter
                        flag =1;
                        break;
                    elseif find(keyCode) == KbName('ESCAPE')
                        Task_Duration(2) = GetSecs-Task_Duration(1);
                        c=clock;
                        outfile=sprintf('RK_Results/RK_999_Group%03d_Sub%03d_%s_%02.0f_%02.0f.mat',group_code,subject_code,date,c(4),c(5));
                        save(outfile, 'test','Task_Duration');
                        sca;
                        return;
                    end
                end
            end
            if flag == 1
                vbl = Screen('Flip', w, vbl - 0.5 * ifi);
                continue;
            end
            vbl = Screen('Flip', w, vbl + isiTimeSecs - 0.5 * ifi);
            test.absolutetime(totalcnt) = GetSecs-anchor; %absolute time since beginning of block
            test.trialtime(totalcnt) = GetSecs-bnchor; % time for each trial
            totalcnt = totalcnt + 1;  %%% this update the overall counter
        end
        
        %*************RELAX OR END INSTRUCTION*********%
        if block<4
            im = imread('MateStop/test_relax.jpg','jpg');
            tex=Screen('MakeTexture', w, im);
            Screen('DrawTexture', w, tex);
            vbl = Screen('Flip', w);
            vbl = Screen('Flip', w, vbl + 10 - 0.5 * ifi);
        else
            im = imread('MateStop/test_end.jpg','jpg');
            tex=Screen('MakeTexture', w, im);
            Screen('DrawTexture', w, tex);
            vbl = Screen('Flip', w);
            vbl = Screen('Flip', w, vbl + 5 - 0.5 * ifi);
        end
    end
    
    Task_Duration(2) = GetSecs-Task_Duration(1);
    c=clock;
    outfile=sprintf('RK_Results/RK_Group%03d_Sub%03d_%s_%02.0f_%02.0f.mat',group_code,subject_code,date,c(4),c(5));
    save(outfile, 'test','Task_Duration');
    sca;
    
catch exception
    Task_Duration(2) = GetSecs-Task_Duration(1);
    c=clock;
    outfile=sprintf('RK_Results/RK_999_Group%03d_Sub%03d_%s_%02.0f_%02.0f.mat',group_code,subject_code,date,c(4),c(5));
    save(outfile, 'test','Task_Duration');
    sca;
    
end

Screen('CloseAll');
Priority(0);
rethrow(exception);

end
