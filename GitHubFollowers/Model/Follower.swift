//
//  Follower.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/14/22.
//

import Foundation

struct Follower: Codable, Hashable {
    var login: String
    var avatarUrl: String
    
    // ASI SE VERIA SI ESCRIBINIMOS NUESTRA PROPIA FUNCION HASH PARA UNA PROPIEDAD EN CONCRETO
//    func hash(int hasher: inout Hasher)  {
//        hasher.combine(login)
//    }
}
