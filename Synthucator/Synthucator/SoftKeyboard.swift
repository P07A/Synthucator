//
//  SoftKeyboard.swift
//  Synthecator
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

struct SoftKeyboard: View { //Keyboard layer and when it is tapped
    var firstOctave: Int
    var octaveCount: Int
    var noteOn: (Pitch, CGPoint) -> Void = { _, _ in }
    var noteOff: (Pitch) -> Void
    var body: some View {
        Keyboard(layout: .piano(
            pitchRange: Pitch(intValue: firstOctave * 12 + 24)...Pitch(intValue: (firstOctave + octaveCount - 1) * 12 + 24)),
            noteOn: noteOn, noteOff: noteOff) {pitch, isActivated in KeyboardKey(pitch: pitch, isActivated: isActivated, text: "", pressedColor: Color.green, flatTop: true)
        }
        .cornerRadius(5)
    }
}
