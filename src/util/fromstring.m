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
%
%   MicroVIP, Microscopy image simulation and analysis tool
%   Copyright (C) 2021  Ali Ahmad, Guillaume Vanel,
%   CREATIS, Universite Lyon 1, Insa de Lyon, Lyon, France.
%
%   This file is part of MicroVIP.
%   MicroVIP is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   any later version.
%
%   This program is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this program.  If not, see <https://www.gnu.org/licenses/>.
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