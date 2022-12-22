//
//  UserInfoVC.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/19/22.
//

import UIKit
import SafariServices

protocol UserInfoVCDelegate: AnyObject {
    func  didTapGitHubProfile(for user: User)
    func didTapGetFollowers(for user: User)
}

class UserInfoVC: UIViewController , UserInfoVCDelegate{

    public var  username: String!
    
    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    let dateLabel = GFBodyLabel(textAlignment: .center)
    weak var delegate : FollowersListVCDelegate!
    var itemViews : [UIView] = []
    var user: User?
   
    
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
        let leftBarButton = UIBarButtonItem(title: "Add To Favorites", style: .plain, target: self, action: #selector(addToFavorites))
        navigationItem.rightBarButtonItem = dondeButton
        navigationItem.leftBarButtonItem = leftBarButton
        
       
    }
    
    @objc func addToFavorites(){
        
        let newFavorite = Follower(login: user!.login, avatarUrl: user!.avatarUrl)
        
        PersistenceManager.updateFavorites(favorite: newFavorite, actionType: .add) {[weak self] error in
            
            guard let self = self else { return}
            
            guard let error = error else {
                
                self.presentGFAlertOnMainThread(title: "User Added", message: "This user is now in your Favorite List", buttonTitle: "Great")
                return
            }
            self.presentGFAlertOnMainThread(title: "Something Went Wrong", message: error.rawValue , buttonTitle: "Ok")
           
        }
    }
    
    
    func getUserInfo()  {
        NetworkManager.shared.getUserInfo(for: username) { [weak self] result in
            guard let self = self else {return}
            
            switch result {
            case .success(let user):
                self.user = user
                DispatchQueue.main.async {
                    self.configUIItems(user: user)
                }
               
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
    
    func configUIItems(user: User)  {

        //aqui seteo el delegate del ItemInfoVC que es de tipo UserInfoVCDelegate
        let repoItemVC = GFRepoItemVC(user: user)
        repoItemVC.delegate = self
        let followersItemVC = GFFollowerItemVC(user: user)
        followersItemVC.delegate = self
        
        self.addChildVC(childVC: GFUserInfoHeaderVC(user: user), to: self.headerView)
        self.addChildVC(childVC: repoItemVC, to: self.itemViewOne)
        self.addChildVC(childVC: followersItemVC, to: self.itemViewTwo)
        self.dateLabel.text =  "GitHub User since \(user.createdAt.convertToDisplayFormat())"
    }
    
    func layoutUI()  {
        
        itemViews = [headerView, itemViewOne,itemViewTwo, dateLabel]
        for itemView  in itemViews {
            view.addSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        
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
                  
                  dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
                  dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
                  dateLabel.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: padding),
                  dateLabel.heightAnchor.constraint(equalToConstant: 18),
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
    
    func didTapGitHubProfile(for user: User) {
        //show safari view controller
        guard let url = URL(string: user.htmlUrl) else {
            presentGFAlertOnMainThread(title: "INVALID URL", message: "The url attached to this user is invalid", buttonTitle: "Exit")
            return
        }
        let safariVc = SFSafariViewController(url: url)
        safariVc.preferredControlTintColor = .systemGreen
        present(safariVc, animated: true)
        
    }
    
    func didTapGetFollowers(for user: User) {
        //tell follower list screen the new user
        guard  user.followers != 0 else {
            presentGFAlertOnMainThread(title: "NO FOLLOWERS", message: "This user has 0 followers", buttonTitle: "So sad")
            return
        }
        delegate.didRequestFollowers(for: user.login)
        dismissVC()
    }
    

}
