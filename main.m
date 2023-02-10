% 主函数
clc, clear, close all;

%% Read
PathVal = ['C:\'.mp4'];%视频路径
obj= VideoReader(PathVal);
numFrames = obj.NumFrames;%读取帧
obj_height = obj.Height;
obj_Width = obj.Width;
V = zeros(obj_height,obj_Width,numFrames);
%%把视频转为序列图像帧处理
for k = 1:numFrames
     frame = read(obj,k);
     g = double(rgb2gray(frame));
     V(:,:,k) = g; 
end
%%
   [k] = LGMD(V, [], [], [], [], [], [],[], []);%记录LGMD模型输出膜电位
%%
repeat_times =20;%pLGMD模型实验重复的次数
[Output_with_PLGMD] = deal(zeros(numFrames, repeat_times));
for j=1:10
    for iiii = 1:repeat_times        
    %%
    [k_p] = pLGMD(V, [], [], [], [], [], [],[],[], j/10,j/10,j/10,j/10,j/10);%记录pLGMD模型输出膜电位
    Output_with_PLGMD(:,iiii) = k_p;
    end
            a= mean(Output_with_PLGMD,2);
            s = std(Output_with_PLGMD,0,2);
            h1 = figure();
            H1 = confidencePlot(a,s);
            set(H1(1),'Color','b','LineWidth',1.25);
            hold on;
            plot(1:numFrames, k,'r','DisplayName','LGMD1');
            hold on;
            line([63 63],[0.4 1],'LineWidth',0.7,'LineStyle','--','color','k','DisplayName','Collision frame');
            xlim([3 numFrames]);
            ylim([0.3 1]) ;
            xlabel('frames','FontSize',20);
            ylabel('normalized membrane potential','FontSize',20);
            title('Model Response','FontSize',20);
            set(H1(3),'handlevisibility','off'); 
            legend1 = legend({'Variance', 'PLGMD','LGMD1','Collision frame'},'FontSize',11 );
            set(legend1, 'Location','Southeast');
            set(gca,'FontSize',14);
            Address = ['C:\Users\',num2str(j/10,'p=%3.1f'),'.fig'];
            Address1 = ['C:\Users\',num2str(j/10,'p=%3.1f'),'.tif'];
            saveas(h1,Address);
            saveas(h1,Address1);
end