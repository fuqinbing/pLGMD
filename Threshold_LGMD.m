function [varargout] = Threshold_LGMD(Input, Cde, Tde, w, We, WI, p1, p2, Cw, thre)
    
    %% LGMD_parameter
    if isempty(Cde)
        Cde = 0.5;
    end
    if isempty(Tde)
        Tde = 15;
    end
    if isempty(w)
        w = [0.125 0.25 0.125;0.25 0 0.25;0.125 0.25 0.125];
    end
    if isempty(We)
        We = 1/9*ones(3,3);
    end
    if isempty(WI)
        WI = 0.3;
    end
    if  isempty(p1)
        p1 = 1/(1+exp(0));
    end
    if isempty(p2)
        p2 = 1/(1+exp(0));
    end
    if isempty(Cw)
        Cw = 3;
    end

    %% init
    [Image_H, Image_W, NumFrames] = size(Input);
    
    [P, I_thre, SUM_thre, E, Ce_thre, G_thre, G_thre1,I,E_thre,G_thre2]...
        = deal(zeros(Image_H, Image_W, NumFrames));
    
    [oumiga_thre, K_thre, k_thre] = deal(zeros(1,NumFrames));
    
    
%%    
    for t = 3:NumFrames
        %% P layer
        P(:,:,t) = Input(:,:,t) - Input(:,:,t-1) + p1*P(:,:,t-1) + p2*P(:,:,t-2);        
        %% E layer
        E(:,:,t) = P(:,:,t).*(abs(P(:,:,t))>=thre); 
        %% I layer        
        I(:,:,t) = conv2(P(:,:,t-1).*(abs(P(:,:,t-1))>=thre),w,'same');
        %% S layer
        I_thre(:,:,t) = I(:,:,t).*(abs(I(:,:,t))>=thre);
        E_thre(:,:,t) = E(:,:,t).*(abs(E(:,:,t))>=thre);
        SUM_thre(:,:,t) = E_thre(:,:,t) - I_thre(:,:,t)*WI;       
        %% 通过系数
        Ce_thre(:,:,t) = conv2(SUM_thre(:,:,t),We,'same'); 
        %% 过滤机制
        oumiga_thre(t) = max(max(abs(Ce_thre(:,:,t))))*(1/Cw) + 0.01;        
        G_thre(:,:,t) = SUM_thre(:,:,t) .* Ce_thre(:,:,t) / oumiga_thre(t);        
        %% 高通滤波
        G_thre1(:,:,t) = G_thre(:,:,t) .* (G_thre(:,:,t)*Cde>=Tde);        
        %% 激活前
        G_thre2(:,:,t) = G_thre1(:,:,t).*(abs(G_thre1(:,:,t))>=thre);
        K_thre(t) = sum(sum(abs(G_thre2(:,:,t))));
        %% 激活
        k_thre(t) = 1 / (1+exp(-K_thre(t)/(Image_H*Image_W)));
        
    end
    
    %% 设置输出
    if nargout == 1
        varargout = {k_thre};
    else
        varargout = {k_thre, K_thre, G_thre1, G_thre, oumiga_thre, Ce_thre, SUM_thre,I, I_thre, E,E_thre, P};
    end
    
end