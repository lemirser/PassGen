//
//  ContentView.swift
//  PassGen
//
//  Created by Leandro Serzo on 7/23/26.
//

import SwiftUI


// Add functionality to set the menubar as active when the toolbar is open
struct ContentView: View {
    @State private var withCapital = false
    @State private var withNumbers = false
    @State private var withSymbols = false
    @State private var passwordLength : Int = 16
    @State private var lengthText = "16"
    
    @State private var lowerOptions: String = "abcdefghijklmnopqrstuvwxyz"
    @State private var upperOptions: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    
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
            Text(lowerOptions)
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
                    }
            
            Toggle("Capital Letters", isOn: capitalBinding)
                .onChange(of: withCapital) {oldValue, newValue in
                    if newValue {
                        if let randomChar = upperOptions.randomElement() {
                            lowerOptions.append(randomChar)
                            }
                        }
                    }
                    
            Toggle("Numbers", isOn: numbersBinding)
            Toggle("Symbols", isOn: symbolsBinding)
            
            Button("Copy"){}
            Button("Regenerate"){}
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
