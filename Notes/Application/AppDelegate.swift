//
//  AppDelegate.swift
//  Notes
//
//  Created by Кирилл on 15.04.2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        
        let storageService = StorageService()
        let presenter = NoteListPresenter(storageService: storageService)
        let view = NoteListViewController(presenter: presenter)
        presenter.view = view
        
        let navigationVC = UINavigationController(rootViewController: view)
        window?.rootViewController = navigationVC
        
        return true
    }
    
}
