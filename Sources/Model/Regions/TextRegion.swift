//
//  TextRegion.swift
//  Ello
//
//  Created by Sean on 2/11/15.
//  Copyright (c) 2015 Ello. All rights reserved.
//

import Foundation

struct TextRegion: Regionable {

    let content:String

    var kind:RegionKind {
        get { return RegionKind.Text }
    }
    
}