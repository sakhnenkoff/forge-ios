import SwiftUI

public extension View {
    func toast(_ toast: Binding<Toast?>) -> some View {
        self.modifier(ToastViewModifier(toast: toast))
    }
}

struct ToastViewModifier: ViewModifier {
    @Binding var toast: Toast?
    @State private var workItem: DispatchWorkItem?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let toast = toast {
                    ToastView(toast: toast) {
                        dismissToast()
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.92).combined(with: .move(edge: .bottom)).combined(with: .opacity),
                        removal: .scale(scale: 0.92).combined(with: .opacity)
                    ))
                    .padding(.bottom, 50)
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: toast)
            .onChange(of: toast) { _, newToast in
                if let newToast = newToast {
                    scheduleAutoDismiss(duration: newToast.duration)
                }
            }
            .onDisappear {
                workItem?.cancel()
                workItem = nil
            }
    }

    private func scheduleAutoDismiss(duration: Double) {
        workItem?.cancel()
        let task = DispatchWorkItem {
            dismissToast()
        }
        workItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
    }

    private func dismissToast() {
        withAnimation {
            toast = nil
        }
        workItem?.cancel()
        workItem = nil
    }
}

#Preview("Toast Modifier") {
    struct PreviewWrapper: View {
        @State private var toast: Toast?

        var body: some View {
            VStack(spacing: 20) {
                Button("Show Error") {
                    toast = .error("Something went wrong!")
                }

                Button("Show Success") {
                    toast = .success("Operation completed!")
                }

                Button("Show Warning") {
                    toast = .warning("Please check your input.")
                }

                Button("Show Info") {
                    toast = .info("New update available.")
                }
            }
            .toast($toast)
        }
    }

    return PreviewWrapper()
}
