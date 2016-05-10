//
//  iRegistrationUITests.swift
//  iRegistrationUITests
//
//  Created by Alex on 18/11/15.
//  Copyright © 2015 A2. All rights reserved.
//

import XCTest

class iRegistrationUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFloatConversion() {
////        ￼36.4 Celsius
////        0xFF00016C
////        ￼￼￼￼
////        ￼￼34.79 Celsius
////        0xFE000D97
//        
//        let interface = ThermometerDataDecoder.sharedInstance
//        let f1 = interface.parseFloat32([0x33, 0x33, 0x13, 0x42], offset: 0) // 36.8
//        XCTAssertLessThanOrEqual(f1, 0.0)
//        
//        let f2 = interface.parseFloat32([0x33, 0x33, 0x13, 0x42], offset: 0) // 36.8
//        XCTAssertLessThanOrEqual(f2, 0.0)

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
