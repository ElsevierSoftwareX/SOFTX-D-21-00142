function toValue = fromstring(fromString, toType)
%fromstring     Convert string or char vector to desired type.
%   If input is a string or character vector, return the value interpreted
%   as a number (or other given type).
%
%   Inputs
%   ------
%       fromString - Value to convert. Will be converted only if it is a 
%   string or character vector.
%       toType - String. Either "double", "uint", "logical" or "function"
%   depending on what type fromString should be converted to. Defaults to
%   "double".
%
%   Output
%   ------
%       toValue - Value after conversion.
%
%   Examples
%   --------
%       myInt = fromstring('10', "int")
%       myFunction = fromstring("@() 10*rand(1,1)")
%       myDouble = fromString("1.5")
%
%   See also valuesfromstrings.
if isstring(fromString) || ischar(fromString)
    if ~exist('toType', 'var')
        toType = "double";
    end
    if toType == "function"
        toValue = str2func(fromString);
    else
        intermediateValue = str2num(fromString);
        switch(toType)
            case "double"
                toValue = double(intermediateValue);
            case "uint"
                toValue = uint8(intermediateValue);
            case "logical"
                toValue = logical(intermediateValue);
            otherwise
                error("Unrecognized type: %s\ntoType should be " + ...
                      "one of 'double', 'uint', 'logical' or " + ...
                      "'function'", toType)
        end
    end
else
    % Value is not a string, no conversion
    toValue = fromString;
end