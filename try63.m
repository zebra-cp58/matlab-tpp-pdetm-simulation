% 改成结构平衡，一致性误差
clc;
clear;
close all;


global C N sigma;

M=10;                           % 调大了的话，延迟和峰值都变小 太大震荡（也有可能sigma的问题
N=100;                          %11
r=M-1;                          %10
bound1=7.5;                      %边界 有点奇怪，这里从7.5调成2，峰值缩小到2以内，看来21系列有点问题
bound2=7.5;                      % 太小峰值会小，太大峰值也会小
C1=zeros(1,N);%提前分配内存
C2=zeros(1,N);%提前分配内存
        for c=0:1:r                                 %0~10 生成神经网络节点
            for p=0:1:r                                 %0~10
                C1(p+1+c*M)=-bound1+2*bound1/r*c;         %C1=-1.5 + 3/10 * k;;;C1(1)=C(2)=...C(10);;;C(11)=...C(20)
                C2(p+1+c*M)=-bound2+2*bound2/r*p;         %C2=-1.5 + 3/10 * p;;;1~10个元素各不同，11~20=1~10
            end
        end
C=[C1;C2];
sigma=2*bound2/r*2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%参数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%参数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TPP
rho0 = 0.8;
%rho0 = 1.2;
rhotf = 0.14;
deltal = 0.7;
deltau = 0.77; 
upsilon = 0.5; %论文中的v
tf = 2;

% 动态事件触发相关参数
ne0 = 0.8;      % 强衰减               与阈值负相关
ne1 = 0.16;      % 中等 eta1 影响       与阈值正相关
ne2 = 0.08;      % 中等 lambda1 影响    与阈值正相关
ne3 = 0.04;     % 基础触发项           与阈值正相关
a0 = 0.1;       % 适当的基础阈值
kappa0 = 0.5;   % 控制 lambda1 大小    与阈值负相关

% 15,16 - 时间相关参数
Tstar = 2.5;
p = 0.01;

% 虚拟控制输入参数（第一步和第二步）
h11 = 30; % 调小了 可能会完全抖振 甚至可能发散 波形峰值小了 延迟好像还高了 保持30最好
h31 = h11;
h41 = h11;
h21 = h11;
h12 = 20; % 调小了 可能会完全抖振 甚至可能发散 波形峰值小了 延迟好像还高了 保持20最好
a11 = 1.5; % 调小了 可能会完全抖振 波形峰值小了 像失真 保持1.5最好
a12 = 1.5; % 调小了 可能会完全抖振 波形峰值小了 像失真 保持1.5最好

% 滤波器APF参数
tau1 = 0.03; %调小了 延迟不变，峰值变小
epsilon10 = 0.1;
kappa11 = 2; % 之前是q1来表示的 调大了 延迟不变，峰值略小

% 滤波器自适应律参数
kappa12 = 2; % 调大了 延迟不变，峰值略小
r1 = 1;

% 自适应律参数（第一步和第二步）
gamma11 = 1;
gamma_z11 = 0.8; % 调大了峰值变大略多，延迟少一半 （延迟真的有少吗？
vartheta11 = 0.5; % ϑ_{i,1} 调小了，波形峰值变大，延迟不咋变
gamma12 = 1; % 1是比较合适的，调大了波形变化不大峰值还小了，调小了会有局部抖振
gamma_z12 = 0.8; % 调大了峰值变大略多，延迟少一半
vartheta12 = 0.5; % vartheta_i2 调小了，波形峰值变大，延迟不咋变

% 神经网络余差参数
Sigma11 = 2; % 调小了波形很漂亮，峰值够大，但是延迟很高，感觉0.1不动最好？
Sigma12 = 2;

% 预测误差参数
mu11 = 0.1; % 调大了波形峰值减蛮多的，然后延迟只减少一丢丢，0.1合适
mu12 = 0.1;

%%%3号智能体参数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 控制律参数
h32 = 20; % 调小了 可能会完全抖振 甚至可能发散 波形峰值小了 延迟好像还高了 保持20最好
a31 = 1.5; % 调小了 可能会完全抖振 波形峰值小了 像失真 保持1.5最好
a32 = 1.5; % 调小了 可能会完全抖振 波形峰值小了 像失真 保持1.5最好

% 滤波器APF参数
tau3 = 0.03; %调小了 延迟不变，峰值变小
epsilon30 = 0.1;
kappa31 = 2; % 之前是q1来表示的 调大了 延迟不变，峰值略小

% 滤波器自适应律参数
kappa32 = 2; % 调大了 延迟不变，峰值略小
r3 = 1;

% 自适应律参数（第一步和第二步）
gamma31 = 1;
gamma_z31 = 0.8; % 调大了峰值变大略多，延迟少一半 （延迟真的有少吗？
vartheta31 = 0.5; % ϑ_{i,1} 调小了，波形峰值变大，延迟不咋变
gamma32 = 1; % 1是比较合适的，调大了波形变化不大峰值还小了，调小了会有局部抖振
gamma_z32 = 0.8; % 调大了峰值变大略多，延迟少一半
vartheta32 = 0.5; % vartheta_i2 调小了，波形峰值变大，延迟不咋变

% 神经网络余差参数
Sigma31 = 2; % 调小了波形很漂亮，峰值够大，但是延迟很高，感觉0.1不动最好？
Sigma32 = 2;

% 预测误差参数
mu31 = 0.1; % 调大了波形峰值减蛮多的，然后延迟只减少一丢丢，0.1合适
mu32 = 0.1;

%%%4号智能体参数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 控制律参数
h42 = 20; % 调小了 可能会完全抖振 甚至可能发散 波形峰值小了 延迟好像还高了 保持20最好
a41 = 1.5; % 调小了 可能会完全抖振 波形峰值小了 像失真 保持1.5最好
a42 = 1.5; % 调小了 可能会完全抖振 波形峰值小了 像失真 保持1.5最好

% 滤波器APF参数
tau4 = 0.03; %调小了 延迟不变，峰值变小
epsilon40 = 0.1;
kappa41 = 2; % 之前是q1来表示的 调大了 延迟不变，峰值略小

% 滤波器自适应律参数
kappa42 = 2; % 调大了 延迟不变，峰值略小
r4 = 1;

% 自适应律参数（第一步和第二步）
gamma41 = 1;
gamma_z41 = 0.8; % 调大了峰值变大略多，延迟少一半 （延迟真的有少吗？
vartheta41 = 0.5; % ϑ_{i,1} 调小了，波形峰值变大，延迟不咋变
gamma42 = 1; % 1是比较合适的，调大了波形变化不大峰值还小了，调小了会有局部抖振
gamma_z42 = 0.8; % 调大了峰值变大略多，延迟少一半
vartheta42 = 0.5; % vartheta_i2 调小了，波形峰值变大，延迟不咋变

% 神经网络余差参数
Sigma41 = 2; % 调小了波形很漂亮，峰值够大，但是延迟很高，感觉0.1不动最好？
Sigma42 = 2;

% 预测误差参数
mu41 = 0.1; % 调大了波形峰值减蛮多的，然后延迟只减少一丢丢，0.1合适
mu42 = 0.1;


%%%2号智能体参数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 控制律参数
h22 = 20; % 调小了 可能会完全抖振 甚至可能发散 波形峰值小了 延迟好像还高了 保持20最好
a21 = 1.5; % 调小了 可能会完全抖振 波形峰值小了 像失真 保持1.5最好
a22 = 1.5; % 调小了 可能会完全抖振 波形峰值小了 像失真 保持1.5最好

% 滤波器APF参数
tau2 = 0.03; %调小了 延迟不变，峰值变小
epsilon20 = 0.1;
kappa21 = 2; % 之前是q1来表示的 调大了 延迟不变，峰值略小

% 滤波器自适应律参数
kappa22 = 2; % 调大了 延迟不变，峰值略小
r2 = 1;

% 自适应律参数（第一步和第二步）
gamma21 = 1;
gamma_z21 = 0.8; % 调大了峰值变大略多，延迟少一半 （延迟真的有少吗？
vartheta21 = 0.5; % ϑ_{i,1} 调小了，波形峰值变大，延迟不咋变
gamma22 = 1; % 1是比较合适的，调大了波形变化不大峰值还小了，调小了会有局部抖振
gamma_z22 = 0.8; % 调大了峰值变大略多，延迟少一半
vartheta22 = 0.5; % vartheta_i2 调小了，波形峰值变大，延迟不咋变

% 神经网络余差参数
Sigma21 = 2; % 调小了波形很漂亮，峰值够大，但是延迟很高，感觉0.1不动最好？
Sigma22 = 2;

% 预测误差参数
mu21 = 0.1; % 调大了波形峰值减蛮多的，然后延迟只减少一丢丢，0.1合适
mu22 = 0.1;


% 事件触发参数初始化
yu1 = 0.01;    % 事件触发阈值1
count1 = 0;    % 事件触发计数器1
num1 = 0;      % 触发次数计数器1
rt1 = [];      % 记录触发时间点1
rtt1 = [];     % 记录触发间隔时间1
tk1 = 0;       % 上次触发时间1

% 事件触发参数初始化
yu3 = 0.01;    % 事件触发阈值3
count3 = 0;    % 事件触发计数器3
num3 = 0;      % 触发次数计数器3
rt3 = [];      % 记录触发时间点3
rtt3 = [];     % 记录触发间隔时间3
tk3 = 0;       % 上次触发时间3

% 事件触发参数初始化
yu4 = 0.01;    % 事件触发阈值4
count4 = 0;    % 事件触发计数器4
num4 = 0;      % 触发次数计数器4
rt4 = [];      % 记录触发时间点4
rtt4 = [];     % 记录触发间隔时间4
tk4 = 0;       % 上次触发时间4

% 事件触发参数初始化
yu2 = 0.01;    % 事件触发阈值2
count2 = 0;    % 事件触发计数器2
num2 = 0;      % 触发次数计数器2
rt2 = [];      % 记录触发时间点2
rtt2 = [];     % 记录触发间隔时间2
tk2 = 0;       % 上次触发时间2


K = [rho0; 
     rhotf; 
     deltal; 
     deltau; 
     upsilon; 
     Tstar; 
     p; 
     tf;
     ne0; 
     ne1; 
     ne2; 
     ne3; 
     kappa0; 
     a0;
     tau1; 
     epsilon10; 
     kappa11; 
     kappa12; 
     r1; 
     h11; 
     a11; 
     gamma11; 
     gamma_z11; 
     vartheta11; 
     mu11; 
     h12; 
     a12; 
     gamma12; 
     gamma_z12; 
     vartheta12; 
     mu12;
     Sigma11;
     Sigma12;
     tau3; 
     epsilon30; 
     kappa31; 
     kappa32; 
     r3; 
     h31; 
     a31; 
     gamma31; 
     gamma_z31; 
     vartheta31; 
     mu31; 
     h32; 
     a32; 
     gamma32; 
     gamma_z32; 
     vartheta32; 
     mu32;
     Sigma31;
     Sigma32;
     tau4; 
     epsilon40; 
     kappa41; 
     kappa42; 
     r4; 
     h41; 
     a41; 
     gamma41; 
     gamma_z41; 
     vartheta41; 
     mu41; 
     h42; 
     a42; 
     gamma42; 
     gamma_z42; 
     vartheta42; 
     mu42;
     Sigma41;
     Sigma42;
     tau2; 
     epsilon20; 
     kappa21; 
     kappa22; 
     r2; 
     h21; 
     a21; 
     gamma21; 
     gamma_z21; 
     vartheta21; 
     mu21; 
     h22; 
     a22; 
     gamma22; 
     gamma_z22; 
     vartheta22; 
     mu22;
     Sigma21;
     Sigma22;];
 

 
 %初值%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
w110=zeros(N,1); 
w120=zeros(N,1); 
x110 = 0.5;
x120 = 0.1;
alpha120c = 0.1;
sigmahat120 = 0.1;
hatepsilon_yu110 = 0.1;
hatepsilon_yu120 = 0.1;
z11F0 = 0.1;
z12F0 = 0.1;
 eta10 = 0.1;

 w310=zeros(N,1); 
w320=zeros(N,1); 
x310 = 0.5;
x320 = 0.1;
alpha320c = 0.1;
sigmahat320 = 0.1;
hatepsilon_yu310 = 0.1;
hatepsilon_yu320 = 0.1;
z31F0 = 0.1;
z32F0 = 0.1;
 eta30 = 0.1;
 
 w410=zeros(N,1); 
w420=zeros(N,1); 
x410 = -0.5;
x420 = 0.1;
alpha420c = 0.1;
sigmahat420 = 0.1;
hatepsilon_yu410 = 0.1;
hatepsilon_yu420 = 0.1;
z41F0 = 0.1;
z42F0 = 0.1;
 eta40 = 0.1;
 
 w210=zeros(N,1); 
w220=zeros(N,1); 
x210 = -0.5;
x220 = 0.1;
alpha220c = 0.1;
sigmahat220 = 0.1;
hatepsilon_yu210 = 0.1;
hatepsilon_yu220 = 0.1;
z21F0 = 0.1;
z22F0 = 0.1;
 eta20 = 0.1;
 
 z0 = [x110; x120; alpha120c; sigmahat120; hatepsilon_yu110; hatepsilon_yu120; z11F0; z12F0; eta10; w110; w120;...
       x310; x320; alpha320c; sigmahat320; hatepsilon_yu310; hatepsilon_yu320; z31F0; z32F0; eta30; w310; w320;...
       x410; x420; alpha420c; sigmahat420; hatepsilon_yu410; hatepsilon_yu420; z41F0; z42F0; eta40; w410; w420;...
       x210; x220; alpha220c; sigmahat220; hatepsilon_yu210; hatepsilon_yu220; z21F0; z22F0; eta20; w210; w220];
   
tic;
for kk=1:1





T = 10;
Ts = 0.01;  % 采样周期，对应 100Hz
tspan = 0:Ts:T;

[t, z] = ode15s(@tryhan63, tspan, z0, [], K);
end
toc;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 重新计算所有中间变量以便画图
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
len = length(t);

% 智能体1的变量
x11 = zeros(len,1);
x12 = zeros(len,1);
alpha12c = zeros(len,1);
sigmahat12 = zeros(len,1);
hatepsilon_yu11 = zeros(len,1);
hatepsilon_yu12 = zeros(len,1);
z11F = zeros(len,1);
z12F = zeros(len,1);
eta1 = zeros(len,1);
w11 = zeros(N, len);
w12 = zeros(N, len);

% 智能体3的变量
x31 = zeros(len,1);
x32 = zeros(len,1);
alpha32c = zeros(len,1);
sigmahat32 = zeros(len,1);
hatepsilon_yu31 = zeros(len,1);
hatepsilon_yu32 = zeros(len,1);
z31F = zeros(len,1);
z32F = zeros(len,1);
eta3 = zeros(len,1);
w31 = zeros(N, len);
w32 = zeros(N, len);

% 智能体4的变量
x41 = zeros(len,1);
x42 = zeros(len,1);
alpha42c = zeros(len,1);
sigmahat42 = zeros(len,1);
hatepsilon_yu41 = zeros(len,1);
hatepsilon_yu42 = zeros(len,1);
z41F = zeros(len,1);
z42F = zeros(len,1);
eta4 = zeros(len,1);
w41 = zeros(N, len);
w42 = zeros(N, len);

% 智能体2的变量
x21 = zeros(len,1);
x22 = zeros(len,1);
alpha22c = zeros(len,1);
sigmahat22 = zeros(len,1);
hatepsilon_yu21 = zeros(len,1);
hatepsilon_yu22 = zeros(len,1);
z21F = zeros(len,1);
z22F = zeros(len,1);
eta2 = zeros(len,1);
w21 = zeros(N, len);
w22 = zeros(N, len);

% 参考信号
x1d = zeros(len,1);
dx1d = zeros(len,1);
ddx1d = zeros(len,1);
x3d = zeros(len,1);
dx3d = zeros(len,1);
ddx3d = zeros(len,1);
x4d = zeros(len,1);
dx4d = zeros(len,1);
ddx4d = zeros(len,1);
x2d = zeros(len,1);
dx2d = zeros(len,1);

% 误差变量
E11 = zeros(len,1);
E31 = zeros(len,1);
E41 = zeros(len,1);
E21 = zeros(len,1);

% TPP相关变量
varpi = zeros(len,1);
rho = zeros(len,1);
drho = zeros(len,1);

% 智能体1的TPP边界
ed1 = zeros(len,1);
eu1 = zeros(len,1);
ded1 = zeros(len,1);
deu1 = zeros(len,1);
Delta11 = zeros(len,1);
Delta1d = zeros(len,1);
Delta1u = zeros(len,1);
Delta12 = zeros(len,1);
z11 = zeros(len,1);

% 智能体3的TPP边界
ed3 = zeros(len,1);
eu3 = zeros(len,1);
ded3 = zeros(len,1);
deu3 = zeros(len,1);
Delta31 = zeros(len,1);
Delta3d = zeros(len,1);
Delta3u = zeros(len,1);
Delta32 = zeros(len,1);
z31 = zeros(len,1);

% 智能体4的TPP边界
ed4 = zeros(len,1);
eu4 = zeros(len,1);
ded4 = zeros(len,1);
deu4 = zeros(len,1);
Delta41 = zeros(len,1);
Delta4d = zeros(len,1);
Delta4u = zeros(len,1);
Delta42 = zeros(len,1);
z41 = zeros(len,1);

% 智能体2的TPP边界
ed2 = zeros(len,1);
eu2 = zeros(len,1);
ded2 = zeros(len,1);
deu2 = zeros(len,1);
Delta21 = zeros(len,1);
Delta2d = zeros(len,1);
Delta2u = zeros(len,1);
Delta22 = zeros(len,1);
z21 = zeros(len,1);

% 神经网络基函数
S11m = zeros(N, len);
S12m = zeros(N, len);
S31m = zeros(N, len);
S32m = zeros(N, len);
S41m = zeros(N, len);
S42m = zeros(N, len);
S21m = zeros(N, len);
S22m = zeros(N, len);

% beta函数相关
beta = zeros(len,1);
dot_beta = zeros(len,1);

% 虚拟控制
alpha11 = zeros(len,1);
alpha31 = zeros(len,1);
alpha41 = zeros(len,1);
alpha21 = zeros(len,1);
dalpha12c = zeros(len,1);
dalpha32c = zeros(len,1);
dalpha42c = zeros(len,1);
dalpha22c = zeros(len,1);
z12 = zeros(len,1);
z32 = zeros(len,1);
z42 = zeros(len,1);
z22 = zeros(len,1);
alpha12 = zeros(len,1);
alpha32 = zeros(len,1);
alpha42 = zeros(len,1);
alpha22 = zeros(len,1);

% 事件触发相关变量（智能体1）
m1 = zeros(len,1);
rou1 = zeros(len,1);
lambda1 = zeros(len,1);
varsigma1 = zeros(len,1);
u1_cont = zeros(len,1); % 连续信号
yu1 = zeros(len,1);    % 阈值
w1z = zeros(len,1);    % 实际控制输入

% 事件触发相关变量（智能体3）
m3 = zeros(len,1);
rou3 = zeros(len,1);
lambda3 = zeros(len,1);
varsigma3 = zeros(len,1);
u3_cont = zeros(len,1); % 连续信号
yu3 = zeros(len,1);    % 阈值
w3z = zeros(len,1);    % 实际控制输入

% 事件触发相关变量（智能体4）
m4 = zeros(len,1);
rou4 = zeros(len,1);
lambda4 = zeros(len,1);
varsigma4 = zeros(len,1);
u4_cont = zeros(len,1); % 连续信号
yu4 = zeros(len,1);    % 阈值
w4z = zeros(len,1);    % 实际控制输入

% 事件触发相关变量（智能体2）
m2 = zeros(len,1);
rou2 = zeros(len,1);
lambda2 = zeros(len,1);
varsigma2 = zeros(len,1);
u2_cont = zeros(len,1); % 连续信号
yu2 = zeros(len,1);    % 阈值
w2z = zeros(len,1);    % 实际控制输入

% 系统导数
dx11 = zeros(len,1);
dx12 = zeros(len,1);
dx31 = zeros(len,1);
dx32 = zeros(len,1);
dx41 = zeros(len,1);
dx42 = zeros(len,1);
dx21 = zeros(len,1);
dx22 = zeros(len,1);

% 自适应律导数
dsigmahat12 = zeros(len,1);
dsigmahat32 = zeros(len,1);
dsigmahat42 = zeros(len,1);
dsigmahat22 = zeros(len,1);
dw11 = zeros(N, len);
dw12 = zeros(N, len);
dw31 = zeros(N, len);
dw32 = zeros(N, len);
dw41 = zeros(N, len);
dw42 = zeros(N, len);
dw21 = zeros(N, len);
dw22 = zeros(N, len);

% 预测误差导数
dhatepsilon_yu11 = zeros(len,1);
dhatepsilon_yu12 = zeros(len,1);
dz11F = zeros(len,1);
dz12F = zeros(len,1);
dhatepsilon_yu31 = zeros(len,1);
dhatepsilon_yu32 = zeros(len,1);
dz31F = zeros(len,1);
dz32F = zeros(len,1);
dhatepsilon_yu41 = zeros(len,1);
dhatepsilon_yu42 = zeros(len,1);
dz41F = zeros(len,1);
dz42F = zeros(len,1);
dhatepsilon_yu21 = zeros(len,1);
dhatepsilon_yu22 = zeros(len,1);
dz21F = zeros(len,1);
dz22F = zeros(len,1);

% eta导数
deta1 = zeros(len,1);
deta3 = zeros(len,1);
deta4 = zeros(len,1);
deta2 = zeros(len,1);

% 实际非线性函数
f2_actual1 = zeros(len,1);  % 智能体1的f2
f2_actual3 = zeros(len,1);  % 智能体3的f2
f2_actual4 = zeros(len,1);  % 智能体4的f2
f2_actual2 = zeros(len,1);  % 智能体2的f2

% 神经网络输出
net_output11 = zeros(len,1);  % 智能体1的第一个神经网络
net_output12 = zeros(len,1);  % 智能体1的第二个神经网络
net_output31 = zeros(len,1);  % 智能体3的第一个神经网络
net_output32 = zeros(len,1);  % 智能体3的第二个神经网络
net_output41 = zeros(len,1);  % 智能体4的第一个神经网络
net_output42 = zeros(len,1);  % 智能体4的第二个神经网络
net_output21 = zeros(len,1);  % 智能体2的第一个神经网络
net_output22 = zeros(len,1);  % 智能体2的第二个神经网络

net_output12_without_comp = zeros(len,1);
net_output22_without_comp = zeros(len,1);
net_output32_without_comp = zeros(len,1);
net_output42_without_comp = zeros(len,1);

% 事件触发记录变量（重新初始化）
num1 = 0; rt1 = []; rtt1 = []; tk1 = 0;
num3 = 0; rt3 = []; rtt3 = []; tk3 = 0;
num4 = 0; rt4 = []; rtt4 = []; tk4 = 0;
num2 = 0; rt2 = []; rtt2 = []; tk2 = 0;



% 从解中提取状态
for i = 1:len
    % 智能体1
    x11(i) = z(i,1);
    x12(i) = z(i,2);
    alpha12c(i) = z(i,3);
    sigmahat12(i) = z(i,4);
    hatepsilon_yu11(i) = z(i,5);
    hatepsilon_yu12(i) = z(i,6);
    z11F(i) = z(i,7);
    z12F(i) = z(i,8);
    eta1(i) = z(i,9);
    
    % 提取智能体1的神经网络权重
    for j = 1:N
        w11(j,i) = z(i,9+j);
        w12(j,i) = z(i,N+9+j);
    end
    
    % 智能体3
    offset_agent3 = 10+2*N;  % 计算偏移量
    x31(i) = z(i,offset_agent3);
    x32(i) = z(i,offset_agent3+1);
    alpha32c(i) = z(i,offset_agent3+2);
    sigmahat32(i) = z(i,offset_agent3+3);
    hatepsilon_yu31(i) = z(i,offset_agent3+4);
    hatepsilon_yu32(i) = z(i,offset_agent3+5);
    z31F(i) = z(i,offset_agent3+6);
    z32F(i) = z(i,offset_agent3+7);
    eta3(i) = z(i,offset_agent3+8);
    
    % 提取智能体3的神经网络权重
    for j = 1:N
        w31(j,i) = z(i,offset_agent3+8+j);
        w32(j,i) = z(i,offset_agent3+8+N+j);
    end
    
    % 智能体4
    offset_agent4 = 19+4*N;  % 计算偏移量
    x41(i) = z(i,offset_agent4);
    x42(i) = z(i,offset_agent4+1);
    alpha42c(i) = z(i,offset_agent4+2);
    sigmahat42(i) = z(i,offset_agent4+3);
    hatepsilon_yu41(i) = z(i,offset_agent4+4);
    hatepsilon_yu42(i) = z(i,offset_agent4+5);
    z41F(i) = z(i,offset_agent4+6);
    z42F(i) = z(i,offset_agent4+7);
    eta4(i) = z(i,offset_agent4+8);
    
    % 提取智能体4的神经网络权重
    for j = 1:N
        w41(j,i) = z(i,offset_agent4+8+j);
        w42(j,i) = z(i,offset_agent4+8+N+j);
    end
    
    % 智能体2
    offset_agent2 = 28+6*N;  % 计算偏移量
    x21(i) = z(i,offset_agent2);
    x22(i) = z(i,offset_agent2+1);
    alpha22c(i) = z(i,offset_agent2+2);
    sigmahat22(i) = z(i,offset_agent2+3);
    hatepsilon_yu21(i) = z(i,offset_agent2+4);
    hatepsilon_yu22(i) = z(i,offset_agent2+5);
    z21F(i) = z(i,offset_agent2+6);
    z22F(i) = z(i,offset_agent2+7);
    eta2(i) = z(i,offset_agent2+8);
    
    % 提取智能体2的神经网络权重
    for j = 1:N
        w21(j,i) = z(i,offset_agent2+8+j);
        w22(j,i) = z(i,offset_agent2+8+N+j);
    end
end

% 重新计算所有变量
for ii = 1:len
    % 当前时间
    ti = t(ii);
    
    % 智能体1当前状态
    x11_ii = x11(ii);
    x12_ii = x12(ii);
    alpha12c_ii = alpha12c(ii);
    sigmahat12_ii = sigmahat12(ii);
    hatepsilon_yu11_ii = hatepsilon_yu11(ii);
    hatepsilon_yu12_ii = hatepsilon_yu12(ii);
    z11F_ii = z11F(ii);
    z12F_ii = z12F(ii);
    eta1_ii = eta1(ii);
    w11_ii = w11(:,ii);
    w12_ii = w12(:,ii);
    
    % 智能体3当前状态
    x31_ii = x31(ii);
    x32_ii = x32(ii);
    alpha32c_ii = alpha32c(ii);
    sigmahat32_ii = sigmahat32(ii);
    hatepsilon_yu31_ii = hatepsilon_yu31(ii);
    hatepsilon_yu32_ii = hatepsilon_yu32(ii);
    z31F_ii = z31F(ii);
    z32F_ii = z32F(ii);
    eta3_ii = eta3(ii);
    w31_ii = w31(:,ii);
    w32_ii = w32(:,ii);
    
    % 智能体4当前状态
    x41_ii = x41(ii);
    x42_ii = x42(ii);
    alpha42c_ii = alpha42c(ii);
    sigmahat42_ii = sigmahat42(ii);
    hatepsilon_yu41_ii = hatepsilon_yu41(ii);
    hatepsilon_yu42_ii = hatepsilon_yu42(ii);
    z41F_ii = z41F(ii);
    z42F_ii = z42F(ii);
    eta4_ii = eta4(ii);
    w41_ii = w41(:,ii);
    w42_ii = w42(:,ii);
    
    % 智能体2当前状态
    x21_ii = x21(ii);
    x22_ii = x22(ii);
    alpha22c_ii = alpha22c(ii);
    sigmahat22_ii = sigmahat22(ii);
    hatepsilon_yu21_ii = hatepsilon_yu21(ii);
    hatepsilon_yu22_ii = hatepsilon_yu22(ii);
    z21F_ii = z21F(ii);
    z22F_ii = z22F(ii);
    eta2_ii = eta2(ii);
    w21_ii = w21(:,ii);
    w22_ii = w22(:,ii);
    
    % 参考信号
    x1d(ii) = -sin(ti);
    dx1d(ii) = -cos(ti);
    ddx1d(ii) = sin(ti);
    
    x3d(ii) = sin(ti);
    dx3d(ii) = cos(ti);
    ddx3d(ii) = -sin(ti);
    
    
    
    x2d(ii) = x11_ii;  % 2号智能体跟踪1号智能体
    dx2d(ii) = x12_ii;
    
    x4d(ii) = x31_ii;  % 4号智能体跟踪3号智能体
    dx4d(ii) = x32_ii;
    
    % 误差
    E11(ii) = x11_ii - x1d(ii);
    E31(ii) = x31_ii - x3d(ii);
    E41(ii) = x41_ii - x4d(ii);
    E21(ii) = x21_ii - x2d(ii);
    
    % TPP - 使用tf而不是Tstar
    varpi(ii) = -(upsilon * tf * ti) / (tf - ti);
    
    if ti >= 0 && ti < tf
        rho(ii) = (rho0 - rhotf) * exp(varpi(ii)) + rhotf;
    else
        rho(ii) = rhotf;
    end
    
    if ti >= 0 && ti < tf
        drho(ii) = -(rho0 - rhotf) * exp(varpi(ii)) * upsilon * tf^2 / ((tf - ti)^2);
    else
        drho(ii) = 0;
    end
    
    % 智能体1的TPP边界（初始状态大于0）
    ed1(ii) = (deltal - 1) * rho(ii) + rhotf * 1;
    eu1(ii) = (deltau + 1) * rho(ii) - rhotf * 1;
    ded1(ii) = (deltal - 1) * drho(ii);
    deu1(ii) = (deltau + 1) * drho(ii);
    Delta11(ii) = (eu1(ii) + ed1(ii)) / ((ed1(ii) + E11(ii)) * (eu1(ii) - E11(ii)));
    Delta1d(ii) = 1 / (ed1(ii) + E11(ii));
    Delta1u(ii) = -1 / (eu1(ii) - E11(ii));
    Delta12(ii) = Delta1d(ii) * ded1(ii) + Delta1u(ii) * deu1(ii) - Delta11(ii) * dx1d(ii);
    z11(ii) = log((ed1(ii) + E11(ii)) / (eu1(ii) - E11(ii)));
    
    % 智能体3的TPP边界（初始状态大于0）
    ed3(ii) = (deltal - 1) * rho(ii) + rhotf * 1;
    eu3(ii) = (deltau + 1) * rho(ii) - rhotf * 1;
    ded3(ii) = (deltal - 1) * drho(ii);
    deu3(ii) = (deltau + 1) * drho(ii);
    Delta31(ii) = (eu3(ii) + ed3(ii)) / ((ed3(ii) + E31(ii)) * (eu3(ii) - E31(ii)));
    Delta3d(ii) = 1 / (ed3(ii) + E31(ii));
    Delta3u(ii) = -1 / (eu3(ii) - E31(ii));
    Delta32(ii) = Delta3d(ii) * ded3(ii) + Delta3u(ii) * deu3(ii) - Delta31(ii) * dx3d(ii);
    z31(ii) = log((ed3(ii) + E31(ii)) / (eu3(ii) - E31(ii)));
    
    % 智能体4的TPP边界（初始状态小于0）
    ed4(ii) = (deltal - (-1)) * rho(ii) + rhotf * (-1);
    eu4(ii) = (deltau + (-1)) * rho(ii) - rhotf * (-1);
    ded4(ii) = (deltal - (-1)) * drho(ii);
    deu4(ii) = (deltau + (-1)) * drho(ii);
%     ed4(ii) = deltal * rhotf;
%     eu4(ii) = deltau * rhotf;
%     ded4(ii) = 0;
%     deu4(ii) = 0;
    Delta41(ii) = (eu4(ii) + ed4(ii)) / ((ed4(ii) + E41(ii)) * (eu4(ii) - E41(ii)));
    Delta4d(ii) = 1 / (ed4(ii) + E41(ii));
    Delta4u(ii) = -1 / (eu4(ii) - E41(ii));
    Delta42(ii) = Delta4d(ii) * ded4(ii) + Delta4u(ii) * deu4(ii) - Delta41(ii) * dx4d(ii);
    z41(ii) = log((ed4(ii) + E41(ii)) / (eu4(ii) - E41(ii)));
    
    % 智能体2的TPP边界（初始状态小于0）
    ed2(ii) = (deltal - (-1)) * rho(ii) + rhotf * (-1);
    eu2(ii) = (deltau + (-1)) * rho(ii) - rhotf * (-1);
    ded2(ii) = (deltal - (-1)) * drho(ii);
    deu2(ii) = (deltau + (-1)) * drho(ii);
    Delta21(ii) = (eu2(ii) + ed2(ii)) / ((ed2(ii) + E21(ii)) * (eu2(ii) - E21(ii)));
    Delta2d(ii) = 1 / (ed2(ii) + E21(ii));
    Delta2u(ii) = -1 / (eu2(ii) - E21(ii));
    Delta22(ii) = Delta2d(ii) * ded2(ii) + Delta2u(ii) * deu2(ii) - Delta21(ii) * dx2d(ii);
    z21(ii) = log((ed2(ii) + E21(ii)) / (eu2(ii) - E21(ii)));
    
    % 神经网络基函数
    for j = 1:N
        S11m(j,ii) = exp(-(sum(([x11_ii, x12_ii]' - C(:,j)).^2)) / (sigma^2));
        S12m(j,ii) = exp(-(sum(([x11_ii, x12_ii]' - C(:,j)).^2)) / (sigma^2));
        S31m(j,ii) = exp(-(sum(([x31_ii, x32_ii]' - C(:,j)).^2)) / (sigma^2));
        S32m(j,ii) = exp(-(sum(([x31_ii, x32_ii]' - C(:,j)).^2)) / (sigma^2));
        S41m(j,ii) = exp(-(sum(([x41_ii, x42_ii]' - C(:,j)).^2)) / (sigma^2));
        S42m(j,ii) = exp(-(sum(([x41_ii, x42_ii]' - C(:,j)).^2)) / (sigma^2));
        S21m(j,ii) = exp(-(sum(([x21_ii, x22_ii]' - C(:,j)).^2)) / (sigma^2));
        S22m(j,ii) = exp(-(sum(([x21_ii, x22_ii]' - C(:,j)).^2)) / (sigma^2));
    end
    
    % beta(t) - 使用Tstar
    if ti >= 0 && ti < Tstar
        beta(ii) = ((Tstar - ti) / Tstar)^2 + p;
    else
        beta(ii) = p;
    end
    
    if ti >= 0 && ti < Tstar
        dot_beta(ii) = -2 * (Tstar - ti) / Tstar^2;
    else
        dot_beta(ii) = 0;
    end
    
    % 虚拟控制 - 智能体1
    alpha11(ii) = -(h11 - dot_beta(ii) / (2 * beta(ii))) * z11(ii) / Delta11(ii) - Delta12(ii) / Delta11(ii) ...
        - w11_ii' * S11m(:,ii) - hatepsilon_yu11_ii - (a11^2 * z11(ii)) / 2;
    
    % 虚拟控制 - 智能体3
    alpha31(ii) = -(h31 - dot_beta(ii) / (2 * beta(ii))) * z31(ii) / Delta31(ii) - Delta32(ii) / Delta31(ii) ...
        - w31_ii' * S31m(:,ii) - hatepsilon_yu31_ii - (a31^2 * z31(ii)) / 2;
    
    % 虚拟控制 - 智能体4
    alpha41(ii) = -(h41 - dot_beta(ii) / (2 * beta(ii))) * z41(ii) / Delta41(ii) - Delta42(ii) / Delta41(ii) ...
        - w41_ii' * S41m(:,ii) - hatepsilon_yu41_ii - (a41^2 * z41(ii)) / 2;
    
    % 虚拟控制 - 智能体2
    alpha21(ii) = -(h21 - dot_beta(ii) / (2 * beta(ii))) * z21(ii) / Delta21(ii) - Delta22(ii) / Delta21(ii) ...
        - w21_ii' * S21m(:,ii) - hatepsilon_yu21_ii - (a21^2 * z21(ii)) / 2;
    
    % 滤波器 - 智能体1
    dalpha12c(ii) = 1 / tau1 * (-((kappa11 - tau1 * dot_beta(ii) / (2 * beta(ii))) * (alpha12c_ii - alpha11(ii))) ...
        - (tau1 * sigmahat12_ii^2 * (alpha12c_ii - alpha11(ii))) / sqrt(sigmahat12_ii^2 * (alpha12c_ii - alpha11(ii))^2 + epsilon10^2));
    
    % 滤波器 - 智能体3
    dalpha32c(ii) = 1 / tau3 * (-((kappa31 - tau3 * dot_beta(ii) / (2 * beta(ii))) * (alpha32c_ii - alpha31(ii))) ...
        - (tau3 * sigmahat32_ii^2 * (alpha32c_ii - alpha31(ii))) / sqrt(sigmahat32_ii^2 * (alpha32c_ii - alpha31(ii))^2 + epsilon30^2));
    
    % 滤波器 - 智能体4
    dalpha42c(ii) = 1 / tau4 * (-((kappa41 - tau4 * dot_beta(ii) / (2 * beta(ii))) * (alpha42c_ii - alpha41(ii))) ...
        - (tau4 * sigmahat42_ii^2 * (alpha42c_ii - alpha41(ii))) / sqrt(sigmahat42_ii^2 * (alpha42c_ii - alpha41(ii))^2 + epsilon40^2));
    
    % 滤波器 - 智能体2
    dalpha22c(ii) = 1 / tau2 * (-((kappa21 - tau2 * dot_beta(ii) / (2 * beta(ii))) * (alpha22c_ii - alpha21(ii))) ...
        - (tau2 * sigmahat22_ii^2 * (alpha22c_ii - alpha21(ii))) / sqrt(sigmahat22_ii^2 * (alpha22c_ii - alpha21(ii))^2 + epsilon20^2));
    
    z12(ii) = x12_ii - alpha12c_ii;
    z32(ii) = x32_ii - alpha32c_ii;
    z42(ii) = x42_ii - alpha42c_ii;
    z22(ii) = x22_ii - alpha22c_ii;
    
    % 基础虚拟控制输入 - 智能体1
    alpha12(ii) = - (h12 - dot_beta(ii) / (2 * beta(ii))) * z12(ii) - w12_ii' * S12m(:,ii) ...
        - hatepsilon_yu12_ii - (a12^2 * z12(ii)) / 2 + dalpha12c(ii) - Delta11(ii) * z11(ii);
    
    % 基础虚拟控制输入 - 智能体3
    alpha32(ii) = - (h32 - dot_beta(ii) / (2 * beta(ii))) * z32(ii) - w32_ii' * S32m(:,ii) ...
        - hatepsilon_yu32_ii - (a32^2 * z32(ii)) / 2 + dalpha32c(ii) - Delta31(ii) * z31(ii);
    
    % 基础虚拟控制输入 - 智能体4
    alpha42(ii) = - (h42 - dot_beta(ii) / (2 * beta(ii))) * z42(ii) - w42_ii' * S42m(:,ii) ...
        - hatepsilon_yu42_ii - (a42^2 * z42(ii)) / 2 + dalpha42c(ii) - Delta41(ii) * z41(ii);
    
    % 基础虚拟控制输入 - 智能体2
    alpha22(ii) = - (h22 - dot_beta(ii) / (2 * beta(ii))) * z22(ii) - w22_ii' * S22m(:,ii) ...
        - hatepsilon_yu22_ii - (a22^2 * z22(ii)) / 2 + dalpha22c(ii) - Delta21(ii) * z21(ii);
    
    % 事件触发相关计算 - 智能体1
    m1(ii) = exp(-z11(ii)^2 - a0);
    rou1(ii) = (0.07 * ti^2 + 1)^(-1);
    lambda1(ii) = 1 / (abs(z11(ii)) + abs(z12(ii)) + kappa0);
    varsigma1(ii) = (ne1 * eta1_ii + ne2 * lambda1(ii) + ne3) / (1 - m1(ii));
    
    % 事件触发相关计算 - 智能体3
    m3(ii) = exp(-z31(ii)^2 - a0);
    rou3(ii) = (0.07 * ti^2 + 1)^(-1);
    lambda3(ii) = 1 / (abs(z31(ii)) + abs(z32(ii)) + kappa0);
    varsigma3(ii) = (ne1 * eta3_ii + ne2 * lambda3(ii) + ne3) / (1 - m3(ii));
    
    % 事件触发相关计算 - 智能体4
    m4(ii) = exp(-z41(ii)^2 - a0);
    rou4(ii) = (0.07 * ti^2 + 1)^(-1);
    lambda4(ii) = 1 / (abs(z41(ii)) + abs(z42(ii)) + kappa0);
    varsigma4(ii) = (ne1 * eta4_ii + ne2 * lambda4(ii) + ne3) / (1 - m4(ii));
    
    % 事件触发相关计算 - 智能体2
    m2(ii) = exp(-z21(ii)^2 - a0);
    rou2(ii) = (0.07 * ti^2 + 1)^(-1);
    lambda2(ii) = 1 / (abs(z21(ii)) + abs(z22(ii)) + kappa0);
    varsigma2(ii) = (ne1 * eta2_ii + ne2 * lambda2(ii) + ne3) / (1 - m2(ii));
    
    % 连续信号控制输入 - 智能体1
    u1_cont(ii) = - (1 + m1(ii)) * (tanh(z12(ii) * alpha12(ii) / rou1(ii)) * alpha12(ii) ...
        + tanh(z12(ii) * varsigma1(ii) / rou1(ii)) * varsigma1(ii));
    
    % 连续信号控制输入 - 智能体3
    u3_cont(ii) = - (1 + m3(ii)) * (tanh(z32(ii) * alpha32(ii) / rou3(ii)) * alpha32(ii) ...
        + tanh(z32(ii) * varsigma3(ii) / rou3(ii)) * varsigma3(ii));
    
    % 连续信号控制输入 - 智能体4
    u4_cont(ii) = - (1 + m4(ii)) * (tanh(z42(ii) * alpha42(ii) / rou4(ii)) * alpha42(ii) ...
        + tanh(z42(ii) * varsigma4(ii) / rou4(ii)) * varsigma4(ii));
    
    % 连续信号控制输入 - 智能体2
    u2_cont(ii) = - (1 + m2(ii)) * (tanh(z22(ii) * alpha22(ii) / rou2(ii)) * alpha22(ii) ...
        + tanh(z22(ii) * varsigma2(ii) / rou2(ii)) * varsigma2(ii));
    
    % 事件触发阈值 - 智能体1
%     if ii == 1
%         yu1(ii) = m1(ii) * abs(0) + ne1 * eta1_ii + ne2 * lambda1(ii) + ne3;
%     else
%         yu1(ii) = m1(ii) * abs(w1z(ii-1)) + ne1 * eta1_ii + ne2 * lambda1(ii) + ne3;
%     end
    
    if ii == 1
        yu1(ii) = m1(ii) * abs(0) + ne1 * eta1_ii + ne2 * lambda1(ii) + ne3;
    else
        yu1(ii) = m1(ii) * abs(w1z(ii-1)) + ne1 * eta1_ii + ne2 * lambda1(ii) + ne3;
    end
    
    % 事件触发阈值 - 智能体3
    if ii == 1
        yu3(ii) = m3(ii) * abs(0) + ne1 * eta3_ii + ne2 * lambda3(ii) + ne3;
    else
        yu3(ii) = m3(ii) * abs(w3z(ii-1)) + ne1 * eta3_ii + ne2 * lambda3(ii) + ne3;
    end
    
    % 事件触发阈值 - 智能体4
    if ii == 1
        yu4(ii) = m4(ii) * abs(0) + ne1 * eta4_ii + ne2 * lambda4(ii) + ne3;
    else
        yu4(ii) = m4(ii) * abs(w4z(ii-1)) + ne1 * eta4_ii + ne2 * lambda4(ii) + ne3;
    end
    
    % 事件触发阈值 - 智能体2
    if ii == 1
        yu2(ii) = m2(ii) * abs(0) + ne1 * eta2_ii + ne2 * lambda2(ii) + ne3;
    else
        yu2(ii) = m2(ii) * abs(w2z(ii-1)) + ne1 * eta2_ii + ne2 * lambda2(ii) + ne3;
    end
    
    % 事件触发逻辑 - 智能体1
if ii == 1
    % 初始时刻总是触发
    w1z(ii) = u1_cont(ii);
    num1 = 1;
    rt1 = t(ii);
    rtt1 = t(ii);
    tk1 = t(ii);
else
    % 检查触发条件
    trigger_condition = abs(u1_cont(ii) - w1z(ii-1)) >= yu1(ii);
    
    if trigger_condition
        % 触发：更新控制值
        w1z(ii) = u1_cont(ii);
        
        % 记录触发事件
        num1 = num1 + 1;
        rt1 = [rt1; t(ii)];
        if isempty(tk1)
            rtt1 = [rtt1; t(ii)];
        else
            rtt1 = [rtt1; t(ii) - tk1];
        end
        tk1 = t(ii);
    else
        % 不触发：保持上次值
        w1z(ii) = w1z(ii-1);
    end
end
    
    % 事件触发逻辑 - 智能体2
if ii == 1
    % 初始时刻总是触发
    w2z(ii) = u2_cont(ii);
    num2 = 1;
    rt2 = t(ii);
    rtt2 = t(ii);
    tk2 = t(ii);
else
    % 检查触发条件
    trigger_condition = abs(u2_cont(ii) - w2z(ii-1)) >= yu2(ii);
    
    if trigger_condition
        % 触发：更新控制值
        w2z(ii) = u2_cont(ii);
        
        % 记录触发事件
        num2 = num2 + 1;
        rt2 = [rt2; t(ii)];
        if isempty(tk2)
            rtt2 = [rtt2; t(ii)];
        else
            rtt2 = [rtt2; t(ii) - tk2];
        end
        tk2 = t(ii);
    else
        % 不触发：保持上次值
        w2z(ii) = w2z(ii-1);
    end
end

% 事件触发逻辑 - 智能体3
if ii == 1
    % 初始时刻总是触发
    w3z(ii) = u3_cont(ii);
    num3 = 1;
    rt3 = t(ii);
    rtt3 = t(ii);
    tk3 = t(ii);
else
    % 检查触发条件
    trigger_condition = abs(u3_cont(ii) - w3z(ii-1)) >= yu3(ii);
    
    if trigger_condition
        % 触发：更新控制值
        w3z(ii) = u3_cont(ii);
        
        % 记录触发事件
        num3 = num3 + 1;
        rt3 = [rt3; t(ii)];
        if isempty(tk3)
            rtt3 = [rtt3; t(ii)];
        else
            rtt3 = [rtt3; t(ii) - tk3];
        end
        tk3 = t(ii);
    else
        % 不触发：保持上次值
        w3z(ii) = w3z(ii-1);
    end
end

% 事件触发逻辑 - 智能体4
if ii == 1
    % 初始时刻总是触发
    w4z(ii) = u4_cont(ii);
    num4 = 1;
    rt4 = t(ii);
    rtt4 = t(ii);
    tk4 = t(ii);
else
    % 检查触发条件
    trigger_condition = abs(u4_cont(ii) - w4z(ii-1)) >= yu4(ii);
    
    if trigger_condition
        % 触发：更新控制值
        w4z(ii) = u4_cont(ii);
        
        % 记录触发事件
        num4 = num4 + 1;
        rt4 = [rt4; t(ii)];
        if isempty(tk4)
            rtt4 = [rtt4; t(ii)];
        else
            rtt4 = [rtt4; t(ii) - tk4];
        end
        tk4 = t(ii);
    else
        % 不触发：保持上次值
        w4z(ii) = w4z(ii-1);
    end
end
    
    % 系统导数 - 使用实际控制输入
    dx11(ii) = x12_ii;
    dx12(ii) = -4.9 * sin(x11_ii) - x12_ii + w1z(ii);
    
    dx31(ii) = x32_ii;
    dx32(ii) = -4.9 * sin(x31_ii) - x32_ii + w3z(ii);
    
    dx41(ii) = x42_ii;
    dx42(ii) = -4.9 * sin(x41_ii) - x42_ii + w4z(ii);
    
    dx21(ii) = x22_ii;
    dx22(ii) = -4.9 * sin(x21_ii) - x22_ii + w2z(ii);
    
    % 自适应律
    dsigmahat12(ii) = -(kappa12 - dot_beta(ii) / beta(ii)) * sigmahat12_ii + r1 * abs(alpha12c_ii - alpha11(ii));
    dsigmahat32(ii) = -(kappa32 - dot_beta(ii) / beta(ii)) * sigmahat32_ii + r3 * abs(alpha32c_ii - alpha31(ii));
    dsigmahat42(ii) = -(kappa42 - dot_beta(ii) / beta(ii)) * sigmahat42_ii + r4 * abs(alpha42c_ii - alpha41(ii));
    dsigmahat22(ii) = -(kappa22 - dot_beta(ii) / beta(ii)) * sigmahat22_ii + r2 * abs(alpha22c_ii - alpha21(ii));
    
    % 神经网络权重更新
    dw11(:,ii) = (1 / gamma11) * (Delta11(ii) * z11(ii) + gamma_z11 * z11F_ii) * S11m(:,ii) ...
        - (vartheta11 - dot_beta(ii) / beta(ii)) * w11_ii;
    dw12(:,ii) = (1 / gamma12) * (z12(ii) + gamma_z12 * z12F_ii) * S12m(:,ii) ...
        - (vartheta12 - dot_beta(ii) / beta(ii)) * w12_ii;
    
    dw31(:,ii) = (1 / gamma31) * (Delta31(ii) * z31(ii) + gamma_z31 * z31F_ii) * S31m(:,ii) ...
        - (vartheta31 - dot_beta(ii) / beta(ii)) * w31_ii;
    dw32(:,ii) = (1 / gamma32) * (z32(ii) + gamma_z32 * z32F_ii) * S32m(:,ii) ...
        - (vartheta32 - dot_beta(ii) / beta(ii)) * w32_ii;
    
    dw41(:,ii) = (1 / gamma41) * (Delta41(ii) * z41(ii) + gamma_z41 * z41F_ii) * S41m(:,ii) ...
        - (vartheta41 - dot_beta(ii) / beta(ii)) * w41_ii;
    dw42(:,ii) = (1 / gamma42) * (z42(ii) + gamma_z42 * z42F_ii) * S42m(:,ii) ...
        - (vartheta42 - dot_beta(ii) / beta(ii)) * w42_ii;
    
    dw21(:,ii) = (1 / gamma21) * (Delta21(ii) * z21(ii) + gamma_z21 * z21F_ii) * S21m(:,ii) ...
        - (vartheta21 - dot_beta(ii) / beta(ii)) * w21_ii;
    dw22(:,ii) = (1 / gamma22) * (z22(ii) + gamma_z22 * z22F_ii) * S22m(:,ii) ...
        - (vartheta22 - dot_beta(ii) / beta(ii)) * w22_ii;
    
    % 预测误差
    dhatepsilon_yu11(ii) = Sigma11 * (dx11(ii) - w11_ii' * S11m(:,ii) - hatepsilon_yu11_ii - x12_ii ...
        + Sigma11^(-1) * (Delta11(ii) * z11(ii) + gamma_z11 * z11F_ii));
    dz11F(ii) = dx11(ii) - x12_ii - w11_ii' * S11m(:,ii) - hatepsilon_yu11_ii ...
        - (mu11 - dot_beta(ii) / (2 * beta(ii))) * z11F_ii;
    
    dhatepsilon_yu31(ii) = Sigma31 * (dx31(ii) - w31_ii' * S31m(:,ii) - hatepsilon_yu31_ii - x32_ii ...
        + Sigma31^(-1) * (Delta31(ii) * z31(ii) + gamma_z31 * z31F_ii));
    dz31F(ii) = dx31(ii) - x32_ii - w31_ii' * S31m(:,ii) - hatepsilon_yu31_ii ...
        - (mu31 - dot_beta(ii) / (2 * beta(ii))) * z31F_ii;
    
    dhatepsilon_yu41(ii) = Sigma41 * (dx41(ii) - w41_ii' * S41m(:,ii) - hatepsilon_yu41_ii - x42_ii ...
        + Sigma41^(-1) * (Delta41(ii) * z41(ii) + gamma_z41 * z41F_ii));
    dz41F(ii) = dx41(ii) - x42_ii - w41_ii' * S41m(:,ii) - hatepsilon_yu41_ii ...
        - (mu41 - dot_beta(ii) / (2 * beta(ii))) * z41F_ii;
    
    dhatepsilon_yu21(ii) = Sigma21 * (dx21(ii) - w21_ii' * S21m(:,ii) - hatepsilon_yu21_ii - x22_ii ...
        + Sigma21^(-1) * (Delta21(ii) * z21(ii) + gamma_z21 * z21F_ii));
    dz21F(ii) = dx21(ii) - x22_ii - w21_ii' * S21m(:,ii) - hatepsilon_yu21_ii ...
        - (mu21 - dot_beta(ii) / (2 * beta(ii))) * z21F_ii;
    
    dhatepsilon_yu12(ii) = Sigma12 * (dx12(ii) - w12_ii' * S12m(:,ii) - hatepsilon_yu12_ii - w1z(ii) ...
        + Sigma12^(-1) * (z12(ii) + gamma_z12 * z12F_ii));
    dz12F(ii) = dx12(ii) - w1z(ii) - w12_ii' * S12m(:,ii) - hatepsilon_yu12_ii ...
        - (mu12 - dot_beta(ii) / (2 * beta(ii))) * z12F_ii;
    
    dhatepsilon_yu32(ii) = Sigma32 * (dx32(ii) - w32_ii' * S32m(:,ii) - hatepsilon_yu32_ii - w3z(ii) ...
        + Sigma32^(-1) * (z32(ii) + gamma_z32 * z32F_ii));
    dz32F(ii) = dx32(ii) - w3z(ii) - w32_ii' * S32m(:,ii) - hatepsilon_yu32_ii ...
        - (mu32 - dot_beta(ii) / (2 * beta(ii))) * z32F_ii;
    
    dhatepsilon_yu42(ii) = Sigma42 * (dx42(ii) - w42_ii' * S42m(:,ii) - hatepsilon_yu42_ii - w4z(ii) ...
        + Sigma42^(-1) * (z42(ii) + gamma_z42 * z42F_ii));
    dz42F(ii) = dx42(ii) - w4z(ii) - w42_ii' * S42m(:,ii) - hatepsilon_yu42_ii ...
        - (mu42 - dot_beta(ii) / (2 * beta(ii))) * z42F_ii;
    
    dhatepsilon_yu22(ii) = Sigma22 * (dx22(ii) - w22_ii' * S22m(:,ii) - hatepsilon_yu22_ii - w2z(ii) ...
        + Sigma22^(-1) * (z22(ii) + gamma_z22 * z22F_ii));
    dz22F(ii) = dx22(ii) - w2z(ii) - w22_ii' * S22m(:,ii) - hatepsilon_yu22_ii ...
        - (mu22 - dot_beta(ii) / (2 * beta(ii))) * z22F_ii;
    
    % 更新eta的动态
    if ii == 1
        deta1(ii) = -ne0 * eta1_ii - abs(u1_cont(ii) - 0) + m1(ii) * abs(0) + ne2 * lambda1(ii) + ne3;
        deta3(ii) = -ne0 * eta3_ii - abs(u3_cont(ii) - 0) + m3(ii) * abs(0) + ne2 * lambda3(ii) + ne3;
        deta4(ii) = -ne0 * eta4_ii - abs(u4_cont(ii) - 0) + m4(ii) * abs(0) + ne2 * lambda4(ii) + ne3;
        deta2(ii) = -ne0 * eta2_ii - abs(u2_cont(ii) - 0) + m2(ii) * abs(0) + ne2 * lambda2(ii) + ne3;
    else
        deta1(ii) = -ne0 * eta1_ii - abs(u1_cont(ii) - w1z(ii-1)) + m1(ii) * abs(w1z(ii-1)) + ne2 * lambda1(ii) + ne3;
        deta3(ii) = -ne0 * eta3_ii - abs(u3_cont(ii) - w3z(ii-1)) + m3(ii) * abs(w3z(ii-1)) + ne2 * lambda3(ii) + ne3;
        deta4(ii) = -ne0 * eta4_ii - abs(u4_cont(ii) - w4z(ii-1)) + m4(ii) * abs(w4z(ii-1)) + ne2 * lambda4(ii) + ne3;
        deta2(ii) = -ne0 * eta2_ii - abs(u2_cont(ii) - w2z(ii-1)) + m2(ii) * abs(w2z(ii-1)) + ne2 * lambda2(ii) + ne3;
    end
    
    % 实际非线性函数值
    f2_actual1(ii) = -4.9 * sin(x11_ii) - x12_ii;
    f2_actual3(ii) = -4.9 * sin(x31_ii) - x32_ii;
    f2_actual4(ii) = -4.9 * sin(x41_ii) - x42_ii;
    f2_actual2(ii) = -4.9 * sin(x21_ii) - x22_ii;
    
    % 神经网络输出
    net_output11(ii) = w11_ii' * S11m(:,ii) + hatepsilon_yu11_ii;
    net_output12(ii) = w12_ii' * S12m(:,ii) + hatepsilon_yu12_ii;
    net_output31(ii) = w31_ii' * S31m(:,ii) + hatepsilon_yu31_ii;
    net_output32(ii) = w32_ii' * S32m(:,ii) + hatepsilon_yu32_ii;
    net_output41(ii) = w41_ii' * S41m(:,ii) + hatepsilon_yu41_ii;
    net_output42(ii) = w42_ii' * S42m(:,ii) + hatepsilon_yu42_ii;
    net_output21(ii) = w21_ii' * S21m(:,ii) + hatepsilon_yu21_ii;
    net_output22(ii) = w22_ii' * S22m(:,ii) + hatepsilon_yu22_ii;
    
    net_output12_without_comp(ii) = w12_ii' * S12m(:,ii);  
    net_output22_without_comp(ii) = w22_ii' * S22m(:,ii);  
    net_output32_without_comp(ii) = w32_ii' * S32m(:,ii);  
    net_output42_without_comp(ii) = w42_ii' * S42m(:,ii);  % 去掉hatepsilon_yu42
end

toc;

% 加段改字体的代码

figure(1);

plot(t, x11, 'b-', 'LineWidth', 1.5); hold on;
plot(t, x21, 'r--', 'LineWidth', 1.5);
plot(t, x31, 'g-.', 'LineWidth', 1.5);
plot(t, x41, 'c:', 'LineWidth', 1.5);
plot(t, x3d, 'm:', 'LineWidth', 1.5);
hold off;
xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
legend('$x_{1,1}$','$x_{2,1}$','$x_{3,1}$','$x_{4,1}$','$y_d$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

%print(figure(1), '1.eps', '-depsc');
print(figure(1), '1.png', '-dpng', '-r300');

% 图2: TPP效果图（包括E11，-ed1，eu1），上下边界
figure(2);

% 左上子图
subplot(2,2,1);
plot(t, E11, 'r-', 'LineWidth', 1.5); hold on;
plot(t, -ed1, 'b--', 'LineWidth', 1.5);
plot(t, eu1, 'g-.', 'LineWidth', 1.5);
hold off;
xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
ylim([-1.5 1.5]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
hLeg1 = legend('$e_{1,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
set(hLeg1, 'FontSize', 9.6, 'Box', 'on');   % 字体缩小到80%
% 图例上移 0.046
pos1 = get(hLeg1, 'Position');
pos1(2) = pos1(2) + 0.015;
set(hLeg1, 'Position', pos1);

% 右上子图
subplot(2,2,2);
plot(t, E21, 'r-', 'LineWidth', 1.5); hold on;
plot(t, -ed2, 'b--', 'LineWidth', 1.5);
plot(t, eu2, 'g-.', 'LineWidth', 1.5);
hold off;
xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
ylim([-1.5 1.5]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
hLeg2 = legend('$e_{2,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'southeast');
set(hLeg2, 'FontSize', 9.6, 'Box', 'on');   % 字体缩小到80%
% 图例下移 0.018
pos2 = get(hLeg2, 'Position');
pos2(2) = pos2(2) + 0.01;
set(hLeg2, 'Position', pos2);

% 左下子图
subplot(2,2,3);
plot(t, E31, 'r-', 'LineWidth', 1.5); hold on;
plot(t, -ed3, 'b--', 'LineWidth', 1.5);
plot(t, eu3, 'g-.', 'LineWidth', 1.5);
hold off;
xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
ylim([-1.5 1.5]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
hLeg3 = legend('$e_{3,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
set(hLeg3, 'FontSize', 9.6, 'Box', 'on');   % 字体缩小到80%
% 图例上移 0.046
pos3 = get(hLeg3, 'Position');
pos3(2) = pos3(2) + 0.015;
set(hLeg3, 'Position', pos3);

% 右下子图
subplot(2,2,4);
plot(t, E41, 'r-', 'LineWidth', 1.5); hold on;
plot(t, -ed4, 'b--', 'LineWidth', 1.5);
plot(t, eu4, 'g-.', 'LineWidth', 1.5);
hold off;
xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
ylim([-1.5 1.5]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
hLeg4 = legend('$e_{4,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'southeast');
set(hLeg4, 'FontSize', 9.6, 'Box', 'on');   % 字体缩小到80%
% 图例下移 0.018
pos4 = get(hLeg4, 'Position');
pos4(2) = pos4(2) + 0.01;
set(hLeg4, 'Position', pos4);

%print(figure(2), '2.eps', '-depsc');
print(figure(2), '2.png', '-dpng', '-r300');

% 图3：控制输入
figure(3);
subplot(2,2,1);
plot(t, u1_cont, 'r-', 'LineWidth', 1.5); hold on;
plot(t, w1z, 'b--', 'LineWidth', 1.5);
xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
legend('$u_1(t)$','$\nu_1(t)$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
ylim([-150 150]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

axes('Position',[0.2 0.63 0.2 0.1]);
plot(t, u1_cont, 'r-', 'LineWidth', 1); hold on;
plot(t, w1z, 'b--', 'LineWidth', 1);
xlim([3 3.5]);
ylim([-20 20]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

subplot(2,2,2);
plot(t, u2_cont, 'r-', 'LineWidth', 1.5); hold on;
plot(t, w2z, 'b--', 'LineWidth', 1.5);
xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
legend('$u_2(t)$','$\nu_2(t)$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
ylim([-600 600]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

axes('Position',[0.65 0.63 0.2 0.1]);
plot(t, u2_cont, 'r-', 'LineWidth', 1); hold on;
plot(t, w2z, 'b--', 'LineWidth', 1);
xlim([3 3.5]);
ylim([-40 40]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

subplot(2,2,3);
plot(t, u3_cont, 'r-', 'LineWidth', 1.5); hold on;
plot(t, w3z, 'b--', 'LineWidth', 1.5);
xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
legend('$u_3(t)$','$\nu_3(t)$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
ylim([-250 250]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

axes('Position',[0.2 0.16 0.2 0.1]);
plot(t, u3_cont, 'r-', 'LineWidth', 1); hold on;
plot(t, w3z, 'b--', 'LineWidth', 1);
xlim([3.5 4]);
ylim([-10 10]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

subplot(2,2,4);
plot(t, u4_cont, 'r-', 'LineWidth', 1.5); hold on;
plot(t, w4z, 'b--', 'LineWidth', 1.5);
xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
legend('$u_4(t)$','$\nu_4(t)$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
ylim([-600 600]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

axes('Position',[0.65 0.16 0.2 0.1]);
plot(t, u4_cont, 'r-', 'LineWidth', 1); hold on;
plot(t, w4z, 'b--', 'LineWidth', 1);
xlim([2.9 3.4]);
ylim([-10 10]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);

%print(figure(3), '3.eps', '-depsc');
print(figure(3), '3.png', '-dpng', '-r300');

% 图5: x12和alpha12c
figure(5);
subplot(4,1,1);
plot(t, x12, 'b-', 'LineWidth', 1.5); hold on;
plot(t, alpha12c, 'r--', 'LineWidth', 1.5);
hold off;
% 不设置 xlabel
hLeg1 = legend('$x_{1,2}$', '$\alpha_{1,2c}$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
max_val1 = max(max(abs(x12)), max(abs(alpha12c)));
ylim([-max_val1*1.1, max_val1*1.1]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
% 图例上移 0.01
pos1 = get(hLeg1, 'Position');
pos1(2) = pos1(2) + 0.01;
set(hLeg1, 'Position', pos1);

subplot(4,1,2);
plot(t, x22, 'b-', 'LineWidth', 1.5); hold on;
plot(t, alpha22c, 'r--', 'LineWidth', 1.5);
hold off;
% 不设置 xlabel
hLeg2 = legend('$x_{2,2}$', '$\alpha_{2,2c}$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
max_val2 = max(max(abs(x22)), max(abs(alpha22c)));
ylim([-max_val2*1.1, max_val2*1.1]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
pos2 = get(hLeg2, 'Position');
pos2(2) = pos2(2) + 0.01;
set(hLeg2, 'Position', pos2);

subplot(4,1,3);
plot(t, x32, 'b-', 'LineWidth', 1.5); hold on;
plot(t, alpha32c, 'r--', 'LineWidth', 1.5);
hold off;
% 不设置 xlabel
hLeg3 = legend('$x_{3,2}$', '$\alpha_{3,2c}$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
max_val3 = max(max(abs(x32)), max(abs(alpha32c)));
ylim([-max_val3*1.1, max_val3*1.1]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
pos3 = get(hLeg3, 'Position');
pos3(2) = pos3(2) + 0.01;
set(hLeg3, 'Position', pos3);

subplot(4,1,4);
plot(t, x42, 'b-', 'LineWidth', 1.5); hold on;
plot(t, alpha42c, 'r--', 'LineWidth', 1.5);
hold off;
xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);   % 只保留底部的横坐标
hLeg4 = legend('$x_{4,2}$', '$\alpha_{4,2c}$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
max_val4 = max(max(abs(x42)), max(abs(alpha42c)));
ylim([-max_val4*1.1, max_val4*1.1]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
pos4 = get(hLeg4, 'Position');
pos4(2) = pos4(2) + 0.01;
set(hLeg4, 'Position', pos4);

%print(figure(5), '5.eps', '-depsc');
print(figure(5), '5.png', '-dpng', '-r300');

% 图6：第二个子系统的非线性函数跟踪情况
figure(6);
subplot(4,1,1);
plot(t, f2_actual1, 'k-', 'LineWidth', 2); hold on;
plot(t, net_output12, 'b--', 'LineWidth', 1.5);
plot(t, net_output12_without_comp, 'r:', 'LineWidth', 1.5);
hold off;
% 不设置 xlabel
hLeg1 = legend('$f_{1,2}$', '$\hat{\mathbf{\omega}}_{1,2}^{\mathrm{T}}\mathbf{S}_{1,2}+\hat{\varepsilon}_{1,2}$', 'method in [11]', ...
    'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 11);
max_val1 = max([max(abs(f2_actual1)), max(abs(net_output12)), max(abs(net_output12_without_comp))]);
ylim([-max_val1*1.1, max_val1*1.1]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
pos1 = get(hLeg1, 'Position');
pos1(2) = pos1(2) + 0.01;
set(hLeg1, 'Position', pos1);

subplot(4,1,2);
plot(t, f2_actual2, 'k-', 'LineWidth', 2); hold on;
plot(t, net_output22, 'b--', 'LineWidth', 1.5);
plot(t, net_output22_without_comp, 'r:', 'LineWidth', 1.5);
hold off;
% 不设置 xlabel
hLeg2 = legend('$f_{2,2}$', '$\hat{\mathbf{\omega}}_{2,2}^{\mathrm{T}}\mathbf{S}_{2,2}+\hat{\varepsilon}_{2,2}$', 'method in [11]', ...
    'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 11);
max_val2 = max([max(abs(f2_actual2)), max(abs(net_output22)), max(abs(net_output22_without_comp))]);
ylim([-max_val2*1.1, max_val2*1.1]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
pos2 = get(hLeg2, 'Position');
pos2(2) = pos2(2) + 0.01;
set(hLeg2, 'Position', pos2);

subplot(4,1,3);
plot(t, f2_actual3, 'k-', 'LineWidth', 2); hold on;
plot(t, net_output32, 'b--', 'LineWidth', 1.5);
plot(t, net_output32_without_comp, 'r:', 'LineWidth', 1.5);
hold off;
% 不设置 xlabel
hLeg3 = legend('$f_{3,2}$', '$\hat{\mathbf{\omega}}_{3,2}^{\mathrm{T}}\mathbf{S}_{3,2}+\hat{\varepsilon}_{3,2}$', 'method in [11]', ...
    'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 11);
max_val3 = max([max(abs(f2_actual3)), max(abs(net_output32)), max(abs(net_output32_without_comp))]);
ylim([-max_val3*1.1, max_val3*1.1]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
pos3 = get(hLeg3, 'Position');
pos3(2) = pos3(2) + 0.01;
set(hLeg3, 'Position', pos3);

subplot(4,1,4);
plot(t, f2_actual4, 'k-', 'LineWidth', 2); hold on;
plot(t, net_output42, 'b--', 'LineWidth', 1.5);
plot(t, net_output42_without_comp, 'r:', 'LineWidth', 1.5);
hold off;
xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);   % 只保留底部的横坐标
hLeg4 = legend('$f_{4,2}$', '$\hat{\mathbf{\omega}}_{4,2}^{\mathrm{T}}\mathbf{S}_{4,2}+\hat{\varepsilon}_{4,2}$', 'method in [11]', ...
    'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 11);
max_val4 = max([max(abs(f2_actual4)), max(abs(net_output42)), max(abs(net_output42_without_comp))]);
ylim([-max_val4*1.1, max_val4*1.1]);
grid on;
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
pos4 = get(hLeg4, 'Position');
pos4(2) = pos4(2) + 0.01;
set(hLeg4, 'Position', pos4);

%print(figure(6), '6.eps', '-depsc');
print(figure(6), '6.png', '-dpng', '-r300');

figure(7) % 事件触发图（四个智能体）

% 智能体1事件触发 - 索引1（最上面）
subplot(4,1,1);
if ~isempty(rt1)
    stem(rt1, rtt1, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
    legend(sprintf('Triggering instants of $o_1$ (C=%d)', num1), ...
        'Interpreter','latex', 'Location','northeast', 'FontSize', 12);
    grid on;
    xlim([0, T]);
    if max(rtt1) > 0
        ylim([0, max(rtt1)*1.2]);
    end
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
else
    plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
    legend('No triggering events (C=0)', 'Location', 'northeast', 'FontSize', 12);
    grid on;
    xlim([0, T]);
    ylim([0, 0.1]);
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
end

% 智能体2事件触发 - 索引2
subplot(4,1,2);
if ~isempty(rt2)
    stem(rt2, rtt2, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
    legend(sprintf('Triggering instants of $o_2$ (C=%d)', num2), ...
        'Interpreter','latex', 'Location','northeast', 'FontSize', 12);
    grid on;
    xlim([0, T]);
    if max(rtt2) > 0
        ylim([0, max(rtt2)*1.2]);
    end
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
else
    plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
    legend('No triggering events (C=0)', 'Location', 'northeast', 'FontSize', 12);
    grid on;
    xlim([0, T]);
    ylim([0, 0.1]);
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
end

% 智能体3事件触发 - 索引3
subplot(4,1,3);
if ~isempty(rt3)
    stem(rt3, rtt3, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
    legend(sprintf('Triggering instants of $o_3$ (C=%d)', num3), ...
        'Interpreter','latex', 'Location','northeast', 'FontSize', 12);
    grid on;
    xlim([0, T]);
    if max(rtt3) > 0
        ylim([0, max(rtt3)*1.2]);
    end
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
else
    plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
    legend('No triggering events (C=0)', 'Location', 'northeast', 'FontSize', 12);
    grid on;
    xlim([0, T]);
    ylim([0, 0.1]);
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
end

% 智能体4事件触发 - 索引4（最下面，保留横坐标）
subplot(4,1,4);
if ~isempty(rt4)
    stem(rt4, rtt4, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
    xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);   % 只保留底部的横坐标
    legend(sprintf('Triggering instants of $o_4$ (C=%d)', num4), ...
        'Interpreter','latex', 'Location','northeast', 'FontSize', 12);
    grid on;
    xlim([0, T]);
    if max(rtt4) > 0
        ylim([0, max(rtt4)*1.2]);
    end
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
else
    plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
    xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);   % 只保留底部的横坐标
    legend('No triggering events (C=0)', 'Location', 'northeast', 'FontSize', 12);
    grid on;
    xlim([0, T]);
    ylim([0, 0.1]);
    set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
end

%print(figure(7), '7.eps', '-depsc');

print(figure(7), '7.png', '-dpng', '-r300');

% figure(8)
% subplot(2,1,1);
% plot(t, u1_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w1z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
% ylim([-20 20]);
% legend('$u_1(t)$','$\nu_1(t)$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
% grid on;
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
% subplot(2,1,2);
% if ~isempty(rt1)
%     stem(rt1, rtt1, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
%     legend(sprintf('Triggering instants (C=%d)', num1), 'Location', 'northeast', 'FontSize', 12);
%     grid on;
%     xlim([0, T]);
%     if max(rtt1) > 0
%         ylim([0, max(rtt1)*1.1]);
%     end
%     set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
%     legend('No triggering events (C=0)', 'Location', 'northeast', 'FontSize', 12);
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
%     set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
% end
% 
% % figure(8) 没有保存命令，只设置字体
% 
% figure(9)
% subplot(2,1,1);
% plot(t, u2_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w2z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
% ylim([-50 50]);
% legend('$u_2(t)$','$\nu_2(t)$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
% grid on;
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
% subplot(2,1,2);
% if ~isempty(rt2)
%     stem(rt2, rtt2, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
%     legend(sprintf('Triggering instants (C=%d)', num2), 'Location', 'northeast', 'FontSize', 12);
%     grid on;
%     xlim([0, T]);
%     if max(rtt2) > 0
%         ylim([0, max(rtt2)*1.1]);
%     end
%     set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
%     legend('No triggering events (C=0)', 'Location', 'northeast', 'FontSize', 12);
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
%     set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
% end
% 
% figure(10)
% subplot(2,1,1);
% plot(t, u3_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w3z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
% ylim([-20 20]);
% legend('$u_3(t)$','$\nu_3(t)$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
% grid on;
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
% subplot(2,1,2);
% if ~isempty(rt3)
%     stem(rt3, rtt3, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
%     legend(sprintf('Triggering instants (C=%d)', num3), 'Location', 'northeast', 'FontSize', 12);
%     grid on;
%     xlim([0, T]);
%     if max(rtt3) > 0
%         ylim([0, max(rtt3)*1.1]);
%     end
%     set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
%     legend('No triggering events (C=0)', 'Location', 'northeast', 'FontSize', 12);
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
%     set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
% end
% 
% figure(11)
% subplot(2,1,1);
% plot(t, u4_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w4z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
% ylim([-50 50]);
% legend('$u_4(t)$','$\nu_4(t)$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
% grid on;
% set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
% subplot(2,1,2);
% if ~isempty(rt4)
%     stem(rt4, rtt4, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
%     legend(sprintf('Triggering instants (C=%d)', num4), 'Location', 'northeast', 'FontSize', 12);
%     grid on;
%     xlim([0, T]);
%     if max(rtt4) > 0
%         ylim([0, max(rtt4)*1.1]);
%     end
%     set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)', 'FontName', 'Times New Roman', 'FontSize', 12);
%     legend('No triggering events (C=0)', 'Location', 'northeast', 'FontSize', 12);
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
%     set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
% end

% 加段改字体的代码

% figure(1);
% 
% plot(t, x11, 'b-', 'LineWidth', 1.5); hold on;
% plot(t, x21, 'r--', 'LineWidth', 1.5);
% plot(t, x31, 'g-.', 'LineWidth', 1.5);
% plot(t, x41, 'c:', 'LineWidth', 1.5);
% plot(t, x3d, 'm:', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$x_{1,1}$','$x_{2,1}$','$x_{3,1}$','$x_{4,1}$','$y_d$', 'Interpreter', 'latex', 'Location', 'northeast');
% grid on;
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',12);
% set(get(gca,'xlabel'),'FontName','Times New Roman','FontSize',12);
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',12,'Interpreter','latex');
% 
% print(figure(1), '1.eps', '-depsc');
% 
% % 图2: TPP效果图（包括E11，-ed1，eu1），上下边界
% figure(2);
% subplot(2,2,1);
% plot(t, E11, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, -ed1, 'b--', 'LineWidth', 1.5);
% plot(t, eu1, 'g-.', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$e_{1,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% ylim([-1.5 1.5]);
% grid on;
% 
% subplot(2,2,2);
% plot(t, E21, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, -ed2, 'b--', 'LineWidth', 1.5);
% plot(t, eu2, 'g-.', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$e_{2,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'southeast');
% ylim([-1.5 1.5]);
% grid on;
% 
% subplot(2,2,3);
% plot(t, E31, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, -ed3, 'b--', 'LineWidth', 1.5);
% plot(t, eu3, 'g-.', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$e_{3,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% ylim([-1.5 1.5]);
% grid on;
% 
% subplot(2,2,4);
% plot(t, E41, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, -ed4, 'b--', 'LineWidth', 1.5);
% plot(t, eu4, 'g-.', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$e_{4,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'southeast');
% ylim([-1.5 1.5]);
% grid on;
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',12);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',12);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',12,'Interpreter','latex');
% 
% print(figure(2), '2.eps', '-depsc');
% 
% % 图3：控制输入
% figure(3);
% subplot(2,2,1);
% plot(t, u1_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w1z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% legend('$u_1(t)$','$\nu_1(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% ylim([-150 150]);
% grid on;
% 
% axes('Position',[0.2 0.63 0.2 0.1]);
% plot(t, u1_cont, 'r-', 'LineWidth', 1); hold on;
% plot(t, w1z, 'b--', 'LineWidth', 1);
% xlim([3 3.5]);
% ylim([-20 20]);
% grid on;
% set(gca,'FontSize',12);   % 子图字体也增大
% 
% subplot(2,2,2);
% plot(t, u2_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w2z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% legend('$u_2(t)$','$\nu_2(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% ylim([-600 600]);
% grid on;
% 
% axes('Position',[0.65 0.63 0.2 0.1]);
% plot(t, u2_cont, 'r-', 'LineWidth', 1); hold on;
% plot(t, w2z, 'b--', 'LineWidth', 1);
% xlim([3 3.5]);
% ylim([-40 40]);
% grid on;
% set(gca,'FontSize',12);
% 
% subplot(2,2,3);
% plot(t, u3_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w3z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% legend('$u_3(t)$','$\nu_3(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% ylim([-250 250]);
% grid on;
% 
% axes('Position',[0.2 0.16 0.2 0.1]);
% plot(t, u3_cont, 'r-', 'LineWidth', 1); hold on;
% plot(t, w3z, 'b--', 'LineWidth', 1);
% xlim([3.5 4]);
% ylim([-10 10]);
% grid on;
% set(gca,'FontSize',12);
% 
% subplot(2,2,4);
% plot(t, u4_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w4z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% legend('$u_4(t)$','$\nu_4(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% ylim([-600 600]);
% grid on;
% 
% axes('Position',[0.65 0.16 0.2 0.1]);
% plot(t, u4_cont, 'r-', 'LineWidth', 1); hold on;
% plot(t, w4z, 'b--', 'LineWidth', 1);
% xlim([2.9 3.4]);
% ylim([-10 10]);
% grid on;
% set(gca,'FontSize',12);
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',12);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',12);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',12,'Interpreter','latex');
% 
% print(figure(3), '3.eps', '-depsc');
% 
% % 图5: x12和alpha12c
% figure(5);
% subplot(4,1,1);
% plot(t, x12, 'b-', 'LineWidth', 1.5); hold on;
% plot(t, alpha12c, 'r--', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$x_{1,2}$', '$\alpha_{1,2c}$', 'Interpreter', 'latex', 'Location','northeast');
% max_val1 = max(max(abs(x12)), max(abs(alpha12c)));
% ylim([-max_val1*1.1, max_val1*1.1]);
% grid on;
% 
% subplot(4,1,2);
% plot(t, x22, 'b-', 'LineWidth', 1.5); hold on;
% plot(t, alpha22c, 'r--', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$x_{2,2}$', '$\alpha_{2,2c}$', 'Interpreter', 'latex', 'Location','northeast');
% max_val2 = max(max(abs(x22)), max(abs(alpha22c)));
% ylim([-max_val2*1.1, max_val2*1.1]);
% grid on;
% 
% subplot(4,1,3);
% plot(t, x32, 'b-', 'LineWidth', 1.5); hold on;
% plot(t, alpha32c, 'r--', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$x_{3,2}$', '$\alpha_{3,2c}$', 'Interpreter', 'latex', 'Location','northeast');
% max_val3 = max(max(abs(x32)), max(abs(alpha32c)));
% ylim([-max_val3*1.1, max_val3*1.1]);
% grid on;
% 
% subplot(4,1,4);
% plot(t, x42, 'b-', 'LineWidth', 1.5); hold on;
% plot(t, alpha42c, 'r--', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$x_{4,2}$', '$\alpha_{4,2c}$', 'Interpreter', 'latex', 'Location','northeast');
% max_val4 = max(max(abs(x42)), max(abs(alpha42c)));
% ylim([-max_val4*1.1, max_val4*1.1]);
% grid on;
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',12);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',12);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',12,'Interpreter','latex');
% 
% print(figure(5), '5.eps', '-depsc');
% 
% % 图6：第二个子系统的非线性函数跟踪情况
% figure(6);
% subplot(4,1,1);
% plot(t, f2_actual1, 'k-', 'LineWidth', 2); hold on;
% plot(t, net_output12, 'b--', 'LineWidth', 1.5);
% plot(t, net_output12_without_comp, 'r:', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$f_{1,2}$', '$\hat{\omega}_{1,2}^{\mathrm{T}}\mathrm{S}_{1,2}+\hat{\varepsilon}_{1,2}$', 'method in [11]', 'Interpreter', 'latex', 'Location', 'northeast');
% max_val1 = max([max(abs(f2_actual1)), max(abs(net_output12)), max(abs(net_output12_without_comp))]);
% ylim([-max_val1*1.1, max_val1*1.1]);
% grid on;
% 
% subplot(4,1,2);
% plot(t, f2_actual2, 'k-', 'LineWidth', 2); hold on;
% plot(t, net_output22, 'b--', 'LineWidth', 1.5);
% plot(t, net_output22_without_comp, 'r:', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$f_{2,2}$', '$\hat{\omega}_{2,2}^{\mathrm{T}}\mathrm{S}_{2,2}+\hat{\varepsilon}_{2,2}$', 'method in [11]', 'Interpreter', 'latex', 'Location', 'northeast');
% max_val2 = max([max(abs(f2_actual2)), max(abs(net_output22)), max(abs(net_output22_without_comp))]);
% ylim([-max_val2*1.1, max_val2*1.1]);
% grid on;
% 
% subplot(4,1,3);
% plot(t, f2_actual3, 'k-', 'LineWidth', 2); hold on;
% plot(t, net_output32, 'b--', 'LineWidth', 1.5);
% plot(t, net_output32_without_comp, 'r:', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$f_{3,2}$', '$\hat{\omega}_{3,2}^{\mathrm{T}}\mathrm{S}_{3,2}+\hat{\varepsilon}_{3,2}$', 'method in [11]', 'Interpreter', 'latex', 'Location', 'northeast');
% max_val3 = max([max(abs(f2_actual3)), max(abs(net_output32)), max(abs(net_output32_without_comp))]);
% ylim([-max_val3*1.1, max_val3*1.1]);
% grid on;
% 
% subplot(4,1,4);
% plot(t, f2_actual4, 'k-', 'LineWidth', 2); hold on;
% plot(t, net_output42, 'b--', 'LineWidth', 1.5);
% plot(t, net_output42_without_comp, 'r:', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$f_{4,2}$', '$\hat{\omega}_{4,2}^{\mathrm{T}}\mathrm{S}_{4,2}+\hat{\varepsilon}_{4,2}$', 'method in [11]', 'Interpreter', 'latex', 'Location', 'northeast');
% max_val4 = max([max(abs(f2_actual4)), max(abs(net_output42)), max(abs(net_output42_without_comp))]);
% ylim([-max_val4*1.1, max_val4*1.1]);
% grid on;
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',12);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',12);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',12,'Interpreter','latex');
% 
% print(figure(6), '6.eps', '-depsc');
% 
% figure(7) % 智能体1事件触发
% subplot(4,1,1);
% if ~isempty(rt1)
%     stem(rt1, rtt1, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants of $o_1$ (C=%d)', num1), ...
%        'Interpreter','latex', 'Location','northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt1) > 0
%         ylim([0, max(rtt1)*1.2]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 智能体3事件触发
% subplot(4,1,3);
% if ~isempty(rt3)
%     stem(rt3, rtt3, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants of $o_3$ (C=%d)', num3), ...
%        'Interpreter','latex', 'Location','northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt3) > 0
%         ylim([0, max(rtt3)*1.2]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 智能体4事件触发
% subplot(4,1,4);
% if ~isempty(rt4)
%     stem(rt4, rtt4, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants of $o_4$ (C=%d)', num4), ...
%        'Interpreter','latex', 'Location','northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt4) > 0
%         ylim([0, max(rtt4)*1.2]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 智能体2事件触发
% subplot(4,1,2);
% if ~isempty(rt2)
%     stem(rt2, rtt2, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants of $o_2$ (C=%d)', num2), ...
%        'Interpreter','latex', 'Location','northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt2) > 0
%         ylim([0, max(rtt2)*1.2]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',12);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',12);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',12,'Interpreter','latex');
% 
% print(figure(7), '7.eps', '-depsc');
% 
% figure(8)
% subplot(2,1,1);
% plot(t, u1_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w1z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylim([-20 20]);
% legend('$u_1(t)$','$\nu_1(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% grid on;
% subplot(2,1,2);
% if ~isempty(rt1)
%     stem(rt1, rtt1, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (C=%d)', num1), 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt1) > 0
%         ylim([0, max(rtt1)*1.1]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',12);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',12);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',12,'Interpreter','latex');
% 
% % figure(8) 没有保存命令，只设置字体（如需要可自行添加 print）
% 
% figure(9)
% subplot(2,1,1);
% plot(t, u2_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w2z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylim([-50 50]);
% legend('$u_2(t)$','$\nu_2(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% grid on;
% subplot(2,1,2);
% if ~isempty(rt2)
%     stem(rt2, rtt2, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (C=%d)', num2), 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt2) > 0
%         ylim([0, max(rtt2)*1.1]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',12);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',12);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',12,'Interpreter','latex');
% 
% figure(10)
% subplot(2,1,1);
% plot(t, u3_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w3z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylim([-20 20]);
% legend('$u_3(t)$','$\nu_3(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% grid on;
% subplot(2,1,2);
% if ~isempty(rt3)
%     stem(rt3, rtt3, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (C=%d)', num3), 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt3) > 0
%         ylim([0, max(rtt3)*1.1]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',12);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',12);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',12,'Interpreter','latex');
% 
% figure(11)
% subplot(2,1,1);
% plot(t, u4_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w4z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylim([-50 50]);
% legend('$u_4(t)$','$\nu_4(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% grid on;
% subplot(2,1,2);
% if ~isempty(rt4)
%     stem(rt4, rtt4, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (C=%d)', num4), 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt4) > 0
%         ylim([0, max(rtt4)*1.1]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',12);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',12);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',12,'Interpreter','latex');

% % 加段改字体的代码
% 
% figure(1);
% 
% plot(t, x11, 'b-', 'LineWidth', 1.5); hold on;
% plot(t, x21, 'r--', 'LineWidth', 1.5);
% plot(t, x31, 'g-.', 'LineWidth', 1.5);
% plot(t, x41, 'c:', 'LineWidth', 1.5);
% plot(t, x3d, 'm:', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$x_{1,1}$','$x_{2,1}$','$x_{3,1}$','$x_{4,1}$','$y_d$', 'Interpreter', 'latex', 'Location', 'northeast');
% grid on;
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',10);
% set(get(gca,'xlabel'),'FontName','Times New Roman','FontSize',10);
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',10,'Interpreter','latex');
% 
% saveas(figure(1), '1.png');
% 
% % 图2: TPP效果图（包括E11，-ed1，eu1），上下边界
% figure(2);
% subplot(2,2,1);
% plot(t, E11, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, -ed1, 'b--', 'LineWidth', 1.5);
% plot(t, eu1, 'g-.', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$e_{1,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% ylim([-1.5 1.5]);
% grid on;
% 
% subplot(2,2,2);
% plot(t, E21, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, -ed2, 'b--', 'LineWidth', 1.5);
% plot(t, eu2, 'g-.', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$e_{2,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'southeast');
% ylim([-1.5 1.5]);
% grid on;
% 
% subplot(2,2,3);
% plot(t, E31, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, -ed3, 'b--', 'LineWidth', 1.5);
% plot(t, eu3, 'g-.', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$e_{3,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% ylim([-1.5 1.5]);
% grid on;
% 
% subplot(2,2,4);
% plot(t, E41, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, -ed4, 'b--', 'LineWidth', 1.5);
% plot(t, eu4, 'g-.', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$e_{4,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'southeast');
% ylim([-1.5 1.5]);
% grid on;
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',10);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',10);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',10,'Interpreter','latex');
% 
% saveas(figure(2), '2.png');
% 
% % 图3：控制输入
% figure(3);
% subplot(2,2,1);
% plot(t, u1_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w1z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% legend('$u_1(t)$','$\nu_1(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% ylim([-150 150]);
% grid on;
% 
% axes('Position',[0.2 0.63 0.2 0.1]);
% plot(t, u1_cont, 'r-', 'LineWidth', 1); hold on;
% plot(t, w1z, 'b--', 'LineWidth', 1);
% xlim([3 3.5]);
% ylim([-20 20]);
% grid on;
% 
% subplot(2,2,2);
% plot(t, u2_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w2z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% legend('$u_2(t)$','$\nu_2(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% ylim([-600 600]);
% grid on;
% 
% axes('Position',[0.65 0.63 0.2 0.1]);
% plot(t, u2_cont, 'r-', 'LineWidth', 1); hold on;
% plot(t, w2z, 'b--', 'LineWidth', 1);
% xlim([3 3.5]);
% ylim([-40 40]);
% grid on;
% 
% subplot(2,2,3);
% plot(t, u3_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w3z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% legend('$u_3(t)$','$\nu_3(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% ylim([-250 250]);
% grid on;
% 
% axes('Position',[0.2 0.16 0.2 0.1]);
% plot(t, u3_cont, 'r-', 'LineWidth', 1); hold on;
% plot(t, w3z, 'b--', 'LineWidth', 1);
% xlim([3.5 4]);
% ylim([-10 10]);
% grid on;
% 
% subplot(2,2,4);
% plot(t, u4_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w4z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% legend('$u_4(t)$','$\nu_4(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% ylim([-600 600]);
% grid on;
% 
% axes('Position',[0.65 0.16 0.2 0.1]);
% plot(t, u4_cont, 'r-', 'LineWidth', 1); hold on;
% plot(t, w4z, 'b--', 'LineWidth', 1);
% xlim([2.9 3.4]);
% ylim([-10 10]);
% grid on;
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',10);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',10);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',10,'Interpreter','latex');
% 
% saveas(figure(3), '3.png');
% 
% % 图5: x12和alpha12c
% figure(5);
% subplot(4,1,1);
% plot(t, x12, 'b-', 'LineWidth', 1.5); hold on;
% plot(t, alpha12c, 'r--', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$x_{1,2}$', '$\alpha_{1,2c}$', 'Interpreter', 'latex', 'Location','northeast');
% max_val1 = max(max(abs(x12)), max(abs(alpha12c)));
% ylim([-max_val1*1.1, max_val1*1.1]);
% grid on;
% 
% subplot(4,1,2);
% plot(t, x22, 'b-', 'LineWidth', 1.5); hold on;
% plot(t, alpha22c, 'r--', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$x_{2,2}$', '$\alpha_{2,2c}$', 'Interpreter', 'latex', 'Location','northeast');
% max_val2 = max(max(abs(x22)), max(abs(alpha22c)));
% ylim([-max_val2*1.1, max_val2*1.1]);
% grid on;
% 
% subplot(4,1,3);
% plot(t, x32, 'b-', 'LineWidth', 1.5); hold on;
% plot(t, alpha32c, 'r--', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$x_{3,2}$', '$\alpha_{3,2c}$', 'Interpreter', 'latex', 'Location','northeast');
% max_val3 = max(max(abs(x32)), max(abs(alpha32c)));
% ylim([-max_val3*1.1, max_val3*1.1]);
% grid on;
% 
% subplot(4,1,4);
% plot(t, x42, 'b-', 'LineWidth', 1.5); hold on;
% plot(t, alpha42c, 'r--', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$x_{4,2}$', '$\alpha_{4,2c}$', 'Interpreter', 'latex', 'Location','northeast');
% max_val4 = max(max(abs(x42)), max(abs(alpha42c)));
% ylim([-max_val4*1.1, max_val4*1.1]);
% grid on;
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',10);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',10);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',10,'Interpreter','latex');
% 
% saveas(figure(5), '5.png');
% 
% % 图6：第二个子系统的非线性函数跟踪情况
% figure(6);
% subplot(4,1,1);
% plot(t, f2_actual1, 'k-', 'LineWidth', 2); hold on;
% plot(t, net_output12, 'b--', 'LineWidth', 1.5);
% plot(t, net_output12_without_comp, 'r:', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$f_{1,2}$', '$\hat{\omega}_{1,2}^{\mathrm{T}}\mathrm{S}_{1,2}+\hat{\varepsilon}_{1,2}$', 'method in [11]', 'Interpreter', 'latex', 'Location', 'northeast');
% max_val1 = max([max(abs(f2_actual1)), max(abs(net_output12)), max(abs(net_output12_without_comp))]);
% ylim([-max_val1*1.1, max_val1*1.1]);
% grid on;
% 
% subplot(4,1,2);
% plot(t, f2_actual2, 'k-', 'LineWidth', 2); hold on;
% plot(t, net_output22, 'b--', 'LineWidth', 1.5);
% plot(t, net_output22_without_comp, 'r:', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$f_{2,2}$', '$\hat{\omega}_{2,2}^{\mathrm{T}}\mathrm{S}_{2,2}+\hat{\varepsilon}_{2,2}$', 'method in [11]', 'Interpreter', 'latex', 'Location', 'northeast');
% max_val2 = max([max(abs(f2_actual2)), max(abs(net_output22)), max(abs(net_output22_without_comp))]);
% ylim([-max_val2*1.1, max_val2*1.1]);
% grid on;
% 
% subplot(4,1,3);
% plot(t, f2_actual3, 'k-', 'LineWidth', 2); hold on;
% plot(t, net_output32, 'b--', 'LineWidth', 1.5);
% plot(t, net_output32_without_comp, 'r:', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$f_{3,2}$', '$\hat{\omega}_{3,2}^{\mathrm{T}}\mathrm{S}_{3,2}+\hat{\varepsilon}_{3,2}$', 'method in [11]', 'Interpreter', 'latex', 'Location', 'northeast');
% max_val3 = max([max(abs(f2_actual3)), max(abs(net_output32)), max(abs(net_output32_without_comp))]);
% ylim([-max_val3*1.1, max_val3*1.1]);
% grid on;
% 
% subplot(4,1,4);
% plot(t, f2_actual4, 'k-', 'LineWidth', 2); hold on;
% plot(t, net_output42, 'b--', 'LineWidth', 1.5);
% plot(t, net_output42_without_comp, 'r:', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$f_{4,2}$', '$\hat{\omega}_{4,2}^{\mathrm{T}}\mathrm{S}_{4,2}+\hat{\varepsilon}_{4,2}$', 'method in [11]', 'Interpreter', 'latex', 'Location', 'northeast');
% max_val4 = max([max(abs(f2_actual4)), max(abs(net_output42)), max(abs(net_output42_without_comp))]);
% ylim([-max_val4*1.1, max_val4*1.1]);
% grid on;
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',10);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',10);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',10,'Interpreter','latex');
% 
% saveas(figure(6), '6.png');
% 
% figure(7) % 智能体1事件触发
% subplot(4,1,1);
% if ~isempty(rt1)
%     stem(rt1, rtt1, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants of $o_1$ (C=%d)', num1), ...
%        'Interpreter','latex', 'Location','northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt1) > 0
%         ylim([0, max(rtt1)*1.2]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 智能体3事件触发
% subplot(4,1,3);
% if ~isempty(rt3)
%     stem(rt3, rtt3, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants of $o_3$ (C=%d)', num3), ...
%        'Interpreter','latex', 'Location','northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt3) > 0
%         ylim([0, max(rtt3)*1.2]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 智能体4事件触发
% subplot(4,1,4);
% if ~isempty(rt4)
%     stem(rt4, rtt4, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants of $o_4$ (C=%d)', num4), ...
%        'Interpreter','latex', 'Location','northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt4) > 0
%         ylim([0, max(rtt4)*1.2]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 智能体2事件触发
% subplot(4,1,2);
% if ~isempty(rt2)
%     stem(rt2, rtt2, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants of $o_2$ (C=%d)', num2), ...
%        'Interpreter','latex', 'Location','northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt2) > 0
%         ylim([0, max(rtt2)*1.2]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',10);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',10);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',10,'Interpreter','latex');
% 
% saveas(figure(7), '7.png');
% 
% figure(8)
% subplot(2,1,1);
% plot(t, u1_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w1z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylim([-20 20]);
% legend('$u_1(t)$','$\nu_1(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% grid on;
% subplot(2,1,2);
% if ~isempty(rt1)
%     stem(rt1, rtt1, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (C=%d)', num1), 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt1) > 0
%         ylim([0, max(rtt1)*1.1]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',10);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',10);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',10,'Interpreter','latex');
% 
% figure(9)
% subplot(2,1,1);
% plot(t, u2_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w2z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylim([-50 50]);
% legend('$u_2(t)$','$\nu_2(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% grid on;
% subplot(2,1,2);
% if ~isempty(rt2)
%     stem(rt2, rtt2, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (C=%d)', num2), 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt2) > 0
%         ylim([0, max(rtt2)*1.1]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',10);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',10);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',10,'Interpreter','latex');
% 
% figure(10)
% subplot(2,1,1);
% plot(t, u3_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w3z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylim([-20 20]);
% legend('$u_3(t)$','$\nu_3(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% grid on;
% subplot(2,1,2);
% if ~isempty(rt3)
%     stem(rt3, rtt3, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (C=%d)', num3), 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt3) > 0
%         ylim([0, max(rtt3)*1.1]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',10);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',10);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',10,'Interpreter','latex');
% 
% figure(11)
% subplot(2,1,1);
% plot(t, u4_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w4z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylim([-50 50]);
% legend('$u_4(t)$','$\nu_4(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% grid on;
% subplot(2,1,2);
% if ~isempty(rt4)
%     stem(rt4, rtt4, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (C=%d)', num4), 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     if max(rtt4) > 0
%         ylim([0, max(rtt4)*1.1]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (C=0)', 'Location', 'northeast');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 设置字体
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',10);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',10);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',10,'Interpreter','latex');

% % 图12: beta(t) 和 dot_beta(t) 随时间的变化曲线
% figure(12);  % 新图号，避免与已有图冲突
% 
% subplot(3,1,1);
% plot(t, beta, 'b-', 'LineWidth', 1.5);
% xlabel('Time(s)');
% legend('$\beta(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% grid on;
% 
% subplot(3,1,2);
% plot(t, dot_beta, 'r-', 'LineWidth', 1.5);
% xlabel('Time(s)');
% legend('$\dot{\beta}(t)$', 'Interpreter', 'latex', 'Location', 'northeast');
% grid on;
% 
% Beta = dot_beta/beta;
% subplot(3,1,3);
% plot(t, Beta, 'r-', 'LineWidth', 1.5);
% xlabel('Time(s)');
% legend('$dot_beta/beta$', 'Interpreter', 'latex', 'Location', 'northeast');
% grid on;
% 
% % 设置统一的字体样式
% set(findall(gcf,'type','axes'),'FontName','Times New Roman','FontSize',10);
% hXLabel = findall(gcf,'type','axes');
% for i = 1:length(hXLabel)
%     set(get(hXLabel(i),'xlabel'),'FontName','Times New Roman','FontSize',10);
% end
% hLeg = findobj(gcf,'Type','legend');
% set(hLeg,'FontName','Times New Roman','FontSize',10,'Interpreter','latex');

% 画图代码可以根据需要添加
% 例如：
% figure(1);
% 
% plot(t, x11, 'b-', 'LineWidth', 1.5); hold on;
% plot(t, x21, 'r--', 'LineWidth', 1.5);
% plot(t, x31, 'g-.', 'LineWidth', 1.5);
% plot(t, x41, 'c:', 'LineWidth', 1.5);
% plot(t, x3d, 'm:', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$x_{1,1}$','$x_{2,1}$','$x_{3,1}$','$x_{4,1}$','$y_d$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% grid on;
% 
% saveas(figure(1), '1.png');  % 保存为PNG格式
% 
% %图2: TPP效果图（包括E11，-ed1，eu1），上下边界
% figure(2);
% subplot(2,2,1);
% plot(t, E11, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, -ed1, 'b--', 'LineWidth', 1.5);
% plot(t, eu1, 'g-.', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$e_{1,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% % 修改ylim，使其关于0对称
% ylim([-1.5 1.5]);  % 原为[-0.5 1.5]
% grid on;
% 
% subplot(2,2,2);
% plot(t, E21, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, -ed2, 'b--', 'LineWidth', 1.5);
% plot(t, eu2, 'g-.', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$e_{2,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'southeast','FontSize', 8);
% % 修改ylim，使其关于0对称
% ylim([-1.5 1.5]);  % 原为[-1.5 0.5]
% grid on;
% 
% subplot(2,2,3);
% plot(t, E31, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, -ed3, 'b--', 'LineWidth', 1.5);
% plot(t, eu3, 'g-.', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$e_{3,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% % 修改ylim，使其关于0对称
% ylim([-1.5 1.5]);  % 原为[-0.5 1.5]
% grid on;
% 
% subplot(2,2,4);
% plot(t, E41, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, -ed4, 'b--', 'LineWidth', 1.5);
% plot(t, eu4, 'g-.', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$e_{4,1}$', '$-e_l(t)$', '$e_u(t)$', 'Interpreter', 'latex', 'Location', 'southeast','FontSize', 8);
% % 修改ylim，使其关于0对称
% ylim([-1.5 1.5]);  % 原为[-1.5 0.5]
% grid on;
% 
% saveas(figure(2), '2.png');  % 保存为PNG格式
% 
% % 图3：控制输入
% figure(3);
% subplot(2,2,1);
% plot(t, u1_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w1z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% legend('$u_1(t)$','$\nu_1(t)$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% ylim([-150 150]); % 放大纵轴范围
% grid on;
% 
% % 添加局部放大图
% axes('Position',[0.2 0.63 0.2 0.1]); % [left bottom width height] 单位是figure比例
% plot(t, u1_cont, 'r-', 'LineWidth', 1); hold on;
% plot(t, w1z, 'b--', 'LineWidth', 1);
% xlim([3 3.5]); % 放大时间范围
% ylim([-20 20]); % 放大纵轴范围
% grid on;
% 
% subplot(2,2,2);
% plot(t, u2_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w2z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% legend('$u_2(t)$','$\nu_2(t)$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% ylim([-600 600]); % 放大纵轴范围
% grid on;
% 
% axes('Position',[0.65 0.63 0.2 0.1]); % [left bottom width height] 单位是figure比例
% plot(t, u2_cont, 'r-', 'LineWidth', 1); hold on;
% plot(t, w2z, 'b--', 'LineWidth', 1);
% xlim([3 3.5]); % 放大时间范围
% ylim([-40 40]); % 放大纵轴范围
% grid on;
% 
% subplot(2,2,3);
% plot(t, u3_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w3z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% legend('$u_3(t)$','$\nu_3(t)$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% ylim([-250 250]); % 放大纵轴范围
% grid on;
% 
% axes('Position',[0.2 0.16 0.2 0.1]); % [left bottom width height] 单位是figure比例
% plot(t, u3_cont, 'r-', 'LineWidth', 1); hold on;
% plot(t, w3z, 'b--', 'LineWidth', 1);
% xlim([3.5 4]); % 放大时间范围
% ylim([-10 10]); % 放大纵轴范围
% grid on;
% 
% subplot(2,2,4);
% plot(t, u4_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w4z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% legend('$u_4(t)$','$\nu_4(t)$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% ylim([-600 600]); % 放大纵轴范围
% grid on;
% 
% axes('Position',[0.65 0.16 0.2 0.1]); % [left bottom width height] 单位是figure比例
% plot(t, u4_cont, 'r-', 'LineWidth', 1); hold on;
% plot(t, w4z, 'b--', 'LineWidth', 1);
% xlim([2.9 3.4]); % 放大时间范围
% ylim([-10 10]); % 放大纵轴范围
% grid on;
% 
% saveas(figure(3), '3.png');  % 保存为PNG格式
% 
% % 图4，转换误差z1
% % figure(4);
% % subplot(4,1,1);
% % plot(t, z11, 'r-', 'LineWidth', 1.5);
% % xlabel('Time(s)');
% % legend('$z_{1,1}$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8,'FontSize', 12);
% % grid on;
% % 
% % subplot(4,1,2);
% % plot(t, z21, 'r-', 'LineWidth', 1.5);
% % xlabel('Time(s)');
% % legend('$z_{2,1}$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8,'FontSize', 12);
% % grid on;
% % 
% % subplot(4,1,3);
% % plot(t, z31, 'r-', 'LineWidth', 1.5);
% % xlabel('Time(s)');
% % legend('$z_{3,1}$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8,'FontSize', 12);
% % grid on;
% % 
% % subplot(4,1,4);
% % plot(t, z41, 'r-', 'LineWidth', 1.5);
% % xlabel('Time(s)');
% % legend('$z_{4,1}$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8,'FontSize', 12);
% % grid on;
% 
% 
% 
% % 图5: x12和alpha12c
% figure(5);
% subplot(4,1,1);
% plot(t, x12, 'b-', 'LineWidth', 1.5); hold on;
% plot(t, alpha12c, 'r--', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$x_{1,2}$', '$\alpha_{1,2c}$', 'Interpreter', 'latex', 'Location','northeast','FontSize', 8);
% % 设置对称的ylim，使0线在中间
% max_val1 = max(max(abs(x12)), max(abs(alpha12c)));
% ylim([-max_val1*1.1, max_val1*1.1]);  % 增加10%边距
% grid on;
% 
% subplot(4,1,2);
% plot(t, x22, 'b-', 'LineWidth', 1.5); hold on;
% plot(t, alpha22c, 'r--', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$x_{2,2}$', '$\alpha_{2,2c}$', 'Interpreter', 'latex', 'Location','northeast','FontSize', 8);
% % 设置对称的ylim，使0线在中间
% max_val2 = max(max(abs(x22)), max(abs(alpha22c)));
% ylim([-max_val2*1.1, max_val2*1.1]);  % 增加10%边距
% grid on;
% 
% subplot(4,1,3);
% plot(t, x32, 'b-', 'LineWidth', 1.5); hold on;
% plot(t, alpha32c, 'r--', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$x_{3,2}$', '$\alpha_{3,2c}$', 'Interpreter', 'latex', 'Location','northeast','FontSize', 8);
% % 设置对称的ylim，使0线在中间
% max_val3 = max(max(abs(x32)), max(abs(alpha32c)));
% ylim([-max_val3*1.1, max_val3*1.1]);  % 增加10%边距
% grid on;
% 
% subplot(4,1,4);
% plot(t, x42, 'b-', 'LineWidth', 1.5); hold on;
% plot(t, alpha42c, 'r--', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$x_{4,2}$', '$\alpha_{4,2c}$', 'Interpreter', 'latex', 'Location','northeast','FontSize', 8);
% % 设置对称的ylim，使0线在中间
% max_val4 = max(max(abs(x42)), max(abs(alpha42c)));
% ylim([-max_val4*1.1, max_val4*1.1]);  % 增加10%边距
% grid on;
% 
% saveas(figure(5), '5.png');  % 保存为PNG格式
% 
% 
% %图6：第二个子系统的非线性函数跟踪情况
% figure(6);
% 
% subplot(4,1,1);
% plot(t, f2_actual1, 'k-', 'LineWidth', 2); hold on;
% plot(t, net_output12, 'b--', 'LineWidth', 1.5);
% plot(t, net_output12_without_comp, 'r:', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$f_{1,2}$', '$\hat{\omega}_{1,2}^{\mathrm{T}}\mathrm{S}_{1,2}+\hat{\varepsilon}_{1,2}$', 'method in [30]', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% % 设置对称的ylim，使0线在中间
% max_val1 = max([max(abs(f2_actual1)), max(abs(net_output12)), max(abs(net_output12_without_comp))]);
% ylim([-max_val1*1.1, max_val1*1.1]);  % 增加10%边距
% grid on;
% 
% subplot(4,1,2);
% plot(t, f2_actual2, 'k-', 'LineWidth', 2); hold on;
% plot(t, net_output22, 'b--', 'LineWidth', 1.5);
% plot(t, net_output22_without_comp, 'r:', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$f_{2,2}$', '$\hat{\omega}_{2,2}^{\mathrm{T}}\mathrm{S}_{2,2}+\hat{\varepsilon}_{2,2}$', 'method in [30]', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% % 设置对称的ylim，使0线在中间
% max_val2 = max([max(abs(f2_actual2)), max(abs(net_output22)), max(abs(net_output22_without_comp))]);
% ylim([-max_val2*1.1, max_val2*1.1]);  % 增加10%边距
% grid on;
% 
% subplot(4,1,3);
% plot(t, f2_actual3, 'k-', 'LineWidth', 2); hold on;
% plot(t, net_output32, 'b--', 'LineWidth', 1.5);
% plot(t, net_output32_without_comp, 'r:', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$f_{3,2}$', '$\hat{\omega}_{3,2}^{\mathrm{T}}\mathrm{S}_{3,2}+\hat{\varepsilon}_{3,2}$', 'method in [30]', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% % 设置对称的ylim，使0线在中间
% max_val3 = max([max(abs(f2_actual3)), max(abs(net_output32)), max(abs(net_output32_without_comp))]);
% ylim([-max_val3*1.1, max_val3*1.1]);  % 增加10%边距
% grid on;
% 
% subplot(4,1,4);
% plot(t, f2_actual4, 'k-', 'LineWidth', 2); hold on;
% plot(t, net_output42, 'b--', 'LineWidth', 1.5);
% plot(t, net_output42_without_comp, 'r:', 'LineWidth', 1.5);
% hold off;
% xlabel('Time(s)');
% legend('$f_{4,2}$', '$\hat{\omega}_{4,2}^{\mathrm{T}}\mathrm{S}_{4,2}+\hat{\varepsilon}_{4,2}$', 'method in [30]', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% % 设置对称的ylim，使0线在中间
% max_val4 = max([max(abs(f2_actual4)), max(abs(net_output42)), max(abs(net_output42_without_comp))]);
% ylim([-max_val4*1.1, max_val4*1.1]);  % 增加10%边距
% grid on;
% 
% saveas(figure(6), '6.png');  % 保存为PNG格式
% 
% 
% 
% figure(7) % 智能体1事件触发
% subplot(4,1,1);
% if ~isempty(rt1)
%     stem(rt1, rtt1, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants of $o_1$ (N=%d)', num1), ...
%        'Interpreter','latex', 'Location','northeast','FontSize',8);
%   %  title('Inter-event times under ET mechanism');
%     grid on;
%     
%     % 设置合适的坐标范围
%     xlim([0, T]);
%     if max(rtt1) > 0
%         ylim([0, max(rtt1)*1.2]);
%     end
% else
%     % 如果没有触发事件
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (N=0)', 'Location', 'northeast','FontSize', 8);
%    % title('Inter-event times under ETM');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]); % 设置一个小的范围，使图看起来正常
% end
% 
% 
% 
%  % 智能体3事件触发
% subplot(4,1,3);
% if ~isempty(rt3)
%     stem(rt3, rtt3, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants of $o_3$ (N=%d)', num3), ...
%        'Interpreter','latex', 'Location','northeast','FontSize',8);
%   %  title('Inter-event times under ET mechanism');
%     grid on;
%     
%     % 设置合适的坐标范围
%     xlim([0, T]);
%     if max(rtt3) > 0
%         ylim([0, max(rtt3)*1.2]);
%     end
% else
%     % 如果没有触发事件
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (N=0)', 'Location', 'northeast','FontSize', 8);
%    % title('Inter-event times under ETM');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]); % 设置一个小的范围，使图看起来正常
% end
% 
% 
% 
% % 智能体4事件触发
% subplot(4,1,4);
% if ~isempty(rt4)
%     stem(rt4, rtt4, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants of $o_4$ (N=%d)', num4), ...
%        'Interpreter','latex', 'Location','northeast','FontSize',8);
%   %  title('Inter-event times under ET mechanism');
%     grid on;
%     
%     % 设置合适的坐标范围
%     xlim([0, T]);
%     if max(rtt4) > 0
%         ylim([0, max(rtt4)*1.2]);
%     end
% else
%     % 如果没有触发事件
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (N=0)', 'Location', 'northeast','FontSize', 8);
%    % title('Inter-event times under ETM');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]); % 设置一个小的范围，使图看起来正常
% end
% 
% 
% 
% % 智能体2事件触发
% subplot(4,1,2);
% if ~isempty(rt2)
%     stem(rt2, rtt2, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants of $o_2$ (N=%d)', num2), ...
%        'Interpreter','latex', 'Location','northeast','FontSize',8);
%   %  title('Inter-event times under ET mechanism');
%     grid on;
%     
%     % 设置合适的坐标范围
%     xlim([0, T]);
%     if max(rtt2) > 0
%         ylim([0, max(rtt2)*1.2]);
%     end
% else
%     % 如果没有触发事件
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (N=0)', 'Location', 'northeast','FontSize', 8);
%    % title('Inter-event times under ETM');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]); % 设置一个小的范围，使图看起来正常
% end
% saveas(figure(7), '7.png');
% 
% figure(8)
% subplot(2,1,1);
% plot(t, u1_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w1z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylim([-20 20]);
% legend('$u_1(t)$','$\nu_1(t)$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% grid on;
% subplot(2,1,2);
% if ~isempty(rt1)
%     stem(rt1, rtt1, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (N=%d)', num1), 'Location', 'northeast','FontSize', 8);
%   %  title('Inter-event times under ET mechanism');
%     grid on;
%     
%     % 设置合适的坐标范围
%     xlim([0, T]);
%     if max(rtt1) > 0
%         ylim([0, max(rtt1)*1.1]);
%     end
% else
%     % 如果没有触发事件
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (N=0)', 'Location', 'northeast','FontSize', 8);
%    % title('Inter-event times under ETM');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]); % 设置一个小的范围，使图看起来正常
% end
% 
% 
% 
% figure(9)
% subplot(2,1,1);
% plot(t, u2_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w2z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylim([-50 50]);
% legend('$u_2(t)$','$\nu_2(t)$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% grid on;
% subplot(2,1,2);
% if ~isempty(rt2)
%     stem(rt2, rtt2, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (N=%d)', num2), 'Location', 'northeast','FontSize', 8);
%   %  title('Inter-event times under ET mechanism');
%     grid on;
%     
%     % 设置合适的坐标范围
%     xlim([0, T]);
%     if max(rtt2) > 0
%         ylim([0, max(rtt2)*1.1]);
%     end
% else
%     % 如果没有触发事件
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (N=0)', 'Location', 'northeast','FontSize', 8);
%    % title('Inter-event times under ETM');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]); % 设置一个小的范围，使图看起来正常
% end
% 
% figure(10)
% subplot(2,1,1);
% plot(t, u3_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w3z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylim([-20 20]);
% legend('$u_3(t)$','$\nu_3(t)$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% grid on;
% subplot(2,1,2);
% if ~isempty(rt3)
%     stem(rt3, rtt3, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (N=%d)', num3), 'Location', 'northeast','FontSize', 8);
%   %  title('Inter-event times under ET mechanism');
%     grid on;
%     
%     % 设置合适的坐标范围
%     xlim([0, T]);
%     if max(rtt3) > 0
%         ylim([0, max(rtt3)*1.1]);
%     end
% else
%     % 如果没有触发事件
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (N=0)', 'Location', 'northeast','FontSize', 8);
%    % title('Inter-event times under ETM');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]); % 设置一个小的范围，使图看起来正常
% end
% 
% figure(11)
% subplot(2,1,1);
% plot(t, u4_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w4z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylim([-50 50]);
% legend('$u_4(t)$','$\nu_4(t)$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% grid on;
% subplot(2,1,2);
% if ~isempty(rt4)
%     stem(rt4, rtt4, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (N=%d)', num4), 'Location', 'northeast','FontSize', 8);
%   %  title('Inter-event times under ET mechanism');
%     grid on;
%     
%     % 设置合适的坐标范围
%     xlim([0, T]);
%     if max(rtt4) > 0
%         ylim([0, max(rtt4)*1.1]);
%     end
% else
%     % 如果没有触发事件
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (N=0)', 'Location', 'northeast','FontSize', 8);
%    % title('Inter-event times under ETM');
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]); % 设置一个小的范围，使图看起来正常
% end


% %% 图8：智能体1控制输入与事件触发
% figure(8)
% subplot(2,1,1);
% plot(t, u1_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w1z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% % 计算动态y轴范围，增加10%边距
% max_val = max(abs([u1_cont; w1z]));
% if max_val == 0, max_val = 1; end
% ylim([-max_val*1.1, max_val*1.1]);
% legend('$u_1(t)$','$\nu_1(t)$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% grid on;
% hold off;
% 
% subplot(2,1,2);
% if ~isempty(rt1)
%     stem(rt1, rtt1, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (N=%d)', num1), 'Location', 'northeast','FontSize', 8);
%     grid on;
%     xlim([0, T]);
%     if max(rtt1) > 0
%         ylim([0, max(rtt1)*1.1]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (N=0)', 'Location', 'northeast','FontSize', 8);
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% %% 图9：智能体2控制输入与事件触发
% figure(9)
% subplot(2,1,1);
% plot(t, u2_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w2z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% max_val = max(abs([u2_cont; w2z]));
% if max_val == 0, max_val = 1; end
% ylim([-max_val*1.1, max_val*1.1]);
% legend('$u_2(t)$','$\nu_2(t)$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% grid on;
% hold off;
% 
% subplot(2,1,2);
% if ~isempty(rt2)
%     stem(rt2, rtt2, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (N=%d)', num2), 'Location', 'northeast','FontSize', 8);
%     grid on;
%     xlim([0, T]);
%     if max(rtt2) > 0
%         ylim([0, max(rtt2)*1.1]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (N=0)', 'Location', 'northeast','FontSize', 8);
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% %% 图10：智能体3控制输入与事件触发
% figure(10)
% subplot(2,1,1);
% plot(t, u3_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w3z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% max_val = max(abs([u3_cont; w3z]));
% if max_val == 0, max_val = 1; end
% ylim([-max_val*1.1, max_val*1.1]);
% legend('$u_3(t)$','$\nu_3(t)$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% grid on;
% hold off;
% 
% subplot(2,1,2);
% if ~isempty(rt3)
%     stem(rt3, rtt3, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (N=%d)', num3), 'Location', 'northeast','FontSize', 8);
%     grid on;
%     xlim([0, T]);
%     if max(rtt3) > 0
%         ylim([0, max(rtt3)*1.1]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (N=0)', 'Location', 'northeast','FontSize', 8);
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% %% 图11：智能体4控制输入与事件触发
% figure(11)
% subplot(2,1,1);
% plot(t, u4_cont, 'r-', 'LineWidth', 1.5); hold on;
% plot(t, w4z, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% max_val = max(abs([u4_cont; w4z]));
% if max_val == 0, max_val = 1; end
% ylim([-max_val*1.1, max_val*1.1]);
% legend('$u_4(t)$','$\nu_4(t)$', 'Interpreter', 'latex', 'Location', 'northeast','FontSize', 8);
% grid on;
% hold off;
% 
% subplot(2,1,2);
% if ~isempty(rt4)
%     stem(rt4, rtt4, 'filled', 'LineWidth', 1.5, 'MarkerSize', 4);
%     xlabel('Time(s)');
%     legend(sprintf('Triggering instants (N=%d)', num4), 'Location', 'northeast','FontSize', 8);
%     grid on;
%     xlim([0, T]);
%     if max(rtt4) > 0
%         ylim([0, max(rtt4)*1.1]);
%     end
% else
%     plot([0, T], [0, 0], 'b-', 'LineWidth', 1.5);
%     xlabel('Time(s)');
%     legend('No triggering events (N=0)', 'Location', 'northeast','FontSize', 8);
%     grid on;
%     xlim([0, T]);
%     ylim([0, 0.1]);
% end
% 
% % 图12: 神经网络权重范数图
% figure(12);
% 
% % 计算神经网络权重的范数（2-范数）
% norm_w11 = zeros(len,1);
% norm_w21 = zeros(len,1);
% norm_w31 = zeros(len,1);
% norm_w41 = zeros(len,1);
% norm_w12 = zeros(len,1);
% norm_w22 = zeros(len,1);
% norm_w32 = zeros(len,1);
% norm_w42 = zeros(len,1);
% 
% for ii = 1:len
%     norm_w11(ii) = norm(w11(:,ii));
%     norm_w21(ii) = norm(w21(:,ii));
%     norm_w31(ii) = norm(w31(:,ii));
%     norm_w41(ii) = norm(w41(:,ii));
%     norm_w12(ii) = norm(w12(:,ii));
%     norm_w22(ii) = norm(w22(:,ii));
%     norm_w32(ii) = norm(w32(:,ii));
%     norm_w42(ii) = norm(w42(:,ii));
% end
% 
% % 绘制第一个神经网络权重范数（四个智能体）
% subplot(4,2,1);
% plot(t, norm_w11, 'b-', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylabel('Norm');
% legend('$||\hat{W}_{1,1}||$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 8);
% grid on;
% 
% subplot(4,2,3);
% plot(t, norm_w21, 'r-', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylabel('Norm');
% legend('$||\hat{W}_{2,1}||$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 8);
% grid on;
% 
% subplot(4,2,5);
% plot(t, norm_w31, 'g-', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylabel('Norm');
% legend('$||\hat{W}_{3,1}||$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 8);
% grid on;
% 
% subplot(4,2,7);
% plot(t, norm_w41, 'm-', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylabel('Norm');
% legend('$||\hat{W}_{4,1}||$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 8);
% grid on;
% 
% % 绘制第二个神经网络权重范数（四个智能体）
% subplot(4,2,2);
% plot(t, norm_w12, 'b--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylabel('Norm');
% legend('$||\hat{W}_{1,2}||$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 8);
% grid on;
% 
% subplot(4,2,4);
% plot(t, norm_w22, 'r--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylabel('Norm');
% legend('$||\hat{W}_{2,2}||$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 8);
% grid on;
% 
% subplot(4,2,6);
% plot(t, norm_w32, 'g--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylabel('Norm');
% legend('$||\hat{W}_{3,2}||$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 8);
% grid on;
% 
% subplot(4,2,8);
% plot(t, norm_w42, 'm--', 'LineWidth', 1.5);
% xlabel('Time(s)');
% ylabel('Norm');
% legend('$||\hat{W}_{4,2}||$', 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 8);
% grid on;
% 
% % 调整子图间距
% sgtitle('神经网络权重范数变化', 'FontSize', 12, 'FontWeight', 'bold');