import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/saved_items_provider.dart'; // Provedor que criaremos para gerenciar itens salvos

class DetailsPage extends StatefulWidget {
  final Map<String, dynamic> item;

  const DetailsPage({Key? key, required this.item}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    final savedItemsProvider =
        Provider.of<SavedItemsProvider>(context, listen: false);
    isSaved = savedItemsProvider.isSaved(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.item['title'] ?? widget.item['name'] ?? 'Detalhes'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPoster(context),
            SizedBox(height: 16),
            _buildTitle(context),
            SizedBox(height: 16),
            _buildDescription(),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPoster(BuildContext context) {
    String posterPath = widget.item['poster_path'];
    return Center(
      child: SizedBox(
        width: 200,
        height: 300,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Image.network(
            'https://image.tmdb.org/t/p/w500$posterPath',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item['media_type'] == 'movie' ? 'Filme' : 'Série de TV',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.item['title'] ??
                    widget.item['name'] ??
                    'Título Desconhecido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    _getReleaseYear(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.yellow,
                        size: 20,
                      ),
                      SizedBox(width: 5),
                      Text(
                        _getRating(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        _getAgeRestriction(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        _getDuration(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.bookmark,
              color: isSaved ? Colors.red : Colors.red.withOpacity(0.5),
              size: 30,
            ),
            onPressed: () {
              setState(() {
                isSaved = !isSaved;
              });
              final savedItemsProvider =
                  Provider.of<SavedItemsProvider>(context, listen: false);
              if (isSaved) {
                savedItemsProvider.addSavedItem(widget.item);
              } else {
                savedItemsProvider.removeSavedItem(widget.item);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    String overview = widget.item['overview'] ?? 'Descrição não disponível.';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        overview,
        style: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getReleaseYear() {
    String releaseDate = widget.item['release_date'] ??
        widget.item['first_air_date'] ??
        'Não especificado';
    return releaseDate.isNotEmpty
        ? releaseDate.substring(0, 4)
        : 'Não especificado';
  }

  String _getRating() {
    double rating = widget.item['vote_average'] ?? 0.0;
    return rating.toStringAsFixed(1);
  }

  String _getAgeRestriction() {
    String certification = 'Não especificado';
    List<dynamic>? releaseDates = widget.item['release_dates']?['results'];

    if (releaseDates != null) {
      for (var result in releaseDates) {
        if (result['iso_3166_1'] == 'US') {
          var certifications = result['release_dates'];
          for (var cert in certifications) {
            if (cert['type'] == 3) {
              certification = cert['certification'] ?? 'Não especificado';
              break;
            }
          }
          break;
        }
      }
    }

    return '($certification)';
  }

  String _getDuration() {
    int runtime =
        widget.item['runtime'] ?? widget.item['episode_run_time']?.first ?? 0;
    int hours = runtime ~/ 60;
    int minutes = runtime % 60;
    String duration = hours > 0 ? '$hours h $minutes min' : '$minutes min';
    return duration;
  }
}
