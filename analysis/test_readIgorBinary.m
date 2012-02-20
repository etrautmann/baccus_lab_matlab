clc
clear all
pathname = './data/';
% files{1} = '020112_2.bin';
% files{1} = '020112_7.bin';
% files{1} = '020112_7.bin';

files{1} = '20120124T164942a.bin';

[data, info] = readIgorBinary(files,pathname);

% [data, info] = readIgorBinary();