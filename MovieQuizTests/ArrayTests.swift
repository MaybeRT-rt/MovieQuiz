//
//  ArrayTests.swift
//  MovieQuiz
//
//  Created by Liz-Mary on 31.10.2024.
//


import Foundation
import XCTest
@testable import MovieQuiz

func testGetValueInRange() throws {
    // Given
    let array = [1, 1, 2, 3, 5]
    
    // When
    let value = array[safe: 2]
    
    //Then
    XCTAssertNotNil(value)
    XCTAssertEqual(value, 2)
}

func testGetValueOutOfRange() throws {
    // Given
    let array = [1, 1, 2, 3, 5]
    
    // When
    let value = array[safe: 20]
    
    XCTAssertNil(value)
}
