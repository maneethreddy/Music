import SwiftUI

struct AlbumRowView: View {
    let album: Album
    let onTap: () -> Void
    
    // Apple Music Colors
    private let appleMusicPink = Color(red: 1.0, green: 0.31, blue: 0.42) // #FF4E6B
    private let appleMusicRed = Color(red: 1.0, green: 0.02, blue: 0.21) // #FF0436
    
    var body: some View {
        HStack(spacing: 12) {
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
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "music.note")
                                .font(.title2)
                                .foregroundColor(.gray)
                        )
                }
            }
            
            // Album Info
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                Text(album.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(album.formattedYear)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(album.songCount) songs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Source Badge with Apple Music colors
                Text(album.source.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        album.source == .local ? 
                        AnyShapeStyle(LinearGradient(
                            gradient: Gradient(colors: [appleMusicPink, appleMusicRed]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )) : AnyShapeStyle(Color.green.opacity(0.2))
                    )
                    .foregroundColor(album.source == .local ? .white : .green)
                    .cornerRadius(4)
            }
            
            Spacer()
            
            // Play Button
            Button(action: onTap) {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(appleMusicPink)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .contentShape(Rectangle())
    }
}

#Preview {
    VStack {
        AlbumRowView(
            album: Album(
                title: "A Night at the Opera",
                artist: "Queen",
                year: 1975,
                source: .local,
                songs: [
                    Song(title: "Bohemian Rhapsody", artist: "Queen", album: "A Night at the Opera", duration: 354, source: .local, url: "mock://local/bohemian"),
                    Song(title: "You're My Best Friend", artist: "Queen", album: "A Night at the Opera", duration: 180, source: .local, url: "mock://local/best_friend")
                ]
            ),
            onTap: {}
        )
        
        AlbumRowView(
            album: Album(
                title: "The Dark Side of the Moon",
                artist: "Pink Floyd",
                year: 1973,
                source: .spotify,
                songs: [
                    Song(title: "Time", artist: "Pink Floyd", album: "The Dark Side of the Moon", duration: 421, source: .spotify, url: "spotify://track/time"),
                    Song(title: "Money", artist: "Pink Floyd", album: "The Dark Side of the Moon", duration: 382, source: .spotify, url: "spotify://track/money")
                ]
            ),
            onTap: {}
        )
    }
    .padding()
} 