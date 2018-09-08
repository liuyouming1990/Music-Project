%%GMM obj function
function [gmmobj,mval,betaZZ]=MP_10_GMMobj(thetas)
global betaZi betaZj ngammal ngammad
%printm(thetas)
gamma_l = thetas(1:ngammal);
gamma_d = thetas(ngammal+1:ngammal+ngammad);
rho     = exp(thetas(ngammal+ngammad+1:ngammal+ngammad+7));
eta     = exp(thetas(ngammal+ngammad+8))/(1+exp(thetas(ngammal+ngammad+8)));
betaS   = thetas(ngammal+ngammad+9);
SigmaZ   = thetas(ngammal+ngammad+10:end-1); 
betaZ    = sparse(betaZi,betaZj,SigmaZ);
sigmas   = betaZ(:,2);
betaZZ   = betaZ(:,1);
mc       = thetas(end);

clear betaZ betaZs

%1. Stage 2, Time Allocation Problem
[Vs, usage_it] = MP_21_TimeAlloc(gamma_l,gamma_d,rho,eta);


%2. Stage 1, Platform Bundle Choice
[mval,share_ijt,share_ibt,shareHat,flag_maxBLP] = MP_23_MeanUtility(Vs,betaS,sigmas,mc);



%4. Calculate GMM object function
if flag_maxBLP
gmmobj = 1e10;    
else
%3. Calculate Moments
[mom1,mom2,W_mom1,W_mom2,obs1,obs2,betaZZ] = MP_24_moments(usage_it,mval,betaZZ,share_ibt,share_ijt,shareHat);
gmmobj = obs1.*mom1*(W_mom1\mom1')+obs2.*mom2*(W_mom2\mom2');
end



