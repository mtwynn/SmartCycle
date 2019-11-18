//
//  CaptureViewController.swift
//  SmartCycle
//
//  Created by Tam Nguyen on 10/25/19.
//  Copyright © 2019 Rho Bros Co. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import AlamofireImage

class CaptureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var analyzeButtonView: UIButton!
    
    var labelAnnotations = [NSDictionary]()
  
    var ref : DatabaseReference!
    
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
        
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func capture(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        let alert = UIAlertController(title: "Message", message: "Choose an image mode", preferredStyle: .alert)
        
        
        let cameraBtn = UIAlertAction(title: "Camera", style: .default) { action in
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }
        alert.addAction(cameraBtn)
        
        let galleryBtn = UIAlertAction(title: "Gallery", style: .default) { action in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }
        
        alert.addAction(galleryBtn)
        
        present(alert, animated: true, completion: nil)
        
        
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
            
            let recyclables = [
                    "Plastic bottle", "Aluminum can", "Beverage can", "Tin can",
                    "Glass", "Glass bottle", "Bottle", "Can",
            ]
            
            let foods = ["Food", "Burger", "Junk food", "Drink", "Snack", "Fast Food"]
            
            
            var recycleResults = [String]()
            var landfillResults = [String]()
            
            let dataDict = myResult as! NSDictionary
            let labels = dataDict["responses"]! as! [Any]
            let labelannot = labels[0] as! [String:Any]
            self.labelAnnotations = labelannot["labelAnnotations"] as! [NSDictionary]
            
            if self.labelAnnotations.count == 0 {
                self.ref.child("Current analysis/SORT").setValue(0)
            }
            
            //self.ref.child("Current analysis/SORT").setValue(1)
            
            var isRecyclable = false
            
            for label in self.labelAnnotations {
                let description = label["description"] as! String
                let score = label["score"] as! Double
                
                if (recyclables.contains(description)) {
            
                    if (score > 0.80) {
            
                        isRecyclable = true
                        self.ref.child("Current analysis/SORT").setValue(1)
                        break
                        
                    }
                   

                } else if (foods.contains(description)) {
                    
                    self.ref.child("Current analysis/SORT").setValue(2)
                    break
                    
                }
                
            }
            
            /*
            if (recycleResults.count > landfillResults) {
                isRecyclable = true
            } else {
                isRecycle = false
            }*/
            if (isRecyclable) {
                self.ref.child("Current analysis/SORT").setValue(1)
            }
            
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
