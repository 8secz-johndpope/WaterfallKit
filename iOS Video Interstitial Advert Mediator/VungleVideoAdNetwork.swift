//
//  VungleVideoAdNetwork.swift
//  iOS Video Interstitial Advert Mediator
//
//  Created by Peter Morris on 29/10/2018.
//  Copyright © 2018 Pete Morris. All rights reserved.
//

import Foundation

class VungleVideoAdNetwork: VideoAdNetwork {
    weak var delegate: VideoAdNetworkDelegate?
    init(appID: String, placementID: String) {
        print("Vungle initializer")
    }
    func requestAd() {
        print("Vungle Ad Requested")
    }
}