//
//  StringExt+TitleCase.swift
//  Meditation
//
//  Created by Zach Strenfel on 2/20/17.
//  Copyright © 2017 Zach Strenfel. All rights reserved.
//

import Foundation

extension String {
     func titleCase() -> String {
        let original = self
        var changed = original.replacingOccurrences(of: ".wav", with: "")
        changed = changed.replacingOccurrences(of: "_", with: " ")
        changed = changed.capitalized
        return changed
    }
}
