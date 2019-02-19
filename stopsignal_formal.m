function stopsignal_formal (group_code, subject_code)
%% invoking 'Stimat' function
stimat = sequence_formal(group_code, subject_code);
Seeker = stimat;
%% counting task duration
Task_Duration = ones(1,2);
Task_Duration(1) = GetSecs;
%% Define parameter
step = 50; % staircase time
NBLOCKS = 4; % block number
totalcnt = 1;  % this is the overall counter
%% Define button
KbName('UnifyKeyNames');
escapeKey = KbName('ESCAPE');
%% initial value of Ladder (first four stop trials)
SSD = [400; 550; 700; 850];
Seeker.stoporder(Seeker.condition==1) = 1:height(Seeker(Seeker.condition==1,:));
for i = 1:4
    Seeker.SSD(Seeker.stoporder==i) = SSD(Seeker.LadderOrder(Seeker.stoporder==i));
end
%% partition Seeker into 4 blocks
h = height(Seeker);
j = NBLOCKS;
for k = 1:j
    Seeker.block((k-1)*h/j+1:(k*h/j),1) = k;
end
%% Define Onsettime
for i = 1:NBLOCKS
    n = 0;
    m = Seeker(Seeker.block == i,:);
    for k = 1:height(m)
        n = n + 2 + m.jitter(k);
        Seeker.onsettime(k+(i-1)*h/j) = n;
    end
end
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
    %% argument in block feedback
    meanrt = zeros(1,NBLOCKS);
    stoprate = zeros(1,NBLOCKS);
    %% define resp
    Seeker.resp = zeros(height(Seeker),1);
    %% BLOCK LOOP
    for block = 1:NBLOCKS % change number of blocks
        %*************Introduction & Keyboard************%
        switch mod(subject_code,2)
            case 0 % number is even
                IN = KbName('f'); % key 1
                OUT = KbName('j'); % key 2
                switch block
                    case 1
                        sq=imread('MateStop/ins_even.jpg','jpg');  %%% even instruction
                    otherwise
                        sq=imread('MateStop/ins_even_next.jpg','jpg');
                end
            case 1
                OUT = KbName('f'); % key 1
                IN = KbName('j'); % key 2
                switch  block
                    case 1
                        sq=imread('MateStop/ins_odd.jpg','jpg');  %%% odd instruction
                    otherwise
                        sq=imread('MateStop/ins_odd_next.jpg','jpg');
                end
        end
        tex=Screen('MakeTexture',w,sq); Screen('DrawTexture',w,tex); % make & draw instruction
        vbl = Screen('Flip', w, vbl  - 0.5 * ifi);
        KbWait;
        anchor=GetSecs; % absolute onsettime start
        %% TRIAL LOOP (each block)
        for totalcnt = (h/j*(block-1)+1) : (h/j*block)
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
%                         oldvariables = Seeker.Properties.VariableNames;
%                         newvariables = {'order','PicID','PicNam','PicSet','ShortDescription','similarlevel','similar_score','block','condition','lag','in_out','resp','correctness','RT','LadderOrder','SSD','inhibit_effect','jitter','trialtime','absolutetime','onsettime'};
%                         [~,LOCB] = ismember(newvariables,oldvariables);
%                         Seeker = Seeker(:,LOCB);
                        outfile=sprintf('Results/StopSignal_formal_999_Group%03d_Sub%03d_%s_%02.0f_%02.0f.mat',group_code,subject_code,date,c(4),c(5));
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
        %% FEEDBACK %%
        % go RT && nogo stoprate
        meanrt(block) = 1000*mean(Seeker.RT(Seeker.block(:)==block & Seeker.condition(:)~=1 & Seeker.resp(:)~=0 & Seeker.correctness(:)==1));
        stoprate(block) = height(Seeker(Seeker.block(:)==block & Seeker.condition(:)==1 & Seeker.correctness(:)==1,:))/height(Seeker(Seeker.block(:)==block & Seeker.condition(:)==1,:));
        % make feedback figure for each block
        xvals = 1:1:NBLOCKS;
        fh = figure;
        % go RT
        subplot(2,1,1);
        plot(xvals, meanrt, '.', 'markersize', 30);
        axis([1 NBLOCKS 300 1200]);
        title('Reaction Time(ms)');
        % stop Rate
        subplot(2,1,2);
        plot(xvals, stoprate, '.', 'markersize', 30);
        axis([1 NBLOCKS 0 1]);
        title('Stop Rate');
        
        fname = sprintf('Results/feedback/feedback%dgroup%dsub%d',block,group_code,subject_code);
        print(fh,'-djpeg','-r300',fname);
        close(fh);
        fbimage = imread(fname,'jpg');
        tex = Screen('MakeTexture',w,fbimage);
        Screen('DrawTexture',w,tex);
%         DrawFormattedText(w,'Your Grade','center',rect(4)*0.8,[255 0 0]);
        Screen('Flip',w);
        %% relax time
        if block<4
            im = imread('MateStop/relax.jpg','jpg');
            t = 30;
        else
            im = imread('MateStop/end.jpg','jpg');
            t = 5;
        end
        tex=Screen('MakeTexture', w, im);
        Screen('DrawTexture', w, tex);
        Screen('Flip', w, vbl + 8 - 0.5 * ifi);
        vbl = Screen('Flip', w, vbl + t - 0.5 * ifi);
        
    end % BLOCK LOOP END
    
    Task_Duration(2) = GetSecs-Task_Duration(1);
    c=clock;
    oldvariables = Seeker.Properties.VariableNames;
    newvariables = {'order','PicID','PicNam','PicSet','ShortDescription','similarlevel','similar_score','block','condition','lag','in_out','resp','correctness','RT','LadderOrder','SSD','inhibit_effect','jitter','trialtime','absolutetime','onsettime'};
    [~,LOCB] = ismember(newvariables,oldvariables);
    Seeker = Seeker(:,LOCB);
    outfile=sprintf('Results/StopSignal_formal_Group%03d_Sub%03d_%s_%02.0f_%02.0f.mat',group_code,subject_code,date,c(4),c(5));
    save(outfile, 'Seeker','Task_Duration');
    
catch exception
    Task_Duration(2) = GetSecs-Task_Duration(1);
    c=clock;
%     oldvariables = Seeker.Properties.VariableNames;
%     newvariables = {'order','PicID','PicNam','PicSet','ShortDescription','similarlevel','similar_score','block','condition','lag','in_out','resp','correctness','RT','LadderOrder','SSD','inhibit_effect','jitter','trialtime','absolutetime','onsettime'};
%     [~,LOCB] = ismember(newvariables,oldvariables);
%     Seeker = Seeker(:,LOCB);
    outfile=sprintf('Results/StopSignal_formal_999_Group%03d_Sub%03d_%s_%02.0f_%02.0f.mat',group_code,subject_code,date,c(4),c(5));
    save(outfile, 'Seeker','Task_Duration');
end
Screen('CloseAll');
Priority(0);
rethrow(exception);
end


