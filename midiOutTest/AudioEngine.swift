//
//  AudioEngine.swift
//  midiOutTest
//
//  Created by Andrei Antonescu on 18/03/2019.
//  Copyright © 2019 Andrei Antonescu. All rights reserved.
//

import Foundation
import AudioKit

class AudioEngine {
    static let sharedInstance = AudioEngine()
    let midi = AKMIDI()
    let synth = AKOscillatorBank()
    
    func start() {
        AudioKit.output = synth
        
        do {
            try AudioKit.start()
        } catch {
            AKLog("Failed to start AudioKit")
        }
    }
}
