import SwiftUI
import AVKit
import ExyteMediaPicker


struct Video: View {
    @State var player : AVPlayer
    var url: URL
    @State var isPlaying: Bool = false
    @State var showControls : Bool = true
    @State var value: Float = 0
    @ObservedObject var cameraVM : CameraViewModel

    var body: some View{
            ZStack{
                VideoPlayer(player: $player)
//                if showControls{
//                    Controls(player: self.$player, isPlaying: self.$isPlaying, pannel: self.$showControls, value: self.$value)
//                }
                if !isPlaying {
                    Image(systemName: "play.fill").foregroundColor(Color.gray).font(.largeTitle).frame(width: 150, height: 150)
                }
               
            }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).edgesIgnoringSafeArea(.all)
            .onTapGesture {
                if isPlaying{
                    self.player.pause()
                    isPlaying = false
                }else{
                    self.player.play()
                    isPlaying = true
                }
            }.onDisappear{
                self.player.pause()
                isPlaying = false
            }.onAppear{
                self.player.play()
                isPlaying = true
            }

    }
}


struct CustomProgressBar : UIViewRepresentable {
    func makeCoordinator() -> CustomProgressBar.Coordinator {
        return CustomProgressBar.Coordinator(parent1: self)
    }

    @Binding var value: Float
    @Binding var player: AVPlayer
    @Binding var isPlaying: Bool

    func makeUIView(context: UIViewRepresentableContext<CustomProgressBar>) -> UISlider {
        let slider = UISlider()
        slider.minimumTrackTintColor = UIColor(named: "AccentColor")
        slider.maximumTrackTintColor = .gray
        slider.setThumbImage(UIImage(named: "thumb"), for: .normal)
        slider.value = value
        slider.addTarget(context.coordinator, action: #selector(context.coordinator.changed(slider:)), for: .valueChanged)
        return slider
    }

    func updateUIView(_ uiView: UISlider, context: UIViewRepresentableContext<CustomProgressBar>) {
        uiView.value = value
    }

    class Coordinator: NSObject {
        var parent: CustomProgressBar
        init(parent1: CustomProgressBar){
            parent = parent1

        }
        @objc func changed(slider: UISlider){
            if slider.isTracking{
                parent.player.pause()
                let sec = Double(slider.value * Float((parent.player.currentItem?.duration.seconds)!))

                parent.player.seek(to: CMTime(seconds: sec, preferredTimescale: 1))
            }else{
                let sec = Double(slider.value * Float((parent.player.currentItem?.duration.seconds)!))

                parent.player.seek(to: CMTime(seconds: sec, preferredTimescale: 1))

                if parent.isPlaying{
                    parent.player.play()
                }
            }
        }
    }
}

struct Controls: View {

    @Binding var player: AVPlayer
    @Binding var isPlaying : Bool
    @Binding var pannel: Bool
    @Binding var value: Float
    var body: some View{
        VStack{
            Spacer()

            HStack{
                Button(action:{
                    self.player.seek(to: CMTime(seconds: self.getSeconds() - 5, preferredTimescale: 1))

                },label:{
                    Image(systemName: "gobackward.5").font(.title).foregroundColor(FOREGROUNDCOLOR).padding()
                })

                Spacer()
                Button(action:{
                    if self.isPlaying{
                        self.player.pause()
                    }else{
                        if self.value == 1.0{
                            restartVideo()
                        }
                        self.player.play()
                    }
                    self.isPlaying.toggle()
                },label:{
                    Image(systemName: self.isPlaying ? "pause.fill" : "play.fill").font(.title).foregroundColor(FOREGROUNDCOLOR).padding()
                })

                Spacer()

                Button(action:{
                    self.player.seek(to: CMTime(seconds: self.getSeconds() + 5, preferredTimescale: 1))
                },label:{
                    Image(systemName: "goforward.5").font(.title).foregroundColor(FOREGROUNDCOLOR).padding()
                })


            }

            CustomProgressBar(value: self.$value, player: self.$player, isPlaying: self.$isPlaying)
            Spacer()
        }.padding().onTapGesture {
            self.pannel = false
        }.onAppear{
            self.player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { _ in
                self.value = self.getSliderValue()

                if self.value == 1.0{
                    self.isPlaying = false
                }
            }
        }
    }

    func restartVideo(){
        self.player.seek(to: CMTime(seconds: 0, preferredTimescale: 1))
    }
    func getSliderValue()-> Float {
        return Float(self.player.currentTime().seconds / (self.player.currentItem?.duration.seconds)!)
    }

    func getSeconds()-> Double {
        return Double(Double(self.value) * (self.player.currentItem?.duration.seconds)!)
    }
}


struct VideoPlayer : UIViewControllerRepresentable {
    @Binding var player: AVPlayer

    func makeUIViewController(context: UIViewControllerRepresentableContext<VideoPlayer>) -> AVPlayerViewController {

        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspect
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<VideoPlayer>) {

    }
    



}

