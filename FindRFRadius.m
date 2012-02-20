function [RFRadius, nSpikesLog] = FindRFRadius(dio, RF, stimScreen, stimWin, WHICHRIG)
    %Procedure to find the receptive field size after finding the x and y
    %midline locations.  Procedure described in supplemental materials in
    %Bollinger and Gollisch, 2011 (Neuron)
    % Eric Trautmann - etraut@stanford.edu
    % 2/10/12

    NUMFLASHES = 6;
    DURATION = 1;       %1s for each flash
    
    RFSizes = linspace(10,200,20);

    nSpikesLog = nan(zeros(1,20));
    for iSizes = 1:20
        
        thisCircle = [RF.xCenter - RFSizes(iSizes)/2; RF.yCenter-RfSizes(iSizes)/2; RF.xCenter + RFSizes(iSizes)/2; RF.yCenter + RFSizes(iSizes)/2 ];
        
        nSpikes = 0;
        for iFlash = 1:NUMFLASHES
            if mod(iFlash,2) == 0
                color = stimScreen.black;
            else
                color = stimScreen.white;
            end
            
            Screen('FillOval', stimWin, color, thisCircle);
            Screen('Flip',stimWin);
            nSpikes = nSpikes + countSpikes(dio, DURATION, .1, WHICHRIG);   
        end
        
        nSpikesLog(iSizes) = nSpikes;
    end
    
    [~,idx] = max(nSpikesLog);
    RFRadius = RFSizes(idx);
end