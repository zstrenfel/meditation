//
//  DisplayTableViewCell.swift
//  Meditation
//
//  Created by Zach Strenfel on 2/13/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import UIKit

class DisplayTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var optionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()
    
    func setupView() {
        self.addSubview(titleLabel)
        self.addSubview(optionLabel)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[v0(==v1)]-16-[v1]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": titleLabel, "v1": optionLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[v0]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": titleLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[v0]-8-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0": optionLabel]))
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
