//
//  ViewController.swift
//  Alamofire Img Upload
//
//  Created by AshutoshD on 08/04/20.
//  Copyright © 2020 ravindraB. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var txtFName: UITextField!
    @IBOutlet weak var txtLName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumer: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    var selectedImages : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setDefaultMaskType(.custom)
        SVProgressHUD.setForegroundColor(UIColor.white)
        SVProgressHUD.setBackgroundColor(UIColor.black)
        
    }

    @IBAction func BtnSelectImgTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    //MARK:-- ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imgView.contentMode = .scaleToFill
            imgView.image = pickedImage
            selectedImages = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }
    @IBAction func BtnSubmitTapped(_ sender: UIButton) {
        
//        if imgView.image != nil {
//            self.uploadWithAlamofire()
//        }else{
//            print("Please upload Image first")
//        }
        
        if imgView.image != nil {
            
            SVProgressHUD.show()
            
            if let data = selectedImages?.jpegData(compressionQuality: 0.5) {
                let url = "http://13.57.238.187/ak/360legalforms_api/public/api/v1/register"
                let headers : HTTPHeaders = ["Secure-Key" : "20dcc7ec-7387-44b6-abeb-7d116c214417",
                                             "Accept" : "application/json"]
                // define parameters
                let parameters : Parameters = [
                    "first_name" : txtFName.text as Any,
                    "last_name" : txtLName.text as Any,
                    "email" : txtEmail.text as Any,
                    "phone_number" : txtPhoneNumer.text as Any,
                    "password" : txtPassword.text as Any
                ]
                // You can change your image name here, i use NSURL image and convert into string
                //            let imageURL = info[UIImagePickerControllerReferenceURL] as! NSURL
                //            let fileName = imageURL.absouluteString
                // Start Alamofire
                Alamofire.upload(multipartFormData: { multipartFormData in
                    for (key,value) in parameters {
                        multipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                    }
                    multipartFormData.append(data, withName: "avatar", fileName: "file.png",mimeType: "image/jpeg")
                },
                                 usingThreshold: UInt64.init(),to: url, method: .post, headers: headers,
                                 encodingCompletion: { encodingResult in
                                    switch encodingResult {
                                    case .success(let upload, _, _):
                                        upload.responseJSON { response in
                                            debugPrint(response)
                                            if let json = response.value {
                                                print("JSON: \(json)")// serialized json response after post
                                                
                                                let jsonDict = json as? NSDictionary
                                                let message  = jsonDict?.value(forKey: "message") as! String
                                                if message == "Register Success" {
                                                    let secondViewController = self.storyboard!.instantiateViewController(withIdentifier: "SuccessfullySignUpVC") as! SuccessfullySignUpVC
                                                    SVProgressHUD.dismiss(); self.navigationController!.pushViewController(secondViewController, animated: true)
                                                }else {
                                                    print("message\(message)")
                                                    SVProgressHUD.dismiss();
                                                    let alert = UIAlertController(title: "Alert", message: message,preferredStyle: UIAlertController.Style.alert)
                                                    
                                                    alert.addAction(UIAlertAction(title: "Ok",
                                                                                  style: UIAlertAction.Style.default,
                                                                                  handler: {(_: UIAlertAction!) in
                                                                                    //Sign out action
                                                    }))
                                                    self.present(alert, animated: true, completion: nil)
                                                }
                                               SVProgressHUD.dismiss();
                                            }
                                            
                                        }
                                    case .failure(let encodingError):
                                        print(encodingError)
                                          SVProgressHUD.dismiss();
                                        
                                    }
                })
            }
            
            
        }else{
                print("Please upload Image first")
            }
    }
    
//    Another Method to upload a picture using firebase
    
//    func uploadWithAlamofire() {
////        let image = UIImage(named: "bodrum")!
//
//
//
//       let url = "http://13.57.238.187/ak/360legalforms_api/public/api/v1/register"
//        let headers = ["Secure-Key" : "20dcc7ec-7387-44b6-abeb-7d116c214417",
//            "Accept" : "application/json"]
//        // define parameters
//        let parameters = [
//            "first_name" : txtFName.text,
//            "last_name" : txtLName.text,
//            "email" : txtEmail.text,
//            "phone_number" : txtPhoneNumer.text,
//            "password" : txtPassword.text
//        ]
//
//        Alamofire.upload(multipartFormData: { multipartFormData in
//            if let imageData = selectedImages?.jpegData(compressionQuality: 0.5) {
//                multipartFormData.append(imageData, withName: "file", fileName: "file.png", mimeType: "image/png")
//            }
//
//            for (key, value) in parameters {
//                multipartFormData.append((value!.data(using: .utf8))!, withName: key)
//            }}, to: url, method: .post, headers: headers,
//                encodingCompletion: { encodingResult in
//                    switch encodingResult {
//                    case .success(let upload, _, _):
//                        upload.response { [weak self] response in
//                            guard let strongSelf = self else {
//                                return
//                            }
//                            debugPrint(response)
//                        }
//                    case .failure(let encodingError):
//                        print("error:\(encodingError)")
//                    }
//        })
//    }

}



