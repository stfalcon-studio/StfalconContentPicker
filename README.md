# StfalconContentPicker 

This is library for fetch assets from user library. Library highly customizable, and have different UI elements. In example you will see different cases how I use it.

### Who we are
Need iOS and Android apps, MVP development or prototyping? Contact us via info@stfalcon.com. We develop software since 2009, and we're known experts in this field. Check out our [portfolio](https://stfalcon.com/en/portfolio) and see more libraries from [stfalcon-studio](https://stfalcon.com/en/opensource).

### Download

Download via Cocoapods:
```pod
 pod 'StfalconContentPicker', '0.1.1'
```

### Usage
 
 ## Protocols and what they do

  AskGalleryPermision - this protocol needed for checking permisions, but this not requared and you can implemented your own logic.
  Alertable - this protocol need for show popup's when user doesn't have permisions.
 MediaPickerProtocol - this protocol needed for show widget with asset's in different cases such as:
  1. Show widget in parent view.
  2. Show widget in input view in UITextView, UITextField.

## UI

CollectionAssetView - needed for display assets that already fetched. You can inheritate in customize it how you wish.
MediaItemCollectionViewCell - cell for displaying asset. You can inheritate in customize it how you wish. 
MediaPickerViewController - controller that include CollectionAssetView in displayed all fetched assets. Also you can add some custom ui in this controller or create custom transition when you show it.
 
## Entities

MediaPickerOptions - all needed options for fetch assets, and configure CollectionAssetView.
MediaAsset - needed for represent asset from librarry. You can inheritate it or conform your custom class to MediaAssetProtocol.

## About example

In example app you can see how I use it.

![Imgur](https://i.imgur.com/0iMqGyS.gif)
![Imgur](https://i.imgur.com/tdf4Xo5.gif)
[Imgur](https://i.imgur.com/TrsRm2l.mp4)


### License

```
Copyright 2018 stfalcon.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
