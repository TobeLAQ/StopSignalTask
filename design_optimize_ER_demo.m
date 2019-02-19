addpath '/Users/guixue/Documents/software/spm5'

TR=2;
Nscans=160; 
np=Nscans;

%cycle=[1 2 4 5 8 10 16 20 40 80]; 
%trial_length=np*TR./(cycle*2);

ntrial=80;

%%%%%%%%%%%%%%%%%%%%%%%%%%
%------------------------------
%HP filter code
cut=100;
cut=cut/TR;
sigN2=(cut/sqrt(2))^2;
K    = toeplitz(1/sqrt(2*pi*sigN2)*exp(-[0:(Nscans - 1)].^2/(2*sigN2)));
K    = spdiags(1./sum(K')',0,Nscans,Nscans)*K;
 
H = zeros(Nscans,Nscans); % Smoothing matrix, s.t. H*y is smooth line
X = [ones(Nscans,1) (1:Nscans)'];
for k = 1:Nscans
   W = diag(K(k,:));
   Hat = X*pinv(W*X)*W;
   H(k,:) = Hat(k,:);
end

F=eye(Nscans)-H;  %this is the highpass filtering matrix

%HP_X=F*X; %%% not necessary.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% autocorrelation
corvec=zeros(1,Nscans);
corvec(1:11)=.20.^[0:10];
V=toeplitz(corvec);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% creat the design matrix from the design
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% sepearate stage 1 2 3;
%SPM.xBF.name       = 'hrf (with time derivative)';
SPM.xBF.name       = 'hrf';
SPM.xBF.order      = 1;                
SPM.xBF.length     = 32;                % length in seconds
SPM.xBF.T          = 16;               	% number of time bins per scan
SPM.xBF.T0         = 1;	            	% middle slice/timebin
SPM.xBF.UNITS      = 'scans';           % OPTIONS: 'scans'|'secs' for onsets
SPM.xBF.Volterra   = 1;                 % OPTIONS: 1|2 = order of convolution
SPM.xBF.dt = TR/SPM.xBF.T;
xBF=spm_get_bf(SPM.xBF);
Tbin=16;
TR=2;
n=1; %number of condition

%xBF=spm_hrf(TR);

for i=1:500
 if ~mod(i,500), fprintf('%d...',i); end   

%% add jitter

d=exprnd(ones(1,ntrial))*2;
while mean(d)>2 | mean(d)<1.90 | max(d) > 7
    d=exprnd(ones(1,ntrial))*2;
end

x(1:ntrial,1)=1; % only one condition
x(1:end,2)=cumsum(d(1:end)+2); %% mean SOA 4s, at least 2s;  

%% generate the design matrix
x1=sortrows(x,1); % sort according to stimuli
for mm=1:n
    x2(:,mm)=x1(x(:,1)==mm,2);
end

% % Convolve stimulus functions with basis functions
% %-------------------------------------------------------
% [X,Xn,Fc] = spm_Volterra(U,bf,V);
% 
% % Resample regressors at acquisition times (32 bin offset)
% %-------------------------------------------------------
% try
%     X = X([0:(k - 1)]*fMRI_T + fMRI_T0 + 32,:);
% end
        
aa=zeros(np*Tbin,n);
bb=zeros(np*Tbin+31,n);
cc=zeros(np*Tbin+256+31,n);

for k=1:n % convolve with hrf;
    aa(ceil(x2(:,k)*Tbin/TR),k)=k;
    bb(:,k)=conv(aa(:,k),ones(Tbin*2,1));
    cc(:,k)=conv(bb(:,k),xBF.bf(:,1)*16);
end
cc=cc([0:np-1]*Tbin+1+4,:);%% resample
cdm=cc;
clear cc;

DES=cdm;

%%%% add temporal derivation;
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


%% plot
hist(eff_reg);
ylabel('effciency');
