%loadphidget21.m - Loads the phidget21 library, paying attention to OS,
%suppressing warnings.
function loadphidget21

if not(libisloaded('phidget21'))
    warning off MATLAB:loadlibrary:TypeNotFound
    warning off MATLAB:loadlibrary:TypeNotFoundForStructure
    switch computer
        case 'PCWIN'
            [notfound,warnings]=loadlibrary('phidget21', 'phidget21Matlab_Windows_x86.h');
        case 'PCWIN64'
            [notfound,warnings]=loadlibrary('phidget21', 'phidget21Matlab_Windows_x64.h');
        case 'MAC'
        case 'MACI'
        case 'MACI64'
            [notfound,warnings]=loadlibrary('/Library/frameworks/Phidget21.framework/Versions/Current/Phidget21', 'phidget21matlab_unix.h', 'alias', 'phidget21');
        case 'GLNX86'
        case 'GLNXA64'
            [notfound,warnings]=loadlibrary('/usr/lib/libphidget21.so', 'phidget21matlab_unix.h', 'alias', 'phidget21');
    end
end
 