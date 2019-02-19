%  Pattern Separation
%  test = Generate the result file
% by LAQ

function SPST(group_code, subject_code)

%****************load result of StopSignalTask********%
openfile = dir(sprintf('Results/StopSignal_formal_Group%03d_Sub%03d*', group_code, subject_code));
filename=sprintf('%s%s','Results/',openfile.name);
load(filename(:),'Seeker');

%*************Keyboard Setting***********%
KbName('UnifyKeyNames');
Old = KbName('f'); % Key 1
Lure = KbName('h'); % Key 2
New = KbName('j'); % Key 3

%**********Counting Task Duration***********%
Task_Duration = ones(1,2);
Task_Duration(1) = GetSecs;

%***********Generate the Testing File******%
test_old =  table();
test_lure = table();
test_new = readtable('test_new');
test_old = Seeker(Seeker.Repetition == 1, :);

oldvariables = test_old.Properties.VariableNames;
newvariables = {'PicID','PicNam','PicSet','ShortDescription','old_simil_new','similarlevel','similar_score'};
[~,LOCB] = ismember(newvariables,oldvariables);
test_old = test_old(:,LOCB);

test_lure = test_old;

for i = 1:height(test_lure)
    a = cell2mat(test_lure.PicNam(i));
    b = strrep(a,'a','b');
    test_lure.PicNam(i) = {b};
    test_lure.old_simil_new(i) = 2;
end
test = table();
test = [test_old; test_lure; test_new];

%******************RANDOM TRIALS************%
test.testorder = randperm(height(test))';
test = sortrows(test,'testorder','ascend');

%***************DEVIDE BLOCK**************%
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
            sq=imread('MateStop/SPST_ins.jpg','jpg');
        else
            sq=imread('MateStop/SPST_next.jpg','jpg');
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
            fname = sprintf('%s%d%s','.\PictureSet\set',test.PicSet(totalcnt),'\',char(test.PicNam(totalcnt)));
            im = imread(fname);
            tex=Screen('MakeTexture', w, im);
            Screen('DrawTexture', w, tex, [], [], 0);
            vbl = Screen('Flip', w, vbl + fixTimeSecs - 0.5 * ifi);
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
                    if keyCode(Old)
                        test.testresponse(totalcnt) = 1;
                        test.RT(totalcnt) = GetSecs-start_time;
                        noresp = false;
                        test.absolutetime(totalcnt) = GetSecs-anchor; %absolute time since beginning of block
                        totalcnt = totalcnt + 1;  %%% this update the overall counter
                        flag = 1;
                        break;
                    elseif keyCode(Lure)
                        test.testresponse(totalcnt) = 2;
                        test.RT(totalcnt) = GetSecs-start_time;
                        noresp = false;
                        test.absolutetime(totalcnt) = GetSecs-anchor; %absolute time since beginning of block
                        totalcnt = totalcnt + 1;  %%% this update the overall counter
                        flag = 1;
                        break;
                    elseif keyCode(New)
                        test.testresponse(totalcnt) = 3;
                        test.RT(totalcnt) = GetSecs-start_time;
                        noresp = false;
                        test.absolutetime(totalcnt) = GetSecs-anchor; %absolute time since beginning of block
                        totalcnt = totalcnt + 1;  %%% this update the overall counter
                        flag = 1;
                        break;
                    elseif keyCode(escapeKey)
                        Task_Duration(2) = GetSecs-Task_Duration(1);
                        c=clock;
                        outfile=sprintf('SPST_Results/SPST_999_Group%03d_Sub%03d_%s_%02.0f_%02.0f.mat',group_code,subject_code,date,c(4),c(5));
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
        outfile=sprintf('SPST_Results/SPST_Group%03d_Sub%03d_%s_%02.0f_%02.0f.mat',group_code,subject_code,date,c(4),c(5));
        save(outfile, 'test','Task_Duration');
        sca;
        
        catch exception
            Task_Duration(2) = GetSecs-Task_Duration(1);
            c=clock;
            outfile=sprintf('SPST_Results/SPST_999_Group%03d_Sub%03d_%s_%02.0f_%02.0f.mat',group_code,subject_code,date,c(4),c(5));
            save(outfile, 'test','Task_Duration');
            sca;
            
    end
    
    Screen('CloseAll');
    Priority(0);
    rethrow(exception);
    
end
