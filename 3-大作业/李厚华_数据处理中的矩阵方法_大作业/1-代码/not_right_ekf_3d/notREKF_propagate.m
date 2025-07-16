function [Estimation_X] = notREKF_propagate(Estimation_X, OdometryFromThis2Next, Sigma_ODO )



% retrieve v and w
v = OdometryFromThis2Next(1:3);
w = OdometryFromThis2Next(4:6);


NumberOfLandmarks = size(Estimation_X.landmarks, 2);
Jrw = jaco_r(-w);
%jaco_r 函数是一个重载函数，根据输入 delta 的维度不同，会执行不同的计算逻辑。
%它主要用于计算与旋转相关的雅可比矩阵，
ExpMinusM = so3_exp(-w);




temp = repmat({Estimation_X.orientation}, NumberOfLandmarks+2,1 );
A = blkdiag(temp{:});
A(4:6,1:3)=skew(Estimation_X.position)*Estimation_X.orientation;
 
if NumberOfLandmarks>0
   for i=1:NumberOfLandmarks
    A(6+3*i-2:6+3*i,1:3)=skew(Estimation_X.landmarks(1:3,i))*Estimation_X.orientation;
   end
end
B1=[eye(3)  zeros(3,3); zeros(3,3) eye(3)];
B=[B1; sparse(3*NumberOfLandmarks,6)];
B=sparse(B);
adA=A*B;
odoCov=diag([w.^2;v.^2])*Sigma_ODO^2;
% final update the covariance
Estimation_X.cov = Estimation_X.cov+ adA*odoCov*adA';

% update position and orientation
Estimation_X.position = Estimation_X.position+Estimation_X.orientation*v;
Estimation_X.orientation = Estimation_X.orientation*so3_exp(w);


end




