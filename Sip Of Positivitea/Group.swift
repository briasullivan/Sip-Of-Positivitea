//
//  Group.swift
//  Sip Of Positivitea
//
//  Created by Bria Sullivan on 4/23/17.
//  Copyright © 2017 Bria Sullivan. All rights reserved.
//

internal class Group {
    internal let id: String
    internal let name: String
    internal var membersById : [String] = []

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}
