//
//  ContentView.swift
//  Music
//
//  Created by Maneeth Reddy on 04/08/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = MusicPlayerViewModel()
    @StateObject private var searchViewModel: SearchViewModel
    @State private var selectedTab = 0
    
    // Apple Music Colors
    private let appleMusicPink = Color(red: 1.0, green: 0.31, blue: 0.42) // #FF4E6B
    private let appleMusicRed = Color(red: 1.0, green: 0.02, blue: 0.21) // #FF0436
    
    init() {
        let musicPlayerViewModel = MusicPlayerViewModel()
        self._viewModel = StateObject(wrappedValue: musicPlayerViewModel)
        self._searchViewModel = StateObject(wrappedValue: SearchViewModel(musicPlayerViewModel: musicPlayerViewModel))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Content Area at Top
                TabView(selection: $selectedTab) {
                    // Search Tab
                    SearchView(searchViewModel: searchViewModel, musicPlayerViewModel: viewModel)
                        .tag(0)
                    
                    // Library Tab
                    LibraryView(viewModel: viewModel)
                        .tag(1)
                    
                    // Queue Tab
                    QueueView(viewModel: viewModel)
                        .tag(2)
                }
                .padding(.bottom, 80) // Add padding for music player height
                
                // Music Player in Middle
                PersistentMusicPlayerView(viewModel: viewModel)
                
                // Tab Bar at Bottom
                HStack(spacing: 0) {
                    TabButton(
                        title: "Search",
                        icon: "magnifyingglass",
                        isSelected: selectedTab == 0,
                        action: { selectedTab = 0 }
                    )
                    
                    TabButton(
                        title: "Library",
                        icon: "music.note.list",
                        isSelected: selectedTab == 1,
                        action: { selectedTab = 1 }
                    )
                    
                    TabButton(
                        title: "Queue",
                        icon: "list.bullet",
                        isSelected: selectedTab == 2,
                        action: { selectedTab = 2 }
                    )
                }
                .background(Color.clear)
                .shadow(radius: 1)
            }
        }
        .navigationDestination(for: Album.self) { album in
            AlbumDetailView(album: album, viewModel: viewModel)
        }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearError() } }
        )) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

struct PersistentMusicPlayerView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    @State private var showNowPlayingSheet = false
    
    // Apple Music Colors
    private let appleMusicPink = Color(red: 1.0, green: 0.31, blue: 0.42) // #FF4E6B
    private let appleMusicRed = Color(red: 1.0, green: 0.02, blue: 0.21) // #FF0436
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar (always visible)
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: appleMusicPink))
                .scaleEffect(x: 1, y: 0.5, anchor: .center)
            
            // Music player content
            HStack(spacing: 8) {
                // Album artwork
                ZStack {
                    if let currentSong = viewModel.currentSong, let artworkURL = currentSong.artworkURL {
                        AsyncImage(url: URL(string: artworkURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "music.note")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                )
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "music.note")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                            )
                    }
                    
                    // Playing indicator overlay
                    if let currentSong = viewModel.currentSong, viewModel.isPlaying {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [appleMusicPink, appleMusicRed]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 12, height: 12)
                            .overlay(
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                            )
                            .offset(x: 12, y: -12)
                    }
                }
                
                // Song info
                VStack(alignment: .leading, spacing: 2) {
                    if let currentSong = viewModel.currentSong {
                        Text(currentSong.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        
                        Text(currentSong.artist)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    } else {
                        Text("No song playing")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Text("Tap to play music")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Controls
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.playPrevious()
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                    .disabled(viewModel.currentSong == nil)
                    
                    Button(action: {
                        viewModel.togglePlayPause()
                    }) {
                        Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title2)
                            .foregroundColor(appleMusicPink)
                    }
                    .disabled(viewModel.currentSong == nil)
                    
                    Button(action: {
                        viewModel.playNext()
                    }) {
                        Image(systemName: "forward.fill")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                    .disabled(viewModel.currentSong == nil)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.clear)
            .shadow(radius: 1)
            .contentShape(Rectangle())
            .onTapGesture {
                if viewModel.currentSong != nil {
                    showNowPlayingSheet = true
                }
            }
        }
        .sheet(isPresented: $showNowPlayingSheet) {
            NowPlayingSheetView(viewModel: viewModel)
        }
    }
}

struct NowPlayingSheetView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var volume: Float = 0.5
    
    // Apple Music Colors
    private let appleMusicPink = Color(red: 1.0, green: 0.31, blue: 0.42) // #FF4E6B
    private let appleMusicRed = Color(red: 1.0, green: 0.02, blue: 0.21) // #FF0436
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with current song info
                if let currentSong = viewModel.currentSong {
                    HStack(spacing: 12) {
                        // Album artwork
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 60, height: 60)
                            
                            if viewModel.isPlaying {
                                Image(systemName: "speaker.wave.2.fill")
                                    .font(.title2)
                                    .foregroundColor(appleMusicPink)
                            } else {
                                Image(systemName: "music.note")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Song info
                        VStack(alignment: .leading, spacing: 2) {
                            Text(currentSong.title)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            
                            Text(currentSong.artist)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        // Control buttons
                        HStack(spacing: 16) {
                            Button(action: {}) {
                                Image(systemName: "heart")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                            }
                            
                            Button(action: {}) {
                                Image(systemName: "ellipsis")
                                    .font(.title3)
                                    .foregroundColor(.gray)
                            }
                            
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
                                Image(systemName: "infinity")
                                    .font(.title3)
                                    .foregroundColor(appleMusicPink)
                                    .background(appleMusicPink.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding()
                    .background(Color.clear)
                }
                
                // Continue Playing Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Continue Playing")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Text("Autoplaying similar music")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // Queue/Continue Playing List
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(viewModel.queue.enumerated()), id: \.element.id) { index, song in
                                ContinuePlayingRowView(
                                    song: song,
                                    isCurrentSong: viewModel.currentSong?.id == song.id,
                                    isPlaying: viewModel.currentSong?.id == song.id && viewModel.isPlaying,
                                    onTap: {
                                        viewModel.play(song: song)
                                    },
                                    onAddToQueue: {
                                        // Song is already in queue, so this would add it again or move it
                                        viewModel.addToQueue(song)
                                    }
                                )
                            }
                        }
                    }
                }
                
                // Progress and Controls
                VStack(spacing: 16) {
                    // Progress bar
                    VStack(spacing: 8) {
                        ProgressView(value: viewModel.progress)
                            .progressViewStyle(LinearProgressViewStyle(tint: appleMusicPink))
                        
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
                    
                    // Main controls
                    HStack(spacing: 40) {
                        Button(action: {
                            viewModel.playPrevious()
                        }) {
                            Image(systemName: "backward.fill")
                                .font(.title)
                                .foregroundColor(.primary)
                        }
                        
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
                        
                        Button(action: {
                            viewModel.playNext()
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.title)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    // Volume control
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
                    .padding(.horizontal)
                    
                    // Additional controls
                    HStack(spacing: 30) {
                        Button(action: {}) {
                            Image(systemName: "quote.bubble")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "airplayaudio")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {}) {
                            Image(systemName: "list.bullet")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom)
                }
                .background(Color.clear)
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            #endif
        }
    }
}

struct ContinuePlayingRowView: View {
    let song: Song
    let isCurrentSong: Bool
    let isPlaying: Bool
    let onTap: () -> Void
    let onAddToQueue: () -> Void
    
    // Apple Music Colors
    private let appleMusicPink = Color(red: 1.0, green: 0.31, blue: 0.42) // #FF4E6B
    private let appleMusicRed = Color(red: 1.0, green: 0.02, blue: 0.21) // #FF0436
    
    var body: some View {
        HStack(spacing: 12) {
            // Album artwork
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                if isCurrentSong && isPlaying {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.title3)
                        .foregroundColor(appleMusicPink)
                } else {
                    Image(systemName: "music.note")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            
            // Song info
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isCurrentSong ? appleMusicPink : .primary)
                    .lineLimit(1)
                
                Text(song.artist)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Progress indicator for current song
            if isCurrentSong {
                ProgressView(value: 0.3) // This would be actual progress
                    .progressViewStyle(LinearProgressViewStyle(tint: appleMusicPink))
                    .frame(width: 60)
            }
            
            // Add to queue button
            Button(action: onAddToQueue) {
                Image(systemName: "plus.circle")
                    .font(.title3)
                    .foregroundColor(appleMusicPink)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(isCurrentSong ? appleMusicPink.opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    // Apple Music Colors
    private let appleMusicPink = Color(red: 1.0, green: 0.31, blue: 0.42) // #FF4E6B
    private let appleMusicRed = Color(red: 1.0, green: 0.02, blue: 0.21) // #FF0436
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? appleMusicPink : .gray)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? appleMusicPink : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
    }
}

#Preview {
    ContentView()
}
