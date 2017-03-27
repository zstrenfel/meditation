//
//  CustomHeaderCellswift
//  Meditation
//
//  Created by Zach Strenfel on 3/27/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

class CustomHeaderCell: UITableViewCell {

    // MARK: - Properties
    
    let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textColor = UIColor.darkGray
        label.text = "Sample Header"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupViews() {
        addSubview(label)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(<=8)-[v0]-(<=8)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": label]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(<=4)-[v0]-(<=4)-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": label]))
        
    }
    

}
