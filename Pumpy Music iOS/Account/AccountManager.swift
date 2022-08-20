//
//  AccountVM.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 02/04/2021.
//  Copyright © 2021 Jack Vanderpump. All rights reserved.
//

import Foundation
import Firebase
import PumpyLibrary

class AccountManager: AccountManagerProtocol {
    static let shared = AccountManager()
    @Published var pageState: SignType = .login
    @Published var usernameTF = String()
    @Published var passwordTF = String()
    @Published var activityIndicatorVisible = false
    @Published var errorAlert = String()
    @Published var showingAlert = false
    
    @Published var user: User?
    
    let defaults = UserDefaults.standard
    
    init() {
        loadSavedDetails()
    }
    
    func loadSavedDetails() {
        if let name = defaults.string(forKey: K.username), let password = defaults.string(forKey: K.password) {
            usernameTF = name
            passwordTF = password
        }
    }
    
    func togglePageState() {
        switch pageState {
        case .login:
            pageState = .register
        case .register:
            pageState = .login
        }
    }
    
    func attemptSign() {
        if usernameTF != String() {
            activityIndicatorVisible = true
            switch pageState {
            case .login:
                attemptSignIn(usernameTF, passwordTF)
            default:
                attemptSignUp(usernameTF, passwordTF)
            }
        }
    }

    func attemptSignIn(_ name: String, _ password: String) {
        Auth.auth().signIn(withEmail: name.lowercased(), password: password) { result, error in
            self.respondToLogin(result, error)
        }
    }
    
    func attemptSignUp(_ name: String, _ password: String) {
        Auth.auth().createUser(withEmail: name.lowercased(), password: password) { result, error in
            self.respondToLogin(result, error)
        }
    }
    
    func respondToLogin(_ result: AuthDataResult?, _ error: Error?) {
        self.activityIndicatorVisible = false
        if let e = error {
            errorAlert = e.localizedDescription
            showingAlert = true
        } else {
            if let r = result, let email = r.user.email {
                loginSucceed(email)
            }
        }
    }
    
    func loginSucceed(_ email: String) {
        user = User(username: email.lowercased())
        self.defaults.set(self.usernameTF.lowercased(), forKey: K.username)
        self.defaults.set(self.passwordTF, forKey: K.password)
    }
    
    func signOut() {
        usernameTF = String()
        passwordTF = String()
        user?.signOut()
        user = nil
    }
    
}
