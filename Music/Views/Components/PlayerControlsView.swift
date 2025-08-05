import SwiftUI

struct PlayerControlsView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    @State private var volume: Float = 0.5
    
    // Apple Music Colors
    private let appleMusicPink = Color(red: 1.0, green: 0.31, blue: 0.42) // #FF4E6B
    private let appleMusicRed = Color(red: 1.0, green: 0.02, blue: 0.21) // #FF0436
    
    var body: some View {
        VStack(spacing: 20) {
            // Progress Bar
            VStack(spacing: 8) {
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: appleMusicPink))
                
                HStack {
                    Text(formatTime(viewModel.currentTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatTime(viewModel.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Main Controls
            HStack(spacing: 40) {
                Button(action: {
                    viewModel.playPrevious()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                .disabled(viewModel.currentSong == nil)
                
                Button(action: {
                    viewModel.togglePlayPause()
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [appleMusicPink, appleMusicRed]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .disabled(viewModel.currentSong == nil)
                
                Button(action: {
                    viewModel.playNext()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title)
                        .foregroundColor(.primary)
                }
                .disabled(viewModel.currentSong == nil)
            }
            
            // Volume Control
            HStack(spacing: 12) {
                Image(systemName: "speaker.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Slider(value: $volume, in: 0...1)
                    .accentColor(appleMusicPink)
                
                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Additional Controls
            HStack(spacing: 30) {
                Button(action: {}) {
                    Image(systemName: "shuffle")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                Button(action: {}) {
                    Image(systemName: "repeat")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                Button(action: {}) {
                    Image(systemName: "heart")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    PlayerControlsView(viewModel: MusicPlayerViewModel())
        .previewLayout(.sizeThatFits)
} 