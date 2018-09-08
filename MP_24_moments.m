%%This function is used to construct moments

function [mom1,mom2,W_mom1,W_mom2,obs1,obs2,betaZZ] = MP_24_moments(usage_it,mval,betaZZ,share_ibt,share_ijt,shareHat)

global share_age share_gender usage_age usage_gender
global share_time usage_mean
global overlap1 overlap2 op_id1 op_id2
global consumer_age consumer_gender
global nagegroup ngender
global nperiods nconsumers
global choices nchoices
global IV ZZ XX1 XX2
global appid 
%Moment 1: usage time
usageHat = squeeze(mean(sum(repmat(share_ibt,1,1,1,6).*usage_it,3),2));
usageHat_age  = zeros(nperiods,6,nagegroup-1);
for iage = 1:nagegroup-1
usageHat_age(:,:,iage)  = ...
   squeeze(sum(sum(repmat(share_ibt,1,1,1,6).*usage_it.*repmat(consumer_age==iage,1,1,63,6),3),2))./(nconsumers*usageHat);
end
usageHat_gender = ...
    squeeze(sum(sum(repmat(share_ibt,1,1,1,6).*usage_it.*repmat(consumer_gender==0,1,1,63,6),3),2))./(nconsumers*usageHat); %female
usageHat_mean = mean(usageHat,1);

mom11 = usage_mean-usageHat_mean;
obs11 = nperiods;
mom12 = reshape(usageHat_age,nperiods,6*(nagegroup-1))-repmat(reshape(usage_age(:,1:4),6*(nagegroup-1),1)',nperiods,1);
obs12 = size(mom12,1);
mom13 = reshape(usageHat_gender,nperiods,6*(ngender-1))-repmat(reshape(usage_gender(:,1),6*(ngender-1),1)',nperiods,1);
obs13 = size(mom13,1);

W_mom11 = mom11'*mom11/size(mom11,1);
W_mom12 = mom12'*mom12/size(mom12,1);
W_mom13 = mom13'*mom13/size(mom13,1);

mom1 = [mean(mom11),mean(mom12),mean(mom13)];
W_mom1 = blkdiag(W_mom11,W_mom12,W_mom13);
%W_mom1 = eye(length(mom1));
obs1 = [repmat(obs11,1,size(mom11,2)),repmat(obs12,1,size(mom12,2)),repmat(obs13,1,size(mom13,2))];

%Moment2: subscription rate

Y = reshape(mval,[],1);
Z = reshape(permute(ZZ,[1,3,2]),[],size(ZZ,2));
betaZZ = (Z'*Z)\(Z'*Y);
res = Y-Z*betaZZ;

shareHat_age = zeros(nperiods,6,nagegroup-1);
for iage = 1:nagegroup-1
shareHat_age(:,:,iage)  = ...
   squeeze(sum(share_ijt.*repmat(consumer_age==iage,1,1,6),2))./(nconsumers*shareHat);
end
shareHat_gender = squeeze(sum(share_ijt.*repmat(consumer_gender==0,1,1,6),2))./(nconsumers*shareHat);

shareOverlap = zeros(nperiods,nconsumers,length(op_id1));

for cc=1:nchoices
    choice = choices{cc};
    nplatforms = size(choice,2);
    ind = zeros(length(op_id1),1);
    for pp=1:nplatforms
      ind = ind+(op_id1==choice{pp}|op_id2==choice{pp});
      if max(ind)==2
       ind = ind==2;
       shareOverlap(:,:,ind) = shareOverlap(:,:,ind)+share_ibt(:,:,cc);
      end
    end

end
shareOverlap = squeeze(mean(shareOverlap,2));
shareOverlap1 = shareOverlap./shareHat(:,op_id1);
shareOverlap2 = shareOverlap./shareHat(:,op_id2);
mom21 = res'*IV/(nperiods*6);
obs21 = nperiods;
mom22 = reshape(shareHat_age,nperiods,6*(nagegroup-1))-repmat(reshape(share_age(:,1:4),6*(nagegroup-1),1)',nperiods,1);
obs22 = size(mom22,1);
mom23 = reshape(shareHat_gender,nperiods,6*(ngender-1))-repmat(reshape(share_gender(:,1),6*(ngender-1),1)',nperiods,1);
obs23 = size(mom23,1);
mom24 = shareOverlap1-overlap1';
obs24 = size(mom24,1);
mom25 = shareOverlap2-overlap2';
obs25 = size(mom25,1);

W_mom21 = IV'*IV;
%W_mom22 = eye(size(mom22,2));
%W_mom23 = eye(size(mom23,2));
W_mom22 = mom22'*mom22/size(mom22,1);
W_mom23 = mom23'*mom23/size(mom23,1);
W_mom24 = mom24'*mom24/size(mom24,1);
W_mom25 = mom25'*mom25/size(mom25,1);
if any(any(isnan(W_mom22)))
a=1;
end
if rank(W_mom22)<size(W_mom22,1)
W_mom22 = eye(size(W_mom22));
end
if rank(W_mom23)<size(W_mom23,1)
W_mom23 = eye(size(W_mom23));
end
if rank(W_mom24)<size(W_mom24,1)
W_mom24 = eye(size(W_mom24));
end
if rank(W_mom25)<size(W_mom25,1)
W_mom25 = eye(size(W_mom25));
end
mom2 = [mom21,mean(mom22),mean(mom23),mean(mom24),mean(mom25)];
W_mom2 = blkdiag(W_mom21,W_mom22,W_mom23,W_mom24,W_mom25);

obs2 = [repmat(obs21,1,size(mom21,2)),repmat(obs22,1,size(mom22,2)),...
    repmat(obs23,1,size(mom23,2)),repmat(obs24,1,size(mom24,2)),repmat(obs25,1,size(mom25,2))];

end