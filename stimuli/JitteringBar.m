function [ exception ] = JitteringBar(Duration, Repeats, BarSize, NoWaitForSpace)
% displays a vertical bar that jitters up and down for Duration s
% this is repeated Repeats times with exactly the same trajectory
% modified from david's stimulus, ContrastHistory21
% Set NoWaitForSpace to 0 in order to skip the keyboard acknowledgement

AssertOpenGL;
exception=0;
whichRig = 1;           % which computer is this being run on?  
                        % Intracellular=1, Laser = 2, Tobi's laptop=0
                        % if set to 0, don't expect any digital inputs
try
    if( nargin==3 )         % is last argument supplied?
       NoWaitForSpace = 0; 
    end
    
    if whichRig==1
        stimScreen.num = 2;           % if 3 monitors, probably at IC rig: CRT is monitor 2
    else
        stimScreen.num = max(Screen('Screens'));        % use highest screen number (accessory screens)
    end
    stimWin=Screen('OpenWindow',stimScreen.num);

    [xsize ysize]=Screen('WindowSize', stimWin);
    stimScreen.xsize = xsize;
    stimScreen.ysize = ysize;
    stimScreen.black=BlackIndex(stimWin);
    stimScreen.white=WhiteIndex(stimWin);
    stimScreen.gray=((stimScreen.black+stimScreen.white+1)/2)-1;
    stimScreen.period=Screen('GetFlipInterval',stimWin);
    Screen('Flip',stimWin);

    Frames=2*ceil(Duration/stimScreen.period/2);

%     Bar = [ 1 1 xsize round(ysize/2-BarSize/2)-1; 1
%     round(ysize/2-BarSize/2) xsize round(ysize/2+BarSize/2); 1 round(ysize/2+BarSize/2)+1 xsize ysize;];
    Bar.yPos = ysize/2;
    Bar.size = BarSize/2;        % simplify equation
    Bar.coord = [ 1 1 1; ...
        1 round(Bar.yPos-Bar.size) round(Bar.yPos+Bar.size)+1; ...
        stimScreen.xsize stimScreen.xsize stimScreen.xsize; ...
        round(Bar.yPos-Bar.size)-1 round(Bar.yPos+Bar.size) stimScreen.ysize;];
        % bar starts off centered
    %LTRB
    Bar.color = zeros(3,3);
    Bar.color(:,1)=stimScreen.white;
    Bar.color(:,3)=stimScreen.white;    

    photodiode=ones(4,1);       % larger size for full coverage
    photodiode(1,:)=xsize*8.75/10;
    photodiode(2,:)=ysize*0.75/10;
    photodiode(3,:)=xsize*8.75/10+120;
    photodiode(4,:)=ysize*0.75/10+120;

    Screen('FillRect', stimWin, stimScreen.gray);
    Screen('Flip',stimWin);

    if ( NoWaitForSpace==0 )
        WaitForSpaceBarPress();
    end
    HideCursor;
    Priority(MaxPriority(stimWin));
    if whichRig==1          % IC rig
        dio = ReadParallel_init();
    elseif whichRig==2      % laser rig
        dio = ReadDigitalIn_init();
    else
        dio = 0;
    end
    
    ListenChar(2);      % disable keyboard input from going to command line
    Counter = 0;
    
    Screen('FillRect', stimWin, stimScreen.white);
    Screen('FillOval', stimWin, stimScreen.black, photodiode);
    vbl=Screen('Flip',stimWin);
    Screen('Flip',stimWin, vbl+stimScreen.period*28+.001);

    for j=1:Repeats
        % initialize random number generator
        stream = RandStream('mcg16807', 'Seed', 0);
        Bar.yPos = ysize/2;

        Screen('FillRect', stimWin, stimScreen.gray);
        Screen('FillOval', stimWin, stimScreen.black, photodiode);
        vbl = Screen('Flip',stimWin);   
        Screen('Flip',stimWin, vbl+stimScreen.period*9+.001);      % 10 frames between repeats

        for i=1:Frames
            % read keyboard and DAQ/parallel port inputs
            [ Exit, ~, ~ ] = TrackObj_readInputs(dio, Counter, whichRig);
            if ( Exit )
                break
            end
            % update bar position with Shift and jitter (1 pixel either way)
            Bar.yPos = Bar.yPos + randi(stream, 2)*10-15;

            % update rectangles defining bar, for wrapping Screen requires
            Bar = UpdateBarPosition(Bar, stimScreen);

            Screen('FillRect', stimWin, Bar.color, Bar.coord);
            if ( i==1 )                     % white only on first presentation
                Screen('FillOval', stimWin, stimScreen.white, photodiode);
            elseif (mod(i-1, 60)==1 )        % gray on all others, roughly once a second
                Screen('FillOval', stimWin, stimScreen.gray, photodiode);
            else         
                Screen('FillOval', stimWin, stimScreen.black, photodiode);
            end
            Screen('Flip',stimWin);
        end
    end

    Screen('CloseAll');
    ShowCursor;
    ListenChar(0);      % re-enable keyboard input
catch exception
    Screen('CloseAll');
    ShowCursor;
    ListenChar(0);      % re-enable keyboard input
end