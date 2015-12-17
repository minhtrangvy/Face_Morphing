%% Pick corresponding points between the two images
input_dir = ['/Users/minhtrangvy/Documents/MATLAB/Computational_Photography/Face_Morphing/faces/'];
image1 = imread([input_dir '9.jpg']);
image2 = imread([input_dir '10.jpg']);
image1(1498,:,1) = zeros(1,1081);
image1(1498,:,2) = zeros(1,1081);
image1(1498,:,3) = zeros(1,1081);
image2(:,1080,1) = zeros(1498,1);
image2(:,1080,2) = zeros(1498,1);
image2(:,1080,3) = zeros(1498,1);
image2(:,1081,1) = zeros(1498,1);
image2(:,1081,2) = zeros(1498,1);
image2(:,1081,3) = zeros(1498,1);
% cpselect(image1,image2)
load('corr_points_9_10')

%% Compute Delaunay triangulation of the midway shape
points1 = points9;
points2 = points10;
midway_shape = (points1 + points2)/2;
tri = delaunay(midway_shape(:,1),midway_shape(:,2));
% % Look at triangles
% trisurf(tri1,points1(:,1),points1(:,2),zeros(size(points1(:,2))))         

%% Now produce the frames of the morph sequence A
f = 61;
for fnum = 1:f
    t = (fnum-1)/f;
    pts_target = (1-t)*points1 + t*points2;                % intermediate key-point locations
    I1_warp = warp(image1,points1,pts_target,tri);              % warp image 1
    I2_warp = warp(image2,points2,pts_target,tri);               % warp image 2
    Iresult = (1-t)*I1_warp + t*I2_warp;                     % blend the two warped images
    imwrite(Iresult,sprintf('frame_%2.2d.jpg',fnum),'jpg')
end
