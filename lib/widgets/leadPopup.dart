import 'package:flutter/material.dart';

class LeadCategoryPopup extends StatelessWidget {
  final int categoryCount;
  final List<LeadCategory> leadCategories;
  final Function(String) onCategorySelected;
  
  const LeadCategoryPopup({
    Key? key,
    required this.categoryCount,
    required this.leadCategories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: categoryCount.toString() != "1" && categoryCount.toString() != "",
      child: PopupMenuButton<int>(
        child: Container(
          height: 20,
          width: 20,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              categoryCount.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        itemBuilder: (context) {
          return [
            for (int i = 0; i < leadCategories.length; i++)
              PopupMenuItem<int>(
                value: int.parse(leadCategories[i].callMasterId.toString()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        leadCategories[i].isSelected == true
                            ? const Icon(
                                Icons.done,
                                size: 20,
                                color: Colors.green,
                              )
                            : const SizedBox(width: 15),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Text(
                            leadCategories[i].leadCategory.toString(),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: leadCategories[i].leadStatus == "New"
                                  ? Colors.blue
                                  : leadCategories[i].leadStatus == "Follow Up"
                                      ? Colors.yellow
                                      : leadCategories[i].leadStatus == "Rejected"
                                          ? Colors.red
                                          : const Color.fromARGB(255, 96, 66, 226),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              leadCategories[i].leadStatus.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 7.5,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              'Staff: ${leadCategories[i].staffName.toString()}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              'Created Date: ${leadCategories[i].createdDate.toString()}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ];
        },
        onSelected: (value) {
          onCategorySelected(value.toString());
        },
      ),
    );
  }
}

// Example usage in a ListView item
class MyListItem extends StatelessWidget {
  final Item item;
  final List<LeadCategory> leadCategories;
  final Function(String) onCategorySelected;

  const MyListItem({
    Key? key,
    required this.item,
    required this.leadCategories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LeadCategoryPopup(
            categoryCount: item.categoryCount,
            leadCategories: leadCategories,
            onCategorySelected: onCategorySelected,
          ),
        ],
      ),
    );
  }
}

// Dummy classes for demonstration
class LeadCategory {
  final String callMasterId;
  final String leadCategory;
  final String leadStatus;
  final String staffName;
  final String createdDate;
  final bool isSelected;

  LeadCategory({
    required this.callMasterId,
    required this.leadCategory,
    required this.leadStatus,
    required this.staffName,
    required this.createdDate,
    this.isSelected = false,
  });
}

class Item {
  final String title;
  final int categoryCount;

  Item({required this.title, required this.categoryCount});
}

// Example usage in a parent widget
class ParentWidget extends StatelessWidget {
  final List<Item> items;
  final List<LeadCategory> leadCategories;
  
  const ParentWidget({
    Key? key,
    required this.items,
    required this.leadCategories,
  }) : super(key: key);

  void handleCategorySelected(String callMasterId) {
    // Handle the category selection here
    print("Selected category ID: $callMasterId");
    // You can call getData() or any other function here
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return MyListItem(
          item: items[index],
          leadCategories: leadCategories,
          onCategorySelected: handleCategorySelected,
        );
      },
    );
  }
}