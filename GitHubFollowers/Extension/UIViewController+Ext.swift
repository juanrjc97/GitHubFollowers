//
//  UIViewController+Ext.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/13/22.
//

import UIKit

//ESTA EXTENSION ES LA QUE PERMITE PRESENTAR EL ALERTVC EN CUALQUIER VISTA
extension UIViewController {
    
    func presentGFAlertOnMainThread( title: String , message: String , buttonTitle: String){
        DispatchQueue.main.async {
            let alertVC = GFAlertVC(title: title, message: message, buttonTitle: buttonTitle)
            alertVC.modalPresentationStyle  = .overFullScreen
            alertVC.modalTransitionStyle    = .crossDissolve
            self.present(alertVC, animated: true)
        
        }
    }
    
    
    
}
