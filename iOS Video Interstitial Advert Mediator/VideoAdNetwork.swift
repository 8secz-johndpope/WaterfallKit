//
//  VideoAdNetwork.swift
//  iOS Video Interstitial Advert Mediator
//
//  Created by Peter Morris on 29/10/2018.
//  Copyright © 2018 Pete Morris. All rights reserved.
//

import Foundation

/// Used to instantiate `VideoAdNetwork` instances.
protocol VideoAdNetworkFactory {
    /**
     Instantiates and returns a concrete `VideoAdNetwork` object using the `NetworkType` it
     receives as an argument.
     
     - Parameters:
     - type: The `NetworkType` to instantiate a `VideoAdNetwork` object for
     - Returns: An object conforming to `VideoAdNetwork`.
     */
    func createAdNetwork(type: VideoAdNetworkSettings.NetworkType) -> VideoAdNetwork
}

extension VideoAdNetworkFactory {
    func createAdNetwork(type: VideoAdNetworkSettings.NetworkType) -> VideoAdNetwork {
        switch type {
        case let .adColony(appID, zoneID):
            return AdColonyVideoAdNetwork(appID: appID, zoneID: zoneID)
        case let .admob(appID, adUnitID):
            return AdMobVideoAdNetwork(appID: appID, adUnitID: adUnitID)
        case let .appLovin(sdkKey):
            return AppLovinVideoAdNetwork(sdkKey: sdkKey)
        case let .chartboost(appID, appSignature):
            return ChartboostVideoAdNetwork(appID: appID, appSignature: appSignature)
        case let .vungle(appID, placementID):
            return VungleVideoAdNetwork(appID: appID, placementID: placementID)
        }
    }
}

/// Used to instantiate `VideoAdNetwork` instances for interstitatial video ads.
class InterstitialVideoAdNetworkFactory: VideoAdNetworkFactory { }

/// Used to represent a video ad network
protocol VideoAdNetwork {
    /// The object that acts as the delegate of the `VideoAdNetwork`.
    var delegate: VideoAdNetworkDelegate? { get set }
    /// The priority of the network for display purposes
    var priority: Int { get set }
    /**
     Sends a request to the ad network for a advert.
     */
    func requestAd()
    /**
     Tests `anotherAdNetwork` to see if it is the same object as `self`.
     
     - Parameters:
     - anotherAdNetwork: The `VideoAdNetwork` to compare.
     - Returns: `true` is anotherAdNetwork is the same ad network as `self`, `false` otherwise.
     */
    func isEqual(to anotherAdNetwork: VideoAdNetwork) -> Bool
}

/// Used to add timeout functionality to a video ad network
protocol TimeOutableVideoAdNetwork: class, VideoAdNetwork {
    /// The timer used to timeout the request
    var timeoutTimer: TimeOutTimer { get }
    /// Called when the timeout timer fires
    func timeOut()
}

/// Default implementation for TimeOutable
extension TimeOutableVideoAdNetwork {
    /// The Error domain for a timeout error.
    private var timeOutError: String {
        return "RequestTimedOutErrorDomain"
    }
    /// Notifies the delegate that the timeout has occured
    func timeOut() {
        let error = NSError(domain: timeOutError, code: -1, userInfo: nil)
        delegate?.adNetwork(self, didFailToLoad: error)
    }
}

/// Provides callbacks for AdNetwork request events.
protocol VideoAdNetworkDelegate: class {
    /**
     Executed when the ad network request is fulfilled.
     
     - Parameters:
     - adNetwork: The `VideoAdNetwork` responsible for the callback.
     - ad: A `VideoAd` object ready for display.
     */
    func adNetwork(_ adNetwork: VideoAdNetwork, didLoad advert: VideoAd)
    /**
     Executed when the ad network request either fails, or is unfulfilled.
     
     - Parameters:
     - adNetwork: The `VideoAdNetwork` responsible for the callback.
     - error: An `Error` representing the problem that occured.
     */
    func adNetwork(_ adNetwork: VideoAdNetwork, didFailToLoad error: Error)
}

/// Used to add functionality to `Array` where its elements are `VideoAdNetwork` objects.
extension Array where Element == VideoAdNetwork {
    /**
     Removes the first instance of `network`.

     - Parameters:
     - network: The `VideoAdNetwork` to remove the first instance of.
     */
    func removing(network: VideoAdNetwork) -> Array {
        return filter { !$0.isEqual(to: network) }
    }
}
