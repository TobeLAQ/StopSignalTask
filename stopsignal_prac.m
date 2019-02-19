function stopsignal_prac (group_code, subject_code)
%% invoking 'Stimat' function
stimat = sequence_prac(group_code, subject_code);
Seeker = stimat;
%% counting task duration
Task_Duration = ones(1,2);
Task_Duration(1) = GetSecs;
%% Define parameter
step = 50; % staircase time
totalcnt = 1;  % this is the overall counter
%% Define button
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
%% initial value of Ladder (first four stop trials)
SSD = [400; 550; 700];
Seeker.stoporder(Seeker.condition==1) = 1:height(Seeker(Seeker.condition==1,:));
for i = 1:3
    Seeker.SSD(Seeker.stoporder==i) = SSD(Seeker.LadderOrder(Seeker.stoporder==i));
end
%% partition Seeker into 4 blocks
h = height(Seeker);
j = 1; % number of block
oldvariables = Seeker.Properties.VariableNames;
newvariables = {'order','PicID','PicNam','PicSet','ShortDescription','similarlevel','similar_score','condition','in_out','LadderOrder','SSD','jitter'};
[~,LOCB] = ismember(newvariables,oldvariables);
Seeker = Seeker(:,LOCB);
try
    %% get screen ready
    pixelSize = 32;
    scrn = 0;
    HideCursor;
    w = Screen('OpenWindow',scrn,255);  % open a white screen
    ifi = Screen('GetFlipInterval',w); % flip interval
    vbl = Screen('Flip',w);
    rect = Screen (w,'rect');
    Priority(MaxPriority(w)); % raise priority for better timing
    black = BlackIndex(w);
    white = WhiteIndex(w);
    xcenter = rect(3)/2;
    ycenter = rect(4)/2;
    theFont = 'Arial';
    rectangle = [rect(3)/2-220,rect(4)/2-220,rect(3)/2+220,rect(4)/2+220];
    %% Define time
%     fixTimeSecs = 0.5; % fixtion duration
%     fixTimeFrames = round(fixTimeSecs / ifi);
    isiTimeSecs = 2; % stimulation duration
    isiTimeFrames = round(isiTimeSecs / ifi);
    %% define resp
    Seeker.resp = zeros(height(Seeker),1);
    %% BLOCK LOOP
    %*************Introduction & Keyboard************%
    switch mod(subject_code,2)
        case 0 % number is even
            IN = KbName('f'); % key 1
            OUT = KbName('j'); % key 2
            sq=imread('MateStop/ins_prac_even.jpg','jpg');  %%% even instruction
        case 1
            OUT = KbName('f'); % key 1
            IN = KbName('j'); % key 2
            sq=imread('MateStop/ins_prac_odd.jpg','jpg');  %%% odd instruction
    end
    tex=Screen('MakeTexture',w,sq); Screen('DrawTexture',w,tex); % make & draw instruction
    vbl = Screen('Flip', w, vbl  - 0.5 * ifi);
    KbWait;
    anchor=GetSecs;
    %% TRIAL LOOP
    for totalcnt = 1 : height(Seeker)
        fixTimeSecs = Seeker.jitter(totalcnt); % fixtion duration
        fixTimeFrames = round(fixTimeSecs / ifi);
        if Seeker.condition(totalcnt) == 1
            Seeker.SSD(totalcnt) = SSD(Seeker.LadderOrder(totalcnt),1); % update SSD by trial
        end
        %% Draw the Fixation Point
        Screen('DrawDots', w, [xcenter; ycenter], 10, black, [], 2);
        vbl = Screen('Flip', w, vbl  - 0.5 * ifi);
        bnchor = GetSecs; % trial onsettime start
        % here can add trigger
        %% read & draw the stimulus
        fname = sprintf('%s%d%s','.\PictureSet\set',Seeker.PicSet(totalcnt),'\',char(Seeker.PicNam(totalcnt)));
        im = imread(fname);
        tex=Screen('MakeTexture', w, im);
        Screen('DrawTexture', w, tex, [], [], 0); % make & draw stimulus
        vbl = Screen('Flip', w, vbl + (fixTimeFrames - 0.5) * ifi); % Refresh the fixation point, show the stimulus
        start_time = vbl; % RT start time
        noresp = true;
        notone = true;
        FlushEvents('keyDown');
        %% Draw the stop signal
        while(GetSecs-start_time < isiTimeSecs && noresp) %% || (Seeker.group(totalcnt)==1 && notone)
            %% Check the keyboard. The person should press
            [keyIsDown,~,keyCode] = KbCheck;
            if keyIsDown
                if keyCode(IN) || keyCode(OUT)
                    if keyCode(IN)
                        Seeker.resp(totalcnt) = 1;
                    elseif keyCode(OUT)
                        Seeker.resp(totalcnt) = 2;
                    end
                    Seeker.RT(totalcnt) = GetSecs-start_time;
                    noresp = false;
                    Seeker.absolutetime(totalcnt) = GetSecs - anchor; %absolute time since beginning of block
                    Seeker.trialtime(totalcnt) = GetSecs - bnchor;
                    Screen('Flip', w);
                    break;
                elseif keyCode(escapeKey)
                    Task_Duration(2) = GetSecs-Task_Duration(1);
                    c=clock;
                    outfile=sprintf('Results/StopSignal_prac_999_Group%03d_Sub%03d_%s_%02.0f_%02.0f.mat',group_code,subject_code,date,c(4),c(5));
                    save(outfile, 'Seeker','Task_Duration');
                    sca;
                    return;
                end
            end
            if Seeker.condition(totalcnt)==1 && GetSecs-start_time>=Seeker.SSD(totalcnt)/1000 && notone
                Screen('DrawTexture', w, tex, [], [], 0);
                Screen('FrameRect', w, [255 0 0] , rectangle, 6);
                Screen('Flip', w, vbl + Seeker.SSD(totalcnt)/1000 - 0.5 * ifi);
                notone = false;
            end
        end
        %% Change the Ladders
        if Seeker.resp(totalcnt) ~= 0 && Seeker.condition(totalcnt) == 1
            a = Seeker.LadderOrder(totalcnt);
            SSD(a,1) = SSD(a,1) - step;
            Seeker.inhibit_effect(totalcnt) = -1;
        elseif Seeker.resp(totalcnt) == 0 && Seeker.condition(totalcnt) == 1
            a = Seeker.LadderOrder(totalcnt);
            SSD(a,1) = SSD(a,1) + step;
            Seeker.inhibit_effect(totalcnt) = 1;
        end
        vbl = Screen('Flip', w, vbl + (isiTimeFrames - 0.5) * ifi);
        Seeker.absolutetime(totalcnt) = GetSecs-anchor; %absolute time since beginning of block
        Seeker.trialtime(totalcnt) = GetSecs - bnchor;
        %% judge the correctness of the response
        switch Seeker.condition(totalcnt)
            case 1
                switch Seeker.resp(totalcnt)
                    case 0
                        Seeker.correctness(totalcnt) = 1;
                    otherwise
                        Seeker.correctness(totalcnt) = 0;
                end
            otherwise
                switch Seeker.resp(totalcnt) == Seeker.in_out(totalcnt)
                    case 1
                        Seeker.correctness(totalcnt) = 1;
                    case 0
                        Seeker.correctness(totalcnt) = 0;
                end
        end
        totalcnt = totalcnt + 1;  %%% this update the overall counter
    end% end each block loop
    im = imread('MateStop/end.jpg','jpg');
    t = 5;
    tex=Screen('MakeTexture', w, im);
    Screen('DrawTexture', w, tex);
    Screen('Flip', w);
    vbl = Screen('Flip', w, vbl + t - 0.5 * ifi);
    
    Task_Duration(2) = GetSecs-Task_Duration(1);
    c=clock;
    outfile=sprintf('Results/StopSignal_prac_Group%03d_Sub%03d_%s_%02.0f_%02.0f.mat',group_code,subject_code,date,c(4),c(5));
    save(outfile, 'Seeker','Task_Duration');
    
catch
    Task_Duration(2) = GetSecs-Task_Duration(1);
    c=clock;
    outfile=sprintf('Results/StopSignal_prac_999_Group%03d_Sub%03d_%s_%02.0f_%02.0f.mat',group_code,subject_code,date,c(4),c(5));
    save(outfile, 'Seeker','Task_Duration');
end
Screen('CloseAll');
Priority(0);
% rethrow(exception);
end


