function [pointCoordinate] = pointsoncurve(curve, distanceDistribution)
    %pointsoncurve  Place points along a curve with a distance distibution.
    %   Generate a point cloud with points following given curve and their
    %   distances along this curve following given distribution.
    %   
    %   Inputs
    %   ------
    %       curve - nx3 double matrix of 3D coordinates describing the
    %   curve (arbitrary unit).
    %       distanceDistribution - Function handle that outputs a distance
    %   along the curve between two successive points. For instance,
    %   "@() 50*rand(1,1)" will produce inter-points distances following a
    %   uniform distribution from 0 to 50 (arbitrary unit).
    %
    %   Output
    %   ------
    %       pointCoordinate - nx3 double matrix of produced points 3D
    %   coordinates (arbitrary unit).
    %
    %   Example
    %   -------
    %       pointCloud = pointsoncurve(eye(3), @() rand()) generate points
    %   along a 3D 'V' shape with distances following a random distribution
    %   from 0 to 1.
    
    %% License information
    %   MicroVIP, Microscopy image simulation and analysis tool
    %   Copyright (C) 2021  Ali Ahmad, Guillaume Vanel,
    %   CREATIS, Universite Lyon 1, Insa de Lyon, Lyon, France.
    %
    %   This file is part of MicroVIP.
    %   MicroVIP is free software: you can redistribute it and/or modify
    %   it under the terms of the GNU General Public License as published
    %   by the Free Software Foundation, either version 3 of the License,
    %   or any later version.
    %
    %   This program is distributed in the hope that it will be useful,
    %   but WITHOUT ANY WARRANTY; without even the implied warranty of
    %   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %   GNU General Public License for more details.
    %
    %   You should have received a copy of the GNU General Public License
    %   <https://www.gnu.org/licenses/>.

    % This code is based on following work, modified so that points are not
    % equally spaced but randomly spaced following given input
    % distribution. This means the number of points is not predetermined
    % anymore.
    %
    % Yo Fukushima (2021). curvspace (https://www.mathworks.com/matlabcentral/fileexchange/7233-curvspace),
    % MATLAB Central File Exchange. Retrieved March 8, 2021.
    %
    % Copyright (c) 2016, Yo Fukushima
    % All rights reserved.
    % Redistribution and use in source and binary forms, with or without
    % modification, are permitted provided that the following conditions
    % are met:
    % 
    %   * Redistributions of source code must retain the above copyright
    % notice, this list of conditions and the following disclaimer.
    %   * Redistributions in binary form must reproduce the above copyright
    % notice, this list of conditions and the following disclaimer in the
    % documentation and/or other materials provided with the distribution
    % THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    % AS IS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
    % LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
    % A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
    % OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    % SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
    % LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
    % DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
    % THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
    % (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
    % OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

    %% Initialization    
    nInCurve = size(curve, 1); % Number of points in curve.
    if nInCurve < 2
        error("Invalid curve: %s\n Curve should contain at least " + ...
              "two points.", mat2str(curve))
    end
    % Total distance along the curve
    distancetoEnd = sum(distancebetween(curve(1:end-1, :), curve(2:end, :)));
    previousPoint = curve(1, :);
    nPoint = 0; % Number of points generated
    iEndOfSegment = 2; % Index of closest point in curve after currentPoint
    % Distance to next generated point
    distanceToNext = distanceDistribution();
    % Preallocate output. As it is of unknown size, Preallocate to an
    % estimated maximum, which is the number of points obtained if all
    % distances were as small as the first quartile of distribution.
    distanceSample = arrayfun(@(x) distanceDistribution(), zeros(10000,1));
    distanceQuartile = quantile(distanceSample, 0.25);
    clear distanceSample
    estimatedMax = ceil(distancetoEnd / distanceQuartile);
    pointCoordinate = zeros(estimatedMax, 3);
    %% Generation
    while (distancetoEnd > distanceToNext) % Stop when curve end is reached
        endOfSegment = curve(iEndOfSegment, :);
        distanceToEndOfSegment = distancebetween(previousPoint, endOfSegment);
        while distanceToEndOfSegment < distanceToNext
            % Next point is firther away from previous point than the end
            % of segment, we need to jump to next segment.
            previousPoint = endOfSegment;
            iEndOfSegment = iEndOfSegment + 1;
            endOfSegment = curve(iEndOfSegment, :);
            % Update distances
            distanceToNext = distanceToNext - distanceToEndOfSegment;
            distancetoEnd = distancetoEnd - distanceToEndOfSegment;
            distanceToEndOfSegment = distancebetween(previousPoint, ...
                                              endOfSegment);
        end
       % Generate next point between previous one and end of segment.
       nextPoint = pointBetween(previousPoint, endOfSegment, ...
                                distanceToNext);
       previousPoint = nextPoint;
       % Add to the output points
       nPoint = nPoint + 1;
       if nPoint > size(pointCoordinate, 1)
           % In case we exceed preallocated space
           pointCoordinate = [pointCoordinate; zeros(estimatedMax, 3)];
       end
       pointCoordinate(nPoint, :) = nextPoint;
       % Update distances
       distancetoEnd = distancetoEnd - distanceToNext;
       distanceToNext = distanceDistribution();
    end
    % Shrink output matrix to correct for preallocation overestimation
    pointCoordinate = pointCoordinate(1:nPoint, :);
end

function euclidianDistance = distancebetween(x1, x2)
    %distancebetween    Compute euclidian distance between two points.
    %   Compute euclidian distance between two points x1 and x2, or
    %   element-wise distances between points of two matrices of same size.
    %   Points can be 2D or 3D vectors of coordinates.
    %
    %   Inputs
    %   ------
    %       x1, x2 - nxm matrices of m-dimensional point coordinates. n
    %   can be 1, in which case distance between the two points is
    %   computed, or greater in which case a distance is computed for the
    %   pair of points of each row.
    %
    %   Output
    %   ------
    %       euclidianDistance - double or nx1 double vector containing
    %   distance value(s) computed between x1 and x2. n is the number of
    %   rows of x1 and x2.
    %
    %   Prerequisites
    %   -------------
    %       x1 and x2 must have same size.
    %
    %   Example
    %   -------
    %   myDistance = distancebetween([1, 1, 1], [1, 3, 1])
    %   myDistance = distancebetween(eye(3), zeros(3))
    if size(x1) ~= size(x2)
        error("Point matrices must have same size, but their sizes " + ...
              "are %s and %s.", mat2str(size(x1)), mat2str(size(x2)))
    end
    euclidianDistance = 0;
    for dimensionNo = 1:size(x1, 2)
        euclidianDistance = euclidianDistance + ...
                            ((x1(:, dimensionNo)-x2(:, dimensionNo)) .^ 2);
    end
    euclidianDistance = sqrt(euclidianDistance);
end

function coordinate = pointBetween(x1, x2, distanceFromX1)
    %pointBetween   Compute coordinates of a point between x1 and x2.
    %   Compute coordinates of the point on segment [x1, x2] at a distance
    %   distanceFromX1 from x1.
    %
    %   Inputs
    %   ------
    %       x1, x2 - 1xn double vector of n dimensional coordinates of
    %   edges of the segment on which to generate a new point.
    %       distanceFromX1 - numeric. Euclidian distance between x1 and the
    %   generated point.
    %
    %   Output
    %   ------
    %       coordinate - 1xn double vector of computed n dimensional
    %   coordinates. n is the kength of x1 and x2.
    %
    %   Prerequisites
    %   -------------
    %       x1 and x2 must have the same size.
    %
    %   Example
    %   -------
    %       middle = pointBetween([0, 0, 0], [0, 1, 0], 0.5)
    if ~all([size(x1, 1), size(x2, 1)] == 1)
        error("Point coordinates must be 1xn vectors, but their " + ...
              "sizes are %s and %s.", mat2str(size(x1)), mat2str(size(x2)))
    end
    if size(x1) ~= size(x2)
        error("Point coordinates must have same size, but their " + ...
              "sizes are %s and %s.", mat2str(size(x1)), mat2str(size(x2)))
    end
    direction = x2 - x1;
    direction = direction ./ norm(direction);
    coordinate = (distanceFromX1 * direction) + x1;
end