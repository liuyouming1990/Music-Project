%%This function is calculating the mean utilities
function [mval,share_ijt,share_ibt,shareHat,flag_maxBLP] = MP_23_MeanUtility(Vs,betaS,sigmas,mc)
global tolT nIterT share_time
global nconsumers
global choices nchoices nperiods

flag_maxBLP = 0;
flagNM = 0;
tolNM = 1;
%BLP algorithm
load mval
for iterT=1:nIterT
mval_old = mval;
[shareHat,share_ijt,share_ibt] = MP_22_Share(mval,Vs,betaS,sigmas,mc);
 if flagNM == 0
 mval = mval_old+log(share_time)-log(shareHat);
 else
 mval = zeros(nperiods,6);
 for tt=1:nperiods
  deriv = zeros(6,6,nchoices);
  
  for cc=1:nchoices
    choice = choices{cc};
    nplatforms = size(choice,2);
     for pp=1:nplatforms
        ichoice = choice{pp};
        for qq=1:nplatforms
        jchoice = choice{qq};
        deriv(jchoice,ichoice,cc) = deriv(jchoice,ichoice,cc)+mean(share_ibt(tt,:,cc),2);
        end
     end  
  end
  deriv = (sum(deriv,3)-squeeze(share_ijt(tt,:,:))'*squeeze(share_ijt(tt,:,:))/nconsumers)./repmat(shareHat(tt,:)',1,6); 
  mval(tt,:) = mval_old(tt,:) + (deriv\((log(share_time(tt,:))-log(shareHat(tt,:)))'))';

 end
 end
delta = mean(mean((mval-mval_old).^2));

if delta<tolT ||  any(any(isnan(mval))) || any(any(isinf(mval)))
break;
elseif delta<tolNM
flagNM = 1;
end

end



if (iterT==nIterT) && (delta>tolT) || any(any(isnan(mval))) || any(any(isinf(mval)))
flag_maxBLP = 1;
else
save mval mval   
end


end