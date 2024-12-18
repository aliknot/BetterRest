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
                LinearGradient(
                    colors: [.deepBlue, .primaryPurple],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack {
                    Form {
                        Section {
                            DatePicker(
                                "Please enter a time", selection: $wakeUp,
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .datePickerStyle(.wheel)
                            .padding(.vertical)
                        } header: {
                            Text("When do you want to wake up?")
                                .font(.title3.bold())
                                .foregroundStyle(.gold)
                                .textCase(nil)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                        Section {
                            Stepper(
                                "\(sleepAmount.formatted()) hours",
                                value: $sleepAmount, in: 4...12, step: 0.25
                            )
                        } header: {
                            Text("How much sleep do you need?")
                                .font(.title3.bold())
                                .foregroundStyle(.gold)
                                .textCase(nil)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }

                        Section {
                            Picker("Number of cups", selection: $coffeeAmount) {
                                ForEach(1...20, id: \.self) { number in
                                    Text(number == 1 ? "1 cup" : "\(number) cups")
                                }
                            }
                        } header: {
                            Text("Daily coffee intake")
                                .font(.title3.bold())
                                .foregroundStyle(.gold)
                                .textCase(nil)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(.white)

                    Button(action: calculateBedTime) {
                        Text("Calculate")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gold)
                            .foregroundStyle(.deepBlue)
                            .font(.headline)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding()
                }
            }
            .navigationTitle("BetterRest")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.deepBlue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
        .preferredColorScheme(.dark)
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
