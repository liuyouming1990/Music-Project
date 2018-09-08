function [shareHat,share_ijt,share_ibt] = MP_22_Share(mval,Vs,betaS,sigmas,mc)

global nconsumers consumer_draws nrand
global time T nperiods
global ZZ 
global Newly_Released_Albums_Titles Number_of_Labels Number_of_Singers 
global ex_Albums_Titles ex_Labels_Titles ex_Singer_Titles
global choices nchoices
global appid

%Output

share_ijt = zeros(nperiods,nconsumers,6);
%Utility of each choice

%Stochastic Part
mu_ibt = MP_31_mu(Vs,betaS,sigmas,mc);
%Utility
lambda_ibt = zeros(nperiods,nconsumers,nchoices);

for cc=1:nchoices
   choice = choices{cc};
    nplatforms = size(choice,2);
     for pp=1:nplatforms
        ichoice = choice{pp};
        lambda_ibt(:,:,cc) = lambda_ibt(:,:,cc)+mval(:,ichoice);
     end
end

lambda_ibt = lambda_ibt+mu_ibt;


share_ibt = exp(lambda_ibt)./(1+repmat(sum(exp(lambda_ibt),3),1,1,nchoices));

for cc=1:nchoices
   choice = choices{cc};
   nplatforms = size(choice,2);
     for pp=1:nplatforms
        ichoice = choice{pp};
        share_ijt(:,:,ichoice) = share_ijt(:,:,ichoice) + share_ibt(:,:,cc);
     end
end

shareHat = squeeze(mean(share_ijt,2));

