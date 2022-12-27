//
//  GFButton.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/12/22.
//

import UIKit

class GFButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    init(backgroundColor: UIColor, title: String) {
        super.init(frame: .zero)
        self.backgroundColor = backgroundColor
        self.setTitle(title, for: .normal )
        configure()
    }
    
    
    private func configure() {
        
        layer.cornerRadius      = 10
        setTitleColor(.white, for: .normal)
        titleLabel?.font        = UIFont.preferredFont(forTextStyle: .headline)
       translatesAutoresizingMaskIntoConstraints = false
    }
    
    @available(iOS 15.0, *)
    func set(backgroundColor: UIColor,title: String, systemImageName: String)  {
        self.backgroundColor = backgroundColor
        setTitle(title, for: .normal)
       
        configuration?.image = UIImage(systemName: systemImageName )
        
        configuration?.imagePadding = 6
        configuration?.imagePlacement = .leading
    }
}
