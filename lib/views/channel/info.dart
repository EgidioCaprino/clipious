import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:invidious/models/channel.dart';
import 'package:invidious/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/imageObject.dart';
import '../../models/videoInList.dart';
import '../components/subscribeButton.dart';
import '../components/videoThumbnail.dart';
import '../videoList/singleVideo.dart';

class ChannelInfo extends StatelessWidget {
  final Channel channel;

  const ChannelInfo({super.key, required this.channel});

  @override
  Widget build(BuildContext context) {
    var locals = AppLocalizations.of(context)!;
    ColorScheme colors = Theme.of(context).colorScheme;
    var textTheme = Theme.of(context).textTheme;
    List<Widget> widgets = [
      Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 0),
        child: Text(
          channel.author ?? '',
          style: textTheme.titleLarge?.copyWith(color: colors.primary),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            SubscribeButton(channelId: channel.authorId, subCount: compactCurrency.format(channel.subCount)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: SelectableLinkify(
            text: channel.description,
            linkStyle: TextStyle(color: colors.primary, decoration: TextDecoration.none),
            onOpen: (link) => launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication),
            options: const LinkifyOptions(humanize: true, removeWww: true)),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Text(
          locals.latestVideos,
          style: textTheme.titleMedium?.copyWith(color: colors.secondary),
        ),
      ),
    ];

    widgets.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GridView.count(
          crossAxisCount: getGridCount(context),
          padding: const EdgeInsets.all(4),
          crossAxisSpacing: 5,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          mainAxisSpacing: 5,
          childAspectRatio: getGridAspectRatio(context),
          children: channel.latestVideos?.map((e) {
                VideoInList videoInList = VideoInList(e.title, e.videoId, e.lengthSeconds, 0, e.author, channel.authorId, channel.authorId, 0, '', e.videoThumbnails);
                videoInList.filtered = e.filtered;
                videoInList.matchedFilters = e.matchedFilters;
                return VideoListItem(video: videoInList);
              }).toList() ??
              []),
    ));

    return SingleChildScrollView(
      child: Stack(
        children: [
          SizedBox(
            height: 230,
            child: Thumbnail(
                width: double.infinity,
                thumbnailUrl: ImageObject.getBestThumbnail(channel.authorThumbnails)?.url ?? '',
                id: 'channel-banner/${channel.authorId}',
                decoration: BoxDecoration(
                  color: colors.secondaryContainer,
                )),
          ),
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment(0, Alignment.topCenter.y + 0.035), end: Alignment(0, Alignment.topCenter.y + 0.044), colors: [colors.background.withOpacity(0), colors.background])),
            child: Padding(
              padding: const EdgeInsets.only(top: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widgets,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
