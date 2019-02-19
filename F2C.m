%  Forced to choose from 2(old/lure)
%  test = Generate the result file
% by LAQ

function F2C(group_code, subject_code)

%****************load result of StopSignalTask********%
openfile = dir(sprintf('Results/StopSignal_formal_Group%03d_Sub%03d*', group_code, subject_code));
filename=sprintf('%s%s','Results/',openfile.name);
load(filename(:),'Seeker');

%*************Keyboard Setting***********%
KbName('UnifyKeyNames');
Left = KbName('f'); % Key 1
Right = KbName('j'); % Key 2

%**********Counting Task Duration***********%
Task_Duration = ones(1,2);
Task_Duration(1) = GetSecs;

%***********Generate the Testing File******%
test =  table();
test = Seeker(Seeker.block == 1, :);
test.testorder = randperm(height(test))'; % random trials
test.oldposition = randperm(height(test))'; % random the position of old/lure
for i = 1:height(test)
    switch mod(test.oldposition(i),2)
        case 1
            test.oldposition(i) = 1;
        case 0
            test.oldposition(i) = 2;
    end
end
test = sortrows(test,'testorder','ascend');

%*********DEVIDE BLOCK**********%
test.testblock(1:(0.25*height(test)),1) = 1;
test.testblock((0.25*height(test)+1):(0.5*height(test)),1) = 2;
test.testblock((0.5*height(test)+1):(0.75*height(test)),1) = 3;
test.testblock((0.75*height(test)+1):height(test),1) = 4;

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
    
    Lpixel = [];
    Rpixel = [];
    
    fixTimeSecs = 0.5; % fixtion duration
    fixTimeFrames = round(fixTimeSecs / ifi);
    isiTimeSecs = 4; % stimulation duration
    isiTimeFrames = round(isiTimeSecs / ifi);
    NBLOCKS = 4; % block number
    totalcnt = 1;  % this is the overall counter
    
    test.testresponse = zeros(height(test),1);
    test.RT = zeros(height(test),1);
    test.absolutetime= zeros(height(test),1);
    
    %*************BLOCK LOOP*************%
    for block = 1:NBLOCKS % change number of blocks
        if block ==1
            sq = imread('MateStop/F2C_ins.jpg','jpg');
        else
            sq = imread('MateStop/F2C_next.jpg','jpg');
        end
        tex=Screen('MakeTexture',w,sq);
        Screen('DrawTexture',w,tex);
        vbl = Screen('Flip', w, vbl  - 0.5 * ifi);
        KbWait;
        
        anchor=GetSecs;
        
        %*******************TRIAL LOOP************%
        for totalcnt = (0.25*height(test)*(block-1)+1) : (0.25*height(test)*block)
            
            % Draw the fixation point
            Screen('DrawDots', w, [xcenter; ycenter], 10, black, [], 2);
            vbl = Screen('Flip', w, vbl  - 0.5 * ifi);
            
            % Draw the stimulation
            olditem = cell2mat(test.PicNam(totalcnt));
            lureitem = strrep(olditem,'a','b');
            fname_old = sprintf('%s%d%s','.\PictureSet\set',test.PicSet(totalcnt),'\', olditem);
            fname_lure = sprintf('%s%d%s','.\PictureSet\set',test.PicSet(totalcnt),'\', lureitem);
            % arrange the positions of old & lure 
            if test.oldposition(totalcnt) == 1
                LPIC = imread(fname_old);
                RPIC = imread(fname_lure);
            else
                LPIC = imread(fname_lure);
                RPIC = imread(fname_old);
            end        
            [M,N,P] = size(LPIC); % get pixel information(leftpic)
            [U,V,W] = size(RPIC); % get pixel information(rightpic)
            Lindex = Screen('MakeTexture', w, LPIC);
            Rindex = Screen('MakeTexture', w, RPIC);
            GRect = Screen('Rect', Lindex);
            GRect = Screen('Rect', Rindex);
            Screen('DrawTexture', w, Lindex, GRect, [xcenter-100-N, ycenter-M/2, xcenter-100, ycenter+M/2]); % left up right down
            Screen('DrawTexture', w, Rindex, GRect, [xcenter+100, ycenter-U/2, xcenter+100+V, ycenter+U/2]);  
            vbl = Screen('Flip', w, vbl + fixTimeSecs - 0.5 * ifi);
            start_time = vbl;
            noresp = true;
            FlushEvents('keyDown');
            
            while(GetSecs-start_time < isiTimeSecs && noresp) 
            % ********Check the keyboard. The person should press******%
            escapeKey = KbName('ESCAPE');
            [keyIsDown,~,keyCode] = KbCheck;
            flag =0;
            if keyIsDown
                if keyCode(Left)
                    switch test.oldposition(totalcnt)
                        case 1
                            test.testresponse(totalcnt) = 1;
                            test.RT(totalcnt) = GetSecs-start_time;
                        case 2
                            test.testresponse(totalcnt) = 2;
                            test.RT(totalcnt) = GetSecs-start_time;
                    end
                    noresp = false;
                    test.absolutetime(totalcnt) = GetSecs-anchor; %absolute time since beginning of block
                    totalcnt = totalcnt + 1;  %%% this update the overall counter
                    flag = 1;
                    break;
                elseif keyCode(Right)
                    switch test.oldposition(totalcnt)
                        case 1
                            test.testresponse(totalcnt) = 2;
                            test.RT(totalcnt) = GetSecs-start_time;
                        case 2
                            test.testresponse(totalcnt) = 1;
                            test.RT(totalcnt) = GetSecs-start_time;
                    end
                    noresp = false;
                    test.absolutetime(totalcnt) = GetSecs-anchor; %absolute time since beginning of block
                    totalcnt = totalcnt + 1;  %%% this update the overall counter
                    flag = 1;
                    break;
                elseif keyCode(escapeKey)
                    Task_Duration(2) = GetSecs-Task_Duration(1);
                    c=clock;
                    outfile=sprintf('F2C_Results/Force2Choose_999_Group%03d_Sub%03d_%s_%02.0f_%02.0f.mat',group_code,subject_code,date,c(4),c(5));
                    save(outfile, 'test','Task_Duration');
                    sca;
                    return;
                end
            end
            end
            
            if flag ==1 
                vbl = Screen('Flip', w, vbl - 0.5 * ifi);
                continue;
            end
            
            vbl = Screen('Flip', w, vbl + isiTimeSecs - 0.5 * ifi);
            test.absolutetime(totalcnt) = GetSecs-anchor; %absolute time since beginning of block
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
    outfile=sprintf('F2C_Results/Force2Choose_Group%03d_Sub%03d_%s_%02.0f_%02.0f.mat',group_code,subject_code,date,c(4),c(5));
    save(outfile, 'test','Task_Duration');
    sca;
    
catch exception
    Task_Duration(2) = GetSecs-Task_Duration(1);
    c=clock;
    outfile=sprintf('F2C_Results/Force2Choose_999_Group%03d_Sub%03d_%s_%02.0f_%02.0f.mat',group_code,subject_code,date,c(4),c(5));
    save(outfile, 'test','Task_Duration');
    sca;
    
end

Screen('CloseAll');
Priority(0);
rethrow(exception);

end
