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
        DSScreen(title: "Home") {
            VStack(alignment: .leading, spacing: DSSpacing.xl) {
                DSSegmentedControl(
                    items: HomeViewModel.homeTabs,
                    selection: $viewModel.selectedHomeTab
                )

                if viewModel.selectedHomeTab == "Dashboard" {
                    dashboardContent
                } else {
                    componentsContent
                }
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

    // MARK: - Dashboard

    private var dashboardContent: some View {
        StaggeredVStack(alignment: .leading, spacing: DSSpacing.xl) {
            greetingHeader
                .staggeredAppearance(index: 0)
            heroStatCard
                .staggeredAppearance(index: 1)
            quickStatsRow
                .staggeredAppearance(index: 2)
            activityList
                .staggeredAppearance(index: 3)
        }
    }

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text(viewModel.greeting(for: session))
                .font(.display())
                .foregroundStyle(Color.textPrimary)
            Text(viewModel.currentDateString)
                .font(.bodyMedium())
                .foregroundStyle(Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var heroStatCard: some View {
        DSHeroCard(usesGlass: true) {
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                HStack {
                    HeroIcon(systemName: "flame.fill", size: 28, tint: Color.themePrimary, usesGlass: true)
                    Spacer()
                    TagBadge(text: "Today", tint: Color.themePrimary)
                }
                Text("12")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                Text("Active items")
                    .font(.bodyLarge())
                    .foregroundStyle(Color.textSecondary)
            }
        }
    }

    private var quickStatsRow: some View {
        HStack(spacing: DSSpacing.smd) {
            statPill(icon: "clock.fill", value: "3", label: "Pending", tint: .info)
            statPill(icon: "checkmark.circle.fill", value: "7", label: "Complete", tint: .success)
        }
    }

    private func statPill(icon: String, value: String, label: String, tint: Color) -> some View {
        DSCard(depth: .raised) {
            VStack(spacing: DSSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(tint)
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.textPrimary)
                Text(label)
                    .font(.captionLarge())
                    .foregroundStyle(Color.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var activityList: some View {
        DSSection(title: "Recent Activity") {
            DSListCard {
                DSListRow(
                    title: "Design review",
                    subtitle: "Updated the component library",
                    leadingIcon: "paintbrush.fill"
                ) {
                    TimePill(title: "2h ago")
                }
                Divider()
                DSListRow(
                    title: "New feature",
                    subtitle: "Added onboarding flow",
                    leadingIcon: "sparkles"
                ) {
                    TimePill(title: "5h ago")
                }
                Divider()
                DSListRow(
                    title: "Bug fix",
                    subtitle: "Resolved auth redirect",
                    leadingIcon: "ladybug.fill"
                ) {
                    TimePill(title: "1d ago")
                }
                Divider()
                DSListRow(
                    title: "Release prep",
                    subtitle: "Finalized v1.0 build",
                    leadingIcon: "shippingbox.fill"
                ) {
                    TimePill(title: "2d ago")
                }
            }
        }
    }

    // MARK: - Components Gallery

    private var componentsContent: some View {
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

    // MARK: - Buttons

    private var buttonsSection: some View {
        DSSection(title: "Buttons") {
            Text("Primary, secondary, tertiary, and destructive button styles with icon variants.")
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)
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
            Text("Segmented controls, glass toggles, and time pickers.")
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)
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
            Text("Text fields with icons, focus states, and validation.")
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)
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
            Text("Hero cards with glass effects, info cards, and warning cards.")
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)
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
            Text("Choice buttons for multi-select options.")
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)
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
            Text("Compact rows with leading icons, trailing views, and dividers.")
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)
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
            Text("Shimmer loading states and toast notifications.")
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)
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
            Text("Placeholder states for empty content and error recovery.")
                .font(.bodySmall())
                .foregroundStyle(Color.textSecondary)
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
