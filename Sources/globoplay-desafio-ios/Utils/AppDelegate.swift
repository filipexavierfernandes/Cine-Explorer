//
//  AppDelegate.swift
//  globoplay-desafio-ios
//
//  Created by Filipe Xavier Fernandes on 22/01/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: Coordinator?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = Colors.darkGray
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        let navigationController = UINavigationController()
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.barStyle = .black
        
        coordinator = Coordinator(navigationController: navigationController)
        coordinator?.start()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
}

