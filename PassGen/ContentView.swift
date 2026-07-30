//
//  ContentView.swift
//  PassGen
//
//  Created by Leandro Serzo on 7/23/26.
//

import SwiftUI
import AppKit


struct ContentView: View {
    @State private var withCapital = true
    @State private var withNumbers = true
    @State private var withSymbols = true
    @State private var passwordLength : Int = 16
    @State private var lengthText = "16"
    
    @State private var lowerOptions: String = "abcdefghijklmnopqrstuvwxyz"
    @State private var upperOptions: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    @State private var numberOptions: String = "0123456789"
    @State private var specialOptions: String = "!@#$%^&*()-_=+"
    
    @State private var generatedPassword: String = ""
    
    @State private var clipboardTimer: Timer?
    @State private var copiedPassword: String = ""
    
    @State private var currentEntropy: Double = 0
    
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
            Text(charColor())
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("Strength: \(strengthLabel())").padding(2)
            
            ProgressView(value: strengthPercentage()/100)
                .tint(strengthColor())
            
            TextField("Length", text:$lengthText)
                .frame(width: 60)
                .multilineTextAlignment(.center)
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
                    currentEntropy = calculateEntropy()
                    }
            
            VStack(alignment: .leading){
                Toggle("Capital Letters", isOn: capitalBinding).onChange(of: withCapital) {
                    oldValue, newValue in generatedPassword = generatePassword()
                    currentEntropy = calculateEntropy()
                }
                
                Toggle("Numbers", isOn: numbersBinding).onChange(of: withNumbers) {
                    oldValue, newValue in generatedPassword = generatePassword()
                    currentEntropy = calculateEntropy()
                }
                
                Toggle("Symbols", isOn: symbolsBinding).onChange(of: withSymbols) {
                    oldValue, newValue in generatedPassword = generatePassword()
                    currentEntropy = calculateEntropy()
                }
            }
            .padding()
            
            HStack(){
                Button("Copy"){
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(generatedPassword, forType: .string)
                    
                    copiedPassword = generatedPassword
                    
                    clipboardTimer?.invalidate()
                    
                    // Clear clipboard after 90s if the value in the clipboard is still the copied password
                    // Reset timer every click on the Copy button
                    clipboardTimer = Timer.scheduledTimer(withTimeInterval: 90, repeats: false) {
                        _ in let pasteboardContents = NSPasteboard.general.string(forType: .string)
                        if pasteboardContents == copiedPassword {
                            NSPasteboard.general.clearContents()
                        }
                    }
                    AccessibilityNotification.Announcement("Password copied to clipboard, password strength is \(strengthLabel()).").post()
                }
                
                Button("Regenerate") {
                    generatedPassword = generatePassword()
                    currentEntropy = calculateEntropy()
                    AccessibilityNotification.Announcement("New password generated, new password strength is \(strengthLabel()).").post()
                }
            }
        }
        .padding()
        .frame(width: 300, height: 269 + CGFloat(lineCount() - 1) * 20)
        .onAppear() {
            generatedPassword = generatePassword()
            currentEntropy = calculateEntropy()
        }
    }
    
    func generatePassword() -> String {
        
        var requiredChars: [Character] = []
        var pool = lowerOptions
        
        if let randomChar = lowerOptions.randomElement(){
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
    
    func calculatePoolSize() -> Int {
        
        var poolSize = lowerOptions.count
        
        if withCapital {
            poolSize += upperOptions.count
        }
        
        if withNumbers {
            poolSize += numberOptions.count
        }
        
        if withSymbols {
            poolSize += specialOptions.count
        }
        
        return poolSize
    }
    
    func calculateEntropy() -> Double {
        
        let poolSize = calculatePoolSize()
        let entropy = Double(passwordLength) * log2(Double(poolSize))
        
        return entropy
    }
    
    func strengthLabel() -> String {
        
        let entropy = currentEntropy
        var strength = ""
        
        if entropy <= 40 {
            strength = "Weak"
        } else if entropy <= 60 {
            strength = "Fair"
        } else if entropy <= 100 {
            strength = "Strong"
        } else {
            strength = "Very Strong"
        }
        
        return strength
    }
    
    func strengthPercentage() -> Double {
        
        let entropy = currentEntropy
        
        let percentage = min((entropy / 100) * 100,100)
        
        return percentage
    }
    
    func formattedPassword() -> String {
        let charList = generatedPassword
        let stepSize = 20
        
        // Step through character counts in increments of 20
        let allChunks = stride(from: 0, to: charList.count, by: stepSize).map { i in
            // Convert starting integer to a valid String.Index position
            let start = charList.index(charList.startIndex, offsetBy: i)
            
            // Find ending index, capping at endIndex so it doesn't run off the end
            let end = charList.index(start, offsetBy: stepSize, limitedBy: charList.endIndex) ?? charList.endIndex
            
            // Slice using valid String.Index range
            return String(charList[start..<end])
        }
        
        // Stack chunks line-by-line with newlines
        return allChunks.joined(separator: "\n")
    }
    
    func strengthColor() -> Color {
        let label = strengthLabel()
        
        if label == "Weak" {
            return .red
        } else if label == "Fair" {
            return .yellow
        } else if label == "Strong" {
            return Color(red: 0.55, green: 0.82, blue: 0.39)
        } else {
            return .green
        }
    }
    
    func charColor() -> AttributedString {
        let formattedChar = formattedPassword()
        let upperChecker = upperOptions
        let numberChecker = numberOptions
        let specialChecker = specialOptions
        
        var result = AttributedString()
        
        for char in formattedChar {
            // Wrap the single character into an AttributedString
            var styledChar = AttributedString(String(char))
            
            // Determine the foreground color based on character set matching
            if upperChecker.contains(char) {
                styledChar.foregroundColor = .green
            } else if numberChecker.contains(char) {
                styledChar.foregroundColor = .yellow
            } else if specialChecker.contains(char) {
                styledChar.foregroundColor = .red
            } else {
                // Retain default color
                styledChar.foregroundColor = .primary
            }
            
            result.append(styledChar)
        }
        
        return result
    }
    
    func lineCount() -> Int {
        let allChunks = formattedPassword()
        
        let lineCount = allChunks.split(separator: "\n")
        
        return lineCount.count
    }
    
}

#Preview {
    ContentView()
}
