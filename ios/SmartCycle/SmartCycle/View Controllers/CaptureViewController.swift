//
//  CaptureViewController.swift
//  SmartCycle
//
//  Created by Tam Nguyen on 10/25/19.
//  Copyright © 2019 Rho Bros Co. All rights reserved.
//

import UIKit
import AlamofireImage

class CaptureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var analyzeButtonView: UIButton!
    
    var labelAnnotations = [NSDictionary]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //analyzeButtonView.isHidden = true
        if imageView.image == nil {
            analyzeButtonView.layer.backgroundColor = UIColor.init(red: 212/255, green: 212/255, blue: 212/255, alpha: 1).cgColor
            analyzeButtonView.setTitleColor(UIColor.init(red: 157/255, green: 157/255, blue: 157/255, alpha: 1), for: .normal)
            analyzeButtonView.isEnabled = false
            imageView.layer.borderWidth = 0
            imageView.layer.borderColor = UIColor.white.cgColor
        }
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func capture(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageAspectScaled(toFill: size)
        
        imageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
        analyzeButtonView.isEnabled = true
        analyzeButtonView.layer.backgroundColor = UIColor.init(red: 0, green: 122/255, blue: 1, alpha: 1).cgColor
        analyzeButtonView.setTitleColor(UIColor.white, for: .normal)
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor(red: 0, green: 122/255, blue: 1, alpha: 1).cgColor
        
    }

    @IBAction func analyzeImage(_ sender: Any) {
        CloudVisionsAPICaller().detect(from: imageView.image!) { myResult in
        //            guard let myResult = myResult else {
        //                fatalError("Did not recognize image")
        //            }
            let dataDict = myResult as! NSDictionary
            let labels = dataDict["responses"]! as! [Any]
            let labelannot = labels[0] as! [String:Any]
            self.labelAnnotations = labelannot["labelAnnotations"] as! [NSDictionary]
            self.performSegue(withIdentifier: "resultsSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "resultsSegue") {
            let resultsViewController = segue.destination as? ResultsViewController
            resultsViewController?.text = "From CaptureViewController" //self.labelAnnotations
            resultsViewController?.results = self.labelAnnotations
        }
        
    }
    

}
