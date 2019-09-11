import UIKit

class DemoHomeViewController: UIViewController, DemoController {

	weak var menuController: CariocaController?

    @IBOutlet weak var logo: UIImageView!
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logo.image = logo.image?.withRenderingMode(.alwaysTemplate)
        logo.tintColor = UIColor(hex: "#434343")
    }
}
