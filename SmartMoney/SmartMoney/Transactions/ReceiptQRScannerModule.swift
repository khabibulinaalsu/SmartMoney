import UIKit
import Vision
import VisionKit
import PhotosUI

protocol QRScannerDelegate: AnyObject {
    func didScanReceiptQR(_ receiptData: ReceiptQRParser.ReceiptData)
    func didFailToScanQR(_ error: Error)
}

class ReceiptQRScannerModule: NSObject {
    
    weak var delegate: QRScannerDelegate?
    private weak var presentingViewController: UIViewController?
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
        super.init()
    }
    
    func startScanning() {
        presentPhotoLibrary()
    }
    
    private func presentPhotoLibrary() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        presentingViewController?.present(picker, animated: true)
    }
    
    private func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            delegate?.didFailToScanQR(QRScannerError.imageProcessingFailed)
            return
        }
        
        let request = VNDetectBarcodesRequest { [weak self] request, error in
            DispatchQueue.main.async {
                self?.handleBarcodeDetection(request: request, error: error)
            }
        }
        
        request.symbologies = [.qr]
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            delegate?.didFailToScanQR(error)
        }
    }
    
    private func handleBarcodeDetection(request: VNRequest, error: Error?) {
        if let error = error {
            delegate?.didFailToScanQR(error)
            return
        }
        
        guard let results = request.results as? [VNBarcodeObservation],
              let firstBarcode = results.first,
              let qrString = firstBarcode.payloadStringValue else {
            delegate?.didFailToScanQR(QRScannerError.noQRCodeFound)
            return
        }
        
        if let receiptData = ReceiptQRParser.parseReceiptQR(qrString) {
            delegate?.didScanReceiptQR(receiptData)
        } else {
            delegate?.didFailToScanQR(QRScannerError.invalidReceiptQR)
        }
    }
}

// MARK: - PHPickerViewControllerDelegate
extension ReceiptQRScannerModule: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.delegate?.didFailToScanQR(error)
                    return
                }
                
                guard let image = object as? UIImage else {
                    self?.delegate?.didFailToScanQR(QRScannerError.imageProcessingFailed)
                    return
                }
                
                self?.processImage(image)
            }
        }
    }
}

// MARK: - Errors
enum QRScannerError: LocalizedError {
    case imageProcessingFailed
    case noQRCodeFound
    case invalidReceiptQR
    
    var errorDescription: String? {
        switch self {
        case .imageProcessingFailed:
            return "Не удалось обработать изображение"
        case .noQRCodeFound:
            return "QR-код не найден на изображении"
        case .invalidReceiptQR:
            return "QR-код не является кодом чека"
        }
    }
}
