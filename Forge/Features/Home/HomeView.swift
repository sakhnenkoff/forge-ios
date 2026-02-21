//
//  HomeView.swift
//  Forge
//

import SwiftUI
import AppRouter
import DesignSystem

struct HomeView: View {
    @Environment(AppServices.self) private var services
    @Environment(AppSession.self) private var session
    @Environment(Router<AppTab, AppRoute, AppSheet>.self) private var router

    @State private var viewModel = HomeViewModel()

    // Gallery state
    @State private var selectedSegment = "Daily"
    @State private var isToggleOn = true
    @State private var demoTime = Date()
    @State private var nameField = ""
    @State private var selectedChoices: Set<String> = ["Save more"]
    @State private var showSkeleton = true

    var body: some View {
        DSScreen(title: "Design System") {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                buttonsSection
                controlsSection
                inputsSection
                cardsSection
                selectionSection
                listRowsSection
                statesSection
                emptyErrorSection
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                DSIconButton(icon: "gearshape", style: .tertiary, size: .small, showsBackground: false, accessibilityLabel: "Settings") {
                    router.selectedTab = .settings
                }
            }
        }
        .toast($viewModel.toast)
        .onAppear {
            viewModel.onAppear(services: services, session: session)
        }
    }

    // MARK: - Buttons

    private var buttonsSection: some View {
        DSSection(title: "Buttons") {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                HStack(spacing: DSSpacing.sm) {
                    DSButton(title: "Primary") { }
                    DSButton(title: "Secondary", style: .secondary) { }
                }
                HStack(spacing: DSSpacing.sm) {
                    DSButton(title: "Text only", style: .tertiary) { }
                    DSButton(title: "Destructive", style: .destructive) { }
                }
                DSButton.cta(title: "Full-width CTA") { }
                HStack(spacing: DSSpacing.sm) {
                    DSIconButton(icon: "heart.fill", style: .primary, size: .medium, accessibilityLabel: "Favorite") { }
                    DSIconButton(icon: "plus", style: .secondary, size: .small, accessibilityLabel: "Add") { }
                    DSIconButton(icon: "xmark", style: .tertiary, size: .small, accessibilityLabel: "Close") { }
                    DSIconButton(icon: "trash", style: .destructive, size: .small, accessibilityLabel: "Delete") { }
                }
            }
        }
    }

    // MARK: - Controls

    private var controlsSection: some View {
        DSSection(title: "Controls") {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                DSSegmentedControl(items: ["Daily", "Weekly", "Monthly"], selection: $selectedSegment)
                HStack(spacing: DSSpacing.sm) {
                    GlassToggle(isOn: $isToggleOn, accessibilityLabel: "Glass toggle")
                    TimePill(time: $demoTime, usesGlass: true, accessibilityLabel: "Time picker")
                }
            }
        }
    }

    // MARK: - Inputs

    private var inputsSection: some View {
        DSSection(title: "Inputs") {
            DSTextField(
                placeholder: "Your name",
                text: $nameField,
                icon: "person",
                autocapitalization: .words
            )
        }
    }

    // MARK: - Cards

    private var cardsSection: some View {
        DSSection(title: "Cards") {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                DSHeroCard {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        HStack {
                            HeroIcon(systemName: "sparkles", size: DSLayout.iconMedium)
                            Spacer()
                            TagBadge(text: "New")
                        }
                        Text("Hero card")
                            .font(.headlineMedium())
                            .foregroundStyle(Color.textPrimary)
                        Text("Use DSHeroCard for featured content with optional glass.")
                            .font(.bodySmall())
                            .foregroundStyle(Color.textSecondary)
                    }
                }

                DSInfoCard(
                    title: "Heads up",
                    message: "Info cards communicate short status updates.",
                    icon: "info.circle",
                    tint: .info
                )

                DSInfoCard(
                    title: "Warning",
                    message: "Something needs your attention.",
                    icon: "exclamationmark.triangle",
                    tint: .warning
                )
            }
        }
    }

    // MARK: - Selection

    private var selectionSection: some View {
        DSSection(title: "Selection") {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                DSChoiceButton(
                    title: "Save more",
                    icon: "banknote",
                    isSelected: selectedChoices.contains("Save more")
                ) {
                    toggleChoice("Save more")
                }

                DSChoiceButton(
                    title: "Pay off debt",
                    icon: "creditcard.fill",
                    isSelected: selectedChoices.contains("Pay off debt")
                ) {
                    toggleChoice("Pay off debt")
                }

                DSChoiceButton(
                    title: "Track spending",
                    icon: "chart.line.uptrend.xyaxis",
                    isSelected: selectedChoices.contains("Track spending")
                ) {
                    toggleChoice("Track spending")
                }
            }
        }
    }

    // MARK: - List Rows

    private var listRowsSection: some View {
        DSSection(title: "List rows") {
            DSListCard {
                DSListRow(
                    title: "Balance",
                    subtitle: "Your current balance.",
                    leadingIcon: "dollarsign.circle"
                ) {
                    TagBadge(text: "$4,280")
                }
                Divider()
                DSListRow(
                    title: "Reminder",
                    subtitle: "Bill due date alert.",
                    leadingIcon: "bell.fill"
                ) {
                    TimePill(title: "17:00")
                }
                Divider()
                DSListRow(
                    title: "Category",
                    subtitle: "Manage spending categories.",
                    leadingIcon: "folder.fill"
                )
            }
        }
    }

    // MARK: - States

    private var statesSection: some View {
        DSSection(title: "States") {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                HStack(spacing: DSSpacing.sm) {
                    Circle()
                        .fill(Color.surfaceVariant)
                        .frame(width: DSLayout.avatarSmall, height: DSLayout.avatarSmall)
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("Profile Name")
                            .font(.headlineSmall())
                        Text("Loading content...")
                            .font(.bodySmall())
                    }
                    Spacer()
                }
                .shimmer(showSkeleton)

                HStack(spacing: DSSpacing.sm) {
                    DSButton(title: showSkeleton ? "Stop shimmer" : "Start shimmer", style: .secondary) {
                        showSkeleton.toggle()
                    }

                    DSButton(title: "Show Toast", style: .tertiary) {
                        viewModel.toast = Toast(style: .success, message: "Action completed!")
                    }
                }
            }
        }
    }

    // MARK: - Empty & Error

    private var emptyErrorSection: some View {
        DSSection(title: "Empty & error") {
            VStack(alignment: .leading, spacing: DSSpacing.md) {
                EmptyStateView(
                    icon: "tray",
                    title: "No items yet",
                    message: "Create your first item to get started.",
                    actionTitle: "Create",
                    action: { }
                )
                ErrorStateView(
                    title: "Upload failed",
                    message: "Please check your connection.",
                    retryTitle: "Try again",
                    onRetry: { }
                )
            }
        }
    }

    // MARK: - Helpers

    private func toggleChoice(_ choice: String) {
        if selectedChoices.contains(choice) {
            selectedChoices.remove(choice)
        } else {
            selectedChoices.insert(choice)
        }
    }
}

private extension Bundle {
    var displayName: String {
        object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? "App"
    }
}

#Preview {
    HomeView()
        .environment(AppServices(configuration: .mock(isSignedIn: true)))
        .environment(AppSession())
        .environment(Router<AppTab, AppRoute, AppSheet>(initialTab: .home))
}
