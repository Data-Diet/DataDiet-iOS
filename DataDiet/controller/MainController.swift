import AVFoundation
import UIKit

class MainController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet var videoPreview: UIView!
    
    @IBOutlet var ScanButton: UIButton!
    @IBOutlet var ImageGalleryButton: UIButton!
    @IBOutlet var HistoryButton: UIButton!
    @IBOutlet var SettingsButton: UIButton!
    
    var canScan = false
    
    let SegueIdProductJSON = "ProductView"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
//        previewLayer.frame = view.layer.bounds
//        previewLayer.videoGravity = .resizeAspectFill
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
        
        print("in Metadata Output")
        
        if (canScan) {
            captureSession.stopRunning()
            
            
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
        if (canScan) {
            
            
            let barcodeNumber = code.suffix(code.count - 1)
            print(barcodeNumber)
            
            let productJSONURL = "https://world.openfoodfacts.org/api/v0/product/" + barcodeNumber + ".json"
            
            let item = Product(URL: productJSONURL)
            
            performSegue(withIdentifier: SegueIdProductJSON, sender: item)
            
            DispatchQueue.main.async {
                //calling another function after fetching the json
                //it will show the names to label
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = storyBoard.instantiateViewController(withIdentifier: "ProductView") as! ProductViewController
                self.present(newViewController, animated: true, completion: nil)
            }
        
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBAction func OnScanButtonTouchUpInside(_ sender: Any) {
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
