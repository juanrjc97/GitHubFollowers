//
//  SearchVC.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/12/22.
//

import UIKit

class SearchVC: UIViewController, UITextFieldDelegate {
    
    let logoImageView       = UIImageView()
    let usernameTextField   = GFTextField()
    let searchButton = GFButton(backgroundColor: .systemGreen, title: "Get Followers")
    
    //COMPUTER PROPERTY isUsernameEntered
    var isUsernameEntered: Bool {
        return !usernameTextField.text!.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        usernameTextField.delegate = self
        configureLogoImageView()
        configureTextField()
        configureCallToActionButton()
        createDismissKeyboardTapGesture()

    }
    
    //AQUI LE QUITAMOS EL NAVIGATION BAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    //dismiss the keyboard function , se le puede agregar a cualquier view para hacer el dismiss
    func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    //funcion para mostar el followers vc
    @objc func pushFollowerListVC() {
        guard isUsernameEntered else {
        presentGFAlertOnMainThread(title: "Empty Username", message: "Please enter a username. We need to know who to look for 😀.", buttonTitle: "Ok")
            return
        }
        
        //AQUI CREO LA VISTA DEL FOLLOWELISTVC
        let followerListVC      = FollowerListVC()
        followerListVC.username = usernameTextField.text
        followerListVC.title    = usernameTextField.text
        // con esto se lo pone en el tope de la pila que muestra las pantallas 
        navigationController?.pushViewController(followerListVC, animated: true)
    }
    
    
    func configureLogoImageView() {
        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage(named: "gh-logo")!
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            logoImageView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    func configureTextField() {
        view.addSubview(usernameTextField)
        //usernameTextField.delegate = self
        
        NSLayoutConstraint.activate([
            usernameTextField.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 48),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configureCallToActionButton() {
        view.addSubview(searchButton)
        // aqui activamos la funcion que muestra el followersVC
        searchButton.addTarget(self, action: #selector(pushFollowerListVC), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            searchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            searchButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            searchButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
// MARK: - UITEXTFIELD DELEGATE FUNCTIONS
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       
        pushFollowerListVC()
        return true;
    
    }
}
    
    
    

