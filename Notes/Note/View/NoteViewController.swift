//
//  NoteViewController.swift
//  Notes
//
//  Created by Кирилл on 15.04.2022.
//

import UIKit

final class NoteViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let presenter: NotePresenterProtocol
    private lazy var noteView = view as? NoteView
    
    private lazy var closeButton: UIBarButtonItem = {
        UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(didTapCloseButton)
        )
    }()
    
    init(presenter: NotePresenterProtocol) {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = NoteView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultNavBarState()
        noteView?.setViewState()
        subscribeNoteViewActions()
        presenter.viewDidLoad()
    }
    
    // MARK: - Private settings UI methods
    
    private func setDefaultNavBarState() {
        let deleteButton = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(didTapDeleteButton)
        )
        
        let editButton = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(didTapEditButton)
        )
        
        navigationItem.rightBarButtonItems?.removeAll()
        navigationItem.rightBarButtonItems = [closeButton,editButton, deleteButton]
    }
    
    private func setEditNavBarState() {
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(didTapDoneButton)
        )
        
        let imageButton = UIBarButtonItem(
            barButtonSystemItem: .camera,
            target: self,
            action: #selector(didTapCameraButton)
        )
        navigationItem.rightBarButtonItems?.removeAll()
        navigationItem.rightBarButtonItems = [closeButton,doneButton, imageButton]
    }
    
    // MARK: - Private action methods
    
    private func subscribeNoteViewActions() {
        noteView?.noteDidChanged = { [ weak self ] name, text in
            self?.presenter.noteDidChange(name: name, text: text)
        }
        
        noteView?.didDeleteImage = { [ weak self ] index in
            self?.presenter.didDeleteImage(at: index)
        }
    }
    
    @objc private func didTapEditButton() {
        noteView?.setEditeState()
        setEditNavBarState()
    }
    
    @objc private func didTapDoneButton() {
        setDefaultNavBarState()
        noteView?.setViewState()
        presenter.didTapDoneButton()
    }
    
    @objc private func didTapCameraButton() {
        presenter.didTapCameraButton()
    }
    @objc private func didTapCloseButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapDeleteButton() {
        showAlert(title: "Вы точно хотите удалить заметку?") { [ weak self ] in
            self?.presenter.didSelectDeleteAction()
            self?.dismiss(animated: true)
        }
    }
}

    // MARK: - NotesViewProtocol

extension NoteViewController: NotesViewProtocol {
    func addImage(image: UIImage) {
        noteView?.addImages(images: [image])
    }
    
    func updateDate(date: String) {
        noteView?.updateDate(date: date)
    }
    
    func showNote(note: Note) {
        let stringDate = note.edited == nil
        ? note.created.getStringDate(style: .medium, timeStyle: .short)
        : note.edited?.getStringDate(style: .medium,  timeStyle: .short)
        
        noteView?.showNote(
            name: note.name,
            text: note.text,
            images: note.images,
            date: stringDate
        )
        
        if note.name == nil && note.text == nil && note.images.isEmpty {
            didTapEditButton()
        }
        
    }
    
    func showImagePicker(imagePicker: UIImagePickerController) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    func showChoicePhotoAlert(output: ImagePickerProviderProtocol) {
        let alert = ChoicePhotoAlertController(output: output)
        present(alert, animated: true, completion: nil)
    }
    
    func showAlert(
        title: String,
        message: String?,
        actionTitle: String?,
        okCompletion: @escaping (() -> Void),
        actionCompletion: @escaping (() -> Void)
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let OkAction = UIAlertAction(title: "OК", style: .cancel) {_ in
            okCompletion()
        }
        
        if let actionTitle = actionTitle {
            let extraAction = UIAlertAction(title: actionTitle, style: .default) { _ in
                actionCompletion()
            }
            alert.addAction(extraAction)
        }
        
        alert.addAction(OkAction)
        present(alert, animated: true, completion: nil)
    }
    
}
