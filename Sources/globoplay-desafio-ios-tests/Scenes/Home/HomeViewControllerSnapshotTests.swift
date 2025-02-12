//
//  HomeViewControllerSnapshotTests.swift
//  globoplay-desafio-ios-tests
//
//  Created by Filipe Xavier Fernandes on 27/01/25.
//

import SnapshotTesting
import XCTest
@testable import globoplay_desafio_ios

class HomeViewControllerSnapshotTests: XCTestCase {
    
    func testHomeViewController() {
        let service = MediaService()
        let coordinator = Coordinator(navigationController: UINavigationController())
        let viewController = HomeViewController(service: service, coordinator: coordinator)
        
        isRecording = false

        viewController.loadViewIfNeeded()
        viewController.view.frame = CGRect(x: 0, y: 0, width: 1179, height: 2556)
        
        // Comparação de snapshot
        assertSnapshot(matching: viewController, as: .image)
    }
}
