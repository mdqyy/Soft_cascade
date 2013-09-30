function [Cn Rn]= reorderStages(data, labels, v, C)
%reorderStages 
%labesl = {0, 1}
%v is rejection distribution vector
%C is array of structures representing the stage classifier, numel(C) ==
%numel(v)

%total stages
T = numel(v);
%positive rejection fraction
p = 0;
%execution time
m = 0;

labels = labels(:)';
b = sum(labels);
a = numel(labels) - b;
%number of negative samples used so far
A = a;
at = 0;
bt = 0;
totalData = size(data,1);
ind = ones(totalData, 1)==1;
indC = ones(T, 1)==1;
%sample responses
dt = zeros(totalData,1)';
Cn = [];
Rn = [];
cind = []
rs = evaluate(C, data);
for t=1:T
    p = p + v(t);
    bt = sum(labels(ind));
    at = sum(labels(ind)==0);
    i = findMaxStage(C, labels(ind), dt(ind), at, bt, rs(:,  ind)); 
    ct = i;
    cind(t) = ct;
    dt(ind) = dt(ind) + rs(i, ind);
    rt = findMaxThresh(dt(ind), labels(ind), p*b);
    p = p - sum((dt(ind) <= rt).*labels(ind))/b;
    %step 5
    Cn = [Cn, C(ct)];
    C(ct) = [];
    rs(ct,:) = [];
    Rn(t) = rt;
    ind(find(dt(ind) < rt)) = 0;
    
    %step 6
    
    %dt(ind) < 
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rt = findMaxThresh(dt, lb, pb)
dti = sort(dt, 'ascend');
i = numel(dt);
flags = 1;
while flags == 1 && i >=1
    rt = dti(i);
    if(sum((dt <= rt).*lb) <= pb)
        flags = 0;
    else
        i = i-1;
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rs = evaluate(C, data)

T = numel(C);

for j=1:T
    rs(j,:) = (data*C(j).w)';
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  mxInd = findMaxStage(C, labels, dt, at, bt, rs)

mxInd = 0;
maxQ  = -100000000;
T = numel(C);

for j=1:T
    ft = dt+rs(j,:);
    val = sum(ft.*labels)/bt - sum(ft.*(1-labels))/at;
    if val > maxQ || j == 1
        maxQ = val;
        mxInd = j;
    end
end
%return mxInd;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%