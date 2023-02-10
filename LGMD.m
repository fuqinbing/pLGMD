function [varargout] = LGMD(Input, Cde, Tde, w, We, WI, p1,p2, Cw)

    %% LGMD_parameter
    if isempty(Cde)
        Cde = 0.15;
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
    if  isempty(p2)
        p2 = 1/(1+exp(0));
    end
    if isempty(Cw)
        Cw = 4;
    end

    %% init
    [Image_H, Image_W, NumFrames] = size(Input);
    
    [P, SUM, E, I, Ce, G, G_]...
        = deal(zeros(Image_H, Image_W, NumFrames));
    
    [oumiga, K, k] = deal(zeros(1,NumFrames));
    
    
    %% main
    for t = 3:NumFrames
        %% P layer
        P(:,:,t) = Input(:,:,t) - Input(:,:,t-1) + p1*P(:,:,t-1)+ p2*P(:,:,t-2);
         %% E layer
        E(:,:,t) =P(:,:,t);        
        %% I layer
        I(:,:,t) = conv2(P(:,:,t-1),w,'same');
        %% S layer 
        SUM(:,:,t) = E(:,:,t) - I(:,:,t)*WI;        
        %% 通过系数
        Ce(:,:,t) = conv2(SUM(:,:,t),We,'same');      
        %% G层
        oumiga(t) = max(max(abs(Ce(:,:,t))))*(1/Cw) + 0.01;
        G(:,:,t) = SUM(:,:,t) .* Ce(:,:,t) / oumiga(t);        
        %% 高通滤波
        G_(:,:,t) = G(:,:,t) .* (G(:,:,t)*Cde>=Tde);   
        %% 激活前
        K(t) = sum(sum(abs(G_(:,:,t))));        
        %% 激活
        k(t) = 1 / (1+exp(-K(t)/(Image_H*Image_W)));
        
    end
    
    %% 设置输出
    if nargout == 1
        varargout = {k};
    else
        varargout = {k, K, G_, G, oumiga, Ce, SUM, I, E, P};
    end
    