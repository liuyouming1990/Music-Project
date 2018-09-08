%%% Music Platform Porject %%%
%%% By Youming Liu %%%
%%% Version 1, 7/6/2018 %%%
clear
clc

global nconsumers T
global nIterT tolT
global nrand betaZi betaZj ngammal ngammad
rng('default')
%Add paths
path(path,'Auxillary')
path(path,'D:\Program Files\Artelys\Knitro 11.0.1\knitromatlab')
%Initial Parameters
nconsumers = 1000;
T = 12;
nIterT = 500;
tolT = 1e-14;

gamma_l = [-27.5025    0.5963   -3.6518    3.8733    3.4900 ... %Const, Monthly Trend, Year Fe (2015-2017)
          -5.1670    0.1931  -10.4078    0.0106   -5.9927 ... %App Fe(2-6)
          1      1      1  0.5     0.5   0.5]; % Total & Exclusive albums/singer/labels 
ngammal = length(gamma_l);
gamma_d = [4    3    2    1    0   3]; %Age 5 group & gender
ngammad = length(gamma_d);
rho     = [1.1089   -7.3948    6.3548   -0.7947    3.8405   -5.3275    2.2840]; %rho
eta     =  -1.5897;
betaS   = 0.8169;
betaZ   = [0,-0.8256;...%constant
          0, 0;...%trend
          0, 0; %2015
          0, 0; %2016
          0, 0; %2017
           0,-6.1156;...%qqmusic
          0,-3.2548;...%kugou
           0,8.5174;...%kuwo
           0,3.2437;...%xiami
          0,8.8087];...%netease
%            0.1,0;... %fea_lyricpost
%            0.1,0;... %fea_lyricdesk
%            0.1,0;... %fea_fm
%            0.1,0;... %fea_game
%            0.1,0;... %fea_live
%            0.1, 0];... %fea_songdect
[betaZi,betaZj,betaZs] = find(betaZ);
nrand = 7+size(betaZ,1); %Number of random parameters = 7 exponential errors+ number of ZZ variables
mc     = 8.9669; %multihoming costs
%Import Data
thetas_ini = [gamma_l,gamma_d,rho,eta,betaS,betaZs',mc];
ImportData

%[gmmobj,mval]=MP_10_GMMobj(thetas_ini);
options = optimset('MaxFunEvals',2000, 'MaxIter',2000,'display','iter','TolFun',10^-3,'TolX',10^-3);%,'Algorithm','active-set');
%[thetas,fval]=knitromatlab(@(x)MP_10_GMMobj(x),thetas_ini,[],[],[],[],[],[],[],[],options);
[thetas,fval]=fminsearch(@(x)MP_10_GMMobj(x),thetas_ini,options);
%[thetas,fval]=fmincon(@(x)MP_10_GMMobj(x),thetas_ini,[],[],[],[],[],[],[],options);
%problem = createOptimProblem('fmincon','objective',@(x)MP_10_GMMobj(x),'x0',thetas_ini,'options',options);
%opts = optimoptions(@fmincon,'Algorithm','sqp');
%ms=GlobalSearch;
%[thetas,fval]=run(ms,problem);
