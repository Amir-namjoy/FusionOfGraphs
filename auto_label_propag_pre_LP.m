warning('on')
clear;
clc;
close all;
fusion_after_end = false;
test_eigenvalue_after_end = false;
%% set paths
all_Ws_path = [pwd, '\results\W\']; % read w matrixs from this path
results_save_path = [pwd, '\results\w_test\']; % save test results on this path

%% diary
diary(char(strcat(results_save_path, ['Log',datestr(now, 'yyyy_dd_mmmm_HH_MM_SS'),'.txt'])));
diary on

%% Set parameters
splits_num = 10
labled_percent = [45] % labaled percent per class
dataset_names = ["pie", "yaleExt", "feret7", "pf101"]%  "pie", "yaleExt", "feret7", "pf101", "small_test1", "small_test2"
% SimGraph_NearestNeighbors: "normal_KNN" or "mutual_KNN", "SimGraph_Full", "SimGraph_Epsilon"
% "W_L1Robust", "KNN" , "newgraph", "LSP_sigma_KNN"
graph_type = ["W_L1Robust", "KNN" , "newgraph"]

% eigenvalues_laplace_type = [1, 2, 3]
% diag_one = [false]
% %'largestabs'(default), 'smallestabs', 'largestreal', 'smallestreal', 'bothendsreal'
% %For nonsymmetric problems, sigma also can be: 'largestimag', 'smallestimag', 'bothendsimag', scalar
% eigenvalues_sigma = ["largestabs",  "largestreal"; "smallestabs", "smallestreal"]
% %    "smallestabs", "smallestreal", "smallestimag",  "bothendsreal", "bothendsimag", ];

fprintf('Start Run "auto_label_propag" on:');
disp(datetime('now'));
fprintf('\n');

%% check that all W sets is exist
for count_graph_type=1:length(graph_type)
    for count_datasets=1:length(dataset_names)
        fprintf('-----------Check Dataset: %s , graph Type: %s is exist on the path? >> \n',...
            dataset_names(count_datasets), graph_type(count_graph_type));
        W_path = strcat(all_Ws_path, dataset_names(count_datasets), '\', graph_type(count_graph_type));
        W_List = dir(fullfile(W_path, '**', 'w*.mat'));
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
        W_List = dir(fullfile(W_path, '**', 'w*.mat'));
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
            %% test label propagation
            %             W_set.Ws(K) = test_label_propagation(W_graph, labled_num,...
            %                 splits_num, W_List(K).name, W_List(K).folder);
%             save_eigens = false;
%             W_set.Ws(K) = W_test_error_speratly(W_graph, labled_num,...
%                             splits_num, W_List(K).name, W_List(K).folder,...
%                             eigenvalues_laplace_type, eigenvalues_sigma, diag_one, save_eigens);
%             W_graph.W = normalizeData(W_graph.W);
            W_set.Ws(K) = W_test_error_pre_LP(W_graph, labled_num,...
                splits_num, W_List(K).name, W_List(K).folder);
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
        %remove unnesscary field from excel
        for count_labled=1:length(labled_num)
            c_l = num2str(labled_num(count_labled));%count labaled
            lgc_L = strcat('lgc_L',c_l,'_errors');
            if isfield(W_set.Ws, lgc_L)
                W_set.Ws = rmfield(W_set.Ws, lgc_L);
            end
            grf_L = strcat('grf_L',c_l,'_errors');
            if isfield(W_set.Ws, grf_L)
                W_set.Ws = rmfield(W_set.Ws, grf_L);
            end
            % warnings
            lgc_L = strcat('lgc_L',c_l,'_Warning');
            if isfield(W_set.Ws, lgc_L)
                W_set.Ws = rmfield(W_set.Ws, lgc_L);
            end
            grf_L = strcat('grf_L',c_l,'_Warning');
            if isfield(W_set.Ws, grf_L)
                W_set.Ws = rmfield(W_set.Ws, grf_L);
            end
        end
        for count_labled=1:length(labled_num)
            c_l = num2str(labled_num(count_labled)-1);%count labaled
            lgc_L = strcat('lgc_LL',c_l,'_errors');
            if isfield(W_set.Ws, lgc_L)
                W_set.Ws = rmfield(W_set.Ws, lgc_L);
            end
            grf_L = strcat('grf_LL',c_l,'_errors');
            if isfield(W_set.Ws, grf_L)
                W_set.Ws = rmfield(W_set.Ws, grf_L);
            end
            % warnings
            lgc_L = strcat('lgc_LL',c_l,'_Warning');
            if isfield(W_set.Ws, lgc_L)
                W_set.Ws = rmfield(W_set.Ws, lgc_L);
            end
            grf_L = strcat('grf_LL',c_l,'_Warning');
            if isfield(W_set.Ws, grf_L)
                W_set.Ws = rmfield(W_set.Ws, grf_L);
            end
        end
        if fusion_after_end == true || test_eigenvalue_after_end == true
            W_set_list(count_graph_type, count_datasets) = W_set;% for run fusion test at end of this code
        end
        if isfield(W_set.Ws, 'W_folder')
            W_set.Ws = rmfield(W_set.Ws, 'W_folder');
        end
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

% if test_eigenvalue_after_end == true
%     clearvars -except W_set_list fusion_after_end
%     auto_test_eigenvalue
% end

% run Fusion test
% if fusion_after_end == true
%     clearvars -except W_set_list
%     main_fusion
% end