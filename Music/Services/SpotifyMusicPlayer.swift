import Foundation
import Combine

class SpotifyMusicPlayer: MusicPlayerProtocol {
    // Published properties
    @Published private var _playbackState: PlaybackState = .stopped
    @Published private var _currentTime: TimeInterval = 0
    @Published private var _currentSong: Song?
    
    // Protocol properties
    var currentSong: Song? { _currentSong }
    var playbackState: PlaybackState { _playbackState }
    var currentTime: TimeInterval { _currentTime }
    var duration: TimeInterval { _currentSong?.duration ?? 0 }
    
    // Publishers
    var playbackStatePublisher: AnyPublisher<PlaybackState, Never> {
        $_playbackState.eraseToAnyPublisher()
    }
    
    var currentTimePublisher: AnyPublisher<TimeInterval, Never> {
        $_currentTime.eraseToAnyPublisher()
    }
    
    var currentSongPublisher: AnyPublisher<Song?, Never> {
        $_currentSong.eraseToAnyPublisher()
    }
    
    private var timer: Timer?
    
    init() {
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self._playbackState == .playing else { return }
            self._currentTime += 0.1
            if self._currentTime >= self.duration {
                self._playbackState = .stopped
                self._currentTime = 0
            }
        }
    }
    
    func play(song: Song) -> AnyPublisher<Void, Never> {
        return Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            
            // Simulate Spotify API authentication and streaming
            self._playbackState = .loading
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self._currentSong = song
                self._playbackState = .playing
                self._currentTime = 0
                promise(.success(()))
            }
        }.eraseToAnyPublisher()
    }
    
    func pause() -> AnyPublisher<Void, Never> {
        return Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            
            self._playbackState = .paused
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func resume() -> AnyPublisher<Void, Never> {
        return Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            
            self._playbackState = .playing
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func stop() -> AnyPublisher<Void, Never> {
        return Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            
            self._playbackState = .stopped
            self._currentTime = 0
            self._currentSong = nil
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func seek(to time: TimeInterval) -> AnyPublisher<Void, Never> {
        return Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            
            self._currentTime = min(time, self.duration)
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    func setVolume(_ volume: Float) -> AnyPublisher<Void, Never> {
        return Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            
            // Simulate Spotify volume control
            print("Spotify volume set to: \(volume)")
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    deinit {
        timer?.invalidate()
    }
} 