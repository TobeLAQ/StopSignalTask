% count the ACC of the StopSignal_prac
% if the ACC >= 70%, pass the prac
% if the ACC < 70%, continue the prac
pracACC = length(find(Seeker.correctness == 1))/height(Seeker);

switch (pracACC >= 0.7)
    case 1
        a = 100;
    case 0
        a = 0;
end
    