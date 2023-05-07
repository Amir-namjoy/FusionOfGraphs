% Sparse Multiple Graph Integration
% Input
%  Y: Label vector
%  L: Graph Laplacian matrices (cell array)
%  options: 
%   lambda1, lambda2: regularization parameters
%   u: initial graph weight
%   tol: stopping condition
% Author
%  M. Karasuyama
% Reference
%  M. Karasuyama and H. Mamitsuka, Multiple Graph Label 
%  Propagation by Sparse Integration, IEEE Transactions on 
%  Neural Networks and Learning Systems, vol.24. no.12, 
%  pp.1999-2012, 2013.
function [F ,u,accuracy,target,predict] = SMGI(Y, L, options,Y_u,num_labeled_data)

  maxIter = 100;
  lambda1 = 0.01;
  lambda2 = 0.1;
  tol = 1e-4;

  K = length(L);
  N = size(Y,1);
  u = ones(K,1) / K;

  if exist('options','var')
    if isfield(options,'maxIter')
      maxIter = options.maxIter;
    end
    if isfield(options,'lambda1')
      lambda1 = options.lambda1;
    end
    if isfield(options,'lambda2')
      lambda2 = options.lambda2;
    end
    if isfield(options,'u')
      u = options.u;
    end
    if isfield(options,'tol')
      tol = options.tol;
    end
  end

  % Normalizing Laplacian matrix
  for i = 1:length(L)
    L{i} = L{i} / sqrt(sum(sum(L{i}.^2)));
  end

  if lambda2 == 0
      disp 'lambada2'
    for i = 1:K
      Ltilde = lambda1*eye(N) + L{i};
      F = lambda1*(Ltilde \ Y);
      v = sum(sum(F.*(L{i}*F)));
      obj(i) = v + lambda1*sum(sum((F - Y).^2));
    end
    [minObj Lidx] = min(obj);

    u = zeros(K,1);
    u(Lidx) = 1;
    Ltilde = lambda1*eye(N) + L{Lidx};
    F = lambda1 * (Ltilde \ Y);
    return;
  end


  objPrev = inf;
  % Main iteration
  for iter = 1:maxIter
    fprintf('Iteration: %d\n', iter);
    % Update f
    Ltilde = lambda1 * eye(N);
    for i = 1:K
      Ltilde = Ltilde + u(i)*L{i};
    end
    F = lambda1*(Ltilde \ Y);

    for i = 1:K
      v(i,1) = sum(sum(F.*(L{i}*F)));
    end

    obj = u'*v + lambda1*sum(sum((F - Y).^2)) + ...
          lambda2*(u'*u/2);
    fprintf('obj = %f\n', obj);

    if (objPrev - obj)/abs(obj) <= tol
      fprintf('Iteration converges with %d iterations.\n',iter);
      break;
    end
    objPrev = obj;
    
    fprintf('u = %s \n',sprintf('%f ', u)); %khodam ezafe kardam%
    disp '.............................';
    
    % Update u
    u = solveQP(v, lambda2);
    % u = solveQP2(v, lambda2);
    fprintf('u = %s \n',sprintf('%f ', u)); 
%     disp '.............................';
  end

    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
    % this part added by me 
    
    for o=1:length(Y)
        [val,ind]=max(F(o,:));
        predict(o)=ind;
    end
    
    check=predict(num_labeled_data+1:end)'-Y_u;
    num_correct = length(find(check==0));
    num_unlabel=size(Y_u,1);   
    accuracy=(num_correct/num_unlabel)*100;
    accuracy=round(accuracy,2);
    
    predict=predict(num_labeled_data+1:end)';
    target=Y_u;
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% --------------------------------------------------
function u = solveQP(v, lambda2)

  if lambda2 == 0

    [max_v maxIdx] = max(v);
    u = zeros(length(v),1);
    u(maxIdx) = 1;
    return
  elseif lambda2 == inf

    u = ones(length(v),1) / length(v);
  end

  % k = k0;
  [sv uidx] = sort(v);
  K = length(v);

  for k = 1:K
    sum_v = sum(sv(1:k));
    eta = (lambda2 + sum_v) / k;
    u = (eta-v) ./ lambda2;
    kHat = length(find(u>0));
    if kHat == k
      break;
    end
  end

  u(u<0) = 0;
  
% --------------------------------------------------
function u = solveQP2(v, lambda2, u_old)

  if lambda2 == 0
    [max_v maxIdx] = max(v);
    u = zeros(length(v),1);
    u(maxIdx) = 1;
    return
  elseif lambda2 == inf
    u = ones(length(v),1) / length(v);
  end

  [sv uidx] = sort(v);
  K = length(v);

  sum_v = sv(1);
  eta = (lambda2 + sum_v) / 1;
  kHat = length(find(eta > sv));
  if kHat == 1
    u = (eta-v) ./ lambda2;
    u(u<0) = 0;
    return;
  end
  
  isInc = 0;
  for k = 2:K
    sum_v = sum_v + sv(k);
    etaPrev = eta;
    eta = (lambda2 + sum_v) / k;

    if isInc == 0 && etaPrev < eta
      isInc = 1;
    end

    if isInc 
      kHat = kHat + length(find(eta > sv(kHat+1:end)));
    else
      kHat = length(find(eta > sv(1:kHat)));
    end
    if k == kHat
      break;
    end
  end

  u = (eta-v) ./ lambda2;
  u(u<0) = 0;
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
