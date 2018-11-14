//
//  TestDelegates.swift
//  iOS Video Interstitial Advert MediatorTests
//
//  Created by Peter Morris on 09/11/2018.
//  Copyright © 2018 Pete Morris. All rights reserved.
//

import Foundation
//import WaterfallKit
//swiftlint:disable weak_delegate

class TimerTestDelegate {
    var wasInvalidated = false
}

class FactoryTestDelegate {
    var factoryRegisteredType: VideoAdNetworkAdapter.Type?
    var factoryCreateType: VideoAdNetworkAdapter.Type {
        let type: VideoAdNetworkAdapter.Type = !createdFirst ?
            MockVideoAdNetworkAdapter.self : AnotherMockVideoAdNetworkAdapter.self
        createdFirst = true
        return type
    }
    private var createdFirst = false
}

class VideoAdLoaderTestDelegate {
    var adapterShouldDelegate = false
    var adapterShouldFailToInitialize = false
    var adapterPriority = 0
    var adapterDelegateSet = false
    var adapterAdRequested = false
}
