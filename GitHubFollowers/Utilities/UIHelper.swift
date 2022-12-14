//
//  UIHelper.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/14/22.
//

import UIKit

struct UIHelper {
    
    static func createThreeColumnFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
        
        let width                       = view.bounds.width //EL ANCHO DE TODA LA PANTALLA
        let padding: CGFloat            = 12
        let minimumItemSpacing: CGFloat = 10
        let availableWidth              = width - (padding * 2) - (minimumItemSpacing * 2)// OBTENEMOS EL ANCHO DISPONIBLE
        let itemWidth                   = availableWidth / 3 // SE LO DIVIDE PARA 3 PARA SABER CUANTO ESPACIO LE TOCA A CADA ITEM
        
        let flowLayout                  = UICollectionViewFlowLayout()
        flowLayout.sectionInset         = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.itemSize             = CGSize(width: itemWidth, height: itemWidth + 40)
        
        return flowLayout
    }
}

