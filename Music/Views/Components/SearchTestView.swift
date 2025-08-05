import SwiftUI

struct SearchTestView: View {
    @StateObject private var musicPlayerViewModel = MusicPlayerViewModel()
    @StateObject private var searchViewModel: SearchViewModel
    @State private var testQuery = "Eminem - Lose Yourself"
    
    init() {
        let musicPlayerViewModel = MusicPlayerViewModel()
        self._musicPlayerViewModel = StateObject(wrappedValue: musicPlayerViewModel)
        self._searchViewModel = StateObject(wrappedValue: SearchViewModel(musicPlayerViewModel: musicPlayerViewModel))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("TheAudioDB API Test")
                .font(.title)
                .fontWeight(.bold)
            
            TextField("Test Query", text: $testQuery)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button("Test Search") {
                searchViewModel.searchText = testQuery
            }
            .buttonStyle(.borderedProminent)
            
            if searchViewModel.isLoading {
                ProgressView("Searching...")
            }
            
            if let error = searchViewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            }
            
            if !searchViewModel.searchResults.isEmpty {
                Text("Results (\(searchViewModel.searchResults.count)):")
                    .font(.headline)
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 10) {
                        ForEach(searchViewModel.searchResults, id: \.id) { song in
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
                                Text("Source: \(song.source.displayName)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    SearchTestView()
} 