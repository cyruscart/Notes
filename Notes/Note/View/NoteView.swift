//
//  NoteView.swift
//  Notes
//
//  Created by Кирилл on 15.04.2022.
//

import UIKit

final class NoteView: UIView {
    
    // MARK: - Public properties
    
    var noteDidChanged: ((_ name: String, _ text: String) -> Void)?
    var didDeleteImage: ((_ atIndex: Int) -> Void)?
    
    // MARK: - Private properties
    
    private var lastAddedImageIndex = 0
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        stackView.backgroundColor = .systemBackground
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    private let dateTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.italicSystemFont(ofSize: 17)
        label.backgroundColor = .systemBackground
        return label
    }()
    
    private let headerTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = UIFont.boldSystemFont(ofSize: 20)
        textView.backgroundColor = .systemBackground
        return textView
    }()
    
    private let bodyTextView: UITextView = {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.backgroundColor = .systemBackground
        return textView
    }()
    
    private let namePlaceholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Название заметки"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .lightGray
        label.backgroundColor = .systemBackground
        return label
    }()
    
    
    private let textPlaceholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.text = "Текст заметки"
        label.backgroundColor = .systemBackground
        label.textColor = .lightGray
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .systemBackground
        setSubviews()
        setupStackView()
        setupConstraints()
        setupPlaceholdersConstraints()
        setInputAccessoryView()
        headerTextView.delegate = self
        bodyTextView.delegate = self
        isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private setup UI methods
    
    private func setSubviews() {
        addSubviews(scrollView)
        scrollView.addSubviews(stackView)
        headerTextView.addSubviews(namePlaceholderLabel)
        bodyTextView.addSubviews(textPlaceholderLabel)
    }
    
    private func setupStackView() {
        stackView.addArrangedSubview(dateTextLabel)
        stackView.addArrangedSubview(headerTextView)
        stackView.addArrangedSubview(bodyTextView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
                        
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -60),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }
    
    private func setupPlaceholdersConstraints() {
        NSLayoutConstraint.activate([
            namePlaceholderLabel.topAnchor.constraint(equalTo: headerTextView.topAnchor, constant: 5),
            namePlaceholderLabel.leadingAnchor.constraint(equalTo: headerTextView.leadingAnchor, constant: 10),
            
            textPlaceholderLabel.topAnchor.constraint(equalTo: bodyTextView.topAnchor, constant: 5),
            textPlaceholderLabel.leadingAnchor.constraint(equalTo: bodyTextView.leadingAnchor, constant: 10),
        ])
    }
    
    private func setInputAccessoryView() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Готово", style: .done, target: nil, action: #selector(keyboardDoneButtonPressed))
        let flexButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([flexButton, doneButton], animated: false)
        
        headerTextView.inputAccessoryView = toolBar
        bodyTextView.inputAccessoryView = toolBar
    }
    
    private func createImageView(from image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        
        let constraint = NSLayoutConstraint(
            item: imageView, attribute: .height,
            relatedBy: .equal,
            toItem: imageView, attribute: .width,
            multiplier: image.size.height / image.size.width, constant: 0.0
        )
        constraint.isActive = true
        layoutIfNeeded()
        
        setInteractionToImageView(imageView: imageView)
        
        return imageView
    }
    
    private func setInteractionToImageView(imageView: UIImageView) {
        imageView.tag = lastAddedImageIndex
        lastAddedImageIndex += 1
        let interaction = UIContextMenuInteraction(delegate: self)
        imageView.addInteraction(interaction)
    }
    
    // MARK: - Private action methods
    
    private func editNote() {
        guard let noteDidChanged = noteDidChanged else {
            return
        }
        noteDidChanged(headerTextView.text, bodyTextView.text)
    }
    
    private func setTapGestureRecognizer(on view: UIView) {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(keyboardDoneButtonPressed))
        view.addGestureRecognizer(gesture)
    }
    
    @objc private func keyboardDoneButtonPressed() {
        headerTextView.resignFirstResponder()
        bodyTextView.resignFirstResponder()
    }
    
}

// MARK: - UITextViewDelegate

extension NoteView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        editNote()
        
        guard let placeholder = textView.subviews.filter({ $0 is UILabel }).first else {
            return
        }
        placeholder.isHidden = !textView.text.isEmpty
        
    }
    
}

// MARK: - Public methods

extension NoteView {
    func setEditeState() {
        [headerTextView, bodyTextView].forEach { view in
            view.isUserInteractionEnabled = true
        }
        headerTextView.becomeFirstResponder()
        stackView.isUserInteractionEnabled = true
    }
    
    func setViewState() {
        [headerTextView, bodyTextView].forEach { view in
            view.isUserInteractionEnabled = false
            view.resignFirstResponder()
        }
        stackView.isUserInteractionEnabled = false
    }
    
    func showNote(name: String?, text: String?, images: [UIImage], date: String?) {
        headerTextView.text = name
        bodyTextView.text = text
        dateTextLabel.text = date
        addImages(images: images)
        namePlaceholderLabel.isHidden = !headerTextView.text.isEmpty
        textPlaceholderLabel.isHidden = !bodyTextView.text.isEmpty
    }
    
    func updateDate(date: String) {
        dateTextLabel.text = date
    }
    
    func addImages(images: [UIImage]) {
        images.forEach { image in
            let imageView = createImageView(from: image)
            setTapGestureRecognizer(on: imageView)
            stackView.addArrangedSubview(imageView)
        }
    }
}

// MARK: - UIContextMenuInteractionDelegate
extension NoteView: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {
        
        guard let imageIndex = interaction.view?.tag else {
            return nil
        }
        
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { [ weak self ] _ in
                guard let deleteAction = self?.createDeleteImageAction(at: imageIndex) else {
                    return UIMenu(title: "", children: [])
                }
                let children: [UIMenuElement] = [deleteAction]
                return UIMenu(title: "", children: children)
            })
    }
    
    private func createDeleteImageAction(at index: Int) -> UIAction {
        let attributes = UIMenuElement.Attributes.destructive
        
        let deleteImage = UIImage(systemName: "delete.left")
        return UIAction(
            title: "Delete image",
            image: deleteImage,
            identifier: nil,
            attributes: attributes) { [ weak self ] _ in
                self?.deleteImage(at: index)
                
                guard let didDeleteImage = self?.didDeleteImage else {
                    return
                }
                
                didDeleteImage(index)
            }
    }
    
    private func deleteImage(at index: Int) {
        // deleting UIImageView with need tag
        stackView.arrangedSubviews.forEach { view in
            if view is UIImageView && view.tag == index {
                view.removeFromSuperview()
            }
        }
        // update UIImageView tags after deleting
        lastAddedImageIndex = 0
        let imageViews = stackView.arrangedSubviews.filter { $0 is UIImageView }
        imageViews.forEach { view in
            view.tag = lastAddedImageIndex
            lastAddedImageIndex += 1
        }
    }
    
}
