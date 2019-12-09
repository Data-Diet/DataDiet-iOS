import AVFoundation
import UIKit
import Firebase
import Hero

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet var videoPreview: UIView!
    @IBOutlet var ScanButton: UIButton!
    @IBOutlet var ImageGalleryButton: UIButton!
    @IBOutlet var HistoryButton: UIButton!
    @IBOutlet var SettingsButton: UIButton!
    
    let diets = ["Vegan", "Vegetarian", "Pescatarian", "Kosher", "Ketogenic", "Paleolithic"]
    var dietsSelected = [Bool](repeating: false, count: 6)
    var allergyArray = [String]()
    let defaultSettings: [String: Any] = [
           "Vegan": false,
           "Vegetarian": false,
           "Pescatarian": false,
           "Kosher": false,
           "Ketogenic": false,
           "Paleolithic": false,
           "Allergies": [String]()
       ]
    
    var db: Firestore!
    
    var canScan = false
    var productBarcode = ""
    
    let SegueIdProductJSON = "ProductView"
        
    override func viewDidLoad() {
        super.viewDidLoad()
        hero.isEnabled = true
        
        db = Firestore.firestore()
        loadDietsAndAllergens()
        
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
        
        let data = USDARequest()
        data.checkIfExists(barcodeNumber: self.productBarcode) { (totalHits) in
            DispatchQueue.main.async {
                if (totalHits > 0) {
                    self.performSegue(withIdentifier: "ProductViewSegue", sender: self)
                } else {
                    self.showToast(message : "Sorry! No product was found with the barcode: " + self.productBarcode, font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.thin))
                }
            }
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
    
    func loadDietsAndAllergens() {
        if let userID = Auth.auth().currentUser?.uid {
            print(userID)
            let scannerData = db.collection("users").document(userID).collection("Settings").document("Scanner")
            scannerData.getDocument { (document, error) in
                if let document = document, document.exists {
                    let scannerSettings = document.data()
                    for i in 0 ... self.diets.count - 1 {
                        self.dietsSelected[i] = scannerSettings![self.diets[i]] as! Bool
                    }
                    self.allergyArray = scannerSettings!["Allergies"] as! [String]
                }
                else {
                    scannerData.setData(self.defaultSettings) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ProductViewSegue") {
            let ProductVC = segue.destination as! ProductViewController
            ProductVC.productBarcode = self.productBarcode
            ProductVC.allergyArray = self.allergyArray
        }
    }
    
    @IBAction func OnSettingsButtonPressed(_ sender: Any) {
        if let SettingsVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewController(withIdentifier: "SettingsViewController") as? SettingsViewController
        {
            SettingsVC.hero.modalAnimationType = .push(direction: .down)
            present(SettingsVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func OnHistoryButtonPressed(_ sender: Any) {
        if let HistoryVC = UIStoryboard(name: "History", bundle: nil).instantiateViewController(withIdentifier: "HistoryViewController") as? HistoryViewController
        {
            HistoryVC.hero.modalAnimationType = .push(direction: .up)
            present(HistoryVC, animated: true, completion: nil)
        }
    }
}

extension UIViewController {

    func showToast(message : String, font: UIFont) {

        let toastLabel = UILabel(frame: CGRect(x: 25, y: self.view.frame.size.height - 500, width: self.view.frame.size.width - 50, height: 70))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.numberOfLines = 100
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
