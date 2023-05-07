warning('on')
% clear;
clc;
close all;
addpath('.\code\other\')
%% set paths
results_save_path = [pwd, '\results\w_test\']; % save test results on this path
report_accuracy = true;
%% diary
% diary(char(strcat(results_save_path, ['Log',datestr(now, 'yyyy_dd_mmmm_HH_MM_SS'),'.txt'])));
% diary on

%% Set parameters
splits_num = 10
labled_percent = [30] % labaled percent per class

fprintf('Start Run "auto_label_propag" on:');
disp(datetime('now'));
fprintf('\n');

% if file_dialog == true && ~exist('W_set_list', 'var')
%     %% open file dialog
%     [filename, pathname] = uigetfile({'*.mat'}, 'Pick an dataset file', 'MultiSelect', 'on');
%     
%     %This code checks if the user pressed cancel on the dialog.
%     if isequal(filename,0) || isequal(pathname,0)
%         disp('User pressed cancel');
%         clearvars -except W_set
%         return;
%     else
%         dataset_file = fullfile(pathname, filename);
%         disp(['User selected ', dataset_file]);
%         
%     end
%     if class(dataset_file) == "char"
%         all_Ws_set = load(dataset_file);
%     else
%         for i=1:length(dataset_file)
%             current_file = dataset_file(i);
%             all_Ws_set(i) = load(current_file{:});
%         end
%     end
% end

%%
% for count_w_set = 1:length(all_Ws_set)
    
    W_List = Ws_for_fusion.Ws;
    fprintf('\n\n-----------working on Dataset: %s  >> \n', Ws_for_fusion.dataset_name);
       
    total_time_tic = tic;
    W_set.splits_num = splits_num;
    for K = 1 : length(W_List)
        fprintf('Load dataset+W(%.0f of %.0f): %s   from:%s\n', K, length(W_List), W_List(K).name, W_List(K).W_folder);
        load([W_List(K).W_folder, '\', W_List(K).name]);
        % calculate labled_num form labled_percent
        for i=1:length(labled_percent)
            labled_num(i) = ceil(size(W_graph.Splits, 2) / 100 * labled_percent(i));
        end
        W_set.labled_num = labled_num;
        W_set.Splits = Ws_for_fusion.Splits;
        W_set.labels = Ws_for_fusion.labels;
        if report_accuracy == true
            W_set.Ws(K) = W_test_acc_only_add_end(Ws_for_fusion.Ws(K), W_graph, labled_num,...
                splits_num, W_List(K).name, W_List(K).W_folder);
        else
            W_set.Ws(K) = W_test_error_only_add_end(Ws_for_fusion.Ws(K), W_graph, labled_num,...
                splits_num, W_List(K).name, W_List(K).W_folder);
        end
        fprintf('\n');
    end
    total_time = toc(total_time_tic);
    fprintf('$$$$$$$$$$$$$>> Total Time = %f minutes ', total_time/60);
    % label_propagation_Accuracy = rmfield(label_propagation_Accuracy, {'POBs_lgc', 'POBs_grf'});
    W_set.dataset_name = Ws_for_fusion.dataset_name;
    W_set.graph_type = Ws_for_fusion.graph_type;
    save_file_name = strcat('W_set_test_',Ws_for_fusion.dataset_name,'_',...
        Ws_for_fusion.graph_type, '_splits', num2str(splits_num),...
        '_labeled', num2str(labled_num), '_', datestr(now, 'yyyy_dd_mmmm_HH_MM_SS'));
    save(strcat(results_save_path, save_file_name, '.mat'), 'W_set');
    %remove unnesscary field from excel
    expression = ["Warning", "POB_lgc", "W_folder", "lgc_L\d+_errors", "grf_L\d+_errors"];
    W_set.Ws = Remove_Fields(W_set.Ws, expression);
    writetable(struct2table(W_set.Ws), strcat(results_save_path, save_file_name,'.xlsx'),'WriteVariableNames', true);
    
    fprintf('\n\n');
% end
fprintf('End Run "auto_label_propag" on:');
disp(datetime('now'));
fprintf('\n');
% diary off
warning('ON')
rmpath('.\code\other\')