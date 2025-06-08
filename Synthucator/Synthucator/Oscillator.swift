//
//  Oscillator.swift
//  Synthucator
//
//  Created by PlaCDreamer on 23/11/2024.
//

import SwiftUI
import AudioKit
import AudioKitUI
import Keyboard
import Tonic
import AVFoundation
import SoundpipeAudioKit //sound stuff


struct MorphingOscillatorData {
//    var isPlaying: Bool = false
    var frequency: AUValue = 440
    var octaveFrequency: AUValue = 440
    var amplitude: AUValue = 0.2
    var rampDuration: AUValue = 0.1

}
class SynthClass: ObservableObject { //Synthesiser progress
//    let midi = MIDI()
    let filter: MoogLadder //low pass filter
    var osc1 = [MorphingOscillator(index:0.75, detuningOffset: -0.5), //Osc1
                        MorphingOscillator(index:2.75)]
    var osc2 = Oscillator(waveform: Table(.sine)) //Osc2
    var engine = AudioEngine()
    @Published var delay: Delay!
    @Published var reverb: Reverb!
    @Published var octave = 1
    @Published var noteRange = 2
    @Published public var adsr: AmplitudeEnvelope
    @Published var cutoff = AUValue(20_000) { //LPF cut off range
        didSet {
            filter.cutoffFrequency = AUValue(cutoff)
        }
    }
    @Published var masterVolume: AUValue = 1.0 { //Master volume range
        didSet {
            engine.mainMixerNode?.volume = masterVolume
        }
    }

    
    init() { //process of the engine = OSC->filter->adsr->delay->reverb->engine

            filter = MoogLadder((Mixer(osc1[0],osc1[1],osc2)),cutoffFrequency: 20_000)
            adsr = AmplitudeEnvelope(filter, attackDuration: 0.01, decayDuration: 0.5, sustainLevel: 0.5, releaseDuration: 0.2)
            delay = Delay(adsr)
            delay.feedback = 0.0
            delay.dryWetMix = 0.0
            reverb = Reverb(delay)
            reverb.loadFactoryPreset(.cathedral)
            reverb.dryWetMix = 0.0
            engine.output = reverb
            
            //        midi.openInput()
            //        midi.addListener(self)
            //        try! engine.start()
        do { //Check if the sound works on iPad
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio: \(error.localizedDescription)")
        }
    }
    
    func startOscillator1() { //function to make sound by oscillator1 with the engine
        if !engine.avEngine.isRunning {
            try? engine.start()
        }
        for i in 0...1 {
            osc1[i].start()
            osc1[i].amplitude = 0.5
        }
    }
    
    func stopOscillator1() { //function to stop sound by oscillator1 with the engine
        for i in 0...1 {
            osc1[i].amplitude = 0.0
            osc1[i].stop()
        }
        if osc1[0].amplitude == 0.0 {
            engine.stop()
        }
    }
    
    func startOscillator2() { //function to make sound by oscillator2 with the engine
        if !engine.avEngine.isRunning {
            try? engine.start()
        }
            osc2.start()
            osc2.amplitude = 0.5
    }
    
    func stopOscillator2() { //function to stop sound by oscillator1 with the engine
            osc2.amplitude = 0.0
            osc2.stop()
        if osc2.amplitude == 0.0 {
            engine.stop()
        }
    }
    
    @Published var data = MorphingOscillatorData() { //Initialised data of the oscillators
        didSet {
            //            if data.isPlaying {
            for i in 0...1 {
                osc1[i].start()
                osc1[i].$amplitude.ramp(to: data.frequency, duration: data.rampDuration)
                osc2.start()
                osc2.$amplitude.ramp(to: data.frequency, duration: data.rampDuration)
            }
            osc1[0].$frequency.ramp(to: data.frequency, duration: data.rampDuration)
            osc1[1].$frequency.ramp(to: data.frequency, duration: data.rampDuration)
            osc2.$frequency.ramp(to: data.frequency, duration: data.rampDuration)
        }
    }
    
    func noteOn(pitch: Pitch, point: CGPoint) { //When pressd a keyboard to make a sound
        //        data.isPlaying = true
        data.frequency = AUValue(pitch.midiNoteNumber)
            .midiNoteToFrequency()
        data.octaveFrequency = AUValue(pitch.midiNoteNumber-12)
            .midiNoteToFrequency()
        adsr.openGate()
    }
    func noteOff(pitch: Pitch) {
        //        data.isPlaying = false
        adsr.closeGate()
    }
//    func setpupMIDI() { //MIDI connection in the future
//        midi.openInput()
//        midi.addListener(self)
//    }
}

//extension SynthClass: MIDIListener { MIDI connection in the future
//    func receivedMIDINoteOn(noteNumber: AudioKit.MIDINoteNumber, velocity: AudioKit.MIDIVelocity, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
//    }
//    
//    func receivedMIDINoteOff(noteNumber: AudioKit.MIDINoteNumber, velocity: AudioKit.MIDIVelocity, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
//    }
//    
//    func receivedMIDIController(_ controller: AudioKit.MIDIByte, value: AudioKit.MIDIByte, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
//    }
//    
//    func receivedMIDIAftertouch(noteNumber: AudioKit.MIDINoteNumber, pressure: AudioKit.MIDIByte, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
//    }
//    
//    func receivedMIDIAftertouch(_ pressure: AudioKit.MIDIByte, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
//    }
//    
//    func receivedMIDIPitchWheel(_ pitchWheelValue: AudioKit.MIDIWord, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
//    }
//    
//    func receivedMIDIProgramChange(_ program: AudioKit.MIDIByte, channel: AudioKit.MIDIChannel, portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
//    }
//    
//    func receivedMIDISystemCommand(_ data: [AudioKit.MIDIByte], portID: MIDIUniqueID?, timeStamp: MIDITimeStamp?) {
//    }
//    
//    func receivedMIDISetupChange() {
//    }
//    
//    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
//    }
//    
//    func receivedMIDINotification(notification: MIDINotification) {
//    }
//    
//    func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
//        let pitch = Pitch(Int8(noteNumber))
//        noteOn(pitch: pitch, point: CGPoint())
//    }
//    
//    func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel) {
//        let pitch = Pitch(Int8(noteNumber))
//        noteOff(pitch: pitch)
//    }
//}

struct VolumeSlider: View { //Master volume slider view
    @ObservedObject var conductor: SynthClass
    
    var body: some View {
        VStack(spacing: 100) {

            Slider(value: $conductor.masterVolume, label: {Text("Volume")}, minimumValueLabel: {Text("")}, maximumValueLabel: {Text("")})
                .foregroundColor(.white)
                .frame(width: 150, height: 20)
                .rotationEffect(.degrees(-90))
                .padding(.top, 50)
            
            Text("Volume: \(String(format: "%.2f", conductor.masterVolume))")
                            .foregroundColor(.white)
                            .font(.title2)
                            .padding(.top, -10)
            
        }
    }
}
