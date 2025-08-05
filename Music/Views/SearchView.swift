import SwiftUI

struct SearchView: View {
    @ObservedObject var searchViewModel: SearchViewModel
    @ObservedObject var musicPlayerViewModel: MusicPlayerViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Search")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !searchViewModel.searchResults.isEmpty {
                    Text("\(searchViewModel.searchResults.count) results")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search songs, artists, or 'Artist - Title'", text: $searchViewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchViewModel.searchText.isEmpty {
                    Button("Clear") {
                        searchViewModel.clearSearch()
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            // Search Tips
            if searchViewModel.searchText.isEmpty && searchViewModel.searchResults.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("Search for Music")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Try searching for:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("• Artist names: 'Eminem'")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("• Song titles: 'Lose Yourself'")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("• Artist - Title: 'Eminem - Lose Yourself'")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
            } else {
                // Search Results
                if searchViewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Searching...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
                } else if let errorMessage = searchViewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                        
                        Text("Search Error")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Try Again") {
                            searchViewModel.performSearch(searchViewModel.searchText)
                        }
                        .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
                } else if searchViewModel.searchResults.isEmpty && !searchViewModel.searchText.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "music.note.slash")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        
                        Text("No Results Found")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("Try different search terms or check your spelling")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.clear)
                } else {
                    List {
                        ForEach(searchViewModel.searchResults, id: \.id) { song in
                            SongRowView(
                                song: song,
                                isPlaying: musicPlayerViewModel.currentSong?.id == song.id && musicPlayerViewModel.isPlaying
                            ) {
                                searchViewModel.playSong(song)
                            }
                            .swipeActions(edge: .trailing) {
                                Button {
                                    musicPlayerViewModel.addToQueue(song)
                                } label: {
                                    Label("Add to Queue", systemImage: "plus")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
        }
        .background(Color.clear)
    }
}

#Preview {
    SearchView(
        searchViewModel: SearchViewModel(),
        musicPlayerViewModel: MusicPlayerViewModel()
    )
} 