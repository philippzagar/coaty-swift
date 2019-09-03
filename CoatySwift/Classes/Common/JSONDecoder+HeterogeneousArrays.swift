// ! Copyright (c) 2019 Siemens AG. Licensed under the MIT License.
//
//  JSONDecoder+HeterogeneousArrays.swift
//  CoatySwift
//
//

import Foundation

extension JSONDecoder {
    
    /// Decode a heterogeneous list of objects.
    ///
    /// - Parameters:
    ///     - family: The ClassFamily enum type to decode with.
    ///     - data: The data to decode.
    /// - Returns: The list of decoded objects.
    func decode<T: ObjectFamily, U: Decodable>(family: T.Type, from data: Data) throws -> [U] {
        return try self.decode([ClassWrapper<T, U>].self, from: data).compactMap { $0.object }
    }
    
    /// Decode a single object with a type from a ClassFamily.
    ///
    /// - Parameters:
    ///     - family: The ClassFamily enum type to decode with.
    ///     - data: The data to decode.
    /// - Returns: The list of decoded objects.
    func decode<T: ObjectFamily, U: Decodable>(family: T.Type, from data: Data) throws -> U {
        guard let object = try self.decode(ClassWrapper<T, U>.self, from: data).object else {
            let errorMessage = "Could not decode single object with type ClassFamily."
            LogManager.log.error(errorMessage)
            throw CoatySwiftError.DecodingFailure(errorMessage)
        }
        
        return object
    }
    
    func decodeIfPresent<T: ObjectFamily, U: Decodable>(family: T.Type, from data: Data) throws -> U? {
        return try? self.decode(family: T.self, from: data)
    }
}

/// ClassWrapper is a private helper class that allows the decoding of an object based
/// on a ClassFamily.
internal class ClassWrapper<T: ObjectFamily, U: Decodable>: Decodable {
    
    /// The decoded object. Can be any subclass of U.
    let object: U?
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Discriminator.self)
        
        // Try to decode the object with the provided custom type.
        if let customFamily = try? container.decode(T.self, forKey: .objectType) {
            // Decode the object by initialising the corresponding type.
            if let type = customFamily.getType() as? U.Type {
                object = try type.init(from: decoder)
            } else {
                object = nil
            }
            
            // Succesfully decoded as custom type.
            return
        }
        
        // Try to decode the object with the builtin standard Coaty types.
        if let defaultFamily = try? container.decode(CoatyObjectFamily.self, forKey: .objectType) {
            // Decode the object by initialising the corresponding type.
            if let type = defaultFamily.getType() as? U.Type {
                object = try type.init(from: decoder)
            } else {
                object = nil
            }
            
            // Successfully decoded as default type.
            return
        }
        
        // TODO: This parses an object as coreType. We use it for decoding dynamic coaty objects.
        // This should be documented.
        // Try to decode the object with the builtin core coaty types.
        if let defaultFamily = try? container.decode(CoatyObjectFamily.self, forKey: .coreType) {
            // Decode the object by initialising the corresponding type.
            if let type = defaultFamily.getType() as? U.Type {
                object = try type.init(from: decoder)
            } else {
                object = nil
            }
            
            // Successfully decoded as core type.
            return
        }
        
        // Could neither decode as custom nor as default type.
        let errorMessage = "Could not decode class wrapper."
        LogManager.log.error(errorMessage)
        throw CoatySwiftError.DecodingFailure(errorMessage)
    }
}
