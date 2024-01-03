//
//  ViewController.swift
//  AudioVideoApp
//
//  Created by Simpro on 02/01/24.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController, AVAudioPlayerDelegate, AVPlayerViewControllerDelegate, AVAudioRecorderDelegate {

    @IBOutlet var recordBtn: UIButton!
    var audioRecorder : AVAudioRecorder!
    var audioRecorderSession : AVAudioSession!
    var audioPlayer : AVAudioPlayer!
    var videoPlayer : AVPlayer!
    
    var audio : URL = Bundle.main.url(forResource: "audio2", withExtension: "mp3")!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudioSession()
    }
    //for playing audio
    @IBAction func playAudio(_ sender: UIButton) {
        playAudio()
    }
    //for recording audio
    @IBAction func startAudioRecord(_ sender: UIButton) {
        recordButtonTap()
    }
    //for playing video
    @IBAction func playVideo(_ sender: UIButton) {
        playVideo()
    }
    func playAudio(){
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: audio)
            audioPlayer.delegate = self
            audioPlayer.volume = 10
            audioPlayer?.play()
        }catch{
            print("error loading url")
            return
        }
    }
    func recordButtonTap(){
        if audioRecorder != nil{
            stopRecording(success: true)
        }else{
            startRecording()
        }
    }
    func startRecording(){
        let settings : [String : Any] = [
            AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey : 44100,
            AVNumberOfChannelsKey : 2,
            AVEncoderAudioQualityKey : AVAudioQuality.high.rawValue
        ]
        let audioURL = getDocumentsDirectory().appending(component: "recording.m4a")
        do{
            audioRecorder = try AVAudioRecorder(url: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder!.prepareToRecord()
            audioRecorder!.record()
            recordBtn.setTitle("Tap to Stop", for: .normal)
        }catch{
            print("Error: Failed to create audio recorder")
            stopRecording(success: false)
        }
    }
    func stopRecording(success : Bool){
        audioRecorder.stop()
        audioRecorder = nil
        if success{
            recordBtn.setTitle("Tap to Re-Record", for: .normal)
            getFilePath()
            playAudio()
        }else{
            recordBtn.setTitle("Tap to Record", for: .normal)
        }
    }
    func playVideo(){
        let url = Bundle.main.url(forResource: "video1", withExtension: "mp4")
        videoPlayer = AVPlayer(url: url!)
        let playerViewControler = AVPlayerViewController()
        playerViewControler.player = videoPlayer
        playerViewControler.allowsPictureInPicturePlayback = true
        playerViewControler.delegate = self
        playerViewControler.player?.play()
        self.present(playerViewControler, animated: true, completion: nil)
    }
    func setupAudioSession()
    {
        audioRecorderSession = AVAudioSession.sharedInstance()
        do{
           try audioRecorderSession.setCategory(.playAndRecord, options: .defaultToSpeaker)
           try audioRecorderSession.setActive(true, options: .notifyOthersOnDeactivation)
            audioRecorderSession.requestRecordPermission { [unowned self] allowed in
                if allowed{
                    recordBtn.isEnabled = true
                }else{
                    recordBtn.isEnabled = false
                }
            }
        }catch{
            print("error setting up in audio session")
        }
    }
    func getDocumentsDirectory() -> URL{
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    func getFilePath(){
        audio = getDocumentsDirectory().appending(component: "recording.m4a")
    }
    //delegate methods
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag{
            stopRecording(success: false)
        }
    }
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Error while recording audio \(error!.localizedDescription)")
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("finished playing audio")
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Error while playing audio \(error!.localizedDescription)")
    }
}

