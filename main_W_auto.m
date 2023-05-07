clear;
clc;
close all;

data_normalization = false;

%  "pie", "yaleExt", "feret7", "pf101", "small_test1", "small_test2"
dataset_names = ["pie", "yaleExt", "feret7", "pf101"];
dataset_names = flip(dataset_names);
% SimGraph_NearestNeighbors: "normal_KNN", "mutual_KNN", "SimGraph_Full", "SimGraph_Epsilon"
% "W_L1Robust", "KNN" , "newgraph"
graph_type = ["KNN" , "newgraph"];

tol = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.05, 1, 1.5, 2]; %W_L1Robust tolrance
tol = flip(tol);
K=[3, 5, 7, 9, 15, 27]; %KNN_graph 3, 5, 7, 10, 15, 20
sigma=[0.05, 0.1, 0.3, 0.7, 0.9, 1]; % KNN_graph , "SimGraph_NearestNeighbors", "SimGraph_Full"
epsilon = [0.25, 0.5, 0.75, 1]; % SimGraph_Epsilon
Warning_count = 0;

currentFolder = pwd;
% currentFolder = '\\172.16.0.178\c\W_L1Robust & label propagation';
% codes_path = [currentFolder, '/l1magic-1.11/l1magic/Optimization'];
% addpath(codes_path);
addpath('.\code\Normalize\')
addpath('.\code\w_graph\')
addpath('.\code\transformation\')
addpath('.\code\w_graph\l1magic-1.11\l1magic\Optimization\')

for count_graph_type=1:length(graph_type)
    for count_datasets=1:length(dataset_names)
        W_graph.dataset_name = dataset_names(count_datasets);% pie, yaleExt,  VIPeR_PCA, feret7, pf101
        W_graph.graph_type = graph_type(count_graph_type)'; % 'KNN' or 'W_L1Robust' or 'newgraph'
        results_folder = strcat(currentFolder,'\results\W\', W_graph.dataset_name, '\', W_graph.graph_type,'\');
        datasets_folder = strcat(currentFolder, '\datasets\');
        dataset_full_path = strcat(currentFolder, '\datasets\', W_graph.dataset_name);
        dataset_List = dir(fullfile(dataset_full_path, '', '*.mat')); % '' only root folder, '**' root and subfolders, '*' only subfolders
        
        for i = 1 : length(dataset_List)
            fprintf('Load dataset: %s   from=> %s\n', dataset_List(i).name, dataset_List(i).folder);
            load([dataset_List(i).folder, '\', dataset_List(i).name]);
            W_graph.datasets_folder = dataset_List(i).folder;
            W_graph.datasets_full_name = dataset_List(i).name;
            if exist('face', 'var')
                data= double(face.mat);
                W_graph.labels = face.labels;
                W_graph.Splits = face.Splits;
                clear face;
            elseif exist('Desc', 'var')
                data= double(Desc.D);
                W_graph.labels = Desc.labels;
                W_graph.Splits = Desc.Splits;
                clear Desc;
            elseif exist('TP_PCA', 'var') % W_graph.dataset_name = 'VIPeR_PCA';
                data= double(TP_PCA');
                W_graph.labels = [1:632, 1:632];
                W_graph.Splits = ones(2,632);
                W_graph.Splits(2, :) = 2;
                clear TP_PCA;
            elseif exist('descriptors_A_COG', 'var')
                data= double(TP_PCA');
                W_graph.labels = [1:632, 1:632];
                W_graph.Splits = ones(2,632);
                W_graph.Splits(2, :) = 2;
                clear descriptors_A_COG descriptors_B_COG;
            else
                disp('Warning: Can''t find "face" or "Desc" and Return!!!!!');
                Warning_count = Warning_count + 1;
                return
            end
            
            %% calculate W , L
            if strcmpi(W_graph.graph_type, 'W_L1Robust')
                tol_k_rep = length(tol);
                sig_eps_rep = 1;
                %                 "normal_KNN", "mutual_KNN", "SimGraph_Full", "SimGraph_Epsilon"
            elseif strcmpi(W_graph.graph_type, 'knn') || strcmpi(W_graph.graph_type, 'newgraph')...
                    || strcmpi(W_graph.graph_type, 'normal_KNN') || strcmpi(W_graph.graph_type, 'mutual_KNN')
                tol_k_rep = length(K);
                sig_eps_rep = length(sigma);
            elseif strcmpi(W_graph.graph_type, 'SimGraph_Full')
                tol_k_rep = 1;
                sig_eps_rep = length(sigma);
            elseif strcmpi(W_graph.graph_type, 'SimGraph_Epsilon')
                tol_k_rep = 1;
                sig_eps_rep = length(epsilon);
            elseif strcmpi(W_graph.graph_type, 'LSP_sigma_KNN')
                tol_k_rep = length(K);
                sig_eps_rep = 1;
            end
            save_folder = strcat(results_folder, dataset_List(i).name,'_',W_graph.graph_type);
            save_folder = strrep(save_folder, '.mat','');
            save_ok = false;
            for tol_k_count = 1 : tol_k_rep
                for sig_eps_count = 1 : sig_eps_rep
                    try
                        tic
                        if strcmpi(W_graph.graph_type, 'W_L1Robust')
                            W_graph.tol = tol(tol_k_count);
                            save_name = strcat('\W_tol_', num2str(W_graph.tol),'_', strrep(dataset_List(i).name,'.mat','_'), W_graph.graph_type,'.mat');
                            if exist(strcat(save_folder, save_name), 'file') == 2
                                fprintf('File: %s  Exist on path: %s \n', save_name, save_folder);
                            else
                                [W_graph.W, W_graph.D, W_graph.L] = W_L1Robust(data, W_graph.tol);
                                save_ok = true;
                            end
                        elseif strcmpi(W_graph.graph_type, 'knn')
                            W_graph.K = K(tol_k_count);
                            W_graph.sigma = sigma(sig_eps_count);
                            [W_graph.W, W_graph.L, W_graph.D, W_graph.data] = KNN_graph(data, W_graph.K, W_graph.sigma);
%                             [W_graph.W] = Build_ConsensusKNN( W_graph.W );
                            save_name = strcat('\W_K_', num2str(W_graph.K),'_sigma_',num2str(W_graph.sigma),'_', strrep(dataset_List(i).name,'.mat','_'), W_graph.graph_type,'.mat');
                            save_ok = true;
                        elseif strcmpi(W_graph.graph_type, 'newgraph')
                            %% check for normalization
                            if data_normalization == true
                                data = normalizeData(data);
                            end
                            W_graph.K = K(tol_k_count);
                            [W_graph.W, W_graph.L, W_graph.D] = newgraph({data'}, W_graph.K);
                            save_name = strcat('\W_K_', num2str(W_graph.K),'_', strrep(dataset_List(i).name,'.mat','_'), W_graph.graph_type,'.mat');
                            save_ok = true;
                        elseif strcmpi(W_graph.graph_type, "normal_KNN")
                            %% check for normalization
                            if data_normalization == true
                                data = normalizeData(data);
                            end
                            W_graph.K = K(tol_k_count);
                            W_graph.sigma = sigma(sig_eps_count);
                            W_graph.W = SimGraph_NearestNeighbors(data, W_graph.K, 1, W_graph.sigma);
                            save_name = strcat('\W_K_', num2str(W_graph.K),'_sigma_',num2str(W_graph.sigma),'_',...
                                strrep(dataset_List(i).name,'.mat','_'), W_graph.graph_type,'.mat');
                            save_ok = true;
                        elseif strcmpi(W_graph.graph_type, "mutual_KNN")
                            %% check for normalization
                            if data_normalization == true
                                data = normalizeData(data);
                            end
                            W_graph.K = K(tol_k_count);
                            W_graph.sigma = sigma(sig_eps_count);
                            W_graph.W = SimGraph_NearestNeighbors(data, W_graph.K, 2, W_graph.sigma);
                            save_name = strcat('\W_K_', num2str(W_graph.K),'_sigma_',num2str(W_graph.sigma),'_',...
                                strrep(dataset_List(i).name,'.mat','_'), W_graph.graph_type,'.mat');
                            save_ok = true;
                        elseif strcmpi(W_graph.graph_type, "SimGraph_Full")
                            %% check for normalization
                            if data_normalization == true
                                data = normalizeData(data);
                            end
                            W_graph.sigma = sigma(sig_eps_count);
                            W_graph.W = SimGraph_Full(data, W_graph.sigma);
                            save_name = strcat('\W_sigma_',num2str(W_graph.sigma),'_',...
                                strrep(dataset_List(i).name,'.mat','_'), W_graph.graph_type,'.mat');
                            save_ok = true;
                        elseif strcmpi(W_graph.graph_type, "SimGraph_Epsilon")
                            %% check for normalization
                            if data_normalization == true
                                data = normalizeData(data);
                            end
                            W_graph.epsilon = epsilon(sig_eps_count);
                            W_graph.W = SimGraph_Epsilon(data, W_graph.epsilon);
                            save_name = strcat('\W_epsilon_',num2str(W_graph.epsilon),'_',...
                                strrep(dataset_List(i).name,'.mat','_'), W_graph.graph_type,'.mat');
                            save_ok = true;
                        elseif strcmpi(W_graph.graph_type, 'LSP_sigma_KNN')
                            %% check for normalization
                            if data_normalization == true
                                data = normalizeData(data);
                            end
                            W_graph.K = K(tol_k_count);
                            [W_graph.W] = LSP_sigma_KNN(data', W_graph.K);
                            %                         [W_graph.W] = Build_ConsensusKNN( W_graph.W );
                            save_name = strcat('\W_K_', num2str(W_graph.K),'_', strrep(dataset_List(i).name,'.mat','_'), W_graph.graph_type,'.mat');
                            save_ok = true;
                        end
                        dataset_List(i).time_Minutes = toc/60;
                        %% save results
                        if save_ok
                            mkdir(save_folder);
                            save(strcat(save_folder, save_name), 'W_graph');
                        end
                        %             save([currentFolder,'/results/W/',dataset_List(K).name,'/W_all_tol_',num2str(tol(tols_count)),'_',strrep(dataset_List(K).name, '.mat', ''),'.mat'], 'W','L','D','data','labels','Splits', 'dataset_name', 'dataset_folder');
                        % imagesc(W);
                        % figure;
                        % imshow(W,[]);
                        
                    catch exception
                        %             %         movefile([dataset_List(K).folder, '\', dataset_List(K).name], [currentFolder, '/error_datasets']);
                        eval(['dataset_List(i).error', strrep(num2str(W_graph.tol),'.','_'), ' = exception.message']);
                        disp(['Error on dataset: ', dataset_List(i).folder, '\', dataset_List(i).name]);
                        disp(exception.message);
                    end
                end
            end
        end
        save(strcat(results_folder,'total ', W_graph.dataset_name, ' ', W_graph.graph_type,' ',date,'.mat'), 'dataset_List');
        clearvars -except tol K sigma dataset_names graph_type currentFolder Warning_count ...
            count_graph_type count_datasets data_normalization epsilon
        
        fprintf('\n\n');
    end
end
rmpath('.\code\w_graph\')
rmpath('.\code\transformation\')
rmpath('.\code\w_graph\l1magic-1.11\l1magic\Optimization\')
rmpath('.\code\Normalize\')
load handel;
player = audioplayer(y, Fs);
play(player);

auto_label_propag;