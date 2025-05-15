import UIKit

protocol CategoryViewProtocol: AnyObject {
    func setupUI()
    func updateCategories(_ categories: [CategoryModel])
    func showError(_ message: String)
    func dismissScreen()
    func showCategoryForm(category: CategoryModel?)
}

class CategoryViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView = UITableView()
    private let addButton = UIBarButtonItem()
    
    // MARK: - Properties
    var presenter: CategoryPresenterProtocol!
    private var categories: [CategoryModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    @objc private func addButtonTapped() {
        presenter.addCategoryTapped()
    }
}

extension CategoryViewController: CategoryViewProtocol {
    func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Категории"
        
        setupTableView()
        setupNavigationBar()
    }
    
    func updateCategories(_ categories: [CategoryModel]) {
        self.categories = categories
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func dismissScreen() {
        navigationController?.popViewController(animated: true)
    }
    
    func showCategoryForm(category: CategoryModel?) {
        let presentingController = self.presentingViewController ?? self
        
        let alertController = UIAlertController(
            title: category == nil ? "Новая категория" : "Редактировать категорию",
            message: "Введите название категории",
            preferredStyle: .alert
        )
        
        alertController.addTextField { textField in
            textField.placeholder = "Название категории"
            textField.text = category?.name ?? ""
            textField.autocapitalizationType = .words
        }
        
        // Действие сохранения
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self] _ in
            guard let self else { return }
            
            guard let textField = alertController.textFields?.first,
                  let categoryName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !categoryName.isEmpty else {
                self.showError("Введите название категории")
                return
            }
            
            if let existingCategory = category {
                self.presenter.saveCategory(id: existingCategory.id, name: categoryName, colorHEX: existingCategory.colorHEX)
            } else {
                self.presenter.saveCategory(id: nil, name: categoryName, colorHEX: "000000")
            }
            
            self.tableView.reloadData()
        }
        
        // Действие отмены
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        // Представляем алерт в главном потоке
        DispatchQueue.main.async {
            presentingController.present(alertController, animated: true)
        }
    }
        
        private func setupTableView() {
            view.addSubview(tableView)
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: "CategoryCell")
            
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        private func setupNavigationBar() {
            addButton.title = "Добавить"
            addButton.target = self
            addButton.action = #selector(addButtonTapped)
            navigationItem.rightBarButtonItem = addButton
        }
    }

    // MARK: - UITableViewDataSource
    extension CategoryViewController: UITableViewDataSource {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return categories.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath) as! CategoryTableViewCell
            let category = categories[indexPath.row]
            cell.configure(with: category)
            return cell
        }
    }

    // MARK: - UITableViewDelegate
    extension CategoryViewController: UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            let category = categories[indexPath.row]
            
            if presenter.isSelectionMode {
                presenter.categorySelected(category)
            } else {
                presenter.editCategory(category)
            }
        }
        
        func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let category = categories[indexPath.row]
            
            let editAction = UIContextualAction(style: .normal, title: "Редактировать") { [weak self] _, _, completion in
                self?.presenter.editCategory(category)
                completion(true)
            }
            
            editAction.backgroundColor = .systemBlue
            
            let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
                self?.presenter.deleteCategory(category)
                completion(true)
            }
            
            return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        }
    }
