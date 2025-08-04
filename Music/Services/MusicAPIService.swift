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
            .decode(type: AudioDBResponse.self, decoder: JSONDecoder())
            .map { response in
                response.tracks?.map { track in
                    Song(
                        title: track.strTrack ?? "Unknown Track",
                        artist: track.strArtist ?? "Unknown Artist",
                        album: track.strAlbum,
                        duration: TimeInterval(track.intDuration ?? 0),
                        artworkURL: track.strTrackThumb,
                        source: .local,
                        url: "mock://local/\(track.idTrack ?? UUID().uuidString)"
                    )
                } ?? []
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
}

// MARK: - Response Models

struct AudioDBResponse: Codable {
    let tracks: [AudioDBTrack]?
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