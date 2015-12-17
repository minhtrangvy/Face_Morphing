function T = tform(tri1,tri2)
    % compute the transformation T which maps points
    % of triangle1 to triangle2 
    %
    %  tri1 : 2x3 matrix containing coordinates of triangle 1
    %  tri2 : 2x3 matrix containing coordinates of triangle 2
    %
    %  T : the resulting transformation, should be a 3x3
    %      matrix which operates on points described in 
    %      homogeneous coordinates 
   

    % Method 1, just dividing
    % Source: http://math.stackexchange.com/questions/1092002/how-to-define-an-affine-transformation-using-2-triangles
    tri1 = tri1';
    tri2 = tri2';
    
    tri1(3,:) = [1,1,1];
    tri2(3,:) = [1,1,1];
%     T = inv(tri1) * tri2;
    T = tri2/tri1;
%     T = tri1/tri2;
%}
    
%{

    % Method 2: using affine matrix 
    % Source: http://stackoverflow.com/questions/1114257/transform-a-triangle-to-another-triangle
    tri1_1 = tri1(1,:);
    tri1_2 = tri1(2,:);
    tri1_3 = tri1(3,:);
    
    tri2_1 = tri2(1,:);
    tri2_2 = tri2(2,:);
    tri2_3 = tri2(3,:);

    X = [tri1_1(1) tri1_1(2) 1 0 0 0;
         tri1_2(1) tri1_2(2) 1 0 0 0;
         tri1_3(1) tri1_3(2) 1 0 0 0;
         0 0 0 tri1_1(1) tri1_1(2) 1;
         0 0 0 tri1_2(1) tri1_2(2) 1;
         0 0 0 tri1_3(1) tri1_3(2) 1];
    X2 = [tri2_1(1) tri2_1(2) 1 0 0 0;      % dividing the other way
          tri2_2(1) tri2_2(2) 1 0 0 0;
          tri2_3(1) tri2_3(2) 1 0 0 0;
          0 0 0 tri2_1(1) tri2_1(2) 1;
          0 0 0 tri2_2(1) tri2_2(2) 1;
          0 0 0 tri2_3(1) tri2_3(2) 1];
      
    Y = [tri2_1, tri2_2, tri2_3]';
    Y2 = [tri1_1, tri1_2, tri1_3]';
    
%     X_inv = inv(X);
%     T = X_inv * Y;
    T = X\Y;                % Dividing instead because Matlab complained that 
    T2 = X2\Y2;             % multiplying an inverse matrix with another matrix is slower
    
    T = [T(1) T(2) T(3);
         T(4) T(5) T(6);
         0 0 1];
    T2 = [T2(1) T2(2) T2(3);
         T2(4) T2(5) T2(6);
         0 0 1];     
     
     
     
     
     
    %
    % test code to make sure we have done the right thing
    %
%}
    % apply mapping to corners of tri1 and 
    % make sure the result is close to tri2
    a = tri1(:,1);
    b = tri2(:,1);
    err1 = sum((T*a - b).^2);
    assert(err1 < eps)
    
    err2 = sum((T*tri1(:,2) - tri2(:,2)).^2);
    assert(err2 < eps)

    err3 = sum((T*tri1(:,3) - tri2(:,3)).^2);
    assert(err3 < eps)

