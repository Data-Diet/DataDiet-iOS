import AVFoundation
import UIKit
import Firebase

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
        
//        print(metadataObjects.count)

        if (canScan) {

            print(metadataObjects)
            
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
        }
    }
    
    func found(code: String) {
        self.productBarcode = String(code.suffix(code.count - 1))
        
        canScan = false
        let productJSONURL = "https://world.openfoodfacts.org/api/v0/product/" + productBarcode + ".json"
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ProductViewSegue", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ProductViewSegue") {
            var ProductVC = segue.destination as! ProductViewController
            ProductVC.productBarcode = self.productBarcode
        }
    }
    
    @IBAction func ImageGalleryPicker(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageSelected = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
            let ciImage:CIImage=CIImage(image:imageSelected)!
            var qrCodeLink=""

            let features=detector.features(in: ciImage)
            for feature in features as! [CIQRCodeFeature] {
                qrCodeLink += feature.messageString!
            }

            if qrCodeLink == "" {
                print("nothing")
            } else {
                print("message: \(qrCodeLink)")
            }
        }
        picker.dismiss(animated: true, completion: nil)
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
