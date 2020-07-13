//
//  AnyCache.swift
//  MessageDemo
//
//  Created by Thinkpower on 2020/1/7.
//  Copyright © 2020 Apple. All rights reserved.
//

import Foundation

final class Cache<Key: Hashable, Value> {
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval
    private let keyTracker = KeyTracker()
    
    init(dateProvider: @escaping () -> Date = Date.init,
         entryLifetime: TimeInterval = 12 * 60 * 60,
         maximumEntryCount: Int = 50) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
        
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
    }
    
    func insert(_ value: Value, forKey key: Key) {
        let date = dateProvider().addingTimeInterval(entryLifetime)
        let entry = Entry(key: key, value: value, expirationDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        
        // notify the keyTracker whenever a key was added.
        keyTracker.keys.insert(key)
    }
    
    func value(forKey key: Key) -> Value? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }
        guard dateProvider() < entry.expirationDate else {
            // Discard values that have expired
            removeValue(forKey: key)
            return nil
        }
        return entry.value
    }
    
    func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
}


// MARK: - extension with WrappedKey
private extension Cache {
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else { return false }
            return value.key == key
        }
    }
}

// MARK: - extension with Entry
private extension Cache {
    final class Entry {
        let key: Key
        let value: Value
        let expirationDate: Date
        
        init(key: Key, value: Value, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}

// MARK: - extension with subscript use
extension Cache {
    subscript(key: Key) -> Value? {
        get { return value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nill was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }
            
            insert(value, forKey: key)
        }
    }
}

// MARK: - extension with KeyTracker
private extension Cache {
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()
        
        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
            guard let entry = obj as? Entry else { return }
            
            keys.remove(entry.key)
        }
    }
}

// MARK: - extension with Entry to conform Codable use.
extension Cache.Entry: Codable where Key: Codable, Value: Codable { }

// MARK: - extension with utility methods for Cache
private extension Cache {
    
    func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        
        keyTracker.keys.insert(entry.key)
    }
    
    func entry(forKey key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }
        guard dateProvider() < entry.expirationDate else {
            // Discard values that have expired
            removeValue(forKey: key)
            return nil
        }
        return entry
    }
}

// MARK: - extension with initialize for codable value cache
extension Cache: Codable where Key: Codable, Value: Codable {
        convenience init(from decoder: Decoder) throws {
            self.init()
    
            let container = try decoder.singleValueContainer()
            let entries = try container.decode([Entry].self)
            
            entries.forEach(insert)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(keyTracker.keys.compactMap(entry))
        }
}
