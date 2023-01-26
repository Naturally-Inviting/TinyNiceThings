import AffirmationsClient
import ComposableArchitecture
import ImageRenderClient
import SwiftUI
import UIApplicationClient

public struct Home: ReducerProtocol {
    // MARK: - State
    public struct State: Equatable {
        public var affirmation: String
        public var opacity: CGFloat
        public var isShareVisible: Bool
        public var renderedImage: UIImage
        public var displayScale: CGFloat
        public var canOpenInstagram: Bool
        
        public init(
            affirmation: String = "",
            opacity: CGFloat = .zero,
            isShareVisible: Bool = false,
            displayScale: CGFloat = .zero,
            canOpenInstagram: Bool = false
        ) {
            self.affirmation = affirmation
            self.opacity = opacity
            self.isShareVisible = isShareVisible
            self.renderedImage = .init()
            self.displayScale = displayScale
            self.canOpenInstagram = canOpenInstagram
        }
    }
    
    // MARK: - Action
    public enum Action {
        case task
        case affirmationLoaded(Affirmation)
        case transition
        case setShareVisible(visible: Bool)
        case generateImage
        case imageGenrated(image: UIImage)
        case setDisplayScale(scale: CGFloat)
        case instagramLogoTapped
        case setCanOpenInstagram(canOpen: Bool)
    }
    
    @Dependency(\.affirmations) var affirmations
    @Dependency(\.imageRender) var imageRender
    @Dependency(\.applicationClient) var applicationClient
    
    public init() {}
    
    // MARK: - Reducer Body
    public var body: some ReducerProtocol<State, Action> {
        Reduce<State, Action> { state, action in
            switch action {
            case .task:
                return .merge(
                    .task {
                        let canOpen = self.applicationClient.canOpen(UIApplicationClient.instagramUrlScheme)
                        return .setCanOpenInstagram(canOpen: canOpen)
                    },
                    .task {
                        let affirmation = try await self.affirmations.dailyAffirmation()
                        return .affirmationLoaded(affirmation)
                    }
                )
                
            case let .affirmationLoaded(affirmation):
                state.affirmation = affirmation.title
                
                return .run { send in
                    await send(.transition, animation: .easeIn(duration: 1.5))
                    await send(.generateImage)
                }
                
            case let .setDisplayScale(scale):
                state.displayScale = scale
                return .none
                
            case .generateImage:
                return .task { [state] in
                    let renderView = SharedView(title: state.affirmation)
                    let image = await self.imageRender.render(renderView, scale: state.displayScale)
                    return .imageGenrated(image: image)
                }

            case let .imageGenrated(image):
                state.renderedImage = image
                return .none
                
            case let .setShareVisible(visible):
                state.isShareVisible = visible
                return .none
                
            case .transition:
                state.opacity = 1
                return .none
                
            case let .setCanOpenInstagram(canOpen):
                state.canOpenInstagram = canOpen
                return .none
                
            case .instagramLogoTapped:
                return .fireAndForget { [image = state.renderedImage] in
                    guard let png = image.pngData() else { return }
                    await self.applicationClient.shareImageToInstagramStories(png)
                }
                
            default:
                return .none
            }
        }
    }
}

public struct AffirmationView: View {
    @Environment(\.colorScheme) var colorScheme

    var title: String
    var opacity: CGFloat
    
    public var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(title)
                    .foregroundColor(.white)
                    .opacity(opacity)
                    .font(.custom("Helvetica Bold", size: 48, relativeTo: .largeTitle))
                .padding()
                
                Spacer()
            }
            Spacer()
        }
        .background(
            colorScheme == .dark ? Color.black : Color(hex: "242423")
        )
        .edgesIgnoringSafeArea(.all)
    }
    
}

// MARK: - View
public struct HomeView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.displayScale) var displayScale
    
    let store: StoreOf<Home>
    @ObservedObject var viewStore: ViewStoreOf<Home>
    
    public init(
        store: StoreOf<Home>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store)
    }
    
    public var body: some View {
        ZStack {
            AffirmationView(
                title: viewStore.affirmation,
                opacity: viewStore.opacity
            )
            
            VStack(spacing: 32) {
                if viewStore.canOpenInstagram {
                    Button(action: { viewStore.send(.instagramLogoTapped) }) {
                        InstagramLogo()
                    }
                }
                
                Button(action: { viewStore.send(.setShareVisible(visible: true))}) {
                    Image(systemName: "arrowshape.turn.up.right")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            .padding()
            .padding(.bottom)
        }
        .task {
            viewStore.send(.task)
            viewStore.send(.setDisplayScale(scale: displayScale))
        }
        .sheet(
            isPresented: viewStore.binding(
                get: \.isShareVisible,
                send: Home.Action.setShareVisible(visible:))
        ) {
            ActivityView(
                activityItems: [viewStore.renderedImage]
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct InstagramLogo: View {
    var color: Color = .white
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(color)
                .frame(width: 3, height: 3)
                .offset(x: 7, y: -7)
            
            Circle()
                .stroke(color, lineWidth: 2)
                .frame(width: 11, height: 11)
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(color, lineWidth: 2)
                .frame(width: 25, height: 25)
        }
    }
}

struct SharedView: View {
    var title: String
    var isShowingAppDetails: Bool = true
    
    var body: some View {
        ZStack {
            AffirmationView(
                title: title,
                opacity: 1
            )
            
            VStack {
                Spacer()
                
                HStack {
                    Image(uiImage: UIImage(named: "logo", in: .module, with: nil) ?? .init())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.white, lineWidth: 1)
                        )
                    
                    VStack(alignment: .leading) {
                        Text("Tiny Nice Things")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Daily affirmations delivered")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 8)
                    Spacer()
                }
                .padding(12)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .padding()
                .environment(\.colorScheme, .dark)
            }
        }
        .frame(width: 428)
        .frame(height: 926)
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(
            store: .init(
                initialState: .init(),
                reducer: Home()
            )
        )
        
        SharedView(
            title: "I have the wisdom to make the right decisions for me."
        )
        .previewLayout(.sizeThatFits)
    }
}
