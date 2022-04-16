//
//  Note.swift
//  Notes
//
//  Created by Кирилл on 15.04.2022.
//

import UIKit

final class Note {
    var name: String?
    var text: String?
    var images: [UIImage] = []
    let created: Date
    var edited: Date?
    
    init(created: Date) {
        self.created = created
    }
    
    init(name: String?, text: String?, images: [UIImage], created: Date, edited: Date?) {
        self.name = name
        self.text = text
        self.images = images
        self.created = created
        self.edited = edited
    }
}

