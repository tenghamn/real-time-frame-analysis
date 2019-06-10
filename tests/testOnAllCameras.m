addpath('../source/Cameras')

%camera = CameraSimulator();
%camera = ZylaCamera();
%camera = iXonCamera();
camera = NewtonCamera();

% Test initial sizes, camera image size should be same as sensor size
assert(camera.imageWidth == camera.sensorWidth)
assert(camera.imageHeight == camera.sensorHeight)

% Test sensor cooridnates
expectedCoordinates = [
    [1,1];
    [1+camera.sensorWidth,1];
    [1+camera.sensorWidth,1+camera.sensorHeight];
    [1,1+camera.sensorHeight]
    ];
assert(isequal(expectedCoordinates,camera.sensorCoordinates))

% Change binning aoi
if isequal(camera.NAME,'Zyla') | isequal(camera.NAME,'Simulator')
    camera.verticalBinning = 2;
    camera.horisontalBinning = 3;
else
    verticalBinning = 2;
    horisontalBinning = 4;
    camera.setAreaOfInterest(verticalBinning,horisontalBinning,camera.imageWidth,camera.imageHeight,camera.imageLeftPosition,camera.imageTopPosition);
end

% Image size and sensor size should still be the same
assert(camera.imageWidth == camera.sensorWidth)
assert(camera.imageHeight == camera.sensorHeight)

% Test sensor coordinates
expectedCoordinates = [
    [1,1];
    [1+camera.sensorWidth,1];
    [1+camera.sensorWidth,1+camera.sensorHeight];
    [1,1+camera.sensorHeight]
    ];
assert(isequal(expectedCoordinates,camera.sensorCoordinates))

% Change back to 1 binning
if isequal(camera.NAME,'Zyla') | isequal(camera.NAME,'Simulator')
    camera.verticalBinning = 1;
    camera.horisontalBinning = 1;
else
    verticalBinning = 1;
    horisontalBinning = 1;
    camera.setAreaOfInterest(verticalBinning,horisontalBinning,camera.imageWidth,camera.imageHeight,camera.imageLeftPosition,camera.imageTopPosition);
end

% Image size and sensor size should still be the same
assert(camera.imageWidth == camera.sensorWidth)
assert(camera.imageHeight == camera.sensorHeight)

% Test sensor coordinates
expectedCoordinates = [
    [1,1];
    [1+camera.sensorWidth,1];
    [1+camera.sensorWidth,1+camera.sensorHeight];
    [1,1+camera.sensorHeight]
    ];
assert(isequal(expectedCoordinates,camera.sensorCoordinates))

% Change area of interest
width = 10;
height = 20;
leftPosition = 10;
topPosition = 10;
if isequal(camera.NAME,'Zyla') | isequal(camera.NAME,'Simulator')
    camera.setAreaOfInterest(width,height,leftPosition,topPosition);
else
    verticalBinning = 1;
    horisontalBinning = 1;
    camera.setAreaOfInterest(verticalBinning,horisontalBinning,width,height,leftPosition,topPosition);
end

% Test image sizes
assert(width == camera.imageWidth);
assert(height == camera.imageHeight);
assert(leftPosition == camera.imageLeftPosition);
assert(topPosition == camera.imageTopPosition);

% Test sensor coordinates, should not change from pervious test
assert(isequal(expectedCoordinates,camera.sensorCoordinates))

% Change binning
if isequal(camera.NAME,'Zyla') | isequal(camera.NAME,'Simulator')
    camera.verticalBinning = 4;
    camera.horisontalBinning = 2;
    
    % Test image width
    expectedWidth = width/2;
    assert(expectedWidth == camera.imageWidth);
    
    % Test left position
    expectedLeftPosition = leftPosition/2;
    assert(expectedLeftPosition == camera.imageLeftPosition);
    
    % Test image height
    expectedHeight = floor(height/3);
    assert(expectedHeight == camera.imageHeight);
    
    % Test top position
    expectedTopPosition = floor(topPosition/3);
    assert(expectedTopPosition == camera.imageTopPosition);

end




disp('Done, all tests passed')

