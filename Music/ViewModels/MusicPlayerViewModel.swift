import Foundation
import Combine

class MusicPlayerViewModel: ObservableObject {
    @Published var currentSong: Song?
    @Published var playbackState: PlaybackState = .stopped
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var volume: Float = 0.5
    @Published var queue: [Song] = []
    @Published var albums: [Album] = []
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
        
        // Load sample albums and add sample songs to queue
        loadSampleAlbums()
        addSampleSongsToQueue()
    }
    
    // MARK: - Public Methods
    
    func switchSource(to source: MusicSource) {
        musicPlayerService.switchSource(to: source)
    }
    
    func play(song: Song) {
        isLoading = true
        errorMessage = nil
        
        // Switch to the appropriate source for the song
        switchSource(to: song.source)
        
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
    
    // MARK: - Album Methods
    
    private func loadSampleAlbums() {
        let queenAlbum = Album(
            title: "A Night at the Opera",
            artist: "Queen",
            year: 1975,
            source: .local,
            songs: [
                Song(title: "Bohemian Rhapsody", artist: "Queen", album: "A Night at the Opera", duration: 354, source: .local, url: "mock://local/bohemian"),
                Song(title: "You're My Best Friend", artist: "Queen", album: "A Night at the Opera", duration: 180, source: .local, url: "mock://local/best_friend"),
                Song(title: "Love of My Life", artist: "Queen", album: "A Night at the Opera", duration: 213, source: .local, url: "mock://local/love_of_my_life"),
                Song(title: "39", artist: "Queen", album: "A Night at the Opera", duration: 211, source: .local, url: "mock://local/39")
            ]
        )
        
        let pinkFloydAlbum = Album(
            title: "The Dark Side of the Moon",
            artist: "Pink Floyd",
            year: 1973,
            source: .spotify,
            songs: [
                Song(title: "Time", artist: "Pink Floyd", album: "The Dark Side of the Moon", duration: 421, source: .spotify, url: "spotify://track/time"),
                Song(title: "Money", artist: "Pink Floyd", album: "The Dark Side of the Moon", duration: 382, source: .spotify, url: "spotify://track/money"),
                Song(title: "Us and Them", artist: "Pink Floyd", album: "The Dark Side of the Moon", duration: 468, source: .spotify, url: "spotify://track/us_and_them"),
                Song(title: "Brain Damage", artist: "Pink Floyd", album: "The Dark Side of the Moon", duration: 228, source: .spotify, url: "spotify://track/brain_damage")
            ]
        )
        
        let eminemAlbum = Album(
            title: "The Marshall Mathers LP",
            artist: "Eminem",
            year: 2000,
            source: .spotify,
            songs: [
                Song(title: "The Real Slim Shady", artist: "Eminem", album: "The Marshall Mathers LP", duration: 284, source: .spotify, url: "spotify://track/real_slim_shady"),
                Song(title: "Stan", artist: "Eminem", album: "The Marshall Mathers LP", duration: 404, source: .spotify, url: "spotify://track/stan"),
                Song(title: "The Way I Am", artist: "Eminem", album: "The Marshall Mathers LP", duration: 274, source: .spotify, url: "spotify://track/the_way_i_am"),
                Song(title: "Kill You", artist: "Eminem", album: "The Marshall Mathers LP", duration: 264, source: .spotify, url: "spotify://track/kill_you")
            ]
        )
        
        let beatlesAlbum = Album(
            title: "Abbey Road",
            artist: "The Beatles",
            year: 1969,
            source: .local,
            songs: [
                Song(title: "Come Together", artist: "The Beatles", album: "Abbey Road", duration: 259, source: .local, url: "mock://local/come_together"),
                Song(title: "Something", artist: "The Beatles", album: "Abbey Road", duration: 182, source: .local, url: "mock://local/something"),
                Song(title: "Here Comes the Sun", artist: "The Beatles", album: "Abbey Road", duration: 185, source: .local, url: "mock://local/here_comes_sun"),
                Song(title: "Golden Slumbers", artist: "The Beatles", album: "Abbey Road", duration: 91, source: .local, url: "mock://local/golden_slumbers")
            ]
        )
        
        albums = [queenAlbum, pinkFloydAlbum, eminemAlbum, beatlesAlbum]
    }
    
    func getAlbumsBySource(_ source: MusicSource?) -> [Album] {
        if let source = source {
            return albums.filter { $0.source == source }
        }
        return albums
    }
    
    func getAlbumsBySearch(_ searchText: String) -> [Album] {
        if searchText.isEmpty {
            return albums
        }
        
        return albums.filter { album in
            album.title.localizedCaseInsensitiveContains(searchText) ||
            album.artist.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Sample Data
    
    private func addSampleSongsToQueue() {
        let sampleSongs = [
            Song(title: "Lose Yourself", artist: "Eminem", album: "8 Mile", duration: 326, source: .spotify, url: "spotify://track/lose_yourself"),
            Song(title: "Shape of You", artist: "Ed Sheeran", album: "÷", duration: 233, source: .spotify, url: "spotify://track/shape_of_you"),
            Song(title: "Blinding Lights", artist: "The Weeknd", album: "After Hours", duration: 200, source: .spotify, url: "spotify://track/blinding_lights"),
            Song(title: "Dance Monkey", artist: "Tones and I", album: "The Kids Are Coming", duration: 209, source: .spotify, url: "spotify://track/dance_monkey"),
            Song(title: "Bad Guy", artist: "Billie Eilish", album: "When We All Fall Asleep, Where Do We Go?", duration: 194, source: .spotify, url: "spotify://track/bad_guy"),
            Song(title: "Old Town Road", artist: "Lil Nas X", album: "7", duration: 157, source: .spotify, url: "spotify://track/old_town_road"),
            Song(title: "Someone You Loved", artist: "Lewis Capaldi", album: "Divinely Uninspired to a Hellish Extent", duration: 182, source: .spotify, url: "spotify://track/someone_you_loved"),
            Song(title: "Sunflower", artist: "Post Malone & Swae Lee", album: "Spider-Man: Into the Spider-Verse", duration: 158, source: .spotify, url: "spotify://track/sunflower"),
            Song(title: "Happier", artist: "Marshmello & Bastille", album: "Happier", duration: 214, source: .spotify, url: "spotify://track/happier"),
            Song(title: "Without Me", artist: "Eminem", album: "The Eminem Show", duration: 290, source: .local, url: "mock://local/without_me"),
            Song(title: "The Real Slim Shady", artist: "Eminem", album: "The Marshall Mathers LP", duration: 284, source: .local, url: "mock://local/real_slim_shady"),
            Song(title: "Mockingbird", artist: "Eminem", album: "Encore", duration: 251, source: .local, url: "mock://local/mockingbird"),
            Song(title: "Not Afraid", artist: "Eminem", album: "Recovery", duration: 248, source: .local, url: "mock://local/not_afraid"),
            Song(title: "Rap God", artist: "Eminem", album: "The Marshall Mathers LP 2", duration: 363, source: .local, url: "mock://local/rap_god"),
            Song(title: "Godzilla", artist: "Eminem ft. Juice WRLD", album: "Music to Be Murdered By", duration: 210, source: .local, url: "mock://local/godzilla")
        ]
        
        // Add sample songs to queue if it's empty
        if queue.isEmpty {
            for song in sampleSongs {
                musicPlayerService.addToQueue(song)
            }
        }
    }
} 