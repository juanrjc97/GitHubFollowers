//
//  ErrorMessage.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/14/22.
//

import Foundation

enum GFError: String, Error {
    
    case invalidUsername    = "This username created an invalid request. Please try again."
    case unableToComplete   = "Unable to complete your request. Please check your internet connection"
    case invalidResponse    = "Invalid response from the server. Please try again."
    case invalidData        = "The data received from the server was invalid. Please try again."
    case unableToFavorite   = "There was an error retriving the favorites followers list, Please try again"
    case unableToSaveFavorites   = "There was an error saving the favorites followers list, Please try again"
    case alreadyInFavorites = "This user is already in the favorites List."
}
