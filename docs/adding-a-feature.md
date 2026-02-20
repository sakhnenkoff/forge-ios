# Adding a Feature

This guide walks through adding a complete feature to the template, using a "Notes" screen as the example. Every step includes copy-paste ready code.

> **When you're done with this example:** Delete `Features/Notes/` — it was just a learning example. Your real feature lives in its own folder with its own names.

## Overview: What We're Building

A Notes screen that:
- Shows a list of notes (loaded asynchronously via a manager)
- Has a ViewModel with loading state and error handling
- Is reachable via push navigation from the Home tab
- Tracks an analytics event on appear

## Step 1: Create the Feature Folder and Files

Create `Forge/Features/Notes/` with two files:

**`NotesViewModel.swift`:**
```swift
import Foundation
import DesignSystem

@MainActor
@Observable
final class NotesViewModel {
    var notes: [String] = []
    var isLoading = false
    var errorMessage: String?
    var toast: Toast?

    func onAppear(services: AppServices) {
        services.logManager.trackEvent(eventName: "Notes_Appear", type: .analytic)
        Task { await loadNotes(services: services) }
    }

    private func loadNotes(services: AppServices) async {
        isLoading = true
        defer { isLoading = false }
        // TODO: Replace with your actual data loading
        // Example: notes = try await services.notesManager.getNotes()
        notes = ["Note 1", "Note 2", "Note 3"]
    }
}
```

**`NotesView.swift`:**
```swift
import SwiftUI
import DesignSystem

struct NotesView: View {
    @Environment(AppServices.self) private var services
    @State private var viewModel = NotesViewModel()

    var body: some View {
        DSScreen(title: "Notes") {
            if viewModel.isLoading {
                ProgressView("Loading notes...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                LazyVStack(spacing: DSSpacing.sm) {
                    ForEach(viewModel.notes, id: \.self) { note in
                        Text(note)
                            .font(.bodyMedium())
                            .foregroundStyle(Color.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(DSSpacing.md)
                            .cardSurface(cornerRadius: DSRadii.md)
                    }
                }
            }

            if let errorMessage = viewModel.errorMessage {
                ErrorStateView(
                    title: "Couldn't load notes",
                    message: errorMessage,
                    retryTitle: "Try again",
                    onRetry: { viewModel.onAppear(services: services) }
                )
            }
        }
        .toast($viewModel.toast)
        .onAppear { viewModel.onAppear(services: services) }
    }
}

#Preview {
    NotesView()
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
}
```

## Step 2: Add a Route

Open `Forge/App/Navigation/AppRoute.swift` and add a `.notes` case:

```swift
enum AppRoute: DestinationType {
    case detail(title: String)
    case profile(userId: String)
    case settingsDetail
    case designSystemGallery
    case notes              // ← Add this

    static func from(path: String, fullPath: [String], parameters: [String: String]) -> AppRoute? {
        switch path {
        case "detail":
            return .detail(title: parameters["title"] ?? "Details")
        case "profile":
            return .profile(userId: parameters["id"] ?? "me")
        case "settings":
            return .settingsDetail
        case "design-system":
            return .designSystemGallery
        case "notes":
            return .notes   // ← Add this
        default:
            return nil
        }
    }
}
```

## Step 3: Register the Route

Open `Forge/App/Navigation/AppRouterViewModifiers.swift` and add the Notes destination to the switch:

```swift
extension View {
    func withAppRouterDestinations() -> some View {
        navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .detail(let title):
                DetailView(title: title)
            case .profile(let userId):
                ProfileView(userId: userId)
            case .settingsDetail:
                SettingsDetailView()
            case .designSystemGallery:
                DesignSystemGalleryView()
            case .notes:
                NotesView()             // ← Add this
            }
        }
    }
}
```

## Step 4: Navigate to the Feature

From anywhere with a `Router` in the environment (e.g., `HomeView`), navigate to Notes:

```swift
struct HomeView: View {
    @Environment(Router<AppTab, AppRoute, AppSheet>.self) private var router

    var body: some View {
        DSListRow(title: "Notes", leadingIcon: "note.text") {
            router.navigateTo(.notes, for: .home)
        }
    }
}
```

The second argument (`.home`) specifies which tab's navigation stack receives the push.

## Step 5: (Optional) Add to a Tab

If Notes should be a top-level tab — visible in the tab bar at all times — open `Forge/App/Navigation/AppTab.swift` and add:

```swift
enum AppTab: TabType {
    case home
    case settings
    case notes      // ← Add this (only if truly top-level)
}
```

Then add the Notes tab view in `AppTabsView.swift` following the existing tab pattern.

> **When to use a tab vs a route:** Only add a tab if the feature is a primary destination the user returns to constantly (like Home, Inbox, or Profile). Most features should be push routes.

## Step 6: (Optional) Add a Manager for Backend Data

If Notes needs real backend data, create a manager following the protocol-service pattern:

**`NotesManager.swift`:**
```swift
import Foundation

// Protocol enables Mock substitution in the Mock build
protocol NotesServiceProtocol {
    func getNotes(for userId: String) async throws -> [String]
}

@MainActor
final class NotesManager {
    private let service: NotesServiceProtocol

    init(service: NotesServiceProtocol) {
        self.service = service
    }

    func getNotes(for userId: String) async throws -> [String] {
        try await service.getNotes(for: userId)
    }
}

// Real implementation (Firestore, REST API, etc.)
final class FirestoreNotesService: NotesServiceProtocol {
    func getNotes(for userId: String) async throws -> [String] {
        // TODO: Implement Firestore fetch
        return []
    }
}

// Mock implementation for Mock builds
final class MockNotesService: NotesServiceProtocol {
    func getNotes(for userId: String) async throws -> [String] {
        return ["Mock note 1", "Mock note 2"]
    }
}
```

Then add `notesManager: NotesManager?` to `AppServices.swift` and initialize it:

```swift
// In AppServices.init(configuration:)
let notesService: NotesServiceProtocol = configuration.isMock
    ? MockNotesService()
    : FirestoreNotesService()
self.notesManager = NotesManager(service: notesService)
```

Update the ViewModel to use it:

```swift
private func loadNotes(services: AppServices) async {
    isLoading = true
    defer { isLoading = false }
    do {
        notes = try await services.notesManager?.getNotes(for: userId) ?? []
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

## Done!

Your feature is now:
- Reachable via `router.navigateTo(.notes, for: .home)`
- Tracking analytics on appear via `LogManager`
- Handling loading and error states correctly
- Previewing in Xcode with mock data (no credentials needed)
- Following all template conventions (MVVM, @Observable, @Environment)

**Now delete `Features/Notes/`** and build your real feature the same way.
