import SwiftUI

struct SongRowView: View {
    let song: Song
    let isPlaying: Bool
    let onTap: () -> Void
    
    // Apple Music Colors
    private let appleMusicPink = Color(red: 1.0, green: 0.31, blue: 0.42) // #FF4E6B
    private let appleMusicRed = Color(red: 1.0, green: 0.02, blue: 0.21) // #FF0436
    
    var body: some View {
        HStack(spacing: 16) {
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
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "music.note")
                                .foregroundColor(.gray)
                        )
                }
                
                // Playing indicator overlay with Apple Music colors
                if isPlaying {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [appleMusicPink, appleMusicRed]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 18, y: -18)
                        .shadow(color: appleMusicPink.opacity(0.4), radius: 4, x: 0, y: 2)
                }
            }
            .shadow(color: appleMusicPink.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // Song Info
            VStack(alignment: .leading, spacing: 6) {
                Text(song.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(song.artist)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if let album = song.album {
                    Text(album)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
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
            
            Spacer()
            
            // Source Badge with Apple Music colors
            Text(song.source.displayName)
                .font(.system(size: 10, weight: .bold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    song.source == .local ? 
                    AnyShapeStyle(LinearGradient(
                        gradient: Gradient(colors: [appleMusicPink, appleMusicRed]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )) : AnyShapeStyle(Color.green.opacity(0.15))
                )
                .foregroundColor(song.source == .local ? .white : .green)
                .cornerRadius(6)
            
            // Duration
            Text(formatDuration(song.duration))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: appleMusicPink.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                onTap()
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    VStack(spacing: 16) {
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
    .background(Color(.systemGray6))
} 