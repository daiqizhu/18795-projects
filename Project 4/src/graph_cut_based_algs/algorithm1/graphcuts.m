% % % Grayscale image segmentation using normalized graph cuts (Shi & Malik 2000)

% input is image, a grayscale image read in via imread
% outputs are the subgraphs 
% This code is the stock code for graph cut segmentation
% This code can be modified for user's application by choosing different
% splitting points and adding constraints like minsize of the graph,
% sigmaI, sigmaX values

% % for bi-partitions uncomment lines (105-235) and run
% % for k simultaneous partitions uncomment lines (240-265) and run

function [seg_images] = graphcuts( im, k )

t0=cputime;

% resizing to avoid out of memory error
cim=imresize(im,[100 100]);
[r, c]=size(cim);
ind=find(cim);
lind=length(ind);
[I,J]=ind2sub([r,c],ind);

% % I've used linear indexing to speed up the partitioning



% vectoring the pixel nodes
for i=1:lind
       V1(i)=double(cim(ind(i)));
end

% normalizing to [0-1] scale
V=(V1./255);   


% w is the weight matrix (similarity matrix or adjacency matrix)
w=zeros(lind,lind);

% r, sigmaI, sigmaX values
rad=5;
sigi=.1;
sigx=.3;

% computing the weight matrix
for i=1:lind
    x1=I(i,1);
    y1=J(i,1);
    
    for j=1:lind
         if (i==j)
                 w(i,j)=1;
         else
          
                 x2=I(j,1);
                 y2=J(j,1);

            dist=((x1-x2)^2 + (y1-y2)^2);  
            if sqrt(dist)>=rad
                dx=0;            
            else
                dx=exp(-((dist)/(sigx^2)));
            end
  
            pdiff=(V(i)-V(j))^2;
            di=exp(-((pdiff)/(sigi)^2));  
            w(i,j)=di*dx;
        end
    
    end
end

d=zeros(lind,lind);
s=sum(w,2);

% the diagonal matrix for computing the laplacian matrix
for i=1:lind
     d(i,i)=s(i);
end

A=zeros(lind,lind);
A=(d-w); % A is the laplacian matrix

%  vt has the eigen vectors corresponding to eigen values in vl
%  other eigs / eig functions in matlab can be used but I'm using the
%  function to compute the 5 smallest eigenvectors
[vt,vl]=eigs(A,d,5,'sm');




% % % Bi - Partitions

%  fist binary partition

% se has the second smallest eigen vector, third and so on
se=vt(:,2:4);
id(:,:)=se;
id(:,4)=ind(1:length(ind));
idk=id;

% % med1 is the first splitting point, can be 0 or mean or median
% % the mean as the splitting point has the minimum Ncut value
% 
% 
% % med1=median(se(:,1));
% med1=0;
% % med1=mean(se(:,1));
% g1=find(idk(:,1)>=med1);
% gp1=idk(g1,:);
% imp1=zeros(r,c);
% imp1(gp1(:,4))=cim(gp1(:,4));
% % figure,imshow(uint8(imp1));
% 
% g2=find(idk(:,1)<med1);
% gp2=idk(g2,:);
% imp2=zeros(r,c);
% imp2(gp2(:,4))=cim(gp2(:,4));
% % figure,imshow(uint8(imp2));
% 
% 
% 
% 
% 
% 
% % % % Second level partitioning (4 subgraphs as the result )
% 
% % med2 and med3 are the splitting points for second bipartitioning 
% % med2=0;
% med2=median(gp1(:,2));
% % med2=mean(gp1(:,2));
% g11=find(gp1(:,2)>med2);
% gp11=gp1(g11,:);
% imp11=zeros(r,c);
% imp11(gp11(:,4))=cim(gp11(:,4));
% % figure,imshow(uint8(imp11));
% 
% g12=find(gp1(:,2)<=med2);
% gp12=gp1(g12,:);
% imp12=zeros(r,c);
% imp12(gp12(:,4))=cim(gp12(:,4));
% % figure,imshow(uint8(imp12));
% 
% 
% % med3=0;
% med3=median(gp2(:,2));
% % med3=mean(gp2(:,2));
% g21=find(gp2(:,2)>med3);
% gp21=gp2(g21,:);
% imp21=zeros(r,c);
% imp21(gp21(:,4))=cim(gp21(:,4));
% % figure,imshow(uint8(imp21));
% 
% g22=find(gp2(:,2)<=med3);
% gp22=gp2(g22,:);
% imp22=zeros(r,c);
% imp22(gp22(:,4))=cim(gp22(:,4));
% % figure,imshow(uint8(imp22));



% 
% % % % third level bipartioning resulting in 8 subgraphs
% % med4, med5, med6, med7 are the corresponing splitting points
% 
% % more partitions
% 
% % % % med4=0;
% % % med4=median(gp11(:,3));
% % % g111=find(gp11(:,3)>med4);
% % % gp111=gp11(g111,:);
% % % imp111=zeros(r,c);
% % % imp111(gp111(:,4))=cim(gp111(:,4));
% % % % figure,imshow(uint8(imp111));
% % % 
% % % g112=find(gp11(:,3)<=med4);
% % % gp112=gp11(g112,:);
% % % imp112=zeros(r,c);
% % % imp112(gp112(:,4))=cim(gp112(:,4));
% % % % figure,imshow(uint8(imp112));
% 
% % % % med5=0;
% % % med5=median(gp12(:,3));
% % % g121=find(gp12(:,3)>med5);
% % % gp121=gp12(g121,:);
% % % imp121=zeros(r,c);
% % % imp121(gp121(:,4))=cim(gp121(:,4));
% % % figure,imshow(uint8(imp121));
% % % 
% % % g122=find(gp12(:,3)<=med5);
% % % gp122=gp12(g122,:);
% % % imp122=zeros(r,c);
% % % imp122(gp122(:,4))=cim(gp122(:,4));
% % % figure,imshow(uint8(imp122));
% 
% % % % med6=0;
% % % med6=median(gp21(:,3));
% % % g211=find(gp21(:,3)>med6);
% % % gp211=gp21(g211,:);
% % % imp211=zeros(r,c);
% % % imp211(gp211(:,4))=cim(gp211(:,4));
% % % % figure,imshow(uint8(imp211));
% % % 
% % % g212=find(gp21(:,3)<=med6);
% % % gp212=gp21(g212,:);
% % % imp212=zeros(r,c);
% % % imp212(gp212(:,4))=cim(gp212(:,4));
% % % % figure,imshow(uint8(imp212));
% % % 
% % % % med7=0;
% % % med7=median(gp22(:,3));
% % % g221=find(gp22(:,3)>med7);
% % % gp221=gp22(g221,:);
% % % imp221=zeros(r,c);
% % % imp221(gp221(:,4))=cim(gp221(:,4));
% % % % figure,imshow(uint8(imp221));
% % % 
% % % g222=find(gp22(:,3)<=med7);
% % % gp222=gp22(g222,:);
% % % imp222=zeros(r,c);
% % % imp222(gp222(:,4))=cim(gp222(:,4));
% % % % figure,imshow(uint8(imp222));

% figure;
% subplot(2,4,1);imshow(uint8(im));title('Original image');
% subplot(2,4,2);imshow(uint8(cim));title('Preprocessed image');
% subplot(2,4,3);imshow(uint8(imp1));title('Partition 1');
% subplot(2,4,4);imshow(uint8(imp2));title('Partition 2');
% subplot(2,4,5);imshow(uint8(imp11));title('Partition 1-1');
% subplot(2,4,6);imshow(uint8(imp12));title('Partition 1-2');
% subplot(2,4,7);imshow(uint8(imp21));title('Partition 2-1');
% subplot(2,4,8);imshow(uint8(imp22));title('Partition 2-2');




% % % % % Simultaneous 'k' partitions

id=kmeans(se,k);
imp=cell(1,k);
pic=cell(1,k);

seg_images = cell(1,k);

for i=1:k
    imp{1,i}= find(id(:,1)==i);
    mat=zeros(100,100);
    in=imp{1,i};
    mat(in)=cim(in);
    % pic{1,i}= (uint8(mat) ~= 0) * i / k * 255.0;
    pic{1,i} = uint8(mat);
    seg_images{i} = pic{1,i};
%     figure,imshow(pic{1,i});
end


% pic has the sub graphs or partitiond sub images

% figure;
% subplot(2,4,1);imshow(uint8(im));title('Original image');
% subplot(2,4,2);imshow(uint8(cim));title('Preprocessed image');
% subplot(2,4,3);imshow(pic{1,1});title('Partition 1');
% subplot(2,4,4);imshow(pic{1,2});title('Partition 2');
% subplot(2,4,5);imshow(pic{1,3});title('Partition 3');
% subplot(2,4,6);imshow(pic{1,4});title('Partition 4');
% subplot(2,4,7);imshow(pic{1,5});title('Partition 5');
% subplot(2,4,8);imshow(pic{1,6});title('Partition 6');

% seg_image = uint8(seg_image);
t1=cputime-t0;
end
