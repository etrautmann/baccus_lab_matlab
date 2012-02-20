Screen('FillRect', stimWin, stimScreen.white);
Screen('Flip',stimWin);

%%
ScreenNum = 1;
StimWin = Screen('OpenWindow', ScreenNum);          % get pointer to stimulus window

[xsize ysize ] = Screen('WindowSize', StimWin);
Screen('FillOval', stimWin, stimScreen.black, [100,-100,400,300]);
vbl=Screen('Flip',stimWin);
    
pause(3)
Screen('CloseAll');

%%

ScreenNum = 1;
StimWin = Screen('OpenWindow', ScreenNum);          % get pointer to stimulus window

[xsize ysize ] = Screen('WindowSize', StimWin);
ScreenRes = [xsize ysize ];
black = BlackIndex(StimWin);
white = WhiteIndex(StimWin);

Screen('FillRect', StimWin, black);        % start with black
[vbl]=Screen('Flip',StimWin);
Screen('FillRect', stimWin, stimScreen.white,[0;0;100;ysize]);
Screen('Flip',stimWin);

%%
Screen('FillRect', StimWin, black);        % start with black
[vbl]=Screen('Flip',StimWin);
pause(1)
Screen('FillRect', StimWin, white);        
[vbl]=Screen('Flip',StimWin);
pause(1)

Screen('CloseAll');
