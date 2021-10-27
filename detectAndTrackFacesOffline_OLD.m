function [] = detectAndTrackFacesOffline(inputFilePath)
% detectAndTrackFaces
% Automatically detects and tracks multiple faces in a webcam-acquired
% video stream.
%
% Copyright 2013-2014 The MathWorks, Inc

% Instantiate video device, face detector, and KLT object tracker
% videoFileReader = webcam;
videoFileReader = vision.VideoFileReader(inputFilePath);

% nframes = videoFileReader.NumberOfFrames;
% duration = floor(videoFileReader.Duration);
% framePermeasurements = floor((nframes/ (duration*4)));


faceDetector = vision.CascadeObjectDetector(); % Finds faces by default
tracker = MultiObjectTrackerKLT;

% Get a frame for frame-size information
frame = step(videoFileReader);

% Create a video player instance
videoPlayer = vision.DeployableVideoPlayer; %('Position',[100 100 [size(frame, 2), size(frame, 1)]+30]);

% Iterate until we have successfully detected a face
bboxes = [];
while isempty(bboxes)
    framergb = step(videoFileReader);
    frame = rgb2gray(framergb);
    bboxes = faceDetector.step(frame);
end
tracker.addDetections(frame, bboxes);

% And loop until the player is closed
frameNumber = 0;
disp('Press Ctrl-C to exit...');
while ~isDone(videoFileReader)
    
    framergb = step(videoFileReader);
    frame = rgb2gray(framergb);
    
    if mod(frameNumber, 10) == 0
        
        % (Re)detect faces.
        %
        % NOTE: face detection is more expensive than imresize; we can
        % speed up the implementation by reacquiring faces using a
        % downsampled frame:
        bboxes = faceDetector.step(frame);
        %bboxes = 2 * faceDetector.step(imresize(frame, 0.5));
        if ~isempty(bboxes)
            tracker.addDetections(frame, bboxes);
            % allHR = zeros(size(tracker.BoxIds));
            % allIBI = zeros(size(tracker.BoxIds));
        end
    else
        % Track faces
        tracker.track(frame);
    end
    
    for i=1:size(tracker.ROIBboxes,1)
        box = tracker.ROIBboxes(i,:);
        fImg = framergb(box(2):box(2)+box(4), box(1):box(1)+box(3), :);
        LabAvg = zeros(3,1);
        
        LabImg = rgbImg2LabImg(fImg);% transformation into Lab color space
        for ch = 1:3
            labCh = LabImg (:,:,ch);
            LabAvg(ch) = mean(labCh(:));
        end
        
        id = tracker.BoxIds(i);
        k = 1 + 3 * (id - 1);
        tracker.addLabAvg(k,frameNumber+1, LabAvg);
        
        
        infoAmount = nnz(tracker.MultLabAvg(k,:));
        if ((infoAmount >=100) && mod(frameNumber,10)==0)
            % LabAvg = tracker.MultLabAvg(k+1:k+2,:);
            all_ch = tracker.MultLabAvg(k+1:k+2,:);
            non_zero = find(all_ch(1, :));
            colorCh = all_ch(:, non_zero(1):end);
            [HR, IBI] = HRibi_fft_NEW(colorCh,infoAmount);
            % allHR(i) = HR;
            % allIBI(i) = IBI;
            tracker.addHR(HR,i);
            tracker.addIBI(IBI,i);
            
        end
        
    end
    
    %      for i=1:size(tracker.ROIBboxes,1)
    %          id = tracker.BoxIds(i);
    %          k = 1 + 3 * (id - 1);
    %          infoAmount = nnz(this.MultLabAvg(k,:));
    %          if (infoAmount >=100)
    %             % LabAvg = tracker.MultLabAvg(k+1:k+2,:);
    %              colorCh = tracker.MultLabAvg(k+1:k+2,:);
    %              [HR1, IBI1] = HRibi_fft(colorCh,infoAmount);
    %          end
    %      end
    label_str=[];
    if (~isempty(tracker.HR) && ~isempty(tracker.BoxIds) )
        for i = 1:size(tracker.BoxIds,2)
            label_str{i} = sprintf('id: %d HR: %0.2f  IBI: %0.1f', tracker.BoxIds(i), tracker.HR(i), tracker.IBI(i));
        end
    end
    
    if (~isempty(tracker.Bboxes))
        % Display bounding boxes and tracked points.
        displayFrame = insertObjectAnnotation(framergb, 'rectangle',...
            tracker.Bboxes, label_str);
        % displayFrame = insertMarker(displayFrame, tracker.Points);
        % displayFrame = insertMarker(displayFrame, 'rectangle',...
        %    tracker.ROIBboxes);
        displayFrame = insertShape(displayFrame, 'Rectangle', tracker.ROIBboxes, 'Color','green');
        videoPlayer.step(displayFrame);
    else
        videoPlayer.step(framergb);
    end
    frameNumber = frameNumber + 1;
end

%filename = 'HRIBI.csv';
%csvwrite(filename,RTPP);

% Clean up
release(videoPlayer);