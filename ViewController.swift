//
//  ViewController.swift
//  imagePicker
//
//  Created by Ivan Jovany Arellano Gaspar on 4/30/20.
//  Copyright © 2020 udacity. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {

    
    
   
    
    @IBOutlet var ImagePickerView: UIImageView!
    @IBOutlet var topTextFieldDelegate: UITextField!
    @IBOutlet var bottomTextFieldDelegate: UITextField!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var pickAnImage: UIButton!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var toolBar: UIToolbar!
    
    // text field format
    func setupTextField(tf: UITextField, text:String){
        tf.defaultTextAttributes = [
            NSAttributedString.Key.strokeColor : UIColor.black,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth : -3.3 ]
        
        tf.textColor = UIColor.white
        tf.tintColor = UIColor.white
        tf.textAlignment = .center
        tf.text = text
        tf.delegate = self
        
    }
    
    struct meme {
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var memeImage: UIImage
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        self.setupTextField(tf: topTextFieldDelegate, text: "TOP")
        self.setupTextField(tf: bottomTextFieldDelegate, text: "Bottom")
        
    }
    
    //share button and actions
    @IBAction func shareButton(_ sender: Any) {
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = {activity, success, items, error in
            self.save()
            self.dismiss(animated: true, completion: nil)
        }
        
        present(activityController, animated: true, completion: nil)
        
    }
    
    // cancell button
    @IBAction func cancellButton(_ sender: Any) {
        topTextFieldDelegate.text = "TOP"
        bottomTextFieldDelegate.text = "BOTTOM"
        self.ImagePickerView.image = nil
    }
    
    // access to camera
    @IBAction func cameraButton(_ sender: Any) {
        startImagePicker(sourceType: .camera)
    }
    
    //access to personal folder to pick an image
    @IBAction func pickAnImage(_ sender: Any) {
        startImagePicker(sourceType: .photoLibrary)
    }
    
    private func startImagePicker(sourceType: UIImagePickerController.SourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    //keyboard functions
 override func viewWillAppear(_ animated: Bool) {

     super.viewWillAppear(animated)
     subscribeToKeyboardNotifications()
 }

 override func viewWillDisappear(_ animated: Bool) {

     super.viewWillDisappear(animated)
     unsubscribeFromKeyboardNotifications()
 }
    
    
    func subscribeToKeyboardNotifications() {

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    func unsubscribeFromKeyboardNotifications() {

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
//keyboard will show notification
   @objc func keyboardWillShow(_ notification:Notification) {

        view.frame.origin.y -= getKeyboardHeight(notification)
    }

    func getKeyboardHeight(_ notification:Notification) -> CGFloat {

        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func generateMemedImage() -> UIImage {
        navigationBar.isHidden = true
        toolBar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //show toolbar
        navigationBar.isHidden = false
        toolBar.isHidden = false
        
        return memedImage
        
    }
    
    
    // save image
    func save() {
            // Create the meme
        let memedImage = generateMemedImage()
        _ = Meme(top: topTextFieldDelegate.text!, bottom: bottomTextFieldDelegate.text!, image: ImagePickerView.image, memedImage:generateMemedImage())
        
      
    }
}



