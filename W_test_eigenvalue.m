function W_for_eigen=W_test_eigenvalue(W_for_eigen,...
    eigenvalues_laplace_type, eigenvalues_sigma, diag_one, save_eigens)
% global normalized_num;
addpath('.\code\clustring\')
addpath('.\code\Normalize\')
addpath('.\code\label_porpagation\')
addpath('.\code\clustring\')
addpath('.\code\other\')
%% load W
% if ~(exist(strcat(W_for_eigen.W_folder, '\', W_for_eigen.name), 'file') == 2)
%
% end
W_for_eigen.W_folder = strrep(W_for_eigen.W_folder, '.mat', '');
fprintf('Load W:  %s   from=> %s\n',W_for_eigen.name, W_for_eigen.W_folder);
load(strcat(W_for_eigen.W_folder, '\', W_for_eigen.name));

% % check if normalized
% valMin = min(W_graph.W, [], 2);
% valMax = max(W_graph.W, [], 2);
% if size(unique(valMin), 1) > 1 || size(unique(valMax), 1) > 1
%     disp('The dataset might not be normalized. normalizing it...');
% W_graph.W = normalizeData(W_graph.W);
%     normalized_num = normalized_num + 1;
%     return
% end
%% eigenvalue & eigenvector
%this function creat a matrix W of labaleds only
% labled_percent = [45];
% labled_num = ceil(size(W_graph.Splits, 2) / 100 * labled_percent);
% labeled_ind = labeled_ind_by_Split(W_graph.labels, W_graph.Splits(1,1:labled_num));
% 
% [W_labeled] = labeled_W_by_ind(W_graph.W, labeled_ind);
% labels_labeled = W_graph.labels(labeled_ind);
% [W_graph.W] = noise_remove(W_labeled, labels_labeled);

% [W_labeled] = sparse(labeled_W_by_ind(W_graph.W, labeled_ind));
% labels_labeled = W_graph.labels(labeled_ind);
Clusters_num = length(unique(W_graph.labels));
for diag_one_count = 1:length(diag_one)
    for SPC_sigma_count = 1:length(eigenvalues_sigma)
        for SPC_type_count = 1:length(eigenvalues_laplace_type)
            LTS = num2str(eigenvalues_laplace_type(SPC_type_count));
            DOS = num2str(diag_one(diag_one_count));
            ESS = eigenvalues_sigma{SPC_sigma_count};
            %                     ESS = '1';
            fprintf('Calculate eigenvalue: diag= %s, sigma= %s, Type= %s', DOS, ESS, LTS);
            if save_eigens==true
                % save egien vec & val
                eval(strcat('[W_for_eigen.sum_c_', ESS,'_eigenvalue_type', LTS, '_diag', DOS,...
                    ',', 'W_for_eigen.eigenvectors_', ESS,'_type', LTS, '_diag', DOS,...
                    ', W_for_eigen.eigenvalues_', ESS,'_type', LTS, '_diag', DOS,']',...
                    '= eigen_values_vectors(W_graph.W, Clusters_num, '' ',ESS,''', ', LTS, ',', DOS,');'));
            else
                eval(strcat('[W_for_eigen.sum_c_', ESS,'_eigenvalue_type', LTS, '_diag', DOS,...
                    ', ~, ~]',...
                    '= eigen_values_vectors(W_graph.W, Clusters_num, '' ',ESS,''', ', LTS, ',', DOS,');'));
            end
            
            eval(strcat('SCE = W_for_eigen.sum_c_', ESS,'_eigenvalue_type', LTS, '_diag', DOS, ';'));
            fprintf(' ==> sum c= %f \n',SCE);
        end
    end
end

rmpath('.\code\clustring\')
rmpath('.\code\Normalize\')
rmpath('.\code\label_porpagation\')
rmpath('.\code\other\')
end

