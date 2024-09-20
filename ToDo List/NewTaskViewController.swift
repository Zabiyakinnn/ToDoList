//
//  NewTaskViewController.swift
//  ToDo List
//
//  Created by Дмитрий Забиякин on 14.09.2024.
//

import UIKit
import SnapKit

class NewTaskViewController: UIViewController {
    
    var todoListInstance: ToDoList?
    
    private lazy var todoTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(red: 230/255, green: 240/255, blue: 255/255, alpha: 1)
        textField.textColor = .black
        textField.tintColor = .black
        textField.placeholder = "Enter the task"
        textField.layer.shadowColor = UIColor.lightGray.cgColor //цвет тени
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)  //смещение тени
        textField.layer.shadowRadius = 4  // радиус размытия тени
        textField.layer.shadowOpacity = 0.4 // прозрачность тени
        textField.layer.masksToBounds = false
        return textField
    }()
    
    private lazy var commentTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(red: 230/255, green: 240/255, blue: 255/255, alpha: 1)
        textField.textColor = .black
        textField.tintColor = .black
        textField.placeholder = "Enter the comment"
        textField.layer.shadowColor = UIColor.lightGray.cgColor //цвет тени
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)  //смещение тени
        textField.layer.shadowRadius = 4  // радиус размытия тени
        textField.layer.shadowOpacity = 0.4 // прозрачность тени
        textField.layer.masksToBounds = false
        return textField
    }()
    
    private lazy var dateOfDone: UILabel = {
        let label = UILabel()
        label.text = "dd-MM-yyyy"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var setDateOfDone: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemBlue
        button.setTitle("To choose", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor(red: 230/255, green: 240/255, blue: 255/255, alpha: 1)
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(setDateOfTask), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var taskCompletionDate: UILabel = {
        let label = UILabel()
        label.text = "Task completion date.."
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var labelTask: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.text = "Create a new task.."
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var buttonSaveTask: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .systemBlue
        button.setTitle("Save Task", for: .normal)
        button.clipsToBounds = true
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor(red: 230/255, green: 240/255, blue: 255/255, alpha: 1)
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(saveToDoList), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "New Task"
        view.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1.0)
        setupView()
        setupeConstraint()
    }
    
    private func setupView() {
        view.addSubview(labelTask)
        view.addSubview(todoTextField)
        view.addSubview(commentTextField)
        view.addSubview(buttonSaveTask)
        view.addSubview(dateOfDone)
        view.addSubview(taskCompletionDate)
        view.addSubview(setDateOfDone)
    }
    
    @objc func setDateOfTask() {
        let vc = UIViewController()
        vc.preferredContentSize = CGSize(width: 250,height: 50)
        let pickerView = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
        pickerView.datePickerMode = .date
        vc.view.addSubview(pickerView)
        pickerView.snp.makeConstraints { make in
            make.center.equalTo(vc.view.snp.center)
        }
        pickerView.addTarget(self, action: #selector(updateDateOfToDo(sender: )), for: .valueChanged)
        let DateAlert = UIAlertController(title: "Select the date of completion of the task", message: "", preferredStyle: .alert)
        DateAlert.setValue(vc, forKey: "contentViewController")
        DateAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: nil))
        updateDateOfToDo(sender: pickerView)
        present(DateAlert, animated: true)
    }
    
    @objc func updateDateOfToDo(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let selectedDate = dateFormatter.string(from: sender.date)
        dateOfDone.text = selectedDate
    }
    
    @objc func saveToDoList() {
        if todoTextField.hasText && commentTextField.hasText && dateOfDone.text != "dd-MM-yyyy" {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"

            // Проверяем, если todoListInstance == nil, создаем новый объект
            // Получаем контекст ManagedObjectContext
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
                
            // Создаем новый объект ToDoList
            if todoListInstance == nil {
                todoListInstance = ToDoList(context: context)
            }
            
            todoListInstance?.todo = todoTextField.text
            todoListInstance?.comment = commentTextField.text
            todoListInstance?.date = formatter.date(from: dateOfDone.text ?? "01-01-2024")
            todoListInstance?.completed = false
            
            // Сохраняем данные в Core Data
            do {
                try todoListInstance?.managedObjectContext?.save()
                dismiss(animated: true)
                print("Данные сохранены в coreData ----- \(String(describing: todoListInstance))")
            } catch {
                print("Ошибка при сохранении данных в Core Data: \(error)")
            }
        } else {
            print("Ошибка сохранения задачи в CoreData")
        }
    }
}

extension NewTaskViewController {
    private func setupeConstraint() {
        labelTask.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(37)
            make.left.equalTo(view.snp.left).inset(22)
            make.height.equalTo(34)
            make.width.equalTo(220)
        }
        todoTextField.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(labelTask.snp.top).offset(64)
            make.height.equalTo(55)
            make.width.equalToSuperview()
        }
        commentTextField.snp.makeConstraints { make in
            make.centerX.equalTo(view.snp.centerX)
            make.top.equalTo(todoTextField.snp.top).offset(66)
            make.height.equalTo(55)
            make.width.equalToSuperview()
        }
        buttonSaveTask.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(35)
            make.right.equalTo(view.snp.right).inset(24)
            make.height.equalTo(40)
            make.width.equalTo(135)
        }
        dateOfDone.snp.makeConstraints { make in
            make.top.equalTo(commentTextField.snp.top).offset(120)
            make.left.equalTo(view.snp.left).inset(30)
        }
        taskCompletionDate.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).inset(34)
            make.top.equalTo(commentTextField.snp.top).offset(78)
        }
        setDateOfDone.snp.makeConstraints { make in
            make.left.equalTo(dateOfDone.snp.left).offset(155)
            make.top.equalTo(commentTextField.snp.top).offset(114)
            make.width.equalTo(124)
            make.height.equalTo(30)
        }
    }
}
