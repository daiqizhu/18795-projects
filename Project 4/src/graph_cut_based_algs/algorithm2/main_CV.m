%To minimize energy A*v_i-B*v_i*v_j (B>=0, v \in {0,1}) using graph cut.
%-----------------------------------
%To implemente this code, please compile the mex file with command in the matlab window:
% mex maxflowmex_CV34.cpp
%--------------------------------
%(Only test on gcc compiler.)
%
% Code from http://math.bnu.edu.cn/~liujun/
%
%clc;

% Originally a script; changed it into a function so it takes in an input
% file path, and also writes to fileOut

function [] = main_CV(filePath, fileOut)

close all

% Check if tif; if so, convert to jpg since this code runs on jpg


filename={filePath}

for filenum=1:length(filename)
Im=imread(filename{filenum});
%Im=imresize(Im,[15 15]);

% If tif, save as jpeg then read it again
if(strfind(filePath, 'tif') ~= [])
    imwrite(Im , 'temp.jpg' , 'quality', 100);
    filename = {'temp.jpg'};
    Im = imread(filename{filenum});
end

% Make color-dimension if it's only grayscale, so it can run in this code
if(size(Im,3) == 1)
    temp = cat(3,Im,Im);
    Im = cat(3,temp,Im);
end

if filenum==1
%Im=Im(:,:,1);
Im=rgb2gray(Im);
end;

Im=mat2gray(Im);
%Im=imnoise(Im,'gaussian',0,0.1);
height= size(Im,1);
width=size(Im,2);
depth=size(Im,3);
N = height*width;

if filenum==1
K=4; % number of clusters
lambda=1.25e-1;
elseif filenum==2
    K=2;
    lambda=4e-1;
end

epsilon=1.e-6;


%initial values for means of intensity.
m={};
for k=1:K
    m{k}=repmat((max(Im(:))-min(Im(:)))/(K+1)*k,[1 1 depth]);
    Sigma(:,:,k)=eye(depth);
end


m{1}=repmat(0.4,[1 1 depth]);
m{2}=repmat(0.8,[1 1 depth]);
m{3}=repmat(0.2,[1 1 depth]);
m{4}=repmat(0.6,[1 1 depth]);
%}

f=repmat(0,[height,width,K]);
resold=repmat(0,[ceil(log2(K))*N 1]);

tic;
for iter=1:100
    %data term.
for k=1:K
    %f(:,k)=abs(Im(:)-m(k));
    f(:,:,k)=sum((Im-repmat(m{k},[height width])).^2,3);
  %  f(:,:,k)=dataterm(Im,m{k},Sigma(:,:,k));
end



if K<2^ceil(log2(K))
    for k=K+1:2^ceil(log2(K))
        f(:,:,k)=f(:,:,K);
    end
end
[flow,res] = maxflowmex_CV34(f,lambda,[height,width,1,ceil(log2(K))]);
phi=reshape(res,[height width ceil(log2(K))]);

phi=double(phi);
Lab=repmat(0,[height width]);
for k=1:ceil(log2(K))
    temp=phi(:,:,k).*2^(k-1);
    Lab=Lab+temp;
end
Lab(Lab>K-1)=K-1;




for k=1:K
    m{k}=sum(sum(Im.*repmat(double(Lab==(k-1)),[1 1 depth]),1),2)/(sum(sum(double(Lab==(k-1))))+eps);
%  temp=Im(Lab==(k-1));
 % m(k)=median(temp(:));
 
 Temp1=Im-repmat(m{k},[height width 1]);
       Temp2=Temp1.*repmat(double(Lab==(k-1)),[1 1 depth]);
       dm1=reshape(Temp1,[N, depth]);
       dm2=reshape(Temp2,[N, depth]);
       Sigma(:,:,k)=(dm1'*dm2)./sum(sum(double(Lab==(k-1))))+eps*eye(depth);
end

t=toc;

if sum((resold-double(res)).^2)<sum(double(res).^2)*epsilon
    break;
end
resold=double(res);


%figure(10)
%imagesc(Lab);
%colormap(gray);
%title(num2str(iter));
end

figure;
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
imwrite(mat2gray(Lab),fileOut);
end

end