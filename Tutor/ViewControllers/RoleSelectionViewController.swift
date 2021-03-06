//
//  RoleSelectionViewController.swift
//  Tutor
//
//  Created by Eli Zhang on 11/29/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit
import Hero

enum Role {
    case tutor
    case tutee
    case both
}

class RoleSelectionViewController: UIViewController {

    var tutorButton: TutorShape!
    var tuteeButton: TuteeShape!
    var tutorLabel: UILabel!
    var tuteeLabel: UILabel!
    var bothButton: UIButton!
    var bothColor = UIColor.white
    var buttonDiameter: CGFloat = 170
    var role: Role!
    var warm: String!
    var cool: String!
    var imageURL: String!
    
    weak var delegate: PromptViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        tutorButton = TutorShape(minX: view.frame.minX, maxX: view.frame.maxX, minY: view.frame.minY, maxY: view.frame.maxY, color: warm)
        tutorButton.isUserInteractionEnabled = false
        view.addSubview(tutorButton)
        
        tuteeButton = TuteeShape(minX: view.frame.minX, maxX: view.frame.maxX, minY: view.frame.minY, maxY: view.frame.maxY, color: cool)
        tuteeButton.isUserInteractionEnabled = false
        view.addSubview(tuteeButton)
        
        bothButton = UIButton()
        bothButton.layer.cornerRadius = 0.5 * buttonDiameter
        bothButton.backgroundColor = bothColor
        bothButton.clipsToBounds = true
        bothButton.setTitle("Both", for: .normal)
        bothButton.setTitleColor(.black, for: .normal)
        bothButton.titleLabel?.font = UIFont.systemFont(ofSize: 50, weight: .semibold)
        bothButton.addTarget(self, action: #selector(both), for: .touchUpInside)
        bothButton.hero.id = "both"
        view.addSubview(bothButton)
        
        tutorLabel = UILabel()
        tutorLabel.text = "Tutor"
        tutorLabel.textColor = .white
        tutorLabel.font = UIFont.systemFont(ofSize: 70, weight: .semibold)
        tutorLabel.hero.id = "tutor"
        view.addSubview(tutorLabel)
        
        tuteeLabel = UILabel()
        tuteeLabel.text = "Tutee"
        tuteeLabel.textColor = .white
        tuteeLabel.font = UIFont.systemFont(ofSize: 70, weight: .semibold)
        tutorLabel.hero.id = "tutee"
        view.addSubview(tuteeLabel)
        
        setUpConstraints()
    }
    
    func addInfo(warm: String, cool: String, imageURL: String) {
        self.warm = warm
        self.cool = cool
        self.imageURL = imageURL
    }
    
    @objc func both() {
        presentProfileSetup(color: bothColor, role: .both, id: "both")
    }
    func tutor() {
        presentProfileSetup(color: ColorConverter.hexStringToUIColor(hex: warm), role: .tutor, id: "tutor")
    }
    func tutee() {
        presentProfileSetup(color: ColorConverter.hexStringToUIColor(hex: cool), role: .tutee, id: "tutee")
    }
    
    func setUpConstraints() {
        tutorButton.snp.makeConstraints{(make) -> Void in
            make.edges.equalTo(view)
        }
        tuteeButton.snp.makeConstraints{(make) -> Void in
            make.edges.equalTo(view)
        }
        bothButton.snp.makeConstraints{(make) -> Void in
            make.height.equalTo(buttonDiameter)
            make.height.equalTo(bothButton.snp.width)
            make.center.equalTo(view)
        }
        tutorLabel.snp.makeConstraints{(make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(70)
            make.leading.equalTo(view).offset(60)
        }
        tuteeLabel.snp.makeConstraints{(make) -> Void in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-70)
            make.trailing.equalTo(view).offset(-60)
        }
    }
    
    func presentProfileSetup(color: UIColor, role: Role, id: String) {
        let profileSetupView = ProfileSetupViewController(color: color, role: role, id: id)
        profileSetupView.hero.isEnabled = true
        profileSetupView.delegate = self
        profileSetupView.addInfo(warm: warm, cool: cool, imageURL: imageURL)
        present(profileSetupView, animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touchPoint = touches.first?.location(in: self.view) else {
            return
        }
        if tutorButton.path.contains(touchPoint) {
            tutor()
        }
        else if tuteeButton.path.contains(touchPoint) {
            tutee()
        }
    }
    
}

class TutorShape: UIView {
    
    var path: UIBezierPath!
    var minX: CGFloat!
    var maxX: CGFloat!
    var minY: CGFloat!
    var maxY: CGFloat!
    var color: String!
    
    init(minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat, color: String) {
        super.init(frame: .zero)
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
        self.color = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: maxY))
        path.addLine(to: CGPoint(x: maxX, y: 0))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = ColorConverter.hexStringToUIColor(hex: color).cgColor
        shapeLayer.path = path.cgPath
        layer.addSublayer(shapeLayer)
    }
}

class TuteeShape: UIView {
    
    var path: UIBezierPath!
    var minX: CGFloat!
    var maxX: CGFloat!
    var minY: CGFloat!
    var maxY: CGFloat!
    var color: String!
    
    init(minX: CGFloat, maxX: CGFloat, minY: CGFloat, maxY: CGFloat, color: String) {
        super.init(frame: .zero)
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
        self.color = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        path = UIBezierPath()
        path.move(to: CGPoint(x: maxX, y: maxY))
        path.addLine(to: CGPoint(x: 0, y: maxY))
        path.addLine(to: CGPoint(x: maxX, y: 0))
        path.addLine(to: CGPoint(x: maxX, y: maxY))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = ColorConverter.hexStringToUIColor(hex: color).cgColor
        shapeLayer.path = path.cgPath
        layer.addSublayer(shapeLayer)
    }
}
