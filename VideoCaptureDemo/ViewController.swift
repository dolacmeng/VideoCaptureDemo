//
//  ViewController.swift
//  VideoCaptureDemo
//
//  Created by 许伟杰 on 2018/7/26.
//  Copyright © 2018年 JackXu. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    fileprivate lazy var session : AVCaptureSession = AVCaptureSession()
    fileprivate var videoOutput : AVCaptureVideoDataOutput?
    fileprivate var previewLayer : AVCaptureVideoPreviewLayer?
    fileprivate var videoInput : AVCaptureDeviceInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //1.初始化视频的输入&输出
        setUpVideoInputOutput()
        
        //2.初始化音频的输入&输出
        setupAudioInputOutput()
        
        //3.初始化一个预览图层
        setupPreviewLayer()
        
    }
}

extension ViewController{
    @IBAction func startCapturing(){
        session.startRunning()
    }
    
    @IBAction func stopCapturing(){
        session.stopRunning()
        previewLayer?.removeFromSuperlayer()
    }
    
    @IBAction func rotateCamera(){
        guard let videoInput = videoInput else {
            return
        }
        let position : AVCaptureDevice.Position = (videoInput.device.position == .front) ? .back: .front
        guard let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] else {return}
        guard let device = devices.filter({$0.position == position}).first else {return}
        guard let input = try? AVCaptureDeviceInput(device: device) else {return}
        
        //移除旧的input，添加新input
        session.beginConfiguration()
        session.removeInput(videoInput)
        if session.canAddInput(input) {
            session.addInput(input)
        }
        session.commitConfiguration()
        
        self.videoInput = input
    }
}

extension ViewController{
    fileprivate func setUpVideoInputOutput() {
        //1.添加视频输入
        guard let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] else {return}
        guard let device = devices.filter({$0.position == .front}).first else {return}
        guard let input = try? AVCaptureDeviceInput(device: device) else {return}
        self.videoInput = input
        
        //2.添加视频输出
        let output = AVCaptureVideoDataOutput()
        let queue = DispatchQueue.global()
        output.setSampleBufferDelegate(self, queue: queue)
        self.videoOutput = output
        
        //3.添加输入&输出
        addInputOutputToSession(input, output)
    }
    
    
    fileprivate func setupAudioInputOutput() {
        //1.创建输入
        guard let device = AVCaptureDevice.default(for: .audio) else { return }
        guard let input = try? AVCaptureDeviceInput(device: device) else { return }
        
        //2.创建输出
        let output = AVCaptureAudioDataOutput()
        let queue = DispatchQueue.global()
        output.setSampleBufferDelegate(self, queue: queue)
        
        //3.添加输入&输出
        addInputOutputToSession(input, output)
    }
    
    private func addInputOutputToSession(_ input : AVCaptureInput, _ output : AVCaptureOutput){
        session.beginConfiguration()
        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        session.commitConfiguration()
    }
    
    fileprivate func setupPreviewLayer() {
        //1.创建预览图层
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        
        //2.设置previewLayer属性
        previewLayer.frame = view.bounds;
        
        //3.将图层添加到控制器的view的layer中
        view.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
    }
}

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if videoOutput?.connection(with: .video) == connection {
            print("采集视频")
        }else{
            print("采集音频")
        }
    }
}

