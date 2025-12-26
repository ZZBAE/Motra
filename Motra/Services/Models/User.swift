//
//  User.swift
//  Motra
//
//  Created by Jaeeun Byun on 12/19/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: String
    var email: String
    var nickname: String
    var createdAt: Date
    
    init(id: String = UUID().uuidString, email: String, nickname: String, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.nickname = nickname
        self.createdAt = createdAt
    }
}
