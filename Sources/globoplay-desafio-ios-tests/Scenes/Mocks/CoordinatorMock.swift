//
//  CoordinatorMock.swift
//  globoplay-desafio-ios-tests
//
//  Created by Filipe Xavier Fernandes on 26/01/25.
//

import UIKit
@testable import globoplay_desafio_ios

class CoordinatorMock: CoordinatorProtocol {
    
    var navigateToFavoritesCalled = false
    var navigateToDetailsCalled = false
    var navigateToDetailsId: Int?
    var navigateToDetailsMediaType: MediaType?
    var popViewControllerCalled = false
    var presentErrorAlertCalled = false
    var presentedErrorMessage: String?

    func navigateToFavorites() {
        navigateToFavoritesCalled = true
    }

    func navigateToDetails(id: Int, mediaType: MediaType) {
        navigateToDetailsCalled = true
        navigateToDetailsId = id
        navigateToDetailsMediaType = mediaType
    }
    
    func popViewController() {
        popViewControllerCalled = true
    }
    
    func presentErrorAlert(message: String) {
        presentErrorAlertCalled = true
        presentedErrorMessage = message
    }
}
