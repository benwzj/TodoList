//
//  realmCategory.swift
//  TodoList
//
//  Created by Ben Wen on 28/12/20.
//

import Foundation
import RealmSwift

class RealmCategory: Object {
    @objc dynamic var name: String = ""
    let items = List<RealmItem>()
}
