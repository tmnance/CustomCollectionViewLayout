// Copyright 2017 Brightec
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

class CollectionViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!

    let numItems = 60
    var dateLabels: [String] = []

    let contentCellIdentifier = "ContentCellIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(
            UINib(nibName: "ContentCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: contentCellIdentifier
        )


        for item in 0..<numItems {
            let date = Calendar.current.date(byAdding: .day, value: (-1 * item), to: Date())!
            let df = DateFormatter()

            //        df.dateFormat = "MMMM"
            //        let monthName = df.string(from: date)

            df.dateFormat = "d"
            let dayNumber = df.string(from: date)

            df.dateFormat = "EEE"
            let dayName = df.string(from: date)
            dateLabels.append("\(dayName)\n\(dayNumber)")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        collectionView?.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
}


// MARK: - UICollectionViewDataSource
extension CollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 60
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numItems
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: contentCellIdentifier,
            for: indexPath
        ) as! ContentCollectionViewCell

        if indexPath.section % 2 != 0 {
            cell.backgroundColor = indexPath.row % 2 == 0 ?
                UIColor(white: 225/255.0, alpha: 1.0) :
                UIColor(white: 245/255.0, alpha: 1.0)
        } else {
            cell.backgroundColor = indexPath.row % 2 == 0 ?
                UIColor(white: 235/255.0, alpha: 1.0) :
                UIColor(white: 255/255.0, alpha: 1.0)
        }

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.contentLabel.text = "Date"
            } else {
                cell.contentLabel.text = dateLabels[indexPath.row - 1]
//                cell.contentLabel.text = "D\(indexPath.row)"
            }
        } else {
            if indexPath.row == 0 {
                cell.contentLabel.text = String(indexPath.section)
            } else {
                cell.contentLabel.text = Int.random(in: 0...1) == 0 ? "☑️" : ""
            }
        }

        return cell
    }
}


// MARK: - UICollectionViewDelegate
extension CollectionViewController: UICollectionViewDelegate {
}
