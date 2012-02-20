function [dioValue, counterOut, exitFlag] = waitForCounterChange(dio, WHICHRIG, timeOut)
%WAITFORCOUNTERCHANGE Samples the digital and returns only when counter
%updates, indicated new data on DIO lines 
%   Eric Trautmann - etrautmann@gmail.com
%   2/7/12

    exitFlag = 'success';
    if nargin < 3
        timeOut = 10; %timeout length in seconds
    end

    if dio~=0 && WHICHRIG>0 && WHICHRIG<3                % only if on the laser or IC rig
        [dioValue, counter]= ReadParallel(dio);       % for intracellular rig
        counterNew = counter;

        tic        %start timer
        while (counterNew == counter)          %loop until counter updates
            % Sample digital lines
            if WHICHRIG==1
                [dioValue, counterNew] = ReadParallel(dio);       % for intracellular rig
            elseif WHICHRIG==2
                [dioValue, counterNew, ~] = ReadDigitalIn(dio);             % for laser rig
            end

            % if counter has changed, update value of shift
            if counterNew ~= counter        % only pass value when changed!
                dioValue = cast(dioValue, 'double');
            end
            
            %exit if timeout reached
            timeTaken = toc;    %update timer
            if toc > timeOut
                break
                exitFlag = 'timeout'
            end
            
        end
        counterOut = counterNew;
    end

end

