//
//  GFAvatarImageView.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/14/22.
//

import UIKit

class GFAvatarImageView: UIImageView {

    let cache               = NetworkManager.shared.cache
    let placeholderImage    = UIImage(named: "avatar-placeholder")!

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configure() {
        layer.cornerRadius  = 10
        clipsToBounds       = true
        image               = placeholderImage
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    func downloadImage(url: String)  {
        let cacheKey = NSString(string: url)
        
        //AQUI REVISAMOS SI TENEMOS LA IMAGEN EN EL CACHE ANTES DE HACER OTRA LLAMADA AL API
        if let image = cache.object(forKey: cacheKey){
            self.image = image
            return
        }
        
        guard let url = URL(string: url) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else {return}
            if error != nil {return}
            guard let response = response as? HTTPURLResponse , response.statusCode == 200 else { return }
            guard let data = data else { return }
            
                guard let image = UIImage(data: data) else {return }
            
                self.cache.setObject(image, forKey: cacheKey)
            
                DispatchQueue.main.async {
                    self.image = image
                }

        }
        
        
        task.resume()
    }
}
