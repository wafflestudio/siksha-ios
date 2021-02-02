//
//  Storage.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/02.
//

import Foundation
import Realm
import RealmSwift

class Storage {
    static let shared = Storage() // singleton class
    
    private init() {}
    
    let formatter = DateFormatter()
    
    let realm = try! Realm()
}
