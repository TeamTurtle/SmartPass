//
//  VerifyVoiceKeyViewController.swift
//  SmartPass
//
//  Created by Cassidy Wang on 10/9/16.
//  Copyright © 2016 Cassidy Wang. All rights reserved.
//

import UIKit
import AudioKit
import Speech

class VerifyVoiceKeyViewController: UIViewController, SFSpeechRecognizerDelegate, AlertPresenter {

    //Outlets
    @IBOutlet weak var audioInputPlot: EZAudioPlot!
    @IBOutlet weak var keyLabel: UILabel!
    
    //Constants
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    
    //Variables
    var mic: AKMicrophone!
    var engineOn: Bool = false
    var mixer: AKMixer!
    var plot: AKNodeOutputPlot!
    var match: Bool = false

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.orange
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
        
        //Set up live plot
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        
        //Set up speech recognition
        speechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization({(authStatus) in
            switch authStatus {
            case .authorized:
                break
            case .denied:
                self.presentAlert(title: "No access", message: "User denied access to speech recognition", type: .notification, sender: self)
            case .restricted:
                self.presentAlert(title: "No access", message: "Speech recognition restricted on this device", type: .notification, sender: self)
            case .notDetermined:
                self.presentAlert(title: "No access", message: "Speech recognition not yet authorized", type: .notification, sender: self)
            }
        })
        
        startRecording()
        print("listening on")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        AudioKit.start()
        setupPlot()
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    }
    
    func setupPlot() {
        plot = AKNodeOutputPlot(mic, frame: audioInputPlot.bounds)
        plot.plotType = .buffer
        plot.shouldFill = true
        plot.shouldMirror = true
        plot.color = UIColor.blue
        audioInputPlot.addSubview(plot)
    }
    
    func startRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            self.presentAlert(title: "Audio session error", message: "Audio session properties not set", type: .notification, sender: self)
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            if result != nil {
                
                self.keyLabel.text = result?.bestTranscription.formattedString
                self.audioEngine.stop()
                recognitionRequest.endAudio()
                self.plot.color = UIColor.red
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                if (self.keyLabel.text! == "\(currentKey)") {
                    self.view.backgroundColor = UIColor.green
                    self.match = true
                } else {
                    self.view.backgroundColor = UIColor.red
                    self.match = false
                }
                self.performSegue(withIdentifier: "unwindToHostEvent", sender: self)
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            presentAlert(title: "Audio engine error", message: "Audio engine could not start", type: .notification, sender: self)
        }
        
        keyLabel.text = "Say something; I'm listening!"
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if match {
            segue.destination.view.backgroundColor = UIColor.green
        } else {
            segue.destination.view.backgroundColor = UIColor.red
        }
    }

}
