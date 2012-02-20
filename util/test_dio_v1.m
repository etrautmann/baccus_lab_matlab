function [ exception trajectory ] = test_dio_v1(Duration)
% Test reading from the parallel port
% right now only works on IC rig

try
    dio = ReadParallel_init();
    Counter = 0;
    
    for i=1:Duration
        % read keyboard and DAQ/parallel port inputs
        [ Exit, shift, Counter ] = TrackObj_readInputs(dio, Counter, 1);
        if ( Exit )
            break
            disp('dio error')
        end
        disp(shift)
        Counter = Counter + 1;
    end

catch exception

end