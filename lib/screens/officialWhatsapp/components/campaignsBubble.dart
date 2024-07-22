import 'package:flutter/material.dart';
import '../campaignsChatScreen.dart';
import '../colorConst.dart';


Widget campaignsBubble(context, campaignsListModel) {
  return ListTile(
    tileColor: Colors.white,
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CampaignsChatScreen(
              groupId: campaignsListModel.groupId, nav: '',
            ),
          ));
    },
    leading: Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(campaignsListModel.profilePic),
          ),
          borderRadius: BorderRadius.circular(30)),
    ),
    title: Text(
      campaignsListModel.campaignName,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
    subtitle: Row(
      children: [
        campaignsListModel.fromMe == true
            ? const Icon(
          Icons.done_all,
          size: 18,
          color: ColorConstant.messageSeen,
        )
            : const SizedBox(),
        const SizedBox(
          width: 5,
        ),
        SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: const Text(
              'last Message',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
      ],
    ),
    trailing: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '12.30',
          style: TextStyle(
              fontSize: 10,
              color: Colors.grey[400]),
        ),
        const SizedBox(
          height: 4,
        ),
      ],
    ),
  );
}
