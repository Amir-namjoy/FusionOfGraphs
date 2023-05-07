function test_results=W_test_Accuracy_only(Ws_for_fusion_Ws, W_graph, labled_num, splits_num, W_name, W_folder)

addpath('.\code\label_porpagation\')
test_results = Ws_for_fusion_Ws;
test_results.name = W_name;
for i=1:length(labled_num)
    i_s = num2str(labled_num(i));
    eval(strcat('test_results.lgc_L', i_s,'_mean_Accuracys=0;'));
    eval(strcat('test_results.lgc_L', i_s,'_STD_Accuracys=0;'));
    eval(strcat('test_results.grf_L', i_s,'_mean_Accuracys=0;'));
    eval(strcat('test_results.grf_L', i_s,'_STD_Accuracys=0;'));
end

for count_labled=1:length(labled_num)
    for count_splits=1:splits_num
        labeled_ind = labeled_ind_by_Split(W_graph.labels, W_graph.Splits(count_splits,1:labled_num(count_labled)));
        %% label propagation
%         [W_graph.W] = noise_remove(W_graph.W, W_graph.labels);
        W_g.W = W_graph.W;
        W_g.L = '';
        W_g.IS = '';
        c_l = num2str(labled_num(count_labled));%count labaled
        c_s = num2str(count_splits);% count cluster
        try
            lastwarn('');
            tic
            [~, ~, lgc_error]=lgc(W_graph.labels, labeled_ind, W_g);
            lgc_Accuracy = 1 - lgc_error;
            time_lgc = toc;
            [warnMsg, warnId] = lastwarn;
            if ~isempty(warnId)
                eval(strcat('test_results.lgc_L',c_l,'_Warning{', c_s, '}=[warnMsg, warnId];'));
                disp(warnMsg);
            else
                eval(strcat('test_results.lgc_L',c_l,'_Warning{', c_s, '}=['', ''];'));
            end
        catch exception
             disp(exception.message);
            lgc_Accuracy = nan;
        end
        
        try
            lastwarn('');
            tic
            [~, ~, grf_error]=grf(W_graph.labels, labeled_ind, W_graph.W);
            grf_Accuracy = 1 - grf_error;
            time_grf = toc;
            [warnMsg, warnId] = lastwarn;
            if ~isempty(warnId)
                eval(strcat('test_results.grf_L',c_l,'_Warning{', c_s, '}=[warnMsg, warnId];'));
                disp(warnMsg);
            else
                eval(strcat('test_results.grf_L',c_l,'_Warning{', c_s, '}=['', ''];'));
            end
        catch exception
            disp(exception.message);
            grf_Accuracy = nan;
        end
        
        %% Results

        eval(strcat('test_results.lgc_L',c_l,...
            '_Accuracys(', c_s, ')=',num2str(lgc_Accuracy*100),';'));
        eval(strcat('test_results.grf_L', c_l,...
            '_Accuracys(', c_s, ')=',num2str(grf_Accuracy*100),';'));
        
        fprintf('labeld num=%.0f, ', labled_num(count_labled));
        fprintf('split(%.0f)= ', count_splits);
        fprintf('%d, ', W_graph.Splits(count_splits,1:labled_num(count_labled)));
        fprintf('=======> ');
        fprintf('lgc Accuracy = %f    ', lgc_Accuracy*100);
        fprintf('grf Accuracy = %f       ', grf_Accuracy*100);
        fprintf('lgc Time = %f    ', time_lgc);
        fprintf('grf Time = %f\n', time_grf);
        
        
    end
end
%% Accuracy Mean & STD for one dataset per many spilits
fprintf('*******************************> \n');
for i=1:length(labled_num)
    % save lgc & grf per labeled num
    l_n = num2str(labled_num(i));
    eval(strcat('test_results.lgc_L', l_n,...
        '_mean_Accuracys=nanmean(test_results.lgc_L', l_n, '_Accuracys, 2);'));
    eval(strcat('test_results.lgc_L', l_n,...
        '_STD_Accuracys=std(test_results.lgc_L', l_n, '_Accuracys, 0, 2);'));
    eval(strcat('test_results.grf_L', l_n,...
        '_mean_Accuracys=nanmean(test_results.grf_L', l_n, '_Accuracys, 2);'));
    eval(strcat('test_results.grf_L', l_n,...
        '_STD_Accuracys=std(test_results.grf_L', l_n, '_Accuracys, 0, 2);'));
    
    % for print
    eval(strcat('lgc_Accuracys_mean= test_results.lgc_L', l_n,'_mean_Accuracys;'));
    eval(strcat('grf_Accuracys_mean= test_results.grf_L', l_n,'_mean_Accuracys;'));
    eval(strcat('lgc_Accuracys_std= test_results.lgc_L', l_n,'_STD_Accuracys;'));
    eval(strcat('grf_Accuracys_std= test_results.grf_L', l_n,'_STD_Accuracys;'));
    % print
    fprintf('mean lgc Accuracy(L%d)= %f ± %f  ,', labled_num(i),...
        lgc_Accuracys_mean, lgc_Accuracys_std);
    fprintf('  mean grf Accuracy(L%d)= %f ± %f\n', labled_num(i),...
        grf_Accuracys_mean, grf_Accuracys_std);
end % end label propagation


test_results.W_folder = W_folder;
rmpath('.\code\label_porpagation\')
end
