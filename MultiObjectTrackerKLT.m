% MultiObjectTrackerKLT implements tracking multiple objects using the
% Kanade-Lucas-Tomasi (KLT) algorithm.
% tracker = MultiObjectTrackerKLT() creates the multiple object tracker.
%
% MultiObjectTrackerKLT properties:
%   PointTracker - a vision.PointTracker object
%   Bboxes       - object bounding boxes
%   BoxIds       - ids associated with each bounding box
%   Points       - tracked points from all objects
%   PointIds     - ids associated with each point
%   NextId       - the next object will have this id
%   BoxScores    - and indicator of whether or not an object is lost
%
% MultiObjectTrackerKLT methods:
%   addDetections - add detected bounding boxes
%   track         - track the objects

% Copyright 2013-2014 The MathWorks, Inc 

classdef MultiObjectTrackerKLT < handle
    properties
        % PointTracker A vision.PointTracker object
        PointTracker; 
        
        % Bboxes M-by-4 matrix of [x y w h] object bounding boxes
        Bboxes = [];
        
        % Bboxes M-by-4 matrix of object ROI boxes
        ROIBboxes =[];
        
        % BoxIds M-by-1 array containing ids associated with each bounding box
        BoxIds = [];
        
        % Points M-by-2 matrix containing tracked points from all objects
        Points = [];
        
        % PointIds M-by-1 array containing object id associated with each 
        %   point. This array keeps track of which point belongs to which object.
        PointIds = [];
        
        %for multiple mean of lab color for each face each channel
        MultLabAvg = [];
        
        %for related HR       
        HR = [];
        
        IBI = [];

        % NextId The next new object will have this id.
        NextId = 1;
        
        % BoxScores M-by-1 array. Low box score means that we probably lost the object.
        BoxScores = [];
    end
    
    methods
        %------------------------------------------------------------------
        function this = MultiObjectTrackerKLT()
        % Constructor
            this.PointTracker = ...
                vision.PointTracker('MaxBidirectionalError', 2);
        end
        
        %------------------------------------------------------------------
        function addDetections(this, I, bboxes)
        % addDetections Add detected bounding boxes.
        % addDetections(tracker, I, bboxes) adds detected bounding boxes.
        % tracker is the MultiObjectTrackerKLT object, I is the current
        % frame, and bboxes is an M-by-4 array of [x y w h] bounding boxes.
        % This method determines whether a detection belongs to an existing
        % object, or whether it is a brand new object.
            for i = 1:size(bboxes, 1)
                % Determine if the detection belongs to one of the existing
                % objects.
                boxIdx = this.findMatchingBox(bboxes(i, :));
                
                
                
                if isempty(boxIdx)
                    % This is a brand new object.
                    this.Bboxes = [this.Bboxes; bboxes(i, :)];
                    points = detectMinEigenFeatures(I, 'ROI', bboxes(i, :));
                    points = points.Location;
                    
                    this.ROIBboxes= [this.ROIBboxes; getROIBoundingBox(points)];
                    
                    this.BoxIds(end+1) = this.NextId;
                    idx = ones(size(points, 1), 1) * this.NextId;
                    this.PointIds = [this.PointIds; idx];
                    this.NextId = this.NextId + 1;
                    this.Points = [this.Points; points];
                    this.BoxScores(end+1) = 1;
                    this.HR(end+1) = 0;
                    this.IBI(end+1) = 0;
                    
                else % The object already exists.
                    
                    boxHR = this.HR(find(this.BoxIds == boxIdx));
                    boxIBI = this.IBI(find(this.BoxIds == boxIdx));
                    
                    
                    % Delete the matched box
                    currentBoxScore = this.deleteBox(boxIdx);
                    
                    % Replace with new box
                    this.Bboxes = [this.Bboxes; bboxes(i, :)];
                    
                    % Re-detect the points. This is how we replace the
                    % points, which invariably get lost as we track.
                    points = detectMinEigenFeatures(I, 'ROI', bboxes(i, :));
                    points = points.Location;
                    this.ROIBboxes= [this.ROIBboxes; getROIBoundingBox(points)];
                    this.BoxIds(end+1) = boxIdx;                    
                    this.HR(end+1) = boxHR;
                    this.IBI(end+1) = boxIBI;
                    
                    idx = ones(size(points, 1), 1) * boxIdx;
                    this.PointIds = [this.PointIds; idx];
                    this.Points = [this.Points; points];                    
                    this.BoxScores(end+1) = currentBoxScore + 1;
                end
            end
            
            % Determine which objects are no longer tracked.
            minBoxScore = -2;
            this.BoxScores(this.BoxScores < 3) = ...
                this.BoxScores(this.BoxScores < 3) - 0.5;
            boxesToRemoveIds = this.BoxIds(this.BoxScores < minBoxScore);
            while ~isempty(boxesToRemoveIds)
                this.deleteBox(boxesToRemoveIds(1));
                boxesToRemoveIds = this.BoxIds(this.BoxScores < minBoxScore);
            end
            
            % Update the point tracker.
            if this.PointTracker.isLocked()
                this.PointTracker.setPoints(this.Points);
            else
                this.PointTracker.initialize(this.Points, I);
            end
        end
                
        %------------------------------------------------------------------
        function track(this, I)
        % TRACK Track the objects.
        % TRACK(tracker, I) tracks the objects into frame I. tracker is the
        % MultiObjectTrackerKLT object, I is the current video frame. This
        % method updates the points and the object bounding boxes.
            [newPoints, isFound] = this.PointTracker.step(I);
            this.Points = newPoints(isFound, :);
            this.PointIds = this.PointIds(isFound);
            generateNewBoxes(this);
            if ~isempty(this.Points)
                this.PointTracker.setPoints(this.Points);
            end
        end
        
        function addLabAvg(this,k,frameNumber, LabAvg)
            this.MultLabAvg(k:k+2,frameNumber) = LabAvg;            
        end
        
        function addHR(this, HR, index)
            this.HR(index) = HR;            
        end
        
         function addIBI(this, IBI, index)
            this.IBI(index) = IBI;            
        end
    end
    
   
    
    methods(Access=private)        
        %------------------------------------------------------------------
        function boxIdx = findMatchingBox(this, box)
        % Determine which tracked object (if any) the new detection belongs to. 
            boxIdx = [];
            for i = 1:size(this.Bboxes, 1)
                area = rectint(this.Bboxes(i,:), box);                
                if area > 0.2 * this.Bboxes(i, 3) * this.Bboxes(i, 4) 
                    boxIdx = this.BoxIds(i);
                    return;
                end
            end           
        end
        
        %------------------------------------------------------------------
        function currentScore = deleteBox(this, boxIdx)            
        % Delete object.
            this.Bboxes(this.BoxIds == boxIdx, :) = [];
            this.ROIBboxes(this.BoxIds == boxIdx, :) = [];          
            this.Points(this.PointIds == boxIdx, :) = [];
            this.PointIds(this.PointIds == boxIdx) = [];
            currentScore = this.BoxScores(this.BoxIds == boxIdx);
            this.BoxScores(this.BoxIds == boxIdx) = [];
            this.HR(this.BoxIds == boxIdx) = [];
            this.IBI(this.BoxIds == boxIdx) = [];
            this.BoxIds(this.BoxIds == boxIdx) = []; 
           
            
        end
        
        %------------------------------------------------------------------
        function generateNewBoxes(this)  
        % Get bounding boxes for each object from tracked points.
            oldBoxIds = this.BoxIds;
            oldScores = this.BoxScores;
            oldHR = this.HR;
            oldIBI = this.IBI;
            uniqueIds = unique(this.PointIds);
            this.BoxIds = uniqueIds';
            numBoxes = numel(this.BoxIds);
            this.Bboxes = zeros(numBoxes, 4);
            this.ROIBboxes = zeros(numBoxes, 4);
            this.BoxScores = zeros(numBoxes, 1);
            this.HR = zeros(size(this.BoxIds));
            this.IBI = zeros(size(this.BoxIds));
            for i = 1:numBoxes
                points = this.Points(this.PointIds == this.BoxIds(i), :);
                newBox = getBoundingBox(points);
                newROIBox = getROIBoundingBox(points);
                this.Bboxes(i, :) = newBox;
                this.ROIBboxes(i, :) = newROIBox;
                this.BoxScores(i) = oldScores(oldBoxIds == this.BoxIds(i));
                this.HR(i) = oldHR(oldBoxIds == this.BoxIds(i));
                this.IBI(i) = oldIBI(oldBoxIds == this.BoxIds(i));
                
            end
        end 
    end
end

%--------------------------------------------------------------------------
function bbox = getBoundingBox(points)
x1 = min(points(:, 1));
y1 = min(points(:, 2));
x2 = max(points(:, 1));
y2 = max(points(:, 2));
bbox = [x1 y1 x2 - x1 y2 - y1];
end

function ROIbbox = getROIBoundingBox(points)
x1 = min(points(:, 1));
y1 = min(points(:, 2));
x2 = max(points(:, 1));
y2 = max(points(:, 2));
w = x2 - x1;
h = y2 - y1;
ROIbbox = [floor(x1+0.2*w) floor(y1+0.1*h) floor(w*0.6) floor(h*0.8)];
%ROI = videoFrame(y1:y1+h1,x1:x1+w1,:);
end
