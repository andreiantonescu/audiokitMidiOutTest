//
//  ViewController.swift
//  midiOutTest
//
//  Created by Andrei Antonescu on 18/03/2019.
//  Copyright © 2019 Andrei Antonescu. All rights reserved.
//

import UIKit
import AudioKitUI

class ViewController: UIViewController, AKKeyboardDelegate, UITableViewDelegate, UITableViewDataSource {
    var keyboard: AKKeyboardView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.keyboard = AKKeyboardView(frame: CGRect(x: 0,
                                                     y: self.view.frame.height - 100,
                                                     width: self.view.bounds.width,
                                                     height: 100))
        self.keyboard.delegate = self
        self.view.addSubview(self.keyboard)
        AudioEngine.sharedInstance.start()
        
        self.tableView.allowsMultipleSelection = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "midiOutput")
    }
    
    func noteOn(note: MIDINoteNumber) {
        AudioEngine.sharedInstance.synth.play(noteNumber: note, velocity: 120)
        AudioEngine.sharedInstance.midi.sendEvent(AKMIDIEvent(noteOn: note, velocity: 120, channel: 0))
    }
    
    func noteOff(note: MIDINoteNumber) {
        AudioEngine.sharedInstance.synth.stop(noteNumber: note)
        AudioEngine.sharedInstance.midi.sendEvent(AKMIDIEvent(noteOff: note, velocity: 120, channel: 0))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AudioEngine.sharedInstance.midi.destinationUIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "midiOutput")!
        let uid = AudioEngine.sharedInstance.midi.destinationUIDs[indexPath.row]
        
        cell.textLabel?.text = AudioEngine.sharedInstance.midi.destinationName(for:
            uid)

        if AudioEngine.sharedInstance.midi.endpoints.keys.contains(uid) {
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            self.tableView.deselectRow(at: indexPath, animated: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < AudioEngine.sharedInstance.midi.destinationUIDs.count else { return }
        let uid = AudioEngine.sharedInstance.midi.destinationUIDs[indexPath.row]
        AudioEngine.sharedInstance.midi.openOutput(uid: uid)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard indexPath.row < AudioEngine.sharedInstance.midi.destinationUIDs.count else { return }
        let uid = AudioEngine.sharedInstance.midi.destinationUIDs[indexPath.row]
        AudioEngine.sharedInstance.midi.closeOutput(uid: uid)
    }
    
    @IBAction func refreshTableView(_ sender: UIButton) {
        self.tableView.reloadData()
    }
    
    func reloadData() {
        self.tableView.reloadData()
        
        // reloading table view data clears selected states
        // so we'll loop through existing rows to see if they match current endpoints
        for section in 0 ..< self.tableView.numberOfSections {
            for row in 0 ..< self.tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                guard indexPath.row < AudioEngine.sharedInstance.midi.destinationUIDs.count else { return }
                
                let endpoint = AudioEngine.sharedInstance.midi.destinationUIDs[indexPath.row]
                if AudioEngine.sharedInstance.midi.endpoints.keys.contains(endpoint) {
                    self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                } else {
                    self.tableView.deselectRow(at: indexPath, animated: false)
                }
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

