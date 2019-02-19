function data=stopsignalAnalysis(Seeker)
type=1;JitterType=1;
LEFT=70;RIGHT=74;




%%% kluge to create ladders from Seeker
Ladder1 = Seeker(find(Seeker(:,5)==1),6);
Ladder2 = Seeker(find(Seeker(:,5)==2),6);
Ladder3 = Seeker(find(Seeker(:,5)==3),6);
Ladder4 = Seeker(find(Seeker(:,5)==4),6);
[r foo] = size(Seeker); num_blocks = Seeker(r,2);

if JitterType==1, CUTOFF = 11; else CUTOFF=6; end;

ymax=max(max([Ladder1 Ladder2 Ladder3 Ladder4]));
ymin=min(min([Ladder1 Ladder2 Ladder3 Ladder4]));
if ymin>0,
	ymin=0;
end;
xmax=4*num_blocks;

for a=1:size(Ladder1),
	Ladder1Plot(2*a-1)=Ladder1(a);
	Ladder2Plot(2*a-1)=Ladder2(a);
	Ladder3Plot(2*a-1)=Ladder3(a);
	Ladder4Plot(2*a-1)=Ladder4(a);
	Ladder1Plot(2*a)=Ladder1(a);
	Ladder2Plot(2*a)=Ladder2(a);
	Ladder3Plot(2*a)=Ladder3(a);
	Ladder4Plot(2*a)=Ladder4(a);
end;

% %%%%% plotting
% subplot(2,2,1);
% for a=1:size(Ladder1)-1;
% 	hold on;
% 	plot(a:a+1,Ladder1Plot(2*a-1:2*a), 'b');
% 	plot([a+1 a+1],Ladder1Plot(2*a:2*a+1), 'b');
% end;
% axis([1 xmax ymin ymax]);
% subplot(2,2,2);
% for a=1:size(Ladder2)-1;
% 	hold on;
% 	plot(a:a+1,Ladder2Plot(2*a-1:2*a), 'b');
% 	plot([a+1 a+1],Ladder2Plot(2*a:2*a+1), 'b');
% end;
% axis([1 xmax ymin ymax]);
% subplot(2,2,3);
% for a=1:size(Ladder3)-1;
% 	hold on;
% 	plot(a:a+1,Ladder3Plot(2*a-1:2*a), 'b');
% 	plot([a+1 a+1],Ladder3Plot(2*a:2*a+1), 'b');
% end;
% axis([1 xmax ymin ymax]);
% subplot(2,2,4);
% for a=1:size(Ladder4)-1;
% 	hold on;
% 	plot(a:a+1,Ladder4Plot(2*a-1:2*a), 'b');
% 	plot([a+1 a+1],Ladder4Plot(2*a:2*a+1), 'b');
% end;
% axis([1 xmax ymin ymax]);

%%%% Actual Analysis...
if type==1
%GRTmedian=median(Seeker(find(((Seeker(:,3)==0 & Seeker(:,4)==0&Seeker(:,7)==LEFT)|Seeker(:,3)==0 & (Seeker(:,4)==1&Seeker(:,7)==RIGHT))&Seeker(:,3)==0),8))*1000;
%GRTmean=mean(Seeker(find(((Seeker(:,3)==0 & Seeker(:,4)==0&Seeker(:,7)==LEFT)|Seeker(:,3)==0 & (Seeker(:,4)==1&Seeker(:,7)==RIGHT))&Seeker(:,3)==0),8))*1000;
% x=Seeker(find(((Seeker(:,3)==0 & Seeker(:,4)==0 & Seeker(:,7)==LEFT) | (Seeker(:,3)==0 & Seeker(:,4)==1 & Seeker(:,7)==RIGHT)) ),8)*1000;
% GRTmedian=median(x(132:end))
x=Seeker(find(((Seeker(132:end,3)==0 & Seeker(132:end,4)==0 & Seeker(132:end,7)==LEFT) | (Seeker(132:end,3)==0 & Seeker(132:end,4)==1 & Seeker(132:end,7)==RIGHT)) ),8)*1000;
GRTmedian=median(x);
end

if type==2 | type==3
GRTmedian=median(Seeker(find(Seeker(:,3)==0 & Seeker(:,8)>0),8))*1000;
GRTmean=mean(Seeker(find(Seeker(:,3)==0 & Seeker(:,8)>0),8))*1000;
end

Ladder1mean=mean(Ladder1(CUTOFF:num_blocks*4));
Ladder2mean=mean(Ladder2(CUTOFF:num_blocks*4));
Ladder3mean=mean(Ladder3(CUTOFF:num_blocks*4));
Ladder4mean=mean(Ladder4(CUTOFF:num_blocks*4));
SSDfifty=mean([Ladder1mean Ladder2mean Ladder3mean Ladder4mean]);
SSRT=GRTmedian-SSDfifty;

Accu=length(find( Seeker(:,3)==0 & ( (Seeker(:,4)==0 & Seeker(:,7)==70) | ( Seeker(:,4)==1 & Seeker(:,7)==74 ) )))/length(find( Seeker(:,3)==0));
meanrt = 1000*median(Seeker(find( Seeker(:,3)==0 & Seeker(:,7)~=0  & ( (Seeker(:,4)==1 & Seeker(:,7)==74) | ( Seeker(:,4)==0 & Seeker(:,7)==70 ) )),8));
stoprate=length(find(Seeker(:,10)==1))/64;


if type==1
    DimErrors=sum((Seeker(:,3)==0 & ( (Seeker(:,4)==0 & Seeker(:,7)==RIGHT) | ( Seeker(:,4)==1 & Seeker(:,7)==LEFT ) )));
    data = [meanrt Accu stoprate GRTmedian SSRT Ladder1mean Ladder2mean Ladder3mean Ladder4mean SSDfifty DimErrors];
else
    data = [meanrt Accu stoprate GRTmedian SSRT GRTmedian SSRT Ladder1mean Ladder2mean Ladder3mean Ladder4mean SSDfifty];
end
% title(sprintf('SSRT=%0.2f',SSRT))