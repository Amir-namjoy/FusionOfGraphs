fusion_type = ["simple_average",  "max_POB_per_sample"];%, "Weighted_averageSTD_POB_per_sample",...
%     "max_entropy_per_sample", "max_std_per_sample",...
%     , "simple_sum", "Weighted_average_sum_std_POB_and_max_POB_per_sample",...
%     "Weighted_average_max_POB_per_sample", "Weighted_average_sum_std_and_max_POB_per_sample",...
%     "Weighted_average_sum_c_biggest_eigenvalue", "Weighted_average_sum_entropy_average",...
%     "Weighted_average_SUM_STD", "Weighted_average_SumPOB", "Weighted_average_sum_c_biggest_eigenvalue2"];
warning('off')
addpath('.\code\fusion\')
addpath('.\code\Normalize\')
addpath('.\code\label_porpagation\')

report_accuracy = true;
file_dialog = false;
split_SWICW = 1;
if file_dialog == true && ~exist('W_set_list', 'var')
    %% open file dialog
    [filename, pathname] = uigetfile({'*.mat'}, 'Pick an dataset file', 'MultiSelect', 'on');
    
    %This code checks if the user pressed cancel on the dialog.
    if isequal(filename,0) || isequal(pathname,0)
        disp('User pressed cancel');
        clearvars -except W_set
        return;
    else
        dataset_file = fullfile(pathname, filename);
        disp(['User selected ', dataset_file]);
        
    end
    if class(dataset_file) == "char"
        all_Ws_set = load(dataset_file);
    else
        for i=1:length(dataset_file)
            current_file = dataset_file(i);
            all_Ws_set(i) = load(current_file{:});
        end
    end
elseif exist('W_set_list', 'var') % passed from auto_label_propag, m file
    counter = 1;
    for count_graph_type=1:size(W_set_list, 1)
        for count_datasets=1:size(W_set_list, 2)
            all_Ws_set(counter).W_set = W_set_list(count_graph_type, count_datasets);
            counter =  counter + 1;
        end
    end
else
%     all_Ws_set = W_set;
        all_Ws_set = Ws_for_fusion;
    % all_Ws_set = [Accuracy_test_yale, Accuracy_test_pie, Accuracy_test_yale_ext];
end

Def_L = 1; % defult Labaled num for w name, for save file name
for count_w_set = 1:length(all_Ws_set)
    clearvars -except all_Ws_set count_w_set Def_L W_set_test fusion_type W_set_list W_set W
    if length(all_Ws_set)==1 % select labalel propagtion Accuracy list
        %         Ws_for_fusion = all_Ws_set.W_set; %if isfield(all_Ws_set, 'W_set_test')%diffrent file save format!
        %         Ws_for_fusion = all_Ws_set.W_set;
        Ws_for_fusion = all_Ws_set;
    else
        Ws_for_fusion = all_Ws_set(count_w_set).W_set;
    end
    
    dataset_name = Ws_for_fusion.dataset_name;
    splits_num = 10;
    labled_num = Ws_for_fusion.labled_num;
    W_num = size(Ws_for_fusion.Ws, 2);
    graph_type = Ws_for_fusion.graph_type;
    results_path = [pwd, '/results/fusion/'];
    results_path = strcat(results_path, 'W_Fusion_',num2str(W_num), '_',...
        dataset_name, '_', graph_type,'_',datestr(now, 'yyyy_dd_mmmm_HH_MM_SS'),'/');
    mkdir(results_path);
    diary(char(strcat(results_path,'Log.txt')));
    diary on
    fprintf('Start Run on:');
    disp(datetime('now'));
    fprintf('\n');
    
    %% Load all W matrix's if dont load previously
    if ~exist('W', 'var')
        W = cell(1, W_num);
        for K = 1 : W_num
%             Ws_for_fusion.Ws(K).W_folder = strrep(Ws_for_fusion.Ws(K).W_folder,'E:\Arshad\payan','C:');
            fprintf('Load dataset (%d of %d): %s   from=> %s\n', K, W_num,...
                Ws_for_fusion.Ws(K).name, Ws_for_fusion.Ws(K).W_folder);
            load(strcat(Ws_for_fusion.Ws(K).W_folder,'\', Ws_for_fusion.Ws(K).name));
            W{K} = W_graph.W;
            
%             labeled_ind = labeled_ind_by_Split(W_graph.labels, W_graph.Splits(2,1:labled_num));
%             [W{K}]=zero_WOCW_labeled_W_by_ind(W_graph.W, labeled_ind, W_graph.labels);

            %             W{K} = MinMax_Normalize(W_graph.W, 0, 1);
        end
    end
    fprintf('\n');
    
    %% Fusion
    for f_counter = 1:length(fusion_type)
        fprintf('fusion by: %s ...', fusion_type(f_counter));
        tic
        eval(strcat('[W_fusion{', num2str(f_counter),'}, Ws_for_fusion.Ws] =',...
            fusion_type(f_counter),'(Ws_for_fusion, W);'));
        time_W_fusion = toc;
        fprintf(' Done. ==> Run Time = %f Seconds\n', time_W_fusion);
    end
    fprintf('\n');
    %% Test
    for f_counter = 1:length(fusion_type)
        fprintf('Testing W Fusion(%d of %d): %s ===>\n', f_counter, length(fusion_type), fusion_type(f_counter));
        
        W_folder = results_path;
        %         W_name = '';% aval Accuracy hesab shavad to dar name w bashad!
        % propgation NEW Fusion W and calculate Accuracy
        % W_fusion{f_counter}, Ws_for_fusion.labels, , , Splits,
        W_graph_temp.W = W_fusion{f_counter};
        W_graph_temp.labels = Ws_for_fusion.labels;
        W_graph_temp.Splits = Ws_for_fusion.Splits;
       

            result_W_fusion(f_counter) = W_test_acc_only(W_graph_temp,...
                labled_num, splits_num, fusion_type(f_counter), W_folder);
  
        % for w name need: lgc_Accuracys_mean_L, grf_Accuracys_mean_L
        eval(strcat('lgc_Accuracys_mean_L= result_W_fusion(', num2str(f_counter),').lgc_L',num2str(labled_num(Def_L)),'_mean_Accuracys;'));
        eval(strcat('grf_Accuracys_mean_L= result_W_fusion(', num2str(f_counter),').grf_L',num2str(labled_num(Def_L)),'_mean_Accuracys;'));
        W_name = strcat('W_Fusion_', strrep(fusion_type(f_counter), 'metric_fusion_','') ,'_',num2str(W_num), '_', dataset_name, '_',...
            'LGC_L', num2str(labled_num(Def_L)), '_', num2str(lgc_Accuracys_mean_L),...
            '_GRF_L', num2str(labled_num(Def_L)), '_', num2str(grf_Accuracys_mean_L));
        %         result_W_fusion(f_counter).Fusion_method = fusion_type(f_counter);
        save_name = strcat(results_path,W_name, '.mat');
        eval(strcat('W_f_s = W_fusion{', num2str(f_counter),'};'));
        % save fusion results
        if isfield(Ws_for_fusion.Ws, 'POB_lgc')
            Ws_for_fusion.Ws = rmfield(Ws_for_fusion(f_counter).Ws, 'POB_lgc');
        end
        results = result_W_fusion(f_counter);
        save(save_name, 'W_f_s', 'Ws_for_fusion' , 'results');
    end
    %% save finla result: mat and xlsx
    w_result_name = strcat(results_path,'/results_W_fusion_',num2str(W_num), '_',dataset_name, '_',datestr(now, 'yyyy_dd_mmmm_HH_MM_SS'));
    save(strcat(w_result_name,'.mat'), 'result_W_fusion', 'Ws_for_fusion', 'W_folder');
    
    %remove unnesscary field from excel
    W_set = Ws_for_fusion;
    names = fieldnames(W_set.Ws);
%     Ws_for_fusion
    match = {};
    expression = ["Warning", "lgc_L\d+_Accuracys", "grf_L\d+_Accuracys", "POB_lgc", "W_folder"];
    for i = 1:length(expression)
        for j = 1:length(names)
            if ~isempty(regexp(names{j}, expression(i), 'once'))
                match{end+1} = names{j};
            end
        end
    end
    W_set.Ws = rmfield(W_set.Ws, match(:));
    % save fusion reults as Excel
    writetable(struct2table(result_W_fusion), strcat(w_result_name,'.xlsx'),'WriteVariableNames', true);
    W_fusioned_name = strcat('W_set_Fusion_', num2str(W_num), '_', dataset_name, '_', graph_type);
    % save fusied Ws list as ecxel
    writetable(struct2table(Ws_for_fusion.Ws), strcat(results_path, W_fusioned_name,'.xlsx'),'WriteVariableNames', true);
    
    
    fprintf('\n\n End Run on:');
    disp(datetime('now'));
    fprintf('\n');
    diary off
end
rmpath('.\code\fusion\')
rmpath('.\code\Normalize\')
rmpath('.\code\label_porpagation\')
warning('ON')
% play sound!
load handel;
player = audioplayer(y, Fs);
play(player);