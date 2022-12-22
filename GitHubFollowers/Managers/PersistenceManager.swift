//
//  PersistenceManager.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/21/22.
//

import Foundation

enum PersistenceActionType {
    case add , remove
}


enum PersistenceManager {
    
    static private let defaults = UserDefaults.standard
    
    enum Keys  {
     static let favorites = "favorites"
    }
    
    
    static func updateFavorites(favorite: Follower, actionType: PersistenceActionType, completed: @escaping (GFError?) -> Void){
        retrieveFavorites { result in
            
            switch result {
                
            case .success(let favorites):
                var retrivedFavorites = favorites
                
                switch actionType {
                case .add:
                    //verificamos si en realidad el array de favoritos lo tiene
                    guard !retrivedFavorites.contains(favorite) else {
                        completed(.alreadyInFavorites)
                        return
                    }
                    retrivedFavorites.append(favorite)

                case .remove:
                    retrivedFavorites.removeAll { $0.login  == favorite.login }
                }
                
                completed(saveFavorites(favorites: retrivedFavorites))
                
            case .failure(let error):
                completed(error)
                
            }
        }
    }
    
    
    
    static func retrieveFavorites(completed: @escaping (Result<[Follower],GFError>)-> Void){
        guard let favoritesData = defaults.object(forKey: Keys.favorites) as? Data else {
            completed(.success([])) // le regresamos el arreglo vacio porque esta seria la primera vez que trata de obetner los favoritos
            return
        }
        
        do{
            let decoder = JSONDecoder()
            let favorites =  try decoder.decode([Follower].self, from: favoritesData)
            completed(.success(favorites))
        }catch{
            completed(.failure(.unableToFavorite))
        }
    }
    
    static func saveFavorites(favorites: [Follower]) -> GFError? {
        
        do{
            let encoder = JSONEncoder()
            let encodedFavorites = try encoder.encode(favorites)
            defaults.set(encodedFavorites, forKey: Keys.favorites)
            return nil
            
        }catch {
            return .unableToSaveFavorites
        }
    }
}
