//
//  ProfilePictureViewController.swift
//  Tutor
//
//  Created by Eli Zhang on 12/1/18.
//  Copyright © 2018 Cornell AppDev. All rights reserved.
//

import UIKit
import SnapKit
import ViewAnimator

class ProfilePictureViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var collectionView: UICollectionView!
    var instructionLabel: UILabel!
    var imageURLs: [String] = []
    var selectedImageURL: String!

    let profilePictureReuseIdentifier = "profilePictureReuseIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        instructionLabel = UILabel()
        instructionLabel.text = "Choose a profile photo!"
        instructionLabel.textAlignment = .center
        instructionLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        instructionLabel.textColor = .black
        view.addSubview(instructionLabel)
        
        imageURLs = ["BrownDog", "Bird", "Beer", "Chicken", "DerpyPenguin", "Donut", "Fish", "GrayDog", "Ham", "Penguin", "Shrimp", "Turtle", "ToyStory"]
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 20
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProfileCollectionViewCell.self, forCellWithReuseIdentifier: profilePictureReuseIdentifier)
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
        return imageURLs.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profilePictureReuseIdentifier, for: indexPath) as! ProfileCollectionViewCell
        cell.configure(picture: imageURLs[indexPath.item])
        cell.setNeedsUpdateConstraints()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let length = (collectionView.frame.width - 40 * 3) / 3
        return CGSize(width: length, height: length)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImageURL = imageURLs[indexPath.item]
        nextScreen(imageURL: selectedImageURL)
    }

    func nextScreen(imageURL: String) {
        let promptView = PromptViewController()
        present(promptView, animated: true, completion: nil)
    }
}

