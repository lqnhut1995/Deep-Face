import UIKit
import Koloda
import JGProgressHUD
import ViewAnimator

class DemoScanViewController: UIViewController, DemoController {
    @IBOutlet weak var getimage: UIButton!
    @IBOutlet weak var cnn: UILabel!
    var hud: JGProgressHUD!
    var kolodaView: KolodaView!
    @IBOutlet weak var imageview: UIImageView!
    weak var menuController: CariocaController?
	override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    weak var alertaction : UIAlertAction?
    
    override func viewDidLoad() {
        imageview.layer.shadowColor = UIColor.black.cgColor
        imageview.layer.shadowOpacity = 1
        imageview.layer.shadowOffset = .zero
        imageview.layer.shadowRadius = 10
        imageview.layer.shadowPath = UIBezierPath(rect: imageview.bounds).cgPath
        
        for btn in [getimage] as! [UIButton]{
            btn.layer.cornerRadius = 5
            btn.layer.borderWidth = 1
            btn.layer.borderColor = UIColor.white.cgColor
        }
        
        kolodaView=KolodaView()
        view.addSubview(kolodaView)
        kolodaView.translatesAutoresizingMaskIntoConstraints = false
        kolodaView.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive=true
        kolodaView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -70).isActive=true
        kolodaView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive=true
        kolodaView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive=true
        kolodaView.dataSource = self
        kolodaView.delegate = self
        kolodaView.isHidden=true
        
        hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Processing Image"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fromAnimation = AnimationType.from(direction: .right, offset: 30.0)
        let zoomAnimation = AnimationType.zoom(scale: 0.2)
        let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/6)
        UIView.animate(views: [imageview, getimage, cnn],
                       animations: [zoomAnimation, rotateAnimation, fromAnimation],
                       duration: 1.0)
    }

    @IBAction func getimage(_ sender: Any) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 100
        blurEffectView.isHidden=true
        
        self.view.addSubview(blurEffectView)
        self.view.bringSubview(toFront: self.kolodaView)
        blurEffectView.isHidden=false
        self.kolodaView.isHidden=false
        let fromAnimation = AnimationType.from(direction: .right, offset: 30.0)
        let zoomAnimation = AnimationType.zoom(scale: 0.2)
        let rotateAnimation = AnimationType.rotate(angle: CGFloat.pi/6)
        UIView.animate(views: [kolodaView],
                       animations: [zoomAnimation, rotateAnimation, fromAnimation],
                       duration: 1.0)
    }
    
}

extension DemoScanViewController: KolodaViewDelegate, KolodaViewDataSource{
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        kolodaView.revertAction()
        koloda.isHidden=true
        if let viewWithTag = self.view.viewWithTag(100) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
    }
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        return 1
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view=Bundle.main.loadNibNamed("ScanView", owner: self, options: nil)?.first as! ScanView
        view.delegate = self
        return view
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
//        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)[0] as? OverlayView
        return nil
    }
}

extension DemoScanViewController{
    func getText(images: [UIImage]){
        let alert = UIAlertController(title: "Nhập Tên", message: "Điền tên vào chỗ trống", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Tên nào đó"
            textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) -> Void in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.sendToServer(name: textField!.text!, images: images)
        })
        
        alert.addAction(okAction)
        
        alertaction = okAction
        alertaction?.isEnabled = false
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func textChanged(_ sender: UITextField) {
        self.alertaction?.isEnabled  = !sender.text!.isEmpty
    }
    
    func sendToServer(name: String, images: [UIImage]){
        hud.show(in: self.view)
        WebServices.uploadImage(downloadString: "http://nhandang.vlute.edu.vn:9092/cal/uploadFaces", param: ["name": name, "files": images], complete: { [weak self](status) in
            if let _ = status{
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.1, animations: {
                        self?.hud.textLabel.text = "Up thành công"
                        self?.hud.detailTextLabel.text = nil
                        self?.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    })
                    
                    self?.hud.dismiss(afterDelay: 1.0)
                }
            }else{
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 0.1, animations: {
                        self?.hud.textLabel.text = "Up thất bại"
                        self?.hud.detailTextLabel.text = nil
                        self?.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    })
                    
                    self?.hud.dismiss(afterDelay: 1.0)
                }
            }
        })
    }
}

extension DemoScanViewController: ScanViewDelegate{
    func imagesResultCallBack(images: [UIImage], complete: @escaping () -> ()) {
        getText(images: images)
        complete()
    }
}
