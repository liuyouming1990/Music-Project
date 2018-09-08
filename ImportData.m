load ../'Music Platform Data'/MonVariables.mat
global nperiods nrand
global time
global ZZ XX1 XX2 IV
global Newly_Released_Albums_Titles Number_of_Labels Number_of_Singers 
global ex_Albums_Titles ex_Labels_Titles ex_Singer_Titles
global choices nchoices
global appid alg
global share_time usage_mean
%Appid: 1. QQmusic 2.kugou 3.Kuwo 4.Xiami 5.Netease 6.Baidu
appid = MonVariables.appid; 
alg  = MonVariables.alg(appid==1,:);
qqmusic = 1; kugou=2; kuwo=3; xiami=4; music163=5; baidu=6;
%Usage Hours
usage = MonVariables.usage_length;
%Active Users
usrs = MonVariables.active_usrs;
%Time
time = MonVariables.date(appid==1);
nperiods = length(time);

%Featrues
fea_lyricpost = MonVariables.feature_lyricpost;
fea_lyricdesk = MonVariables.feature_lyricpost;
fea_fm        = MonVariables.feature_fm;
fea_game      = MonVariables.feature_games;
fea_live      = MonVariables.feature_live;
fea_songdect  = MonVariables.feature_songdect;

ZZ_tmp = [fea_lyricpost,fea_lyricdesk,fea_fm,fea_game,fea_live,fea_songdect];

ZZ = zeros(nperiods,1+1+3+5,6); %1 constant, 1 trend, 3 years fe, 6(5) platforms, -1 to avoid multicollinearity
ZZ(:,1,:) = 1; %constant
ZZ(13:24,3,:) = 1;%2015
ZZ(25:36,4,:) = 1;%2016
ZZ(37:43,5,:) = 1;%2017

for pp=1:6
ZZ(:,2,pp) = (1:nperiods)';
if pp>1
ZZ(:,4+pp,pp) = 1;
end
%ZZ(:,9:8+size(ZZ_tmp,2),pp) = ZZ_tmp(appid==pp,:);
end

clear ZZ_tmp




%Variables
Newly_Released_Albums_Titles = MonVariables.monthly_album;
Number_of_Labels = MonVariables.monthly_all_label;
Number_of_Singers = MonVariables.monthly_all_singer;
share  = MonVariables.share_usrs;
%For Multihoming Choices - Exclusive Variables
ex_Albums_Titles=[];
ex_Labels_Titles=[];
ex_Singer_Titles=[];
for cc=1:57
ex_choice = MonVariables.Properties.VariableNames=="ex_album_choice"+num2str(cc);
ex_Albums_Titles = [ex_Albums_Titles,table2array(MonVariables(:,ex_choice))];
ex_choice = MonVariables.Properties.VariableNames=="ex_label_choice"+num2str(cc);
ex_Labels_Titles = [ex_Labels_Titles,table2array(MonVariables(:,ex_choice))];
ex_choice = MonVariables.Properties.VariableNames=="ex_singerchoice"+num2str(cc);
ex_Singer_Titles = [ex_Singer_Titles,table2array(MonVariables(:,ex_choice))];
end
XX1_tmp = [log(Newly_Released_Albums_Titles+1),log(Number_of_Singers+1),log(Number_of_Labels+1)]; %Fixed across all choices

XX1 = zeros(nperiods,1+1+3+5+size(XX1_tmp,2),6); %1 constant, 1 trend, 3 years, 5 platforms
XX1(:,1,:) = 1;%constant
XX1(13:24,3,:) = 1;%2015
XX1(25:36,4,:) = 1; %2016
XX1(37:43,5,:) = 1; %2017
XX2 = zeros(nperiods,3,57,6);
for pp=1:6
XX1(:,2,pp) = (1:nperiods)';    
if pp>1
XX1(:,pp+4,pp) =1;
end
XX1(:,11:10+size(XX1_tmp,2),pp) = XX1_tmp(appid==pp,:);    
XX2(:,1,:,pp) = log(ex_Albums_Titles(appid==pp,:)+1);
XX2(:,2,:,pp) = log(ex_Singer_Titles(appid==pp,:)+1);
XX2(:,3,:,pp) = log(ex_Labels_Titles(appid==pp,:)+1);
end

IV = [reshape(permute(ZZ,[1,3,2]),nperiods*6,size(ZZ,2)),reshape(permute(XX1(:,end-2:end,:),[1,3,2]),nperiods*6,3)];

clear ex_choice XX1_tmp XX2


%Choice Sets - order is fixed and correspond to choice number
%Total choices 64 inlcuding the otherside options
choices={{qqmusic},{kugou},{kuwo},{xiami},{music163},{baidu},{music163 baidu},{xiami baidu},{xiami music163},{kuwo baidu},{kuwo music163},...
{kuwo xiami},{kugou baidu},{kugou music163},{kugou xiami},{kugou kuwo},{qqmusic baidu},...
{qqmusic music163},{qqmusic xiami},{qqmusic kuwo},{qqmusic kugou},{xiami music163 baidu},...
{kuwo music163 baidu},{kuwo xiami baidu},{kuwo xiami music163},{kugou music163 baidu},...
{kugou xiami baidu},{kugou xiami music163},{kugou kuwo baidu},{kugou kuwo music163},...
{kugou kuwo xiami},{qqmusic music163 baidu},{qqmusic xiami baidu},{qqmusic xiami music163},...
{qqmusic kuwo baidu},{qqmusic kuwo music163},{qqmusic kuwo xiami},{qqmusic kugou baidu},...
{qqmusic kugou music163},{qqmusic kugou xiami},{qqmusic kugou kuwo},{kuwo xiami music163 baidu},...
{kugou xiami music163 baidu},{kugou kuwo music163 baidu},{kugou kuwo xiami baidu},...
{kugou kuwo xiami music163},{qqmusic xiami music163 baidu},{qqmusic kuwo music163 baidu},...
{qqmusic kuwo xiami baidu},{qqmusic kuwo xiami music163},{qqmusic kugou music163 baidu},...
{qqmusic kugou xiami baidu},{qqmusic kugou xiami music163},{qqmusic kugou kuwo baidu},...
{qqmusic kugou kuwo music163},{qqmusic kugou kuwo xiami},{kugou kuwo xiami music163 baidu},...
{qqmusic kuwo xiami music163 baidu},{qqmusic kugou xiami music163 baidu},{qqmusic kugou kuwo music163 baidu},...
{qqmusic kugou kuwo xiami baidu},{qqmusic kugou kuwo xiami music163},{qqmusic kugou kuwo xiami music163 baidu}};
nchoices = size(choices,2);

%Generate Random Characteristics
Consumer_Draws

%Initial mval
share_time = zeros(nperiods,6);
usage_mean = zeros(nperiods,6);
for pp=1:6
share_time(:,pp) = share(appid==pp,:);
usage_mean(:,pp) = usage(appid==pp,:)./usrs(appid==pp,:);
end

mval = log(share_time) - log(1-sum(share_time,2));
save mval mval

%Micro Moments
global share_age share_gender usage_age usage_gender 
global overlap1 overlap2 op_id1 op_id2
load micro_age
load micro_gender
load micro_overlap
share_age = reshape(MicroMomentAge.prc_active_usrs_age,6,5);
share_gender = reshape(MicroMomentGender.prc_active_usrs_gender,6,2);
usage_age = reshape(MicroMomentAge.prc_usage_length_age,6,5);
usage_gender = reshape(MicroMomentGender.prc_usage_length_gender,6,2);
overlap1 = MicroOverlap.overlap_percent1;
overlap2 = MicroOverlap.overlap_percent2;
op_id1 = MicroOverlap.appid;
op_id2 = MicroOverlap.appid2;