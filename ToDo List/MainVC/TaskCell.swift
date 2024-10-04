//
//  TaskCell.swift
//  ToDo List
//
//  Created by Дмитрий Забиякин on 13.09.2024.
//

import UIKit
import SnapKit

class TaskCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    var cellLabel: UILabel!
    var pan: UIPanGestureRecognizer!
    var deleteLabel1: UILabel!
    var deleteLabel2: UILabel!
    var onStatusChange: ((Bool) -> Void)?
    
    //Previous methods here
    
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
        commonInit()
        
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
        commentLabel.text = todoItem.comment ?? "Your comment"
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        createdToDoLabel.text = formatter.string(from: todoItem.date ?? Date())
        statusButton.isSelected = todoItem.completed ?? false
    }
    
    @objc private func shareStatusButtonTapped() {
        statusButton.isSelected.toggle()
        onStatusChange?(statusButton.isSelected)
    }

    
    //    MARK: - Other functions here
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return abs((pan.velocity(in: pan.view)).x) > abs((pan.velocity(in: pan.view)).y)
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
            make.right.equalTo(contentView.snp.right).offset(-30)
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

//MARK: - Swipe to cell
extension TaskCell {
    
    private func commonInit() {
        self.contentView.backgroundColor = UIColor.gray
        self.backgroundColor = UIColor.red
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
        
        cellLabel = UILabel()
        cellLabel.textColor = UIColor.white
        cellLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(cellLabel)
        cellLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        cellLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor).isActive = true
        cellLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor).isActive = true
        cellLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
        
        deleteLabel1 = UILabel()
        deleteLabel1.text = "delete"
        deleteLabel1.textColor = UIColor.white
        self.insertSubview(deleteLabel1, belowSubview: self.contentView)
        
        deleteLabel2 = UILabel()
        deleteLabel2.text = "delete"
        deleteLabel2.textColor = UIColor.white
        self.insertSubview(deleteLabel2, belowSubview: self.contentView)
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        pan.delegate = self
        self.addGestureRecognizer(pan)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if (pan.state == UIGestureRecognizer.State.changed) {
            let p: CGPoint = pan.translation(in: self)
            let width = self.contentView.frame.width
            let height = self.contentView.frame.height
            self.contentView.frame = CGRect(x: p.x,y: 0, width: width, height: height);
            self.deleteLabel2.frame = CGRect(x: p.x - deleteLabel2.frame.size.width-10, y: 0, width: 100, height: height)
            self.deleteLabel1.frame = CGRect(x: p.x + width + deleteLabel1.frame.size.width, y: 0, width: 100, height: height)
        }
    }
    
    @objc func onPan(_ pan: UIPanGestureRecognizer) {
        if pan.state == UIGestureRecognizer.State.began {
            
        } else if pan.state == UIGestureRecognizer.State.changed {
            self.setNeedsLayout()
        } else {
            if abs(pan.velocity(in: self).x) > 700 {
                let collectionView: UICollectionView = self.superview as! UICollectionView
                let indexPath: IndexPath = collectionView.indexPathForItem(at: self.center)!
                collectionView.delegate?.collectionView!(collectionView, performAction: #selector(onPan(_:)), forItemAt: indexPath, withSender: nil)
            } else {
                UIView.animate(withDuration: 0.2, animations: {
                    self.setNeedsLayout()
                    self.layoutIfNeeded()
                })
            }
        }
    }
}


