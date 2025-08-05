import SwiftUI

struct LibraryView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    @State private var searchText = ""
    @State private var showAlbums = true // Toggle between albums and songs
    
    var filteredAlbums: [Album] {
        viewModel.getAlbumsBySearch(searchText)
    }
    
    var filteredSongs: [Song] {
        // Get all songs from all albums
        var allSongs: [Song] = []
        for album in viewModel.albums {
            allSongs.append(contentsOf: album.songs)
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            allSongs = allSongs.filter { song in
                song.title.localizedCaseInsensitiveContains(searchText) ||
                song.artist.localizedCaseInsensitiveContains(searchText) ||
                (song.album?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
        
        return allSongs
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Search Bar
            searchBarView
            
            // View Toggle
            viewToggleView
            
            // Content
            if showAlbums {
                albumsGridView
            } else {
                songsListView
            }
        }
        .background(Color.clear)
    }
    
    private var headerView: some View {
        HStack {
            Text("Library")
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text(showAlbums ? "\(filteredAlbums.count) albums" : "\(filteredSongs.count) songs")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var searchBarView: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(showAlbums ? "Search albums or artists..." : "Search songs, artists, or albums...", text: $searchText)
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
    }
    
    private var viewToggleView: some View {
        HStack {
            Text("View:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker("View", selection: $showAlbums) {
                Text("Songs").tag(false)
                Text("Albums").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private var albumsGridView: some View {
        Group {
            if filteredAlbums.isEmpty {
                emptyAlbumsView
            } else {
                albumsList
            }
        }
    }
    
    private var songsListView: some View {
        Group {
            if filteredSongs.isEmpty {
                emptySongsView
            } else {
                songsList
            }
        }
    }
    
    private var emptyAlbumsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No albums found")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("Your album library is empty")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
    
    private var emptySongsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "music.note.list")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No songs found")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("Your song library is empty")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
    
    private var albumsList: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(filteredAlbums) { album in
                    NavigationLink(destination: AlbumDetailView(album: album, viewModel: viewModel)) {
                        AlbumGridView(album: album) {
                            // Navigation handled by NavigationLink
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
    }
    
    private var songsList: some View {
        List {
            ForEach(filteredSongs) { song in
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

struct AlbumGridView: View {
    let album: Album
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Album Artwork
            ZStack {
                if let artworkURL = album.artworkURL {
                    AsyncImage(url: URL(string: artworkURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                }
            }
            .overlay(
                // Play button overlay
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: onTap) {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 8)
                        .padding(.bottom, 8)
                    }
                }
            )
            
            // Album Info
            VStack(alignment: .leading, spacing: 2) {
                Text(album.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(album.artist)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(album.formattedYear)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text("\(album.songCount) songs")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
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
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    LibraryView(viewModel: MusicPlayerViewModel())
} 