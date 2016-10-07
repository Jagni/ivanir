//
//  AudioViewController.swift
//  Ivanir
//
//  Created by Jagni Dasa Horta Bezerra on 9/7/16.
//  Copyright © 2016 Jagni. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import MMLoadingButton
import FCAlertView

class AudioViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate{
    
    @IBOutlet weak var sendButton: MMLoadingButton!
    @IBOutlet weak var recordButtonConstraint: NSLayoutConstraint!
    @IBOutlet var recordButton: UIButton!
    var recordCheckTimer: Timer?
    var recorder: AVAudioRecorder?
    var recorderTimer: Timer?
    @IBOutlet var recordLabel: UILabel?
    
    var player: AVAudioPlayer?
    var playbackTimer: Timer?
    @IBOutlet var playBackTimeLabel: UILabel?
    @IBOutlet var playbackSlider: UISlider?
    @IBOutlet var playButton: UIButton?
    @IBOutlet var pauseButton: UIButton?
    
    var animationTimer = Timer()
    
    override func viewDidAppear(_ animated: Bool) {
        
        let hasRecordedAudio = UserDefaults.standard.bool(forKey: "hasRecordedAudio")
        
        if  hasRecordedAudio{
            showPlayInterface()
        }
        
        recordButton.layer.masksToBounds = true;
        recordButton.layer.cornerRadius = recordButton.bounds.width/2
        recordButton.layer.shadowOpacity = 1
        recordButton.layer.shadowColor = UIColor.black.cgColor
        recordButton.layer.shadowRadius = 5
    }
    
    @IBAction func didTapRecordButton(_ sender: UIButton){
        
        if let _ = recorder{
            finishRecording(UIButton())
            
            recorder = nil
            
            let animation = CABasicAnimation(keyPath: "cornerRadius")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.fromValue = sender.layer.cornerRadius
            animation.toValue = sender.bounds.width/2
            animation.duration = 0.25
            sender.layer.add(animation, forKey: "cornerRadius")
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                sender.layer.cornerRadius = sender.bounds.width/2
            })
        }
        else{
            
            startRecording(UIButton())
            let animation = CABasicAnimation(keyPath: "cornerRadius")
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            animation.fromValue = sender.layer.cornerRadius
            animation.toValue = 0
            animation.duration = 0.25
            sender.layer.add(animation, forKey: "cornerRadius")
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                sender.layer.cornerRadius = 0
            })
            
        }
    }
    
    @IBAction func sliderIsBeingDragged(_ sender: UISlider){
        
        if let player = player{
            player.pause()
            if let _ = self.playbackTimer{
                self.playbackTimer!.invalidate()
                self.playbackTimer = nil
            }
        }
        
    }
    
    @IBAction func didSelectPlaybackTime(_ sender: UISlider){
        
        if let player = player{
            player.currentTime = Double(sender.value)
            
            if playButton!.isHidden{
                player.play()
                playbackTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(AudioViewController.updatePlaybackProgress(_:)), userInfo: nil, repeats: true)
                
            }
            
        }
        
    }
    
    func configureAVRecorder(){
        
        // Set audio file
        var pathComponents = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        pathComponents.append("inputAudio.m4a")
        let outputFileURL = NSURL.fileURL(withPathComponents: pathComponents)
        
        
        // Define the recorder setting
        let recordSetting : [String : AnyObject] = [
            AVFormatIDKey : NSNumber(value: kAudioFormatMPEG4AAC as UInt32),
            AVSampleRateKey : NSNumber(value: 44100 as Int32),
            AVNumberOfChannelsKey : NSNumber(value: 2 as Int32)
        ]
        
        // Initiate and prepare the recorder
        recorder = try! AVAudioRecorder(url: outputFileURL!, settings: recordSetting)
        if let recorder = recorder{
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            recorder.prepareToRecord()
        }
        
        
    }
    
    @IBAction func startRecording(_ sender: AnyObject) {
        // Setup audio session
        if recorder == nil {
            if  !self.configureAVAudioSession() {
                return
            }
            self.configureAVRecorder()
            // TO-DO: set recorder to nil when leaving 'audio screen'
        }
        
        // Stop the audio player before recording
        if let player = self.player{
            if player.isPlaying {
                player.stop()
            }
        }
        let session = AVAudioSession.sharedInstance()
        try! session.setActive(true)
        
        // Start recording
        recordCheckTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(AudioViewController.confirmRecording), userInfo: nil, repeats: false)
        
    }
    
    func confirmRecording(){
        recorder!.record()
        
        recordCheckTimer!.invalidate()
        recordCheckTimer = nil
        
        // Stop the audio player before recording
        if player != nil{
            if (player!.isPlaying) {
                player!.stop()
            }
        }
        
        do{
            let session = AVAudioSession()
            
            try session.setActive(true)
            
            if recordLabel!.isHidden{
                hidePlayInterface()
            }
            
            recorderTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(AudioViewController.updateRecorderProgress), userInfo: nil, repeats: true)
        }
        catch{}
    }
    
    func updateRecorderProgress(){
        let seconds = 30 - Int(recorder!.currentTime.truncatingRemainder(dividingBy: 60))
        
        recordLabel!.text = String(format: "00:00:%02d", seconds)
        
        if seconds == 0 {
            
            self.didTapRecordButton( self.recordButton )
            
        }
    }
    
    func updatePlaybackProgress(_ sender: AnyObject){
        if player?.currentTime == 0 && playbackSlider!.value > 0{
            
            DispatchQueue.main.async(execute: {
                self.playbackSlider!.value = 0
                self.playButton!.isHidden = false
                self.pauseButton!.isHidden = true
            })
        }
        
        
        playbackSlider!.value = Float(player!.currentTime)
        let remainingTime = Float(player!.duration - player!.currentTime)
        let seconds = Int(remainingTime.truncatingRemainder(dividingBy: 60))
        let minutes = Int((remainingTime / 60).truncatingRemainder(dividingBy: 60))
        
        playBackTimeLabel!.text = String(format: "%02d:%02d", minutes, seconds)
        
    }
    
    
    @IBAction func finishRecording(_ sender: AnyObject){
        
        if (recorderTimer != nil) {
            
            recorderTimer!.invalidate()
            recorderTimer = nil
            
        }
        
        
        self.showPlayInterface()
        
        playbackSlider?.minimumValue = 0
        playbackSlider?.maximumValue = Float(recorder!.currentTime)
        
        recorder!.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        
    }
    
    func showPlayInterface(){
        self.playbackSlider?.isHidden = false
        self.playbackSlider?.alpha = 0
        
        self.playButton?.isHidden = false
        self.playButton?.alpha = 0
        
        self.playBackTimeLabel?.isHidden = false
        self.playBackTimeLabel?.alpha = 0
        
        self.pauseButton?.isHidden = true
        self.pauseButton?.alpha = 1
        
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            self.recordLabel?.alpha = 0
            
            
        }) { (finished) -> Void in
            self.recordLabel?.isHidden = true
            
            UIView.animate(withDuration: 0.5, delay: 0.125, options: UIViewAnimationOptions(), animations: { () -> Void in
                
                self.playbackSlider?.alpha = 1
                self.playButton?.alpha = 1
                self.playBackTimeLabel?.alpha = 1
                self.sendButton.alpha = 1
                self.recordButtonConstraint.constant = 50
                self.view.layoutIfNeeded()
                
                }, completion: nil)
        }
        
    }
    
    func hidePlayInterface(){
        self.recordLabel?.isHidden = false
        self.recordLabel?.alpha = 0
        self.playbackSlider?.value = 0
        
        if let _ = playbackTimer{
            playbackTimer!.invalidate()
            playbackTimer = nil
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            self.playbackSlider?.alpha = 0
            self.playButton?.alpha = 0
            self.pauseButton?.alpha = 0
            self.playBackTimeLabel?.alpha = 0
            self.recordButtonConstraint.constant = 0
            self.sendButton.alpha = 0
            self.view.layoutIfNeeded()
            
            
        }) { (finished) -> Void in
            self.playbackSlider?.isHidden = true
            self.playButton?.isHidden = true
            self.pauseButton?.isHidden = true
            self.playBackTimeLabel?.isHidden = true
            
            
            UIView.animate(withDuration: 0.5, delay: 0.125, options: UIViewAnimationOptions(), animations: { () -> Void in
                
                self.recordLabel?.alpha = 1
                
                
                }, completion: nil)
        }
        
    }
    
    @IBAction func didTapPlay(_ sender: AnyObject){
        self.playButton?.isHidden = true
        self.pauseButton?.isHidden = false
        do{
            var pathComponents = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            pathComponents.append("inputAudio.m4a")
            let outputFileURL = NSURL.fileURL(withPathComponents: pathComponents)
            
            player = try AVAudioPlayer(contentsOf: outputFileURL!)
            player?.delegate = self
            player!.currentTime = Double(playbackSlider!.value)
            player?.play()
            
            playbackTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.updatePlaybackProgress(_:)), userInfo: nil, repeats: true)
            
        }
        catch{}
        
    }
    
    
    @IBAction func didTapPause(_ sender: AnyObject){
        self.playButton?.isHidden = false
        self.pauseButton?.isHidden = true
        player!.pause()
        playbackTimer!.invalidate()
        playbackTimer = nil
    }
    
    func configureAVAudioSession()->Bool{
        //get your app's audioSession singleton object
        let session = AVAudioSession.sharedInstance()
        do{
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            try session.setActive(true)
            return true
        }
        catch{
            return false
        }
    }
    
    func animateButton(_ sender: Any){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                if self.sendButton.alpha == 0{
                    self.sendButton.alpha = 1
                }
                else{
                    self.sendButton.alpha = 0
                }
            }
        }
    }
    
    @IBAction func didTapSend(_ sender: MMLoadingButton) {
        
        var pathComponents = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        pathComponents.append("inputAudio.m4a")
        let outputFileURL = NSURL.fileURL(withPathComponents: pathComponents)
        
        let audioData = try? Data(contentsOf: outputFileURL!)
        
        var dataJSON = [String : AnyObject]()
        dataJSON["type"] = "AUDIO" as AnyObject?
        dataJSON["id"] = id as AnyObject?
        dataJSON["audio"] = audioData!.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) as AnyObject?
        self.sendButton.isEnabled = false
        self.sendButton.setTitle("Enviando", for: UIControlState.disabled)
        self.animationTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.animateButton(_:)), userInfo: nil, repeats: true)
        
        ConnectionHelper.sendJSON(json: dataJSON) { (response) in
            self.animationTimer.invalidate()

            if response{
                
                let alert = FCAlertView()
                
                
                alert.makeAlertTypeSuccess()
                alert.tintColor = UIColor ( red: 1.0, green: 0.3333, blue: 0.3333, alpha: 1.0 )
                
                DispatchQueue.main.async {
                    alert.showAlert(inView: self, withTitle: "Sucesso!", withSubtitle: "Áudio enviado com sucesso :D", withCustomImage: nil, withDoneButtonTitle: "Tá bom", andButtons: nil)
                }
                
                
                UserDefaults.standard.set(true, forKey: "hasRecordedAudio")
                UserDefaults.standard.synchronize()
                
            }
            else{
                
                let alert = FCAlertView()
                
                alert.makeAlertTypeWarning()
                alert.tintColor = UIColor ( red: 1.0, green: 0.3333, blue: 0.3333, alpha: 1.0 )
                
                alert.showAlert(inView: self, withTitle: "Erro!", withSubtitle: "Houve algum erro :(\n*Provavelmente de rede*", withCustomImage: nil, withDoneButtonTitle: "Que pena, né?", andButtons: nil)
                
            }
            
            
                self.sendButton.alpha = 1
                self.sendButton.isEnabled = true
                self.sendButton.titleLabel?.text = "Enviar"
            
        }
        
        
    }
    
}
