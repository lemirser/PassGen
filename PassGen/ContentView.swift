//
//  ContentView.swift
//  PassGen
//
//  Created by Leandro Serzo on 7/23/26.
//

import SwiftUI
import AppKit


// Add functionality to set the menubar as active when the toolbar is open
struct ContentView: View {
    @State private var withCapital = true
    @State private var withNumbers = true
    @State private var withSymbols = true
    @State private var passwordLength : Int = 16
    @State private var lengthText = "16"
    
    static let lowerOptions = "abcdefghijklmnopqrstuvwxyz"
    @State private var defaultPass: String = lowerOptions
    @State private var upperOptions: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    @State private var numberOptions: String = "0123456789"
    @State private var specialOptions: String = "!@#$%^&*()-_=+"
    
    @State private var generatedPassword: String = ""
    
    var capitalBinding: Binding<Bool> {
        Binding(
            get:{withCapital},
            set: {newValue in
                if newValue == false && withNumbers == false && withSymbols == false {
                    return
                }
                withCapital = newValue
            }
        )
    }
    
    var numbersBinding: Binding<Bool> {
        Binding(
            get:{withNumbers},
            set: {newValue in
                if newValue == false && withCapital == false && withSymbols == false {
                    return
                }
                withNumbers = newValue
            }
        )
    }
    
    var symbolsBinding: Binding<Bool> {
        Binding(
            get:{withSymbols},
            set: {newValue in
                if newValue == false && withCapital == false && withNumbers == false {
                    return
                }
                withSymbols = newValue
            }
        )
    }
    
    var body: some View {
        VStack {
            Text(generatedPassword)
            Text("Strength: strong")
            
            TextField("Length", text:$lengthText)
                .onChange(of: lengthText, {oldValue,
                    newValue in lengthText = newValue.filter {$0.isNumber}
                }
                )
                .onSubmit {
                    var value = Int(lengthText) ?? 16
                    if value < 8 { value = 8 }
                    if value > 64 { value = 64 }
                    passwordLength = value
                    lengthText = String(value)
                    generatedPassword = generatePassword()
                    }
            
            Toggle("Capital Letters", isOn: capitalBinding).onChange(of: withCapital) {
                oldValue, newValue in generatedPassword = generatePassword()
            }
                    
            Toggle("Numbers", isOn: numbersBinding).onChange(of: withNumbers) {
                oldValue, newValue in generatedPassword = generatePassword()
            }
            
            Toggle("Symbols", isOn: symbolsBinding).onChange(of: withSymbols) {
                oldValue, newValue in generatedPassword = generatePassword()
            }
            
            Button("Copy"){
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(generatedPassword, forType: .string)
            }
            
            Button("Regenerate") {
                generatedPassword = generatePassword()
            }
        }
        .padding()
        .onAppear() {
            generatedPassword = generatePassword()
        }
    }
    
    func generatePassword() -> String {
        
        var requiredChars: [Character] = []
        var pool = ContentView.lowerOptions
        
        if let randomChar = ContentView.lowerOptions.randomElement(){
            requiredChars.append(randomChar)
        }
        
        if withCapital {
            if let randomChar = upperOptions.randomElement() {
                requiredChars.append(randomChar)
            }
            pool += upperOptions
        }
        
        if withNumbers {
            if let randomChar = numberOptions.randomElement() {
                requiredChars.append(randomChar)
            }
            pool += numberOptions
        }
        
        if withSymbols {
            if let randomChar = specialOptions.randomElement() {
                requiredChars.append(randomChar)
            }
            pool += specialOptions
        }
        
        let remainingLength = passwordLength - requiredChars.count
        
        for _ in 0..<remainingLength {
            if let randomChar = pool.randomElement() {
                requiredChars.append(randomChar)
            }
        }
        
        let shuffledChars = requiredChars.shuffled()
        return String(shuffledChars)
        
    }
    
}

#Preview {
    ContentView()
}
