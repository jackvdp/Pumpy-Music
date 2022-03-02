//
//  LoginView.swift
//  Pumpy Music iOS
//
//  Created by Jack Vanderpump on 03/01/2020.
//  Copyright © 2020 Jack Vanderpump. All rights reserved.
//

import SwiftUI
import ActivityIndicatorView

struct LoginView: View {
    
    @EnvironmentObject var accountVM: AccountManager
    let usernamePlaceholder: String
    let buttonText: String
    let pageSwitchText: String
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                PumpyView()
                Spacer()
                TextFieldView(string: $accountVM.usernameTF, placeholder: usernamePlaceholder)
                SecureTextFieldView(string: $accountVM.passwordTF, placeholder: "Enter your password")
                LogInButtonView(title: buttonText, action: {accountVM.attemptSign()})
                Spacer()
                Button(action: {
                    accountVM.togglePageState()
                }) {
                    Text(pageSwitchText)
                        .foregroundColor(.white)
                }
            }
            .padding(.all, 10.0)
            ActivityView(activityIndicatorVisible: $accountVM.activityIndicatorVisible)
        }
        .background(BackgroundView())
        .alert(isPresented: $accountVM.showingAlert) {
            Alert(title: Text("Error"),
                  message: Text(accountVM.errorAlert),
                  dismissButton: .default(Text("Got it!")))
        }
        .onAppear() {
            accountVM.attemptSign()
        }
        .accentColor(.white)
    }

}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    
    static let musicManager = MusicManager(username: "Test", settingsManager: SettingsManager(username: "Test"))
    
    static var previews: some View {
        LoginView(usernamePlaceholder: "Login", buttonText: "Login", pageSwitchText: "Register")
            .environmentObject(AccountManager())
    }
}
#endif

struct BackgroundView: View {
    let colour = Color.pumpyPink
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [colour, colour, colour, Color(#colorLiteral(red: 0.4331024013, green: 0.0725254769, blue: 0.4235387483, alpha: 1))]),
                             startPoint: .top,
                             endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)
    }
}

struct PumpyView: View {
    var body: some View {
        Image(K.pumpyImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

struct TextFieldView: View {
    @Binding var string: String
    let placeholder: String
    
    var body: some View {
        TextField(placeholder, text: $string)
            .textContentType(.emailAddress)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .colorScheme(.light)
            .accentColor(.pumpyPink)
            .padding(.all, 10)
    }
}

struct SecureTextFieldView: View {
    @Binding var string: String
    let placeholder: String
    
    var body: some View {
        SecureField(placeholder, text: $string)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .colorScheme(.light)
            .accentColor(.pumpyPink)
            .padding(.horizontal, 10)
            .padding(.bottom, 50)
    }
}

struct LogInButtonView: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
        }
        .frame(minWidth: 100, maxWidth: 100, minHeight: 40, maxHeight: 40)
        .foregroundColor(.pumpyPink)
        .background(Color.white)
        .cornerRadius(10)
    }
}

struct ActivityView: View {
    @Binding var activityIndicatorVisible: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.black)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                .opacity(0.5)
                .isHidden(!activityIndicatorVisible)
            ActivityIndicatorView(isVisible: $activityIndicatorVisible, type: .arcs)
                .frame(width: 50.0, height: 50.0)
                .foregroundColor(Color(UIColor(named: K.pumpyPink)!))
        }
    }
}
