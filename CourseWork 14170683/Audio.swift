//
//  File.swift
//  CourseWork 14170683
//
//  Created by Sadat Safuan on 13/01/2020.
//  Copyright © 2020 Sadat Safuan. All rights reserved.
//

import AVFoundation

class Audio {
    static let sharedHelper = Audio()
    var soundPlayer: AVAudioPlayer?
    
    func playAudio() {
        let aSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "AngriBirdsThemeSong", ofType: "mp3")!)
        do {
            soundPlayer = try AVAudioPlayer(contentsOf:aSound as URL)
            soundPlayer!.numberOfLoops = -1
            soundPlayer!.prepareToPlay()
            soundPlayer!.play()
        }
        catch {
            print("Cannot play the file")
        }
    }
}

