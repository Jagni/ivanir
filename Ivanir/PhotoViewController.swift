//
//  PhotoViewController.swift
//  Ivanir
//
//  Created by Jagni Dasa Horta Bezerra on 9/6/16.
//  Copyright © 2016 Jagni. All rights reserved.
//

import Foundation
import UIKit
import DZNPhotoPickerController
import Photos
import MMLoadingButton
import FCAlertView

class PhotoViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var photoConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoView: UIImageView!
    
    @IBOutlet weak var sendButton: MMLoadingButton!
    
    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var photoToolbar: UIToolbar!
    
    @IBOutlet weak var cameraView: UIView!
    
    var animationTimer = Timer()
    
    var photo : UIImage?
    var croppedPhoto : UIImage?
    
    func animateButton(_ sender: Any){
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                if self.sendButton.alpha == 0{
                    self.sendButton.alpha = 1
                }
                else{
                    self.sendButton.alpha = 0
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let photoData = UserDefaults.standard.data(forKey: "photo")
        let croppedPhotoData = UserDefaults.standard.data(forKey: "croppedPhoto")
        
        self.photo = UIImage(data:  photoData!)
        self.croppedPhoto = UIImage(data:  croppedPhotoData!)
        
        if let _ = photo, let _ = croppedPhoto{
            
            self.photoView.image = self.croppedPhoto!
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.photoView.alpha = 1
                self.photoToolbar.alpha = 1
                self.sendButton.alpha = 1
                self.photoButton.alpha = 0
                self.photoConstraint.constant = -44
                self.view.layoutIfNeeded()
            })
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    @IBAction func didTapEditPhoto(_ sender: AnyObject){
        let editor = DZNPhotoEditorViewController.init(image: photo)
        
        editor?.cropMode = DZNPhotoEditorViewControllerCropMode.square
        
        editor?.acceptBlock = {(edit, userInfo) in
            self.croppedPhoto = userInfo?[UIImagePickerControllerEditedImage] as? UIImage
            self.photo = userInfo?[UIImagePickerControllerOriginalImage] as? UIImage
            self.photoView.image = self.croppedPhoto!
            self.dismiss(animated: true, completion: nil)
        }
        
        editor?.cancelBlock = {(edit) in
            self.dismiss(animated: true, completion: nil)
        }
        
        let navigationController = UINavigationController(rootViewController: editor!)
        
        self.present(navigationController, animated: true, completion: nil)
        
    }
    
    @IBAction func didTapRemovePhoto(_ sender: AnyObject) {
        self.photo = nil
        self.croppedPhoto = nil
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.photoView.alpha = 0
            self.photoToolbar.alpha = 0
            self.photoButton.alpha = 1
            self.photoConstraint.constant = 0
            self.sendButton.alpha = 0
            self.view.layoutIfNeeded()
        }) 
    }
    
    @IBAction func didTapPictureButton(_ sender: AnyObject){
        
        
        let actionSheet = UIAlertController(title: nil, message: NSLocalizedString("Mudar foto do dia", comment: ""), preferredStyle: .actionSheet)
        
        actionSheet.view.tintColor = UIColor ( red: 1.0, green: 0.3333, blue: 0.3333, alpha: 1.0 )
        
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        picker.cropMode = DZNPhotoEditorViewControllerCropMode.square
        
        let cameraAction = UIAlertAction(title: NSLocalizedString("Câmera", comment: ""), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            picker.sourceType = UIImagePickerControllerSourceType.camera
            
            picker.navigationBar.barTintColor = UIColor ( red: 1.0, green: 0.3333, blue: 0.3333, alpha: 1.0 )
            picker.navigationBar.tintColor = UIColor.white
            
            self.present(picker, animated: true, completion: nil)
            
            
        })
        
        let galleryAction = UIAlertAction(title: NSLocalizedString("Biblioteca de Fotos", comment: ""), style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.navigationBar.barTintColor = UIColor ( red: 1.0, green: 0.3333, blue: 0.3333, alpha: 1.0 )
            picker.navigationBar.backgroundColor = UIColor ( red: 1.0, green: 0.3333, blue: 0.3333, alpha: 1.0 )
            picker.navigationBar.tintColor = UIColor.white
            picker.navigationBar.titleTextAttributes =  [NSForegroundColorAttributeName:UIColor.white]
            self.navigationController?.navigationBar.isTranslucent = false
            
            self.present(picker, animated: true, completion: nil)
            
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancelar", comment: ""), style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        actionSheet.addAction(cameraAction)
        actionSheet.addAction(galleryAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        self.croppedPhoto = info[UIImagePickerControllerEditedImage] as? UIImage
        self.photo = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.photoView.image = self.croppedPhoto!
        self.dismiss(animated: true) { () -> Void in
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.photoView.alpha = 1
                self.photoToolbar.alpha = 1
                self.sendButton.alpha = 1
                self.photoButton.alpha = 0
                self.photoConstraint.constant = -44
                self.view.layoutIfNeeded()
            }) 
        }
    }
    
    @IBAction func didTapSend(_ sender: MMLoadingButton) {
        self.sendButton.isEnabled = false
        self.sendButton.setTitle("Enviando", for: UIControlState.disabled)
        self.animationTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.animateButton(_:)), userInfo: nil, repeats: true)
        
        let imageData = UIImageJPEGRepresentation(self.croppedPhoto!, 1)!
        var dataJSON = [String : AnyObject]()
        dataJSON["type"] = "PHOTO" as AnyObject?
        dataJSON["id"] = id as AnyObject?
        dataJSON["photo"] = imageData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters) as AnyObject?
        
        
        ConnectionHelper.sendJSON(json: dataJSON) { (response) in
            self.animationTimer.invalidate()

            if response{
                
                let alert = FCAlertView()
                
                alert.makeAlertTypeSuccess()
                alert.tintColor = UIColor ( red: 1.0, green: 0.3333, blue: 0.3333, alpha: 1.0 )
                
                DispatchQueue.main.async {
                    alert.showAlert(inView: self, withTitle: "Sucesso!", withSubtitle: "Imagem enviada com sucesso :D", withCustomImage: nil, withDoneButtonTitle: "Tá bom", andButtons: nil)
                    UserDefaults.standard.set(UIImageJPEGRepresentation(self.croppedPhoto!, 1)!, forKey: "croppedPhoto")
                }
                
                
                UserDefaults.standard.set(UIImageJPEGRepresentation(self.photo!, 1)!, forKey: "photo")
                UserDefaults.standard.synchronize()
            }
            else{
                
                let alert = FCAlertView()
                
                alert.makeAlertTypeWarning()
                alert.tintColor = UIColor ( red: 1.0, green: 0.3333, blue: 0.3333, alpha: 1.0 )
                
                alert.showAlert(inView: self, withTitle: "Erro!", withSubtitle: "Houve algum erro :(\n*Provavelmente de rede*", withCustomImage: nil, withDoneButtonTitle: "Que pena, né?", andButtons: nil)
                
            }
            

            
                self.sendButton.alpha = 1
                self.sendButton.isEnabled = true
                self.sendButton.titleLabel?.text = "Enviar"
            
        }
        
    }
}
