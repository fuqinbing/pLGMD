function C = CConv2_with_probability(A,B,Prob)
    %CConv2_with_probability
    %   ֻд�ˡ�same��
    %   A�����룬B�Ǿ���ˣ�Prob�Ǹ��ʣ��;����B�ĳߴ�һ��

    
    %% ���˵Ĺ淶��
    % ��ȡ����A�Ĵ�С
    [ma, na] = size(A);
    
    % ��ȡ�����B�Ĵ�С
    [mb, nb] = size(B);
    
    if size(Prob,1) ~= mb || size(Prob,2) ~= nb
        error('����˵ĳߴ�͸��ʲ����ߴ粻һ�£�');
    end
    
    
    if mod(mb,2) == 0 || mod(mb,2) == 0
        error('����˵ĳߴ����Ϊ����'); 
    end
    
    %% init
    mc = ma;nc = na;
    C =  zeros(mc, nc);
    
    expansion_A = zeros( ma+mb-1, na+nb-1 );
    expansion_A( (mb-1)/2+1:(mb-1)/2+ma , (nb-1)/2+1:(nb-1)/2+na ) = A;
    
    %% ����
    for ii = 1:mb
        for jj = 1:nb
            temp = expansion_A(ii:ii+mc-1, jj:jj+nc-1);
            prob_num = Prob(mb+1-ii ,nb+1-jj);
            prob_matrix = randsrc(ma, na,[0 1;1-prob_num ,prob_num]);
            C = C + B(mb+1-ii ,nb+1-jj) .* temp .* prob_matrix;
        end
    end            
end