import SwiftUI

struct AlbumRowView: View {
    let album: Album
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Album Artwork
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "square.stack")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            
            // Album Info
            VStack(alignment: .leading, spacing: 4) {
                Text(album.title)
                    .font(.headline)
                    .foregroundColor(.primary)
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
                    
                    if album.duration > 0 {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(album.formattedDuration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Source Badge
            Text(album.source.displayName)
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(album.source == .local ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                .foregroundColor(album.source == .local ? .blue : .green)
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
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