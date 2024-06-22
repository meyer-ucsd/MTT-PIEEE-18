% Florian Meyer, 2017, 2020

function [] = showResults(trueTracks, estimatedTracks, sensorPositions, measurements, cardinalityEstimated, mode)
numTrue = size(trueTracks,2);
numSteps = size(trueTracks,3);
numEstimated = size(estimatedTracks,2);
numSensors = size(measurements,2);

cardinalityTrue = permute(sum(~isnan(trueTracks(1,:,:)),2),[3,1,2]);

for step = 1:numSteps-1

    if(mode == 0)
        currentStep = numSteps-1;
    else
        currentStep = step;
    end

    figure(1);
    subplot(2,1,1)
    scatter(trueTracks(1,1,currentStep),trueTracks(2,1,currentStep),50,[0,0,0],'x','LineWidth', 1.5)
    hold on
    
    step
    for sensor = 1:numSensors
        sensor
        scatter(sensorPositions(1,sensor),sensorPositions(2,sensor),50,[0,0,1],'o','LineWidth', 1.5)

        currentMeasurements = measurements{currentStep,sensor};
        currentMeasurementsCartesian = [sensorPositions(1,sensor) + currentMeasurements(1,:).*sind(currentMeasurements(2,:)); sensorPositions(2,sensor) + currentMeasurements(1,:).*cosd(currentMeasurements(2,:))];

        scatter(currentMeasurementsCartesian(1,:),currentMeasurementsCartesian(2,:),40,[0,0,1],'.','LineWidth', 1)
    end

    for target = 1:numTrue
        currentTrack = permute(trueTracks(:,target,1:currentStep),[1,3,2]);
        scatter(currentTrack(1,end),currentTrack(2,end),50,[0,0,0],'x','LineWidth', 1.5)
        plot(currentTrack(1,:),currentTrack(2,:),'k');
    end

    for target = 1:numEstimated
        currentTrack = permute(estimatedTracks(:,target,1:currentStep),[1,3,2]);
        scatter(currentTrack(1,end),currentTrack(2,end),50,[1,0,0],'x','LineWidth', 1.5)
        plot(currentTrack(1,:),currentTrack(2,:),'r');
    end
    hold off

    axis ([-3000 3000 -3000 3000]);
    xlabel('x-coordinate [m]'), ylabel('y-coordinate [m]');
    pbaspect('manual')

    subplot(2,1,2)
    plot(1:currentStep, cardinalityTrue(1:currentStep),'k');
    xlabel('time step'), ylabel('cardinality');
    axis ([1 numSteps 0 10]);
    hold on
    plot(1:currentStep, cardinalityEstimated(1:currentStep),'r');
    hold off

    if(step == 1 && mode ~= 0)
        pause
    end

    if(mode == 0)
        break
    elseif(mode == 2)
        pause
    else
        pause(0.01)
    end
end

end