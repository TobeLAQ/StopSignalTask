% 2018/11/22 Anqi
function stimat = sequence_prac(group_code, subject_code)
rand('twister',(2^31+group_code)/subject_code);
%% read txt & random picture
stim = readtable('info\Pracpic.txt');
conditions = textread('info\prac_conditions.txt');
a = table(conditions(:, group_code), 'VariableNames', {'condition'});
stim = [stim,a];
%stim = [stim; stim]; % repeat once
%% random chip
chip = readtable('info\chip_prac.txt');
chip.order = randperm(height(chip))';
chip = sortrows(chip,'order','ascend');
%% input stimulate sequence
stimseq = table();
stimseqtem = [];
for i = 1:height(chip)
    switch chip.chip(i)
        case 1
            c = [5;1];
        case 2
            c = [4;2;1];
        case 3
            c = [4;3;2;1];
        case 4
            c = [4;3;3;2;1];
        otherwise
            warning('There are some error in chip.')
    end
    stimseqtem = [stimseqtem; c];
end
stimseq.condition = stimseqtem;
stimseq.order(:) = 1:height(stimseq);
%% random in group & input stim & design jitter
stimat = table();
for i = 1:5
   stimtem = stim(stim.condition==i,:);
    stimtem.rank = randperm(height(stimtem))';
    seqtem = stimseq(stimseq.condition==i,:);
    seqtem.rank = randperm(height(seqtem))';
    % add jitter
    pd = makedist('Exponential','mu',2);
    t = truncate(pd,0.5,4);
    d = random(t,height(stimtem),1);
    while mean(d)>2 || mean(d)<1.9
        d = random(t,height(stimtem),1);
    end
    stimtem.jitter(:)=d(1:end); %% mean SOA 2s, at least 0.5s, less than 4s;
    % combine the stimtem & seqtems
    tem = innerjoin(stimtem, seqtem);
    % combine 5 conditions
    stimat =  [stimat; tem];
end
%% define 4 type LadderOrder
n = [];
for k = 1 : height(stimat(stimat.condition==1,:))/3
    m = randperm(3)';
    n = [n; m];
end
stimat = sortrows(stimat, 'order', 'ascend');
stimat.LadderOrder(stimat.condition == 1,:) = n;
stimat.rank = [];
end