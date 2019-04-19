//
//  PlayerView.swift
//  RadioPro
//
//  Created by Faizan Naseem on 18/04/2019.
//  Copyright © 2019 Faizan Naseem. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {
    
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var playBtn: UIButton!
    
    var sliderMoving = true
    var buttonPressCallBack: (()->Void)?
    let radio = RadioPlayer()
    
    public func onButtonPress(callBack: @escaping (()->Void)) {
        self.buttonPressCallBack = callBack
    }
    
    @objc func buttonPressed(sender: UIButton) {
        self.buttonPressCallBack?()
    }
    
    @objc func playPressed(sender: UIButton) {
        RadioPlayer.player?.playpause()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // add targets on outlets
        timeSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
        button.addTarget(self, action: #selector(buttonPressed(sender:)), for: .touchUpInside)
        playBtn.addTarget(self, action: #selector(playPressed(sender:)), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let currentItem = RadioPlayer.player?.player?.currentItem else { return }
        self.timeSlider.maximumValue = Float(CMTimeGetSeconds(currentItem.asset.duration))
        setAudioProgress()
    }
    
    func setAudioProgress() {
        RadioPlayer.player?.onProgress { [weak self] (player, item) in
            guard let currentItem = item else { return }
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
        }
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
