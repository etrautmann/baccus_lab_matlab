
ScreenNum = 0;
StimWin = Screen('OpenWindow', ScreenNum);          % get pointer to stimulus window

[xsize ysize ] = Screen('WindowSize', StimWin);
ScreenRes = [xsize ysize ];
black = BlackIndex(StimWin);
white = WhiteIndex(StimWin);

Screen('FillRect', StimWin, black);        % start with black
[vbl]=Screen('Flip',StimWin);
pause(1)
Screen('FillRect', StimWin, white);        
[vbl]=Screen('Flip',StimWin);
pause(1)


Screen('CloseAll');



