//
//  ContentView.swift
//  BetterRest
//
//  Created by Oleg Gavashi on 26.07.2023.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUpTime = setTime(hours: 7, minutes: 0)
    @State private var amountOfSleep = 8.0
    @State private var coffeIntake = 1
    @State private var goToBedTime = setTime(hours: 23, minutes: 0)
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    
    static func setTime(hours: Int, minutes: Int) -> Date {
        var components = DateComponents()
        components.hour = hours
        components.minute = minutes
        
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try BetterRestML(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUpTime)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let wakeUp = Double(hour + minute)
            
            
            let prediction = try model.prediction(wake: wakeUp, estimatedSleep: amountOfSleep, coffee: Double(coffeIntake))
            
            let bedTime = wakeUpTime - prediction.actualSleep
            goToBedTime = bedTime
        }
        catch {
            alertTitle = "Error occured"
            alertMessage = "Something went wrong with AI. Please, try again."
            showAlert = true
        }
        
    }
    
    var body: some View {
        
        NavigationView {
            Form {
                Section {
                    VStack {
                        DatePicker("Select wake up time", selection: $wakeUpTime, displayedComponents: .hourAndMinute)
                            .onChange(of: wakeUpTime) { _ in
                                calculateBedTime()
                            }
                    }
                }
                Section {
                    Stepper("\(amountOfSleep.formatted()) hours", value: $amountOfSleep, in: 2...12, step: 1)
                        .onChange(of: amountOfSleep) { _ in
                            calculateBedTime()
                        }
                } header: {
                    Text("Desired amount of sleep")
                        .font(.headline)
                }
                Section {
                    Stepper(coffeIntake == 1 ? "1 cup" : "\(coffeIntake) cups", value: $coffeIntake, in: 1...10, step: 1)
                        .onChange(of: coffeIntake) { _ in
                            calculateBedTime()
                        }
                } header: {
                    Text("Daily coffee intake")
                        .font(.headline)
                }
                Section {
                    Text("You should go to bed at: ")
                    +
                    Text("\(goToBedTime.formatted(date: .omitted, time: .shortened))")
                        .font(.headline)
                } header: {
                    Text("AI Analysis")
                        .font(.headline)
                }
            }
            .navigationTitle("BetterRest")
            .alert(alertTitle, isPresented: $showAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
