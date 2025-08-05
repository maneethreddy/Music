import SwiftUI
import Combine

struct SearchView: View {
    @ObservedObject var searchViewModel: SearchViewModel
    @ObservedObject var musicPlayerViewModel: MusicPlayerViewModel
    
    // Apple Music Colors
    private let appleMusicPink = Color(red: 1.0, green: 0.31, blue: 0.42) // #FF4E6B
    private let appleMusicRed = Color(red: 1.0, green: 0.02, blue: 0.21) // #FF0436
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Search")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Discover new music")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Search icon with Apple Music colors
                Image(systemName: "magnifyingglass")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [appleMusicPink, appleMusicRed]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: appleMusicPink.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 20)
            
            // Search Bar
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16, weight: .medium))
                    
                    TextField("Search for songs, artists, or albums...", text: $searchViewModel.searchText)
                        .font(.system(size: 16))
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !searchViewModel.searchText.isEmpty {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                searchViewModel.clearSearch()
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            
            // Search Results
            if searchViewModel.isLoading {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .foregroundColor(appleMusicPink)
                    
                    Text("Searching...")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if searchViewModel.searchText.isEmpty {
                // Empty State
                VStack(spacing: 24) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 60))
                        .foregroundColor(appleMusicPink)
                        .opacity(0.8)
                    
                    VStack(spacing: 8) {
                        Text("Search for music")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Find your favorite songs, artists, and albums")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 40)
            } else if searchViewModel.searchResults.isEmpty {
                // No Results
                VStack(spacing: 24) {
                    Image(systemName: "magnifyingglass.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                        .opacity(0.6)
                    
                    VStack(spacing: 8) {
                        Text("No results found")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Try searching for something else")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, 40)
            } else {
                // Results List
                List {
                    ForEach(searchViewModel.searchResults) { song in
                        SongRowView(
                            song: song,
                            isPlaying: musicPlayerViewModel.currentSong?.id == song.id && musicPlayerViewModel.isPlaying
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                musicPlayerViewModel.play(song: song)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    musicPlayerViewModel.addToQueue(song)
                                }
                            } label: {
                                Label("Add to Queue", systemImage: "plus")
                            }
                            .tint(appleMusicPink)
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())
                .background(Color.clear)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    SearchView(
        searchViewModel: SearchViewModel(),
        musicPlayerViewModel: MusicPlayerViewModel()
    )
} 