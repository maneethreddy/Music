import Foundation

enum PlaybackState: String, CaseIterable {
    case stopped = "Stopped"
    case playing = "Playing"
    case paused = "Paused"
    case loading = "Loading"
    
    var displayName: String {
        return self.rawValue
    }
} 