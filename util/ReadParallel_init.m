function dio = ReadParallel_init()
% initializes parallel port for reading

    dio = digitalio('parallel', 'LPT1');
    addline(dio,0:15, 'in');         % use wacky default mapping
    
    %{
    Could also assign these lines to different channels, using
    something like: hwlines(1).HwLine = 1;
    see Referencing Individual Hardware Lines 
    %}
end