% test in a list of test labael propagation
warning('on')
% global normalized_num ;

results_save_path = [pwd, '\results\W_test_eigenvalue\']; % save test results on this path
% diary(char(strcat(results_save_path, ['Log',datestr(now, 'yyyy_dd_mmmm_HH_MM_SS'),'.txt'])));
% diary on
fprintf('Start Run "auto_test_eigenvalue" on:');
disp(datetime('now'));
fprintf('\n');
%% set parameters
eigenvalues_laplace_type = [0, 1]

diag_one = [false, true]
save_eigens = false;
%'largestabs'(default), 'smallestabs', 'largestreal', 'smallestreal', 'bothendsreal'
%For nonsymmetric problems, sigma also can be: 'largestimag', 'smallestimag', 'bothendsimag', scalar
eigenvalues_sigma = ["smallestreal", "largestreal"]

%%
file_dialog = true;
if file_dialog == true && ~exist('W_set_list', 'var')
    %% open file dialog
    [filename, pathname] = uigetfile({'*.mat'}, 'Pick an dataset file', 'MultiSelect', 'on');
    
    %This code checks if the user pressed cancel on the dialog.
    if isequal(filename,0) || isequal(pathname,0)
        disp('User pressed cancel');
        clear
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
    all_Ws_set = W_set;
    %     all_Ws_set = [W_set_for_fusion];
    % all_Ws_set = [error_test_yale, error_test_pie, error_test_yale_ext];
end

Def_L = 1; % defult Labaled num for w name, for save file name
for count_w_set = 1:length(all_Ws_set)
    %     normalized_num = 0;
    clearvars -except all_Ws_set count_w_set Def_L W_set_test  W_set_list ...
        eigenvalues_laplace_type diag_one eigenvalues_sigma results_save_path normalized_num save_eigens
    if length(all_Ws_set)==1 % select labalel propagtion error list
        %         Ws_for_fusion = all_Ws_set.W_set; %if isfield(all_Ws_set, 'W_set_test')%diffrent file save format!
        Ws_for_fusion = all_Ws_set.W_set;
%         Ws_for_fusion = all_Ws_set;
    else
        Ws_for_fusion = all_Ws_set(count_w_set).W_set;
    end
    
    dataset_name = Ws_for_fusion.dataset_name;
    splits_num = Ws_for_fusion.splits_num;
    labled_num = Ws_for_fusion.labled_num;
    W_num = size(Ws_for_fusion.Ws, 2);
    graph_type = Ws_for_fusion.graph_type;
    %     results_path = strcat(results_save_path, 'W_eigenvalue_',num2str(W_num), '_',...
    %         dataset_name, '_', graph_type,'_',datestr(now, 'yyyy_dd_mmmm_HH_MM_SS'),'/');
    %     mkdir(results_path);
    %     diary(char(strcat(results_path,'Log.txt')));
    %     diary on
    fprintf('Start Run on:');
    disp(datetime('now'));
    fprintf('\n');
    
    %% test all W matrix's
    for K = 1 : W_num
%         Ws_for_fusion.Ws(K) = W_test_eigenvalue(Ws_for_fusion.Ws(K),...
%             eigenvalues_laplace_type, eigenvalues_sigma, diag_one);
% if eigen val vec 
                Ws_for_fusion.Ws_new(K) = W_test_eigenvalue(Ws_for_fusion.Ws(K),...
            eigenvalues_laplace_type, eigenvalues_sigma, diag_one, save_eigens);
%         Ws_for_fusion.Ws_new(K) = W_test_eigenvalue_speratly(Ws_for_fusion.Ws(K),...
%             eigenvalues_laplace_type, eigenvalues_sigma, diag_one, save_eigens);
    end
    
    % save fusied Ws list as ecxel
    if isfield(Ws_for_fusion.Ws, 'POB_lgc')
        Ws_for_fusion.Ws = rmfield(Ws_for_fusion(f_counter).Ws, 'POB_lgc');
    end
    %% save finla result: mat and xlsx
    W_eigenvalue_name = strcat('W_set_eigenvalue_', num2str(W_num), '_', dataset_name, '_', graph_type);
    save(strcat(results_save_path, W_eigenvalue_name,'.mat'), 'Ws_for_fusion');
    %remove unnesscary field from excel
    for count_labled=1:length(labled_num)
        c_l = num2str(labled_num(count_labled));%count labaled
        lgc_L = strcat('lgc_L',c_l,'_errors');
        if isfield(Ws_for_fusion.Ws_new, lgc_L)
            Ws_for_fusion.Ws_new = rmfield(Ws_for_fusion.Ws_new, lgc_L);
        end
        grf_L = strcat('grf_L',c_l,'_errors');
        if isfield(Ws_for_fusion.Ws_new, grf_L)
            Ws_for_fusion.Ws_new = rmfield(Ws_for_fusion.Ws_new, grf_L);
        end
        % warnings
        lgc_L = strcat('lgc_L',c_l,'_Warning');
        if isfield(Ws_for_fusion.Ws_new, lgc_L)
            Ws_for_fusion.Ws_new = rmfield(Ws_for_fusion.Ws_new, lgc_L);
        end
        grf_L = strcat('grf_L',c_l,'_Warning');
        if isfield(Ws_for_fusion.Ws_new, grf_L)
            Ws_for_fusion.Ws_new = rmfield(Ws_for_fusion.Ws_new, grf_L);
        end
    end
    
    if isfield(Ws_for_fusion.Ws_new, 'W_folder')
        Ws_for_fusion.Ws_new = rmfield(Ws_for_fusion.Ws_new, 'W_folder');
    end
    if isfield(Ws_for_fusion.Ws_new, 'eigenvalues')
        Ws_for_fusion.Ws_new = rmfield(Ws_for_fusion.Ws_new, 'eigenvalues');
    end
    if isfield(Ws_for_fusion.Ws_new, 'eigenvectors')
        Ws_for_fusion.Ws_new = rmfield(Ws_for_fusion.Ws_new, 'eigenvectors');
    end
    writetable(struct2table(Ws_for_fusion.Ws_new),...
        strcat(results_save_path, W_eigenvalue_name,'.xlsx'), 'WriteVariableNames', true);
    
    fprintf('\n\n End Run on:');
    disp(datetime('now'));
    fprintf('\n');
    
end
warning('ON')
fprintf('End Run "auto_test_eigenvalue" on:');
disp(datetime('now'));
fprintf('\n');
% play sound!
load handel;
player = audioplayer(y, Fs);
play(player);