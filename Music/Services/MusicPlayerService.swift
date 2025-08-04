import Foundation
import Combine

class MusicPlayerService: ObservableObject {
    // Singleton instance
    static let shared = MusicPlayerService()
    
    // Published properties for UI binding
    @Published var currentSong: Song?
    @Published var playbackState: PlaybackState = .stopped
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 0.5
    @Published var queue: [Song] = []
    @Published var currentSource: MusicSource = .local
    
    // Private properties
    private var currentPlayer: MusicPlayerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // Strategy pattern: Different players for different sources
    private let localPlayer = LocalMusicPlayer()
    private let spotifyPlayer = SpotifyMusicPlayer()
    
    private init() {
        self.currentPlayer = localPlayer
        setupBindings()
        loadMockData()
    }
    
    private func setupBindings() {
        // Bind current player's publishers to our published properties
        currentPlayer.playbackStatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.playbackState, on: self)
            .store(in: &cancellables)
        
        currentPlayer.currentTimePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentTime, on: self)
            .store(in: &cancellables)
        
        currentPlayer.currentSongPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentSong, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func switchSource(to source: MusicSource) {
        currentSource = source
        
        // Stop current playback
        currentPlayer.stop()
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)
        
        // Switch to new player
        switch source {
        case .local:
            currentPlayer = localPlayer
        case .spotify:
            currentPlayer = spotifyPlayer
        }
        
        // Re-setup bindings
        cancellables.removeAll()
        setupBindings()
    }
    
    func play(song: Song) -> AnyPublisher<Void, Never> {
        return currentPlayer.play(song: song)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func pause() -> AnyPublisher<Void, Never> {
        return currentPlayer.pause()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func resume() -> AnyPublisher<Void, Never> {
        return currentPlayer.resume()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func stop() -> AnyPublisher<Void, Never> {
        return currentPlayer.stop()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func seek(to time: TimeInterval) -> AnyPublisher<Void, Never> {
        return currentPlayer.seek(to: time)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func setVolume(_ newVolume: Float) -> AnyPublisher<Void, Never> {
        volume = newVolume
        return currentPlayer.setVolume(newVolume)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Queue Management
    
    func addToQueue(_ song: Song) {
        queue.append(song)
    }
    
    func removeFromQueue(at index: Int) {
        guard index < queue.count else { return }
        queue.remove(at: index)
    }
    
    func moveInQueue(from source: IndexSet, to destination: Int) {
        queue.move(fromOffsets: source, toOffset: destination)
    }
    
    func playNext() {
        guard let currentSong = currentSong,
              let currentIndex = queue.firstIndex(of: currentSong),
              currentIndex + 1 < queue.count else { return }
        
        let nextSong = queue[currentIndex + 1]
        play(song: nextSong)
    }
    
    func playPrevious() {
        guard let currentSong = currentSong,
              let currentIndex = queue.firstIndex(of: currentSong),
              currentIndex > 0 else { return }
        
        let previousSong = queue[currentIndex - 1]
        play(song: previousSong)
    }
    
    // MARK: - API Integration
    
    private let apiService = MusicAPIService()
    
    private func loadMockData() {
        // Load popular tracks from API
        apiService.getPopularTracks()
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Failed to load tracks: \(error)")
                    }
                },
                receiveValue: { [weak self] tracks in
                    self?.queue = tracks
                }
            )
            .store(in: &cancellables)
    }
} 