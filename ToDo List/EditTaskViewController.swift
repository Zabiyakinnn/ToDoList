//
//  EditTaskViewController.swift
//  ToDo List
//
//  Created by Дмитрий Забиякин on 28.09.2024.
//

import UIKit
import SnapKit

final class EditTaskViewController: UIViewController {
    
    var todo: String?
    var comment: String?
    var todoListInstance: ToDoList?
    private var dateOfDone = String()
    private var selectedDate: Date?
    private var calendar = UICalendarView()
    private func showFields() {
        NotificationUtils.showFields(on: self)
    }
    
    private var buttonDate: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        let calendarImage = UIImage(systemName: "calendar")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        button.setImage(calendarImage, for: .normal)
        button.backgroundColor = UIColor(red: 230/255, green: 240/255, blue: 255/255, alpha: 1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.setTitle("Date", for: .normal)
        button.contentHorizontalAlignment = .left
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 0)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(setDateOfTask), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var todoTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(red: 230/255, green: 240/255, blue: 255/255, alpha: 1)
        textField.textColor = .black
        textField.tintColor = .black
        textField.text = todoListInstance?.todo
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
        textField.text = todoListInstance?.comment
        textField.placeholder = "Enter the comment"
        textField.layer.shadowColor = UIColor.lightGray.cgColor //цвет тени
        textField.layer.shadowOffset = CGSize(width: 0, height: 2)  //смещение тени
        textField.layer.shadowRadius = 4  // радиус размытия тени
        textField.layer.shadowOpacity = 0.4 // прозрачность тени
        textField.layer.masksToBounds = false
        return textField
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
        label.text = "Edit task.."
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
        button.addTarget(self, action: #selector(saveEditTask), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Edit Task"
        view.backgroundColor = UIColor(red: 249/255, green: 249/255, blue: 249/255, alpha: 1.0)
        setupView()
        setupeConstraint()
    }
    
    private func setupView() {
        view.addSubview(labelTask)
        view.addSubview(todoTextField)
        view.addSubview(commentTextField)
        view.addSubview(buttonSaveTask)
        view.addSubview(taskCompletionDate)
        view.addSubview(buttonDate)
        
        self.hideKeybord()
        
        setRightButtonComment()
        setRightButtonToDo()
        setLeftImageToDo()
        setLeftImageComment()
    }
    
//    clear textField
    private func setRightButtonToDo() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(clearTextFieldToDo), for: .touchUpInside)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        containerView.addSubview(button)
        
        button.center = containerView.center
        todoTextField.rightView = containerView
        todoTextField.rightViewMode = .always
    }
    
    @objc private func clearTextFieldToDo() {
        todoTextField.text = nil
    }
    
    private func setRightButtonComment() {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .gray
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(clearTextFieldComment), for: .touchUpInside)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        containerView.addSubview(button)
        
        button.center = containerView.center
        commentTextField.rightView = containerView
        commentTextField.rightViewMode = .always
    }
    
    @objc private func clearTextFieldComment() {
        commentTextField.text = nil
    }
    
//    Left image TextField
    private func setLeftImageToDo() {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "doc.text")
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 7, y: 0, width: 16, height: 20)
        imageView.tintColor = .gray
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        containerView.addSubview(imageView)
        
        imageView.center = containerView.center
        todoTextField.leftView = containerView
        todoTextField.leftViewMode = .always
    }

    private func setLeftImageComment() {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "rays")
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 7, y: 0, width: 16, height: 20)
        imageView.tintColor = .gray
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        containerView.addSubview(imageView)
        
        imageView.center = containerView.center
        commentTextField.leftView = containerView
        commentTextField.leftViewMode = .always
    }
    
    @objc func setDateOfTask() {
        calendar.calendar = .current
        calendar.locale = .current
        view.addSubview(calendar)
        
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendar.selectionBehavior = selection
        
        calendar.snp.makeConstraints { make in
            make.top.equalTo(350)
            make.left.equalTo(30)
            make.right.equalTo(-30)
        }
    }
    
    @objc func updateDateOfToDo(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let selectedDate = dateFormatter.string(from: sender.date)
        dateOfDone = selectedDate
    }
    
    @objc private func saveEditTask() {
        if todoTextField.hasText && commentTextField.hasText && dateOfDone != "dd-MM-yyyy" {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd-MM-yyyy"
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext            
//            проверяем существует ли уже todoListInstance
            if let todoEdit = todoListInstance {
                print("редактирую задачу: \(todoEdit)")
//                редактируем ToDoList
                todoEdit.todo = todoTextField.text
                todoEdit.comment = commentTextField.text
                todoEdit.date = formatter.date(from: dateOfDone)
                todoEdit.completed = todoListInstance?.completed != nil
            } else {
                print("ошибка: todoListInstance = nil")
            }
            do {
                try context.save()
                dismiss(animated: true)
            } catch {
                print("Ошибка при обновлении данных в Core Data: - \(error)")
            }
        } else {
            showFields()
        }
    }
}

extension EditTaskViewController {
    private func setupeConstraint() {
        labelTask.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).inset(51)
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
            make.top.equalTo(view.snp.top).inset(48)
            make.right.equalTo(view.snp.right).inset(24)
            make.height.equalTo(40)
            make.width.equalTo(135)
        }
        taskCompletionDate.snp.makeConstraints { make in
            make.left.equalTo(view.snp.left).inset(34)
            make.top.equalTo(commentTextField.snp.top).offset(78)
        }
        buttonDate.snp.makeConstraints { make in
            make.top.equalTo(taskCompletionDate.snp.top).inset(35)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.left.equalTo(14)
            make.right.equalTo(-14)
        }
    }
    
    private func hideKeybord() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapScreen(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    //    обработка нажатия и скрытия клавиатуры
    @objc private func tapScreen(_ sender: UITapGestureRecognizer) {
        todoTextField.endEditing(true)
        commentTextField.endEditing(true)
    }
}

extension EditTaskViewController: UICalendarSelectionSingleDateDelegate {
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents, let date = dateComponents.date else { return }
        
        selectedDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let selectedDate = dateFormatter.string(from: date)
        dateOfDone = selectedDate
        
        buttonDate.setTitle(selectedDate, for: .normal)
        calendar.removeFromSuperview()
    }
}
