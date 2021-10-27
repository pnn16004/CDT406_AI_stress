function [newBboxPolygon, ROIbox,ROI] = adjPolygon(bboxPolygon,videoFrame)
% newly created function 29/09/2016
% this function forces the bbox to stay inside the image frame; the problems
% happens when any of the box corner excedes its value than the frame size
% newBboxPolygon is the bbox after the corner adjusted
% ROIbox is the box around ROI
% ROI is the the ROI facial part

p11 = bboxPolygon(1,1);
p12 = bboxPolygon(1,2);
p21 = bboxPolygon(1,3);
p22 = bboxPolygon(1,4);
p31 = bboxPolygon(1,5);
p32 = bboxPolygon(1,6);
p41 = bboxPolygon(1,7);
p42 = bboxPolygon(1,8);
%point p1 top-leftmost corner
if p11 <1 && p12 <1
    p11 =1;p12 =1;
end

% poit p1 left wall
if p11 <1 && p12 >1
    p11 =1;
end
% point p1 top wall
if p11 >1 && p12 <1
    p12 =1;
end
%point p2 top-rightmost corner
if p21 >size(videoFrame,2) && p22 <1
    p21 =size(videoFrame,2);p22 =1;
end
%p2 top wall
if p21 >1 && p22 <1
    p22 =1;
end
% p2 right wall
if p21 >size(videoFrame,2) && p22 >1
    p21 =size(videoFrame,2);
end

%point p3 down-rightmost corner
if p31 >size(videoFrame,2) && p32 >size(videoFrame,1)
    p31 =size(videoFrame,2);p32 =size(videoFrame,1);
end
%p3 right wall
if p31 >size(videoFrame,2) && p32 >1
    p31 =size(videoFrame,2);
end
% p3 down wall
if p31 >1 && p32 >size(videoFrame,1)
    p32 =size(videoFrame,1);
end

%point p4 down-rightmost corner
if p41 <1 && p42 >size(videoFrame,1)
    p41 =1;p42 =size(videoFrame,1);
end
%p4 left wall
if p41 <1 && p42 >1
    p41 =1;
end
% p4 down wall
if p41 >1 && p42 >size(videoFrame,1)
    p42 =size(videoFrame,1);
end

newBboxPolygon = [p11 p12 p21 p22 p31 p32 p41 p42];
x = p11;
y = p12;
w = p31-p11;
h = p42-p12;

x1=floor(x+(0.15*w));
y1=floor(y+(0.15*h));
w1=floor(w*0.6);
h1=floor(h*0.8);

ROIbox= [x1, y1, x1+w1, y1, x1+w1, y1+h1, x1, y1+h1];
ROI = videoFrame(y1:y1+h1,x1:x1+w1,:);

end