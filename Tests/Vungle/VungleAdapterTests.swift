//
//  VungleAdapterTests.swift
//  iOS Video Interstitial Advert MediatorTests
//
//  Created by Peter Morris on 07/11/2018.
//  Copyright © 2018 Pete Morris. All rights reserved.
//

import XCTest
@testable import iOS_Video_Interstitial_Advert_Mediator
//swiftlint:disable weak_delegate

class VungleAdapterTests: XCTestCase {
    var adapter: VungleAdapter!
    var mockVungleSDK = MockVungleSDK()
    var delegate = MockNetworkDelegate()
    override func setUp() {
        adapter = VungleAdapter(appID: "123", placementID: "456", vungleSDK: mockVungleSDK)
        adapter.delegate = delegate
    }
    func testConvenienceInitializer() {
        let adapter = VungleAdapter(type: .vungle(appID: "", placementID: ""))
        XCTAssertNotNil(adapter, "VungleAdapter convenience initializer should return object for valid network type")
    }
    func testConvenienceInitializerInvalidCase() {
        let adapter = VungleAdapter(type: .adColony(appID: "", zoneID: ""))
        XCTAssertNil(adapter, "VungleAdapter convenience initializer should return nil for invalid network type")
    }
    func testBeginsInNonReadyState() {
        XCTAssertNil(adapter.ready, "VungleAdapter ready property should begin nil.")
    }
    func testDelegateSetOnInit() {
        XCTAssertNotNil(mockVungleSDK.delegate, "VungleAdapter start should set VungleSDK delegate.")
    }
    func testStartsSDK() {
        XCTAssertTrue(mockVungleSDK.started, "VungleAdapter start should start Vungle SDK")
    }
    func testReadyFalseOnStartException() {
        let mockSDK = getMockVungleSDK(shouldThrowStartException: true)
        let adapter = VungleAdapter(appID: "123", placementID: "456", vungleSDK: mockSDK)
        XCTAssert(
            adapter.ready != nil && adapter.ready! == false,
            "VungleAdapter start should set ready to false on start exception."
        )
    }
    func testRequestAdPendingAdRequestIfReadyNil() {
        adapter.requestAd()
        XCTAssertTrue(adapter.pendingAdRequest, "VungleAdapter requestAd should set pendingAdRequest if ready nil.")
    }
    func testReadyWhenSDKInitialized() {
        mockVungleSDK.delegate?.vungleSDKDidInitialize?()
        XCTAssert(
            adapter.ready != nil && adapter.ready! == true,
            "VungleAdapter should be ready after SDK intitializes"
        )
    }
    func testRequestAdExecutedIfPendingAdRequest() {
        adapter.requestAd()
        mockVungleSDK.delegate?.vungleSDKDidInitialize?()
        XCTAssertTrue(
            mockVungleSDK.loadPlacementCalled,
            "VungleAdapter should requestAd when pendingAdRequest and ready is true."
        )
    }
    func testRequestAdInitializationError() {
        let error = NSError(domain: "", code: 0, userInfo: nil)
        mockVungleSDK.delegate?.vungleSDKFailedToInitializeWithError?(error)
        adapter.requestAd()
        XCTAssertNotNil(
            delegate.error,
            "VungleAdapter request ad should execute delegate error method if SDK does not initialize."
        )
    }
    func testRequestAdLoadsPlacementIfReady() {
        let mockSDK = getMockVungleSDK(shouldStart: true)
        VungleAdapter(appID: "123", placementID: "456", vungleSDK: mockSDK).requestAd()
        XCTAssertTrue(mockSDK.loadPlacementCalled, "VungleAdapter requestAd should loadPlacement if SDK ready")
    }
    func testRequestAdSetsNotReadyOnException() {
        let mockSDK = getMockVungleSDK(shouldStart: true, shouldThrowLoadPlacementException: true)
        let adapter = VungleAdapter(appID: "123", placementID: "456", vungleSDK: mockSDK)
        adapter.requestAd()
        XCTAssert(
            adapter.ready != nil && adapter.ready! == false,
            "VungleAdapter requestAd should set ready false on loading exception."
        )
    }
    func testIsEqualFalse() {
        let adapter1 = VungleAdapter(appID: "", placementID: "")
        let adapter2 = VungleAdapter(appID: "", placementID: "")
        XCTAssertFalse(
            adapter1.isEqual(to: adapter2),
            "VungleAdapter isEqual should return false for another VungleAdapter which is not the same object."
        )
    }
    func testIsEqualTrue() {
        XCTAssertTrue(
            adapter.isEqual(to: adapter),
            "VungleAdapter isEqual should return true for another VungleAdapter which is the same object."
        )
    }
    func testIsEqualFalseWithDifferentClass() {
        let adapter2 = MockVideoAdNetworkAdapter(type: .test)!
        XCTAssertFalse(
            adapter.isEqual(to: adapter2),
            "VungleAdapter isEqual should return false for objects of different class."
        )
    }
    func testPlayabilityUpdateGuardsWhenReadyNil() {
        adapter.vungleAdPlayabilityUpdate(true, placementID: nil, error: nil)
        XCTAssertFalse(delegate.didLoad, "VungleAdapter playabilityUpdate should guard when ready nil.")
    }
    func testPlayabilityUpdateGuardsWhenNotReady() {
        let delegate = MockNetworkDelegate()
        let mockSDK = getMockVungleSDK(shouldStart: true, shouldThrowStartException: true)
        let adapter = VungleAdapter(appID: "", placementID: "", vungleSDK: mockSDK)
        adapter.delegate = delegate
        adapter.vungleAdPlayabilityUpdate(true, placementID: "", error: nil)
        XCTAssertFalse(delegate.didLoad, "VungleAdapter playability update should guard when ready false.")
    }
    func testPlayabilityUpdateCallsDelegate() {
        let delegate = MockNetworkDelegate()
        let mockSDK = getMockVungleSDK(shouldStart: true, shouldThrowStartException: false)
        let adapter = VungleAdapter(appID: "", placementID: "", vungleSDK: mockSDK)
        adapter.delegate = delegate
        adapter.vungleAdPlayabilityUpdate(true, placementID: "", error: nil)
        XCTAssertTrue(
            delegate.didLoad,
            "VungleAdapter playability update should execute delegate didLoad method when ad received."
        )
    }
    func getMockVungleSDK(shouldStart: Bool? = nil,
                          shouldThrowStartException: Bool? = nil,
                          shouldLoadPlacement: Bool? = nil,
                          shouldThrowLoadPlacementException: Bool? = nil) -> MockVungleSDK {
        let mockSDK = MockVungleSDK()
        if let shouldStart = shouldStart {
            mockSDK.shouldStart = shouldStart
        }
        if let shouldThrowStartException = shouldThrowStartException {
            mockSDK.shouldThrowStartException = shouldThrowStartException
        }
        if let shouldLoadPlacement = shouldLoadPlacement {
            mockSDK.shouldLoadPlacement = shouldLoadPlacement
        }
        if let shouldThrowLoadPlacementException = shouldThrowLoadPlacementException {
            mockSDK.shouldThrowLoadPlacementException = shouldThrowLoadPlacementException
        }
        return mockSDK
    }
}