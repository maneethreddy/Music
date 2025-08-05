import SwiftUI

struct NowPlayingView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Source Selector
            HStack {
                Text("Music Source:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Picker("Source", selection: Binding(
                    get: { viewModel.currentSource },
                    set: { viewModel.switchSource(to: $0) }
                )) {
                    ForEach(MusicSource.allCases, id: \.self) { source in
                        Text(source.displayName).tag(source)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 150)
            }
            .padding(.horizontal)
            
            // Current Song Display
            if let currentSong = viewModel.currentSong {
                VStack(spacing: 12) {
                    // Album Artwork
                    ZStack {
                        if let artworkURL = currentSong.artworkURL {
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
                        
                        // Playing indicator overlay
                        if viewModel.isPlaying {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                )
                                .offset(x: 35, y: -35)
                        }
                    }
                    
                    // Song Info
                    VStack(spacing: 4) {
                        Text(currentSong.title)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        Text(currentSong.artist)
                            .font(.title3)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        if let album = currentSong.album {
                            Text(album)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        // Source Badge
                        Text(currentSong.source.displayName)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(currentSong.source == .local ? Color.blue.opacity(0.2) : Color.green.opacity(0.2))
                            .foregroundColor(currentSong.source == .local ? .blue : .green)
                            .cornerRadius(8)
                    }
                }
                .padding()
            } else {
                // No Song Playing
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.1))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "music.note")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                    }
                    
                    Text("No song playing")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            
            // Playback State
            HStack {
                Text("Status:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(viewModel.playbackState.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(playbackStateColor)
            }
            .padding(.horizontal)
        }
        .background(Color.clear)
        .cornerRadius(16)
        .shadow(radius: 2)
    }
    
    private var playbackStateColor: Color {
        switch viewModel.playbackState {
        case .playing:
            return .green
        case .paused:
            return .orange
        case .stopped:
            return .red
        case .loading:
            return .blue
        }
    }
}

#Preview {
    NowPlayingView(viewModel: MusicPlayerViewModel())
        .previewLayout(.sizeThatFits)
} 