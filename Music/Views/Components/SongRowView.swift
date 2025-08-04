import SwiftUI

struct SongRowView: View {
    let song: Song
    let isPlaying: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Album Artwork
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                if isPlaying {
                    Image(systemName: "speaker.wave.2.fill")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "music.note")
                        .foregroundColor(.gray)
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
                source: .spotify,
                url: "spotify://track/shape"
            ),
            isPlaying: false,
            onTap: {}
        )
    }
    .padding()
} 