function test_results=W_test_error_pre_LP(W_graph, labled_num, splits_num, W_name, W_folder)

addpath('.\code\label_porpagation\')

test_results.name = W_name;
for i=1:length(labled_num)
    i_s = num2str(labled_num(i));
    eval(strcat('test_results.lgc_L', i_s,'_mean_errors=0;'));
    eval(strcat('test_results.lgc_L', i_s,'_STD_errors=0;'));
    eval(strcat('test_results.grf_L', i_s,'_mean_errors=0;'));
    eval(strcat('test_results.grf_L', i_s,'_STD_errors=0;'));
    i_s = num2str(labled_num(i)-1);
    eval(strcat('test_results.lgc_LL', i_s,'_mean_errors=0;'));
    eval(strcat('test_results.lgc_LL', i_s,'_STD_errors=0;'));
    eval(strcat('test_results.grf_LL', i_s,'_mean_errors=0;'));
    eval(strcat('test_results.grf_LL', i_s,'_STD_errors=0;'));
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
            lgc_error = nan;
        end
        
        try
            lastwarn('');
            tic
            [~, ~, grf_error]=grf(W_graph.labels, labeled_ind, W_graph.W);
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
            grf_error = nan;
        end
        
        %% Results
        
        eval(strcat('test_results.lgc_L',c_l,...
            '_errors(', c_s, ')=',num2str(lgc_error*100),';'));
        eval(strcat('test_results.grf_L', c_l,...
            '_errors(', c_s, ')=',num2str(grf_error*100),';'));
        
        fprintf('labeld num=%.0f, ', labled_num(count_labled));
        fprintf('split(%.0f)= ', count_splits);
        fprintf('%d, ', W_graph.Splits(count_splits,1:labled_num(count_labled)));
        fprintf('=======> ');
        fprintf('lgc Error = %f    ', lgc_error*100);
        fprintf('grf Error = %f       ', grf_error*100);
        fprintf('lgc Time = %f    ', time_lgc);
        fprintf('grf Time = %f\n', time_grf);
        
        
    end
    %% evalute W by label propagation on Labaled part
    %     parts = floor(labled_num/100*90);
    labeled_ind = labeled_ind_by_Split(W_graph.labels, W_graph.Splits(1,1:labled_num(count_labled)));
    [W_graph.W] = labeled_W_by_ind(W_graph.W, labeled_ind);
    W_graph.labels = W_graph.labels(labeled_ind);
    for count_splits=1:labled_num
        Split = (1:labled_num);
        Split(count_splits) = [];
        labeled_ind = labeled_ind_by_Split(W_graph.labels, Split);
        %% label propagation
        %         [W_graph.W] = noise_remove(W_graph.W, W_graph.labels);
        W_g.W = W_graph.W;
        W_g.L = '';
        W_g.IS = '';
        c_l = num2str(labled_num(count_labled)-1);%count labaled
        c_s = num2str(count_splits);% count cluster
        try
            lastwarn('');
            tic
            [~, ~, lgc_error]=lgc(W_graph.labels, labeled_ind, W_g);
            time_lgc = toc;
            [warnMsg, warnId] = lastwarn;
            if ~isempty(warnId)
                eval(strcat('test_results.lgc_LL',c_l,'_Warning{', c_s, '}=[warnMsg, warnId];'));
                disp(warnMsg);
            else
                eval(strcat('test_results.lgc_LL',c_l,'_Warning{', c_s, '}=['', ''];'));
            end
        catch exception
            disp(exception.message);
            lgc_error = nan;
        end
        
        try
            lastwarn('');
            tic
            [~, ~, grf_error]=grf(W_graph.labels, labeled_ind, W_graph.W);
            time_grf = toc;
            [warnMsg, warnId] = lastwarn;
            if ~isempty(warnId)
                eval(strcat('test_results.grf_LL',c_l,'_Warning{', c_s, '}=[warnMsg, warnId];'));
                disp(warnMsg);
            else
                eval(strcat('test_results.grf_LL',c_l,'_Warning{', c_s, '}=['', ''];'));
            end
        catch exception
            disp(exception.message);
            grf_error = nan;
        end
        
        %% Results
        
        eval(strcat('test_results.lgc_LL',c_l,...
            '_errors(', c_s, ')=',num2str(lgc_error*100),';'));
        eval(strcat('test_results.grf_LL', c_l,...
            '_errors(', c_s, ')=',num2str(grf_error*100),';'));
        
        fprintf('labeld part*** labeld num=%.0f, ', labled_num(count_labled));
        fprintf(' split(%.0f)= ', count_splits);
        fprintf('%d, ',Split);
        fprintf('=======> ');
        fprintf(' lgc Error = %f    ', lgc_error*100);
        fprintf(' grf Error = %f       ', grf_error*100);
        fprintf(' lgc Time = %f    ', time_lgc);
        fprintf(' grf Time = %f\n', time_grf);
        
        
    end
    
   %% Labeled part: Error Mean & STD for one dataset per many spilits
fprintf('*******************************> \n');
for i=1:length(labled_num)
    % save lgc & grf per labeled num
    l_n = num2str(labled_num(i)-1);
    eval(strcat('test_results.lgc_LL', l_n,...
        '_mean_errors=nanmean(test_results.lgc_LL', l_n, '_errors, 2);'));
    eval(strcat('test_results.lgc_LL', l_n,...
        '_STD_errors=std(test_results.lgc_LL', l_n, '_errors, 0, 2);'));
    eval(strcat('test_results.grf_LL', l_n,...
        '_mean_errors=nanmean(test_results.grf_LL', l_n, '_errors, 2);'));
    eval(strcat('test_results.grf_LL', l_n,...
        '_STD_errors=std(test_results.grf_LL', l_n, '_errors, 0, 2);'));
    
    % for print
    eval(strcat('lgc_errors_mean= test_results.lgc_LL', l_n,'_mean_errors;'));
    eval(strcat('grf_errors_mean= test_results.grf_LL', l_n,'_mean_errors;'));
    eval(strcat('lgc_errors_std= test_results.lgc_LL', l_n,'_STD_errors;'));
    eval(strcat('grf_errors_std= test_results.grf_LL', l_n,'_STD_errors;'));
    % print
    fprintf('Labeled part: mean lgc Error(L%d)= %f ± %f  ,', labled_num(i),...
        lgc_errors_mean, lgc_errors_std);
    fprintf('Labeled part:  mean grf Error(L%d)= %f ± %f\n', labled_num(i),...
        grf_errors_mean, grf_errors_std);
    
end
%% Error Mean & STD for one dataset per many spilits
fprintf('*******************************> \n');
for i=1:length(labled_num)
    % save lgc & grf per labeled num
    l_n = num2str(labled_num(i));
    eval(strcat('test_results.lgc_L', l_n,...
        '_mean_errors=nanmean(test_results.lgc_L', l_n, '_errors, 2);'));
    eval(strcat('test_results.lgc_L', l_n,...
        '_STD_errors=std(test_results.lgc_L', l_n, '_errors, 0, 2);'));
    eval(strcat('test_results.grf_L', l_n,...
        '_mean_errors=nanmean(test_results.grf_L', l_n, '_errors, 2);'));
    eval(strcat('test_results.grf_L', l_n,...
        '_STD_errors=std(test_results.grf_L', l_n, '_errors, 0, 2);'));
    
    % for print
    eval(strcat('lgc_errors_mean= test_results.lgc_L', l_n,'_mean_errors;'));
    eval(strcat('grf_errors_mean= test_results.grf_L', l_n,'_mean_errors;'));
    eval(strcat('lgc_errors_std= test_results.lgc_L', l_n,'_STD_errors;'));
    eval(strcat('grf_errors_std= test_results.grf_L', l_n,'_STD_errors;'));
    % print
    fprintf('mean lgc Error(L%d)= %f ± %f  ,', labled_num(i),...
        lgc_errors_mean, lgc_errors_std);
    fprintf('  mean grf Error(L%d)= %f ± %f\n', labled_num(i),...
        grf_errors_mean, grf_errors_std);
end % end label propagation


test_results.W_folder = W_folder;
rmpath('.\code\label_porpagation\')
end
