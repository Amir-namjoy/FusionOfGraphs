function test_results=W_test_error_speratly_RN(W_graph, labled_num, splits_num,...
    W_name, W_folder)

addpath('.\code\label_porpagation\')
test_results.name = W_name;
test_results.W_folder = W_folder;

for count_labled=1:length(labled_num)
    for count_splits=1:splits_num
        labeled_ind = labeled_ind_by_Split(W_graph.labels, W_graph.Splits(count_splits,1:labled_num(count_labled)));
        %% label propagation
        W_g.W = W_graph.W;
        W_g.L = '';
        W_g.IS = '';
        try
            lastwarn('');
            tic
            [lgc_predict, POB_lgc, lgc_error]=lgc(W_graph.labels, labeled_ind, W_g);
            time_lgc = toc;
            [warnMsg, warnId] = lastwarn;
            if ~isempty(warnId)
                if strcmpi(warnId, 'MATLAB:illConditionedMatrix')
                    disp(warnMsg);
                else
                    disp(warnMsg);
                end
            end
        catch exception
            error(exception.message);
            lgc_predict = nan;
            POB_lgc = nan;
            lgc_error = nan;
        end
        
        try
            lastwarn('');
            tic
            [grf_predict, POB_grf, grf_error]=grf(W_graph.labels, labeled_ind, W_graph.W);
            time_grf = toc;
            [warnMsg, warnId] = lastwarn;
            if ~isempty(warnId)
                if strcmpi(warnId, 'MATLAB:singularMatrix')
                    disp(warnMsg);
                else
                    disp(warnMsg);
                end
            end
        catch exception
            error(exception.message);
            grf_predict = nan;
            POB_grf = nan;
            grf_error = nan;
        end
        
        % Results
        c_l = num2str(labled_num(count_labled));%count labaled
        c_s = num2str(count_splits);% count cluster
        eval(strcat('test_results.lgc_L',c_l,...
            '_Error_split', c_s, '=',num2str(lgc_error*100),';'));
        
        eval(strcat('test_results.grf_L', c_l,...
            '_Error_split', c_s, '=',num2str(grf_error*100),';'));
        
        %% eigenvalue & eigenvector
        %this function creat a matrix W of labaleds only
%         [W_labeled] = sparse(labeled_W_by_ind(W_graph.W, labeled_ind));
        [W_labeled] = labeled_W_by_ind(W_graph.W, labeled_ind);
        labels_labeled = W_graph.labels(labeled_ind);
        [W_labeled_NR, W_labeled_Noise] = noise_remove(W_labeled, labels_labeled);
        %             labels_labeled
        sum_in_class_L = sum(W_labeled_NR(:));
        sum_Noise_L = sum(W_labeled_Noise(:));
%         entropy_in_class_L = entropy(W_labeled_NR(:));
%         entropy_Noise_L = entropy(W_labeled_Noise(:));
%         std_in_class_L = std(W_labeled_NR(:));
%         std_Noise_L = std(W_labeled_Noise(:));
        eval(strcat('test_results.sum_in_class_L', c_l,...
            '_split', c_s, '=', num2str(sum_in_class_L),';'));
        eval(strcat('test_results.sum_Noise_L', c_l,...
            '_split', c_s, '=', num2str(sum_Noise_L),';'));
        eval(strcat('test_results.sum_NR_Noise_L', c_l,...
            '_split', c_s, '=', num2str(sum_in_class_L-sum_Noise_L),';'));
        
        fprintf('labeld num=%.0f, ', labled_num(count_labled));
        fprintf('split(%.0f)= ', count_splits);
        fprintf('%d, ', W_graph.Splits(count_splits,1:labled_num(count_labled)));
        fprintf('=======> ');
        fprintf('lgc Error = %f    ', lgc_error*100);
        fprintf('grf Error = %f       ', grf_error*100);
        fprintf('lgc Time = %f    ', time_lgc);
        fprintf('grf Time = %f\n', time_grf);
        fprintf('sum_in_class= %f - sum_Noise= %f ==> %f\n', sum_in_class_L, sum_Noise_L,(sum_in_class_L-sum_Noise_L));
    end
end

rmpath('.\code\label_porpagation\')
end
