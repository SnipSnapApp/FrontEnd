/*
 * Copyright (c) 2022. Josh Bedwell
 * All rights reserved.
 */

import AuthenticationServices
import SwiftUI

struct MainView: View {
    
    enum NonceStatus {
        case none
        case getting
        case got(nonce: String)
        case failed
    }
    
    @AppStorage("userId")
    private var userId: String?
    
    @AppStorage("deviceId")
    private var deviceId: String = UUID().uuidString
    
    @State
    private var triedToGetApnsToken: Bool = false
    
    @State
    private var serverMessage: String?
    
    @State
    private var signInWithAppleNonce: NonceStatus = .none
    
    
    var body: some View {
        NavigationView {
            if serverMessage != nil {
                infoView
            } else {
                loginView
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private var loginView: some View {
        VStack {
            switch signInWithAppleNonce {
            case .got(nonce: _):
                Text("Nonce obtained from server")
            case .getting:
                Text("Getting a nonce from server")
            case .failed:
                Text("Failed to get a nonce from server")
            case .none:
                Text("Have no nonce")
            }
            
            signInButton

        }
        .navigationTitle("Sign In")
        .onAppear {
            switch signInWithAppleNonce {
            case .none:
                Task {
                    await getNonce()
                }
            default:
                break
            }
        }
    }
    
    private var signInButton: some View {
        SignInWithAppleButton(.continue) { signInRequest in
            switch signInWithAppleNonce {
            case .got(let nonce):
                signInRequest.nonce = nonce
                signInWithAppleNonce = .none
            default:
                break
            }
        } onCompletion: { result in
            // TODO finish off
            switch result {
            case .success(let auth):
                guard let credentials = auth.credential as? ASAuthorizationAppleIDCredential else {
                    print("Could not cast credentials to ASAuthorizationAppleIDCredential")
                    return
                }
                userId = credentials.user
                guard let identityToken = credentials.identityToken else {
                    print("Error getting identity token from sign in with apple response")
                    return
                }
                let appleToken = String(decoding: identityToken, as: UTF8.self)
            
                Task {
                    print("Beginning login request")
                    let loginRequest = LoginRequest()
                    do {
                        let loginResponse = try await loginRequest.login(userId: credentials.user, appleToken: appleToken, deviceId: deviceId)
                        serverMessage = loginResponse.serverMessage
                        print("Got server message \(loginResponse.serverMessage)")
                    } catch {
                        print("Got error logging in: \(error)")
                    }
                }
            case .failure:
                print("The result of sign in with apple was failure")
                break
            }
        }
        .frame(height: 50)
        .padding(.horizontal, 20)
    }
    
    private func getNonce() async {
        signInWithAppleNonce = .getting
        print("Beginning get nonce request")
        let nonceRequest = NonceRequest(deviceId: deviceId)
        print("Made get nonce request")
        do {
            let nonceResponse = try await nonceRequest.getNonce()
            print("Got get nonce response")
            signInWithAppleNonce = .got(nonce: nonceResponse.nonce)
            print("Got nonce value: \(nonceResponse.nonce)")
        } catch {
            print("Failed to get a nonce")
            signInWithAppleNonce = .failed
        }
    }
    
    private var infoView: some View {
        VStack {
            Text("UserId: \(userId ?? "Error")")
            Text("Server message: \(serverMessage ?? "Error")")
        }
        .navigationTitle("User Info")
        .toolbar {
            Button {
                userId = nil
                serverMessage = nil
            } label: {
                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
