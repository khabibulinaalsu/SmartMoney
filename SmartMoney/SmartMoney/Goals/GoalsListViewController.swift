import UIKit
import SwiftData

protocol GoalsListViewProtocol: AnyObject {
    func displayGoals(viewModel: GoalsList.FetchGoals.ViewModel)
    func displayError(message: String)
}

class GoalsListViewController: UIViewController, GoalsListViewProtocol {
    
    // MARK: - UI Elements
    private let segmentedControl = UISegmentedControl(items: ["Active", "Completed", "Frozen"])
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
        
        // Initial fetch for active goals
        fetchGoals(status: .active)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchGoals(status: GoalStatus(rawValue: segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex) ?? "Active"))
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        title = "Financial Goals"
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
    
    // MARK: - Actions
    @objc private func segmentChanged() {
        let segment = segmentedControl.selectedSegmentIndex
        let status: GoalStatus
        
        switch segment {
        case 0:
            status = .active
        case 1:
            status = .completed
        case 2:
            status = .frozen
        default:
            status = .active
        }
        
        fetchGoals(status: status)
    }
    
    @objc private func addButtonTapped() {
        router.routeToAddGoal()
    }
    
    // MARK: - Data Fetching
    private func fetchGoals(status: GoalStatus?) {
        let request = GoalsList.FetchGoals.Request(status: status)
        interactor.fetchGoals(request: request)
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
        return viewModel?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel?.sections[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.sections[section].goals.count ?? 0
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
        guard let goalVM = viewModel?.sections[indexPath.section].goals[indexPath.row],
              let id = viewModel?.sections[indexPath.section].goals[indexPath.row].id,
              let modelContext = try? ModelContainer(for: FinancialGoal.self).mainContext,
              let goal = try? modelContext.fetch(FetchDescriptor<FinancialGoal>(predicate: #Predicate { $0.id == id })).first else {
            return
        }
        router.routeToGoalDetails(goal: goal)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let goalVM = viewModel?.sections[indexPath.section].goals[indexPath.row],
              let id = viewModel?.sections[indexPath.section].goals[indexPath.row].id,
              let modelContext = try? ModelContainer(for: FinancialGoal.self).mainContext,
              let goal = try? modelContext.fetch(FetchDescriptor<FinancialGoal>(predicate: #Predicate { $0.id == id })).first else {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            let request = GoalsList.DeleteGoal.Request(goal: goal)
            self?.interactor.deleteGoal(request: request)
            completion(true)
        }
        
        var statusActions: [UIContextualAction] = []
        
        switch goal.status {
        case .active:
            let completeAction = UIContextualAction(style: .normal, title: "Complete") { [weak self] _, _, completion in
                let request = GoalsList.UpdateGoalStatus.Request(goal: goal, newStatus: .completed)
                self?.interactor.updateGoalStatus(request: request)
                completion(true)
            }
            completeAction.backgroundColor = .systemGreen
            
            let freezeAction = UIContextualAction(style: .normal, title: "Freeze") { [weak self] _, _, completion in
                let request = GoalsList.UpdateGoalStatus.Request(goal: goal, newStatus: .frozen)
                self?.interactor.updateGoalStatus(request: request)
                completion(true)
            }
            freezeAction.backgroundColor = .systemBlue
            
            statusActions = [completeAction, freezeAction]
            
        case .completed:
            let reactivateAction = UIContextualAction(style: .normal, title: "Reactivate") { [weak self] _, _, completion in
                let request = GoalsList.UpdateGoalStatus.Request(goal: goal, newStatus: .active)
                self?.interactor.updateGoalStatus(request: request)
                completion(true)
            }
            reactivateAction.backgroundColor = .systemOrange
            statusActions = [reactivateAction]
            
        case .frozen:
            let thawAction = UIContextualAction(style: .normal, title: "Unfreeze") { [weak self] _, _, completion in
                let request = GoalsList.UpdateGoalStatus.Request(goal: goal, newStatus: .active)
                self?.interactor.updateGoalStatus(request: request)
                completion(true)
            }
            thawAction.backgroundColor = .systemOrange
            statusActions = [thawAction]
        }
        
        let config = UISwipeActionsConfiguration(actions: statusActions + [deleteAction])
        return config
    }
}
