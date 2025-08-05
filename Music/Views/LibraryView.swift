import SwiftUI

struct LibraryView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    @State private var searchText = ""
    @State private var showAlbums = true
    @State private var selectedTab = 0
    
    // Apple Music Colors
    private let appleMusicPink = Color(red: 1.0, green: 0.31, blue: 0.42) // #FF4E6B
    private let appleMusicRed = Color(red: 1.0, green: 0.02, blue: 0.21) // #FF0436
    
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
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                songsListView
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .animation(.easeInOut(duration: 0.3), value: showAlbums)
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Library")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(showAlbums ? "\(filteredAlbums.count) albums" : "\(filteredSongs.count) songs")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Library icon with Apple Music colors
            Image(systemName: "music.note.list")
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
    }
    
    private var searchBarView: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField(showAlbums ? "Search albums or artists..." : "Search songs, artists, or albums...", text: $searchText)
                    .font(.system(size: 16))
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            searchText = ""
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
    }
    
    private var viewToggleView: some View {
        HStack {
            Text("View")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Custom segmented control with Apple Music colors
            HStack(spacing: 0) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showAlbums = false
                    }
                }) {
                    Text("Songs")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(showAlbums ? .secondary : .white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            showAlbums ? AnyShapeStyle(Color.clear) : 
                            AnyShapeStyle(LinearGradient(
                                gradient: Gradient(colors: [appleMusicPink, appleMusicRed]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                        )
                        .cornerRadius(8)
                }
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showAlbums = true
                    }
                }) {
                    Text("Albums")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(showAlbums ? .white : .secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(
                            showAlbums ? 
                            AnyShapeStyle(LinearGradient(
                                gradient: Gradient(colors: [appleMusicPink, appleMusicRed]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )) : AnyShapeStyle(Color.clear)
                        )
                        .cornerRadius(8)
                }
            }
            .background(Color(.systemGray5))
            .cornerRadius(10)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
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
        VStack(spacing: 24) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 60))
                .foregroundColor(appleMusicPink)
                .opacity(0.8)
            
            VStack(spacing: 8) {
                Text("No albums found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Your album library is empty")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
    
    private var emptySongsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(appleMusicPink)
                .opacity(0.8)
            
            VStack(spacing: 8) {
                Text("No songs found")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Your song library is empty")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
    
    private var albumsList: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 20) {
                ForEach(filteredAlbums) { album in
                    NavigationLink(value: album) {
                        AlbumGridView(album: album) {
                            // Navigation handled by NavigationLink
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 0.2), value: filteredAlbums.count)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }
    
    private var songsList: some View {
        List {
            ForEach(filteredSongs) { song in
                SongRowView(
                    song: song,
                    isPlaying: viewModel.currentSong?.id == song.id && viewModel.isPlaying
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.play(song: song)
                    }
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.addToQueue(song)
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

struct AlbumGridView: View {
    let album: Album
    let onTap: () -> Void
    
    // Apple Music Colors
    private let appleMusicPink = Color(red: 1.0, green: 0.31, blue: 0.42) // #FF4E6B
    private let appleMusicRed = Color(red: 1.0, green: 0.02, blue: 0.21) // #FF0436
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Album Artwork
            ZStack {
                if let artworkURL = album.artworkURL {
                    AsyncImage(url: URL(string: artworkURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 160, height: 160)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                }
                
                // Play button overlay with Apple Music colors
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: onTap) {
                            Image(systemName: "play.circle.fill")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.white)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                gradient: Gradient(colors: [appleMusicPink, appleMusicRed]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 40, height: 40)
                                )
                                .shadow(color: appleMusicPink.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                        .padding(.trailing, 12)
                        .padding(.bottom, 12)
                    }
                }
            }
            .shadow(color: appleMusicPink.opacity(0.15), radius: 8, x: 0, y: 4)
            
            // Album Info
            VStack(alignment: .leading, spacing: 6) {
                Text(album.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Text(album.artist)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Text(album.formattedYear)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [appleMusicPink, appleMusicRed]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(4)
                    
                    Text("•")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("\(album.songCount) songs")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [appleMusicPink, appleMusicRed]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal, 4)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                onTap()
            }
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    // Apple Music Colors
    private let appleMusicPink = Color(red: 1.0, green: 0.31, blue: 0.42) // #FF4E6B
    private let appleMusicRed = Color(red: 1.0, green: 0.02, blue: 0.21) // #FF0436
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ? 
                    AnyShapeStyle(LinearGradient(
                        gradient: Gradient(colors: [appleMusicPink, appleMusicRed]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )) : AnyShapeStyle(Color.gray.opacity(0.2))
                )
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    LibraryView(viewModel: MusicPlayerViewModel())
} 