import Foundation

struct Song: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let artist: String
    let album: String?
    let duration: TimeInterval
    let artworkURL: String?
    let source: MusicSource
    let url: String
    
    init(id: String = UUID().uuidString, 
         title: String, 
         artist: String, 
         album: String? = nil, 
         duration: TimeInterval, 
         artworkURL: String? = nil, 
         source: MusicSource, 
         url: String) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.duration = duration
        self.artworkURL = artworkURL
        self.source = source
        self.url = url
    }
}

enum MusicSource: String, Codable, CaseIterable {
    case local = "Local"
    case spotify = "Spotify"
    
    var displayName: String {
        return self.rawValue
    }
} 