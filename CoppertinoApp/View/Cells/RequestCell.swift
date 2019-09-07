//
//  RequestCell.swift
//  CoppertinoApp
//
//  Created by Yura Velko on 9/6/19.
//  Copyright © 2019 Yura Velko. All rights reserved.
//

import UIKit

class RequestCell: UITableViewCell {
    
    
    @IBOutlet weak var requestText: UILabel!
    @IBOutlet weak var date: UILabel!
    
    
    func configureCell(with request: SearchRequest) {
        requestText.text = request.text
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        date.text = formatter.string(from: request.date ?? Date()) // 1:00 PM || 2:34 AM
    }
    
}
