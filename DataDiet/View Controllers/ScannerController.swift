import AVFoundation
import UIKit
import Firebase

class ScannerController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet var videoPreview: UIView!
    @IBOutlet var ScanButton: UIButton!
    @IBOutlet var ImageGalleryButton: UIButton!
    @IBOutlet var HistoryButton: UIButton!
    @IBOutlet var SettingsButton: UIButton!
    
    var canScan = false
    var productBarcode = ""
    
    let SegueIdProductJSON = "ProductView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        let format = VisionBarcodeFormat.all
//        let barcodeOptions = VisionBarcodeDetectorOptions(formats: format)
//
//        var vision = Vision.vision()
//
//        let barcodeDetector = vision.barcodeDetector(options: barcodeOptions)
//
//        func imageOrientation(
//            deviceOrientation: UIDeviceOrientation,
//            cameraPosition: AVCaptureDevice.Position
//            ) -> VisionDetectorImageOrientation {
//            switch deviceOrientation {
//                case .portrait:
//                    return cameraPosition == .front ? .leftTop : .rightTop
//                case .landscapeLeft:
//                    return cameraPosition == .front ? .bottomLeft : .topLeft
//                case .portraitUpsideDown:
//                    return cameraPosition == .front ? .rightBottom : .leftBottom
//                case .landscapeRight:
//                    return cameraPosition == .front ? .topRight : .bottomRight
//                case .faceDown, .faceUp, .unknown:
//                    return .leftTop
//            }
//        }
//
//        let cameraPosition = AVCaptureDevice.Position.back  // Set to the capture device you used.
//        let metadata = VisionImageMetadata()
//        metadata.orientation = imageOrientation(
//            deviceOrientation: UIDevice.current.orientation,
//            cameraPosition: cameraPosition
//        )
//
//        let image = VisionImage(buffer: CMSampleBuffer.self as! CMSampleBuffer)
//        image.metadata = metadata
//
//        barcodeDetector.detect(in: image) { features, error in
//          guard error == nil, let features = features, !features.isEmpty else {
//            // ...
//            return
//          }
//
//          // ...
//        }

                
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            print("input set")
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
            print("input added")
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
            metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
            print("output added")
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        bringButtonsToFront()
        
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        print(metadataObjects.count)

        if (canScan) {

            print(metadataObjects)
            
            if metadataObjects.count > 1 {
                let alert = UIAlertController(title: "Alert", message: "Scanning multiple barcodes is a planned implementation, please scan one barcode at a time.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                      switch action.style{
                      case .default:
                            print("default")

                      case .cancel:
                            print("cancel")

                      case .destructive:
                            print("destructive")


                }}))
                 DispatchQueue.main.sync {
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                found(code: stringValue)
            }

            if metadataObjects.isEmpty {
                captureSession.startRunning()
                print("No Barcodes Found")
                canScan = false
            }
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
    
    func found(code: String) {
        self.productBarcode = String(code.suffix(code.count - 1))
        
        canScan = false
        let productJSONURL = "https://world.openfoodfacts.org/api/v0/product/" + productBarcode + ".json"
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ProductViewSegue", sender: self)
        }
        
        captureSession.startRunning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var ProductVC = segue.destination as! ProductViewController
        ProductVC.productBarcode = self.productBarcode
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func ScanButtonTouchUpInside(_ sender: Any) {
        canScan = false
        print(canScan)
    }
    @IBAction func ScanButtonTouchDownInside(_ sender: Any) {
        canScan = true
        print(canScan)
    }
    
    func bringButtonsToFront() {
        videoPreview.bringSubviewToFront(ScanButton)
        videoPreview.bringSubviewToFront(ImageGalleryButton)
        videoPreview.bringSubviewToFront(HistoryButton)
        videoPreview.bringSubviewToFront(SettingsButton)
    }
}
