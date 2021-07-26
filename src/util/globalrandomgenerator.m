function globalrandomgenerator(randomSeed, iJob, nJob)
%globalrandomgenerator  Initialize an independant random number generator.
%   For parallelization of a script, initialize a random number generator
%   for current thread/job, statistically independant from other
%   threads/jobs' one. This is achieved by using RandStream with given
%   values for 'NumStreams' and 'StreamIndices'. The random number
%   generator is not returned, it is set as global random number generator
%   for matlab session.
%
% 	Inputs
%   ------
%       randomSeed - Int. Used as seed for random number generator. 
%   Should be the same for all parallel threads/jobs.
%       iJob - Int. Index of current thread/job. Should be unique to each
%   thread/job.
%       nJob - Int. Number of parallel threads/jobs. Should be the same
%   for all parallel threads/jobs.
%
%   Prerequisite
%   ------------
%       iJob must be between 1 and nJob, included.
%
%   Notes
%   -----
%       All parameters support strings containing their value, in addition
%   to their aforementionned type.
%
%   Example
%   -------
%       globalrandomgenerator(1, 1, 10)
%
%   See also RandStream, RandStream.create, rng.
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

% Ensure correct inut type
[randomSeed, iJob, nJob] = valuesfromstrings({}, {randomSeed, iJob, ...
                                                  nJob}, {}, {});
% Create independant random number generator and set it as global..
randStr = RandStream.create('mlfg6331_64', 'NumStreams', nJob, ...
                            'Seed', randomSeed, 'StreamIndices', ...
                            iJob);
RandStream.setGlobalStream(randStr)