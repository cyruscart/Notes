//
//  NotesListCell.swift
//  Notes
//
//  Created by Кирилл on 15.04.2022.
//

import UIKit

final class NotesListCell: UITableViewCell {
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()
    
    private let noteTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .left
        return label
    }()
    
    private let photoImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var basicConstraints = [
        headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
        headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
        
        dateLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 5),
        dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
        dateLabel.widthAnchor.constraint(equalToConstant: 80),
        
        noteTextLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 5),
        noteTextLabel.leadingAnchor.constraint(equalTo: dateLabel.trailingAnchor, constant: 10),
    ]
    
    private lazy var withPhotoConstraints = [
        headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: photoImageView.leadingAnchor, constant: -10),
        noteTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: photoImageView.leadingAnchor, constant: -10),
        
        photoImageView.widthAnchor.constraint(equalToConstant: 40),
        photoImageView.heightAnchor.constraint(equalToConstant: 40),
        photoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        photoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
    ]
    
    private lazy var withoutPhotoConstraints = [
        headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10),
        noteTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10),
    ]
    
    private func setTextData(header: String, text: String, date: String) {
        headerLabel.text = header
        noteTextLabel.text = text
        dateLabel.text = date
    }
    
    private func setBasicLayout() {
        contentView.addSubviews(headerLabel, noteTextLabel, dateLabel)
        basicConstraints.forEach { $0.isActive = true }
        
    }
    
    private func setWithImageLayout() {
        setBasicLayout()
        contentView.addSubviews(photoImageView)
        withPhotoConstraints.forEach { $0.isActive = true }
    }
    
    private func setWithoutImageLayout() {
        setBasicLayout()
        withoutPhotoConstraints.forEach { $0.isActive = true }
    }
    
    override func prepareForReuse() {
        photoImageView.image = nil
    }
    
    // MARK: - Public methods
    
    func configureWithImage(header: String, text: String, date: String, image: UIImage) {
        setWithImageLayout()
        setTextData(header: header, text: text, date: date)
        photoImageView.image = image
    }
    
    func configure(header: String, text: String, date: String) {
        setWithoutImageLayout()
        setTextData(header: header, text: text, date: date)
    }
}
