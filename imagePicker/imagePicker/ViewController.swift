
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

    
    //MARK: OUTLETS
    @IBOutlet var ImagePickerView:UIImageView!
    @IBOutlet var topTextFieldDelegate: UITextField!
    @IBOutlet var bottomTextFieldDelegate: UITextField!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var pickAnImage: UIButton!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var toolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancellButton: UIBarButtonItem!
    
    var topTextFieldEdited = false
    var bottomTextFieldEdited = false
    

    //MARK: text field format
      func setupTextField(tf: UITextField, text:String){
          tf.defaultTextAttributes = [
              NSAttributedString.Key.strokeColor : UIColor.black,
              NSAttributedString.Key.foregroundColor : UIColor.white,
              NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
              NSAttributedString.Key.strokeWidth : -3.3 ]
          
          
      }
    
        override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.darkGray
        // Do any additional setup after loading the view.
        

        
        self.setupTextField(tf: topTextFieldDelegate, text: "TOP")
        self.setupTextField(tf: bottomTextFieldDelegate, text: "Bottom")
        
        
    }
    
    //MARK:VIEW SET UP
         override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            //set up view as a delegate for text field
            
            topTextFieldDelegate.delegate = self
            bottomTextFieldDelegate.delegate = self
            
            //camera is enabled
            cameraButton.isEnabled  = UIImagePickerController.isSourceTypeAvailable(.camera)
            
            //Disable share button/ until image is created
            shareButton.isEnabled = ImagePickerView.image != nil
            
            subscribeToKeyboardNotifications()
         }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //unsubcribeToKeyboardNotifications()
        
    }
    
     // MARK: save meme
        func save(memedImage: UIImage?) {
                // Create the meme
            guard let memedImage =  memedImage, let _ = ImagePickerView.image else {
                print("NO IMAGE HAS BEEN SELECRED OR IT COULD NOT BE SAVE")
                // PRINT ALERT
                imageNotSaved()
                
                return
        }

            let _ = Meme(topText: topTextFieldDelegate.text!, bottomText: bottomTextFieldDelegate.text!, image: ImagePickerView.image!, memedImage: memedImage)
    }
    
//MARK: ALERT IF IMAGE NOT SAVED
    func imageNotSaved() {
        let alert = UIAlertController(title: "select an Image", message: "Meme could not be saved guey,you did not select an image", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    //MARK: subcribe to Keyboard show and hide
         func subscribeToKeyboardNotifications() {

                NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
               
                NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
            }
         
    
    
    //MARK:
    
    @objc func keyboardWillShow(_ notification:Notification) {
            if bottomTextFieldDelegate.isFirstResponder && view.frame.origin.y == 0 {
                view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
        
    @objc func keyboardWillHide(_ notification:Notification) {
            
            //will move picture back while typing
            //only needed for bottom text
            
            if bottomTextFieldDelegate.isFirstResponder && view.frame.origin.y == 0 {
                view.frame.origin.y = 0
            }
        }
        
        func getKeyboardHeight(_ notification:Notification) -> CGFloat {

            let userInfo = notification.userInfo
            let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
            return keyboardSize.cgRectValue.height
        }

    //MARK: iba actions
    
    //share button and actions
    @IBAction func shareButton(sender: AnyObject) {
        let memedImage = generateMemedImage() //MEME IMAGE & TEXT IS GENERATED
        
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {activity, success, items, error in
            if success {
                self.save(memedImage: memedImage) //save
                self.dismiss(animated: true, completion: nil) //will dissmis the view controller
                
            }
        }
        
        self.present(activityController, animated: true, completion: nil)
        
    }
    
    //MARK: cancell button
    @IBAction func cancellButton(_ sender: Any) {
        topTextFieldDelegate.text = "TOP"
        topTextFieldEdited = false
        bottomTextFieldDelegate.text = "BOTTOM"
        bottomTextFieldEdited = false
        ImagePickerView.image = nil
        shareButton.isEnabled = false
        dismiss(animated: false, completion: nil)
    }
    
    
    //MARK: access to camera & album
     //save image
       func pickAnImageFrom(from source: UIImagePickerController.SourceType){
           let imagePicker = UIImagePickerController()
           imagePicker.delegate = self
           imagePicker.sourceType = source
           present(imagePicker, animated: true, completion: nil)
           
       }
    @IBAction func cameraButton(_ sender: Any) {
        pickAnImageFrom(from: .camera)
    }
    
    //access to personal folder to pick an image
    @IBAction func pickAnImage(_ sender: Any) {
        pickAnImageFrom(from: .photoLibrary)
    }
    
    //user will select picture from ImagePicker
    private func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaInfo info: [String : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
                ImagePickerView.contentMode = UIView.ContentMode.scaleAspectFit
                ImagePickerView.layer.masksToBounds = true
                ImagePickerView.image = image
                buttonsControl(toptext: false, bottomtext: false)
                dismiss(animated: true, completion: nil)
            }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        ImagePickerView.image = nil
        buttonsControl(toptext: true, bottomtext: true)
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: navigation bars
    func buttonsControl(toptext: Bool, bottomtext: Bool){
        topTextFieldDelegate.isHidden = toptext
        bottomTextFieldDelegate.isHidden = bottomtext
    }
                         //top               //bottom
    func toolbarsControl(toptoolbar: Bool, bottomtoolbar: Bool){
        navigationBar.isHidden = toptoolbar
        toolBar.isHidden = bottomtoolbar
        
    }
    
    //MARK: meme Creation
    
    func generateMemedImage() -> UIImage {
        toolbarsControl(toptoolbar: true, bottomtoolbar: true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsGetImageFromCurrentImageContext()
        
        toolbarsControl(toptoolbar: false, bottomtoolbar: false)
        
        return memedImage
        
    }
    
}
    
    
   


