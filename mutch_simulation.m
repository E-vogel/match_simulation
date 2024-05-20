% Clear all variables and close all figures
clear
close all

% Set the number of players in each team
n = 5;
m = 5;

% Set the time step and time vector
h = 0.1;
t = 0:h:150;

% Draw the field and goals
field_width = 68;
field_height = 50;
rectangle('Position',[0 0 field_width field_height],"EdgeColor",'k','LineWidth',2)
hold on
rectangle('Position',[-5 20 5 10],"EdgeColor",'k','LineWidth',2)
rectangle('Position',[field_width 20 5 10],"EdgeColor",'k','LineWidth',2)
xline(field_width/2,'Color','k','LineWidth',2)
daspect([1 1 1])
axis([-10 80 0 field_height])

% Initialize team A positions and velocities
teamAx0 = field_width/2*rand(1,n);
teamAy0 = field_height*rand(1,n);
teamAvx = zeros(1,n);
teamAvy = zeros(1,n);

% Initialize team B positions and velocities
teamBx0 = field_width/2*rand(1,m)+field_width/2;
teamBy0 = field_height*rand(1,m);
teamBvx = zeros(1,m);
teamBvy = zeros(1,m);

% Initialize ball position and velocity
ballx0 = field_width/2;
bally0 = field_height/2;
ballvx = zeros(1,1);
ballvy = zeros(1,1);

% Initialize scores
countA = 0;
countB = 0;

% Set velocity parameters for teams
start_Av = 0.5;                      % Basic speed(all team A)
Toball_Av = 0.5;                     % Speed of a player chasing the ball (One of the team A)
Toball_Av_all = 0.08;                % Speed of players chasing the ball (all team A)
distance_Av = 0.001;                 % team A keeps its distance.

start_Bv = 0.5;                      % Basic speed(all team B)
Toball_Bv = 0.5;                     % Speed of a player chasing the ball (One of the team B)
Toball_Bv_all = 0.08;                % Speed of players chasing the ball (all team B)
distance_Bv = 0.001;                 % team B keeps its distance.

% Set ball parameters
ball_speed = 2;       % dribble
ball_shoot = 1;     % shoot
ball_pass = 0.03;     % pass


% Distance parameter for repulsion
D = 5;

% Display the score
txtA = "A: " + countA;
txtB = "B: " + countB;
TA = text(-12,45,txtA,'FontSize',20,'Color','r');
TB = text(69,45,txtB,'FontSize',20,'Color','b');

% Initialize goal notifications
GoolA = 'Gool!';
GoolB = 'Gool!';
gA = 0;
gB = 0;
TA_GoolA = text(5,45,'','FontSize',30,'Color','r');
TB_GoolB = text(40,45,'','FontSize',30,'Color','b');
axis off

% Initialize players and ball on the field
teamA = scatter(teamAx0,teamAy0,30,'r','filled');
teamB = scatter(teamBx0,teamBy0,30,'b','filled');
ball = scatter(ballx0,bally0,field_height,'k','filled');

% Simulation loop
for i = 1:length(t)
    % Update velocities
    tmpAx = teamA.XData;
    tmpAy = teamA.YData;
    tmpBx = teamB.XData;
    tmpBy = teamB.YData;

    nrball_strA = [];
    nrball_strB = [];

    % Calculate distances to the ball for team A
    for iA = 1:n
        nrball_strA = [nrball_strA norm([tmpAx(iA) tmpAy(iA)] - [ball.XData ball.YData])];
    end
    
    % Calculate distances to the ball for team B
    for iB = 1:m
        nrball_strB = [nrball_strB norm([tmpBx(iB) tmpBy(iB)] - [ball.XData ball.YData])];
    end
    nrball_str = [nrball_strA nrball_strB];

    % Update team A velocities
    if ball.XData > field_width/2
        teamAvx = start_Av*ones(1,n);
        teamAvy = 2*rand(1,n)-1;
    else 
        teamAvx = -start_Av*ones(1,n);
        teamAvy = 2*rand(1,n)-1;
    end
    [nrballA_min,idx] = min(nrball_strA);
    teamAvx(idx) = teamAvx(idx) - Toball_Av*(tmpAx(idx) - ball.XData);
    teamAvy(idx) = teamAvy(idx) - Toball_Av*(tmpAy(idx) - ball.YData);

    if rand < 0.4
        teamAvx = teamAvx - Toball_Av_all*(tmpAx - ball.XData);
        teamAvy = teamAvy - Toball_Av_all*(tmpAy - ball.YData);
    end

    % Apply repulsion force for team A
    for iA = 1:n
        for iiA = 1:n 
            r = norm([tmpAx(iA) tmpAx(iiA)] - [tmpAy(iA) tmpAy(iiA)]);
            teamAvx(iA) = teamAvx(iA) + distance_Av*(tmpAx(iA) - tmpAx(iiA))*(D/r + log(r));
            teamAvy(iA) = teamAvy(iA) + distance_Av*(tmpAy(iA) - tmpAy(iiA))*(D/r + log(r));
        end
    end
    
    % Update team B velocities
    if ball.XData < field_width/2
        teamBvx = -start_Bv*ones(1,n);
        teamBvy = 2*rand(1,n)-1;
    else 
        teamBvx = start_Bv*ones(1,n);
        teamBvy = 2*rand(1,n)-1;
    end
    [nrballB_min,idx] = min(nrball_strB);
    teamBvx(idx) = teamBvx(idx) - Toball_Bv*(tmpBx(idx) - ball.XData);
    teamBvy(idx) = teamBvy(idx) - Toball_Bv*(tmpBy(idx) - ball.YData);

    if rand < 0.4
        teamBvx = teamBvx - Toball_Bv_all*(tmpBx - ball.XData);
        teamBvy = teamBvy - Toball_Bv_all*(tmpBy - ball.YData);
    end

    % Apply repulsion force for team B
    for iB = 1:m
        for iiB = 1:m 
            r = norm([tmpBx(iB) tmpBx(iiB)] - [tmpBy(iB) tmpBy(iiB)]);
            teamBvx(iB) = teamBvx(iB) + distance_Bv*(tmpBx(iB) - tmpBx(iiB))*(D/r + log(r));
            teamBvy(iB) = teamBvy(iB) + distance_Bv*(tmpBy(iB) - tmpBy(iiB))*(D/r + log(r));
        end
    end
    
    % Update ball velocities
    d = 0;

    [nrball_min,idx] = min(nrball_str);
    
    if nrball_min < 2 % Ball possession
        if idx > n % Ball possession team B
            if ball.XData > field_width/2 % Carry to the opponent's court
                ballvx = ballvx + 0.7*rand*ball_shoot;
                ballvy = ballvy - 2*rand*ball_shoot + ball_shoot;
            end
            idx = idx - n;
            if rand < 0.5 % Probability of kicking the ball
                ballvx = ballvx + ball_speed*(ball.XData - tmpBx(idx))/nrball_min; % dribble
                ballvy = ballvy + ball_speed*(ball.YData - tmpBy(idx))/nrball_min;
            else
                d = 1;
                if norm([tmpBx(idx)-0 tmpBy(idx)-field_height/2]) < 15 % If there is a goal nearby, shoot.
                    ballvx = ballvx - rand*ball_shoot*(tmpBx(idx) - 0);
                    ballvy = ballvy - rand*ball_shoot*(tmpBy(idx) - field_height/2);
                else
                    nr_strB = [];
                    for iB = 1:m
                        if iB ~= idx
                            nr_strB = [nr_strB norm([tmpBx(iB) tmpBy(iB)] - [tmpBx(idx) tmpBy(idx)])];
                        else
                            nr_strB = [nr_strB -1e10];
                        end
                    end
                    idxB = randi([1 m],1); % Determine which ally to pass to
                    nr_strB_min = nr_strB(idxB);
                    %[nr_strB_min,idxB] = max(nr_strB);
                    ballvx = ballvx - ball_pass*nr_strB_min*(tmpBx(idx) - tmpBx(idxB));
                    ballvy = ballvy - ball_pass*nr_strB_min*(tmpBy(idx) - tmpBy(idxB));
                end
            end
        else % Ball possession team A
            if ball.XData < field_width/2 % Carry to the opponent's court
                ballvx = ballvx - 0.7*rand*ball_shoot;
                ballvy = ballvy + 2*rand*ball_shoot - ball_shoot;
            end
            if rand < 0.5 % Probability of kicking the ball
                ballvx = ballvx + ball_speed*(ball.XData - tmpAx(idx))/nrball_min; % dribble
                ballvy = ballvy + ball_speed*(ball.YData - tmpAy(idx))/nrball_min;
            else
                d = 1;
                if norm([tmpAx(idx)-field_width tmpAy(idx)-field_height/2]) < 15 % If there is a goal nearby, shoot.
                    ballvx = ballvx - rand*ball_shoot*(tmpAx(idx) - field_width);
                    ballvy = ballvy - rand*ball_shoot*(tmpAy(idx) - field_height/2);
                else
                    nr_strA = [];
                    for iA = 1:n
                        if iA ~= idx
                            nr_strA = [nr_strA norm([tmpAx(iA) tmpAy(iA)] - [tmpAx(idx) tmpAy(idx)])];
                        else 
                            nr_strA = [nr_strA -1e10];
                        end
                    end
                    idxA = randi([1 n],1); % Determine which ally to pass to
                    nr_strA_min = nr_strA(idxA);
                    %[nr_strA_min,idxA] = max(nr_strA);
                    ballvx = ballvx - ball_pass*nr_strA_min*(tmpAx(idx) - tmpAx(idxA));
                    ballvy = ballvy - ball_pass*nr_strA_min*(tmpAy(idx) - tmpAy(idxA));
                end
            end
        end
    end

    % Ball deceleration
    ballvx = ballvx*0.9;
    ballvy = ballvy*0.9;

    % Update player positions with wall reflection
    for iA = 1:n
        [teamA.XData(iA),teamA.YData(iA),teamAvx(iA),teamAvy(iA)] = ref(tmpAx(iA),tmpAy(iA),teamAvx(iA),teamAvy(iA),field_width,field_height);
    end
    for iB = 1:m
        [teamB.XData(iB),teamB.YData(iB),teamBvx(iB),teamBvy(iB)] = ref(tmpBx(iB),tmpBy(iB),teamBvx(iB),teamBvy(iB),field_width,field_height);
    end

    % Update ball position with wall reflection and scoring
    countA_str = countA;
    countB_str = countB;
    [ball.XData,ball.YData,ballvx,ballvy,countA,countB,gA,gB] = ref_ball(ball.XData,ball.YData,ballvx,ballvy,countA,countB,gA,gB,field_width,field_height);
    if countA ~= countA_str || countB ~= countB_str
        teamA.XData = field_width/2*rand(1,n);
        teamA.YData = field_height*rand(1,n);
        teamB.XData = field_width/2*rand(1,m)+field_width/2;
        teamB.YData = field_height*rand(1,m);
    end

    % Update player positions
    teamA.XData = teamA.XData + teamAvx*h;
    teamA.YData = teamA.YData + teamAvy*h;
    
    teamB.XData = teamB.XData + teamBvx*h;
    teamB.YData = teamB.YData + teamBvy*h;

    ball.XData = ball.XData + ballvx*h;
    ball.YData = ball.YData + ballvy*h;

    % Update the score display
    TA.String = "A: " + countA;
    TB.String = "B: " + countB;
    
    % Update goal notifications
    if gA > 0
        TA_GoolA.String = GoolA;
        gA = gA + 1;
    elseif gA == 0
        TA_GoolA.String = '';
    end
    
    if gA == 40
        gA = 0;
    end

    if gB > 0
        TB_GoolB.String = GoolB;
        gB = gB + 1;
    elseif gB == 0
        TB_GoolB.String = '';
    end
    
    if gB == 40
        gB = 0;
    end

    drawnow
end

% Function to handle wall reflections for players
function [x,y,dx,dy] = ref(x,y,dx,dy,field_width,field_height)
    if x >= field_width
        dx = -dx;
        x = field_width- 0.1;
    elseif x <= 0
        dx = -dx;
        x = 0.1;
    elseif y >= field_height
        dy = -dy;
        y = field_height - 0.1;
    elseif y <= 0
        dy = -dy;
        y = 0.1;
    end
end

% Function to handle wall reflections and scoring for the ball
function [x,y,dx,dy,countA,countB,gA,gB] = ref_ball(x,y,dx,dy,countA,countB,gA,gB,field_width,field_height)
    if x >= field_width && y < 30 && y > 20
        x = field_width/2;
        y = field_height/2;
        dx = 0;
        dy = 0;
        countA = countA + 1;
        gA = 1;
    elseif x <= 0 && y < 30 && y > 20
        x = field_width/2;
        y = field_height/2;
        dx = 0;
        dy = 0;
        countB = countB + 1;
        gB = 1;
    elseif x >= field_width
        dx = -dx;
        x = field_width- 0.01;
    elseif x <= 0
        dx = -dx;
        x = 0.01;
    elseif y >= field_height
        dy = -dy;
        y = field_height - 0.01;
    elseif y <= 0
        dy = -dy;
        y = 0.01;
    end
end
