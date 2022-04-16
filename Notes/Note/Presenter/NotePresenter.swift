//
//  NotePresenter.swift
//  Notes
//
//  Created by Кирилл on 15.04.2022.
//

import UIKit

protocol NotePresenterProtocol: AnyObject {
    func didTapCameraButton()
    func didTapDoneButton()
    func noteDidChange(name: String, text: String)
    func didSelectDeleteAction()
    func viewDidLoad()
    func didDeleteImage(at index: Int)
}

protocol NotesViewProtocol: AnyObject {
    func showChoicePhotoAlert(output: ImagePickerProviderProtocol)
    func showImagePicker(imagePicker: UIImagePickerController)
    func showNote(note: Note)
    func updateDate(date: String)
    func addImage(image: UIImage)
    
    func showAlert(
        title: String,
        message: String?,
        actionTitle: String?,
        okCompletion: @escaping (() -> Void),
        actionCompletion: @escaping (() -> Void)
    )
}

final class NotePresenter {
    
    weak var view: NotesViewProtocol?
    private let imagePickerProvider: ImagePickerProviderProtocol
    private var note: Note
    private var noteListDelegate: NoteListDelegate
    
    init(
        imagePickerProvider: ImagePickerProviderProtocol,
        note: Note,
        noteListDelegate: NoteListDelegate
    ) {
        self.imagePickerProvider = imagePickerProvider
        self.note = note
        self.noteListDelegate = noteListDelegate
    }
}

// MARK: - NotesPresenterProtocol

extension NotePresenter: NotePresenterProtocol {
    
    func didDeleteImage(at index: Int) {
        note.images.remove(at: index)
    }
    
    func viewDidLoad() {
        view?.showNote(note: note)
    }
    
    func didSelectDeleteAction() {
        noteListDelegate.didDeleteNote()
    }
    
    func noteDidChange(name: String, text: String) {
        note.name = name
        note.text = text
    }
    
    
    func didTapCameraButton() {
        view?.showChoicePhotoAlert(output: imagePickerProvider)
        
        imagePickerProvider.didSelectPickerController = { [weak self] picker in
            if let picker = picker {
                self?.view?.showImagePicker(imagePicker: picker)
            } else {
                self?.view?.showAlert(
                    title: "Камера недоступна",
                    message: nil,
                    actionTitle: nil,
                    okCompletion: {},
                    actionCompletion: {}
                )
            }
        }
        
        imagePickerProvider.didSelectImage = { [weak self] image in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.note.images.append(image)
            strongSelf.view?.addImage(image: image)
            strongSelf.imagePickerProvider.closePicker()
        }
    }
    
    func didTapDoneButton() {
        note.edited = Date()
        noteListDelegate.didChange(note: note)
        
        let newDate = note.edited?.getStringDate(style: .medium, timeStyle: .short)
        view?.updateDate(date: newDate ?? "")
    }
}

