function [ params ] = TestFlash()

% Function written to familiarize myself with both MatLab and the
% Psychophysics toolbox.  Upon keyboard input, changes screen from black to
% white...  For later implementations, keep a constant time base in the
% photodiode pulse.
% 
% try
    ScreenNum = 0;
    StimWin = Screen('OpenWindow', ScreenNum);          % get pointer to stimulus window

    [xsize ysize ] = Screen('WindowSize', StimWin);
    ScreenRes = [xsize ysize ];
    black = BlackIndex(StimWin);
    white = WhiteIndex(StimWin);
    FrameInterval = Screen('GetFlipInterval', StimWin);
    FrameTime = 2 * FrameInterval;                % Baccus lab custom, changes every 2 frames
    [vbl]=Screen('Flip',StimWin);
    
    DurationSec = 2;               % in seconds
    FlashRate_sec = 2;                  % how fast to flicker?
    FlashPeriod = ceil( (1/FlashRate_sec)/FrameTime);          % in # of frames 
    FlashRate_secReal = 1/(FlashPeriod*FrameTime);         % same, but in frames and rounded 
    %DurationFrames = ceil(DurationSec/FrameInterval) ;     % in frames
    Reps = ceil(DurationSec*FlashRate_sec);
    ActualDurationSec = Reps/FlashRate_secReal;        % to correct for rounding errors...
    %Reps = round(DurationSec*FlashPeriod*FlashRate_sec)         % how many repetitions?
    params = [DurationSec ActualDurationSec FlashRate_sec FlashRate_secReal Reps];
    
    photodiode=ones(4,1);           % photodiode code from David
    photodiode(1,:)=ScreenRes(1,1)/10*9;            %x
    photodiode(2,:)=ScreenRes(1,2)/10*1;             %y
    photodiode(3,:)=ScreenRes(1,1)/10*9+80;
    photodiode(4,:)=ScreenRes(1,2)/10*1+80;


    WaitForSpaceBarPress();         % start experiment

    HideCursor
    Priority(MaxPriority(StimWin));
    
    Screen('FillRect', StimWin, black);        % start with black
    vbl=Screen('Flip',StimWin, vbl+FrameTime+.001);

    for i=1:Reps
        for j=1:FlashPeriod/2
            Screen('FillRect', StimWin, white);
            if i==1 && j==1     % wait a bit for first execution?
                vbl=Screen('Flip',StimWin, vbl+FrameTime*1+.001);
            else
                vbl=Screen('Flip',StimWin, vbl+FrameTime+.001);
            end
        end
        for j=1:FlashPeriod/2
            Screen('FillRect', StimWin, black);
            vbl=Screen('Flip',StimWin, vbl+FrameTime+.001);
        end
        if KbCheck
            break;
        end
    end
     
    Screen('CloseAll');
    ShowCursor;
% catch exception
%     'Entering catch clause'
%     Screen('CloseAll');
%     ShowCursor;
% end
% 
% end

% 
% return
% 
% HideCursor;
% Screen('FillRect', StimWin, black);
% Screen('Flip', StimWin);
% 
% tic
% while toc < 1
%                    % do nothing
% end
% 
% Screen('FillRect', StimWin, white);
% Screen('Flip', StimWin);
% 
% tic
% while toc < 1
%                    % do nothing
% end
% 
% 
% Screen('CloseAll');
% ShowCursor;


    


