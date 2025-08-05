import SwiftUI

struct QueueView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Queue")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("\(viewModel.queue.count) songs")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Queue List
            if viewModel.queue.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "music.note.list")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No songs in queue")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("Add songs from the library to start listening")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
            } else {
                List {
                    ForEach(Array(viewModel.queue.enumerated()), id: \.element.id) { index, song in
                        SongRowView(
                            song: song,
                            isPlaying: viewModel.currentSong?.id == song.id && viewModel.isPlaying
                        ) {
                            viewModel.play(song: song)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                viewModel.removeFromQueue(at: index)
                            } label: {
                                Label("Remove", systemImage: "trash")
                            }
                        }
                    }
                    .onMove { from, to in
                        viewModel.moveInQueue(from: from, to: to)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .background(Color.clear)
    }
}

#Preview {
    QueueView(viewModel: MusicPlayerViewModel())
} 