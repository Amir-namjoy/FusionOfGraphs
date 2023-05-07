function test_results=test_label_propagation(W_graph, labled_num, splits_num, W_name, W_folder)
Spectral_Clustering_type = 1;
addpath('.\code\label_porpagation\')
test_results.name = W_name;
for i=1:length(labled_num)
    i_s = num2str(labled_num(i));
    eval(strcat('test_results.lgc_L', i_s,'_mean_errors=0;'));
    eval(strcat('test_results.grf_L', i_s,'_mean_errors=0;'));
    
    eval(strcat('test_results.sum_c_biggest_eigenvalue_L', i_s,'_mean=0;'));
    eval(strcat('test_results.sum_n_c_eigenvalue_L', i_s,'_mean=0;'));
    
    %     eval(strcat('test_results.entropy_L', i_s,'_mean=0;'));
    %     eval(strcat('test_results.purity_L', i_s,'_mean=0;'));
    
    eval(strcat('test_results.lgc_L', i_s,'_STD_errors=0;'));
    eval(strcat('test_results.grf_L', i_s,'_STD_errors=0;'));
end

test_results.W_folder = W_folder;

for count_labled=1:length(labled_num)
    for count_splits=1:splits_num
        labeled_ind = labeled_ind_by_Split(W_graph.labels, W_graph.Splits(count_splits,1:labled_num(count_labled)));
        %% label propagation
        W_g.W = W_graph.W;
        W_g.L = '';
        W_g.IS = '';
        tic
        [lgc_predict, POB_lgc, lgc_error]=lgc(W_graph.labels, labeled_ind, W_g);
        time_lgc = toc;
        tic
        [grf_predict, POB_grf, grf_error]=grf(W_graph.labels, labeled_ind, W_graph.W);
        time_grf = toc;
        
        
%         % this function creat a matrix W of labaleds only
%         [W_labeled] = labeled_W_by_ind(W_graph.W, labeled_ind);
%         labels_labeled = W_graph.labels(labeled_ind);
%         %             labels_labeled
%         Clusters_num = length(unique(W_graph.labels));
%         % Spectral Clustering
%         [sum_c_biggest_eigenvalue, sum_n_c_eigenvalue, entropy, purity] = main_SPC(W_labeled, Clusters_num, Spectral_Clustering_type, labels_labeled);
%         %             [entropy, purity] = main_SPC(W, Clusters_num, Spectral_Clustering_type, labels);
        %% Results
        c_l = num2str(labled_num(count_labled));%count labaled
        c_s = num2str(count_splits);% count cluster
        eval(strcat('test_results.lgc_L',c_l,...
            '_errors(', c_s, ')=',num2str(lgc_error*100),';'));
%         eval(strcat('test_results.grf_L', c_l,...
%             '_errors(', c_s, ')=',num2str(grf_error*100),';'));
        
%         eval(strcat('test_results.sum_c_biggest_eigenvalue_L', c_l,...
%             '(', c_s, ')=',num2str(sum_c_biggest_eigenvalue),';'));
%         eval(strcat('test_results.sum_n_c_eigenvalue_L', c_l,...
%             '(', c_s, ')=',num2str(sum_n_c_eigenvalue),';'));
        
        % entropy, purity for Spectral Clustering
%         eval(strcat('test_results.entropy_L', c_l,...
%             '(', c_s, ')=',num2str(entropy),';'));
%         eval(strcat('test_results.purity_L', c_l,...
%             '(', c_s, ')=', num2str(purity),';'));
        
        %             eval(strcat('test_results.times_lgc_L',num2str(labled_num(count_labled)),...
        %                 '(',num2str(count_splits), ')=',num2str(time_lgc),';'));
        %             eval(strcat('test_results.times_grf_L',num2str(labled_num(count_labled)),...
        %                 '(',num2str(count_splits), ')=',num2str(time_grf),';'));
        %             test_results.lgc_errors(count_labled, count_splits)=lgc_error*100;
        %             test_results.grf_errors(count_labled, count_splits)=grf_error*100;
        %             test_results.times_lgc(count_labled, count_splits) = time_lgc;
        %             test_results.times_grf(count_labled, count_splits) = time_grf;
        % POB = Probability of belonging to class
        %                 test_results(K).POBs_lgc{count_run} = POB_lgc;
        %                 test_results(K).POBs_grf{count_run} = POB_grf;
        %             test_results.Labled_num(count_labled) = labled_num(count_labled);
        %             test_results.Labled_order_per_class{count_splits} = Splits(count_splits,1:labled_num(count_labled));
        
        fprintf('labeld num=%.0f, ', labled_num(count_labled));
        fprintf('split(%.0f)= ', count_splits);
        fprintf('%d, ', W_graph.Splits(count_splits,1:labled_num(count_labled)));
        fprintf('=======> ');
        fprintf('lgc Error = %f    ', lgc_error*100);
%         fprintf('grf Error = %f       ', grf_error*100);
        fprintf('lgc Time = %f    ', time_lgc);
%         fprintf('grf Time = %f\n', time_grf);
        
%         fprintf('sum c(class num) biggest eigenvalue = %f   ', sum_c_biggest_eigenvalue);
%         fprintf('sum n(samples)-c eigenvalue = %f\n', sum_n_c_eigenvalue);
        
%         fprintf('entropy for Spectral Clustering = %f   ', entropy);
%         fprintf('purity for Spectral Clustering = %f\n', purity);
        %clear vars except 'test_results' & 'labels'
        %             clearvars -except test_results labels
        %         catch exception
        %             test_results.error = exception.message;
        %             disp(['Error on dataset: ', W_name,'   folder:', W_folder]);
        %             disp(exception.message);
        %             error_count = error_count + 1;
        %         end
    end
end
% Error Mean & STD for one dataset per many spilits
fprintf('*******************************> \n');
for i=1:length(labled_num)
    % save lgc & grf per labeled num
    l_n = num2str(labled_num(i));
    eval(strcat('test_results.lgc_L', l_n,...
        '_mean_errors=mean(test_results.lgc_L', l_n, '_errors, 2);'));
%     eval(strcat('test_results.grf_L', l_n,...
%         '_mean_errors=mean(test_results.grf_L', l_n, '_errors, 2);'));
    eval(strcat('test_results.lgc_L', l_n,...
        '_STD_errors=std(test_results.lgc_L', l_n, '_errors, 0, 2);'));
%     eval(strcat('test_results.grf_L', l_n,...
%         '_STD_errors=std(test_results.grf_L', l_n, '_errors, 0, 2);'));
    
%     eval(strcat('test_results.sum_c_biggest_eigenvalue_L', l_n,...
%         '_mean=mean(test_results.sum_c_biggest_eigenvalue_L', l_n, ', 2);'));
%     eval(strcat('test_results.sum_n_c_eigenvalue_L', l_n,...
%         '_mean=mean(test_results.sum_n_c_eigenvalue_L', l_n, ', 2);'));
%     eval(strcat('test_results.sum_c_biggest_eigenvalue_L', l_n,...
%         '_STD=std(test_results.sum_c_biggest_eigenvalue_L', l_n, ', 0, 2);'));
%     eval(strcat('test_results.sum_n_c_eigenvalue_L', l_n,...
%         '_STD=std(test_results.sum_n_c_eigenvalue_L', l_n, ', 0, 2);'));
%     
    % save entropy, purity for Spectral Clustering
%     eval(strcat('test_results.entropy_L', l_n,...
%         '_mean=mean(test_results.entropy_L', l_n, ', 2);'));
%     eval(strcat('test_results.purity_L', l_n,...
%         '_mean=mean(test_results.purity_L', l_n, ', 2);'));
%     eval(strcat('test_results.entropy_L', l_n,...
%         '_STD=std(test_results.entropy_L', l_n, ', 0, 2);'));
%     eval(strcat('test_results.purity_L', l_n,...
%         '_STD=std(test_results.purity_L', l_n, ', 0, 2);'));
    
    % print
    eval(strcat('lgc_errors_mean= test_results.lgc_L', l_n,'_mean_errors;'));
%     eval(strcat('grf_errors_mean= test_results.grf_L', l_n,'_mean_errors;'));
    eval(strcat('lgc_errors_std= test_results.lgc_L', l_n,'_STD_errors;'));
%     eval(strcat('grf_errors_std= test_results.grf_L', l_n,'_STD_errors;'));
    
%     eval(strcat('sum_c_biggest_eigenvalue_mean= test_results.sum_c_biggest_eigenvalue_L', l_n,'_mean;'));
%     eval(strcat('sum_n_c_eigenvalue_mean= test_results.sum_n_c_eigenvalue_L', l_n,'_mean;'));
%     eval(strcat('sum_c_biggest_eigenvalue_std= test_results.sum_c_biggest_eigenvalue_L', l_n,'_STD;'));
%     eval(strcat('sum_n_c_eigenvalue_std= test_results.sum_n_c_eigenvalue_L', l_n,'_STD;'));
    
%     eval(strcat('entropy_mean= test_results.entropy_L', l_n,'_mean;'));
%     eval(strcat('purity_mean= test_results.purity_L', l_n,'_mean;'));
%     eval(strcat('entropy_std= test_results.entropy_L', l_n,'_STD;'));
%     eval(strcat('purity_std= test_results.purity_L', l_n,'_STD;'));
    
    fprintf('mean lgc Error(L%d)= %f ± %f  ,', labled_num(i),...
        lgc_errors_mean, lgc_errors_std);
%     fprintf('  mean grf Error(L%d)= %f ± %f\n', labled_num(i),...
%         grf_errors_mean, grf_errors_std);
    
%     fprintf('mean sum c(class num) biggest eigenvalue(L%d)= %f ± %f  ,', labled_num(i),...
%         sum_c_biggest_eigenvalue_mean, sum_c_biggest_eigenvalue_std);
%     fprintf('  mean sum n(samples)-c eigenvalue(L%d)= %f ± %f\n', labled_num(i),...
%         sum_n_c_eigenvalue_mean, sum_n_c_eigenvalue_std);
    
%     fprintf('mean entropy for Spectral Clustering(L%d)= %f ± %f  ,', labled_num(i),...
%         entropy_mean, entropy_std);
%     fprintf('  mean purity for Spectral Clustering(L%d)= %f ± %f\n', labled_num(i),...
%         purity_mean, purity_std);
    
end
% test_results.lgc_errors_mean=mean(test_results.lgc_errors, 2);
% test_results.grf_errors_mean=mean(test_results.grf_errors, 2);
% test_results.lgc_errors_std=std(test_results.lgc_errors, 0, 2);
% test_results.grf_errors_std=std(test_results.grf_errors, 0, 2);
% Time Mean & STD for one dataset per many spilits
% test_results.times_lgc_mean = mean(test_results.times_lgc, 2);
% test_results.times_grf_mean = mean(test_results.times_grf, 2);
% test_results.times_lgc_std = std(test_results.times_lgc, 0, 2);
% test_results.times_grf_std = std(test_results.times_grf, 0, 2);
rmpath('.\code\label_porpagation\')
end
