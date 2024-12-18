//
//  ContentView.swift
//  BetterRest
//
//  Created by Alireza Fazel on 18/12/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = Date.now
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack {
                    Form {
                        Section("When do you want to wake up?") {
                            DatePicker(
                                "Please enter a time", selection: $wakeUp,
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                        }

                        Section("How much sleep do you need?") {
                            Stepper(
                                "\(sleepAmount.formatted()) hours",
                                value: $sleepAmount, in: 4...12, step: 0.25)
                        }

                        Section("Daily coffee intake") {
                            Picker("Number of cups", selection: $coffeeAmount) {
                                ForEach(1...20, id: \.self) { number in
                                    Text(
                                        number == 1 ? "1 cup" : "\(number) cups"
                                    )
                                }
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)

                    Button(action: calculateBedTime) {
                        Text("Calculate")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            }
            .navigationTitle("BetterRest")
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }

    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try BetterRest(configuration: config)

            let components = Calendar.current.dateComponents(
                [.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60

            let prediction = try model.prediction(
                wake: Double(hour + minute), estimatedSleep: sleepAmount,
                coffee: Double(coffeeAmount))

            let sleepTime = wakeUp - prediction.actualSleep

            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry there was a problem calculating your bedtime."
        }

        showingAlert = true
    }
}

#Preview {
    ContentView()
}
