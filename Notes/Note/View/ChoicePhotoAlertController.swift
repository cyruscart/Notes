//
//  ChoicePhotoAlertController.swift
//  Notes
//
//  Created by Кирилл on 15.04.2022.
//

import UIKit

final class ChoicePhotoAlertController: UIAlertController {
    
    private let output: ImagePickerProviderProtocol
    
    init(output: ImagePickerProviderProtocol) {
        self.output = output
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let takePhotoAction = createTakePhotoAlertAction()
        let choosePhotoFromGalleryAction = createChoosePhotoFromGalleryAction()
        let closeAction = UIAlertAction(title: "Закрыть", style: .cancel)
        
        addAction(takePhotoAction)
        addAction(choosePhotoFromGalleryAction)
        addAction(closeAction)
    }
    
    private func createTakePhotoAlertAction() -> UIAlertAction {
        UIAlertAction(title: "Сделать фото", style: .default) { [weak self] _ in
            self?.output.takeProfilePhoto()
        }
    }
    
    private func createChoosePhotoFromGalleryAction() -> UIAlertAction {
        UIAlertAction(title: "Выбрать из галереи", style: .default) { [weak self] _ in
            self?.output.choosePhotoFromGallery()
        }
    }
    
}
