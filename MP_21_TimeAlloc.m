%% Stage 2, Time Allocation


function [Vs, usageHat] = MP_21_TimeAlloc(gamma_l,gamma_d,rho,eta) 
global nconsumers consumer_draws nrand
global time T nperiods
global XX1 XX2
global choices nchoices
global ngammal ngammad

%Output
Vs = zeros(nperiods, nconsumers, nchoices);
usageHat = zeros(nperiods,nconsumers,nchoices,6);

%Parameters
gamma_l_all = gamma_l(1:end-3);
gamma_l_single_ex = [gamma_l(1:end-6),gamma_l(end-2:end)];
gamma_l_ex = gamma_l(end-2:end);


%Consumer Characteristics
exp_gamma_dit  = reshape(exp(reshape(consumer_draws(:,:,1:6),[],ngammad)*gamma_d'),nperiods,nconsumers);
exp_draws  = (consumer_draws(:,:,7:13)./reshape(rho,1,1,7));

%Time Allocation
for cc=1:nchoices

    choice = choices{cc};
    nplatforms = size(choice,2);
    gamma_ibt  = zeros(nperiods,nconsumers,nplatforms+1); %+1 since non-listening option
    gamma_ibt(:,:,1) = exp_draws(:,:,1); %weight of non-listening option is 1
    
    if nplatforms==1
       ichoice = choice{1};
       ljt     = XX1(:,:,ichoice); 
       gamma_ibt(:,:,2) = exp(ljt*gamma_l_single_ex').*exp_gamma_dit.*exp_draws(:,:,ichoice+1);      
    else
       for pp=1:nplatforms
       ichoice = choice{pp};
       ljt     = [XX1(:,:,ichoice),XX2(:,:,cc-6,ichoice)];
       gamma_ibt(:,:,1+pp) = exp(ljt*[gamma_l_all,gamma_l_ex]').*exp_gamma_dit.*exp_draws(:,:,ichoice+1);           
       if any(any(~isreal(gamma_ibt)))
           a=1;
       end
       end
    end
    usagetime = gamma_ibt.^(1/eta)./repmat(sum(gamma_ibt.^(1/eta),3),1,1,nplatforms+1)*T; 
    for pp=1:nplatforms
    ichoice = choice{pp};
    usageHat(:,:,cc,ichoice) = usagetime(:,:,pp+1);
    end
    Vs(:,:,cc) = sum(gamma_ibt.*usagetime.^(1-eta)./(1-eta),3);
 
end

