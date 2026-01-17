import 'package:flutter/material.dart';

class PrivilegePage extends StatefulWidget {
  const PrivilegePage({super.key});

  @override
  State<PrivilegePage> createState() => _PrivilegePageState();
}

class _PrivilegePageState extends State<PrivilegePage> {
  final Map<String, Map<String, Map<String, List<String>>>> allSections = {
    "Staff Management": {
      "Add Staff": {
        "Create": ["create staff"],
        "View": [],
        "Edit": [],
        "Delete": [],
        "Other": []
      },
      "View Staff": {
        "Create": [],
        "View": ["view staff", "view staff dashboard", "view staff report"],
        "Edit": [
          "update dashboard",
          "update staff",
          "update staff password",
          "update staff permission"
        ],
        "Delete": ["delete staff"],
        "Other": ["download staff"]
      },
      "Set Target": {
        "Create": ["create set target"],
        "View": [],
        "Edit": ["edit set target"],
        "Delete": ["delete set target"],
        "Other": []
      },
    },

    "Lead Management": {
      "Dashboard": {
        "Create": ["create call management facebook settings"],
        "View": ["view call management whatsapp settings"],
        "Edit": ["update call management facebook settings"],
        "Delete": ["delete call management facebook settings"],
        "Other": []
      }
    }
  };

  // Checkbox state storage
  Map<String, bool> checks = {};
  Map<String, bool> expandedSection = {};

  @override
  void initState() {
    super.initState();
    _generateCheckboxState();
  }

  void _generateCheckboxState() {
    allSections.forEach((section, menus) {
      expandedSection[section] = true;

      menus.forEach((menu, categories) {
        categories.forEach((category, items) {
          for (var item in items) {
            checks[item] = true;
          }
        });
      });
    });
  }

  // ================================
  //  BUILD UI
  // ================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privileges"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: allSections.keys.map((sectionName) {
          return _buildSection(sectionName, allSections[sectionName]!);
        }).toList(),
      ),
    );
  }

  // ================================
  //  SECTION WIDGET
  // ================================
  Widget _buildSection(
      String title, Map<String, Map<String, List<String>>> menus) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.blue.shade200),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            tileColor: Colors.blue.shade50,
            title: Text(
              title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            trailing: Icon(
              expandedSection[title]!
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: Colors.blue,
            ),
            onTap: () {
              setState(() {
                expandedSection[title] = !expandedSection[title]!;
              });
            },
          ),

          if (expandedSection[title]!)
            Column(
              children: menus.keys.map((menuName) {
                return _buildMenuCard(menuName, menus[menuName]!);
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ================================
  //  MENU CARD WIDGET
  // ================================
  Widget _buildMenuCard(
      String menuName, Map<String, List<String>> categories) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(menuName,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),

            const SizedBox(height: 10),

            Column(
              children: categories.keys.map((categoryName) {
                final items = categories[categoryName]!;

                if (items.isEmpty) return const SizedBox();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(categoryName,
                          style: TextStyle(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold)),

                      const SizedBox(height: 6),

                      ...items.map((item) {
                        return CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item),
                          dense: true,
                          value: checks[item],
                          onChanged: (value) {
                            setState(() {
                              checks[item] = value!;
                            });
                          },
                        );
                      }).toList(),
                    ],
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
