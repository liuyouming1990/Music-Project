function [mu_ijt] = MP_31_mu(Vs,betaS,sigmas,mc)
global nperiods nchoices nconsumers
global appid choices ZZ
global consumer_draws

mu_ijt = betaS*log(Vs);

for cc=1:nchoices
    choice = choices{cc};
    nplatforms = size(choice,2);
     for pp=1:nplatforms
     ichoice = choice{pp};
     mu_ijt(:,:,cc) = mu_ijt(:,:,cc) + ...
               reshape(repmat(ZZ(:,:,ichoice),nconsumers,1)...
               .*reshape(consumer_draws(:,:,14:end),nperiods*nconsumers,size(ZZ,2))...
               *sigmas,nperiods,nconsumers);
     end
     mu_ijt(:,:,cc) = mu_ijt(:,:,cc)-nplatforms*mc; %Deduct the multihoming costs 

end