import Foundation
import Observation

@Observable
final class AppSession {
    var isLoggedIn = false
    var onboardingCompleted = false
}
