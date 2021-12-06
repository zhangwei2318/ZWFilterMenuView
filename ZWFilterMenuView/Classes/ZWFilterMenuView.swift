//
//  YXFirstClassScreeningView.swift
//  YXTeacher
//
//  Created by 张伟 on 2021/11/18.
//  Copyright © 2021 YJJ－CHY. All rights reserved.
//

import UIKit
import SnapKit

public class ZWBaseView: UIView {

    public override init(frame: CGRect) {
        super .init(frame: frame)
        configueLayout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configueLayout(){}

}

public class ZWFilterMenuView: ZWBaseView, UIGestureRecognizerDelegate {
    // bar点击事件
    public var barAction: ((_ index: Int, _ show: Bool) -> Void)?
    // cell点击事件
    public var cellAction: ((_ barIndex: Int, _ index: Int) -> Void)?
    // 记录bar点击的下标
    var barIndex: Int = 0
    
    // MenuBar内边距
    public var contentInset: UIEdgeInsets = .zero {
        didSet {
            menuBarV.contentInset = contentInset
        }
    }
    
    // MenuBar背景色
    public var menuBarBackgroundColor: UIColor = .white {
        didSet {
            menuBarV.menuBarBackgroundColor = menuBarBackgroundColor
        }
    }
    
    // 背景颜色 与 alphaBackgroundColorArray 二选一
    public var alphaBackgroundColor: UIColor = .black
    
    // 背景颜色数组 数据数与titleArray或 titleViewArray一致 否则越界崩溃
    public var alphaBackgroundColorArray: Array<UIColor?>?
    
    // title文字
    public var titleArray: Array<String>? {
        didSet {
            menuBarV.titleArray = titleArray
        }
    }
    
    // title任意控件
    public var titleViewArray: Array<UIView>? {
        didSet {
            menuBarV.titleViewArray = titleViewArray
        }
    }
    
    // 筛选条件数据
    public var filterStrArray: Array<Array<String>?>? {
        didSet {

        }
    }
    // title未选中文字颜色
    public var titleNormalColor: UIColor? = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1) {
        didSet {
            menuBarV.titleNormalColor = titleNormalColor
        }
    }
    // title选中文字颜色
    public var titleSelectColor: UIColor = UIColor.init(red: 116/255.0, green: 155/255.0, blue: 250/255.0, alpha: 1)
    // 记录筛选条件点击下标
    private var showIndex: Int?
    // 记录是否已经展开筛选条件
    private var showState: Bool?
    // 记录是否显示选中状态
    private var selectState: Bool?
    // 展开后Frame
    public var openFrame: CGRect?
    // 最大展示行数, 默认6
    public var maxCellLine: Int = 6
    // 行高, 默认44
    public var cellHeight: CGFloat = 44.0
    // 点击背景是否可以收起, 默认可以
    public var isBackGroundTapDismiss: Bool = true
    
    override func configueLayout() {
        backgroundColor = alphaBackgroundColor.withAlphaComponent(0)
        addSubview(menuBarV)
        menuBarV.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.frame.height)
        }
        
        addSubview(tableView)
        tableView.frame = CGRect.init(x: 0, y: self.frame.height, width: self.frame.width, height: 0)
        
        addSubview(lineV)
        lineV.snp.makeConstraints { (make) in
            make.top.equalTo(menuBarV.snp_bottom).offset(0)
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
        
                
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapGesAction(_:)))
        tapGes.numberOfTapsRequired = 1
        tapGes.delegate = self
        self.addGestureRecognizer(tapGes)
        
    }
    
    // 方法
    @objc func tapGesAction(_ tapGes : UITapGestureRecognizer){
        if isBackGroundTapDismiss == true {
            dismiss()
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view?.isDescendant(of: self.tableView) == true {
               return false
           }
           return true
    }

    // 展示带数据的样式
    func show(index: Int) {
        showState = true
        
        frame = openFrame ?? CGRect.init(x: self.frame.origin.x, y: self.frame.origin.y, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - self.frame.origin.y)
        UIView.animate(withDuration: 0.25) {[weak self] in
            self?.backgroundColor = self?.alphaBackgroundColor == .clear ? .clear : self?.alphaBackgroundColor.withAlphaComponent(0.3)
            self?.screeningViewFrameChange(index: index)
        } completion: { finish in
            
        }
    }
    
    func screeningViewFrameChange(index: Int) {
        let array = filterStrArray?[index]
        let count = array?.count ?? 0
        let height = count > maxCellLine ? (CGFloat(maxCellLine) * cellHeight): (CGFloat(count) * cellHeight)
        tableView.isHidden = array == nil ? true : false
        tableView.frame = CGRect.init(x: 0, y: menuBarV.frame.height , width: frame.width, height: height)
    }
    
    // 动画消失
    func dismiss() {
        showState = false
        UIView.animate(withDuration: 0.25) {[weak self] in
            self?.backgroundColor = .black.withAlphaComponent(0)
            self?.tableView.frame = CGRect.init(x: 0, y: self?.menuBarV.frame.height ?? 0, width: self?.frame.width ?? 0, height: 0)
        } completion: {[weak self] finish in
            self?.frame = CGRect.init(x: self?.openFrame?.origin.x ?? (self?.frame.origin.x ?? 0), y: self?.openFrame?.origin.y ?? (self?.frame.origin.y ?? 0), width: self?.menuBarV.frame.width ?? UIScreen.main.bounds.size.width, height: self?.menuBarV.frame.height ?? 44)
        }
    }
    
    private lazy var menuBarV:ZWFilterMenuBarView = {
        let view = ZWFilterMenuBarView.init()
        view.action = {[weak self] index in
            // 背景颜色数组越界处理
            if self?.alphaBackgroundColorArray != nil, index < (self?.alphaBackgroundColorArray?.count ?? 0) {
                self?.alphaBackgroundColor = self?.alphaBackgroundColorArray?[index] ?? .black
            }
            
            if self?.showIndex != index {
                self?.show(index: index)
                self?.showIndex = index
                self?.tableView.reloadData()
                self?.menuBarV.selectColor(color: self?.titleSelectColor, index: index)
            } else {
                if self?.showState == true {
                    self?.dismiss()
                    self?.showIndex = index
                    self?.menuBarV.selectColor(color: self?.titleNormalColor, index: index)
                }else {
                    self?.show(index: index)
                    self?.showIndex = index
                    self?.tableView.reloadData()
                    self?.menuBarV.selectColor(color: self?.titleSelectColor, index: index)
                }
            }
            guard let action = self?.barAction else {
                return
            }
            action(index, self?.showState ?? false)
        }
        return view
    }()
    
    private lazy var tableView:UITableView = {
        let tableV = UITableView.init()
        tableV.delegate = self
        tableV.dataSource = self
        return tableV
    }()
    
    private lazy var lineV:UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.init(red: 210/255.0, green: 210/255.0, blue: 210/255.0, alpha: 1)
        return view
    }()
}

extension ZWFilterMenuView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterStrArray?[showIndex ?? 0]?.count ?? 0
        
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let cell = UITableViewCell.init()
        let str = filterStrArray?[showIndex ?? 0]?[indexPath.row]
        cell.textLabel?.text = str
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell.textLabel?.textColor = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let str = filterStrArray?[showIndex ?? 0]?[indexPath.row]
        titleArray?[showIndex ?? 0] = str ?? ""
        dismiss()
        menuBarV.selectColor(color: titleNormalColor, index: showIndex ?? 0)
        
        guard let cellAction = cellAction else {
            return
        }
        
        cellAction(showIndex ?? 0, indexPath.row)
    }
    
}


class ZWFilterMenuBarView: ZWBaseView {
    var action: ((_ index: Int) -> Void)?
    
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            menuBarV.snp.updateConstraints { make in
                make.left.equalTo(contentInset.left)
                make.right.equalTo(-contentInset.right)
                make.top.equalTo(contentInset.top)
                make.bottom.equalTo(-contentInset.bottom)
            }
        }
    }
    
    var menuBarBackgroundColor: UIColor = .white {
        didSet {
            backgroundColor = menuBarBackgroundColor
            menuBarV.backgroundColor = menuBarBackgroundColor
        }
    }
    
    var titleNormalColor: UIColor? {
        didSet {
            menuBarV.subviews.forEach { view in
                let item = view as? ZWFilterMenuBarItemView
                item?.titleNormalColor = titleNormalColor ?? UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
            }
        }
    }
    
    var titleArray: Array<String>? {
        didSet {
            menuBarV.subviews.forEach({ $0.removeFromSuperview() })
            for i in 0..<(titleArray?.count ?? 0) {
                let item = ZWFilterMenuBarItemView.init()
                item.action = { [weak self] in
                    guard let action = self?.action else {
                        return
                    }
                    action(i)
                }
                item.title = titleArray?[i]
                item.titleNormalColor = titleNormalColor ?? UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
                menuBarV.addArrangedSubview(item)
            }
        }
    }
    
    var titleViewArray: Array<UIView>? {
        didSet {
            for i in 0..<(titleViewArray?.count ?? 0) {
                let item = ZWFilterMenuBarItemView.init()
                item.action = { [weak self] in
                    guard let action = self?.action else {
                        return
                    }
                    action(i)
                }
                let view = titleViewArray?[i]
                item.subView = view
                menuBarV.addArrangedSubview(item)
            }
        }
    }
    
    override func configueLayout() {
        backgroundColor = menuBarBackgroundColor
        addSubview(menuBarV)
        menuBarV.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
    
    func selectColor(color: UIColor?, index: Int) {
        for i in 0..<menuBarV.subviews.count {
            let item = menuBarV.subviews[i] as? ZWFilterMenuBarItemView
            if i == index {
                item?.titleSelectColor = color ?? UIColor.init(red: 116/255.0, green: 155/255.0, blue: 250/255.0, alpha: 1)
            }else {
                item?.titleNormalColor = titleNormalColor ?? UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1)
            }
        }
    }
    
    private lazy var menuBarV: UIStackView = {
        let view = UIStackView.init()
        view.distribution = .fillEqually
        view.axis = .horizontal
        return view
    }()
    
}



class ZWFilterMenuBarItemView: ZWBaseView {
    var action: (() -> Void)?
    // title未选中文字颜色
    var titleNormalColor: UIColor? {
        didSet {
            titleL.textColor = titleNormalColor
        }
    }
    // title选中文字颜色
    var titleSelectColor: UIColor? {
        didSet {
            titleL.textColor = titleSelectColor
        }
    }
    var subView: UIView? {
        didSet {
            subviews.forEach({ $0.removeFromSuperview() })
            
            subView?.isUserInteractionEnabled = false
            addSubview(subView ?? UIView.init())
            subView?.snp.makeConstraints { (make) in
                make.top.bottom.left.right.equalToSuperview()
            }
        }
    }
    
    var title: String? {
        didSet {
            titleL.text = title
        }
    }
    override func configueLayout() {
        addSubview(titleL)
        titleL.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.centerX.equalToSuperview().offset(-6)
        }
        
        addSubview(imgV)
        imgV.snp.makeConstraints { (make) in
            make.left.equalTo(titleL.snp_right).offset(4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapGesAction(_:)))
        tapGes.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGes)
        
    }
    
    @objc func tapGesAction(_ tapGes : UITapGestureRecognizer){
        guard let action = action else {
            return
        }
        action()
    }
    
    private lazy var titleL:UILabel = {
        let label = UILabel.init()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var imgV:UIImageView = {
        let imgV = UIImageView.init()
        let frameworkBundle = Bundle.init(for: ZWFilterMenuBarItemView.self)
        let bundleURL = frameworkBundle.resourceURL?.appendingPathComponent("ZWFilterMenuView.bundle")
        let resourceBundle = Bundle.init(url: bundleURL!)
        let image = UIImage(named: "zw_triangle_image", in: resourceBundle, compatibleWith: nil)
        imgV.image = image
        
        return imgV
    }()
}
