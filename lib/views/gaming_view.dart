import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class GamingView extends StatelessWidget {
  const GamingView({super.key});

  static const int _currentPoints = 420;
  static const int _nextLevelPoints = 600;
  static const int _completedChallenges = 3;
  static const int _totalChallenges = 5;

  static const List<_Challenge> _challenges = [
    _Challenge(
      title: 'Trailblazer Walk',
      description: 'Complete a 2 km walk around Kamp Wyldemerk.',
      points: 120,
      status: _ChallengeStatus.completed,
    ),
    _Challenge(
      title: 'History Seeker',
      description: 'Visit 3 heritage spots and read their stories.',
      points: 90,
      status: _ChallengeStatus.completed,
    ),
    _Challenge(
      title: 'Nature Observer',
      description: 'Spot 5 unique plants along the trail.',
      points: 70,
      status: _ChallengeStatus.inProgress,
    ),
    _Challenge(
      title: 'Cultural Collector',
      description: 'Find 4 cultural markers on the map.',
      points: 80,
      status: _ChallengeStatus.locked,
    ),
    _Challenge(
      title: 'Audio Explorer',
      description: 'Listen to 3 audio stories on site.',
      points: 60,
      status: _ChallengeStatus.locked,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isIOS) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Kamp Wyldemerk'),
          border: const Border(
            bottom: BorderSide(
              color: CupertinoColors.separator,
              width: 1.0,
              style: BorderStyle.solid,
            ),
          ),
        ),
        child: SafeArea(
          child: _buildContent(context, isCupertino: true),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: _buildContent(context, isCupertino: false),
      ),
    );
  }
}

extension on GamingView {
  Widget _buildContent(BuildContext context, {required bool isCupertino}) {
    final progress = GamingView._currentPoints / GamingView._nextLevelPoints;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        _buildPointsHeader(context, progress, isCupertino),
        const SizedBox(height: 20),
        Text(
          'Challenges',
          style: (isCupertino
                  ? const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    )
                  : Theme.of(context).textTheme.titleLarge)
              ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 12),
        ...GamingView._challenges.map((challenge) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildChallengeCard(context, challenge, isCupertino),
          );
        }),
      ],
    );
  }

  Widget _buildPointsHeader(
    BuildContext context,
    double progress,
    bool isCupertino,
  ) {
    final labelColor = isCupertino
        ? CupertinoColors.label.resolveFrom(context)
        : Theme.of(context).colorScheme.onSurface;
    final mutedColor = isCupertino
        ? CupertinoColors.secondaryLabel.resolveFrom(context)
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final surfaceColor = isCupertino
        ? CupertinoColors.systemGrey6.resolveFrom(context)
        : Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kamp Wyldemerk Progress',
            style: (isCupertino
                    ? const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      )
                    : Theme.of(context).textTheme.titleMedium)
                ?.copyWith(color: labelColor),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                isCupertino ? CupertinoIcons.star_fill : Icons.stars,
                color: Colors.amber,
              ),
              const SizedBox(width: 8),
              Text(
            '${GamingView._currentPoints} points',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: labelColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Progress: ${GamingView._completedChallenges} / ${GamingView._totalChallenges} challenges',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: mutedColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(
    BuildContext context,
    _Challenge challenge,
    bool isCupertino,
  ) {
    final statusInfo = _statusDisplay(challenge.status, isCupertino);
    final surfaceColor = isCupertino
        ? CupertinoColors.systemGrey6.resolveFrom(context)
        : Theme.of(context).colorScheme.surface;
    final titleColor = isCupertino
        ? CupertinoColors.label.resolveFrom(context)
        : Theme.of(context).colorScheme.onSurface;
    final bodyColor = isCupertino
        ? CupertinoColors.secondaryLabel.resolveFrom(context)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusInfo.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusInfo.icon,
              color: statusInfo.foreground,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: titleColor),
                ),
                const SizedBox(height: 6),
                Text(
                  challenge.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: bodyColor,
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      statusInfo.badgeIcon,
                      size: 18,
                      color: statusInfo.foreground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusInfo.label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: statusInfo.foreground,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      '+${challenge.points} pts',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _ChallengeStatusDisplay _statusDisplay(
    _ChallengeStatus status,
    bool isCupertino,
  ) {
    switch (status) {
      case _ChallengeStatus.completed:
        return _ChallengeStatusDisplay(
          label: 'Completed',
          icon: isCupertino
              ? CupertinoIcons.check_mark
              : Icons.check_circle,
          badgeIcon: isCupertino
              ? CupertinoIcons.check_mark
              : Icons.check_circle,
          foreground: Colors.green,
          background: Colors.green.withValues(alpha: 0.12),
        );
      case _ChallengeStatus.inProgress:
        return _ChallengeStatusDisplay(
          label: 'In progress',
          icon: isCupertino ? CupertinoIcons.flag : Icons.flag,
          badgeIcon: isCupertino ? CupertinoIcons.flag : Icons.flag,
          foreground: Colors.orange,
          background: Colors.orange.withValues(alpha: 0.12),
        );
      case _ChallengeStatus.locked:
        return _ChallengeStatusDisplay(
          label: 'Locked',
          icon: isCupertino ? CupertinoIcons.lock : Icons.lock,
          badgeIcon: isCupertino ? CupertinoIcons.lock : Icons.lock,
          foreground: Colors.grey,
          background: Colors.grey.withValues(alpha: 0.12),
        );
    }
  }
}

enum _ChallengeStatus { completed, inProgress, locked }

class _Challenge {
  final String title;
  final String description;
  final int points;
  final _ChallengeStatus status;

  const _Challenge({
    required this.title,
    required this.description,
    required this.points,
    required this.status,
  });
}

class _ChallengeStatusDisplay {
  final String label;
  final IconData icon;
  final IconData badgeIcon;
  final Color foreground;
  final Color background;

  const _ChallengeStatusDisplay({
    required this.label,
    required this.icon,
    required this.badgeIcon,
    required this.foreground,
    required this.background,
  });
}

