clear;
clc;
addpath(genpath(pwd));
datasetName='BBCSport_missing20%';

dataName=[datasetName '.mat'];
load (dataName)
instance_num=size(labels,2);
% Parameter settings
neighbor_num=5;
alpha = 10;
para(1)=10;
beta=1;
para(2)=1;
tau=1;
para(3)=1;
lambda=1;
para(4)=1;
% Construct missing indicator matrices
XF=[];
for view_idx=1:view_num
    XF=[XF;X{view_idx}];
    M{view_idx} = eye(instance_num);
    M{view_idx}(zero_indices{1,view_idx},:) = [];
    W{view_idx} = eye(instance_num);
    W{view_idx}(one_indices{view_idx},:) = [];
end
gamma=10000;
XX=cell(1,view_num);
for view_idx=1:view_num
    instance_num(view_idx)=size(X_missing{view_idx},2);
    dim_num(view_idx)=size(X_missing{view_idx},1);
    XX{view_idx}=X_missing{view_idx}*M{view_idx};
end
sample_num=size(XX{1},2);
S=cell(1,view_num);
for i=1:view_num
    S{i}=Updata_Sv(X_missing{i},class_num,neighbor_num,1);
end
SC = zeros(sample_num,sample_num);
B=cell(1,view_num);
C=cell(1,view_num);
Ci2=cell(1,view_num);
d=cell(1,view_num);
D=cell(1,view_num);
for i =1:view_num
    S{i}=M{i}'*S{i}*M{i};
    SC = SC + S{i};
    bb = ones(1,sample_num);
    bb(zero_indices{1,i}) = instance_num(i)/sample_num; 
    B{i}=diag(bb);
    C{i} = ones(dim_num(i),class_num);
    D{i} = eye(dim_num(i));
end
% Initialize cluster indicator matrix Y
options.method = 'k_means';
YT = init_H(XF',class_num,options);
Y=YT';
S1=full(S{1,1});
S2=full(S{1,2});
XX1=full(XX{1,1});
XX2=full(XX{1,2});
B1=full(B{1,1});
B2=full(B{1,2});
C1=full(C{1,1});
C2=full(C{1,2});
D1=full(D{1,1});
D2=full(D{1,2});
vars_to_keep = {'C1', 'C2', 'D1', 'D2', 'XX1', 'XX2', 'S1', 'S2', 'SC', 'Y', 'B1', 'B2', 'para','vars_to_keep'};
vars_in_workspace = who;  % Get all variable names in the current workspace
% Loop through all variables in the workspace and clear those not in the list of variables to keep
for i = 1:length(vars_in_workspace)
    if ~ismember(vars_in_workspace{i}, vars_to_keep)
        clear(vars_in_workspace{i});  
    end
end
clear i vars_in_workspace vars_to_keep