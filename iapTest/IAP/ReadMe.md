## Steps to import IAP
1. Drag the folder `IAP` to Xcode Project
2. Initialize **IAPViewController** with **prodcutInfo**
    - **prodcutInfo** format as descriped in `IAPProductIds.plist`
        - *selectedIdx* index of the selected product in default
        - *productIds* product ids presented in purchase choice view
        - *productPrices* price of corresponding product in *productIds* array
3. Assign a callback block to **IAPViewController**,*callBackHandler*, which handler the result of IAP and detach the **IAPViewController** instance
4. Attach the **IAPViewController** instance to a container view controller

