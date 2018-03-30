//
//  PreviewViewController.swift
//  CustomCamera
//
//  Created by Nicholas Clark on 3/29/18.
//  Copyright © 2018 Nicholas Clark. All rights reserved.
//

import UIKit
import CoreML
import Vision

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var resultPhoto: UIImageView!
    @IBOutlet weak var photo: UIImageView!
    var image : UIImage!
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.image
        // Do any additional setup after loading the view.
        detectPhoto(image: photo.image!)
        shareBtn.layer.cornerRadius = 8
        shareBtn.layer.borderWidth = 2
        shareBtn.layer.borderColor = UIColor.white.cgColor
        shareBtn.clipsToBounds = true
        view.showLoadingView(inView: view)
    }
    @IBAction func shareBtn_TouchUpInside(_ sender: Any) {
    }
    
    @IBAction func cancelButton_TouchUpInside(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
//    @IBAction func saveButton_TouchUpInside(_ sender: Any) {
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//        dismiss(animated: true, completion: nil)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func detectPhoto(image: UIImage) {
        // load the ml model
        guard let ciImage = CIImage(image: image) else {
            fatalError("couldn't convert UIIMage to CIImage")
        }
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("can't load ml model")
        }
        
        
        let request = VNCoreMLRequest(model: model) { (vnRequest, error) in
            guard let results = vnRequest.results as? [VNClassificationObservation], let firstResult = results.first else {
                fatalError("unexpected result")
            }
            print(results.first?.confidence)
            print(results.first?.identifier)
            
            DispatchQueue.main.async {
                let imageName = firstResult.identifier.contains("cucumber") ? "pickle" : "notPickle"
                self.resultPhoto.image = UIImage(named: imageName)
                self.view.hideLoadingView()
                self.shareBtn.isHidden = false
                self.cancelBtn.isHidden = false
//                if firstResult.identifier.contains("cucumber") {
//                    print("pickle")
//                    self.resultPhoto.image = UIImage(named: "pickle")
//                }
//                else {
//                    print("notpickle")
//                    self.resultPhoto.image = UIImage(named: "notPickle")
//                }
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: ciImage)
        DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive).async {
            do {
                try handler.perform([request])
            }
            catch {
                print(error)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

var loadingView = UIView()
var animateImg = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
extension UIView {
    func showLoadingView(inView v: UIView) {
        loadingView.frame = CGRect(x: 0, y: 0, width: v.frame.size.width, height: v.frame.size.height)
        loadingView.backgroundColor = UIColor.white
        loadingView.alpha = 0.9
        
        v.addSubview(loadingView)
    }
    
    func hideLoadingView() {
        loadingView.removeFromSuperview()
    }
}
