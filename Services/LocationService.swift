import CoreLocation
import Foundation

protocol LocationServiceProtocol {
    func requestCurrentLocation() async throws -> CLLocationCoordinate2D
}

final class LocationService: NSObject, CLLocationManagerDelegate, LocationServiceProtocol {
    private let locationManager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    override init() {
        super.init()
        locationManager.delegate = self
    }

    func requestCurrentLocation() async throws -> CLLocationCoordinate2D {
        let status = locationManager.authorizationStatus

        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        locationManager.requestLocation()

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let coordinate = locations.first?.coordinate {
            continuation?.resume(returning: coordinate)
        } else {
            continuation?.resume(throwing: NSError(domain: "LocationService", code: 0))
        }
        continuation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
