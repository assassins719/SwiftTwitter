//
//  LoginVC.swift
//  Cult
//
//  Created by Han on 5/9/18.
//  Copyright © 2018 Han. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding
import MBProgressHUD

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var avoidView: UIView!
    
    @IBOutlet weak var backButton: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        AppManager.shared.setBorderToUIView(view: loginButton, width: 1, color: UIColor.init(rgb: 0x21283B))

        setPlaceholder(textField: usernameTextField, placeholderString: "USERNAME")
        setPlaceholder(textField: passwordTextField, placeholderString: "PASSWORD")
        
        KeyboardAvoiding.avoidingView = avoidView
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.backButtonTap(_:)))
        backButton.addGestureRecognizer(tap)
        
    }
    
    @IBAction func onLoginButton(_ sender: Any) {
        
        if usernameTextField.text == "" || usernameTextField.text == ""{
            AppManager.shared.showAlert(title: "Oops!", msg: "All fields are mandatory.", activity: self)
            return
        }
        
        AppManager.shared.showLoadingIndicator(view: self.view)
        
        let params = ["username": usernameTextField.text!,
                      "password": passwordTextField.text!]
        
        APIManager.shared.logIn(params: params) { (error, response) in
        
            AppManager.shared.hideLoadingIndicator()
            
            if error == nil{
                print(response)
                if response["result"].stringValue == "success"{
                    
                    UserDefaults.standard.setValue(response["token"].stringValue, forKey: TOKEN)
                    UserDefaults.standard.set(true, forKey: ISLOGGEDIN)
  
                    let user: UserModel = UserModel.init(jsonData: response["user"])
                    
                    let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: user)
                    UserDefaults.standard.set(encodedData, forKey: USER_DATA)
                    
                    AppManager.shared.goToMainTabBar()
                    
                }else{
                    
                    print(response)
                    AppManager.shared.showAlert(title: "Oops!", msg: "Invalid username or password", activity: self)
                    
                }
                
            }
            
        }
        
    }
    
    func setPlaceholder(textField: UITextField, placeholderString: String){
        
        textField.defaultTextAttributes.updateValue(1.5, forKey: NSAttributedStringKey.kern.rawValue)
        
        let string = NSMutableAttributedString(string: placeholderString)
        
        string.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white , range: NSRange(location:0,length: string.length))
        string.addAttribute(kCTKernAttributeName as NSAttributedStringKey, value: CGFloat(1.5), range: NSRange(location: 0, length: string.length))
        string.addAttributes([NSAttributedStringKey.font: UIFont(name: "Roboto-Regular", size: 13.0)!], range: NSRange(location: 0, length: string.length))
        
        textField.attributedPlaceholder = string
        
    }
    
    @objc func backButtonTap(_ sender: UITapGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        }else{
            textField.resignFirstResponder()
        }
        
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}