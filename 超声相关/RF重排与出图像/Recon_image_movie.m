%% 读取并保存重建的二维图像，保存成图片以及movie格式。降采样等操作
ImgData_3D = ImgDataP{1}(:,:,:); %~ ImgData是重建的二维图像，因为是原数据是4-D数据，而第三个维度数据是interbuffer，所以获取另外三维的数据即可
Img_size = size(ImgData_3D);
date = datestr(now,29);
mkdir(['./Data./Movie/' date]);
mkdir(['./Data./Image/' date]);

MoviePath = ['./Data/Movie/' date '/Recon_' num2str(Img_size(3)) 'frames_Movie.avi']; %~ 视频文件的名称
profile = 'Uncompressed AVI'; %~ 视频文件格式
writerObj = VideoWriter(MoviePath,profile); %~ 创建视频文件
open(writerObj); %~ 打开该视频文件

ImagePath = ['./Data/Image/' date];

tic
for n = 1:Img_size(3)
    figure(1);
    resize_image = imresize(ImgData_3D(:,:,n),[128 128]); %~ 将图像大小重采样至为128*128pixels，imresize函数默认使用method—'nearest'进行重采样
    resize_ImgData_3D(:,:,n) = resize_image;
    imshow(resize_image,[],'border','tight');
    set(gca,'looseInset',[0 0 0 0]); %~ 放大坐标区至充满图窗 
    axis off  %~ 不显示坐标轴
    set(gca,'xtick',[],'ytick',[],'xcolor','w','ycolor','w'); %~ 不显示刻度
    colormap(gray(256)); %~ 以灰度图显示
    frame = getframe; %~ 获取图像帧
    writeVideo(writerObj,frame); %~ 将帧写入视频文件中
    imwrite(frame.cdata,[ImagePath '/' num2str(n) '.tif']); %~ 存储图像帧
end
toc
close(writerObj); %~ 关闭视频文件句柄
savefast(['./Data/ImgData_3D_' num2str(Img_size(3)) 'f.mat'],'ImgData_3D');
savefast(['./Data/Resize_ImgData_3D_' num2str(Img_size(3)) 'f.mat'],'resize_ImgData_3D');


%% 
b(find(b>255)) = 255;


