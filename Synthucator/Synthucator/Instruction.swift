//
//  Instruction.swift
//  Synthucator
//
//  Created by PlaCDreamer on 13/01/2025.
//

import SwiftUI

enum TutorialStep: Int {
    case oscillators = 0
    case adsr = 1
    case lpf = 2
    case delay = 3
    case reverb = 4
}

struct TutorialOverlay: View { //Instruction
    @Binding var currentStep: TutorialStep?
    
    var body: some View {
        ZStack {
                    VStack {
                        switch currentStep {
                        case .oscillators: //Step 1
                            TutorialStepView(
                                title:"Step 1: Select Your Sound Source",
                                description: "Tap either a Circle or a Button to activate an Oscillator"
                            )
                        case .adsr: //Step 2
                            TutorialStepView(
                                title:"Step 2: Shape Your Sound",
                                description: "Adjust Attack, Decay, Sustain, and Release knobs"
                                )
                        case .lpf: //Step 3
                            TutorialStepView(
                                title:"Step 3: Filter Your Sound",
                                description: "Use Low-Pass Filter (LPF) to adjust the Tone"
                                )
                        case .delay: //Step 4
                            TutorialStepView(
                                title:"Step 4: Add Delay",
                                description: "Adjust Delay amount and Delay Feedback"
                                )
                        case .reverb: //Step 5
                            TutorialStepView(
                                title:"Step 4: Add Reverb",
                                description: "Turn on the Reverb and create a Space"
                                )
                        case .none:
                            EmptyView()
                        }
                Button("Next") { //Button for the next step
                    moveToNextStep()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(15)
        }
    }
    private func moveToNextStep() { //Button function to move for the next step
        guard let currentStep = currentStep else { return }
        
        if let nextStep = TutorialStep(rawValue: currentStep.rawValue + 1) {
            withAnimation {
                self.currentStep = nextStep
            }
        } else {
            withAnimation {
                self.currentStep = nil
            }
        }
    }
}

struct TutorialStepView: View { //The words of the Instruction
    let title: String
    let description: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .foregroundColor(.white)
            Text(description)
                .foregroundColor(.white)
        }
    }
}
