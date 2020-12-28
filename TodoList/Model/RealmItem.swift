//
//  realmItem.swift
//  TodoList
//
//  Created by Ben Wen on 28/12/20.
//

import Foundation
import RealmSwift

class RealmItem: Object {
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    var parentCategory = LinkingObjects(fromType: RealmCategory.self, property: "items")
}
