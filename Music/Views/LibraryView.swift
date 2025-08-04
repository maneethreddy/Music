import SwiftUI

struct LibraryView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    @State private var selectedSource: MusicSource? = nil
    @State private var searchText = ""
    @State private var isSearching = false
    
    var filteredSongs: [Song] {
        var songs = viewModel.queue
        
        // Filter by source
        if let selectedSource = selectedSource {
            songs = songs.filter { $0.source == selectedSource }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            songs = songs.filter { song in
                song.title.localizedCaseInsensitiveContains(searchText) ||
                song.artist.localizedCaseInsensitiveContains(searchText) ||
                (song.album?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return songs
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Library")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(filteredSongs.count) songs")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search songs, artists, or albums...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                    .foregroundColor(.blue)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
            
            // Source Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    // All Sources
                    FilterChip(
                        title: "All",
                        isSelected: selectedSource == nil,
                        action: { selectedSource = nil }
                    )
                    
                    // Individual Sources
                    ForEach(MusicSource.allCases, id: \.self) { source in
                        FilterChip(
                            title: source.displayName,
                            isSelected: selectedSource == source,
                            action: { selectedSource = source }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            
            // Songs List
            if filteredSongs.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No songs found")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    if selectedSource != nil {
                        Text("Try selecting a different source or add songs to your library")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Your music library is empty")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            } else {
                List {
                    ForEach(filteredSongs, id: \.id) { song in
                        SongRowView(
                            song: song,
                            isPlaying: viewModel.currentSong?.id == song.id && viewModel.isPlaying
                        ) {
                            viewModel.play(song: song)
                        }
                        .swipeActions(edge: .trailing) {
                            Button {
                                viewModel.addToQueue(song)
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
        .background(Color(.systemGroupedBackground))
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    LibraryView(viewModel: MusicPlayerViewModel())
} 