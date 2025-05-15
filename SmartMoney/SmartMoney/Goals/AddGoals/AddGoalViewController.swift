import UIKit
import PhotosUI

protocol AddGoalViewProtocol: AnyObject {
    func displaySuccess()
    func displayError(message: String)
}

class AddGoalViewController: UIViewController, AddGoalViewProtocol {
    
    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleTextField = UITextField()
    private let descriptionTextView = UITextView()
    private let targetAmountTextField = UITextField()
    private let initialAmountTextField = UITextField()
    private let addPhotoButton = UIButton(type: .system)
    private let photoImageView = UIImageView()
    private let saveButton = UIButton(type: .system)
    
    // MARK: - Properties
    var interactor: AddGoalInteractorProtocol!
    var presenter: AddGoalPresenterProtocol!
    var router: AddGoalRouterProtocol!
    
    private var selectedImageData: Data?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFields()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Новая цель накопления"
        view.backgroundColor = .systemBackground
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
        
        // ScrollView setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Configure UI elements
        titleTextField.placeholder = "Название"
        titleTextField.borderStyle = .roundedRect
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionTextView.text = "Описание"
        descriptionTextView.textColor = .placeholderText
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.layer.borderColor = UIColor.systemGray4.cgColor
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.delegate = self
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        targetAmountTextField.placeholder = "Сумма накопления"
        targetAmountTextField.borderStyle = .roundedRect
        targetAmountTextField.keyboardType = .decimalPad
        targetAmountTextField.translatesAutoresizingMaskIntoConstraints = false
        
        initialAmountTextField.placeholder = "Изначальная сумма"
        initialAmountTextField.borderStyle = .roundedRect
        initialAmountTextField.keyboardType = .decimalPad
        initialAmountTextField.translatesAutoresizingMaskIntoConstraints = false
        
        addPhotoButton.setTitle("Добавить фото", for: .normal)
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        
        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true
        photoImageView.layer.cornerRadius = 8
        photoImageView.backgroundColor = .systemGray6
        photoImageView.isHidden = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        saveButton.setTitle("Сохранить цель", for: .normal)
        saveButton.backgroundColor = .systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 10
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add elements to content view
        contentView.addSubview(titleTextField)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(targetAmountTextField)
        contentView.addSubview(initialAmountTextField)
        contentView.addSubview(addPhotoButton)
        contentView.addSubview(photoImageView)
        contentView.addSubview(saveButton)
        
        // Set Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            titleTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionTextView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 120),
            
            targetAmountTextField.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16),
            targetAmountTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            targetAmountTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            initialAmountTextField.topAnchor.constraint(equalTo: targetAmountTextField.bottomAnchor, constant: 16),
            initialAmountTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            initialAmountTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            addPhotoButton.topAnchor.constraint(equalTo: initialAmountTextField.bottomAnchor, constant: 20),
            addPhotoButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            photoImageView.topAnchor.constraint(equalTo: addPhotoButton.bottomAnchor, constant: 16),
            photoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            photoImageView.widthAnchor.constraint(equalToConstant: 200),
            photoImageView.heightAnchor.constraint(equalToConstant: 200),
            
            saveButton.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 40),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupTextFields() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        toolbar.setItems([doneButton], animated: true)
        
        targetAmountTextField.inputAccessoryView = toolbar
        initialAmountTextField.inputAccessoryView = toolbar
    }
    
    private func setupActions() {
        addPhotoButton.addTarget(self, action: #selector(addPhotoTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() {
        router.dismiss()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func addPhotoTapped() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc private func saveButtonTapped() {
        guard let title = titleTextField.text, !title.isEmpty else {
            displayError(message: "Введите название")
            return
        }
        
        guard let targetAmountText = targetAmountTextField.text, !targetAmountText.isEmpty,
              let targetAmount = Double(targetAmountText) else {
            displayError(message: "Введите валидную сумму накопления")
            return
        }
        
        let initialAmount: Double
        if let initialAmountText = initialAmountTextField.text, !initialAmountText.isEmpty {
            guard let amount = Double(initialAmountText) else {
                displayError(message: "Введите имеющуюся сумму накопления")
                return
            }
            initialAmount = amount
        } else {
            initialAmount = 0
        }
        
        let description = descriptionTextView.textColor == .placeholderText ? "" : descriptionTextView.text
        
        let request = GoalsList.AddGoal.Request(
            title: title,
            description: description ?? "",
            targetAmount: targetAmount,
            initialAmount: initialAmount,
            imageData: selectedImageData
        )
        
        interactor.createGoal(request: request)
    }
    
    // MARK: - AddGoalViewProtocol
    func displaySuccess() {
        router.dismiss()
    }
    
    func displayError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate
extension AddGoalViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeholderText {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Описание"
            textView.textColor = .placeholderText
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension AddGoalViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (object, error) in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.displayError(message: error.localizedDescription)
                }
                return
            }
            
            guard let image = object as? UIImage else { return }
            
            DispatchQueue.main.async {
                self.photoImageView.image = image
                self.photoImageView.isHidden = false
                self.selectedImageData = image.jpegData(compressionQuality: 0.7)
            }
        }
    }
}
