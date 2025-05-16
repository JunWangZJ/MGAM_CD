clc;
close all;
clear all;

%% 1-Data input and standardisation
addpath(genpath(pwd));
X = imread('Yellow river II_t1.png');   
Y = imread('Yellow river II_t2.png');   
ref = imread('Yellow river II_ref.png');
ref = ref(:,:,1);
X_or = double(X(:,:,1))+0.1;
Y_or = double(Y(:,:,1))+0.1;
X_nor = image_normlized(X_or,'sar')+0.001;
Y_nor = image_normlized(Y_or,'sar')+0.001;
clear X Y;

%% Parameter settings
[m,n] = size(X_or); 
adj_rate = 0.001;    % adjacency ratio
ps = 2;                  % patch size
pt = 1;                   % patch division step
K =round(m*n*adj_rate);
k = K+1;                 % self-loop+1
tic,

%% Patch Division
X_p = imageTodata(X_nor,ps,pt);   
Y_p = imageTodata(Y_nor,ps,pt);   

%% Vertex attribute matching
X_ave = mean(X_p, 1);
Y_ave = mean(Y_p, 1);
X_med = median(X_p, 1);
Y_med = median(Y_p, 1);

f_ave = abs((0.5.*(log(X_ave)+log(Y_ave)))-log(0.5.*(X_ave+Y_ave))); % first item
f_med = abs(log(X_med)-log(Y_med)); % second item

f_med = f_med./max(f_med(:));
f_ave = f_ave./max(f_ave(:));
f_med_ave = (f_med + f_ave)./2;

f_v = dataToimage(f_med_ave,ps,pt,X_nor);  % change feedback
[m,n] = size(f_v);
DI_v = f_v(ps+1:m-ps, ps+1:n-ps);
DI_v = DI_v./max(DI_v(:));
% figure, imshow(DI_v);

%% Edge attribute matching
[fx_dist,fy_dist,idx, idy, Wx,Wy]  = Graphconstruction(X_p,Y_p,k); % Graph construction
f2_dist = (fx_dist + fy_dist)/2;
f2_dist_i  = dataToimage(f2_dist,ps,pt,X_or); % change feedback
[m,n] = size(f2_dist_i);
DI_e = f2_dist_i(ps+1:m-ps, ps+1:n-ps);
DI_e = DI_e./max(DI_e(:));
% figure, imshow(DI_e);

%% subgraph attribute matching
[~,N] = size(X_p);
[mm,nn] = size(fx_dist);
X_pixel_new = zeros(1,mm);
Y_pixel_new = zeros(1,mm);

for ii = 1:N
    X_pixel_new(ii) = sum(X_ave(idx(ii,:)).*Wx(ii,:))/sum(Wx(ii,:));  % subgraph attribute aggregation
end
for ii = 1:N
    X_pixel_new(ii) = sum(X_pixel_new(idx(ii,:)).*Wx(ii,:))/sum(Wx(ii,:));  % two-order subgraph attribute aggregation
end

for ii = 1:N
    Y_pixel_new(ii) = sum(Y_ave(idy(ii,:)).*Wy(ii,:))/sum(Wy(ii,:));
end
for ii = 1:N
    Y_pixel_new(ii) = sum(Y_pixel_new(idy(ii,:)).*Wy(ii,:))/sum(Wy(ii,:));
end

f_g = abs(log(X_pixel_new)-log(Y_pixel_new));
DI_subg = dataToimage(f_g,ps,pt,X_nor);
[m,n] = size(DI_subg);
DI_g = DI_subg(ps+1:m-ps, ps+1:n-ps);
DI_g = DI_g./max(DI_g(:));
% figure, imshow(DI_g);

%% Difference image generation 
DI =  DI_g + DI_v+  DI_e; 
DI = DI./max(DI(:));
% figure, imshow(DI);
TimeCT = toc

indexedImage = gray2ind(uint8(DI*255), 256); 
rgbImage = ind2rgb(indexedImage, jet(256)); 
% imshow(rgbImage);

%% Otsu
level=graythresh(DI)
CM_OTSU = im2bw(DI, level); 

ref = ref/max(ref(:));
[TPR, FPR]= Roc_plot(DI,ref, 500);
[AUC, Ddist] = AUC_Diagdistance(TPR, FPR);
[tp,fp,tn,fn,fplv,fnlv,~,~,pcc,kappa,imw]=performance(CM_OTSU,1*ref);
F1 = 2*tp/(2*tp + fp + fn);

[FP_x, FP_y] = find(imw==0);
[FN_x, FN_y] = find(imw==255);
CM_map_OTSU(:,:,1) = uint8(CM_OTSU)*255;
CM_map_OTSU(:,:,2) = uint8(CM_OTSU)*255;
CM_map_OTSU(:,:,3) = uint8(CM_OTSU)*255;
for i = 1 : max(size(FP_x))
    CM_map_OTSU(FP_x(i), FP_y(i), 1:3) = [255 0 0];
end
for i = 1 : max(size(FN_x))
    CM_map_OTSU(FN_x(i), FN_y(i), 1:3) = [0 255 0];
end

filename_OTSU = sprintf('CD_VES_OTSU_%4.5f._FN is %d; FP is %d; AUC is %4.4f; PCC is %4.4f; F1 is %4.4f; KC is %4.4f.png',  adj_rate, fn, fp, AUC, pcc, F1, kappa)
% imwrite(CM_map_OTSU, filename_OTSU);
