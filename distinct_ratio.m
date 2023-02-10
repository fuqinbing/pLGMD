% 主函数 用于寻找最优概率参数
clc, clear, close all;
%% Read
PathVal = ['C:\Users\'];%视频路径
obj= VideoReader(PathVal);
numFrames = obj.NumberOfFrames;
obj_height = obj.Height;
obj_Width = obj.Width;
V = zeros(obj_height,obj_Width,numFrames);
%% 把视频转为序列图像帧处理
for k = 1:numFrames
     frame = read(obj,k);
     g = im2double(rgb2gray(frame));
     V(:,:,k) = g*255; 
end
%%
 repeat_times = 20;%pLGMD重复实验次数
 [Maximum_p, ratio] = deal(zeros(20,repeat_times));
 Maximum = zeros(1,20);
 ratio1 = deal(zeros(1,20));
 [record,record1] = deal(zeros(20, repeat_times,numFrames));
 [k] = LGMD(V, [], [], [], [], [], [],[], []);%记录LGMD输出的膜点位
 %%
for j=1:20%概率从0.05开始遍历到1
     for iiii = 1:repeat_times      
%%
    [k_p] = pLGMD(V, [], [], [], [], [], [],[],[], j/20,j/20,j/20,j/20,j/20);  %记录pLGMD输出的膜点位 
    Maximum_p(j,iiii)=max(k_p);%记录pLGMD膜电位的峰值
    record(j,iiii,3:numFrames) = k_p(3:numFrames);
    ratio(j,iiii) = Maximum_p(j,iiii)-(sum(record(j,iiii,3:numFrames),3)-Maximum_p(j,iiii))/numFrames;
     end
           a = mean(ratio,2);
           s = std(ratio,0,2);
           Maximum(j) = max(k);%记录LGMD膜电位的峰值
           record1(3:numFrames) = k(3:numFrames);
           ratio1(j) = Maximum(j)-(sum(record1(3:numFrames))-max(k))/numFrames;          
end
%% 绘图
          h1 = figure();
          H1 = confidencePlot(a,s);
          set(H1(1),'Color','b','LineWidth',1.25);
          hold on;          
          plot(1:20, ratio1,'r','DisplayName','LGMD1');
          hold on;
          line([0.7 0.7],[0.4 1],'LineWidth',0.7,'LineStyle','--','color','k','DisplayName','Collision frame');
          xticks([1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]);
          xticklabels({'0.05','0.1','0.15','0.2','0.25','0.3','0.35','0.4','0.45','0.5','0.55','0.6','0.65','0.7','0.75','0.8','0.85','0.9','0.95','1'});
          line([11 11],[0 0.5],'LineWidth',0.8,'LineStyle','--','color','k','DisplayName','Optimal parameter');
          xlim([1 20]);
          set(H1(3),'handlevisibility','off');
          set(gca,'FontSize',12);
          xlabel('probability','FontSize',24);
          ylabel('distinct ratio','FontSize',24); 
          legend1 = legend('Variance', 'PLGMD','LGMD1','OP','FontSize',13);
          set(legend1, 'Location','Southeast');
          Address = ['C:\Users\','.fig'];
          Address1 = ['C:\Users\','.tif'];
          saveas(h1,Address);
          saveas(h1,Address1);
