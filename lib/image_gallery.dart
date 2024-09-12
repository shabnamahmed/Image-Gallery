
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:transparent_image/transparent_image.dart';
/// A page that displays a grid gallery of images from the Pixabay API.
///
/// The number of columns are based on the screen size.
class ImageGallery extends StatefulWidget {
  /// Creates an [ImageGallery] widget.
  const ImageGallery({Key? key}) : super(key: key);

  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  /// The API key to access Pixabay's image service.
  final String _apiKey = 'YOUR_PIXABAY_API_KEY';
  
  /// The list of images loaded from the Pixabay API.
  List<dynamic> _images = [];

  /// The current search text used to filter the images.
  String _searchText = '';

  /// The current page.
  int _currentPage = 1;

  /// Total number of pages.
  int _totalPages = 1;

  /// Indicates if more images are being loaded from the API.
  bool _isLoading = false;

  /// Scroll controller to detect when to load more images.
  final ScrollController _scrollController = ScrollController();

  /// Timer used for debouncing the search input.
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _getImages(); // get initial images
    _scrollController.addListener(_onScroll); // Add scroll listener for pagination
  }

  @override
  void dispose() {
    _debounce?.cancel(); // Cancel debounce timer
    _scrollController.dispose(); // Dispose scroll controller
    super.dispose();
  }

  /// Fetches images from the Pixabay API.
  Future<void> _getImages({bool loadMore = false}) async {
    if (_isLoading || _currentPage > _totalPages) return;

    setState(() {
      _isLoading = true;
    });

    final api = _searchText.isNotEmpty ? '&q=$_searchText' : '';
    final response = await http.get(Uri.parse(
        'https://pixabay.com/api/?key=$_apiKey&page=$_currentPage&per_page=20$api'));

    if (response.statusCode == 200) {
      final list = json.decode(response.body) as Map<String, dynamic>;

      setState(() {
        if (loadMore) {
          _images.addAll(list['hits']);
        } else {
          _images = list['hits'];
        }
        _totalPages = (list['totalHits'] / 20).ceil();
        _currentPage++;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// detect when more images should be loaded.
  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _getImages(loadMore: true);
    }
  }

  /// search 
  void _updateSearchQuery(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchText = query;
        _currentPage = 1;
      });
      _getImages(); // get filtered images
    });
  }

  /// Opens an image in full screen with an animation.
  void _openFullScreen(BuildContext context, String imageUrl) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => FullScreenImage(imageUrl: imageUrl),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = (MediaQuery.of(context).size.width / 150).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _updateSearchQuery,
              decoration: const InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8.0),
              controller: _scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _images.length + (_isLoading ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (index == _images.length) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final image = _images[index];

                return GestureDetector(
                  onTap: () => _openFullScreen(context, image['largeImageURL']),
                  child: GridTile(
                    footer: GridTileBar(
                      backgroundColor: Colors.black54,
                      title: Text('${image['likes']} likes'),
                      subtitle: Text('${image['views']} views'),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: image['previewURL'],
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}