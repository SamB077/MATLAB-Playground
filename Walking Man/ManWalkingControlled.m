function ManWalkingControlled

clc; close all;

%% ================= INITIAL VALUES =================
data.dt = 0.03;
data.maxDt = 0.1;
data.t = 0;
data.G = -9.81;
data.l = 0;
data.d = 0;
data.i = 0;
data.h = 0;

data.jump = false;
data.jump_vel = 0;
data.jump_velocity = 13;

data.walkSpeed = 20.0;
data.strideRate = 2.0;

data.moveLeft = false;
data.moveRight = false;
data.lastDir = 0;

data.moveLeftLastSeen = -1e9;
data.moveRightLastSeen = -1e9;
data.keyWatchdog = 1.5;
data.moveGrace = 0.12;
data.airDir = 0;

data.daytime = 0.5;
data.seasonlength = 3;
data.sunstart = pi/2;
data.seasonColorVal = 1;

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

data.Tree_height = 8.7;
data.Tree_fluf = 4;
data.oakWorldD = 25;

data.groundStep = 0.05;
data.pineLeafStep = 0.032;
data.leafFallMin = 0.1;
data.leafFallMax = 0.6;
data.leafShapeTimer = 0;
data.leafShapeInterval = 0.25;
data.groundWaveRate = 8;

data.numPineTreesPerSide = 25;
data.numPineTrees = data.numPineTreesPerSide*2;
data.numPineBins = 5;

data.pineWorldMin = 305;
data.pineWorldMax = 395;
data.pineActivateAt = 100;
data.pineCullMargin = 30;

data.sandColor = [0.87, 0.78, 0.55];
data.sandAmp = 0.3;
data.waterColor = [0.15, 0.45, 0.75];
data.waterAmp = 1.4;
data.waveSharpness = 0.35;

data.cactusHeight = 7.5;
data.cactusColor = [0.25, 0.55, 0.3];
data.cactusArmSpread = 1.3;
data.numCacti = 6;
data.cactusWorldD = linspace(455, 545, data.numCacti);
data.cactusCullMargin = 30;

data.boatHullColor = [0.4, 0.25, 0.15];
data.sailColor = [0.93, 0.93, 0.88];

data.rockyColor = [0.55, 0.5, 0.48];
data.rockyAmp = 1.2;
data.mountainColor = [0.42, 0.38, 0.5];
data.mountainParallax = 0.012;
data.mountainBaseline = -6;
data.caveWallColor = [0.28, 0.26, 0.28];

data.caveSkyColor = [0.05, 0.05, 0.08];
data.caveGroundColor = [0.35, 0.32, 0.3];
data.caveAmp = 0.4;
data.numStalactites = 14;
data.stalWorldMin = 910;
data.stalWorldMax = 990;
data.stalCullMargin = 30;
data.stalColor = [0.55, 0.55, 0.58];
data.dripColor = [0.35, 0.65, 0.9];

data.torchColor = [1, 0.6, 0.15];
data.torchFlickerSpeed = 14;
data.torchStickColor = [0.35, 0.22, 0.12];
data.torchStickLength = 1.3;
data.handPos = [0, 0];
data.rightArmMode = 0;

data.hellSkyColor = [0.55, 0.15, 0.05];
data.hellGlowAmp = 0.12;
data.hellGroundColor = [0.42, 0.28, 0.25];
data.hellAmp = 0.8;
data.hellRainColor = [0.95, 0.4, 0.15];
data.gateColor = [0.2, 0.18, 0.2];

data.skyOverride = 0;
data.skyOverrideColor = [0 0 0];
data.inDark = false;
data.inHell = false;
data.inDesert = false;
data.inBoat = false;

%% ================= CACHED CONSTANTS =================
data.groundX = -20:data.groundStep:20;
data.treeLeafBaseX = -data.Tree_fluf:data.Tree_fluf;
data.treeLeafBaseY = sin(258.*data.treeLeafBaseX).*sqrt(data.Tree_fluf^2 - data.treeLeafBaseX.^2);
data.pineLeafBaseY = -data.Tree_fluf:data.pineLeafStep:data.Tree_fluf;
data.pineLeafBaseX = sin(258.*data.pineLeafBaseY).*(data.pineLeafBaseY-data.Tree_fluf)/2.4;

data.pineBaseXNorm = data.pineLeafBaseX(:)/data.Tree_fluf;
data.pineBaseYNorm = data.pineLeafBaseY(:)/data.Tree_fluf;

data.skyQ = 0:2*pi*45;
data.sunShapeX = (cos(data.skyQ/45).*((-1).^data.skyQ+1)/2)*6;
data.sunShapeY = (sin(data.skyQ/45).*((-1).^data.skyQ+1)/2)*6;
data.moonSize = 59;

%% ================= FIGURE =================
fig = figure('Name','Man Walking','NumberTitle','off','KeyPressFcn',@keyDown,'KeyReleaseFcn',@keyUp);
hold on
xlim([-20 20])
axis equal

ax = gca;
ylim([-5 30]);
ax.XLimMode = 'manual';
ax.YLimMode = 'manual';
data.figHandle = fig;
data.axHandle = ax;

data.DistText = text(-19, 28, 'd = 0', 'FontSize', 12, 'FontWeight','bold', ...
    'Color', [0 0 0], 'BackgroundColor', [1 1 1], 'Margin', 2, 'HorizontalAlignment','left');

%% ================= Background =================
plot(0, data.Tree_height+data.Tree_fluf, 'LineStyle', 'none', 'Marker', 'none')

data.SUN = plot(data.sunShapeX+20*cos(data.sunstart), data.sunShapeY+20*sin(data.sunstart),'Color',[1,1,0]);
data.MON = plot(-20*cos(data.sunstart),-20*sin(data.sunstart),'o','MarkerSize',data.moonSize, 'MarkerFaceColor',[0.9 1 1],'MarkerEdgeColor',[0.9 1 1]);
data.TTR = plot([0,0],[-(data.Length_leg_upper+data.Length_leg_lower),data.Tree_height],'LineWidth',24,'Color',[0.51, 0.25, 0.072]);
data.TLV = plot(data.treeLeafBaseX, data.treeLeafBaseY+data.Tree_height,'LineWidth', 4,'Color',[0.13,.55,0.13]);

data.CACTI = gobjects(1,data.numCacti);
for ck = 1:data.numCacti
    data.CACTI(ck) = plot(NaN,NaN,'LineWidth',16,'Color',data.cactusColor,'LineJoin','round');
end

rng(10);

data.numMountains = 13;
peakGap = 10 + 9*rand(1,data.numMountains);
peakX = cumsum(peakGap) - sum(peakGap)/2;
peakH = 9 + 18*rand(1,data.numMountains);
peakHalfBase = 6 + 8*rand(1,data.numMountains);

mountainColorDark = max(0,data.mountainColor*0.7);
mountainColorLight = min(1,data.mountainColor*1.35);

data.mountainTriX = cell(1,data.numMountains);
data.mountainTriY = cell(1,data.numMountains);
data.MTN = gobjects(1,data.numMountains);
for pk = 1:data.numMountains
    data.mountainTriX{pk} = [peakX(pk)-peakHalfBase(pk), peakX(pk), peakX(pk)+peakHalfBase(pk)];
    data.mountainTriY{pk} = [data.mountainBaseline, data.mountainBaseline+peakH(pk), data.mountainBaseline];
    pkColor = mountainColorDark + rand*(mountainColorLight-mountainColorDark);
    data.MTN(pk) = fill(data.mountainTriX{pk}, data.mountainTriY{pk}, pkColor, 'EdgeColor','none', 'Visible','off');
end

groundY0 = -(data.Length_leg_upper+data.Length_leg_lower);
charHeight0 = data.Height_torso*1.14 + 0.5;
nJag = 7;
data.wallJagY = linspace(groundY0, charHeight0, nJag);
data.wallJagDX = [0, (rand(1,nJag-2)-0.5)*2.4, 0];
data.exitJagY = linspace(groundY0, 35, 10);
data.exitJagDX = [0, (rand(1,8)-0.5)*2.6, 0];
data.CAVEWALL = fill(NaN,NaN,data.caveWallColor,'EdgeColor','none','Visible','off');

data.gateWorldD = 1025;
data.numGateBars = 4;
data.gateBarSpacing = 1.1;
data.gateBarHeight = 9;
data.gateCullMargin = 80;
data.GATEBARS = plot(NaN,NaN,'LineWidth',5,'Color',data.gateColor,'LineJoin','round');

data.numRocks = 5;
data.rockWorldD = linspace(770, 830, data.numRocks) + 6*(rand(1,data.numRocks)-0.5);
data.rockSize = 0.9 + 0.9*rand(1,data.numRocks);
data.rockCullMargin = 30;
data.ROCKS = gobjects(1,data.numRocks);
for rk = 1:data.numRocks
    data.ROCKS(rk) = fill(NaN,NaN,data.rockyColor*0.75,'EdgeColor','none','Visible','off');
end

data.stalWidth = 0.8 + 1.2*rand(1,data.numStalactites);
data.STAL = plot(NaN,NaN,'LineWidth',1,'Color',data.stalColor,'LineJoin','round');
data.dripY = zeros(1,data.numStalactites);
data.dripActive = false(1,data.numStalactites);
data.dripTimer = 3*rand(1,data.numStalactites);
data.dripSpeed = 3 + 2*rand(1,data.numStalactites);
data.DRIP = plot(NaN,NaN,'o','MarkerSize',4,'MarkerFaceColor',data.dripColor,'MarkerEdgeColor','none','LineStyle','none');

data.TORCHSTICK = plot(NaN,NaN,'LineWidth',5,'Color',data.torchStickColor,'LineJoin','round');
data.TORCH = plot(NaN,NaN,'LineWidth',6,'Color',data.torchColor,'LineJoin','round');

data.hullTopY = 0.3;
a = 5.5;
b = 5.8;
theta = linspace(pi, 2*pi, 24);
hullX = a*cos(theta);
hullY = data.hullTopY + b*sin(theta);
data.RAFT = fill(hullX, hullY, data.boatHullColor, 'EdgeColor','none', 'Visible', 'off');

data.motorOffsetX = 4.6;
data.HullMotorOval = fill(NaN,NaN,[0.75 0.75 0.75],'EdgeColor','none','Visible','off');
data.HullMotor = plot(NaN,NaN,'LineWidth',6,'Color',[0.15 0.15 0.17],'LineJoin','round','Visible','off');

theta = linspace(0,2*pi,24);
data.cloudBaseX = cos(theta).*(1+0.25*sin(3*theta));
data.cloudBaseY = sin(theta).*(0.5+0.15*cos(4*theta));
data.cloudBaseXCol = data.cloudBaseX(:);
data.cloudBaseYCol = data.cloudBaseY(:);

data.numClouds = 6;
data.cloudWorldD = -45 + 90*rand(1,data.numClouds);
data.cloudY = 16 + 9*rand(1,data.numClouds);
data.cloudSize = 2 + 2.5*rand(1,data.numClouds);
data.cloudParallax = 0.05 + 0.06*rand(1,data.numClouds);
data.cloudPhase = 2*pi*rand(1,data.numClouds);
data.windSpeed = 0.6;
data.cloudNanRow = nan(1,data.numClouds);
data.CLD = plot(NaN,NaN,'LineWidth',12,'Color',[0.97,0.97,0.99]);

data.rainCount = 120;
data.rainX = -22 + 44*rand(1,data.rainCount);
data.rainY = -5 + 35*rand(1,data.rainCount);
data.rainSpeed = 14 + 6*rand(1,data.rainCount);
data.raining = false;
data.rainWasOn = false;
data.weatherTimer = 5 + 10*rand;
data.rainNanRow = nan(1,data.rainCount);
data.RAIN = plot(NaN,NaN,'Color',[0.6,0.7,0.85],'LineWidth',1,'Visible','off');

minDepth = 0.4;
maxDepth = 1.3;

pine_dark  = [0.02,0.18,0.04];
pine_light = [0.12,0.55,0.08];

for b = 1:data.numPineBins
    frac = (b-0.5)/data.numPineBins;
    binColor = pine_dark + frac*(pine_light-pine_dark);
    data.pineBin(b).plot = plot(NaN,NaN,'LineWidth',4,'Color',binColor);
    data.pineBin(b).worldD = [];
    data.pineBin(b).depthScale = [];
    data.pineBin(b).height = [];
    data.pineBin(b).width = [];
end

for k = 1:data.numPineTrees
    if k <= data.numPineTreesPerSide
        side = 1;
        idxInSide = k;
    else
        side = -1;
        idxInSide = k - data.numPineTreesPerSide;
    end
    worldD = side*(data.pineWorldMin + (data.pineWorldMax-data.pineWorldMin)*rand);
    depthFrac = (idxInSide-1)/(data.numPineTreesPerSide-1);
    depthScale = minDepth + (maxDepth-minDepth)*depthFrac;

    height = 6 + 6*rand;
    width  = 2.5 + 2.5*rand;

    b = min(data.numPineBins, max(1, ceil(depthFrac*data.numPineBins)));
    data.pineBin(b).worldD(end+1)     = worldD;
    data.pineBin(b).depthScale(end+1) = depthScale;
    data.pineBin(b).height(end+1)     = height;
    data.pineBin(b).width(end+1)      = width;
end

data.stalWorldD = data.stalWorldMin + (data.stalWorldMax-data.stalWorldMin)*rand(1,data.numStalactites);
data.stalDepthScale = 0.6 + 0.5*rand(1,data.numStalactites);
data.stalLength = 1.8 + 2.5*rand(1,data.numStalactites);

%% ================= Person Plots =================

data.LAU = plot([0 0],[0 0],'LineWidth',15,'Color',[0.58,0.18,0.25]);
data.LAL = plot([0 0],[0 0],'LineWidth',15,'Color',[0.58,0.18,0.25]);
data.LLU = plot([0 0],[0 0],'LineWidth',15,'Color',[0,0.2,0.5]);
data.LLL = plot([0 0],[0 0],'LineWidth',15,'Color',[0,0.2,0.5]);
data.TOR = plot([0 0],[0 data.Height_torso],'LineWidth',15,'Color',[0.6,0.2,0.3]);
data.HED = plot(0, data.Height_torso*1.14, 'o', 'MarkerSize', 34, ...
    'MarkerFaceColor',[0.85,0.55,0.3],'MarkerEdgeColor',[0.85,0.55,0.3],'LineWidth',1);
data.RLU = plot([0 0],[0, -data.Length_leg_upper],'LineWidth',15,'Color',[0,0.3,0.6]);
data.RLL = plot([0 0],[-data.Length_leg_upper, -data.Length_leg_upper-data.Length_leg_upper],'LineWidth',15,'Color',[0,0.3,0.6]);
data.RAU = plot([0 0],[data.Height_torso*0.8, data.Height_torso*0.8-data.Length_arm_upper],'LineWidth',15,'Color',[0.65,0.25,0.35]);
data.RAL = plot([0 0],[data.Height_torso*0.8-data.Length_arm_upper, data.Height_torso*0.8-data.Length_arm_upper-data.Length_arm_lower],'LineWidth',15,'Color',[0.65,0.25,0.35]);

%% ================= Foreground =================

data.GRD = plot(data.groundX,-(data.Length_leg_upper+data.Length_leg_lower)+ ...
    sin(35*data.groundX),  'LineWidth',4,'Color',[0.7,0.8,0.24]);

data = applyPose(data);
uistack(data.RAFT,'top');
uistack(data.GRD,'top');

data.lastFrameTime = tic;
fig.UserData = data;

while ishandle(fig)
    updateTime(fig);
    pause(0.001);
end
end

%% ================= RUN FUNCTION =================
function updateTime(fig)

data = fig.UserData;

elapsed = toc(data.lastFrameTime);
data.lastFrameTime = tic;
dt = min(elapsed, data.maxDt);
if dt <= 0
    dt = data.dt;
end

data.t = data.t + dt;

if ~(data.jump || data.h > 0)
    if data.moveLeft && (data.t - data.moveLeftLastSeen) > data.keyWatchdog
        data.moveLeft = false;
    end
    if data.moveRight && (data.t - data.moveRightLastSeen) > data.keyWatchdog
        data.moveRight = false;
    end
end

data = movesun(data);
data = seasons(data, dt);

dir = resolveDirection(data);
if dir ~= 0 || data.jump || data.h > 0
    data = movement(data, dt, dir);
end

data = updateWeather(data, dt);

set(data.DistText,'String',sprintf('d = %.1f', data.d));

fig.UserData = data;
drawnow
end

%% ================= KEY CLICKS =================
function keyDown(src,event)
data = src.UserData;

switch event.Key
    case {'a','leftarrow'}
        data.moveLeft = true;
        data.lastDir = -1;
        data.moveLeftLastSeen = data.t;
    case {'d','rightarrow'}
        data.moveRight = true;
        data.lastDir = 1;
        data.moveRightLastSeen = data.t;
    case 'space'
        if ~data.jump
            data.jump = true;
            data.jump_vel = data.jump_velocity;
        end
end

src.UserData = data;
end

function keyUp(src,event)
data = src.UserData;

switch event.Key
    case {'a','leftarrow'}
        data.moveLeft = false;
    case {'d','rightarrow'}
        data.moveRight = false;
end

src.UserData = data;
end

%% ================= BACKGROUND FUNCTIONS =================
function data = movesun(data)
sunx = data.sunShapeX + 20*cos(data.sunstart+data.t*data.daytime);
suny = data.sunShapeY + 20*sin(data.sunstart+data.t*data.daytime);
moonx = -20*cos(data.sunstart+data.t*data.daytime);
moony = -20*sin(data.sunstart+data.t*data.daytime);

set(data.SUN,'XData',sunx,'YData',suny);
set(data.MON,'XData',moonx,'YData',moony);

holdValue = 4;
whitebias = 0.46;
skyangle = data.sunstart + data.t*data.daytime;

SIN = sin(skyangle) + whitebias;
SINBI = max(-1, min(1, SIN));
sincos = sign(SINBI) * (abs(SINBI)^(1/holdValue));

colorVal = 0.5 * (sincos + 1);
dayColor = [colorVal colorVal colorVal];

overrideColor = data.skyOverrideColor;
if data.inHell
    pulse = 1 + data.hellGlowAmp*sin(data.t*1.3);
    overrideColor = min(1, max(0, overrideColor*pulse));
end
finalColor = (1-data.skyOverride)*dayColor + data.skyOverride*overrideColor;

data.figHandle.Color = finalColor;
data.axHandle.Color = finalColor;

if data.skyOverride < 0.5
    set(data.SUN,'Visible','on');
    set(data.MON,'Visible','on');
else
    set(data.SUN,'Visible','off');
    set(data.MON,'Visible','off');
end
end

function data = seasons(data, dt)

holdValue = 3;
shapeHold = 750;
bias = 0.2;
season_angle = data.sunstart + data.t*data.daytime/data.seasonlength;

SIN = sin(season_angle) + bias;
SINBI = max(-1, min(1, SIN));

sincos = sign(SINBI) * (abs(SINBI)^(1/holdValue));
colorVal = 0.5 * (sincos + 1);

shapecos = sign(SINBI) * (abs(SINBI)^(1/shapeHold));
shapeVal = 0.5 * (shapecos + 1);

data.seasonColorVal = colorVal;

data = biomes(data, shapeVal, colorVal, dt);
end

function data = biomes(data, shapeVal, colorVal, dt)

data.leafShapeTimer = data.leafShapeTimer - dt;
recomputeLeaf = false;
if data.leafShapeTimer <= 0
    recomputeLeaf = true;
    data.leafShapeTimer = data.leafShapeInterval;
end

lengths = abs(data.d);
if lengths < 100
    if recomputeLeaf
        fall = data.leafFallMax - shapeVal*(data.leafFallMax-data.leafFallMin);
        data.treeLeafBaseX = -data.Tree_fluf:fall:data.Tree_fluf;
        data.treeLeafBaseY = sin(258.*data.treeLeafBaseX).*sqrt(data.Tree_fluf^2 - data.treeLeafBaseX.^2);
    end
    snow = 10 - shapeVal*(10-2);

    leaf_fall  = [0.48, 0.26, 0.072];
    grass_dead = [0.8, 0.8, 0.94];
    green_leaves = [0.13,.55,0.13];
    green_grass = [0.7,0.8,0.24];

    Grass_color = (1-colorVal) * grass_dead + colorVal * green_grass;
    Leaf_color = (1-colorVal) * leaf_fall + colorVal * green_leaves;

    oakX = aheadSign(data.d)*data.oakWorldD - data.d;
    set(data.TLV,'XData', data.treeLeafBaseX + oakX,'YData', data.treeLeafBaseY + data.Tree_height,'Color', Leaf_color,'Visible','on');
    set(data.TTR,'XData',[oakX,oakX],'Visible','on');
    set(data.GRD,'YData',-(data.Length_leg_upper+data.Length_leg_lower)+sin(35*data.groundX-data.i*data.groundWaveRate*data.l),'Color', Grass_color,'LineWidth',snow);

else
    set(data.TLV,'Visible','off');
    set(data.TTR,'Visible','off');
    set(data.STAL,'Visible','off');
    set(data.TORCH,'Visible','off');
    data.skyOverride = 0;
    data.inDark = false;
    data.inHell = false;
    data.inDesert = false;
    data.inBoat = false;

    if lengths < 150
    d = (lengths - 100)/10;

    snowStart = 10 - shapeVal*(10-2);
    t = min(1,(d^2)/4);
    snow = snowStart + (2 - snowStart)*t;
    grass_dead = [0.8, 0.8, 0.94];
    green_grass = [0.7,0.8,0.24];
    savana_grass = [0.7,0.75,0.2];

    Grass_colorStart = (1-colorVal) * grass_dead + colorVal * green_grass;
    Grass_color = Grass_colorStart + (savana_grass - Grass_colorStart)*t;

    Grass_color = min(1,max(0,Grass_color));
    set(data.GRD,'YData',-(data.Length_leg_upper+data.Length_leg_lower)+(d+1)*sin(35*data.groundX-data.i*data.groundWaveRate*data.l),'Color', Grass_color,'LineWidth',snow);

    elseif lengths < 250
    set(data.GRD,'YData',-(data.Length_leg_upper+data.Length_leg_lower)+6*sin(35*data.groundX-data.i*data.groundWaveRate*data.l));

    elseif lengths < 300
    d = (lengths - 250)/10;

    t = (exp(4*d/5) - 1) / (exp(4) - 1);
    snowStart = 10 - shapeVal*(10-2);
    snow = 2 + (snowStart - 2)*t;
    savana_grass = [0.7,0.75,0.2];
    forest_grass = [.1,1,0.1];
    grass_dead = [0.8, 0.8, 0.94];

    Grass_colorFinal = (1-colorVal) * grass_dead + colorVal * forest_grass;
    Grass_color = savana_grass + (Grass_colorFinal - savana_grass)*t;

    Grass_color = min(1,max(0,Grass_color));
    set(data.GRD,'YData',-(data.Length_leg_upper+data.Length_leg_lower)+(6-d*1.1)*sin(35*data.groundX-data.i*data.groundWaveRate*data.l),'Color', Grass_color,'LineWidth',snow);

    elseif lengths < 400
    snow = 10 - shapeVal*(10-2);
    grass_dead = [0.8, 0.8, 0.94];
    forest_grass = [.1,1,0.1];
    Grass_color = (1-colorVal) * grass_dead + colorVal * forest_grass;

    set(data.GRD,'YData',-(data.Length_leg_upper+data.Length_leg_lower)+ 0.5*sin(35*data.groundX-data.i*data.groundWaveRate*data.l),'Color', Grass_color,'LineWidth',snow);

    elseif lengths < 450
    t = (lengths - 400)/50;
    t = t*t*(3-2*t);

    grass_dead = [0.8, 0.8, 0.94];
    forest_grass = [.1,1,0.1];
    forestColor = (1-colorVal) * grass_dead + colorVal * forest_grass;

    Grass_color = (1-t)*forestColor + t*data.sandColor;
    amp = (1-t)*0.5 + t*data.sandAmp;
    lw = (1-t)*(10-shapeVal*(10-2)) + t*6;

    set(data.GRD,'YData',-(data.Length_leg_upper+data.Length_leg_lower)+amp*sin(35*data.groundX-data.i*data.groundWaveRate*data.l),'Color', Grass_color,'LineWidth',lw);

    elseif lengths < 550
    data.inDesert = true;
    set(data.GRD,'YData',-(data.Length_leg_upper+data.Length_leg_lower)+data.sandAmp*sin(35*data.groundX-data.i*data.groundWaveRate*data.l),'Color', data.sandColor,'LineWidth',6);

    elseif lengths < 600
    t = (lengths - 550)/50;
    t = t*t*(3-2*t);

    Grass_color = (1-t)*data.sandColor + t*data.waterColor;
    amp = (1-t)*data.sandAmp + t*data.waterAmp;

    set(data.GRD,'YData',-(data.Length_leg_upper+data.Length_leg_lower)+amp*sin(35*data.groundX-data.i*data.groundWaveRate*data.l),'Color', Grass_color,'LineWidth',6);

    elseif lengths < 700
    theta = 35*data.groundX - data.i*data.groundWaveRate*data.l;
    waveShape = (sin(theta) - data.waveSharpness*cos(2*theta)) / (1+data.waveSharpness);
    set(data.GRD,'YData',-(data.Length_leg_upper+data.Length_leg_lower)+data.waterAmp*waveShape,'Color', data.waterColor,'LineWidth',6);

    elseif lengths < 750
    t = (lengths - 700)/50;
    t = t*t*(3-2*t);

    Grass_color = (1-t)*data.waterColor + t*data.rockyColor;
    amp = (1-t)*data.waterAmp + t*data.rockyAmp;
    set(data.GRD,'YData',-(data.Length_leg_upper+data.Length_leg_lower)+amp*sin(35*data.groundX-data.i*data.groundWaveRate*data.l),'Color', Grass_color,'LineWidth',6);

    elseif lengths < 850
    set(data.GRD,'YData',-(data.Length_leg_upper+data.Length_leg_lower)+data.rockyAmp*sin(35*data.groundX-data.i*data.groundWaveRate*data.l),'Color', data.rockyColor,'LineWidth',6);

    elseif lengths < 900
    t = (lengths - 850)/50;
    t = t*t*(3-2*t);

    Grass_color = (1-t)*data.rockyColor + t*data.caveGroundColor;
    amp = (1-t)*data.rockyAmp + t*data.caveAmp;
    set(data.GRD,'YData',-(data.Length_leg_upper+data.Length_leg_lower)+amp*sin(35*data.groundX-data.i*data.groundWaveRate*data.l),'Color', Grass_color,'LineWidth',6);

    data.skyOverride = t;
    data.skyOverrideColor = data.caveSkyColor;
    data.inDark = t > 0.5;

    elseif lengths < 1000
    set(data.GRD,'YData',-(data.Length_leg_upper+data.Length_leg_lower)+data.caveAmp*sin(35*data.groundX-data.i*data.groundWaveRate*data.l),'Color', data.caveGroundColor,'LineWidth',6);

    data.skyOverride = 1;
    data.skyOverrideColor = data.caveSkyColor;
    data.inDark = true;

    data = updateStalactites(data, dt);
    set(data.STAL,'Visible','on');

    elseif lengths < 1050
    t = (lengths - 1000)/50;
    t = t*t*(3-2*t);

    Grass_color = (1-t)*data.caveGroundColor + t*data.hellGroundColor;
    amp = (1-t)*data.caveAmp + t*data.hellAmp;
    set(data.GRD,'YData',-(data.Length_leg_upper+data.Length_leg_lower)+amp*sin(35*data.groundX-data.i*data.groundWaveRate*data.l),'Color', Grass_color,'LineWidth',6);

    data.skyOverride = 1;
    data.skyOverrideColor = (1-t)*data.caveSkyColor + t*data.hellSkyColor;
    data.inDark = true;
    data.inHell = t > 0.6;

    if t < 0.7
        data = updateStalactites(data, dt);
        set(data.STAL,'Visible','on');
    end

    else
    set(data.GRD,'YData',-(data.Length_leg_upper+data.Length_leg_lower)+data.hellAmp*sin(35*data.groundX-data.i*data.groundWaveRate*data.l),'Color', data.hellGroundColor,'LineWidth',6);

    data.skyOverride = 1;
    data.skyOverrideColor = data.hellSkyColor;
    data.inDark = true;
    data.inHell = true;
    end

    data.inBoat = lengths >= 580 && lengths <= 720;
    if data.inDark
        data.rightArmMode = 1;
    elseif data.inBoat
        data.rightArmMode = 2;
    else
        data.rightArmMode = 0;
    end
end

data = updateTorch(data);
data = updateMountains(data, lengths);
data = updateCaveWall(data, lengths);
data = updateGate(data);
data = updateRaft(data);
data = updateBoatMotor(data);

for ck = 1:data.numCacti
    data = updateCactus(data, data.CACTI(ck), aheadSign(data.d)*data.cactusWorldD(ck));
end
data = updateRocks(data);
data = updatePineTrees(data);
end

function s = aheadSign(d)
s = sign(d);
if s == 0
    s = 1;
end
end

function data = updateCactus(data, handle, worldD)
xOff = worldD - data.d;

if abs(xOff) > data.cactusCullMargin
    set(handle,'XData',NaN,'YData',NaN);
    return
end

groundY = -(data.Length_leg_upper+data.Length_leg_lower);
hgt = data.cactusHeight;
s = data.cactusArmSpread;

X = [xOff, xOff, NaN, xOff, xOff-s, xOff-s, NaN, xOff, xOff+s, xOff+s];
Y = [groundY, groundY+hgt, NaN, groundY+hgt*0.55, groundY+hgt*0.55, groundY+hgt*0.85, NaN, groundY+hgt*0.4, groundY+hgt*0.4, groundY+hgt*0.75];

set(handle,'XData',X,'YData',Y,'Visible','on');
end

function data = updateRocks(data)
groundY = -(data.Length_leg_upper+data.Length_leg_lower);
theta = [0.3, 1.4, 2.6, 3.5, 4.6, 5.7];
rx = [1, 0.7, 0.9, 1.1, 0.6, 0.95];
ry = [0.5, 0.7, 0.4, 0.6, 0.5, 0.35];

for rk = 1:data.numRocks
    worldD = aheadSign(data.d) * data.rockWorldD(rk);
    xOff = worldD - data.d;
    if abs(xOff) > data.rockCullMargin
        set(data.ROCKS(rk),'XData',NaN,'YData',NaN);
        continue
    end
    sz = data.rockSize(rk);
    X = xOff + rx.*cos(theta)*sz;
    Y = groundY + 0.8*sz + ry.*sin(theta)*sz;
    set(data.ROCKS(rk),'XData',X,'YData',Y,'Visible','on');
end
end

function data = updateMountains(data, lengths)
fadeStart = 630;
fadeFull = 780;
hideAt = 900;

if lengths < fadeStart || lengths >= hideAt
    set(data.MTN,'Visible','off');
    return
end

if lengths < fadeFull
    tIn = (lengths - fadeStart)/(fadeFull-fadeStart);
    alpha = tIn*tIn*(3-2*tIn);
else
    alpha = 1;
end

dx = -data.d*data.mountainParallax;
for pk = 1:data.numMountains
    set(data.MTN(pk),'XData',data.mountainTriX{pk}+dx,'YData',data.mountainTriY{pk}, ...
        'Visible','on','FaceAlpha',alpha);
end
end

function data = updateRaft(data)
if ~data.inBoat
    set(data.RAFT,'Visible','off');
    return
end
set(data.RAFT,'Visible','on');
end

function data = updateBoatMotor(data)
if ~data.inBoat
    set(data.HullMotorOval,'Visible','off');
    set(data.HullMotor,'Visible','off');
    return
end

facing = sign(data.i);
if facing == 0
    facing = -1;
end
mx = facing*data.motorOffsetX;
my0 = data.hullTopY - 0.3;

ovalTheta = linspace(0,2*pi,20);
ovalX = mx + 0.75*cos(ovalTheta);
ovalY = (my0+0.8) + 1.2*sin(ovalTheta);
set(data.HullMotorOval,'XData',ovalX,'YData',ovalY,'Visible','on');

housingX = mx + facing*[-0.5, -0.5, 0.5, 0.5];
housingY = my0 + [0, 1.6, 1.6, 0];
propX = [mx, mx];
propY = [my0-1.1, my0];

X = [housingX, NaN, propX];
Y = [housingY, NaN, propY];
set(data.HullMotor,'XData',X,'YData',Y,'Visible','on');
end

function data = updateStalactites(data, dt)
ceilingY = 29;
worldD = aheadSign(data.d) * data.stalWorldD;
xOff = (worldD - data.d) .* data.stalDepthScale;

visible = abs(xOff) < data.stalCullMargin;
if ~any(visible)
    set(data.STAL,'XData',NaN,'YData',NaN);
    set(data.DRIP,'XData',NaN,'YData',NaN);
    return
end

baseX = data.pineBaseXNorm;
baseY = data.pineBaseYNorm;

xV = xOff(visible);
hV = data.stalLength(visible);
wV = data.stalWidth(visible);

CX = xV + baseX*wV;
CY = ceilingY - hV - baseY.*hV;

nanRow = nan(1,size(CX,2));
CX = [CX; nanRow];
CY = [CY; nanRow];
set(data.STAL,'XData',CX(:)','YData',CY(:)');

idx = find(visible);
tipY = ceilingY - 2*hV;
dripX = nan(1,numel(idx));
dripYplot = nan(1,numel(idx));

for k = 1:numel(idx)
    j = idx(k);
    if data.dripActive(j)
        data.dripY(j) = data.dripY(j) + data.dripSpeed(j)*dt;
        if data.dripY(j) > 2.2
            data.dripActive(j) = false;
            data.dripTimer(j) = 1.5 + 3*rand;
        else
            dripX(k) = xV(k);
            dripYplot(k) = tipY(k) - data.dripY(j);
        end
    else
        data.dripTimer(j) = data.dripTimer(j) - dt;
        if data.dripTimer(j) <= 0
            data.dripActive(j) = true;
            data.dripY(j) = 0;
        end
    end
end

set(data.DRIP,'XData',dripX,'YData',dripYplot);
end

function data = updateTorch(data)
if ~data.inDark
    set(data.TORCHSTICK,'Visible','off');
    set(data.TORCH,'Visible','off');
    return
end

hx = data.handPos(1);
hy = data.handPos(2);
tx = hx;
ty = hy + data.torchStickLength;

set(data.TORCHSTICK,'XData',[hx tx],'YData',[hy ty],'Visible','on');

flicker = 0.15*sin(data.t*data.torchFlickerSpeed) + 0.1*sin(data.t*data.torchFlickerSpeed*2.3);

X = [tx, tx, tx-0.15+flicker*0.3, tx, tx+0.18];
Y = [ty, ty+0.5, ty+0.9+flicker, ty+1.3+flicker*1.5, ty+0.85+flicker*0.5];

flameColor = min(1, max(0, data.torchColor + [flicker*0.3, flicker*0.15, 0]));
set(data.TORCH,'XData',X,'YData',Y,'Visible','on','Color',flameColor);
end

function data = updateCaveWall(data, lengths)
slideInStart = 850; slideInEnd = 900;

if lengths < slideInStart
    set(data.CAVEWALL,'Visible','off');
    return
end

ahead = aheadSign(data.d);

if lengths < slideInEnd
    t = (lengths - slideInStart)/(slideInEnd-slideInStart);
    t = t*t*(3-2*t);
    xEntrance = ahead*45*(1-2*t);
else
    xEntrance = -ahead*45;
end

xExit = ahead*data.gateWorldD - data.d;

if ahead*xExit < ahead*xEntrance
    set(data.CAVEWALL,'Visible','off');
    return
end

groundY = -(data.Length_leg_upper+data.Length_leg_lower);

entranceX = xEntrance + data.wallJagDX;
entranceY = data.wallJagY;
exitX = xExit + fliplr(data.exitJagDX);
exitY = fliplr(data.exitJagY);

X = [entranceX, xEntrance+ahead*30, exitX];
Y = [entranceY, 35, exitY];

set(data.CAVEWALL,'XData',X,'YData',Y,'Visible','on','FaceAlpha',1);
end

function data = updateGate(data)
worldD = aheadSign(data.d) * data.gateWorldD;
xOff = worldD - data.d;

if abs(xOff) > data.gateCullMargin
    set(data.GATEBARS,'XData',NaN,'YData',NaN);
    return
end

groundY = -(data.Length_leg_upper+data.Length_leg_lower);
n = data.numGateBars;
barX = xOff + ((1:n)-(n+1)/2)*data.gateBarSpacing;
topY = groundY + data.gateBarHeight;

X = [barX; barX; nan(1,n)];
Y = repmat([groundY; topY; NaN], 1, n);

X = [X(:); barX(1); barX(end); NaN];
Y = [Y(:); topY; topY; NaN];

set(data.GATEBARS,'XData',X','YData',Y');
end

function data = updatePineTrees(data)
groundY = -(data.Length_leg_upper+data.Length_leg_lower);

baseX = data.pineBaseXNorm; 
baseY = data.pineBaseYNorm; 

for b = 1:data.numPineBins
    wD = data.pineBin(b).worldD; 
    if isempty(wD)
        continue
    end
    ds = data.pineBin(b).depthScale; 
    h  = data.pineBin(b).height;    
    w  = data.pineBin(b).width;    

    xOff = (wD - data.d).*ds; 

    visible = abs(xOff) < data.pineCullMargin;
    if ~any(visible)
        set(data.pineBin(b).plot,'XData',NaN,'YData',NaN);
        continue
    end

    xOff = xOff(visible);
    hV = h(visible);
    wV = w(visible);

    CX = xOff + baseX*wV;     
    CY = groundY + hV + baseY*hV;

    nanRow = nan(1,size(CX,2));
    CX = [CX; nanRow];
    CY = [CY; nanRow];

    set(data.pineBin(b).plot,'XData',CX(:)','YData',CY(:)');
end
end

function data = updateClouds(data)
span = 100;
driftPos = data.cloudWorldD - data.d.*data.cloudParallax - data.t*data.windSpeed;
x = mod(driftPos + span/2, span) - span/2;

y = data.cloudY + 0.3*sin(data.t*0.3 + data.cloudPhase);

sz = data.cloudSize;

CX = x + data.cloudBaseXCol*sz;
CY = y + data.cloudBaseYCol*(sz*0.6);

CX = [CX; data.cloudNanRow];
CY = [CY; data.cloudNanRow];

set(data.CLD,'XData',CX(:)','YData',CY(:)');
end

function data = updateWeather(data, dt)

if data.inDesert || (data.inDark && ~data.inHell)
    data.raining = false;
    if data.rainWasOn
        set(data.RAIN,'Visible','off');
    end
    data.rainWasOn = false;
    return
end

if data.inHell
    data.raining = true;
else
    data.weatherTimer = data.weatherTimer - dt;
    if data.weatherTimer <= 0
        coldFactor = 1 - data.seasonColorVal;
        rainChance = 0.25 + 0.35*coldFactor;
        data.raining = rand < rainChance;
        if data.raining
            data.weatherTimer = 8 + 12*rand;
        else
            data.weatherTimer = 15 + 20*rand;
        end
    end
end

if data.raining
    data.rainY = data.rainY - data.rainSpeed*dt;
    below = data.rainY < -5;
    n = nnz(below);
    if n > 0
        data.rainY(below) = 28 + 2*rand(1,n);
        data.rainX(below) = -22 + 44*rand(1,n);
    end

    X = [data.rainX; data.rainX; data.rainNanRow];
    Y = [data.rainY; data.rainY-0.4; data.rainNanRow];
    if data.inHell
        rainColor = data.hellRainColor;
    else
        rainColor = [0.6, 0.7, 0.85];
    end
    set(data.RAIN,'XData',X(:)','YData',Y(:)','Visible','on','Color',rainColor);

    c = min(1,max(0, data.axHandle.Color*0.65));
    data.axHandle.Color = c;
    data.figHandle.Color = c;
elseif data.rainWasOn
    set(data.RAIN,'Visible','off');
end
data.rainWasOn = data.raining;
end

%% ================= MOVEMENT =================
function dir = resolveDirection(data)
leftActive  = data.moveLeft  || (data.t - data.moveLeftLastSeen)  < data.moveGrace;
rightActive = data.moveRight || (data.t - data.moveRightLastSeen) < data.moveGrace;

if leftActive && rightActive
    dir = data.lastDir;
elseif leftActive
    dir = -1;
elseif rightActive
    dir = 1;
else
    dir = 0;
end
end

function data = movement(data, dt, dir)

wasAirborne = data.jump || data.h > 0;
if dir == 0 && wasAirborne && data.airDir ~= 0
    dir = data.airDir;
end

switch dir
    case -1
        data = walkLeftMovement(data, dt);
    case 1
        data = walkRightMovement(data, dt);
    otherwise
        data = idlePose(data, dt);
end

if data.jump || data.h > 0
    data = jumpMovement(data, dt);
    if dir ~= 0
        data.airDir = dir;
    end
else
    data.airDir = 0;
end

data = applyPose(data);
end

function data = walkLeftMovement(data, dt)
data.l = data.l + dt*data.strideRate;
data.i = 1;
data.d = data.d - data.walkSpeed*dt;
data = strideSwing(data, dt);
end

function data = walkRightMovement(data, dt)
data.l = data.l + dt*data.strideRate;
data.i = -1;
data.d = data.d + data.walkSpeed*dt;
data = strideSwing(data, dt);
end

function data = strideSwing(data, dt)
roof = ceil(data.l);
di = (-(-1)^roof) * dt * data.strideRate;

data.Rotator_cuff_left  = data.Rotator_cuff_left  - di*60;
data.Rotator_cuff_right = data.Rotator_cuff_right + di*60;
data.Iliopsoas_left     = data.Iliopsoas_left     + di*60;
data.Iliopsoas_right    = data.Iliopsoas_right    - di*60;

data.Rotator_cuff_left  = min(max(data.Rotator_cuff_left,  -30), 30);
data.Rotator_cuff_right = min(max(data.Rotator_cuff_right, -30), 30);
data.Iliopsoas_left  = min(max(data.Iliopsoas_left,  -33), 23);
data.Iliopsoas_right = min(max(data.Iliopsoas_right, -33), 23);
end

function data = idlePose(data, dt)
ease = min(1, 4*dt);
data.Rotator_cuff_left  = data.Rotator_cuff_left  + (0 - data.Rotator_cuff_left)*ease;
data.Rotator_cuff_right = data.Rotator_cuff_right + (0 - data.Rotator_cuff_right)*ease;
data.Iliopsoas_left     = data.Iliopsoas_left     + (-5 - data.Iliopsoas_left)*ease;
data.Iliopsoas_right    = data.Iliopsoas_right    + (-5 - data.Iliopsoas_right)*ease;
end

function data = jumpMovement(data, dt)
data.h = data.h + data.jump_vel*dt;
data.jump_vel = data.jump_vel + data.G*dt;
if data.h <= 0
    data.h = 0;
    data.jump_vel = 0;
    data.jump = false;
end
end

function data = applyPose(data)
i = data.i;
Brachialis_left  = (data.Rotator_cuff_left + data.elbow)*i;
Brachialis_right = (data.Rotator_cuff_right + data.elbow)*i;
Hamstring_left   = (data.Iliopsoas_left + data.knee)*i;
Hamstring_right  = (data.Iliopsoas_right + data.knee)*i;

shoulder = [sind(i*data.Back_bend),-cosd(i*data.Back_bend)]*(0.8*data.Height_torso);

Arm_left_upper  = shoulder + [sind(i*data.Rotator_cuff_left),-cosd(i*data.Rotator_cuff_left)]*data.Length_arm_upper;
Arm_left_lower  = Arm_left_upper + [sind(Brachialis_left),-cosd(Brachialis_left)]*data.Length_arm_lower;

Arm_right_upper = shoulder + [sind(i*data.Rotator_cuff_right),-cosd(i*data.Rotator_cuff_right)]*data.Length_arm_upper;
Arm_right_lower = Arm_right_upper + [sind(Brachialis_right),-cosd(Brachialis_right)]*data.Length_arm_lower;

if data.rightArmMode == 1
    armShoulderAngle = -35*i;
    armElbowAngle = -55*i;
    Arm_right_upper = shoulder + [sind(armShoulderAngle),-cosd(armShoulderAngle)]*data.Length_arm_upper;
    Arm_right_lower = Arm_right_upper + [sind(armElbowAngle),-cosd(armElbowAngle)]*data.Length_arm_lower;
elseif data.rightArmMode == 2
    armShoulderAngle = 55*i;
    armElbowAngle = 75*i;
    Arm_right_upper = shoulder + [sind(armShoulderAngle),-cosd(armShoulderAngle)]*data.Length_arm_upper;
    Arm_right_lower = Arm_right_upper + [sind(armElbowAngle),-cosd(armElbowAngle)]*data.Length_arm_lower;
end

if data.inBoat
    leftShoulderAngle = -8*i;
    leftElbowAngle = -15*i;
    Arm_left_upper = shoulder + [sind(leftShoulderAngle),-cosd(leftShoulderAngle)]*data.Length_arm_upper;
    Arm_left_lower = Arm_left_upper + [sind(leftElbowAngle),-cosd(leftElbowAngle)]*data.Length_arm_lower;
end

Leg_left_upper  = [sind(i*data.Iliopsoas_left),-cosd(i*data.Iliopsoas_left)]*data.Length_leg_upper;
Leg_left_lower  = Leg_left_upper + [sind(Hamstring_left),-cosd(Hamstring_left)]*data.Length_leg_lower;

Leg_right_upper = [sind(i*data.Iliopsoas_right),-cosd(i*data.Iliopsoas_right)]*data.Length_leg_upper;
Leg_right_lower = Leg_right_upper + [sind(Hamstring_right),-cosd(Hamstring_right)]*data.Length_leg_lower;

h = data.h;

set(data.LAU,'XData',[shoulder(1),Arm_left_upper(1)], 'YData',[shoulder(2),Arm_left_upper(2)]+h);
set(data.LAL,'XData',[Arm_left_upper(1),Arm_left_lower(1)], 'YData',[Arm_left_upper(2),Arm_left_lower(2)]+h);
set(data.RAU,'XData',[shoulder(1),Arm_right_upper(1)], 'YData',[shoulder(2),Arm_right_upper(2)]+h);
set(data.RAL,'XData',[Arm_right_upper(1),Arm_right_lower(1)], 'YData',[Arm_right_upper(2),Arm_right_lower(2)]+h);
set(data.LLU,'XData',[0,Leg_left_upper(1)], 'YData',[0,Leg_left_upper(2)]+h);
set(data.LLL,'XData',[Leg_left_upper(1),Leg_left_lower(1)], 'YData',[Leg_left_upper(2),Leg_left_lower(2)]+h);
set(data.RLU,'XData',[0,Leg_right_upper(1)], 'YData',[0,Leg_right_upper(2)]+h);
set(data.RLL,'XData',[Leg_right_upper(1),Leg_right_lower(1)], 'YData',[Leg_right_upper(2),Leg_right_lower(2)]+h);

set(data.HED,'XData',sind(data.Back_bend)*data.Height_torso*1.14, 'YData',-cosd(data.Back_bend)*data.Height_torso*1.14+h);
set(data.TOR,'XData',[0,sind(data.Back_bend)]*data.Height_torso, 'YData',[0,-cosd(data.Back_bend)]*data.Height_torso+h);

data.handPos = [Arm_right_lower(1), Arm_right_lower(2)+h];
end