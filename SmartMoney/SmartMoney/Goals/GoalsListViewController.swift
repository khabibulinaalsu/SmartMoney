import UIKit
import SwiftData

protocol GoalsListViewProtocol: AnyObject {
    func displayGoals(viewModel: GoalsList.FetchGoals.ViewModel)
    func displayError(message: String)
}

class GoalsListViewController: UIViewController, GoalsListViewProtocol {
    
    // MARK: - UI Elements
    private let segmentedControl = UISegmentedControl(items: [GoalStatus.active.rawValue, GoalStatus.completed.rawValue, GoalStatus.frozen.rawValue])
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
    
    // MARK: - Properties
    var interactor: GoalsListInteractorProtocol!
    var router: GoalsListRouterProtocol!
    private var viewModel: GoalsList.FetchGoals.ViewModel?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    
        fetchGoals(with: getStatus())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchGoals(with: getStatus())
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Configure Segmented Control
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(GoalCell.self, forCellReuseIdentifier: "GoalCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add UI Elements
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        
        // Add Bar Button
        navigationItem.rightBarButtonItem = addButton
        
        // Set Constraints
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupActions() {
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        addButton.target = self
        addButton.action = #selector(addButtonTapped)
    }
    
    private func getStatus() -> GoalStatus {
        let segment = segmentedControl.selectedSegmentIndex
        switch segment {
        case 1:
            return .completed
        case 2:
            return .frozen
        default:
            return .active
        }
    }
    
    // MARK: - Actions
    @objc private func segmentChanged() {
        let status = getStatus()
        tableView.reloadData()
//        fetchGoals(with: status)
    }
    
    @objc private func addButtonTapped() {
        router.routeToAddGoal()
    }
    
    // MARK: - Data Fetching
    private func fetchGoals(with status: GoalStatus) {
        interactor.fetchGoals(request: GoalsList.FetchGoals.Request(status: status))
    }
    
    // MARK: - GoalsListViewProtocol
    func displayGoals(viewModel: GoalsList.FetchGoals.ViewModel) {
        self.viewModel = viewModel
        tableView.reloadData()
    }
    
    func displayError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension GoalsListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let vm = viewModel?.sections else { return 0 }
        for section in vm {
            if let goal = section.goals.first,
               goal.status == getStatus() {
                return section.goals.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: indexPath) as? GoalCell,
              let goalVM = viewModel?.sections[indexPath.section].goals[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.configure(with: goalVM)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let id = viewModel?.sections[indexPath.section].goals[indexPath.row].id,
            let goal = interactor.fetchGoal(request: .init(goalId: id)) else {
            return
        }
        
        router.routeToGoalDetails(goal: goal)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let id = viewModel?.sections[indexPath.section].goals[indexPath.row].id,
              let goal = interactor.fetchGoal(request: .init(goalId: id)) else {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            let request = GoalsList.DeleteGoal.Request(goal: goal)
            self?.interactor.deleteGoal(request: request)
            completion(true)
        }
        
        var statusActions: [UIContextualAction] = []
        
        switch goal.status {
        case .completed:
            break
        case .frozen:
            let reactivateAction = UIContextualAction(style: .normal, title: "Возобновить") { [weak self] _, _, completion in
                goal.status = .active
                let request = GoalsList.EditGoal.Request(goal: goal)
                self?.interactor.updateGoal(request: request)
                completion(true)
            }
            reactivateAction.backgroundColor = .systemOrange
            statusActions = [reactivateAction]
            
        case .active:
            let thawAction = UIContextualAction(style: .normal, title: "Приостановить") { [weak self] _, _, completion in
                goal.status = .frozen
                let request = GoalsList.EditGoal.Request(goal: goal)
                self?.interactor.updateGoal(request: request)
                completion(true)
            }
            thawAction.backgroundColor = .systemOrange
            statusActions = [thawAction]
        }
        
        let config = UISwipeActionsConfiguration(actions: statusActions + [deleteAction])
        return config
    }
}
