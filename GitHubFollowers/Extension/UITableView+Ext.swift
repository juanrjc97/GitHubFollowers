//
//  UITableView+Ext.swift
//  GitHubFollowers
//
//  Created by Juan Jimenez on 12/27/22.
//

import UIKit

extension  UITableView {
    
    func removeExcessCells()  {
        tableFooterView = UIView(frame: .zero )
    }
}
