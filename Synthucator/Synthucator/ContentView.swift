//
//  ContentView.swift
//  Synthucator
//
//  Created by PlaCDreamer on 23/11/2024.
//
import SpriteKit
import SwiftUI
import AudioKit
import AudioKitUI
import Keyboard
import Tonic
import AVFoundation
import SoundpipeAudioKit
import Controls

// keyboard, scrolling oscs, connect to each files?

var engine: AudioEngine!
var player: AudioPlayer!
var osc: Oscillator!
var mixer: Mixer!
var reverb: Reverb!
var delay: Delay!


struct ContentView: View {
    @State private var InfoShowing1 = true
    @State private var InfoShowing2 = true
    @StateObject private var conductor = SynthClass()
    @State private var isKnobMoving: Bool = false
//    @State private var Oscillator1Pressed = false
    @StateObject private var scenes = Scenes()
    @State private var tutorialStep: TutorialStep? = .oscillators
    
    private let maxValue: AUValue = 5.0
    private let maxSustainLevel: AUValue = 1.0

    
    var body: some View {
        ZStack{ //Background (green with gradient)
            RadialGradient(gradient: Gradient(colors: [.green.opacity(0.5), .black]), center: .center, startRadius: 10, endRadius: 800)
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                HStack(spacing: 20) {
                    if (tutorialStep != nil) { //instruction
                        TutorialOverlay(currentStep: $tutorialStep)
                    }

                    VStack {
                        OscillatorCircle1( //Oscillator1 with description
                            isRunning: scenes.oscillator1Scene,
                            scenes: scenes, conductor: conductor)
                        .onTapGesture {
                            scenes.toggleOscillator1()
                            if scenes.oscillator1Scene {
                                conductor.startOscillator1()
                            } else {
                                conductor.stopOscillator1()
                            }
                        }
                    }
                    VStack {
                        OscillatorCircle2( //Oscillator2 with description
                            isRunning: scenes.oscillator2Scene,
                            scenes: scenes, conductor: conductor)
                        .onTapGesture {
                            scenes.toggleOscillator2()
                            if scenes.oscillator2Scene {
                                conductor.startOscillator2()
                            } else {
                                conductor.stopOscillator2()
                            }
                        }
                    }
                    VolumeSlider(conductor: conductor) //Master volume
                    }
                Spacer()
                HStack (spacing: 13) { //ADSR Geometry
                    GeometryReader {geometry in
                        Path {path in
                            let width = geometry.size.width
                            let height = geometry.size.height
                            
                            // Starting point
                            path.move(to: CGPoint(x: 0, y: height))
                            
                            // Attack phase
                            let attackX = width * CGFloat((conductor.adsr.attackDuration / maxValue))
                            path.addLine(to: CGPoint(x: attackX, y:0))
                            
                            // Decay phase
                            let decayX = attackX + width * CGFloat((conductor.adsr.decayDuration / maxValue))
                            let decayY = height * CGFloat((1.0 - conductor.adsr.sustainLevel))
                            path.addLine(to: CGPoint(x: decayX, y:decayY))
                            
                            // Sustain phase
                            let sustainX = width * 0.75
                            path.addLine(to: CGPoint(x: sustainX, y:decayY))
                            
                            // Release phase
                            let releaseX = sustainX + width * CGFloat((conductor.adsr.releaseDuration / maxValue))
                            let releaseY = height
                            path.addLine(to: CGPoint(x: releaseX, y: releaseY))
                        }
                        .stroke(Color.blue, lineWidth: 2)
                        .fill(Color.blue.opacity(0.2))
                    }
                    .frame(width: 710, height: 150)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                   
                    VStack { //Delay Time knob with description
                        SmallKnob(value: $conductor.delay.dryWetMix, range: 0.0 ... 1.0)
                            .frame(maxWidth: 200)
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                            .padding(.top, 1)
                        Text("Delay")
                            .bold()
                            .padding(.top, 5)
                        Text(conductor.delay.dryWetMix < 0.01 ? "(adjust delay amount)" : String(format: "%.2f", conductor.delay.dryWetMix))
                            .font(.footnote)
                    }
                    VStack { //Delay Feedback knob with description
                        SmallKnob(value: $conductor.delay.feedback, range: 0 ... 10)
                            .frame(maxWidth: 200)
                            .overlay(
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                            .padding(.top, 1)
                        Text("Delay Feedback")
                            .bold()
                            .padding(.top, 5)
                        Text(conductor.delay.feedback < 1 ? "(feedback after delay)" : "\(Int(conductor.delay.feedback)/2)")
                            .font(.footnote)
                    }
                }
                HStack (spacing: 30){ //ADSR
                            VStack { //Attack knob with description
                                SmallKnob(value: $conductor.adsr.attackDuration, range: 0.0 ... 1.5)
                                    .frame(maxWidth: 100)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.red, lineWidth: 2)
                                    )
                                    .padding(.top, 1)
                                Text("Attack")
                                    .bold()
                                    .padding(.top, 5)
                                Text(conductor.adsr.attackDuration > 0.0 && conductor.adsr.attackDuration < 0.02 ? "(hitting speed/0.1)" : String(format: "%.2f", conductor.adsr.attackDuration))
                                    .font(.footnote)
                            }
                            VStack { //Decay knob with description
                                SmallKnob(value: $conductor.adsr.decayDuration, range: 0.0 ... 2.0)
                                    .frame(maxWidth: 100)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.orange, lineWidth: 2)
                                    )
                                    .bold()
                                    .padding(.top, 1)
                                Text("Decay")
                                    .padding(.top, 5)
                                Text(conductor.adsr.decayDuration > 0.49 && conductor.adsr.decayDuration < 0.51 ? "(duration of the sound impact/0.5)" : String(format: "%.2f", conductor.adsr.decayDuration))
                                    .font(.footnote)
                            }
                            VStack { //Sustain knob with description
                                SmallKnob(value: $conductor.adsr.sustainLevel, range: 0.0 ... 1.0)
                                    .frame(maxWidth: 100)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.yellow, lineWidth: 2)
                                    )
                                    .padding(.top, 1)
                                Text("Sustain")
                                    .bold()
                                    .padding(.top, 5)
                                Text(conductor.adsr.sustainLevel > 0.49 && conductor.adsr.sustainLevel < 0.51 ? "(duration when touched/0.5)" : String(format: "%.2f", conductor.adsr.sustainLevel))
                                    .font(.footnote)
                            }
                            VStack { //Release knob with description
                                SmallKnob(value: $conductor.adsr.releaseDuration, range: 0.0 ... 2.0)
                                    .frame(maxWidth: 100)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.green, lineWidth: 2)
                                    )
                                    .padding(.top, 1)
                                Text("Release")
                                    .bold()
                                    .padding(.top, 5)
                                Text(conductor.adsr.releaseDuration > 0.19 && conductor.adsr.releaseDuration < 0.21 ? "(duration after touch/0.2)" : String(format: "%.2f", conductor.adsr.releaseDuration))
                                    .font(.footnote)
                            }
                    VStack { //LPF knob with description
                        SmallKnob(value: $conductor.cutoff, range: 0.0 ... 20_000)
                            .frame(maxWidth: 200)
                            .colorInvert()
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .padding(.top, 1)
                        Text("LPF")
                            .bold()
                            .padding(.top, 5)
                        Text(conductor.cutoff > 19_999 ? "(reduce high freq)" : String(format: "%.2f Hz", conductor.cutoff))
                            .font(.footnote)
                    }
                    VStack { //Reverb knob with description
                        SmallKnob(value: $conductor.reverb.dryWetMix, range: 0.0 ... 1.0)
                            .frame(maxWidth: 150)
                            .overlay(
                                Circle()
                                    .stroke(Color.purple, lineWidth: 2)
                            )
                            .padding(.top, 1)
                        Text("Reverb")
                            .bold()
                            .padding(.top, 5)
                        Text(conductor.reverb.dryWetMix < 0.01 ? "(modify a size of a space)" : String(format: "%.2f", conductor.reverb.dryWetMix))
                            .font(.footnote)
                    }
                    }
                Spacer()
                HStack { //Keyboard range setting
                    Button(action: {conductor.noteRange = max(1,conductor.noteRange - 1)}) {
                        Image(systemName: "arrowtriangle.backward.fill")
                            .foregroundStyle(.white)
                    }
                    Text("Range: \(conductor.noteRange)").frame(maxWidth: 150)
                    Button(action: {conductor.noteRange = max(1,conductor.noteRange + 1)}) {
                        Image(systemName: "arrowtriangle.forward.fill")
                            .foregroundStyle(.white)
                    }
                    Button(action: {conductor.octave = max(1,conductor.octave - 1)}) {
                        Image(systemName: "arrowtriangle.backward.fill")
                            .foregroundStyle(.white)
                    }
                    Text("Octave: \(conductor.octave)").frame(maxWidth: 150)
                    Button(action: {conductor.octave = max(1,conductor.octave + 1)}) {
                        Image(systemName: "arrowtriangle.forward.fill")
                            .foregroundStyle(.white)
                    }
                }
                //keyboard
                SoftKeyboard(firstOctave: conductor.octave, octaveCount:  conductor.noteRange, noteOn: conductor.noteOn(pitch:point:), noteOff: conductor.noteOff)
                    .frame(maxHeight: 180)
            }
        }
    }
}
    
    
    #Preview {
        ContentView()
    }
