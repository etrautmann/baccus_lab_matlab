%test FindRFCenterLine.m


AssertOpenGL;
exception=0;
WHICHRIG = 1;           % which computer run on?  Intracellular=1, Laser = 2, Tobi's laptop=0
                        % if set to 0, don't expect any digital inputs
NUMFLASHES = 6;

if WHICHRIG==1
    stimScreen.num = 2;           % if 3 monitors, probably at IC rig: CRT is monitor 2
else
    stimScreen.num = max(Screen('Screens'));        % use highest screen number
end
stimWin=Screen('OpenWindow',stimScreen.num);

[xSize ySize]=Screen('WindowSize', stimWin);
stimScreen.xSize = xSize;
stimScreen.ySize = ySize;
stimScreen.black=BlackIndex(stimWin);
stimScreen.white=WhiteIndex(stimWin);
stimScreen.gray=((stimScreen.black+stimScreen.white+1)/2)-1;
stimScreen.period=Screen('GetFlipInterval',stimWin);
Screen('Flip',stimWin);

% Frames=2*ceil(Duration/stimScreen.period/2);

photodiode=ones(4,1);
photodiode(1,:)=xSize/10*9;
photodiode(2,:)=ySize/10*1;
photodiode(3,:)=xSize/10*9+80;
photodiode(4,:)=ySize/10*1+80;

Screen('FillRect', stimWin, stimScreen.white);
Screen('Flip',stimWin);

% ListenChar(2);      % disable keyboard input from going to command line
% WaitForSpaceBarPress();
% HideCursor;
% Priority(MaxPriority(stimWin));
if WHICHRIG==1          % IC rig
    dio = ReadParallel_init();
elseif WHICHRIG==2      % laser rig
    dio = ReadDigitalIn_init();
else
    dio = 0;
end

Screen('FillOval', stimWin, stimScreen.black, photodiode);
vbl=Screen('Flip',stimWin);

RF.xCenter = findRFCenterLine(dio, stimScreen, stimWin, 'X', WHICHRIG);







