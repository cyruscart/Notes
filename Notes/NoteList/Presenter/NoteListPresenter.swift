//
//  NotesListPresenter.swift
//  Notes
//
//  Created by Кирилл on 15.04.2022.
//

import Foundation
import UIKit

protocol NoteListPresenterProtocol: AnyObject {
    func fetchData() -> [Note]
    func viewDidLoad()
    func didTapAddNoteButton()
    func didSelectNote(at indexPath: IndexPath)
    func didSelectDeleteAllNotesAction()
    func didDeleteRow(at indexPath: IndexPath)
}

protocol NoteListViewProtocol: AnyObject {
    func reloadData()
    func presentViewController(_ view: UIViewController)
}

protocol NoteListDelegate {
    func didDeleteNote()
    func didChange(note: Note)
}

final class NoteListPresenter {
    weak var view: NoteListViewProtocol?
    private let storageService: StorageServiceProtocol
    private var currentNoteIndex: Int?
    
    private var data: [Note] = [] {
        didSet {
            view?.reloadData()
        }
    }
    // переменная для временного сохранения вновь созданной заметки(пока она не
    // будет сохранена пользователем
    private var temporaryNote: Note?
    
    init(storageService: StorageServiceProtocol) {
        self.storageService = storageService
    }
    
    private func createNoteViewController(with note: Note) -> UIViewController {
        let imageProvider = ImagePickerProvider()
        
        let presenter = NotePresenter(
            imagePickerProvider: imageProvider,
            note: note,
            noteListDelegate: self
        )
        
        let view = NoteViewController(presenter: presenter)
        presenter.view = view
        return view
    }
    
    private func sortData() {
        data.sort { noteOne, noteTwo in
            
            guard let dateOne = noteOne.edited, let dateTwo = noteTwo.edited else {
                return false
            }
            
            return dateOne > dateTwo
        }
    }
    
}

// MARK: - NotesListPresenterProtocol

extension NoteListPresenter: NoteListPresenterProtocol {
    func didDeleteRow(at indexPath: IndexPath) {
        data.remove(at: indexPath.row)
        storageService.saveNotes(notes: data)
    }
    
    func didSelectDeleteAllNotesAction() {
        data.removeAll()
        storageService.saveNotes(notes: data)
    }
    
    func didSelectNote(at indexPath: IndexPath) {
        currentNoteIndex = indexPath.row
        let note = data[indexPath.row]
        let viewController = createNoteViewController(with: note)
        let navVC = UINavigationController(rootViewController: viewController)
        view?.presentViewController(navVC)
    }
    
    func didTapAddNoteButton() {
        let note = Note(created: Date())
        temporaryNote = note
        let viewController = createNoteViewController(with: note)
        let navVC = UINavigationController(rootViewController: viewController)
        view?.presentViewController(navVC)
    }
    
    func fetchData() -> [Note] {
        return data
    }
    
    func viewDidLoad() {
        storageService.fetchNotes { [ weak self ] notes in
            self?.data = notes
        }
    }
}
// MARK: -  NoteListDelegate

extension NoteListPresenter: NoteListDelegate {
    func didDeleteNote() {
        guard let index = currentNoteIndex else {
            return
        }
        data.remove(at: index)
        storageService.saveNotes(notes: data)
    }
    
    func didChange(note: Note) {
        if let temporaryNote = temporaryNote {
            data.append(temporaryNote)
            self.temporaryNote = nil
        }
        storageService.saveNotes(notes: data)
        sortData()
    }
    
}
