warning('on')
clear;
clc;
close all;
addpath('.\code\other\')
% fusion_after_end = false;
% test_eigenvalue_after_end = false;
%% set paths
all_Ws_path = [pwd, '\results\W\']; % read w matrixs from this path
results_save_path = [pwd, '\results\w_test\']; % save test results on this path

%% diary
% diary(char(strcat(results_save_path, ['Log',datestr(now, 'yyyy_dd_mmmm_HH_MM_SS'),'.txt'])));
% diary on

%% Set parameters

splits_num = 3
labled_percent = [30] % labaled percent per class
dataset_names = [ "yaleExt"]%  "pie", "yaleExt", "feret7", "pf101", "small_test1", "small_test2"
% SimGraph_NearestNeighbors: "normal_KNN" or "mutual_KNN", "SimGraph_Full", "SimGraph_Epsilon"
% "W_L1Robust", "KNN" , "newgraph", "LSP_sigma_KNN"
graph_type = ["W_L1Robust"]

% eigenvalues_laplace_type = [0, 1]
% diag_one = [false, true]
% save_eigens = false;
%'largestabs'(default), 'smallestabs', 'largestreal', 'smallestreal', 'bothendsreal'
%For nonsymmetric problems, sigma also can be: 'largestimag', 'smallestimag', 'bothendsimag', scalar
% eigenvalues_sigma = ["smallestreal", "largestreal"]
%%
fprintf('Start Run "auto_label_propag" on:');
disp(datetime('now'));
fprintf('\n');

%% check that all W sets is exist
for count_graph_type=1:length(graph_type)
    for count_datasets=1:length(dataset_names)
        fprintf('-----------Check Dataset: %s , graph Type: %s is exist on the path? >> \n',...
            dataset_names(count_datasets), graph_type(count_graph_type));
        W_path = strcat(all_Ws_path, dataset_names(count_datasets), '\', graph_type(count_graph_type));
        W_List = dir(fullfile(W_path, '*', 'w*.mat'));% '' only root folder, '**' root and subfolders, '*' only subfolders
        W_List([W_List.isdir]==1)=[];% remove directory form list and remain files
        if isempty(W_List)
            disp("W list is empty!!! (not found on the path!!!)");
            return;
        end
    end
end

%%
for count_graph_type=1:length(graph_type)
    for count_datasets=1:length(dataset_names)
        fprintf('\n\n-----------working on Dataset: %s  >> \n', dataset_names(count_datasets));
        W_path = strcat(all_Ws_path, dataset_names(count_datasets), '\', graph_type(count_graph_type));
        W_List = dir(fullfile(W_path, '*', 'w*.mat'));% '' only root folder, '**' root and subfolders, '*' only subfolders
        W_List([W_List.isdir]==1)=[];% remove directory form list and remain files
        total_time_tic = tic;
        W_set.splits_num = splits_num;
        for K = 1 : length(W_List)
            fprintf('Load dataset+W(%.0f of %.0f): %s   from:%s\n', K, length(W_List), W_List(K).name, W_List(K).folder);
            load([W_List(K).folder, '\', W_List(K).name]);
            % calculate labled_num form labled_percent
            for i=1:length(labled_percent)
                labled_num(i) = ceil(size(W_graph.Splits, 2) / 100 * labled_percent(i));
            end
            W_set.labled_num = labled_num;
            
            if ~isfield(W_set, 'Splits')
                W_set.Splits = W_graph.Splits;
            elseif ~isequal(W_set.Splits, W_graph.Splits)
                a = input('Accuracy_test.Splits ~= graph.Splits. continue(y/n)? ','s');
                if strcmpi(a,'y')
                    
                else
                    disp('Continue...');
                end
                
            end
            if ~isfield(W_set, 'labels')
                W_set.labels = W_graph.labels;
            elseif ~isequal(W_set.labels, W_graph.labels) && ~isequal(W_set.labels, W_graph.labels')
                a = input('Accuracy_test.Splits ~= graph.Splits. continue(y/n)? ','s');
                if strcmpi(a,'y')
                    
                else
                    disp('Continue...');
                end
                
            end
            %% test label propagation & Egien
            W_set.Ws(K) = W_test_acc_speratly_RN(W_graph, labled_num,...
                            splits_num, W_List(K).name, W_List(K).folder);
%             W_graph.W = normalizeData(W_graph.W);
%             W_set.Ws(K) = W_test_error_only(W_graph, labled_num,...
%                 splits_num, W_List(K).name, W_List(K).folder);
            fprintf('\n');
        end
        total_time = toc(total_time_tic);
        fprintf('$$$$$$$$$$$$$>> Total Time = %f minutes ', total_time/60);
        % label_propagation_Accuracy = rmfield(label_propagation_Accuracy, {'POBs_lgc', 'POBs_grf'});
        W_set.dataset_name = dataset_names(count_datasets);
        W_set.graph_type = graph_type(count_graph_type);
        save_file_name = strcat('W_set_test_',dataset_names(count_datasets),'_',...
            graph_type(count_graph_type), '_splits', num2str(splits_num),...
            '_labeled', num2str(labled_num), '_', datestr(now, 'yyyy_dd_mmmm_HH_MM_SS'));
        save(strcat(results_save_path, save_file_name, '.mat'), 'W_set');
%         if fusion_after_end == true || test_eigenvalue_after_end == true
%             W_set_list(count_graph_type, count_datasets) = W_set;% for run fusion test at end of this code
%         end
        %remove unnesscary field from excel
        expression = ["Warning", "POB_lgc", "W_folder"]; % "lgc_L\d+_errors", "grf_L\d+_errors"
        W_set.Ws = Remove_Fields(W_set.Ws, expression);        
        % save Excel file
        writetable(struct2table(W_set.Ws), strcat(results_save_path, save_file_name,'.xlsx'),'WriteVariableNames', true);

        clearvars -except W_set_list splits_num labled_percent dataset_names ...
            results_save_path all_Ws_path count_datasets graph_type count_graph_type ...
            eigenvalues_laplace_type diag_one eigenvalues_sigma diag_one ...
            fusion_after_end test_eigenvalue_after_end
        fprintf('\n\n');
    end
end
fprintf('End Run "auto_label_propag" on:');
disp(datetime('now'));
fprintf('\n');
diary off
warning('ON')
rmpath('.\code\other\')
% if test_eigenvalue_after_end == true
%     clearvars -except W_set_list fusion_after_end
%     auto_test_eigenvalue
% end

% run Fusion test
% if fusion_after_end == true
%     clearvars -except W_set_list
%     main_fusion
% end