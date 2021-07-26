function varargout = valuesfromstrings(allDoubleString, allIntString, ...
                                      allLogicalString, allFunctionString)
%valuesfromstrings	Convert an ensemble of strings to desired types.
%   For each element of input arrays, convert it from string to correct 
%   type. Return a list with all converted values.
%
%   Inputs
%   ------
%       allDoubleString - 1xl cell array of all values to convert to 
%   double.
%       allIntString - 1xm cell array of all values to convert to int.
%       allLogicalString - 1xn cell array of all values to convert to
%   logical.
%       allFunctionString - 1xp cell array of all values to convert to 
%   unction.
%
%   Output
%   ------
%       varargout - 1x(l+m+n+p) cell array of all values after
%   conversion, in the order they were provided in.
%
%   Notes
%   -----
%       Rely on calls to fromstring, which does not convert given value if
%   it is not indeed a string.
%       All parameters are mandatory but can be empy ({}).
%
%   Examples
%   --------
%       [a, b, c, d] = valuesfromstrings({"0.5", "1.5"}, {'1', '2'}, ...
%                                         {}, {})
%
%   See also fromstring.
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
nTotalValues = numel(allDoubleString) + numel(allIntString) + ...
               numel(allLogicalString) + numel(allFunctionString);
varargout = cell(1, nTotalValues);
valueNo = 1;
for doubleNo = 1:numel(allDoubleString)
    varargout{valueNo} = fromstring(allDoubleString{doubleNo}, "double");
    valueNo = valueNo + 1;
end
for intNo = 1:numel(allIntString)
    varargout{valueNo} = fromstring(allIntString{intNo}, "uint");
    valueNo = valueNo + 1;
end
for logicalNo = 1:numel(allLogicalString)
    varargout{valueNo} = fromstring(allLogicalString{logicalNo}, ...
                                    "logical");
    valueNo = valueNo + 1;
end
for functionNo = 1:numel(allFunctionString)
    varargout{valueNo} = fromstring(allFunctionString{functionNo}, ...
                                    "function");
    valueNo = valueNo + 1;
end