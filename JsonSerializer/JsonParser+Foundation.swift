//
//  JsonSerializer+Foundation.swift
//  JsonSerializer
//
//  Created by Fuji Goro on 2014/09/15.
//  Copyright (c) 2014 Fuji Goro. All rights reserved.
//

import Foundation

public extension Json {
    var anyValue: AnyObject {
        switch self {
        case .object(let ob):
            var mapped: [String : AnyObject] = [:]
            ob.forEach { key, val in
                mapped[key] = val.anyValue
            }
            return mapped as AnyObject
        case .array(let array):
            let mapped = array.map { $0.anyValue }
            return mapped as AnyObject
        case .bool(let bool):
            return bool as AnyObject
        case .number(let number):
            return number as AnyObject
        case .string(let string):
            return string as AnyObject
        case .null:
            return NSNull()
        }
    }
    
    var foundationDictionary: [String : AnyObject]? {
        return anyValue as? [String : AnyObject]
    }
    
    var foundationArray: [AnyObject]? {
        return anyValue as? [AnyObject]
    }
}

extension Json {
    public static func from(_ any: AnyObject) -> Json {
        switch any {
            // If we're coming from foundation, it will be an `NSNumber`.
            //This represents double, integer, and boolean.
        case let number as Double:
            return .number(number)
        case let string as String:
            return .string(string)
        case let object as [String : AnyObject]:
            return from(object)
        case let array as [AnyObject]:
            return .array(array.map(from))
        case _ as NSNull:
            return .null
        default:
            fatalError("Unsupported foundation type")
        }
        return .null
    }
    
    public static func from(_ any: [String : AnyObject]) -> Json {
        var mutable: [String : Json] = [:]
        any.forEach { key, val in
            mutable[key] = .from(val)
        }
        return .from(mutable)
    }
}

extension Json {
    public static func deserialize(_ data: Data) throws -> Json {
        let startPointer = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        let bufferPointer = UnsafeBufferPointer(start: startPointer, count: data.count)
        return try deserialize(bufferPointer)
    }
}
