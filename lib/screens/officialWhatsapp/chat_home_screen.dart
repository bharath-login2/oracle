import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:login2/screens/leadManagement/projectDashboard.dart';
import 'package:login2/screens/officialWhatsapp/campaignsChatScreen.dart';
import 'package:login2/screens/officialWhatsapp/chatScreen.dart';
import 'package:login2/screens/officialWhatsapp/components/campaignsBubble.dart';
import 'package:login2/screens/officialWhatsapp/components/chat_list_item.dart';
import 'package:login2/screens/officialWhatsapp/contact_list.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shimmer/shimmer.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/common.dart';
import '../../models/officialWhatsapp/chat_list_model.dart';
import '../../models/officialWhatsapp/campaignsListModel.dart';
import '../../models/officialWhatsapp/officialWhatsappConfigureModel.dart';
import '../../service/service.dart';
import '../leadManagement/dashboard.dart';
import 'colorConst.dart';
import 'components/tab_bar.dart';

// ignore: must_be_immutable
class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> with WidgetsBindingObserver {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = true;
  bool isSearch = false;
  String whatsAppConfigured = "true";
  late final WebSocketChannel socket;
  String? contactPermission = '';

  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  List<ChatData> items = [];
  int page = 1;
  int pageSize = 20;
  TextEditingController searchController = TextEditingController();
  ChatListModel? chatListModel;
  CampaignsListModel? campaignsListModel;
  OfficialWhatsappConfigeModel? officialWhatsAppConfigure;
  String userId = "";
  String token = '';
  String ProjectDashboardPermission = '';
  String LeadDashboard = '';
  int add = 1;
  bool isConfigered = true;
  
  // Cache control variables
  static const String _chatCacheKey = 'chat_list_cache_v10';
  static const String _chatTimestampKey = 'chat_last_update';
  static const String _scrollPositionKey = 'chat_scroll_position';
  static const String _lastChatGroupIdKey = 'last_chat_group_id';
  bool _loadingFromCache = false;
  String _currentSearch = '';
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  
  // Scroll position tracking
  int _lastScrollIndex = 0;
  bool _shouldRestoreScroll = false;
  bool _isInitialLoadComplete = false;
  String? _lastOpenedGroupId;
  bool _isNavigatingToChat = false;
  bool _isPoppingBack = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Load saved state first
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadSavedState();
      await _initLoad();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    socket.sink.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Listen for route changes
    ModalRoute? route = ModalRoute.of(context);
    if (route != null) {
      route.addScopedWillPopCallback(() async {
        if (!_isNavigatingToChat && !_isPoppingBack) {
          await _saveCurrentScrollPosition();
        }
        return true;
      });
    }
  }

  @override
  void didPopNext() {
    // Called when returning to this route
   // super.didPopNext();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshDataAndRestorePosition();
    });
  }

  Future<void> _initLoad() async {
    // Show loader immediately
    setState(() {
      isLoading = true;
    });
    
    // Load from cache first for instant display
    await _loadFromCache();
    
    // Then fetch fresh data
    await _fetchInitialData();
    
    // Set up scroll listener for pagination
    itemPositionsListener.itemPositions.addListener(_onLoadMore);
    
    // Set up scroll position listener
    itemPositionsListener.itemPositions.addListener(_saveScrollPositionOnScroll);
    
    // Load other data
    chatCampaignsList('');
    getOfficialConfigaration();
    socketStream();
    
    // Mark initial load as complete
    setState(() {
      _isInitialLoadComplete = true;
      isLoading = false;
    });
    
    // Restore scroll position after initial load
    if (_shouldRestoreScroll) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollPosition();
      });
    }
  }

  void _saveScrollPositionOnScroll() {
    if (itemPositionsListener.itemPositions.value.isNotEmpty) {
      final visiblePositions = itemPositionsListener.itemPositions.value;
      if (visiblePositions.isNotEmpty) {
        final firstVisible = visiblePositions.first;
        _lastScrollIndex = firstVisible.index;
        
        // Auto-save scroll position every 10 items
        if (_lastScrollIndex % 10 == 0) {
          Common.saveSharedPref(_scrollPositionKey, _lastScrollIndex.toString());
        }
      }
    }
  }

  Future<void> _saveCurrentScrollPosition() async {
    try {
      if (itemPositionsListener.itemPositions.value.isNotEmpty) {
        final visiblePositions = itemPositionsListener.itemPositions.value;
        if (visiblePositions.isNotEmpty) {
          final firstVisible = visiblePositions.first;
          _lastScrollIndex = firstVisible.index;
          await Common.saveSharedPref(_scrollPositionKey, _lastScrollIndex.toString());
          log('Saved scroll position on exit: $_lastScrollIndex');
        }
      }
    } catch (e) {
      log('Error saving current scroll position: $e');
    }
  }

  void _onLoadMore() {
    if (!_isLoadingMore && 
        _hasMoreData && 
        items.isNotEmpty &&
        itemPositionsListener.itemPositions.value.isNotEmpty &&
        itemPositionsListener.itemPositions.value.last.index >= items.length - 5) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      final moreData = await HttpService.fetchChatList(_currentSearch, page, pageSize);
      if (moreData != null && moreData.data.isNotEmpty) {
        setState(() {
          items.addAll(moreData.data);
          page++;
          
          if (moreData.data.length < pageSize) {
            _hasMoreData = false;
          }
        });
        
        // Save updated cache if not searching
        if (_currentSearch.isEmpty) {
          _saveToCache();
        }
      } else {
        _hasMoreData = false;
      }
    } catch (e) {
      log('Error loading more data: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  socketStream() async {
    userId = await Common.getSharedPref("userId");
    final wsProtocol =
        (Uri.parse('https://dummy').scheme == 'https') ? 'wss://' : 'ws://';
    const wsHost = 'websocket.login2.co.in';
    const wsPort = '8080';

    socket = WebSocketChannel.connect(
      Uri.parse('$wsProtocol$wsHost:$wsPort'),
    );
    socket.sink.add(jsonEncode({'type': 'register', 'userId': "#$userId"}));
    socket.stream.listen((response) async {
      try {
        FlutterRingtonePlayer().playNotification();
        log("socket success - new message received");
        
        // Handle socket update without clearing data
        await _handleSocketUpdate(response);
      } catch (e) {
        log(e.toString());
      }
    });
  }

  Future<void> _handleSocketUpdate(String response) async {
    try {
      final data = jsonDecode(response);
      
      if (data['type'] == 'new_message') {
        final groupId = data['groupId']?.toString();
        final message = data['message']?.toString();
        final sender = data['sender']?.toString();
        
        if (groupId != null) {
          // Find and update the specific chat
          final index = items.indexWhere((chat) => chat.groupId == groupId);
          if (index != -1) {
            setState(() {
              // Create updated chat manually
              final updatedChat = _createUpdatedChat(items[index], message, sender);
              
              // Remove and insert at beginning for most recent chat
              items.removeAt(index);
              items.insert(0, updatedChat);
              
              // Update scroll position if we're tracking this chat
              if (_lastOpenedGroupId == groupId) {
                _lastScrollIndex = 0;
              }
            });
            
            // Save updated list to cache
            _saveToCache();
          } else {
            // If chat not in list, do a soft refresh
            await _softRefresh();
          }
        }
      }
    } catch (e) {
      log('Error handling socket update: $e');
    }
  }

  ChatData _createUpdatedChat(ChatData originalChat, String? message, String? sender) {
    final now = DateTime.now();
    final currentTime = now.toIso8601String();
    
    return ChatData(
      groupId: originalChat.groupId,
      profilePic: originalChat.profilePic,
      groupName: originalChat.groupName,
      phoneNumber: originalChat.phoneNumber,
      lastMsgTime: currentTime,
      canSendMessage: originalChat.canSendMessage,
      msgStatus: originalChat.msgStatus,
      lastMessage: message ?? originalChat.lastMessage,
      fromMe: originalChat.fromMe,
      unreadMessageCount: originalChat.unreadMessageCount + 1,
    );
  }

  Future<void> _softRefresh() async {
    try {
      final newData = await HttpService.fetchChatList(_currentSearch, 1, pageSize);
      if (newData != null && newData.data.isNotEmpty) {
        setState(() {
          _mergeChatLists(newData.data);
        });
        _saveToCache();
      }
    } catch (e) {
      log('Soft refresh error: $e');
    }
  }

  void _mergeChatLists(List<ChatData> newChats) {
    final Map<String, ChatData> chatMap = {};
    
    // Add existing chats to map
    for (final chat in items) {
      chatMap[chat.groupId] = chat;
    }
    
    // Update with new chats (new data takes priority)
    for (final newChat in newChats) {
      chatMap[newChat.groupId] = newChat;
    }
    
    // Sort by last message time (most recent first)
    items = chatMap.values.toList()
      ..sort((a, b) => b.lastMsgTime.compareTo(a.lastMsgTime));
  }

  getOfficialConfigaration() async {
    officialWhatsAppConfigure = await HttpService.officialWhatsAppConfigure();
    if (officialWhatsAppConfigure != null) {
      isConfigered = officialWhatsAppConfigure!.data!;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (pop) async {
        if (!pop) return;
        
        token = await Common.getSharedPref("token");
        ProjectDashboardPermission = await Common.getSharedPref("ProjectDashboardPermission");
        LeadDashboard = await Common.getSharedPref("LeadDashboard");
        
        if (context.mounted) {
          ProjectDashboardPermission == "true"
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDashboard(),
                  ),
                )
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Dashboard(token),
                  ),
                );
        }
      },
      child: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            key: scaffoldKey,
            floatingActionButton: Visibility(
              visible: isConfigered,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WhatsappContactList(),
                    ),
                  );
                },
                backgroundColor: ColorConstant.barGreen,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
            backgroundColor: Colors.grey.shade100,
            body: Container(
              color: Colors.white,
              child: SafeArea(
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: ColorConstant.barGreen,
                        ),
                        padding: const EdgeInsets.only(right: 10),
                        height: 60,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 12,
                            right: 12,
                            top: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: isSearch == true
                                    ? SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.75,
                                        child: TextFormField(
                                          autofocus: true,
                                          controller: searchController,
                                          onChanged: (value) async {
                                            page = 1;
                                            add = 1;
                                            _hasMoreData = true;
                                            _currentSearch = value;
                                            _shouldRestoreScroll = false;
                                            await _handleSearch(value);
                                          },
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    top: 5, bottom: 5),
                                            prefixIcon:
                                                const Icon(Icons.search),
                                            hintText: 'Search',
                                            fillColor: ColorConstant.white,
                                            filled: true,
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide.none,
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Icon(
                                              Icons.arrow_back,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          RichText(
                                            text: const TextSpan(
                                              text: 'WhatsApp',
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSearch = !isSearch;
                                    if (!isSearch) {
                                      searchController.clear();
                                      _handleSearch('');
                                    }
                                  });
                                },
                                child: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      tabbar(),
                      isConfigered
                          ? Expanded(
                              child: TabBarView(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: NotificationListener<ScrollNotification>(
                                        onNotification: (scrollNotification) {
                                          // Save scroll position on user scroll
                                          if (scrollNotification is ScrollUpdateNotification &&
                                              scrollNotification.dragDetails != null) {
                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                              _saveCurrentScrollPosition();
                                            });
                                          }
                                          return false;
                                        },
                                        child: RefreshIndicator(
                                          onRefresh: () async {
                                            // Full refresh on pull-to-refresh
                                            await _fullRefresh();
                                          },
                                          child: whatsAppConfigured == "true"
                                              ? isLoading
                                                  ? buildLoaderListItem()
                                                  : ScrollablePositionedList
                                                      .builder(
                                                      initialScrollIndex: _shouldRestoreScroll && 
                                                                          _lastScrollIndex < items.length 
                                                          ? _lastScrollIndex 
                                                          : 0,
                                                      initialAlignment: 0,
                                                      itemScrollController:
                                                          itemScrollController,
                                                      itemPositionsListener:
                                                          itemPositionsListener,
                                                      itemCount: items.length +
                                                          (_hasMoreData ? 1 : 0),
                                                      itemBuilder:
                                                          (context, index) {
                                                        if (index ==
                                                            items.length) {
                                                          return _buildLoadMoreIndicator();
                                                        }
                                                        return GestureDetector(
                                                          onTap: () {
                                                            _saveAndNavigate(index);
                                                          },
                                                          child: chatListItem(
                                                              context,
                                                              items[index]),
                                                        );
                                                      },
                                                    )
                                              : Center(
                                                  child: SizedBox(
                                                    height: MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.5,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          child: Image.asset(
                                                            "assets/icons/nodatafound.png",
                                                          ),
                                                        ),
                                                        const Text(
                                                          "",
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: StatefulBuilder(
                                        builder: (context, setState) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5),
                                        child: RefreshIndicator(
                                          onRefresh: () async {
                                            await Future.delayed(
                                                const Duration(
                                                    milliseconds: 200));
                                            CampaignsListModel?
                                                campaignsListModel =
                                                await HttpService
                                                    .fetchCampaignsList('');
                                            if (campaignsListModel != null) {
                                              setState(() {});
                                            }
                                          },
                                          child: ListView.builder(
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: campaignsListModel!
                                                .data!.length,
                                            itemBuilder: (context, index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CampaignsChatScreen(
                                                        groupId:
                                                            campaignsListModel!
                                                                .data![index]
                                                                .groupId
                                                                .toString(),
                                                        nav: '',
                                                      ),
                                                    ),
                                                  ).then((v) {
                                                    chatCampaignsList('');
                                                  });
                                                },
                                                child: campaignsBubble(
                                                  context,
                                                  campaignsListModel!
                                                      .data![index],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            )
                          : Center(
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Image.asset(
                                        "assets/icons/official_whatsapp.png",
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      "Configure whatsapp !",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveAndNavigate(int index) async {
    if (index >= items.length) return;
    
    // Set navigation flag
    _isNavigatingToChat = true;
    
    // Save current scroll position and chat info
    _lastScrollIndex = index;
    _lastOpenedGroupId = items[index].groupId;
    _shouldRestoreScroll = true;
    
    // Get current visible positions before navigating
    if (itemPositionsListener.itemPositions.value.isNotEmpty) {
      final visiblePositions = itemPositionsListener.itemPositions.value;
      if (visiblePositions.isNotEmpty) {
        final firstVisible = visiblePositions.first;
        _lastScrollIndex = firstVisible.index;
        
        // Save precise scroll position
        await Common.saveSharedPref(_scrollPositionKey, _lastScrollIndex.toString());
        await Common.saveSharedPref(_lastChatGroupIdKey, _lastOpenedGroupId!);
        log('Saved before chat navigation - Index: $_lastScrollIndex, Group: $_lastOpenedGroupId');
      }
    }
    
    // Navigate to chat screen
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          groupId: items[index].groupId,
          nav: "",
        ),
      ),
    );
    
    // Reset navigation flag
    _isNavigatingToChat = false;
    
    // Refresh data and restore position when returning
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshDataAndRestorePosition();
    });
  }

  Widget _buildLoadMoreIndicator() {
    return _isLoadingMore && items.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                color: ColorConstant.barGreen,
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Future<void> _loadSavedState() async {
    try {
      // Load scroll position
      final scrollIndexString = await Common.getSharedPref(_scrollPositionKey) ?? "0";
      _lastScrollIndex = int.tryParse(scrollIndexString) ?? 0;
      
      // Load last opened chat
      _lastOpenedGroupId = await Common.getSharedPref(_lastChatGroupIdKey);
      
      // Only restore if we have a valid saved position
      if (_lastScrollIndex > 0) {
        _shouldRestoreScroll = true;
        log('Will restore to saved index: $_lastScrollIndex');
      }
    } catch (e) {
      log('Error loading saved state: $e');
    }
  }

  void _restoreScrollPosition() {
    if (!_shouldRestoreScroll || 
        _lastScrollIndex < 0 || 
        _lastScrollIndex >= items.length ||
        !itemScrollController.isAttached) {
      return;
    }
    
    try {
      // Small delay to ensure list is fully built
      Future.delayed(const Duration(milliseconds: 300), () {
        if (itemScrollController.isAttached && 
            _lastScrollIndex < items.length &&
            items.isNotEmpty) {
          
          // Ensure index is within bounds
          final targetIndex = _lastScrollIndex.clamp(0, items.length - 1);
          
          itemScrollController.scrollTo(
            index: targetIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0,
          );
          
          log('Restored scroll to index: $targetIndex');
          
          // Reset flags
          _shouldRestoreScroll = false;
        }
      });
    } catch (e) {
      log('Error restoring scroll position: $e');
    }
  }

  Future<void> _refreshDataAndRestorePosition() async {
    // Don't refresh if already loading
    if (isLoading || _isLoadingMore) return;
    
    // Save current position before refresh
    final savedIndex = _lastScrollIndex;
    final savedGroupId = _lastOpenedGroupId;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      // Refresh data from server
      final freshData = await HttpService.fetchChatList(_currentSearch, 1, pageSize);
      
      if (freshData != null) {
        setState(() {
          items = freshData.data;
          _hasMoreData = freshData.data.length >= pageSize;
          page = 2;
          isLoading = false;
        });
        
        // Save to cache
        if (_currentSearch.isEmpty) {
          await _saveToCache();
        }
        
        // Try to find the same chat in new data
        if (savedGroupId != null && items.isNotEmpty) {
          final newIndex = items.indexWhere((chat) => chat.groupId == savedGroupId);
          if (newIndex != -1) {
            _lastScrollIndex = newIndex;
          } else if (savedIndex < items.length) {
            _lastScrollIndex = savedIndex;
          } else {
            _lastScrollIndex = 0;
          }
        } else if (savedIndex < items.length) {
          _lastScrollIndex = savedIndex;
        } else {
          _lastScrollIndex = 0;
        }
        
        // Restore scroll position after data is loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_lastScrollIndex < items.length && 
              itemScrollController.isAttached &&
              items.isNotEmpty) {
            
            // Ensure index is within bounds
            final targetIndex = _lastScrollIndex.clamp(0, items.length - 1);
            
            Future.delayed(const Duration(milliseconds: 100), () {
              if (itemScrollController.isAttached && 
                  targetIndex < items.length) {
                itemScrollController.scrollTo(
                  index: targetIndex,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  alignment: 0,
                );
                
                log('Restored after refresh to index: $targetIndex');
              }
            });
          }
        });
      }
    } catch (e) {
      log('Error refreshing data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadFromCache() async {
    try {
      if (!_isInitialLoadComplete) {
        setState(() {
          _loadingFromCache = true;
        });
      }
      
      final jsonString = await Common.getSharedPref(_chatCacheKey) ?? "";
      if (jsonString.isNotEmpty) {
        final decodeList = jsonDecode(jsonString);
        final List<Map<String, dynamic>> chatDataList =
            decodeList.cast<Map<String, dynamic>>();
        final List<ChatData> cachedList =
            chatDataList.map((json) => ChatData.fromJson(json)).toList();
        
        if (cachedList.isNotEmpty) {
          setState(() {
            items = cachedList;
            _loadingFromCache = false;
          });
          
          // If we have cached data, try to find and scroll to last opened chat
          if (_lastOpenedGroupId != null && items.isNotEmpty) {
            final lastIndex = items.indexWhere((chat) => chat.groupId == _lastOpenedGroupId);
            if (lastIndex != -1) {
              _lastScrollIndex = lastIndex;
            }
          }
        }
      }
    } catch (e) {
      log('Error loading from cache: $e');
    } finally {
      if (!_isInitialLoadComplete) {
        setState(() {
          _loadingFromCache = false;
        });
      }
    }
  }

  Future<void> _fetchInitialData() async {
    try {
      final freshData = await HttpService.fetchChatList(_currentSearch, 1, pageSize);
      if (freshData != null) {
        setState(() {
          if (freshData.data.isNotEmpty) {
            // Merge fresh data with cached data
            _mergeChatLists(freshData.data);
            
            // Check if we need to load more pages
            _hasMoreData = freshData.data.length >= pageSize;
            page = _hasMoreData ? 2 : 1;
          } else {
            _hasMoreData = false;
          }
        });
        
        // Save to cache only if not searching
        if (_currentSearch.isEmpty) {
          _saveToCache();
        }
      }
    } catch (e) {
      log('Error fetching initial data: $e');
    }
  }

  Future<void> _saveToCache() async {
    try {
      final itemsString = jsonEncode(items.map((item) => item.toJson()).toList());
      await Common.saveSharedPref(_chatCacheKey, itemsString);
      await Common.saveSharedPref(_chatTimestampKey, DateTime.now().toIso8601String());
    } catch (e) {
      log('Error saving to cache: $e');
    }
  }

  Future<void> _handleSearch(String value) async {
    _currentSearch = value;
    _shouldRestoreScroll = false;
    
    setState(() {
      isLoading = true;
    });
    
    if (value.isEmpty) {
      // Load from cache when search is cleared
      await _loadFromCache();
      
      // Also fetch fresh data in background
      _fetchInitialData();
      
      setState(() {
        isLoading = false;
      });
    } else {
      // Perform fresh search
      try {
        final searchData = await HttpService.fetchChatList(value, 1, pageSize);
        setState(() {
          if (searchData != null && searchData.data.isNotEmpty) {
            items = searchData.data;
            _hasMoreData = searchData.data.length >= pageSize;
            page = 2;
          } else {
            items.clear();
            _hasMoreData = false;
          }
          isLoading = false;
        });
      } catch (e) {
        log('Search error: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fullRefresh() async {
    // Save current scroll position before refresh
    final currentIndex = _lastScrollIndex;
    final currentGroupId = _lastOpenedGroupId;
    
    setState(() {
      isLoading = true;
      page = 1;
      _hasMoreData = true;
      _shouldRestoreScroll = true;
    });
    
    try {
      final freshData = await HttpService.fetchChatList(_currentSearch, 1, pageSize);
      setState(() {
        if (freshData != null && freshData.data.isNotEmpty) {
          items = freshData.data;
          _hasMoreData = freshData.data.length >= pageSize;
          page = 2;
        } else {
          items.clear();
          _hasMoreData = false;
        }
        isLoading = false;
      });
      
      // Try to restore to previous position or find the same chat
      if (currentGroupId != null && items.isNotEmpty) {
        final newIndex = items.indexWhere((chat) => chat.groupId == currentGroupId);
        _lastScrollIndex = newIndex != -1 ? newIndex : currentIndex;
      } else {
        _lastScrollIndex = currentIndex;
      }
      
      // Ensure index is within bounds
      if (_lastScrollIndex >= items.length) {
        _lastScrollIndex = items.isEmpty ? 0 : items.length - 1;
      }
      
      // Save to cache
      if (_currentSearch.isEmpty) {
        await _saveToCache();
      }
      
      // Restore scroll position
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_shouldRestoreScroll && 
            items.isNotEmpty && 
            itemScrollController.isAttached) {
          
          Future.delayed(const Duration(milliseconds: 200), () {
            if (itemScrollController.isAttached && 
                _lastScrollIndex < items.length) {
              
              final targetIndex = _lastScrollIndex.clamp(0, items.length - 1);
              
              itemScrollController.scrollTo(
                index: targetIndex,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                alignment: 0,
              );
              
              log('Restored after full refresh to index: $targetIndex');
            }
          });
        }
      });
    } catch (e) {
      log('Full refresh error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateSingleChat(String groupId) async {
    try {
      final freshData = await HttpService.fetchChatList('', 1, pageSize);
      if (freshData != null) {
        final updatedChatIndex = freshData.data.indexWhere(
          (chat) => chat.groupId == groupId,
        );
        
        if (updatedChatIndex != -1) {
          final updatedChat = freshData.data[updatedChatIndex];
          setState(() {
            final index = items.indexWhere((chat) => chat.groupId == groupId);
            if (index != -1) {
              items[index] = updatedChat;
            }
            _saveToCache();
          });
        }
      }
    } catch (e) {
      log('Error updating single chat: $e');
    }
  }

  chats(search) async {
    try {
      chatListModel = await HttpService.fetchChatList(search, page, pageSize);
      if (chatListModel != null) {
        setState(() {
          if (page == 1) {
            items = chatListModel!.data;
          } else {
            items.addAll(chatListModel!.data);
          }
          
          page++;
          isLoading = false;
        });
        
        if (search.isEmpty) {
          _saveToCache();
        }
      }
    } catch (e) {
      log('Error in chats: $e');
    }
    
    whatsAppConfigured = Common.getSharedPref("whatsapp");
  }

  chatCampaignsList(search) async {
    campaignsListModel = await HttpService.fetchCampaignsList(search);
    if (campaignsListModel != null) {
      setState(() {});
    }
  }

  Widget buildLoaderListItem() {
    return Shimmer.fromColors(
      enabled: true,
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 120.0,
                  color: Colors.white,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * .8,
                child: ListView.builder(
                  itemCount: 10,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 50.0,
                            height: 50.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 10.0,
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                ),
                                Container(
                                  width: double.infinity,
                                  height: 10.0,
                                  color: Colors.white,
                                  margin: const EdgeInsets.only(bottom: 8.0),
                                ),
                                Container(
                                  width: 100.0,
                                  height: 10.0,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget scrollShimmer() {
    return Shimmer.fromColors(
      enabled: true,
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 10.0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 8.0),
                      ),
                      Container(
                        width: double.infinity,
                        height: 10.0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 8.0),
                      ),
                      Container(
                        width: 100.0,
                        height: 10.0,
                        color: Colors.white,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 10.0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 8.0),
                      ),
                      Container(
                        width: double.infinity,
                        height: 10.0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 8.0),
                      ),
                      Container(
                        width: 100.0,
                        height: 10.0,
                        color: Colors.white,
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}