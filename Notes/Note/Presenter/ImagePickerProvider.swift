//
//  ImagePickerProvider.swift
//  Notes
//
//  Created by Кирилл on 15.04.2022.
//

import UIKit
import AVFoundation

protocol ImagePickerProviderProtocol: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var didSelectImage: ((UIImage) -> Void)? { get set }
    var didSelectPickerController: ((UIImagePickerController?) -> Void)?  { get set }
    func choosePhotoFromGallery()
    func takeProfilePhoto()
    func closePicker()
}

final class ImagePickerProvider: NSObject, ImagePickerProviderProtocol {
    
    private let pickerViewController = UIImagePickerController()
    var didSelectImage: ((UIImage) -> Void)?
    var didSelectPickerController: ((UIImagePickerController?) -> Void)?
    
    override init() {
        super.init()
        
        pickerViewController.delegate = self
    }
    
    func closePicker() {
        pickerViewController.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        var newImage: UIImage
        
        if let chosenImage = info[.editedImage] as? UIImage {
            newImage = chosenImage
        } else if let chosenImage = info[.originalImage] as? UIImage {
            newImage = chosenImage
        } else {
            return
        }
        
        guard let didSelectImage = didSelectImage else { return }
        didSelectImage(newImage)
    }
    
    private func createCameraImagePicker() -> UIImagePickerController? {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            pickerViewController.sourceType = .camera
            pickerViewController.allowsEditing = false
            return pickerViewController
        } else {
            return nil
        }
    }
    
    func choosePhotoFromGallery() {
        pickerViewController.sourceType = .photoLibrary
        pickerViewController.allowsEditing = false
        pickerViewController.mediaTypes = ["public.image"]
        guard let didSelectPickerController = didSelectPickerController else { return }
        didSelectPickerController(pickerViewController)
    }
    
    func takeProfilePhoto() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] access in
            DispatchQueue.main.async { [weak self] in
                guard let didSelectPickerController = self?.didSelectPickerController else { return }
                switch access {
                case true:
                    let picker = self?.createCameraImagePicker()
                    didSelectPickerController(picker)
                case false:
                    didSelectPickerController(nil)
                }
            }
        }
    }
    
}
