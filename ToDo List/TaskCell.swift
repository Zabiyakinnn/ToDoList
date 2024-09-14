//
//  TaskCell.swift
//  ToDo List
//
//  Created by Дмитрий Забиякин on 13.09.2024.
//

import UIKit
import SnapKit

class TaskCell: UICollectionViewCell {
    
    private lazy var toDoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        return label
    }()
    
    private lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var createdToDoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var seperatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        return view
    }()
    
    private lazy var statusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "circle"), for: .normal)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        button.addTarget(self, action: #selector(shareStatusButtonTapped), for: .touchUpInside)
        button.imageView?.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(toDoLabel)
        contentView.addSubview(commentLabel)
        contentView.addSubview(createdToDoLabel)
        contentView.addSubview(seperatorLine)
        contentView.addSubview(statusButton)
        
        setupeConstraint()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = UIColor.white
        contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.1
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    }
    
    func configure(_ todoItem: Todos) {
        toDoLabel.text = todoItem.todo
        commentLabel.text = todoItem.description ?? "Your comment"
        createdToDoLabel.text = "Data"
        statusButton.isSelected = todoItem.completed ?? false
    }
    
    @objc private func shareStatusButtonTapped() {
        statusButton.isSelected.toggle()
    }
}

extension TaskCell {
    private func setupeConstraint() {
        toDoLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left).offset(10)
            make.right.equalTo(contentView.snp.right).offset(-62)
            make.top.equalTo(contentView.snp.top).offset(18)
        }
        commentLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left).offset(10)
            make.top.equalTo(toDoLabel.snp.top).offset(40)
            make.width.equalTo(180)
        }
        createdToDoLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left).offset(10)
            make.top.equalTo(commentLabel.snp.top).offset(50)
            make.width.equalTo(100)
        }
        seperatorLine.snp.makeConstraints { make in
            make.left.equalTo(contentView.snp.left).offset(20)
            make.right.equalTo(contentView.snp.right).offset(-20)
            make.top.equalTo(commentLabel.snp.top).offset(35)
            make.height.equalTo(1)
        }
        statusButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(24)
            make.right.equalTo(contentView.snp.right).offset(-18)
            make.height.equalTo(30)
            make.width.equalTo(30)
        }
    }
}
