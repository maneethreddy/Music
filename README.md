# Music Player Service - iOS Assignment

A comprehensive music player application that demonstrates advanced iOS development concepts including design patterns, MVVM architecture, and Combine framework.

## 🎯 Challenge 1: Design Patterns - Music Player Service

This implementation showcases a flexible music player system that can play songs from different sources (local files, streaming services) with a unified interface, demonstrating core design patterns and modern iOS development practices.

## 🏗️ Architecture Overview

### Design Patterns Implemented

1. **Strategy Pattern**: Different music sources (Local, Spotify) implement the same `MusicPlayerProtocol`
2. **Singleton Pattern**: `MusicPlayerService` ensures only one player instance exists
3. **Observer Pattern**: Combine publishers notify UI components about playback changes
4. **MVVM Architecture**: Clear separation between Model, View, and ViewModel layers

### Key Features

- ✅ **Multiple Music Sources**: Support for Local files and Spotify (mock)
- ✅ **Unified Interface**: All sources use the same protocol
- ✅ **Playback Control**: Play, pause, skip, previous functionality
- ✅ **State Management**: Maintains current playback state
- ✅ **Queue Management**: Add, remove, reorder songs
- ✅ **State Notifications**: Real-time UI updates via Combine
- ✅ **Single Player Instance**: Proper audio session management
- ✅ **Progress Updates**: Current time, duration tracking
- ✅ **Volume Control**: Adjustable volume levels

## 📱 App Structure

### Models
- `Song.swift`: Data model for music tracks
- `PlaybackState.swift`: Enum for player states
- `MusicSource.swift`: Enum for different music sources

### Services
- `MusicPlayerProtocol.swift`: Strategy pattern interface
- `LocalMusicPlayer.swift`: Local file player implementation
- `SpotifyMusicPlayer.swift`: Mock Spotify player implementation
- `MusicPlayerService.swift`: Singleton service managing all players

### ViewModels
- `MusicPlayerViewModel.swift`: Main ViewModel with business logic

### Views
- `ContentView.swift`: Main app with tab navigation
- `LibraryView.swift`: Music library with filtering
- `QueueView.swift`: Playlist queue management
- `NowPlayingView.swift`: Current song display
- `PlayerControlsView.swift`: Playback controls
- `SongRowView.swift`: Reusable song list item
- `MiniPlayerView.swift`: Compact player overlay

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Installation
1. Clone the repository
2. Open `Music.xcodeproj` in Xcode
3. Build and run the project on a simulator or device

### Usage
1. **Library Tab**: Browse all available songs, filter by source
2. **Queue Tab**: Manage your playlist, reorder songs
3. **Now Playing Tab**: View current song, switch music sources
4. **Mini Player**: Quick controls at the bottom of the screen

## 🎨 UI Features

### Modern Design
- Clean, intuitive interface following iOS design guidelines
- Tab-based navigation for easy access to different features
- Responsive layout that works on all device sizes
- Smooth animations and transitions

### Interactive Elements
- Swipe actions for quick queue management
- Drag-and-drop reordering in queue
- Source filtering with chips
- Real-time progress updates
- Volume slider with visual feedback

## 🔧 Technical Implementation

### Combine Framework
- Reactive programming for state management
- Publishers and subscribers for data binding
- Automatic UI updates when state changes
- Error handling with proper error propagation

### MVVM Architecture
- **Model**: Data structures and business logic
- **View**: SwiftUI views for UI presentation
- **ViewModel**: State management and user interactions

### Design Patterns in Action

#### Strategy Pattern
```swift
protocol MusicPlayerProtocol {
    func play(song: Song) -> AnyPublisher<Void, Error>
    func pause() -> AnyPublisher<Void, Error>
    // ... other methods
}

class LocalMusicPlayer: MusicPlayerProtocol { /* implementation */ }
class SpotifyMusicPlayer: MusicPlayerProtocol { /* implementation */ }
```

#### Singleton Pattern
```swift
class MusicPlayerService: ObservableObject {
    static let shared = MusicPlayerService()
    private init() { /* setup */ }
}
```

#### Observer Pattern
```swift
@Published var playbackState: PlaybackState = .stopped
@Published var currentTime: TimeInterval = 0
// UI automatically updates when these change
```

## 📊 State Management

### Playback States
- `stopped`: No song playing
- `playing`: Currently playing
- `paused`: Playback paused
- `loading`: Loading song

### Data Flow
1. User interacts with UI
2. ViewModel processes action
3. Service executes command
4. State changes published via Combine
5. UI automatically updates

## 🎵 Music Sources

### Local Files
- Simulates local music library
- Fast loading times
- Full control over playback

### Spotify (Mock)
- Simulates streaming service
- Longer loading times (2 seconds)
- Different authentication flow

## 🔄 Queue Management

### Features
- Add songs to queue
- Remove songs with swipe actions
- Reorder songs with drag-and-drop
- Play next/previous functionality
- Queue persistence during app session

## 🛠️ Error Handling

### Comprehensive Error Management
- Network errors for streaming services
- File access errors for local files
- User-friendly error messages
- Graceful degradation when errors occur

## 📈 Performance Optimizations

### Efficient Updates
- Combine publishers for reactive updates
- Minimal UI redraws
- Efficient memory management
- Background processing for heavy operations

## 🧪 Testing Considerations

### Testable Architecture
- ViewModels are fully testable without UI dependencies
- Services can be mocked for unit testing
- Clear separation of concerns enables isolated testing
- Combine publishers can be tested independently

## 🔮 Future Enhancements

### Potential Improvements
- Real Spotify API integration
- Background audio playback
- Audio visualization
- Equalizer settings
- Playlist management
- Offline caching
- Cross-device sync

## 📝 Code Quality

### Best Practices
- Clean, readable code with proper documentation
- Consistent naming conventions
- Proper error handling
- Memory management with weak references
- Separation of concerns
- Reusable components

## 🎯 Assignment Requirements Met

✅ **Multiple Music Sources**: Local and Spotify implementations  
✅ **Unified Interface**: Common protocol for all sources  
✅ **Playback Control**: Complete control functionality  
✅ **State Management**: Comprehensive state handling  
✅ **Queue Management**: Full queue operations  
✅ **State Notifications**: Real-time UI updates  
✅ **Single Player Instance**: Singleton pattern implementation  
✅ **MVVM + Combine**: Modern architecture implementation  

## 📄 License

This project is created for educational purposes as part of an iOS development assignment.

---

**Note**: This is a demonstration project with mock data. In a production environment, you would integrate with real music APIs and implement proper audio file handling. 