import SwiftUI

struct SearchTestView: View {
    @State private var searchText = ""
    @State private var searchResults: [Song] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // Apple Music Colors
    private let appleMusicPink = Color(red: 1.0, green: 0.31, blue: 0.42) // #FF4E6B
    private let appleMusicRed = Color(red: 1.0, green: 0.02, blue: 0.21) // #FF0436
    
    var body: some View {
        VStack(spacing: 20) {
            Text("TheAudioDB Search Test")
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                TextField("Enter search term", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Search") {
                    performSearch()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [appleMusicPink, appleMusicRed]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(8)
            }
            .padding(.horizontal)
            
            if isLoading {
                ProgressView("Searching...")
                    .foregroundColor(appleMusicPink)
            } else if let error = errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundColor(.orange)
                    
                    Text("Error")
                        .font(.headline)
                    
                    Text(error)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else if !searchResults.isEmpty {
                List(searchResults, id: \.id) { song in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(song.title)
                            .font(.headline)
                        
                        Text(song.artist)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let album = song.album {
                            Text(album)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("Duration: \(formatDuration(song.duration))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            } else {
                Spacer()
                
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No search results")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Enter a search term and tap Search to find music")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
        }
        .padding()
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoading = false
            
            // Mock results for testing
            searchResults = [
                Song(
                    title: "Bohemian Rhapsody",
                    artist: "Queen",
                    album: "A Night at the Opera",
                    duration: 354,
                    artworkURL: "https://upload.wikimedia.org/wikipedia/en/4/4d/Queen_A_Night_At_The_Opera.png",
                    source: .local,
                    url: "mock://local/bohemian"
                ),
                Song(
                    title: "Another One Bites the Dust",
                    artist: "Queen",
                    album: "The Game",
                    duration: 213,
                    artworkURL: "https://upload.wikimedia.org/wikipedia/en/1/16/Queen_The_Game.png",
                    source: .local,
                    url: "mock://local/dust"
                )
            ]
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
} 