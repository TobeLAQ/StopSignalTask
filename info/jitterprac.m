pd = makedist('Exponential','mu',2);
t = truncate(pd,0.5,4);
d = randprem(t,500,1);
while mean(d)>2 || mean(d)<1.9
    d = random(t,500,1);
end
n = table();
for i = 1:4
    m = Seeker(Seeker.block ==i,:);
    m.onsettime(1) = 2 + m.jitter(1);
    m.onsettime(2:end) = m.onsettime(1:end-1) + 2 + m.jitter(end);
    n = [n;m];
end