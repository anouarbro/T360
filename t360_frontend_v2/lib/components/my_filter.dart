import 'package:flutter/material.dart';

class MyFilter extends StatefulWidget {
  final List<Map<String, dynamic>> items; // List of filterable items
  final List<List<String>> selectedItems; // List of initially selected items

  const MyFilter({
    super.key,
    required this.items,
    required this.selectedItems,
  });

  @override
  State<MyFilter> createState() => _MyFilterState();
}

class _MyFilterState extends State<MyFilter>
    with SingleTickerProviderStateMixin {
  late List<List<String>>
      _tempSelectedItems; // Temporary list to track selected items
  late TabController _tabController; // Tab controller to manage tabs
  int _previousIndex = 0; // To keep track of the previous tab index

  @override
  void initState() {
    super.initState();

    //! Initialize temporary selected items with widget's selected items
    _tempSelectedItems = List<List<String>>.from(widget.selectedItems);

    //! Set the initial tab index based on selected items
    int initialIndex = _getInitialTabIndex();

    //! Initialize TabController with the number of items and initial index
    _tabController = TabController(
        length: widget.items.length, vsync: this, initialIndex: initialIndex);

    //! Add listener to handle tab changes
    _tabController.addListener(() async {
      if (_tabController.indexIsChanging) {
        //! If there are selected items and the user tries to switch tabs
        if (_tempSelectedItems.isNotEmpty &&
            _tempSelectedItems.any((element) =>
                element[0] != widget.items[_tabController.index]['category'])) {
          //! Show confirmation dialog if the user is switching with selected items
          bool shouldSwitch = await _showConfirmationDialog();

          //! If user decides not to switch, revert to previous tab
          if (!shouldSwitch) {
            _tabController.index = _previousIndex;
          } else {
            setState(() {
              _tempSelectedItems.clear(); // Clear selected items if switching
            });
          }
        }
        _previousIndex = _tabController.index; // Update the previous index
      }
    });
  }

  //! Method to determine the initial tab based on the selected items
  int _getInitialTabIndex() {
    if (_tempSelectedItems.isNotEmpty) {
      String firstCategory = _tempSelectedItems.first[0];
      for (int i = 0; i < widget.items.length; i++) {
        if (widget.items[i]['category'] == firstCategory) {
          return i;
        }
      }
    }
    return 0; // Default to first tab
  }

  //! Show confirmation dialog when switching tabs with selected items
  Future<bool> _showConfirmationDialog() async {
    final theme = Theme.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: theme.scaffoldBackgroundColor,
              content: Text(
                'You have selected items that will be lost. Are you sure you want to switch tabs?',
                style:
                    TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
              ),
              actions: [
                ElevatedButton(
                  style: theme.elevatedButtonTheme.style,
                  onPressed: () => Navigator.pop(context, false), // Cancel
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  style: theme.elevatedButtonTheme.style,
                  onPressed: () => Navigator.pop(context, true), // Continue
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  //! Method to add/remove items from temporary selected list
  void _itemChange(List<String> itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _tempSelectedItems.add(itemValue); // Add item if selected
      } else {
        _tempSelectedItems.removeWhere((element) =>
            element.join() == itemValue.join()); // Remove item if unselected
      }
    });
  }

  //! Method to cancel and close the filter dialog
  void _cancel() {
    Navigator.pop(context);
  }

  //! Method to submit the selected items
  void _submit() {
    Navigator.pop(context, _tempSelectedItems); // Return the selected items
  }

  //! Method to clear the temporary selected items
  void _clear() {
    setState(() {
      _tempSelectedItems.clear(); // Clear all selected items
    });
  }

  //! Method to get the count of selected sub-items for a specific category and main item
  int _getSelectedSubItemCount(String category, String mainItem) {
    return _tempSelectedItems
        .where((selectedItem) =>
            selectedItem[0] == category && selectedItem[1] == mainItem)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Get the current theme
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width
    bool isLargeScreen = screenWidth > 1100; // Check if it's a large screen

    //! Main layout of the filter dialog
    return AlertDialog(
      backgroundColor: theme.scaffoldBackgroundColor, // Dialog background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      //! Title section with close button
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon: Icon(
              Icons.close,
              color:
                  theme.textTheme.headlineMedium?.color, // Close button color
            ),
            onPressed: _cancel, // Close the dialog when pressed
          ),
        ],
      ),
      //! Content of the filter dialog
      content: SizedBox(
        width: screenWidth * 0.9, // Width of the dialog
        height:
            MediaQuery.of(context).size.height * 0.9, // Height of the dialog
        child: Column(
          children: [
            //! TabBar at the top to switch between categories
            SizedBox(
              width: screenWidth * 0.9,
              child: TabBar(
                controller: _tabController,
                isScrollable: false, // Tabs are not scrollable
                indicatorColor:
                    theme.colorScheme.primary, // Tab indicator color
                tabs: widget.items.map<Widget>((item) {
                  bool isSelected = _tabController.index ==
                      widget.items.indexOf(item); // Check if tab is selected
                  String category = item['category']; // Get category name
                  return Container(
                    decoration: const BoxDecoration(),
                    child: Opacity(
                      opacity: isSelected
                          ? 1.0
                          : 0.6, // Change opacity based on selection
                      child:
                          Tab(text: category), // Display category as tab label
                    ),
                  );
                }).toList(),
                labelColor: theme.colorScheme.onSurface, // Selected label color
                unselectedLabelColor:
                    theme.colorScheme.onSurface, // Unselected label color
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold), // Selected label style
                unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal), // Unselected label style
                dividerColor: Colors.transparent, // Remove divider between tabs
              ),
            ),
            //! TabBarView to display items under each category
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: widget.items.map<Widget>((item) {
                  final itemWidgets = <Widget>[];

                  //! Generate widgets for each item in the category
                  for (int i = 0; i < item['items'].length; i += 2) {
                    final item1 = item['items'][i];
                    final item2 = i + 1 < item['items'].length
                        ? item['items'][i + 1]
                        : null;

                    //! Display items in rows for large screens, columns for small screens
                    if (isLargeScreen) {
                      itemWidgets.add(
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child:
                                    _buildItemContainer(item, item1, context)),
                            if (item2 != null)
                              Expanded(
                                  child: _buildItemContainer(
                                      item, item2, context)),
                          ],
                        ),
                      );
                    } else {
                      itemWidgets.add(
                        Column(
                          children: [
                            _buildItemContainer(item, item1, context),
                            if (item2 != null)
                              _buildItemContainer(item, item2, context),
                          ],
                        ),
                      );
                    }
                  }

                  //! Return a ListView of the item widgets
                  return ListView(
                    shrinkWrap: true,
                    children: itemWidgets,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      //! Actions (Clear and Submit buttons) at the bottom
      actions: [
        ElevatedButton(
          style: theme.elevatedButtonTheme.style,
          onPressed: _clear, // Clear selected items
          child: const Text(
            'Clear',
            style: TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton(
          style: theme.elevatedButtonTheme.style,
          onPressed: _submit, // Submit selected items
          child: const Text(
            'Submit',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  //! Build method to create each item container inside the tab view
  Widget _buildItemContainer(Map<String, dynamic> item,
      Map<String, dynamic> itemData, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: theme.listTileTheme.tileColor, // Container background color
        borderRadius: BorderRadius.circular(10), // Rounded corners
        boxShadow: const [
          BoxShadow(
            color: Colors.black12, // Box shadow for a subtle effect
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      //! ExpansionTile to show sub-items when clicked
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Theme(
          data: theme.copyWith(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            iconColor: theme.colorScheme.onSurface, // Icon color
            backgroundColor: theme.listTileTheme.tileColor, // Background color
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //! Display the item name
                Text(
                  itemData['name'],
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
                //! Display the count of selected sub-items
                Text(
                  '${_getSelectedSubItemCount(item['category'], itemData['name'])}${_getSelectedSubItemCount(item['category'], itemData['name']) == 1 ? ' item' : ' items'}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
            //! List of sub-items
            children: <Widget>[
              Column(
                children: itemData['subItems'].map<Widget>((subSubItem) {
                  //! Construct the full path for the sub-item
                  final List<String> fullPath = [
                    item['category'] as String,
                    itemData['name'] as String,
                    subSubItem as String
                  ];
                  //! Check if the sub-item is selected
                  final isSelected = _tempSelectedItems
                      .any((element) => element.join() == fullPath.join());

                  return Column(
                    children: [
                      const Divider(
                          color: Colors.grey), // Divider between sub-items
                      //! CheckboxListTile to select/deselect sub-items
                      CheckboxListTile(
                        checkColor: theme.listTileTheme.tileColor,
                        activeColor: theme.colorScheme.primary,
                        title: Text(subSubItem),
                        value: isSelected,
                        onChanged: (bool? value) {
                          _itemChange(
                              fullPath, value ?? false); // Handle item change
                        },
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
