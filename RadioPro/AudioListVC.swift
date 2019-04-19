//
//  ViewController.swift
//  RadioPro
//
//  Created by Faizan Naseem on 18/04/2019.
//  Copyright © 2019 Faizan Naseem. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class AudioListVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
   
    // Weak reference to update the NowPlayingViewController
    weak var nowPlayingViewController: NowPlayingVC?
    
    var audios = [Audio]()
    let radioPlayer = RadioPlayer()
    let playerView : PlayerView = PlayerView.fromNib()
    
    let audioData = [
        "http://drosuae.com/Download/shk_3azez_far7an/radio%26tv/fatawa/2019_4_16_905.mp3",
        "http://drosuae.com/Download/shaikh_khalid_ismail/dros/tafseer_qran/sort_yons/016.mp3",
        "http://drosuae.com/Download/shaikh_khalid_ismail/dros/shar7_umdatul_ahkam/009.mp3",
        "http://drosuae.com/Download/shk_3azez_far7an/dros/shr7_ketab_bloog_al_maram/ketab_as_seyam/003.mp3",
        "http://drosuae.com/Download/shaikh_khalid_ismail/dros/lugatuna_al_arabiya/006.mp3",
        "http://drosuae.com/Download/quran/khalid&ebrahem-1435h_2014m/110.mp3",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for index in 0..<audioData.count {
            let audio = Audio(audioId: index, audioUrl: audioData[index])
            self.audios.append(audio)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Swift Radio"
        
        if RadioPlayer.player?.isPlaying ?? false {
            // add bottom player view
            addPlayerView()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        // add bottom player view
        playerView.removeFromSuperview()
    }
    
    @IBAction func nowPlayingTapped(_ sender: Any) {
        performSegue(withIdentifier: "NowPlaying", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "NowPlaying", let nowPlayingVC = segue.destination as? NowPlayingVC else { return }

        let newStation: Bool
        if let indexPath = (sender as? IndexPath) {
            // User clicked on row, load/reset station
            radioPlayer.station = audios[indexPath.row]
            newStation = true
        } else {
            // User clicked on Now Playing button
            newStation = false
        }
        nowPlayingViewController = nowPlayingVC
        nowPlayingVC.load(station: radioPlayer.station, isNewStation: newStation)
        nowPlayingVC.delegate = self
    }
    
    private func getIndex(of station: Audio?) -> Int? {
        guard let station = station, let index = audios.firstIndex(where: { $0.audioId == station.audioId }) else {
            return nil
        }
        return index
    }
    
    func addPlayerView() {
        playerView.onButtonPress {
            self.performSegue(withIdentifier: "NowPlaying", sender: nil)
        }
        playerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playerView)
        
        NSLayoutConstraint.activate([
            playerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            playerView.heightAnchor.constraint(equalToConstant: 50.0)
        ])
    }
}

extension AudioListVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audios.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        cell?.textLabel?.text = "Audio \(indexPath.row)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "NowPlaying", sender: indexPath)
    }
}

extension AudioListVC: NowPlayingViewControllerDelegate {
    
    func didPressNextButton() {
        guard let index = getIndex(of: radioPlayer.station) else { return }
        radioPlayer.station = (index + 1 == audios.count) ? audios[0] : audios[index + 1]
        handleRemoteStationChange()
    }
    
    func didPressPreviousButton() {
        guard let index = getIndex(of: radioPlayer.station) else { return }
        radioPlayer.station = (index == 0) ? audios.last : audios[index - 1]
        handleRemoteStationChange()
    }
    
    func handleRemoteStationChange() {
        if let nowPlayingVC = nowPlayingViewController {
            // If nowPlayingVC is presented
            nowPlayingVC.resetAudioOutlets()
            nowPlayingVC.load(station: radioPlayer.station)
            nowPlayingVC.stationDidChange()
        }
    }
}


extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
