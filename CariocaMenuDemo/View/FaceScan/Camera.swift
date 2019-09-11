//
//  Camera.swift
//  CariocaMenuDemo
//
//  Created by Hell Rocky on 8/5/19.
//  Copyright © 2019 CariocaMenu. All rights reserved.
//

import Foundation
import CoreImage
import AVFoundation
import UIKit

protocol CameraDelegate: class {
    func metaOutput(meta: [AVMetadataFaceObject])
    func avOutput(facedetected: Bool, image: UIImage?)
}

class CameraRecord: NSObject, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate{
    private var cameraDevice: AVCaptureDevice?
    private var faceDetector: CIDetector?
    private let captureSession = AVCaptureSession()
    private var player: AVAudioPlayer?
    private var files: [String]!
    private var drawLayer: CAShapeLayer?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: CameraDelegate?
    
    init(videoView: UIView) {
        super.init()
        files = getFiles()
        captureSession.sessionPreset = AVCaptureSession.Preset.medium
        
        let videoDeviceDiscovery = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front)
        
        for camera in videoDeviceDiscovery.devices as [AVCaptureDevice] {
            if camera.position == .front {
                cameraDevice = camera
            }
        }
        if cameraDevice == nil {
            print("Could not find front camera.")
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: cameraDevice!)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                print("Video input can not be added.")
            }
        } catch {
            print("Something went wrong with the video input.")
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
        previewLayer?.frame = videoView.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.connection?.videoOrientation = .portrait
        videoView.layer.addSublayer(previewLayer!)
        videoView.setNeedsUpdateConstraints()
        drawLayer = CAShapeLayer()
        drawLayer?.setValue("", forKey: "drawlayer")
        drawLayer?.frame = previewLayer!.frame
        previewLayer?.addSublayer(drawLayer!)
        
        let metadataOutput = AVCaptureMetadataOutput()
        let metaQueue = DispatchQueue(label: "MetaDataSession")
        metadataOutput.setMetadataObjectsDelegate(self, queue: metaQueue)
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
        } else {
            print("Meta data output can not be added.")
        }
        
        metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.face]
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        let outputQueue = DispatchQueue(label: "CameraSession")
        videoOutput.setSampleBufferDelegate(self, queue: outputQueue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            print("Video output can not be added.")
        }
        
        let configurationOptions: [String: AnyObject] = [CIDetectorAccuracy: CIDetectorAccuracyHigh as AnyObject, CIDetectorTracking : true as AnyObject, CIDetectorNumberOfAngles: 11 as AnyObject]
        faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: configurationOptions)
    }
    
    var faceyaw = 0
    private var image_added=false
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        DispatchQueue.main.async {
            if !self.image_added && self.drawLayer?.superlayer != self.previewLayer{
                self.image_added=true
                if let layers = self.previewLayer?.sublayers{
                    for layer in layers{
                        if layer.value(forKey: "drawlayer") as? String != ""{
                            self.previewLayer?.addSublayer(self.drawLayer!)
                            self.drawLayer?.setNeedsDisplay()
                            self.previewLayer?.setNeedsDisplay()
                            print("yes")
                            break
                        }
                    }
                }
            }
            if self.drawLayer?.superlayer == self.previewLayer{
                self.image_added=false
            }
            let faces = metadataObjects.compactMap { $0 as? AVMetadataFaceObject } .compactMap { (face) -> CGRect? in
                guard let localizedFace =
                    self.previewLayer?.transformedMetadataObject(for: face) else {return nil}
                return localizedFace.bounds }
            for face in faces {
                self.drawLayer?.path = UIBezierPath(roundedRect: face, cornerRadius: 5).cgPath
                self.drawLayer?.strokeColor = UIColor.red.cgColor
                self.drawLayer?.fillColor = UIColor.clear.cgColor
                self.drawLayer?.lineWidth = 3
                self.drawLayer?.setNeedsDisplay()
            }
            self.delegate?.metaOutput(meta: metadataObjects as! [AVMetadataFaceObject])
        }
    }
    
    var front_face=false
    var front_face_eye_mouth_dis = 0.0
    var front_face_up=false
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
        let ciimage = CIImage(cvPixelBuffer: imageBuffer)
        
        let detectorOptions: [String: AnyObject] = [CIDetectorSmile: true as AnyObject, CIDetectorEyeBlink: true as AnyObject, CIDetectorImageOrientation : 6 as AnyObject]
        
        let faces = self.faceDetector!.features(in: ciimage, options: detectorOptions)
        
        if faces.count == 0 || faces.count > 1{
            DispatchQueue.main.async {
                self.drawLayer?.removeFromSuperlayer()
                self.drawLayer?.setNeedsDisplay()
                self.delegate?.avOutput(facedetected: false, image: nil)
            }
        }else{
            let img : UIImage = self.convert(cmage: ciimage)
            let rotate = img.rotate(radians: .pi/2)!
            DispatchQueue.main.async {
                self.delegate?.avOutput(facedetected: true, image: rotate)
            }
        }
        
    }
    
    func start(){
        captureSession.startRunning()
    }
    
    func stop(){
        captureSession.stopRunning()
    }
    
    func changeCamera(){
        let currentCameraInput: AVCaptureInput = captureSession.inputs[0]
        captureSession.removeInput(currentCameraInput)
        if (currentCameraInput as! AVCaptureDeviceInput).device.position == .back {
            cameraDevice = cameraWithPosition(.front)!
        } else {
            cameraDevice = cameraWithPosition(.back)!
        }
        do {
            let videoInput = try AVCaptureDeviceInput(device: cameraDevice!)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                print("Video input can not be added.")
            }
        } catch {
            print("Something went wrong with the video input.")
            return
        }
    }
}

extension CameraRecord{
    private func getFiles() -> [String]{
        if let files = try? FileManager.default.contentsOfDirectory(atPath: Bundle.main.bundlePath ){
            var filtered = files.filter { $0.contains(".mp3") }
            filtered = filtered.reversed()
            return filtered
        }
        return []
    }
    
    func playSound(iterate: Int) {
        guard let url = Bundle.main.url(forResource: files[iterate].components(separatedBy: ".")[0], withExtension: "mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("couldn't load the file")
        }
    }
    
    func stopSound(){
        player?.stop()
    }
    
    private func cameraWithPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let videoDeviceDiscovery = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: position)
        
        for camera in videoDeviceDiscovery.devices as [AVCaptureDevice] {
            if camera.position == position {
                return camera
            }
        }
        return nil
    }
    
    private func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
}
