//
//  Counter+Actor.swift
//  AsynAwait
//
//  Created by trungnghia on 12/03/2023.
//

import Foundation

actor NewCounter {
    
    private(set) var count = 0
    
    func addCount() {
        count += 1
    }
}
