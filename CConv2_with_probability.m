function C = CConv2_with_probability(A,B,Prob)
    %CConv2_with_probability
    %   只写了‘same’
    %   A是输入，B是卷积核，Prob是概率，和卷积核B的尺寸一样

    
    %% 检查核的规范性
    % 获取输入A的大小
    [ma, na] = size(A);
    
    % 获取卷积核B的大小
    [mb, nb] = size(B);
    
    if size(Prob,1) ~= mb || size(Prob,2) ~= nb
        error('卷积核的尺寸和概率参数尺寸不一致！');
    end
    
    
    if mod(mb,2) == 0 || mod(mb,2) == 0
        error('卷积核的尺寸必须为奇数'); 
    end
    
    %% init
    mc = ma;nc = na;
    C =  zeros(mc, nc);
    
    expansion_A = zeros( ma+mb-1, na+nb-1 );
    expansion_A( (mb-1)/2+1:(mb-1)/2+ma , (nb-1)/2+1:(nb-1)/2+na ) = A;
    
    %% 计算
    for ii = 1:mb
        for jj = 1:nb
            temp = expansion_A(ii:ii+mc-1, jj:jj+nc-1);
            prob_num = Prob(mb+1-ii ,nb+1-jj);
            prob_matrix = randsrc(ma, na,[0 1;1-prob_num ,prob_num]);
            C = C + B(mb+1-ii ,nb+1-jj) .* temp .* prob_matrix;
        end
    end            
end