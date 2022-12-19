//
//  UserInfoVC.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/19/22.
//

import UIKit

class UserInfoVC: UIViewController {

    public var  username: String!
    
    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    
    var itemViews : [UIView] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
    
        configureViewController()
        layoutUI()
        getUserInfo()

    }
    
    func configureViewController()  {
        view.backgroundColor = .systemBackground
        let dondeButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        navigationItem.rightBarButtonItem = dondeButton
    }
    
    func getUserInfo()  {
        NetworkManager.shared.getUserInfo(for: username) { [weak self] result in
            guard let self = self else {return}
            
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.addChildVC(childVC: GFUserInfoHeaderVC(user: user), to: self.headerView)
                }
               
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
    
    func layoutUI()  {
        
        itemViews = [headerView, itemViewOne,itemViewTwo]
        for itemView  in itemViews {
            view.addSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        itemViewOne.backgroundColor = .systemRed
        itemViewTwo.backgroundColor = .systemRed
        
        
        let padding : CGFloat = 20
        let itemHeight :CGFloat = 140
        
              NSLayoutConstraint.activate([
                  headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                  headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                  headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                  headerView.heightAnchor.constraint(equalToConstant: 180),
                  
                  itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: padding),
                  itemViewOne.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: padding),
                  itemViewOne.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
                  itemViewOne.heightAnchor.constraint(equalToConstant: itemHeight),
                  
                  itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: padding),
                  itemViewTwo.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: padding),
                  itemViewTwo.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
                  itemViewTwo.heightAnchor.constraint(equalToConstant: itemHeight),
              ])
        
    }
    
    func addChildVC(childVC: UIViewController, to containerView: UIView)  {
        addChild(childVC)
        //el containerview va a ser el headerview
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        //el self se refiere a este view controller en este caso el USERINFOVC
        childVC.didMove(toParent: self)
    }
    
   @objc func dismissVC()  {
        dismiss(animated: true)
    }
    

}
