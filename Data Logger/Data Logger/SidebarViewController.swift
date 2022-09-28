//
//  SidebarViewController.swift
//  Data Logger
//
//  Created by Adam Kopec on 13/09/2022.
//

import UIKit

private let reuseIdentifier = "Cell"

private struct Item: Hashable {
    var text: String
    var sfSymbol: String
    var isSection: Bool
    
    var viewController: UIViewController?
    
    static func section(withTitle title: String) -> Item {
        return Item(text: title, sfSymbol: "", isSection: true)
    }
    
    static func regular(withTitle title: String, systemImage: String, viewController: UIViewController?) -> Item {
        return Item(text: title, sfSymbol: systemImage, isSection: false, viewController: viewController)
    }
}


class SidebarViewController: UICollectionViewController {
    private var dataSource: UICollectionViewDiffableDataSource<String, Item>!
    private lazy var sidebarItems = [Item.regular(withTitle: "Car", systemImage: "car",
                                                  viewController: splitViewController?.viewController(for: .secondary)),
                                     Item.regular(withTitle: "Tracking", systemImage: "location.fill",
                                                  viewController: storyboard?.instantiateViewController(withIdentifier: "trackingController")),
                                     Item.regular(withTitle: "Driver", systemImage: "person.crop.circle",
                                                  viewController: storyboard?.instantiateViewController(withIdentifier: "accountController"))]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        self.collectionView.collectionViewLayout = createLayout()
        self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.collectionView.backgroundColor = .systemBackground
        self.collectionView.delegate = self
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        // Do any additional setup after loading the view.
        
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure()]
            cell.contentConfiguration = content
        }
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Item> { (cell, indexPath, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.text
            content.image = UIImage(systemName: item.sfSymbol)
            cell.contentConfiguration = content
            cell.accessories = []
            cell.contentConfiguration = content
        }
        
        dataSource = UICollectionViewDiffableDataSource<String, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            if item.isSection {
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item.text)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }
        self.collectionView.dataSource = dataSource
                
        if sidebarItems.filter({ $0.isSection }).isEmpty {
            var snapshot = NSDiffableDataSourceSnapshot<String, Item>()
            snapshot.appendSections(["Main"])
            snapshot.appendItems(sidebarItems)
            dataSource.apply(snapshot, animatingDifferences: false)
        } else {
            var snapshot = NSDiffableDataSourceSnapshot<String, Item>()
            snapshot.appendSections(sidebarItems.filter({ $0.isSection }).map(\.text))
            dataSource.apply(snapshot, animatingDifferences: false)
            for sectionItem in sidebarItems.filter({ $0.isSection }) {
                var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<Item>()
                sectionSnapshot.append([sectionItem])
                for item in sidebarItems[(sidebarItems.firstIndex(of: sectionItem)!+1)...] {
                    guard !item.isSection else { break }
                    sectionSnapshot.append([item], to: sectionItem)
                }
                sectionSnapshot.expand([sectionItem])
                dataSource.apply(sectionSnapshot, to: sectionItem.text)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard collectionView.indexPathsForSelectedItems?.isEmpty != false else { return }
        collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: animated, scrollPosition: .top)
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .sidebar)
            if self.sidebarItems.filter({ $0.isSection }).isEmpty {
                config.headerMode = .none
            } else {
                config.headerMode = .firstItemInSection
            }
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }
    
    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSource.itemIdentifier(for: indexPath)
        splitViewController?.setViewController(item?.viewController, for: .secondary)
    }
}
