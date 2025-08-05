import Foundation

struct Album: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let artist: String
    let year: Int?
    let artworkURL: String?
    let source: MusicSource
    let songs: [Song]
    
    init(id: String = UUID().uuidString,
         title: String,
         artist: String,
         year: Int? = nil,
         artworkURL: String? = nil,
         source: MusicSource,
         songs: [Song] = []) {
        self.id = id
        self.title = title
        self.artist = artist
        self.year = year
        self.artworkURL = artworkURL
        self.source = source
        self.songs = songs
    }
    
    var duration: TimeInterval {
        songs.reduce(0) { $0 + $1.duration }
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var formattedYear: String {
        if let year = year {
            return String(year)
        }
        return "Unknown Year"
    }
    
    var songCount: Int {
        songs.count
    }
} 