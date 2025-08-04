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
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Library Tab
            NavigationView {
                LibraryView(viewModel: viewModel)
                    .navigationTitle("Music Library")
            }
            .tabItem {
                Image(systemName: "music.note.list")
                Text("Library")
            }
            .tag(0)
            
            // Queue Tab
            NavigationView {
                QueueView(viewModel: viewModel)
                    .navigationTitle("Queue")
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Queue")
            }
            .tag(1)
            
            // Now Playing Tab
            NavigationView {
                NowPlayingView(viewModel: viewModel)
                    .navigationTitle("Now Playing")
            }
            .tabItem {
                Image(systemName: "play.circle")
                Text("Now Playing")
            }
            .tag(2)
        }
        .overlay(
            // Mini Player at bottom
            VStack {
                Spacer()
                MiniPlayerView(viewModel: viewModel)
            }
        )
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

struct MiniPlayerView: View {
    @ObservedObject var viewModel: MusicPlayerViewModel
    
    var body: some View {
        if let currentSong = viewModel.currentSong {
            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: viewModel.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(x: 1, y: 0.5, anchor: .center)
                
                // Mini player content
                HStack(spacing: 12) {
                    // Album artwork
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                        
                        if viewModel.isPlaying {
                            Image(systemName: "speaker.wave.2.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        } else {
                            Image(systemName: "music.note")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    // Song info
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currentSong.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        
                        Text(currentSong.artist)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
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
                        
                        Button(action: {
                            viewModel.togglePlayPause()
                        }) {
                            Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }
                        
                        Button(action: {
                            viewModel.playNext()
                        }) {
                            Image(systemName: "forward.fill")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(uiColor: .systemBackground))
                .shadow(radius: 2)
            }
        }
    }
}

#Preview {
    ContentView()
}
