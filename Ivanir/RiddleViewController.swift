//
//  RiddleViewController.swift
//  Ivanir
//
//  Created by Jagni Dasa Horta Bezerra on 9/6/16.
//  Copyright © 2016 Jagni. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import FCAlertView
import SwiftMessages
import ReachabilitySwift
import Alamofire
import MMLoadingButton

var id = 0

class RiddleViewController: UIViewController, UITextFieldDelegate{
    @IBOutlet weak var sendButton: MMLoadingButton!
    
    @IBOutlet weak var photoConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var riddleLabel: UILabel!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    var animationTimer = Timer()
    
    var updated = false
    
    var password : String?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        id = UserDefaults.standard.integer(forKey: "id")
        
        let today = Date()
        let calendar = Calendar.current
        let monthDay = (calendar as NSCalendar).components(NSCalendar.Unit.day, from: today)
        
        if id != monthDay.day{
            UserDefaults.standard.set(nil, forKey: "croppedPhoto")
            UserDefaults.standard.set(nil, forKey: "photo")
            UserDefaults.standard.set(false, forKey: "hasRecordedAudio")
            UserDefaults.standard.set(false, forKey: "revealed")
            UserDefaults.standard.synchronize()
        }
        
        if Reachability()?.currentReachabilityStatus == Reachability.NetworkStatus.reachableViaWiFi || Reachability()?.currentReachabilityStatus == Reachability.NetworkStatus.reachableViaWWAN{
            getJSON()
        }
        else{
            self.riddleLabel.text = "Hoje a internet tá a puta que pariu, viu?"
        }
    }
    
    func getJSON(){
        self.riddleLabel.text = "Carregando..."
        ConnectionHelper.getJSON { (response, error) in
            
            if !error{
                
                for (_, json) : (String, JSON) in response{
                    
                    let today = Date()
                    let calendar = Calendar.current
                    let month = (calendar as NSCalendar).components(NSCalendar.Unit.month, from: today)
                    let monthDay = (calendar as NSCalendar).components(NSCalendar.Unit.day, from: today)
                    
                    //if json["day"].intValue == monthDay.day && json["month"].intValue == month.month{
                    if json["day"].intValue == monthDay.day && json["month"].intValue == month.month{
                        self.riddleLabel.text = json["riddle"]["person"].stringValue
                        self.password = json["password"].stringValue
                        
                        self.updated = true
                        UIView.animate(withDuration: 0.5, animations: { () -> Void in
                            self.passwordTextField.isEnabled = true
                            self.passwordTextField.alpha = 1
                            self.sendButton.isEnabled = true
                            self.sendButton.alpha = 1
                        }) 
                        
                        
                        id = json["id"].intValue
                        
                        UserDefaults.standard.set(id, forKey: "id")
                        UserDefaults.standard.synchronize()
                        
                        break
                    }
                    
                }
                
                if !self.updated{
                    self.riddleLabel.text = "CADÊ ALGUÉM?\nHoje num vai dar não Ivanir :P"
                }
                
            }
            else{
                self.riddleLabel.text = "CADÊ ALGUÉM?\nHoje num vai dar não Ivanir :P"
            }
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        inputAnimations()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        passwordTextField.resignFirstResponder()
        inputEndAnimations()
    }
    
    func inputAnimations(){
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.photoConstraint.constant = -205
            self.view.layoutIfNeeded()
        }) 
    }
    
    func inputEndAnimations(){
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.photoConstraint.constant = -35
            self.view.layoutIfNeeded()
        }) 
    }
    
    let alertTitles = ["E-r-r-r-r-ou!", "Já deu né?", "Para, cara", "Ah Ivani..."]
    let alertSubtitles = ["Try again ¯\\_(ツ)_/¯", "Na primeira já dava", "Não adianta tentar adivinhar u-u", "Vai tomar no cur"]
    var numberOfErrors = 0
    
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
    
    @IBAction func didTapSend(_ sender: MMLoadingButton) {
        self.passwordTextField.resignFirstResponder()
        inputEndAnimations()
        if updated{
            if passwordTextField.text?.md5 == self.password!{
                self.sendButton.setTitle("Enviando", for: UIControlState.disabled)
                self.sendButton.isEnabled = false
                self.animationTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.animateButton(_:)), userInfo: nil, repeats: true)
                let json = ["id" : id , "type": "PASSWORD"] as [String : Any]
                ConnectionHelper.sendJSON(json: json, completionHandler: { (response) in
                    sender.stopLoading(response, completed: nil)
                    if response{
                        UserDefaults.standard.set(true, forKey: "revealed")
                        UserDefaults.standard.synchronize()
                        self.performSegue(withIdentifier: "Password", sender: nil)
                    }
                    else{
                        let alert = FCAlertView()
                        alert.makeAlertTypeWarning()
                        alert.tintColor = UIColor ( red: 1.0, green: 0.3333, blue: 0.3333, alpha: 1.0 )
                        
                        alert.showAlert(inView: self, withTitle: "Erro!", withSubtitle: "Houve algum erro oh :( *Provavelmente de rede*", withCustomImage: nil, withDoneButtonTitle: "Que pena, né?", andButtons: nil)
                    }
                    
                    self.animationTimer.invalidate()
                        self.sendButton.alpha = 1
                        self.sendButton.isEnabled = true
                    
                })
            }
            else{
                //sender.stopLoading(false, completed: nil)
                self.passwordTextField.resignFirstResponder()
                let alert = FCAlertView()
                
                alert.makeAlertTypeWarning()
                alert.tintColor = UIColor ( red: 1.0, green: 0.3333, blue: 0.3333, alpha: 1.0 )
                
                alert.showAlert(inView: self, withTitle: alertTitles[numberOfErrors], withSubtitle: alertSubtitles[numberOfErrors], withCustomImage: nil, withDoneButtonTitle: "OK", andButtons: nil)
                
                numberOfErrors += 1
                if numberOfErrors >= alertTitles.count {
                    numberOfErrors = alertTitles.count - 1
                }
            }
        }
        else{
            
            
            
        }
    }
    
}

extension String  {
    var md5: String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate(capacity: digestLen)
        
        return String(format: hash as String)
    }
}
