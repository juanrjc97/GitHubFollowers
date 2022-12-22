//
//  GFRepoItemVC.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/20/22.
//

import UIKit

class GFRepoItemVC : GFItemInfoVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configItems()
    }
    
    private func configItems(){
        //aqui podemos usar el user porque estamos herenando de gfIteminfo donde si tenemos el objeto usuario
        itemInfoViewOne.set(itemInfoType: .repos, withCount: user.publicRepos)
        itemInfoViewTwo.set(itemInfoType: .gists, withCount: user.publicGists)
        
        actionButton.set(backgroundColor: .systemBlue, title: "GitHub Profile")
    }
    
    override func actionButtonTapped() {
       //aqui le mandamos la señal al userInfoVC mediante el delegate
        delegate.didTapGitHubProfile(for: user)
    }
    
}
