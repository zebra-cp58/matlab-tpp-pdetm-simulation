function dz = tryhan63(t, z, K)

global C N sigma;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% 传递初始参数 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rho0    = K(1);
rhotf   = K(2);
deltal  = K(3);
deltau  = K(4);
upsilon = K(5);
Tstar   = K(6);
p       = K(7);
tf      = K(8);
ne0     = K(9);
ne1     = K(10);
ne2     = K(11);
ne3     = K(12);
kappa0  = K(13);
a0      = K(14);
tau1    = K(15);
epsilon10 = K(16);
kappa11 = K(17);
kappa12 = K(18);
r1      = K(19);
h11      = K(20);
a11     = K(21);
gamma11  = K(22);
gamma_z11 = K(23);
vartheta11 = K(24);
mu11    = K(25);
h12      = K(26);
a12     = K(27);
gamma12  = K(28);
gamma_z12 = K(29);
vartheta12 = K(30);
mu12    = K(31);
Sigma11 = K(32);
Sigma12 = K(33);
tau3    = K(34);
epsilon30 = K(35);
kappa31 = K(36);
kappa32 = K(37);
r3      = K(38);
h31     = K(39);
a31     = K(40);
gamma31 = K(41);
gamma_z31 = K(42);
vartheta31 = K(43);
mu31    = K(44);
h32     = K(45);
a32     = K(46);
gamma32 = K(47);
gamma_z32 = K(48);
vartheta32 = K(49);
mu32    = K(50);
Sigma31 = K(51);
Sigma32 = K(52);
tau4    = K(53);
epsilon40 = K(54);
kappa41 = K(55);
kappa42 = K(56);
r4      = K(57);
h41     = K(58);
a41     = K(59);
gamma41 = K(60);
gamma_z41 = K(61);
vartheta41 = K(62);
mu41    = K(63);
h42     = K(64);
a42     = K(65);
gamma42 = K(66);
gamma_z42 = K(67);
vartheta42 = K(68);
mu42    = K(69);
Sigma41 = K(70);
Sigma42 = K(71);
tau2    = K(72);
epsilon20 = K(73);
kappa21 = K(74);
kappa22 = K(75);
r2      = K(76);
h21     = K(77);
a21     = K(78);
gamma21 = K(79);
gamma_z21 = K(80);
vartheta21 = K(81);
mu21    = K(82);
h22     = K(83);
a22     = K(84);
gamma22 = K(85);
gamma_z22 = K(86);
vartheta22 = K(87);
mu22    = K(88);
Sigma21 = K(89);
Sigma22 = K(90);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% 传递状态 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x11 = z(1);
x12 = z(2);
alpha12c = z(3);
sigmahat12 = z(4);
hatepsilon_yu11 = z(5);
hatepsilon_yu12 = z(6);
z11F = z(7);
z12F = z(8);
eta1 = z(9);
w11=zeros(N,1);%提前分配内存
for i=1:N
    w11(i)=z(9+i);               
end
w12=zeros(N,1);%提前分配内存
for i=1:N
    w12(i)=z(N+9+i);               
end

x31 = z(10+2*N);
x32 = z(11+2*N);
alpha32c = z(12+2*N);
sigmahat32 = z(13+2*N);
hatepsilon_yu31 = z(14+2*N);
hatepsilon_yu32 = z(15+2*N);
z31F = z(16+2*N);
z32F = z(17+2*N);
eta3 = z(18+2*N);
w31=zeros(N,1);%提前分配内存
for i=1:N
    w31(i)=z(18+2*N+i);               
end
w32=zeros(N,1);%提前分配内存
for i=1:N
    w32(i)=z(18+3*N+i);               
end

x41 = z(19+4*N);
x42 = z(20+4*N);
alpha42c = z(21+4*N);
sigmahat42 = z(22+4*N);
hatepsilon_yu41 = z(23+4*N);
hatepsilon_yu42 = z(24+4*N);
z41F = z(25+4*N);
z42F = z(26+4*N);
eta4 = z(27+4*N);
w41=zeros(N,1);%提前分配内存
for i=1:N
    w41(i)=z(27+4*N+i);               
end
w42=zeros(N,1);%提前分配内存
for i=1:N
    w42(i)=z(27+5*N+i);               
end

x21 = z(28+6*N);
x22 = z(29+6*N);
alpha22c = z(30+6*N);
sigmahat22 = z(31+6*N);
hatepsilon_yu21 = z(32+6*N);
hatepsilon_yu22 = z(33+6*N);
z21F = z(34+6*N);
z22F = z(35+6*N);
eta2 = z(36+6*N);
w21=zeros(N,1);%提前分配内存
for i=1:N
    w21(i)=z(36+6*N+i);               
end
w22=zeros(N,1);%提前分配内存
for i=1:N
    w22(i)=z(36+7*N+i);               
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% 系统 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x1d = -sin(t);
dx1d = -cos(t);
ddx1d = +sin(t);

E11 = x11 - x1d;

x3d = sin(t);
dx3d = cos(t);
ddx3d = -sin(t);

E31 = x31 - x3d;

% x4d = sin(t);
% dx4d = cos(t);
% ddx4d = -sin(t);
% 
% E41 = x41 - x4d;

dx11 = x12;

x2d = x11;
dx2d = dx11;
% ddx1d = +sin(t);

E21 = x21 - x2d;

dx31 = x32;

x4d = x31;
dx4d = dx31;

E41 = x41 - x4d;
%TPP(6)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
varpi = -(upsilon*tf*t)/(tf-t);

    
if t >= 0 && t < tf
        rho = (rho0 - rhotf) * exp(varpi) + rhotf;
    else
        rho = rhotf;
end

if t >= 0 && t < tf
        drho = -(rho0 - rhotf) * exp(varpi) * upsilon * tf^2 / ((tf - t)^2);
    else
        drho = 0;
end

ed1 = (deltal - 1) * rho + rhotf * 1;%这里暂时默认初始状态大于0,1号智能体
eu1 = (deltau + 1) * rho - rhotf * 1;
ded1 = (deltal - 1) * drho;
deu1 = (deltau + 1) * drho;
Delta11 = (eu1 + ed1)/((ed1 + E11)*(eu1 - E11));
Delta1d = 1/(ed1 + E11);
Delta1u = -1/(eu1 - E11);
Delta12 = Delta1d * ded1 + Delta1u * deu1 - Delta11 * dx1d;
z11 = log((ed1+E11)/(eu1-E11));

ed3 = (deltal - 1) * rho + rhotf * 1;%这里暂时默认初始状态大于0,3号智能体
eu3 = (deltau + 1) * rho - rhotf * 1;
ded3 = (deltal - 1) * drho;
deu3 = (deltau + 1) * drho;
Delta31 = (eu3 + ed3)/((ed3 + E31)*(eu3 - E31));
Delta3d = 1/(ed3 + E31);
Delta3u = -1/(eu3 - E31);
Delta32 = Delta3d * ded3 + Delta3u * deu3 - Delta31 * dx3d;
z31 = log((ed3+E31)/(eu3-E31));

ed4 = (deltal - (-1)) * rho + rhotf * (-1);%这里暂时默认初始状态小于0,4号智能体
eu4 = (deltau + (-1)) * rho - rhotf * (-1);
ded4 = (deltal - (-1)) * drho;
deu4 = (deltau + (-1)) * drho;
% ed4 = deltal * rhotf;
% eu4 = deltau * rhotf;
% ded4 = 0;
% deu4 = 0;
Delta41 = (eu4 + ed4)/((ed4 + E41)*(eu4 - E41));
Delta4d = 1/(ed4 + E41);
Delta4u = -1/(eu4 - E41);
Delta42 = Delta4d * ded4 + Delta4u * deu4 - Delta41 * dx4d;
z41 = log((ed4+E41)/(eu4-E41));

ed2 = (deltal - (-1)) * rho + rhotf * (-1);%这里暂时默认初始状态小于0,2号智能体
eu2 = (deltau + (-1)) * rho - rhotf * (-1);
ded2 = (deltal - (-1)) * drho;
deu2 = (deltau + (-1)) * drho;
Delta21 = (eu2 + ed2)/((ed2 + E21)*(eu2 - E21));
Delta2d = 1/(ed2 + E21);
Delta2u = -1/(eu2 - E21);
Delta22 = Delta2d * ded2 + Delta2u * deu2 - Delta21 * dx2d;
z21 = log((ed2+E21)/(eu2-E21));
%神经网络%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
S11m=zeros(N,1);                                   
for i=1:N
     S11m(i,1)=exp(-(sum(([x11,x12]'-C(:,i)).^2))/(sigma^2));     
end
S12m=zeros(N,1);                                   
for i=1:N
     S12m(i,1)=exp(-(sum(([x11,x12]'-C(:,i)).^2))/(sigma^2));     
end


S31m=zeros(N,1);                                   
for i=1:N
     S31m(i,1)=exp(-(sum(([x31,x32]'-C(:,i)).^2))/(sigma^2));     
end
S32m=zeros(N,1);                                   
for i=1:N
     S32m(i,1)=exp(-(sum(([x31,x32]'-C(:,i)).^2))/(sigma^2));     
end

S41m=zeros(N,1);                                   
for i=1:N
     S41m(i,1)=exp(-(sum(([x41,x42]'-C(:,i)).^2))/(sigma^2));     
end
S42m=zeros(N,1);                                   
for i=1:N
     S42m(i,1)=exp(-(sum(([x41,x42]'-C(:,i)).^2))/(sigma^2));     
end

S21m=zeros(N,1);                                   
for i=1:N
     S21m(i,1)=exp(-(sum(([x21,x22]'-C(:,i)).^2))/(sigma^2));     
end
S22m=zeros(N,1);                                   
for i=1:N
     S22m(i,1)=exp(-(sum(([x21,x22]'-C(:,i)).^2))/(sigma^2));     
end

%beta(t)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if t >= 0 && t < Tstar
        beta = ((Tstar - t)/Tstar)^2 + p;
    else
        beta = p;
end
    
if t >= 0 && t < Tstar
        dot_beta = -2*(Tstar - t)/Tstar^2;
    else
        dot_beta = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%虚拟控制%
alpha11 = -(h11 - dot_beta/(2*beta))*z11/Delta11 - Delta12/Delta11 ... 
    - w11' * S11m - hatepsilon_yu11 - (a11^2*z11)/2;
alpha31 = -(h31 - dot_beta/(2*beta))*z31/Delta31 - Delta32/Delta31 ... 
    - w31' * S31m - hatepsilon_yu31 - (a31^2*z31)/2;
alpha41 = -(h41 - dot_beta/(2*beta))*z41/Delta41 - Delta42/Delta41 ... 
    - w41' * S41m - hatepsilon_yu41 - (a41^2*z41)/2;
alpha21 = -(h21 - dot_beta/(2*beta))*z21/Delta21 - Delta22/Delta21 ... 
    - w21' * S21m - hatepsilon_yu21 - (a21^2*z21)/2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%滤波器%%%
dalpha12c = 1/tau1*(-((kappa11 - tau1 * dot_beta/(2 * beta)) * (alpha12c - alpha11) )...
           - (tau1* sigmahat12^2 * (alpha12c - alpha11)) /  sqrt(sigmahat12^2 * (alpha12c - alpha11)^2 + epsilon10^2));
dalpha32c = 1/tau3*(-((kappa31 - tau3 * dot_beta/(2 * beta)) * (alpha32c - alpha31) )...
           - (tau3* sigmahat32^2 * (alpha32c - alpha31)) /  sqrt(sigmahat32^2 * (alpha32c - alpha31)^2 + epsilon30^2));
dalpha42c = 1/tau4*(-((kappa41 - tau4 * dot_beta/(2 * beta)) * (alpha42c - alpha41) )...
           - (tau4* sigmahat42^2 * (alpha42c - alpha41)) /  sqrt(sigmahat42^2 * (alpha42c - alpha41)^2 + epsilon40^2));
dalpha22c = 1/tau2*(-((kappa21 - tau2 * dot_beta/(2 * beta)) * (alpha22c - alpha21) )...
           - (tau2* sigmahat22^2 * (alpha22c - alpha21)) /  sqrt(sigmahat22^2 * (alpha22c - alpha21)^2 + epsilon20^2));
       
z12 = x12 - alpha12c;
z32 = x32 - alpha32c;
z42 = x42 - alpha42c;
z22 = x22 - alpha22c;

alpha12 = - (h12 - dot_beta/(2*beta))*z12 - w12' * S12m - hatepsilon_yu12 - (a12^2*z12)/2 + dalpha12c - Delta11 *z11;
alpha32 = - (h32 - dot_beta/(2*beta))*z32 - w32' * S32m - hatepsilon_yu32 - (a32^2*z32)/2 + dalpha32c - Delta31 *z31;
alpha42 = - (h42 - dot_beta/(2*beta))*z42 - w42' * S42m - hatepsilon_yu42 - (a42^2*z42)/2 + dalpha42c - Delta41 *z41;
alpha22 = - (h22 - dot_beta/(2*beta))*z22 - w22' * S22m - hatepsilon_yu22 - (a22^2*z22)/2 + dalpha22c - Delta21 *z21;

% 计算自适应阈值 m(t)
    m1 = exp(-z11^2 - a0);  % 确保 m1 ∈ (0,1)

    rou1 = (0.07*t^2 + 1)^(-1);

        % 计算性能相关项 λ(t)
    lambda1 = 1/(abs(z11) + abs(z12) + kappa0);

    varsigma1 = (ne1 * eta1 + ne2 * lambda1 + ne3)/(1 - m1);
    
    m3 = exp(-z31^2 - a0);  % 确保 m1 ∈ (0,1)

    rou3 = (0.07*t^2 + 1)^(-1);

        % 计算性能相关项 λ(t)
    lambda3 = 1/(abs(z31) + abs(z32) + kappa0);

    varsigma3 = (ne1 * eta3 + ne2 * lambda3 + ne3)/(1 - m3);
    
    m4 = exp(-z41^2 - a0);  % 确保 m1 ∈ (0,1)

    rou4 = (0.07*t^2 + 1)^(-1);

        % 计算性能相关项 λ(t)
    lambda4 = 1/(abs(z41) + abs(z42) + kappa0);

    varsigma4 = (ne1 * eta4 + ne2 * lambda4 + ne3)/(1 - m4);
    
    m2 = exp(-z21^2 - a0);  % 确保 m1 ∈ (0,1)

    rou2 = (0.07*t^2 + 1)^(-1);

        % 计算性能相关项 λ(t)
    lambda2 = 1/(abs(z21) + abs(z22) + kappa0);

    varsigma2 = (ne1 * eta2 + ne2 * lambda2 + ne3)/(1 - m2);
    
    
    
    w1z = 0;
w2z = 0;
w3z = 0;
w4z = 0;
% 连续信号u1
u1 = - (1 + m1)*(tanh(z12*alpha12/rou1)*alpha12 + tanh(z12*varsigma1/rou1)*varsigma1);

%yu1 = m1 * abs(w1z) + ne1 * eta1 + ne2 * lambda1 + ne3;
yu1 = m1 * abs(w1z) + ne1 * eta1 + ne2 * lambda1 + ne3;


  if t==0
      w1z=u1;
  end
  if t>0 && abs(u1-w1z)<yu1  % 如果变化量小于阈值
    w1z=w1z;  % 保持原控制输入（不触发）
else 
    w1z=u1;  % 采用新计算的控制输入（触发）
  end
  
u3 = - (1 + m3)*(tanh(z32*alpha32/rou3)*alpha32 + tanh(z32*varsigma3/rou3)*varsigma3);

yu3 = m3 * abs(w3z) + ne1 * eta3 + ne2 * lambda3 + ne3;

  if t==0
      w3z=u3;
  end
  if t>0 && abs(u3-w3z)<yu3  % 如果变化量小于阈值
    w3z=w3z;  % 保持原控制输入（不触发）
else 
    w3z=u3;  % 采用新计算的控制输入（触发）
  end
  
u4 = - (1 + m4)*(tanh(z42*alpha42/rou4)*alpha42 + tanh(z42*varsigma4/rou4)*varsigma4);

yu4 = m4 * abs(w4z) + ne1 * eta4 + ne2 * lambda4 + ne3;

  if t==0
      w4z=u4;
  end
  if t>0 && abs(u4-w4z)<yu4  % 如果变化量小于阈值
    w4z=w4z;  % 保持原控制输入（不触发）
else 
    w4z=u4;  % 采用新计算的控制输入（触发）
  end
  
u2 = - (1 + m2)*(tanh(z22*alpha22/rou2)*alpha22 + tanh(z22*varsigma2/rou2)*varsigma2);

yu2 = m2 * abs(w2z) + ne1 * eta2 + ne2 * lambda2 + ne3;

  if t==0
      w2z=u2;
  end
  if t>0 && abs(u2-w2z)<yu2  % 如果变化量小于阈值
    w2z=w2z;  % 保持原控制输入（不触发）
else 
    w2z=u2;  % 采用新计算的控制输入（触发）
  end
  
  
%f1=0
dx12 = -4.9*sin(x11)-x12 + u1;%f2=-4.9*sin(x11)-x12

dx31 = x32;%f1=0
dx32 = -4.9*sin(x31)-x32 + u3;%f2=-4.9*sin(x11)-x12

dx41 = x42;%f1=0
dx42 = -4.9*sin(x41)-x42 + u4;%f2=-4.9*sin(x11)-x12

dx21 = x22;%f1=0
dx22 = -4.9*sin(x21)-x22 + u2;%f2=-4.9*sin(x11)-x12

dsigmahat12 =  -(kappa12 - dot_beta / beta) * sigmahat12 + r1 * abs(alpha12c - alpha11);
dsigmahat32 =  -(kappa32 - dot_beta / beta) * sigmahat32 + r3 * abs(alpha32c - alpha31);
dsigmahat42 =  -(kappa42 - dot_beta / beta) * sigmahat42 + r4 * abs(alpha42c - alpha41);
dsigmahat22 =  -(kappa22 - dot_beta / beta) * sigmahat22 + r2 * abs(alpha22c - alpha21);

dw11 = (1/gamma11) * (Delta11 * z11 + gamma_z11 * z11F) * S11m - (vartheta11 - dot_beta/(beta)) * w11;
dw12 = (1/gamma12) * (z12 + gamma_z12 * z12F) * S12m - (vartheta12 - dot_beta/(beta)) * w12;

dw31 = (1/gamma31) * (Delta31 * z31 + gamma_z31 * z31F) * S31m - (vartheta31 - dot_beta/(beta)) * w31;
dw32 = (1/gamma32) * (z32 + gamma_z32 * z32F) * S32m - (vartheta32 - dot_beta/(beta)) * w32;

dw41 = (1/gamma41) * (Delta41 * z41 + gamma_z41 * z41F) * S41m - (vartheta41 - dot_beta/(beta)) * w41;
dw42 = (1/gamma42) * (z42 + gamma_z42 * z42F) * S42m - (vartheta42 - dot_beta/(beta)) * w42;

dw21 = (1/gamma21) * (Delta21 * z21 + gamma_z21 * z21F) * S21m - (vartheta21 - dot_beta/(beta)) * w21;
dw22 = (1/gamma22) * (z22 + gamma_z22 * z22F) * S22m - (vartheta22 - dot_beta/(beta)) * w22;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%预测误差%%
dhatepsilon_yu11 = Sigma11 * (dx11 - w11' * S11m - hatepsilon_yu11 - x12 + Sigma11^(-1) * (Delta11 * z11 + gamma_z11 * z11F));  
dz11F = dx11 - x12 - w11' * S11m - hatepsilon_yu11 - (mu11 - dot_beta/(2*beta)) * z11F;

dhatepsilon_yu31 = Sigma31 * (dx31 - w31' * S31m - hatepsilon_yu31 - x32 + Sigma31^(-1) * (Delta31 * z31 + gamma_z31 * z31F));  
dz31F = dx31 - x32 - w31' * S31m - hatepsilon_yu31 - (mu31 - dot_beta/(2*beta)) * z31F;

dhatepsilon_yu41 = Sigma41 * (dx41 - w41' * S41m - hatepsilon_yu41 - x42 + Sigma41^(-1) * (Delta41 * z41 + gamma_z41 * z41F));  
dz41F = dx41 - x42 - w41' * S41m - hatepsilon_yu41 - (mu41 - dot_beta/(2*beta)) * z41F;

dhatepsilon_yu21 = Sigma21 * (dx21 - w21' * S21m - hatepsilon_yu21 - x22 + Sigma21^(-1) * (Delta21 * z21 + gamma_z21 * z21F));  
dz21F = dx21 - x22 - w21' * S21m - hatepsilon_yu21 - (mu21 - dot_beta/(2*beta)) * z21F;

dhatepsilon_yu12 = Sigma12 * (dx12 - w12' * S12m - hatepsilon_yu12 - w1z + Sigma12^(-1) * (z12 + gamma_z12 * z12F));  
dz12F = dx12 - w1z - w12' * S12m - hatepsilon_yu12 - (mu12 - dot_beta/(2*beta)) * z12F;

dhatepsilon_yu32 = Sigma32 * (dx32 - w32' * S32m - hatepsilon_yu32 - w3z + Sigma32^(-1) * (z32 + gamma_z32 * z32F));  
dz32F = dx32 - w3z - w32' * S32m - hatepsilon_yu32 - (mu32 - dot_beta/(2*beta)) * z32F;

dhatepsilon_yu42 = Sigma42 * (dx42 - w42' * S42m - hatepsilon_yu42 - w4z + Sigma42^(-1) * (z42 + gamma_z42 * z42F));  
dz42F = dx42 - w4z - w42' * S42m - hatepsilon_yu42 - (mu42 - dot_beta/(2*beta)) * z42F;

dhatepsilon_yu22 = Sigma22 * (dx22 - w22' * S22m - hatepsilon_yu22 - w2z + Sigma22^(-1) * (z22 + gamma_z22 * z22F));  
dz22F = dx22 - w2z - w22' * S22m - hatepsilon_yu22 - (mu22 - dot_beta/(2*beta)) * z22F;


    % 更新 η 的动态（论文公式(58)）
    deta1 = -ne0 * eta1 - abs(u1-w1z) + m1 * abs(w1z) + ne2 * lambda1 + ne3;
    
    deta3 = -ne0 * eta3 - abs(u3-w3z) + m3 * abs(w3z) + ne2 * lambda3 + ne3;
    deta4 = -ne0 * eta4 - abs(u4-w4z) + m4 * abs(w4z) + ne2 * lambda4 + ne3;
    deta2 = -ne0 * eta2 - abs(u2-w2z) + m2 * abs(w2z) + ne2 * lambda2 + ne3;
    
dz = [dx11;dx12;dalpha12c;dsigmahat12;dhatepsilon_yu11;dhatepsilon_yu12;dz11F;dz12F;deta1;dw11;dw12;...
      dx31;dx32;dalpha32c;dsigmahat32;dhatepsilon_yu31;dhatepsilon_yu32;dz31F;dz32F;deta3;dw31;dw32;...
      dx41;dx42;dalpha42c;dsigmahat42;dhatepsilon_yu41;dhatepsilon_yu42;dz41F;dz42F;deta4;dw41;dw42;...
      dx21;dx22;dalpha22c;dsigmahat22;dhatepsilon_yu21;dhatepsilon_yu22;dz21F;dz22F;deta2;dw21;dw22];
