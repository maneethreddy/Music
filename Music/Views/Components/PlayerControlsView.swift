import SwiftUI

struct PlayerControlsView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress Bar
            VStack(spacing: 8) {
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                
                HStack {
                    Text(viewModel.formattedCurrentTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(viewModel.formattedDuration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // Main Controls
            HStack(spacing: 32) {
                // Previous Button
                Button(action: {
                    viewModel.playPrevious()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                .disabled(viewModel.currentSong == nil)
                
                // Play/Pause Button
                Button(action: {
                    viewModel.togglePlayPause()
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 60, height: 60)
                        
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else if viewModel.isPlaying {
                            Image(systemName: "pause.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(!viewModel.canPlay)
                
                // Next Button
                Button(action: {
                    viewModel.playNext()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                .disabled(viewModel.currentSong == nil)
            }
            
            // Volume Control
            HStack(spacing: 12) {
                Image(systemName: "speaker.fill")
                    .foregroundColor(.secondary)
                
                Slider(value: Binding(
                    get: { viewModel.volume },
                    set: { viewModel.setVolume($0) }
                ), in: 0...1)
                .accentColor(.blue)
                
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Stop Button
            Button(action: {
                viewModel.stop()
            }) {
                HStack {
                    Image(systemName: "stop.fill")
                    Text("Stop")
                }
                .font(.subheadline)
                .foregroundColor(.red)
            }
            .disabled(!viewModel.canStop)
        }
        .padding()
    }
}

#Preview {
    PlayerControlsView(viewModel: MusicPlayerViewModel())
        .previewLayout(.sizeThatFits)
} 