//
//  RealmData.swift
//  TodoList
//
//  Created by Ben Wen on 28/12/20.
//

import Foundation
import RealmSwift

class RealmData: Object{
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = 14
}
