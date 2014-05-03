%To minimize energy A*v_i-B*v_i*v_j (B>=0, v \in {0,1}) using graph cut.
%-----------------------------------
%To implemente this code, please compile the mex file with command in the matlab window:
% mex maxflowmex_PCLSM.cpp
%--------------------------------
%(Only test on gcc compiler.)
%clc;
clear;close all;
filename={'hills.jpg'}

for filenum=1:length(filename)
Im=imread(filename{filenum});
%Im=imresize(Im,[15 15]);
if filenum==1
Im=Im(:,:,1);
end;

Im=mat2gray(Im);
%Im=imnoise(Im,'gaussian',0,0.1);
height= size(Im,1);
width=size(Im,2);
depth=size(Im,3);
N = height*width;

if filenum==1
K=7; % number of clusters
lambda=1e-1;
elseif filenum==2
    K=2;
    lambda=4e-1;
end

epsilon=1.e-6;


%initial values for means of intensity.
m={};
for k=1:K
    m{k}=repmat((max(Im(:))-min(Im(:)))/(K+1)*k,[1 1 depth]);
end

f=repmat(0,[height,width,K]);
resold=repmat(0,[(K-1)*N 1]);
for iter=1:100
    %data term.
for k=1:K
    %f(:,k)=abs(Im(:)-m(k));
    f(:,:,k)=sum((Im-repmat(m{k},[height width])).^2,3);
end

[flow,res] = maxflowmex_PCLSM(f,lambda,[height,width,1,K-1]);
phi=reshape(res,[height width K-1]);

Lab=sum(phi,3);


for k=1:K
    m{k}=sum(sum(Im.*repmat(double(Lab==(k-1)),[1 1 depth]),1),2)/(sum(sum(double(Lab==(k-1))))+eps);
%  temp=Im(Lab==(k-1));
 % m(k)=median(temp(:));
end


if sum((resold-double(res)).^2)<sum(double(res).^2)*epsilon
    break;
end
resold=double(res);


figure(1)
imagesc(Lab);
colormap(gray);
title(num2str(iter));
end

figure(2),
imshow(Im);
hold on;
for i=0:max(Lab(:))
    contour(Lab,[i i],'r');
end

%{
figure,subplot(221),imshow(Lab,[])
res=repmat(0,size(Im));
figure,
for fg=1:K
res=res+repmat(m{fg},[height width 1]).*repmat(Lab==(fg-1),[1 1 depth]);
end
figure,imshow(res,[]);
if size(res,3)==1
Labres=cat(3,res,res,res);
else size(res,3)==3
  Labres=res;
end
if filenum==1
    cx=30;
    cy=435;
elseif filenum==2
    cx=59;
    cy=268;
end

for i=0:31
    for j=0:3
Labres(cx-16+i,cy-16+j,:)=[255 0 0];
Labres(cx-16+i,cy+15+j,:)=[255 0 0];
Labres(cx-16+j,cy-16+i,:)=[255 0 0];
Labres(cx+15+j,cy-16+i,:)=[255 0 0];
    end
end
Lablocal=res(cx-16:cx+15,cy-16:cy+15,:);
imwrite(Labres,['exp2_' num2str(filenum) 'graphcutlab.bmp']);
imwrite(Lablocal,['exp2_' num2str(filenum) 'graphcutlab_local.bmp']);
imwrite(Im,['exp2_org' num2str(filenum) '.jpg']);
%}
end

