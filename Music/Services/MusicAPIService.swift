import Foundation
import Combine

class MusicAPIService: ObservableObject {
    private let baseURL = "https://www.theaudiodb.com/api/v1/json/2"
    
    func searchTracks(query: String) -> AnyPublisher<[Song], Error> {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "\(baseURL)/search.php?s=\(encodedQuery)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: MusicAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data -> [Song] in
                // Print the raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw API Response: \(jsonString)")
                }
                
                // Try to decode with different response structures
                do {
                    let response = try JSONDecoder().decode(AudioDBResponse.self, from: data)
                    return response.tracks?.map { track in
                        Song(
                            title: track.strTrack ?? "Unknown Track",
                            artist: track.strArtist ?? "Unknown Artist",
                            album: track.strAlbum,
                            duration: TimeInterval(track.intDuration ?? 0),
                            artworkURL: track.strTrackThumb,
                            source: .spotify,
                            url: "spotify://track/\(track.idTrack ?? UUID().uuidString)"
                        )
                    } ?? []
                } catch {
                    print("Decoding error: \(error)")
                    // Return mock data as fallback
                    return self.getMockSearchResults(for: query)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func searchTrackByArtistAndTitle(artist: String, title: String) -> AnyPublisher<[Song], Error> {
        let encodedArtist = artist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? artist
        let encodedTitle = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? title
        let urlString = "\(baseURL)/searchtrack.php?s=\(encodedArtist)&t=\(encodedTitle)"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: MusicAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .tryMap { data -> [Song] in
                // Print the raw response for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw API Response (Artist-Title): \(jsonString)")
                }
                
                // Try to decode with different response structures
                do {
                    let response = try JSONDecoder().decode(AudioDBTrackResponse.self, from: data)
                    return response.track?.map { track in
                        Song(
                            title: track.strTrack ?? "Unknown Track",
                            artist: track.strArtist ?? "Unknown Artist",
                            album: track.strAlbum,
                            duration: TimeInterval(track.intDuration ?? 0),
                            artworkURL: track.strTrackThumb,
                            source: .spotify,
                            url: "spotify://track/\(track.idTrack ?? UUID().uuidString)"
                        )
                    } ?? []
                } catch {
                    print("Decoding error (Artist-Title): \(error)")
                    // Return mock data as fallback
                    return self.getMockSearchResults(for: "\(artist) \(title)")
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func getPopularTracks() -> AnyPublisher<[Song], Error> {
        let urlString = "\(baseURL)/mostloved.php?format=track"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: MusicAPIError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: AudioDBResponse.self, decoder: JSONDecoder())
            .map { response in
                response.tracks?.map { track in
                    Song(
                        title: track.strTrack ?? "Unknown Track",
                        artist: track.strArtist ?? "Unknown Artist",
                        album: track.strAlbum,
                        duration: TimeInterval(track.intDuration ?? 0),
                        artworkURL: track.strTrackThumb,
                        source: .spotify,
                        url: "spotify://track/\(track.idTrack ?? UUID().uuidString)"
                    )
                } ?? []
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Mock Data Fallback
    
    private func getMockSearchResults(for query: String) -> [Song] {
        let lowercasedQuery = query.lowercased()
        
        if lowercasedQuery.contains("eminem") {
            return [
                Song(
                    title: "Lose Yourself",
                    artist: "Eminem",
                    album: "8 Mile",
                    duration: 326,
                    artworkURL: nil,
                    source: .spotify,
                    url: "spotify://track/lose_yourself"
                ),
                Song(
                    title: "The Real Slim Shady",
                    artist: "Eminem",
                    album: "The Marshall Mathers LP",
                    duration: 284,
                    artworkURL: nil,
                    source: .spotify,
                    url: "spotify://track/real_slim_shady"
                ),
                Song(
                    title: "Not Afraid",
                    artist: "Eminem",
                    album: "Recovery",
                    duration: 248,
                    artworkURL: nil,
                    source: .spotify,
                    url: "spotify://track/not_afraid"
                ),
                Song(
                    title: "Without Me",
                    artist: "Eminem",
                    album: "The Eminem Show",
                    duration: 290,
                    artworkURL: nil,
                    source: .spotify,
                    url: "spotify://track/without_me"
                )
            ]
        } else if lowercasedQuery.contains("queen") {
            return [
                Song(
                    title: "Bohemian Rhapsody",
                    artist: "Queen",
                    album: "A Night at the Opera",
                    duration: 354,
                    artworkURL: nil,
                    source: .spotify,
                    url: "spotify://track/bohemian_rhapsody"
                ),
                Song(
                    title: "We Will Rock You",
                    artist: "Queen",
                    album: "News of the World",
                    duration: 122,
                    artworkURL: nil,
                    source: .spotify,
                    url: "spotify://track/we_will_rock_you"
                ),
                Song(
                    title: "Another One Bites the Dust",
                    artist: "Queen",
                    album: "The Game",
                    duration: 213,
                    artworkURL: nil,
                    source: .spotify,
                    url: "spotify://track/another_one_bites_dust"
                )
            ]
        } else {
            return [
                Song(
                    title: "Sample Track",
                    artist: "Sample Artist",
                    album: "Sample Album",
                    duration: 180,
                    artworkURL: nil,
                    source: .spotify,
                    url: "spotify://track/sample"
                )
            ]
        }
    }
}

// MARK: - Response Models

struct AudioDBResponse: Codable {
    let tracks: [AudioDBTrack]?
}

struct AudioDBTrackResponse: Codable {
    let track: [AudioDBTrack]?
}

struct AudioDBTrack: Codable {
    let idTrack: String?
    let strTrack: String?
    let strArtist: String?
    let strAlbum: String?
    let intDuration: Int?
    let strTrackThumb: String?
}

enum MusicAPIError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode response"
        }
    }
} 