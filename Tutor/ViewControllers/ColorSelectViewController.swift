//
//  ColorSelectViewController.swift
//  Tutor
//
//  Created by Eli Zhang on 12/1/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit
import Hero
import ViewAnimator

class ColorSelectViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    var instructionLabel: UILabel!
    var warmColors: [UIColor]!
    var coolColors: [UIColor]!
    var warm: Bool = true
    var selectedWarm: UIColor!
    var selectedCool: UIColor!
    
    let colorReuseIdentifier = "colorReuseIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        instructionLabel = UILabel()
        instructionLabel.text = "Choose your favorite warm color!"
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        instructionLabel.textColor = .black
        view.addSubview(instructionLabel)
        
        warmColors = [UIColor(red: 0.929, green: 0.718, blue: 0.259, alpha: 1), // #edb742
                    UIColor(red: 0.925, green: 0.651, blue: 0.247, alpha: 1), // #eca63f
                    UIColor(red: 0.929, green: 0.584, blue: 0.298, alpha: 1), // #ed954c
                    UIColor(red: 0.929, green: 0.498, blue: 0.373, alpha: 1), // #ed7f5f
                    UIColor(red: 0.929, green: 0.424, blue: 0.482, alpha: 1), // #ed6c7b
                    UIColor(red: 0.933, green: 0.431, blue: 0.588, alpha: 1), // #ee6e96
                    UIColor(red: 0.937, green: 0.486, blue: 0.714, alpha: 1), // #ef7cb6
                    UIColor(red: 0.937, green: 0.541, blue: 0.812, alpha: 1)] // #ef8acf
        coolColors = [UIColor(red: 0.361, green: 0.831, blue: 0.784, alpha: 1), // #5cd4c8
                    UIColor(red: 0.298, green: 0.737, blue: 0.871, alpha: 1), // #4cbcde
                    UIColor(red: 0.243, green: 0.663, blue: 0.929, alpha: 1), // #3ea9ed
                    UIColor(red: 0.278, green: 0.596, blue: 0.922, alpha: 1), // #4798eb
                    UIColor(red: 0.443, green: 0.565, blue: 0.925, alpha: 1), // #7190ec
                    UIColor(red: 0.624, green: 0.541, blue: 0.914, alpha: 1), // #9f8ae9
                    UIColor(red: 0.757, green: 0.518, blue: 0.898, alpha: 1), // #c184e5
                    UIColor(red: 0.784, green: 0.514, blue: 0.902, alpha: 1)] // #c883e6
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: colorReuseIdentifier)
        collectionView.showsVerticalScrollIndicator = false

        let zoom = AnimationType.zoom(scale: 0.8)
        collectionView.animate(animations: [zoom],
                       reversed: false,
                       initialAlpha: 0.4,
                       finalAlpha: 1.0,
                       delay: 0,
                       duration: 0.7,
                       completion: nil)
        view.addSubview(collectionView)
        
        setUpConstraints()
    }
    
    func setUpConstraints() {
        instructionLabel.snp.makeConstraints{ (make) in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
            make.height.equalTo(30)
        }
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(instructionLabel.snp.bottom).offset(20)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(view).offset(-20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if warm {
            return warmColors.count
        }
        return coolColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: colorReuseIdentifier, for: indexPath) as! ColorCollectionViewCell
        var color: UIColor
        if warm {
            color = warmColors[indexPath.item]
        }
        else {
            color = coolColors[indexPath.item]
        }
        cell.configure(color: color)
        cell.setNeedsUpdateConstraints()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length = ((collectionView.frame.width - 100) * 2) / 2
        return CGSize(width: length, height: length)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if warm {
            warm = false
            instructionLabel.text = "Choose your favorite cool color!"
            selectedWarm = warmColors[indexPath.item]
            collectionView.reloadData()
        }
        else {
            selectedCool = coolColors[indexPath.item]
            collectionView.reloadData()
            nextScreen(warm: selectedWarm, cool: selectedCool)
        }
    }
    
    func nextScreen(warm: UIColor, cool: UIColor) {
        let profilePictureView = ProfilePictureViewController()
        present(profilePictureView, animated: true, completion: nil)
    }
}
