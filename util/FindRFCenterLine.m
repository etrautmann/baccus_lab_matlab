function [RFCenterLine] = FindRFCenterLine(dio, stimScreen, stimWin, whichAxis, WHICHRIG)
% Procedure described in supplemental materials in
% Bollinger and Gollisch, 2011 (Neuron)
% Eric Trautmann - etraut@stanford.edu
% 2/10/12

TIMEOUT = 1;    %1s timeout for DIO ports
DURATION = 1;
NUMPHASE2DRAWS = 15;
MAXPHASE1ITER = 30;           %maximum number of loops (probably can reduce)

switch whichAxis
    case 'X'
        midline = stimScreen.xSize/10;  %start midline at 10% distance across screen
    case 'Y'
        midline = stimScreen.ySize/10;
end

% Phase I - find Gross centerline of RF along selected axis
% =========================================================================
Ph1Deltas = [];
count = 0;
while (count < MAXPHASE1ITER)
    nSpikesSide1 = 0;
    nSpikesSide2 = 0;
    
    % Create stimulus windows
    switch whichAxis
        case 'X'
            box1 = [0; 0; midline; stimScreen.ySize];
            box2 = [midline; 0; stimScreen.xSize; stimScreen.ySize];
        case 'Y'
            box1 = [0; 0; stimScreen.xSize; midline];
            box2 = [0; midline; stimScreen.xSize; stimScreen.ySize];
    end
    
    [nSpikesSide1, nSpikesSide2] = flashBothSides(dio, stimScreen, stimWin, box1, box2, Duration, BINSIZE,WHICHRIG);
    Ph1Deltas(end+1) = nSpikesSide1 - nSpikesSide2;
    
    count = count+1;
    if (count == 1)         %determine which direction to shift
        if nSpikesSide1 > nSpikeSide2
            shift = -40;
        else
            shift = 40;
        end
    else if (count > 1)      %exit Phase I while loop if spike count decreases
            if (sign(Ph1Deltas(end)) ~= sign(Ph1Deltas(end-1)))
                break
            end
        end
        
        % shift the midline
        midline = midline + shift;
        
    end
end

% Phase II
% =========================================================================
midLineLog = [];
shiftLog = [];
phIIDeltas = [];
centersLog = [];
count2 = 0;
for i = 1:NUMPHASE2DRAWS    % default 15 random midline locations to interpolate from
    
    midLineLog(end+1) = midline;
    
    % Create stimulus windows
    switch whichAxis
        case 'X'
            box1 = [0; 0; midline; stimScreen.ySize];
            box2 = [midline; 0; stimScreen.xSize; stimScreen.ySize];
        case 'Y'
            box1 = [0; 0; stimScreen.xSize; midline];
            box2 = [0; midline; stimScreen.xSize; stimScreen.ySize];
    end
    
    [nSpikesSide1, nSpikesSide2] = flashBothSides(dio,stimScreen, stimWin, box1, box2, Duration, BINSIZE,WHICHRIG);
    phIIDeltas(end+1) = nSpikesSide1 - nSpikesSide2;
    
    %shift the midline towards side with more spikes by uniform random 1-20 pix
    shift = -sign(nSpikesSide1 - nSpikeSide2)*ceil(rand*20);
    midline = midline + shift;
    
    count2 = count2+1;
end

%solve for midline w/ line fit
%todo

%find midline centers between each iteration - eg: if midline on iteration
%#1 is 240 and on iteration #2 is 254, then center is at 247

iterationCenters = diff(midLineLog);
spikeCountDifferences = diff(phIIDeltas);

p = polyfit(iterationCenters,spikeCountDifferences,1);
RFCenterLine = polyval(p,0);

% for debug uncomment
% figure(10); clf;
% plot(iterationCenters,spikeCountDifferences,'bo-')
% hold on
% plot(iterationCenters,polyval(p,iterationCenters),'r-')
% legend('Difference in Spike Counts', 'Linear Fit')

end



function [nSpikesSide1, nSpikesSide2] = flashBothSides(dio,stimScreen, stimWin, box1, box2, DURATION, BINSIZE, WHICHRIG)
% function presents flashing box on one side of screen, default 1Hz flash rate white-black
% for six seconds.  Repeats for second side of screen.  return values
% are the number of spikes recorded during each presentation.

[~, ~, ~] = waitForCounterChange(dio, WHICHRIG);   %stall until new recording bin

%flash Side1 (left or top of screen)
for iFlash = 1:NUMFLASHES %default = 6
    %alternate between black and white flashes
    if mod(iFlash,2) == 0
        color = stimScreen.black;
    else
        color = stimScreen.white;
    end
    
    Screen('FillRect', stimWin, color, box1);
    Screen('Flip',stimWin);
    
    nSpikesSide1 = nSpikesSide1 + countSpikes(dio, DURATION, BINSIZE, WHICHRIG);
end

%clear screen
Screen('FillRect', stimWin, stimScreen.black)
Screen('Flip',stimWin);

%flash Side2 (right or bottom)
[~, ~, ~] = waitForCounterChange(dio, WHICHRIG, TIMEOUT);

for iFlash = 1:NUMFLASHES %default = 6
    %alternate between black and white flashes
    if mod(iFlash,2) == 0
        color = stimScreen.black;
    else
        color = stimScreen.white;
    end
    
    Screen('FillRect', stimWin, color, box2);
    Screen('Flip',stimWin);
    
    nSpikesSide2 = nSpikesSide2 + countSpikes(dio, DURATION, BINSIZE, WHICHRIG);
end

end
