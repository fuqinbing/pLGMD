function [varargout] = pLGMD(Input, Cde, Tde, w, We, WI, p1, p2, Cw,Prob_P,Prob_I,Prob_E, Prob_G,prob)
    
    %% pLGMD_parameter adapted from LGMD
    if isempty(Cde)
        Cde = 0.15;%Ts=Tde/Cde
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
        Cw = 4;
    end
    if isempty(Prob_P)
        Prob_P = 0.8;
    end
    if isempty(Prob_E)
        Prob_E = 0.8;
    end
    if isempty(Prob_I)
        Prob_I = 0.8;
    end
    if isempty(Prob_G)
        Prob_G = 0.8;
    end

    
    %% init
    [Image_H, Image_W, NumFrames] = size(Input);    
    [P,SUM_p, E,E_p, Ce_p, G_p,G_,I_p,G]...
        = deal(zeros(Image_H, Image_W, NumFrames));    
    [oumiga_p, K_p, k_p] = deal(zeros(1,NumFrames));  
    %% main    
    for t = 3:NumFrames
        %% P layer       
        P(:,:,t) = Input(:,:,t) - Input(:,:,t-1) + p1*P(:,:,t-1) + p2*P(:,:,t-2);        
        %% P-E               
        out_PE = randsrc(Image_H, Image_W, [0 1;1-Prob_P ,Prob_P]);
        E(:,:,t) = P(:,:,t).*out_PE ;         
        %% P-I 
        I_p(:,:,t) = CConv2_with_probability(P(:,:,t-1),w,[prob prob prob;prob 0 prob;prob prob prob]);
        %% EI-S         
        out_ES = randsrc(Image_H, Image_W, [0 1;1-Prob_E ,Prob_E]);
        out_IS = randsrc(Image_H, Image_W, [0 1;1-Prob_I ,Prob_I]);
        E_p(:,:,t) = E(:,:,t).*out_ES;
        SUM_p(:,:,t) = E_p(:,:,t) - I_p(:,:,t).*out_IS*WI;        
        %% 过滤机制
        Ce_p(:,:,t) = conv2(SUM_p(:,:,t),We,'same');         
        oumiga_p(t) = max(max(abs(Ce_p(:,:,t))))*(1/Cw) + 0.01;        
        G(:,:,t) = SUM_p(:,:,t).* Ce_p(:,:,t) / oumiga_p(t);        
        %% 高通滤波
        G_(:,:,t) = G(:,:,t).* (G(:,:,t)*Cde>=Tde);
        out_G = randsrc(Image_H, Image_W, [0 1;1-Prob_G ,Prob_G]);
        G_p(:,:,t) = G_(:,:,t).* out_G ;
        %% 激活前
        K_p(t) = sum(sum(abs(G_p(:,:,t))));
        
        %% 激活
        k_p(t) = 1 / (1+exp(-K_p(t)/(Image_H*Image_W)));
        
    end    
    %% 设置输出
    if nargout == 1
        varargout = {k_p};
    else
        varargout = {k_p,K_p, P, oumiga_p, Ce_p, SUM_p, I_p, E,E_p,G_,G_p};
    end    
end