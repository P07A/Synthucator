//
//  Scenes.swift
//  Synthucator
//
//  Created by PlaCDreamer on 23/11/2024.
//

import SwiftUI
import Tonic

class Scenes: ObservableObject { //Oscillators circles and buttons
    @Published var oscillator1Scene = false
    @Published var oscillator2Scene = false
    let synth = SynthClass()
    
    func toggleOscillator1() { //Osc1 button
        oscillator1Scene.toggle()
        if oscillator1Scene == true {
            synth.startOscillator1()
        } else {
            synth.stopOscillator1()
        }
        }

    func toggleOscillator2() { //Osc2 button
        oscillator2Scene.toggle()
        if oscillator2Scene == true {
            synth.startOscillator2()
        } else {
            synth.stopOscillator2()
        }
        }
}
struct OscillatorCircle1: View { //Osc1 circle and description
    let isRunning: Bool
    @State private var opacity = 1.0
    @State private var animationWorkItem: DispatchWorkItem? //Circle blink
    @State public var infoShowing1 = true //Showing up the description with ()
    @State public var oscillator1Pressed = false
    var scenes: Scenes
    var conductor: SynthClass
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle() // The background of the circle1
                    .fill(Color.black.opacity(0.7))
                    .frame(width: 240, height: 180)
                
                Circle() //Circle1
                    .fill(Color.green)
                    .frame(width: 150, height: 150)
                    .opacity(opacity) //Transparancy
                    .onChange(of: isRunning) { _, newValue in
                        animationWorkItem?.cancel()
                        
                        if newValue { //Repeat blinking
                            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                opacity = 0.3
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                opacity = 1.0
                            }
                        }
                    }
                    .onTapGesture { //When it is pressed
                        handleToggle1()  // Use the callback
                    }
            }
            Button("Oscillator1") { //The button with a Text Oscillator1
                handleToggle1()
            }
            .font(.title)
            .bold()
            .foregroundColor(.green)
            .shadow(radius: 2)
            Text("(Choose a sound source 1)")
                .foregroundColor(.black)
                .opacity(infoShowing1 ? 1.0 : 0.0)
        }
        
    }
    private func handleToggle1() { //function when the button1 and description is pressed
        oscillator1Pressed.toggle()
        infoShowing1.toggle()
        scenes.toggleOscillator1()
        
        if oscillator1Pressed {
            conductor.startOscillator1()
        } else {
            conductor.stopOscillator1()
        }
    }
}
struct OscillatorCircle2: View { //Osc2 circle and description
    let isRunning: Bool
    @State private var opacity = 1.0
    @State private var animationWorkItem: DispatchWorkItem?
    @State public var infoShowing2 = true
    @State public var oscillator2Pressed = false
    var scenes: Scenes
    var conductor: SynthClass
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle() // The background of the circle1
                    .fill(Color.black.opacity(0.7))
                    .frame(width: 240, height: 180)
                
                Circle() //Circle2
                    .fill(Color.green)
                    .frame(width: 150, height: 150)
                    .opacity(opacity)
                    .onChange(of: isRunning) { _, newValue in
                        animationWorkItem?.cancel()
                        
                        if newValue {
                            withAnimation(Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                opacity = 0.3
                            }
                        } else {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                opacity = 1.0
                            }
                        }
                    }
                    .onTapGesture {
                        handleToggle2()  // Use the callback
                    }
            }
            Button("Oscillator2") { //The button with a Text Oscillator2
                handleToggle2()
            }
            .font(.title)
            .bold()
            .foregroundColor(.green)
            .shadow(radius: 2)
            Text("(Choose a sound source 2)")
                .foregroundColor(.black)
                .opacity(infoShowing2 ? 1.0 : 0.0)
        }
    }
    private func handleToggle2() { //function when the button2 and description is pressed
        oscillator2Pressed.toggle()
        infoShowing2.toggle()
        scenes.toggleOscillator2()
        
        if oscillator2Pressed {
            conductor.startOscillator2()
        } else {
            conductor.stopOscillator2()
        }
    }
}
    

    
