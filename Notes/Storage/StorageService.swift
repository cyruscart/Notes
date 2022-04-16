//
//  StorageService.swift
//  Notes
//
//  Created by Кирилл on 15.04.2022.
//

import CoreData
import UIKit

protocol StorageServiceProtocol {
    func fetchNotes(completion: @escaping ([Note]) -> Void)
    func saveNotes(notes: [Note])
}

final class StorageService {
    
    // MARK: - CoreData stack
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Note")
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        
        return container
    }()
    
    //    lazy var writeContext: NSManagedObjectContext = {
    //        let context = container.newBackgroundContext()
    //        context.mergePolicy = NSOverwriteMergePolicy
    //        context.automaticallyMergesChangesFromParent = true
    //        return context
    //    }()
    
    //    lazy var readContext: NSManagedObjectContext = {
    //        let context = container.viewContext
    //        context.automaticallyMergesChangesFromParent = true
    //        return context
    //    }()
    
    lazy var fetchRequest: NSFetchRequest<DBNote> = {
        let fetchRequest = DBNote.fetchRequest()
        let editedSortDescriptor = NSSortDescriptor(key: "edited", ascending: false)
        let createdSortDescriptor = NSSortDescriptor(key: "created", ascending: false)
        fetchRequest.sortDescriptors = [editedSortDescriptor, createdSortDescriptor]
        return fetchRequest
    }()
    
    // MARK: - Private Core Data methods
    
    private func performSave(contextCompletion: @escaping ((NSManagedObjectContext) -> Void)) {
        let context = container.newBackgroundContext()
        
        context.perform {
            contextCompletion(context)
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("Couldn't save private context: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func addDBNoteToContext(note: Note, to context: NSManagedObjectContext) {
        let dbNote = DBNote(context: context)
        dbNote.name = note.name
        dbNote.text = note.text
        dbNote.images = convert(images: note.images)
        dbNote.created = note.created
        dbNote.edited = note.edited
    }
    
    func deleteAll(from context: NSManagedObjectContext) {
        do {
            let dbNotes = try context.fetch(fetchRequest)
            
            dbNotes.forEach { dbNote in
                context.delete(dbNote)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Private prepare data methods
    
    private func convert(data: Data?) -> [UIImage] {
        var dataArray: [Data] = []
        
        guard let data = data else {
            return []
        }
        
        do {
            dataArray = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data) as? [Data] ?? []
        } catch {
            print(error.localizedDescription)
        }
        
        var images: [UIImage] = []
        
        dataArray.forEach { data in
            guard let image = UIImage(data: data) else { return }
            images.append(image)
        }
        return images
    }
    
    private func convert(images: [UIImage]) -> Data {
        
        var dataArray: [Data] = []
        
        images.forEach { image in
            guard let data = image.jpegData(compressionQuality: 0.1) else { return }
            dataArray.append(data)
        }
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: dataArray, requiringSecureCoding: true)
            return data
        } catch {
            print(error.localizedDescription)
            return Data()
        }
    }
    
    private func parse(dbNotes: [DBNote]) -> [Note] {
        var notes: [Note] = []
        
        dbNotes.forEach { dbNote in
            let note = Note(
                name: dbNote.name,
                text: dbNote.text,
                images: convert(data: dbNote.images),
                created: dbNote.created ?? Date(),
                edited: dbNote.edited
            )
            notes.append(note)
        }
        return notes
    }
    
}

// MARK: - StorageServiceProtocol

extension StorageService: StorageServiceProtocol {
    
    func saveNotes(notes: [Note]) {
        
        performSave { [ weak self ] context in
            self?.deleteAll(from: context)
            
            notes.forEach { note in
                self?.addDBNoteToContext(note: note, to: context)
            }
        }
    }
    
    
    func fetchNotes(completion: @escaping ([Note]) -> Void) {
        
        do {
            let dbNotes = try container.viewContext.fetch(fetchRequest)
            let notes = parse(dbNotes: dbNotes)
            completion(notes)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
