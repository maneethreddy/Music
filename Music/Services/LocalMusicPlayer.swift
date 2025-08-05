import Foundation
import AVFoundation
import Combine

class LocalMusicPlayer: MusicPlayerProtocol {
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    // Published properties
    @Published private var _playbackState: PlaybackState = .stopped
    @Published private var _currentTime: TimeInterval = 0
    @Published private var _currentSong: Song?
    
    // Protocol properties
    var currentSong: Song? { _currentSong }
    var playbackState: PlaybackState { _playbackState }
    var currentTime: TimeInterval { _currentTime }
    var duration: TimeInterval { audioPlayer?.duration ?? 0 }
    
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
    
    init() {
        setupAudioSession()
        startTimer()
    }
    
    private func setupAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        #endif
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self._currentTime = player.currentTime
        }
    }
    
    func play(song: Song) -> AnyPublisher<Void, Never> {
        return Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            
            self._playbackState = .loading
            
            // For demo purposes, we'll create a mock audio player
            // In a real app, you'd load the actual audio file from the song.url
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
            
            self.audioPlayer?.volume = volume
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
    
    deinit {
        timer?.invalidate()
    }
}

enum MusicPlayerError: Error {
    case playerNotAvailable
    case invalidSong
    case playbackFailed
} 