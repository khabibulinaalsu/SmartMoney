import UIKit

protocol AddTransactionViewProtocol: AnyObject {
    func setupUI()
    func updateCategories(_ categories: [CategoryModel])
    func showError(_ message: String)
    func dismissScreen()
    func updateCategorySelection(_ category: CategoryModel)
}

class AddTransactionViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let amountTextField = UITextField()
    private let titleTextField = UITextField()
    private let annotationTextView = UITextView()
    private let datePickerView = UIDatePicker()
    private let categoryButton = UIButton()
    private let typeSegmentedControl = UISegmentedControl(items: ["Доход", "Расход"])
    
    private let saveButton = UIButton()
    private let cancelButton = UIButton()
    
    // MARK: - Properties
    var presenter: AddTransactionPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }
    
    // MARK: - Actions
    @objc private func saveButtonTapped() {
        let transactionData = AddTransactionInputData(
            amount: Double(amountTextField.text ?? "") ?? 0,
            title: titleTextField.text ?? "",
            annotation: annotationTextView.text ?? "",
            dateAndTime: datePickerView.date,
            isExpense: typeSegmentedControl.selectedSegmentIndex == 1
        )
        presenter.saveTransaction(transactionData)
    }
    
    @objc private func cancelButtonTapped() {
        presenter.cancelTapped()
    }
    
    @objc private func categoryButtonTapped() {
        presenter.categorySelectionTapped()
    }
    
    @objc private func typeChanged() {
        presenter.typeChanged(isExpense: typeSegmentedControl.selectedSegmentIndex == 1)
    }
}

extension AddTransactionViewController: AddTransactionViewProtocol {
    func setupUI() {
        view.backgroundColor = .systemBackground
        setupScrollView()
        setupComponents()
        setupConstraints()
        setupNavigationBar()
    }
    
    func updateCategories(_ categories: [CategoryModel]) {
        // Обновление доступных категорий
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func dismissScreen() {
        navigationController?.popViewController(animated: true)
    }
    
    func updateCategorySelection(_ category: CategoryModel) {
        categoryButton.setTitle(category.name, for: .normal)
        categoryButton.backgroundColor = UIColor(hex: category.colorHEX)
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupComponents() {
        // Настройка всех UI компонентов
        amountTextField.borderStyle = .roundedRect
        amountTextField.placeholder = "Сумма"
        amountTextField.keyboardType = .decimalPad
        
        titleTextField.borderStyle = .roundedRect
        titleTextField.placeholder = "Название"
        
        annotationTextView.layer.borderColor = UIColor.systemGray4.cgColor
        annotationTextView.layer.borderWidth = 1
        annotationTextView.layer.cornerRadius = 8
        
        datePickerView.datePickerMode = .dateAndTime
        datePickerView.preferredDatePickerStyle = .compact
        
        categoryButton.setTitle("Выберите категорию", for: .normal)
        categoryButton.backgroundColor = .systemBlue
        categoryButton.layer.cornerRadius = 8
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        
        typeSegmentedControl.selectedSegmentIndex = 1
        typeSegmentedControl.addTarget(self, action: #selector(typeChanged), for: .valueChanged)
        
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.backgroundColor = .systemGreen
        saveButton.layer.cornerRadius = 8
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        
        cancelButton.setTitle("Отмена", for: .normal)
        cancelButton.backgroundColor = .systemRed
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        [amountTextField, titleTextField, annotationTextView, datePickerView,
         categoryButton, typeSegmentedControl, saveButton, cancelButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            // Constraints для amountTextField
            amountTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            amountTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            amountTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            amountTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Constraints для titleTextField
            titleTextField.topAnchor.constraint(equalTo: amountTextField.bottomAnchor, constant: 16),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Constraints для typeSegmentedControl
            typeSegmentedControl.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            typeSegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            typeSegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            typeSegmentedControl.heightAnchor.constraint(equalToConstant: 32),
            
            // Constraints для categoryButton
            categoryButton.topAnchor.constraint(equalTo: typeSegmentedControl.bottomAnchor, constant: 16),
            categoryButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            categoryButton.heightAnchor.constraint(equalToConstant: 44),
            
            // Constraints для datePickerView
            datePickerView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor, constant: 16),
            datePickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            datePickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            datePickerView.heightAnchor.constraint(equalToConstant: 34),
            
            // Constraints для annotationTextView
            annotationTextView.topAnchor.constraint(equalTo: datePickerView.bottomAnchor, constant: 16),
            annotationTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            annotationTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            annotationTextView.heightAnchor.constraint(equalToConstant: 80),
            
            // Constraints для saveButton
            saveButton.topAnchor.constraint(equalTo: annotationTextView.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: -8),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Constraints для cancelButton
            cancelButton.topAnchor.constraint(equalTo: annotationTextView.bottomAnchor, constant: 24),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 8),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            
            // Constraint для нижней границы contentView
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupNavigationBar() {
        title = presenter.isEditMode ? "Редактировать транзакцию" : "Новая транзакция"
    }
}
