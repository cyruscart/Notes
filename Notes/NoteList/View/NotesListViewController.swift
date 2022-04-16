//
// NoteListViewController.swift
//  Notes
//
//  Created by Кирилл on 15.04.2022.
//

import UIKit

final class NoteListViewController: UIViewController {

    // MARK: - Private properties
    
    private let presenter: NoteListPresenterProtocol
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.rowHeight = 60
        return tableView
    }()
    
    private lazy var addNoteButton: UIBarButtonItem = {
        UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(didTapAddNoteButton)
        )
    }()
    
    private lazy var editNotesButton: UIBarButtonItem = {
        UIBarButtonItem(
            title: "Edit",
            style: .done,
            target: self,
            action: #selector(didTapEditNotesButton)
        )
    }()
    
    private lazy var deleteAllButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            title: "Delete all",
            style: .done,
            target: self,
            action: #selector(didTapDeleteAllButton)
        )
        button.tintColor = .red
        return button
    }()
    
    init(presenter: NoteListPresenterProtocol) {
        self.presenter = presenter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        registerTableViewCells()
        setNavBar()
        presenter.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Private configure UI methods
    
    private func registerTableViewCells() {
        tableView.register(
            NotesListCell.self,
            forCellReuseIdentifier: "\(NotesListCell.self)"
        )
    }
    
    private func setNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Заметки"
    }
    
    private func setupTableView() {
        view.addSubviews(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Private action methods
    
    @objc private func didTapAddNoteButton() {
        presenter.didTapAddNoteButton()
    }
    
    @objc private func didTapDeleteAllButton() {
        showAlert(title: "Вы точно хотите удалить все заметки?") { [ weak self ] in
            self?.presenter.didSelectDeleteAllNotesAction()
            self?.didTapEditNotesButton()
        }
    }
    
    @objc private func didTapEditNotesButton() {
        editNotesButton.title = editNotesButton.title == "Edit" ? "Done" : "Edit"
        let isEdit = editNotesButton.title == "Done"
        tableView.setEditing(isEdit, animated: true)
        
        
        navigationItem.leftBarButtonItem = isEdit ? deleteAllButton : nil
        navigationItem.rightBarButtonItems = editNotesButton.title == "Edit"
        ? [addNoteButton, editNotesButton]
        : [editNotesButton]
        
    }
    
    private func configureBarButtonItems() {
        navigationItem.rightBarButtonItems = presenter.fetchData().count == 0
        ? [addNoteButton]
        : [addNoteButton, editNotesButton]
        
        if presenter.fetchData().isEmpty {
            navigationItem.leftBarButtonItem = nil
            tableView.setEditing(false, animated: true)
        }
    }
    
}

// MARK: -  NotesListViewProtocol

extension NoteListViewController: NoteListViewProtocol {
    
    func presentViewController(_ view: UIViewController) {
        present(view, animated: true)
    }

    func reloadData() {
        tableView.reloadData()
        configureBarButtonItems()
    }
    
}

// MARK: -  UITableViewDataSource

extension NoteListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.fetchData().count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "\(NotesListCell.self)",
            for: indexPath
        ) as? NotesListCell else { return UITableViewCell() }
        
        let note = presenter.fetchData()[indexPath.row]
        
        let name = note.name == "" ? "Без названия" : note.name ?? "Без названия"
        
        let text = note.text ?? ""
        let date = note.created.getStringDate(style: .short)
        let image = note.images.first
        
        image == nil
        ? cell.configure(header: name, text: text, date: date)
        : cell.configureWithImage(header: name, text: text, date: date, image: image ?? UIImage())
        
        return cell
    }
}
// MARK: -  UITableViewDelegate

extension NoteListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectNote(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            presenter.didDeleteRow(at: indexPath)
        }
    }
    
}
