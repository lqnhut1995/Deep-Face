//
//  CNNView.swift
//  CariocaMenuDemo
//
//  Created by Hell Rocky on 8/1/19.
//  Copyright © 2019 CariocaMenu. All rights reserved.
//

import UIKit
import CoreImage
import AVFoundation

protocol ScanViewDelegate: class {
    func imagesResultCallBack(images: [UIImage], complete: @escaping () -> ())
}

class ScanView: UIView {
    @IBOutlet weak var cancel: UIButton!
    @IBOutlet weak var start_stop: UIButton!
    @IBOutlet weak var countdown: UILabel!
    @IBOutlet weak var countFaces: UILabel!
    @IBOutlet weak var uiview: UIView!
    weak var delegate: ScanViewDelegate?
    private var camera:CameraRecord!
    private var images = [UIImage]()
    private var timer: Timer?
    private var image_added=false
    private var save_on_each_second=false
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        self.layer.masksToBounds=true
        camera=CameraRecord(videoView: uiview)
        camera.delegate = self
    }
    
    var isCameraOn=false
    @IBAction func start_stop(_ sender: Any) {
        if isCameraOn{
            isCameraOn=false
            camera.stop()
            timer?.invalidate()
            timer = nil
            start_stop.setTitle("Ttục", for: .normal)
            camera.stopSound()
        }else{
            isCameraOn=true
            camera.start()
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timeEach), userInfo: nil, repeats: true)
            start_stop.setTitle("Dừng", for: .normal)
            camera.playSound(iterate: getCountFace(text: countFaces.text))
        }
    }
    
    @objc func timeEach(){
        if Int(countdown.text!)! == 3{
            countdown.text = "0"
            camera.playSound(iterate: getCountFace(text: countFaces.text))
        }else{
            let time=Int(countdown.text!)!+Int(timer!.timeInterval)
            countdown.text="\(time)"
        }
        save_on_each_second=true
    }
    
    @IBAction func cancel(_ sender: Any) {
        timer?.invalidate()
        timer = nil
        camera.stop()
        countdown.text = "0"
        countFaces.text = "Số ảnh: 0"
    }
    
    @IBAction func changecamera(_ sender: Any) {
        camera.changeCamera()
    }
    
}

extension ScanView: CameraDelegate{
    func metaOutput(meta: [AVMetadataFaceObject]) {
        
    }
    
    func avOutput(facedetected: Bool, image: UIImage?) {
        if facedetected{
            if save_on_each_second{
                save_on_each_second=false
                self.images.append(image!)
            }
            if let _=self.timer, Int(self.countdown.text!)! == 3{
                if !self.image_added{
                    self.image_added=true
                    self.images.append(image!)
                    self.countFaces.text = "Số ảnh: \(getCountFace(text: self.countFaces.text) + 1)"
                    if String(getCountFace(text: self.countFaces.text)) == "16"{
                        self.timer?.invalidate()
                        self.timer = nil
                        self.camera.stop()
                        self.delegate?.imagesResultCallBack(images: self.images, complete: { [weak self] in
                            self?.start_stop.setTitle("Ttục", for: .normal)
                            self?.isCameraOn=false
                            self?.countFaces.text = "Số ảnh: 0"
                            self?.countdown.text = "0"
                            self?.images.removeAll()
                        })
                    }
                    print("\(self.images.count) image added")
                }
            }
            if Int(self.countdown.text!)! != 3{
                self.image_added=false
            }
        }
    }
    
    func getCountFace(text: String?) -> Int{
        return Int((text?.components(separatedBy: " ")[2])!)!
    }
}
