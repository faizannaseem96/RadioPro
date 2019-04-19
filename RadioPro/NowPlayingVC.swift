//
//  NowPlayingVC.swift
//  RadioPro
//
//  Created by Faizan Naseem on 18/04/2019.
//  Copyright © 2019 Faizan Naseem. All rights reserved.
//

import UIKit
import AVFoundation

protocol NowPlayingViewControllerDelegate: class {
    func didPressNextButton()
    func didPressPreviousButton()
}

class NowPlayingVC: UIViewController {
    
    var currentStation: Audio!
    var newStation = true
    var sliderMoving = true
    
    weak var delegate: NowPlayingViewControllerDelegate?
    
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var totalDurationLbl: UILabel!
    @IBOutlet weak var currentTimeLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Check for station change
        newStation ? stationDidChange() : playerStateDidChange()
        
        timeSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
    }
    
    @IBAction func playingPressed(_ sender: Any) {
        RadioPlayer.player?.playpause()
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        delegate?.didPressNextButton()
    }
    
    @IBAction func previousPressed(_ sender: Any) {
        delegate?.didPressPreviousButton()
    }
    
    func load(station: Audio?, isNewStation: Bool = true) {
        guard let station = station else { return }
        currentStation = station
        newStation = isNewStation
    }
    
    func stationDidChange() {
        RadioPlayer.setup(url: currentStation.audioUrl)
        RadioPlayer.player?.onStatusReadyToPlay(block: { (player, item) in
            guard let currentItem = item else { return }
            self.timeSlider.maximumValue = Float(CMTimeGetSeconds(currentItem.asset.duration))
            self.totalDurationLbl.text = self.getTimeString(from: currentItem.asset.duration)
            RadioPlayer.player?.playpause()
        })
        setAudioProgress()
        title = "Audio \(currentStation.audioId)"
    }
    
    func playerStateDidChange() {
        
        //updateLabels(with: message)
        guard let currentItem = RadioPlayer.player?.player?.currentItem else { return }
        self.timeSlider.maximumValue = Float(CMTimeGetSeconds(currentItem.asset.duration))
        self.totalDurationLbl.text = self.getTimeString(from: currentItem.asset.duration)
        setAudioProgress()
    }
    
    func setAudioProgress() {
        RadioPlayer.player?.onProgress { [weak self] (player, item) in
            guard let currentItem = item else { return }
            self?.currentTimeLbl.text = self?.getTimeString(from: currentItem.currentTime())
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
            print(self?.getTimeString(from: currentItem.currentTime()) ?? "")
        }
    }
    
    func resetAudioOutlets() {
        self.timeSlider.value = 0
        self.currentTimeLbl.text = "00:00"
        self.totalDurationLbl.text = "00:00"
    }
    
    func seekSlider(value: Float) {
        
    }
    
    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                sliderMoving = false
            case .ended:
                sliderMoving = true
                seekSlider(value: slider.value)
            default:
                break
            }
        }
    }
}


extension UIViewController {
    
    func getTimeString(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        guard !(totalSeconds.isNaN || totalSeconds.isInfinite) else {
            return "illegal value" // or do some error handling
        }
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours,minutes,seconds])
        }else {
            return String(format: "%02i:%02i", arguments: [minutes,seconds])
        }
    }
}
