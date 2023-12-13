//
//  PlistParser.swift
//  CCC
//
//  Created by Truk Karawawattana on 13/12/2566 BE.
//

import Foundation

struct PlistParser {
    static func getKeysValue() -> Dictionary<String, String>? {
        guard let url = Bundle.main.url(forResource:"keys", withExtension: "plist") else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf:url)
            let dict = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String:String]
            return dict
        } catch {
            print(error)
        }
        return nil
    }
}
