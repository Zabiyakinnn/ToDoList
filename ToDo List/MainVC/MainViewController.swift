//
//  ViewController.swift
//  ToDo List
//
//  Created by Дмитрий Забиякин on 12.09.2024.
//

import UIKit
import SnapKit
import CoreData

class MainViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    private var toDoListData: Todo?
    private var filteredTasks: [Todos] = []
    var todoList: ToDoList?
    var taskCell = "taskCell"
    let currentData = Date()
    let dateFormatter = DateFormatter()
    let itemsSegment = ["All", "Open", "Closed"]
    private var selectedTab: String = "All" // Хранение текущей выбранной вкладки
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoList")
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                print("Error loading persistent store: \(error.localizedDescription)")
                print("Details: \(error), \(error.userInfo)")
            } else {
                print("DB url - \(description.url?.absoluteString ?? "")")
            }
        }
        return container
    }()
    
    private lazy var fetchResultontroller: NSFetchedResultsController<ToDoList> = {
        let fetchRequest = ToDoList.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchResultController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.persistentContainer.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchResultController.delegate = self
        return fetchResultController
    }()
    
    
    private lazy var seperatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10 // расстояние между элементами
        layout.minimumInteritemSpacing = 10
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 140) // размер элемента
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.register(TaskCell.self, forCellWithReuseIdentifier: "taskCell")
        collectionView.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1.0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    //    заголовок
    private lazy var labelTask: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25, weight: .semibold)
        label.text = "Today's Task"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //    Сегодняшняя дата
    private lazy var labelData: UILabel = {
        let label = UILabel()
        dateFormatter.dateFormat = "EEEE, d MMMM"
        dateFormatter.locale = Locale(identifier: "en_US")
        let formattedData = dateFormatter.string(from: currentData)
        label.text = formattedData
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //    Кнопка "New Task"
    private lazy var buttonNewTask: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemBlue
        button.setTitle("+ New Task", for: .normal)
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor(red: 230/255, green: 240/255, blue: 255/255, alpha: 1)
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(tappedNewTask), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //    StackView для вкладок
    private lazy var tabsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try? fetchResultontroller.performFetch()
        view.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1.0)
        setupLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        request()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func request() {
        NetworkService.shared.requestToDoList { [weak self] todos in
            guard let self = self else { return }
            self.toDoListData = Todo(todos: todos)
            self.saveTodosToCoreData(todos: todos)
            DispatchQueue.main.async {
                self.setupTabs()
                self.updateDataForSelectedTab()
                self.collectionView.reloadData()
            }
        }
    }
    
//    Сохранение данных в Core Data
    private func saveTodosToCoreData(todos: [Todos]) {
        let context = persistentContainer.viewContext
        
        for todoItem in todos {
            let fetchRequest: NSFetchRequest<ToDoList> = ToDoList.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "todo == %@", todoItem.todo ?? "")
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.isEmpty {
//                    если задачи не существует в Core Data создаем новую запись
                    let newTask = ToDoList(context: context)
                    newTask.todo = todoItem.todo
                    newTask.comment = todoItem.comment
                    newTask.date = todoItem.date
                    newTask.completed = todoItem.completed ?? false
                    
                    try context.save()
                }
            } catch {
                print("Ошибка сохранения в Core Data \(error)")
            }
        }
    }

    //    функция сооздания вкладок
    func createTab(title: String, count: Int, isSelected: Bool) -> UIView {
        let tabView = UIStackView()
        tabView.axis = .horizontal
        tabView.alignment = .center
        tabView.spacing = 5
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: isSelected ? .bold : .semibold)
        titleLabel.textColor = isSelected ? .systemBlue : .gray
        
        let countLabel = UILabel()
        countLabel.text = "\(count)"
        countLabel.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        countLabel.textColor = isSelected ? .systemBlue : .gray
        
        tabView.addArrangedSubview(titleLabel)
        tabView.addArrangedSubview(countLabel)
        
        // Добавляем обработчик нажатий на вкладку
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tabTapped(_:)))
        tabView.isUserInteractionEnabled = true
        tabView.addGestureRecognizer(tapGesture)
        tabView.tag = itemsSegment.firstIndex(of: title) ?? 0 // Устанавливаем tag для распознавания
        
        return tabView
    }
    
    //    настройка вкладок и добавлие в stackView
    private func setupTabs() {
        // общее количество задач
        let allCount = toDoListData?.todos?.count ?? 0
        // Фильтруем задачи на незавершенные (Open)
        let openCount = toDoListData?.todos?.filter { $0.completed == false }.count ?? 0
        // Фильтруем задачи на завершенные (Closed)
        let closedCount = toDoListData?.todos?.filter { $0.completed == true }.count ?? 0
        // вкладки с реальными значениями
        let allTab = createTab(title: "All", count: allCount, isSelected: selectedTab == "All")
        let openTab = createTab(title: "Open", count: openCount, isSelected: selectedTab == "Open")
        let closedTab = createTab(title: "Closed", count: closedCount, isSelected: selectedTab == "Closed")
        
        // Очищаем старые вкладки и добавляем новые
        tabsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        tabsStackView.addArrangedSubview(allTab)
        tabsStackView.addArrangedSubview(seperatorLine)
        tabsStackView.addArrangedSubview(openTab)
        tabsStackView.addArrangedSubview(closedTab)
    }
    //    обработка нажатий на вкладку
    @objc private func tabTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedView = sender.view else { return }
        let tappedTabTitle = itemsSegment[tappedView.tag]
        selectedTab = tappedTabTitle
        updateTabs()
        updateDataForSelectedTab()
    }
    
    // обновлениe вкладок
    private func updateTabs() {
        // Очищаем StackView перед обновлением
        tabsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        // Пересоздаем вкладки с учетом новой выбранной вкладки
        setupTabs()
    }
    
    // обновлениe данных в зависимости от выбранной вкладки
    private func updateDataForSelectedTab() {
        var coreDataTask: [ToDoList] = []
        do {
            try fetchResultontroller.performFetch()
            coreDataTask = fetchResultontroller.fetchedObjects ?? []
        } catch {
            print("Ошибка получения данных из Core Data \(error)")
        }
        
        var combineTask: [Todos] = []
//        Добавляем задачи из сети
        if let todos = toDoListData?.todos {
            combineTask.append(contentsOf: todos)
        }
//        Добавляем задачи из Core Data если их нет в сетевых данных
        for coreTask in coreDataTask {
            if !(combineTask.contains { $0.todo == coreTask.todo }) {
                let task = Todos(
                    comment: coreTask.comment ?? "",
                    todo: coreTask.todo ?? "",
                    completed: coreTask.completed,
                    date: coreTask.date
                )
                combineTask.append(task)
            }
        }

        switch selectedTab {
        case "All":
            filteredTasks = combineTask
        case "Open":
            filteredTasks = combineTask.filter { $0.completed == false }
        case "Closed":
            filteredTasks = combineTask.filter { $0.completed == true }
        default:
            break
        }
        collectionView.reloadData()
    }
    
    @objc func tappedNewTask() {
        let newTaskVC = NewTaskViewController()
        newTaskVC.todoListInstance = ToDoList.init(entity: NSEntityDescription.entity(forEntityName: "ToDoList", in: persistentContainer.viewContext)!, insertInto: persistentContainer.viewContext)
        navigationController?.present(newTaskVC, animated: true)
    }
}

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTasks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: taskCell, for: indexPath) as! TaskCell
        let item = filteredTasks[indexPath.row]
        cell.configure(item)
        return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
        updateTabs()
        updateDataForSelectedTab()
    }
}


private extension MainViewController {
    private func setupLayout() {
        prepareView()
    }
    
    func prepareView() {
        view.addSubview(labelTask)
        view.addSubview(buttonNewTask)
        view.addSubview(labelData)
        view.addSubview(tabsStackView)
        view.addSubview(collectionView)
        labelTask.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(66)
            make.left.equalTo(view.snp.left).inset(30)
            make.height.equalTo(34)
            make.width.equalTo(150)
        }
        buttonNewTask.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(80)
            make.right.equalTo(view.snp.right).inset(30)
            make.height.equalTo(46)
            make.width.equalTo(145)
        }
        labelData.snp.makeConstraints { make in
            make.top.equalTo(labelTask.snp.top).inset(42)
            make.left.equalTo(view.snp.left).inset(32)
            make.height.equalTo(20)
//            make.width.equalTo(180)
        }
        tabsStackView.snp.makeConstraints { make in
            make.top.equalTo(labelData.snp.top).offset(30)
            make.left.equalTo(view.snp.left).inset(30)
            make.height.equalTo(40)
            make.width.equalTo(260)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(tabsStackView.snp.top).offset(40)
            make.left.equalTo(view.snp.left).offset(20)
            make.right.equalTo(view.snp.right).offset(-20)
            make.bottom.equalToSuperview()
        }
        seperatorLine.snp.makeConstraints { make in
            make.width.equalTo(1.5)
            make.height.equalTo(20)
        }
    }
}


