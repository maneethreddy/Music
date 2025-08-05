//
//  ContentView.swift
//  Music
//
//  Created by Maneeth Reddy on 04/08/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = MusicPlayerViewModel()
    @StateObject private var searchViewModel: SearchViewModel
    @State private var selectedTab = 0
    
    init() {
        let musicPlayerViewModel = MusicPlayerViewModel()
        self._viewModel = StateObject(wrappedValue: musicPlayerViewModel)
        self._searchViewModel = StateObject(wrappedValue: SearchViewModel(musicPlayerViewModel: musicPlayerViewModel))
    }
    
    var body: some View {
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
            .padding(.bottom, 49) // Add padding for music player height
            
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
            .background(Color(uiColor: .systemBackground))
            .shadow(radius: 1)
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar (always visible)
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .scaleEffect(x: 1, y: 0.5, anchor: .center)
            
            // Music player content
            HStack(spacing: 12) {
                // Album artwork
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 50, height: 50)
                    
                    if let currentSong = viewModel.currentSong {
                        if viewModel.isPlaying {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.title3)
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "music.note")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                    } else {
                        Image(systemName: "music.note")
                            .font(.title3)
                            .foregroundColor(.gray)
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
                HStack(spacing: 16) {
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
                            .foregroundColor(.blue)
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
            .padding(.vertical, 12)
            .background(Color(uiColor: .systemBackground))
            .shadow(radius: 1)
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .blue : .gray)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(isSelected ? .blue : .gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    ContentView()
}
