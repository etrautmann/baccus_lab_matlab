function  [ val cntr value ] = ReadParallel(dio)
% read current state of the digital input lines on LPTR1
% reads 11 lines: the first 8 as val (int8), 
% the last 3 as cntr (uint8)

    value = getvalue(dio);

% initial unpacking routine
%     value(2) = xor(1, value(2));        % flip the second bit
%     cntr = sum(value(9:11).*2.^(0:2));
%     val = typecast( uint8(sum(value(1:8).*2.^(0:7)) ),'int8');

% new unpacking routine, determined a month afterwards
    value(13) = xor(1, value(13));       % flip 13th bit
    cntr = sum(value(3:-1:1).*2.^(0:2));
    val = typecast( uint8(sum(value(4:8).*2.^(7:-1:3))+...
        value(11)+value(13)*2+value(12)*4 ),'int8');

    value = value';
    % troubleshooting
%     Size = max(size(valueBin));
%     valueHex = dec2hex(sum(value.*2.^(0:Size-1)));
%     valueDec = sum(value.*2.^(0:Size-1));

end
