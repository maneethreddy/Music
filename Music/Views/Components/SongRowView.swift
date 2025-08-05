import SwiftUI

struct SongRowView: View {
    let song: Song
    let isPlaying: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Album Artwork
            ZStack {
                if let artworkURL = song.artworkURL {
                    AsyncImage(url: URL(string: artworkURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "music.note")
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(.gray)
                        )
                }
                
                // Playing indicator overlay
                if isPlaying {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                        .offset(x: 15, y: -15)
                }
            }
            
            // Song Info
            VStack(alignment: .leading, spacing: 4) {
                Text(song.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if let album = song.album {
                    Text(album)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Source Badge
            Text(song.source.displayName)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(song.source == .local ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                .foregroundColor(song.source == .local ? .blue : .green)
                .cornerRadius(4)
            
            // Duration
            Text(formatDuration(song.duration))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    VStack {
        SongRowView(
            song: Song(
                title: "Bohemian Rhapsody",
                artist: "Queen",
                album: "A Night at the Opera",
                duration: 354,
                artworkURL: "https://upload.wikimedia.org/wikipedia/en/4/4d/Queen_A_Night_At_The_Opera.png",
                source: .local,
                url: "mock://local/bohemian"
            ),
            isPlaying: true,
            onTap: {}
        )
        
        SongRowView(
            song: Song(
                title: "Shape of You",
                artist: "Ed Sheeran",
                album: "÷",
                duration: 233,
                artworkURL: "https://upload.wikimedia.org/wikipedia/en/3/3b/Dark_Side_of_the_Moon.png",
                source: .spotify,
                url: "spotify://track/shape"
            ),
            isPlaying: false,
            onTap: {}
        )
    }
    .padding()
} 