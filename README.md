# ImageViewCaching

**Cache mechanism usage:**

```
let urlStr = "https://iso.500px.com/wp-content/uploads/2016/03/stock-photo-142984111.jpg"
if let url = URL(string: urlStr) {
    URLCache.shared.loadImage(url: url) { image in
    }
}

```
loadImage will download the image and store the response in the cache, everything is done under the hood. Completion is optional nil.
You can use it if you wanna prefetch some photos prior presenting them on the screen
You can do the same on any Data, not only images, using:
` URLCache.shared.loadData(url: url)
`So it can be used to save any kind of data, e.g some API's response

**UIImageView and SwiftUI's image usage:**


**SwiftUI Usage:**
Very similar to the native AsyncImage, but with the addition of our caching layer:
https://developer.apple.com/documentation/swiftui/asyncimage

```
let strUrl = "https://media.istockphoto.com/photos/abstract-blur-background-picture-id538372041?a=2"

AsyncCachedImage(strUrl: strUrl) {
    ZStack {
        Circle()
            .fill(Color.red)
        ActivityIndicator(isAnimating: .constant(true), style: .medium)
    }
} error: {
    Circle()
        .fill(Color.blue)
}
.clipped()
.frame(width: 100, height: 100, alignment: .center)
.aspectRatio(1, contentMode: .fit)
.clipShape(Circle())
.shadow(radius: 2)

```

Placeholder and error are optional nil, you're not forced to define them. You can pass inside and kind of SwiftUI View, Image, color, or Stack of anything you want (e.g progress view on top of some circle)


**UIKit usage**

Instead of:

```
let placeholderImage = UIImage(with: UIImage.LooraImage.studentAvatar)
let errorImage = UIImage(with: UIImage.LooraImage.errorImage)

```
now:

```
self.avatarImageView.loadImage(fromURL: imageURL, placeholderImage: placeholderImage, errorImage: errorImage) { image in
}

```
placeholderImage, errorImage and completion are all optional nil
You can use also

`self.avatarImageView.loadImage(fromURL: imageURL, placeholderImage: placeholderImage)
`
