import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/story_provider.dart';
import '../models/story_model.dart';
import '../screens/story/create_story_screen.dart';
import '../screens/story/story_view_screen.dart';

class StoriesBar extends StatelessWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final storyProvider = context.watch<StoryProvider>();
    final stories = storyProvider.stories;

    // Group stories by userId
    final Map<String, List<StoryModel>> groupedStories = {};
    final List<String> userIdsOrder = [];

    for (final story in stories) {
      if (!groupedStories.containsKey(story.userId)) {
        groupedStories[story.userId] = [];
        userIdsOrder.add(story.userId);
      }
      groupedStories[story.userId]!.add(story);
    }

    final isTeknisi = currentUser?.isTeknisi ?? false;
    final myUserId = currentUser?.id;
    final myStories = myUserId != null ? (groupedStories[myUserId] ?? []) : <StoryModel>[];
    
    // Filter out current user's stories from the list of other users
    final otherUserIds = userIdsOrder.where((id) => id != myUserId).toList();

    if (stories.isEmpty && !isTeknisi) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'LATEST STORIES',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2C1810),
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: otherUserIds.length + (isTeknisi ? 1 : 0),
            itemBuilder: (context, index) {
              if (isTeknisi && index == 0) {
                // Technician's "Story Anda" bubble
                final avatarUrl = currentUser?.avatarUrl;
                final fullName = currentUser?.name ?? 'Teknisi';
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (myStories.isNotEmpty) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StoryViewScreen(
                                  stories: myStories.reversed.toList(),
                                  initialIndex: 0,
                                ),
                              ),
                            ).then((_) {
                              if (context.mounted) {
                                context.read<StoryProvider>().fetchStories();
                              }
                            });
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreateStoryScreen()),
                            ).then((_) {
                              if (context.mounted) {
                                context.read<StoryProvider>().fetchStories();
                              }
                            });
                          }
                        },
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            (() {
                              final allMyStoriesViewed = myStories.isNotEmpty &&
                                  myStories.every((story) => storyProvider.viewedStoryIds.contains(story.id));
                              return Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: myStories.isNotEmpty
                                        ? (allMyStoriesViewed ? Colors.grey : const Color(0xFFE5B94C))
                                        : const Color(0xFF2C1810),
                                    width: myStories.isNotEmpty ? 3.5 : 3,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF2C1810),
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                padding: myStories.isNotEmpty ? const EdgeInsets.all(2.5) : EdgeInsets.zero,
                                child: myStories.isNotEmpty
                                    ? Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFF2C1810), width: 2),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(32),
                                          child: avatarUrl != null
                                              ? Image.network(avatarUrl, fit: BoxFit.cover)
                                              : Center(
                                                  child: Text(
                                                    fullName.isNotEmpty ? fullName[0].toUpperCase() : 'T',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.w900,
                                                      color: const Color(0xFF2C1810),
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(32),
                                        child: avatarUrl != null
                                            ? Image.network(avatarUrl, fit: BoxFit.cover)
                                            : Center(
                                                child: Text(
                                                  fullName.isNotEmpty ? fullName[0].toUpperCase() : 'T',
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.w900,
                                                    color: const Color(0xFF2C1810),
                                                  ),
                                                ),
                                              ),
                                      ),
                              );
                            })(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const CreateStoryScreen()),
                                ).then((_) {
                                  if (context.mounted) {
                                    context.read<StoryProvider>().fetchStories();
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5B94C), // Gold
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF2C1810), width: 2),
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  size: 14,
                                  color: Color(0xFF2C1810),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Story Anda',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2C1810),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Normal story bubble
              final storyListIndex = isTeknisi ? index - 1 : index;
              final targetUserId = otherUserIds[storyListIndex];
              final userStoriesList = groupedStories[targetUserId]!;
              final latestStory = userStoriesList.first;
              final userName = latestStory.userName?.split(' ').first ?? 'Teknisi';

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StoryViewScreen(
                              stories: userStoriesList.reversed.toList(),
                              initialIndex: 0,
                            ),
                          ),
                        ).then((_) {
                          if (context.mounted) {
                            context.read<StoryProvider>().fetchStories();
                          }
                        });
                      },
                      child: (() {
                        final allStoriesViewed = userStoriesList.every((story) => storyProvider.viewedStoryIds.contains(story.id));
                      return Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: allStoriesViewed ? Colors.grey : const Color(0xFFE5B94C), // Gold border indicating unseen story, grey for seen
                            width: 3.5,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF2C1810),
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(2.5),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF2C1810), width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: latestStory.userAvatarUrl != null
                                ? Image.network(latestStory.userAvatarUrl!, fit: BoxFit.cover)
                                : Container(
                                    color: const Color(0xFF4A90D9),
                                    child: Center(
                                      child: Text(
                                        userName.isNotEmpty ? userName[0].toUpperCase() : 'T',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      );
                    })(),
                  ),
                    const SizedBox(height: 6),
                    Text(
                      userName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2C1810),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
