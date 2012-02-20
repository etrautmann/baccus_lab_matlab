function [numSpikes] = countSpikes(dio, duration, varargin) 
% Counts the number of spikes over a certain length of time.
% Eric Trautmann, 2/8/12
% etrautmann@gmail.com

% if numvarargs > 2
% 	error('myfuns:somefun2Alt:TooManyInputs', ...
% 	    'requires at most 3 optional inputs');
% end

%unpack optional arguments binSize and WHICHRIG
% optargs = {.1, 1};	%binSize = .1s, IC rig is default
% optargs{1:numvarargs} = varargin;
% {binSize, WHICHRIG} = optargs;

binSize = .1;
WHICHRIG = 1;

numSpikes = 0;
nBins = duration/binSize;
for iBin = 1:nBins
	[dioValue, counterOut, exitFlag] = waitForCounterChange(dio, WHICHRIG);
	numSpikes = numSpikes + dioValue; 
end 


