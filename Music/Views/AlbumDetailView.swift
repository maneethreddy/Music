import SwiftUI

struct AlbumDetailView: View {
    let album: Album
    @ObservedObject var viewModel: MusicPlayerViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Text("Album")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    // Add all songs to queue
                    for song in album.songs {
                        viewModel.addToQueue(song)
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            // Album Info
            VStack(spacing: 16) {
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
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                )
                        }
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            )
                    }
                }
                
                // Album Details
                VStack(spacing: 8) {
                    Text(album.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(album.artist)
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    HStack(spacing: 12) {
                        Text(album.formattedYear)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("\(album.songCount) songs")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if album.duration > 0 {
                            Text("•")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(album.formattedDuration)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Source Badge
                    Text(album.source.displayName)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(album.source == .local ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                        .foregroundColor(album.source == .local ? .blue : .green)
                        .cornerRadius(8)
                }
            }
            .padding()
            
            // Play All Button
            if !album.songs.isEmpty {
                Button(action: {
                    if let firstSong = album.songs.first {
                        viewModel.play(song: firstSong)
                        // Add remaining songs to queue
                        for song in album.songs.dropFirst() {
                            viewModel.addToQueue(song)
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                            .font(.title3)
                        
                        Text("Play All")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            
            // Songs List
            VStack(alignment: .leading, spacing: 8) {
                Text("Songs")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .padding(.horizontal)
                
                if album.songs.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "music.note.slash")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("No songs in this album")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(Array(album.songs.enumerated()), id: \.element.id) { index, song in
                            HStack(spacing: 12) {
                                // Track Number
                                Text("\(index + 1)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .frame(width: 30, alignment: .leading)
                                
                                // Song Info
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(song.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .lineLimit(1)
                                    
                                    Text(formatDuration(song.duration))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Play Button
                                Button(action: {
                                    viewModel.play(song: song)
                                }) {
                                    Image(systemName: "play.circle")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
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
        }
                        .background(Color.clear)
        #if os(iOS)
        .navigationBarHidden(true)
        #endif
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    AlbumDetailView(
        album: Album(
            title: "A Night at the Opera",
            artist: "Queen",
            year: 1975,
            source: .local,
            songs: [
                Song(title: "Bohemian Rhapsody", artist: "Queen", album: "A Night at the Opera", duration: 354, source: .local, url: "mock://local/bohemian"),
                Song(title: "You're My Best Friend", artist: "Queen", album: "A Night at the Opera", duration: 180, source: .local, url: "mock://local/best_friend"),
                Song(title: "Love of My Life", artist: "Queen", album: "A Night at the Opera", duration: 213, source: .local, url: "mock://local/love_of_my_life")
            ]
        ),
        viewModel: MusicPlayerViewModel()
    )
} 