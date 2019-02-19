%% parameter
Nscans = 251; % 504(total trials)/4(runs)*4(meanITI)/2(TR)=251
np = Nscans;
Tbin = 16; % number of time bins per scan
TR = 2;
n = 5; %number of condition
% ntrial = 80;

%% HP filter code
cut = 100;
cut = cut/TR;
sigN2 = (cut/sqrt(2))^2;
K = toeplitz(1/sqrt(2*pi*sigN2)*exp(-[0:(Nscans - 1)].^2/(2*sigN2)));
K = spdiags(1./sum(K')',0,Nscans,Nscans)*K;
H = zeros(Nscans,Nscans); % Smoothing Matrix, s.t. H*y is smooth line
X = [ones(Nscans,1) (1:Nscans)'];
for k = 1:Nscans
    W = diag(K(k,:));
    Hat = X*pinv(W*X)*W;
    H(k,:) = Hat(k,:);
end
F = eye(Nscans) - H; % the highpass filtering matrix

%% autocorrelation
corvec=zeros(1,Nscans);
corvec(1:11)=.20.^[0:10];
V=toeplitz(corvec);

%% creat the design matrix from the design
SPM.xBF.name       = 'hrf';
SPM.xBF.order      = 1;
SPM.xBF.length     = 32; % length in seconds
SPM.xBF.T          = 16; % number of time bins per scan
SPM.xBF.T0         = 1;	 % middle slice/timebin
SPM.xBF.UNITS      = 'scans'; % OPTIONS: 'scans'|'secs' for onsets
SPM.xBF.Volterra   = 1; % OPTIONS: 1|2 = order of convolution
SPM.xBF.dt = TR/SPM.xBF.T;
xBF=spm_get_bf(SPM.xBF);

%% random the conditions
% input chips and random
chip = readtable('info\chip.txt');
chip.order = randperm(height(chip))';
chip = sortrows(chip,'order','ascend');
% input conditions
conseq = table();
conseqtem = [];
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
    conseqtem = [conseqtem; c];
end
conseq.condition = conseqtem;
conseq.order(:) = 1:height(conseq);
%% partition Seeker into 4 blocks
NBLOCKS = 4;
h = height(conseq);
j = NBLOCKS;
for k = 1:j
    conseq.run((k-1)*h/j+1:(k*h/j),1) = k;
end

%% set jitters in each run
for run = 1:1
    runseq = conseq(conseq.run(:) == run,:);
    
    for i = 1:10000
        if ~mod(i,10000)
            fprintf('%d...',i);
        end
        
        %% add jitter
        pd = makedist('Exponential','mu',2); % mean SOA 2s
        t = truncate(pd,0.5,4); % at least 2.5s, no more than 6s
        d = random(t,height(runseq),1);
        while mean(d)>2 || mean(d)<1.9
            d = random(t,height(runseq),1);
        end
        runseq.jitter(:)=d(1:end); % mean point 2s, at least 0.5s, less than 4s;
        runseq.absT(:) = cumsum(d(1:end)+2); %% each trial mean SOA 4s, at least 2.5s, no more than 6s;
        
        %% generate the design matrix
        for con=1:n %n
            x(1,con) = {runseq.absT(runseq.condition == con)};
        end
        aa=zeros(np*Tbin,n);
        bb{1,n}=zeros(np*Tbin+31,1); % bb=zeros(np*Tbin+31,n);
        cc=zeros(np*Tbin+256+31,n); % cc=zeros(np*Tbin+256+31,n);
        for con=1:n %n % convolve with hrf;
            aa(ceil(x{1,con}*Tbin/TR),con)=con;
            bb(:,con)={conv(aa(:,con),ones(Tbin*2,1))};
            cc(:,con)=conv(bb{:,con},xBF.bf(:,1)*16);
        end
        cc=cc([0:np-1]*Tbin+1+4,:);%% resample
        cdm=cc;
        clear cc;
        DES=cdm;
        
        %% add temporal derivation;
        dimDES=size(DES);
        nreg=dimDES(2);
        DES_prime=DES(2:end,:)-DES(1:(end-1),:);
        DES_prime=[DES_prime(1,:);DES_prime];
        
        DES=[DES,DES_prime];  %add the derivatives to the end of the design matrix
        DEShp=F*DES;
        
        %% efficiency
        %eff_all=1./diag(inv(DEShp'*DEShp));
        %X=[1 -1 0 0];
        eff_all(i,:)=sqrt(1./diag(inv(DEShp'*inv(V)*DEShp)));
        eff_reg(i,:)=eff_all(i,1:nreg);  %we don't want to include the derivatives in this
        %eff(i)=sqrt(1./diag(X*inv(DEShp'*inv(V)*DEShp)*X'));
        %a=corrcoef(DEShp);
        %corr(i)=a(1,2);
        %eff_all1(i,:)=sqrt(1./diag(inv(cdm'*cdm)));
        %%eff
    end
end
%% plot
hist(eff_reg);
ylabel('effciency');