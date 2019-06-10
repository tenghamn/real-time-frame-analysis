clc, clear, close;
addpath('../source/SensingRegions');

% Test initialisation of Sensing region
sr = Region();
expectedWidth = 1;
expectedHeight = 1;
expectedxPosition = 0;
expectedyPosition = 0;
assert(sr.width == expectedWidth)
assert(sr.height == expectedHeight)
assert(sr.xPosition == expectedxPosition)
assert(sr.yPosition == expectedyPosition)

% Test set width
sr = Region();
width = 10;
sr.width = width;
assert(sr.width==width);

% Test set height
sr = Region();
height = 20;
sr.height = height;
assert(sr.height==height);

% Test set xPosition
sr = Region();
xPosition = 10;
sr.xPosition = xPosition;
assert(sr.xPosition==xPosition);

% Test set yPosition
sr = Region();
yPosition = 10;
sr.yPosition = yPosition;
assert(sr.yPosition==yPosition);

% Test get channel coordinates
sr = Region();
channelCoordinates = sr.coordinates();
expectedCoordinates = [
    [-1, -1];
    [1, -1];
    [1, 1];
    [-1, 1]
];
assert(isequal(channelCoordinates,expectedCoordinates));

% Test get channels fill coordinates
sr = Region();
expected_x = [-1, 1, 1, -1, -1];
expected_y = [-1, -1, 1, 1, -1];
fillCoordinates = sr.fillCoordinates();
assert(isequal(fillCoordinates,[expected_x,expected_y]));

















