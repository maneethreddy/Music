import Foundation
import Combine

class MusicPlayerViewModel: ObservableObject {
    @Published var currentSong: Song?
    @Published var playbackState: PlaybackState = .stopped
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 0.5
    @Published var queue: [Song] = []
    @Published var currentSource: MusicSource = .local
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let musicPlayerService = MusicPlayerService.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupBindings()
    }
    
    private func setupBindings() {
        // Bind service properties to ViewModel
        musicPlayerService.$currentSong
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentSong, on: self)
            .store(in: &cancellables)
        
        musicPlayerService.$playbackState
            .receive(on: DispatchQueue.main)
            .assign(to: \.playbackState, on: self)
            .store(in: &cancellables)
        
        musicPlayerService.$currentTime
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentTime, on: self)
            .store(in: &cancellables)
        
        musicPlayerService.$duration
            .receive(on: DispatchQueue.main)
            .assign(to: \.duration, on: self)
            .store(in: &cancellables)
        
        musicPlayerService.$volume
            .receive(on: DispatchQueue.main)
            .assign(to: \.volume, on: self)
            .store(in: &cancellables)
        
        musicPlayerService.$queue
            .receive(on: DispatchQueue.main)
            .assign(to: \.queue, on: self)
            .store(in: &cancellables)
        
        musicPlayerService.$currentSource
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentSource, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func switchSource(to source: MusicSource) {
        musicPlayerService.switchSource(to: source)
    }
    
    func play(song: Song) {
        isLoading = true
        errorMessage = nil
        
        musicPlayerService.play(song: song)
            .sink(receiveValue: { [weak self] _ in
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
    
    func togglePlayPause() {
        switch playbackState {
        case .playing:
            pause()
        case .paused, .stopped:
            if let song = currentSong {
                play(song: song)
            }
        case .loading:
            break
        }
    }
    
    func pause() {
        musicPlayerService.pause()
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func stop() {
        musicPlayerService.stop()
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func seek(to time: TimeInterval) {
        musicPlayerService.seek(to: time)
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func setVolume(_ newVolume: Float) {
        volume = newVolume
        musicPlayerService.setVolume(newVolume)
            .sink(receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    func playNext() {
        musicPlayerService.playNext()
    }
    
    func playPrevious() {
        musicPlayerService.playPrevious()
    }
    
    func addToQueue(_ song: Song) {
        musicPlayerService.addToQueue(song)
    }
    
    func removeFromQueue(at index: Int) {
        musicPlayerService.removeFromQueue(at: index)
    }
    
    func moveInQueue(from source: IndexSet, to destination: Int) {
        musicPlayerService.moveInQueue(from: source, to: destination)
    }
    
    // MARK: - Computed Properties
    
    var formattedCurrentTime: String {
        formatTime(currentTime)
    }
    
    var formattedDuration: String {
        formatTime(duration)
    }
    
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    var isPlaying: Bool {
        playbackState == .playing
    }
    
    var canPlay: Bool {
        currentSong != nil && playbackState != .loading
    }
    
    var canPause: Bool {
        playbackState == .playing
    }
    
    var canStop: Bool {
        playbackState == .playing || playbackState == .paused
    }
    
    // MARK: - Helper Methods
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func clearError() {
        errorMessage = nil
    }
} 