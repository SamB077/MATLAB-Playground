% add biomes as you walk further, add rain, maybe jump, add time while not
% walking hi

function ManWalkingControlled

clc; close all;

%% ================= INITIAL VALUES =================
% Walking Left was base
data.dt = 0.05; % keep at 0.05 for best experience
data.t = 0;
data.l = 0;
data.sunstart = pi/2;

data.keyDown = false;
data.lastKey = '';
data.lastPressTime = datetime('now');

data.elbow = -30;
data.knee = 24;
data.Back_bend = 180;

data.Rotator_cuff_left = 45;
data.Rotator_cuff_right = -30;
data.Iliopsoas_left = -40;
data.Iliopsoas_right = 25;

data.Height_torso = 5.7;
data.Length_arm_upper = 2;
data.Length_arm_lower = 2;
data.Length_leg_upper = 2.5;
data.Length_leg_lower = 2.5;

data.Tree_pos = 0;
data.Tree_height = 8;
data.Tree_fluf = 4;

%% ================= CACHED CONSTANTS (perf) =================
% These never change shape frame-to-frame, so build them ONCE here
% instead of rebuilding thousand-point ranges inside the timer callback
% every single tick.
data.groundX = -20:0.05:20;
data.treeLeafBaseX = -data.Tree_fluf:0.005:data.Tree_fluf;
data.treeLeafBaseY = sin(258.*data.treeLeafBaseX).*sqrt(data.Tree_fluf^2 - data.treeLeafBaseX.^2);

data.skyQ = 0:2*pi*45;
data.sunShapeX = (cos(data.skyQ/45).*((-1).^data.skyQ+1)/2)*9;
data.sunShapeY = (sin(data.skyQ/45).*((-1).^data.skyQ+1)/2)*9;
data.moonShapeX = (cos(data.skyQ/45).*((-1).^data.skyQ+1)/2)*2;
data.moonShapeY = (sin(data.skyQ/45).*((-1).^data.skyQ+1)/2)*2;

%% ================= FIGURE =================
fig = figure('Name','Man Walking', ...
    'NumberTitle','off', ...
    'KeyPressFcn',@keyDown, ...
    'KeyReleaseFcn',@keyUp);
hold on
xlim([-20 20])
axis equal

ax = gca;
ylim([-5 30]);
ax.XLimMode = 'manual';
ax.YLimMode = 'manual';
data.figHandle = fig;
data.axHandle = ax;
%% ================= Background =================
plot(0, data.Tree_height+data.Tree_fluf, 'LineStyle', 'none', 'Marker', 'none')

data.SUN = plot(data.sunShapeX+20*cos(data.sunstart), data.sunShapeY+20*sin(data.sunstart),'Color',[1,1,0]);
data.MON = plot(data.moonShapeX-20*cos(data.sunstart), data.moonShapeY-20*sin(data.sunstart),'Color',[0.9,1,1]);
data.TTR = plot([data.Tree_pos,data.Tree_pos],[-(data.Length_leg_upper+data.Length_leg_lower), ...
    data.Tree_height],'LineWidth',24,'Color',[0.51, 0.25, 0.072]);
data.TLV = plot(data.treeLeafBaseX, data.treeLeafBaseY+data.Tree_height,'Color',[0.13,.55,0.13]);
%% ================= Person Plots =================

data.LAU = plot([0 0],[0 0],'LineWidth',15,'Color',[0.58,0.18,0.25]);
data.LAL = plot([0 0],[0 0],'LineWidth',15,'Color',[0.58,0.18,0.25]);
data.LLU = plot([0 0],[0 0],'LineWidth',15,'Color',[0,0.2,0.5]);
data.LLL = plot([0 0],[0 0],'LineWidth',15,'Color',[0,0.2,0.5]);
data.TOR = plot([0 0],[0 data.Height_torso],'LineWidth',15,'Color',[0.6,0.2,0.3]);
data.HED = scatter([0],[data.Height_torso*1.14] ,'LineWidth',43,'MarkerEdgeColor',[0.85,0.55,0.3]);
data.RLU = plot([0 0],[0, -data.Length_leg_upper],'LineWidth',15,'Color',[0,0.3,0.6]);
data.RLL = plot([0 0],[-data.Length_leg_upper, -data.Length_leg_upper-data.Length_leg_upper],'LineWidth',15,'Color',[0,0.3,0.6]);
data.RAU = plot([0 0],[data.Height_torso*0.8, data.Height_torso*0.8-data.Length_arm_upper],'LineWidth',15,'Color',[0.65,0.25,0.35]);
data.RAL = plot([0 0],[data.Height_torso*0.8-data.Length_arm_upper, data.Height_torso*0.8-data.Length_arm_upper-data.Length_arm_lower],'LineWidth',15,'Color',[0.65,0.25,0.35]);

%% ================= Foreground =================

data.GRD = plot(data.groundX,-(data.Length_leg_upper+data.Length_leg_lower)+ ...
    sin(35*data.groundX),  'LineWidth',4,'Color',[0.7,0.8,0.24]);

fig.UserData = data;

% No java.timer here on purpose (lab machines can have Java restricted,
% which silently kills timer objects). A plain loop + pause needs no
% Java at all and still only ever calls movement logic from updateTime.
while ishandle(fig)
    updateTime(fig);
    pause(fig.UserData.dt);
end
end

%% ================= RUN FUNCTION =================
function updateTime(fig)

data = fig.UserData;
data.t = data.t + data.dt;
data = movesun(data);

if data.keyDown && seconds(datetime('now') - data.lastPressTime) > 3*data.dt
    data.keyDown = false;
end

if data.keyDown
    switch data.lastKey
        case {'a','leftarrow'}
            data = walking(data);
        case {'d','rightarrow'}
            data = walking(data);
    end
end

drawnow limitrate % single flush per tick instead of one per sub-function

fig.UserData = data;

end

%% ================= KEY CLICKS =================
function keyDown(src,event)
data = src.UserData;

if ismember(event.Key,{'a','leftarrow','d','rightarrow'})
    data.keyDown = true;
    data.lastKey = event.Key;
    data.lastPressTime = datetime('now');
end

src.UserData = data;
end

function keyUp(src,event)
data = src.UserData;

if ismember(event.Key,{data.lastKey})
    data.keyDown = false;
end

src.UserData = data;
end

%% ================= BACKGROUND FUNCTIONS =================
function data = movesun(data)
sunx = data.sunShapeX + 20*cos(data.sunstart+data.t*1);
suny = data.sunShapeY + 20*sin(data.sunstart+data.t*1);
moonx = data.moonShapeX - 20*cos(data.sunstart+data.t*1);
moony = data.moonShapeY - 20*sin(data.sunstart+data.t*1);

%% Update Plots
set(data.SUN,'XData',[sunx],'YData',[suny]);
set(data.MON,'XData',[moonx],'YData',[moony]);

holdValue = 3;
whitebias = 0.4;
skyangle = data.sunstart + data.t;

SIN = sin(skyangle) + whitebias;
SINBI = max(-1, min(1, SIN));
sincos = sign(SINBI) * (abs(SINBI)^(1/holdValue));

colorVal = 0.5 * (sincos + 1);
data.figHandle.Color = [colorVal colorVal colorVal];
data.axHandle.Color = [colorVal colorVal colorVal];

end

%% ================= WALKING STEP =================
function data = walking(data)

dt = data.dt;
data.l = data.l + dt;

if ismember(data.lastKey, {'a','leftarrow'})
    i = 1;
    data.Tree_pos = data.Tree_pos+dt;
elseif ismember(data.lastKey, {'d','rightarrow'})
    i = -1;
    data.Tree_pos = data.Tree_pos-dt;
end

if data.Tree_pos > 25
    data.Tree_pos = -25;
elseif data.Tree_pos < -25
    data.Tree_pos = 25;
end

roof = ceil(data.l);
di = (-(-1)^roof)*dt;

data.Rotator_cuff_left  = data.Rotator_cuff_left - di*60;
data.Rotator_cuff_right = data.Rotator_cuff_right + di*60;
data.Iliopsoas_left     = data.Iliopsoas_left + di*60;
data.Iliopsoas_right    = data.Iliopsoas_right - di*60;

data.Rotator_cuff_left  = min(max(data.Rotator_cuff_left,  -30), 30);
data.Rotator_cuff_right = min(max(data.Rotator_cuff_right, -30), 30);
data.Iliopsoas_left     = min(max(data.Iliopsoas_left,     -30), 30);
data.Iliopsoas_right    = min(max(data.Iliopsoas_right,    -30), 30);

Brachialis_left  = (data.Rotator_cuff_left + data.elbow)*i;
Brachialis_right = (data.Rotator_cuff_right + data.elbow)*i;
Hamstring_left   = (data.Iliopsoas_left + data.knee)*i;
Hamstring_right  = (data.Iliopsoas_right + data.knee)*i;

shoulder = [sind(i*data.Back_bend),-cosd(i*data.Back_bend)]*(0.8*data.Height_torso);

Arm_left_upper  = shoulder + ...
    [sind(i*data.Rotator_cuff_left),-cosd(i*data.Rotator_cuff_left)]*data.Length_arm_upper;
Arm_left_lower  = Arm_left_upper + ...
    [sind(Brachialis_left),-cosd(Brachialis_left)]*data.Length_arm_lower;

Arm_right_upper = shoulder + ...
    [sind(i*data.Rotator_cuff_right),-cosd(i*data.Rotator_cuff_right)]*data.Length_arm_upper;
Arm_right_lower = Arm_right_upper + ...
    [sind(Brachialis_right),-cosd(Brachialis_right)]*data.Length_arm_lower;

Leg_left_upper  = ...
    [sind(i*data.Iliopsoas_left),-cosd(i*data.Iliopsoas_left)]*data.Length_leg_upper;
Leg_left_lower  = Leg_left_upper + ...
    [sind(Hamstring_left),-cosd(Hamstring_left)]*data.Length_leg_lower;

Leg_right_upper = ...
    [sind(i*data.Iliopsoas_right),-cosd(i*data.Iliopsoas_right)]*data.Length_leg_upper;
Leg_right_lower = Leg_right_upper + ...
    [sind(Hamstring_right),-cosd(Hamstring_right)]*data.Length_leg_lower;

%% Update Plots
set(data.LAU,'XData',[shoulder(1),Arm_left_upper(1)], ...
             'YData',[shoulder(2),Arm_left_upper(2)]);
set(data.LAL,'XData',[Arm_left_upper(1),Arm_left_lower(1)], ...
             'YData',[Arm_left_upper(2),Arm_left_lower(2)]);
set(data.RAU,'XData',[shoulder(1),Arm_right_upper(1)], ...
             'YData',[shoulder(2),Arm_right_upper(2)]);
set(data.RAL,'XData',[Arm_right_upper(1),Arm_right_lower(1)], ...
             'YData',[Arm_right_upper(2),Arm_right_lower(2)]);
set(data.LLU,'XData',[0,Leg_left_upper(1)], ...
             'YData',[0,Leg_left_upper(2)]);
set(data.LLL,'XData',[Leg_left_upper(1),Leg_left_lower(1)], ...
             'YData',[Leg_left_upper(2),Leg_left_lower(2)]);
set(data.RLU,'XData',[0,Leg_right_upper(1)], ...
             'YData',[0,Leg_right_upper(2)]);
set(data.RLL,'XData',[Leg_right_upper(1),Leg_right_lower(1)], ...
             'YData',[Leg_right_upper(2),Leg_right_lower(2)]);

set(data.HED,'XData',[sind(data.Back_bend)]*data.Height_torso*1.14, ...
             'YData',[-cosd(data.Back_bend)]*data.Height_torso*1.14);
set(data.TOR,'XData',[0,sind(data.Back_bend)]*data.Height_torso, ...
             'YData',[0,-cosd(data.Back_bend)]*data.Height_torso);

set(data.TTR,'XData',[data.Tree_pos,data.Tree_pos]);
set(data.TLV,'XData',data.treeLeafBaseX + data.Tree_pos);
set(data.GRD,'YData', ...
    -(data.Length_leg_upper+data.Length_leg_lower) + ...
    sin(35*data.groundX-i*dt*280*data.t));

end