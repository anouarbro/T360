import 'package:flutter/material.dart';

class MyFilter extends StatefulWidget {
  final List<Map<String, dynamic>> b2bItems;
  final List<Map<String, dynamic>> b2cItems;
  final List<Map<String, dynamic>> selectedItems;
  final int initialTabIndex; // Add this to allow setting the initial tab index

  const MyFilter({
    super.key,
    required this.b2bItems,
    required this.b2cItems,
    required this.selectedItems,
    required this.initialTabIndex, // Required for the initial tab index
  });

  @override
  _MyFilterState createState() => _MyFilterState();
}

class _MyFilterState extends State<MyFilter>
    with SingleTickerProviderStateMixin {
  late List<Map<String, dynamic>> _tempSelectedItems;
  late TabController _tabController;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    // Clone the selectedItems into tempSelectedItems to modify selections in the dialog
    _tempSelectedItems = List<Map<String, dynamic>>.from(widget.selectedItems);

    // Initialize tab index based on where the last items were selected or passed index
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex, // Set initial tab index
    );

    _previousIndex = widget.initialTabIndex; // Track the starting index

    // Handle tab switching and possible selection loss
    _tabController.addListener(() async {
      if (_tabController.indexIsChanging && _tempSelectedItems.isNotEmpty) {
        bool shouldSwitch = await _showConfirmationDialog();
        if (!shouldSwitch) {
          _tabController.index = _previousIndex;
        }
        _previousIndex = _tabController.index;
      }
    });
  }

  // Confirmation dialog when switching tabs
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
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: theme.elevatedButtonTheme.style,
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Continue',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  // Handle item selection change (add or remove from tempSelectedItems)
  void _itemChange(Map<String, dynamic> itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _tempSelectedItems.add(itemValue);
      } else {
        _tempSelectedItems
            .removeWhere((element) => element['name'] == itemValue['name']);
      }
    });
  }

  // Handle parent item and its linked items
  void _parentItemChange(Map<String, dynamic> parentItem, bool isSelected,
      List<String> linkedItems) {
    setState(() {
      if (isSelected) {
        _tempSelectedItems.add(parentItem);
        for (var linkedItem in linkedItems) {
          _tempSelectedItems.add({'name': linkedItem});
        }
      } else {
        _tempSelectedItems
            .removeWhere((element) => element['name'] == parentItem['name']);
        for (var linkedItem in linkedItems) {
          _tempSelectedItems
              .removeWhere((element) => element['name'] == linkedItem);
        }
      }
    });
  }

  // Clear all selected items
  void _clear() {
    setState(() {
      _tempSelectedItems.clear();
    });
  }

  // Close dialog without saving changes
  void _cancel() {
    Navigator.pop(context);
  }

  // Submit the selected items and close the dialog
  void _submit() {
    Navigator.pop(context, _tempSelectedItems); // Pass selected items back
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth > 1100;

    return AlertDialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            icon:
                Icon(Icons.close, color: theme.textTheme.headlineMedium?.color),
            onPressed: _cancel,
          ),
        ],
      ),
      content: SizedBox(
        width: screenWidth * 0.9,
        height: MediaQuery.of(context).size.height * 0.7, // Adjust height
        child: Column(
          children: [
            SizedBox(
              width: screenWidth * 0.9,
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                indicatorColor: theme.colorScheme.primary,
                tabs: const [
                  Tab(text: 'B2B'),
                  Tab(text: 'B2C'),
                ],
                labelColor: theme.colorScheme.onSurface,
                unselectedLabelColor: theme.colorScheme.onSurface,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.normal),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildItemList(
                      widget.b2bItems, isLargeScreen, 'B2B'), // B2B Items
                  _buildItemList(
                      widget.b2cItems, isLargeScreen, 'B2C'), // B2C Items
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          style: theme.elevatedButtonTheme.style,
          onPressed: _clear,
          child: const Text('Clear', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          style: theme.elevatedButtonTheme.style,
          onPressed: _submit,
          child: const Text('Submit', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // Build the item list for either B2B or B2C tab
  Widget _buildItemList(
      List<Map<String, dynamic>> items, bool isLargeScreen, String category) {
    List<List<Map<String, dynamic>>> splitItems = _splitListIntoColumns(items);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLargeScreen
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildColumn(splitItems[0], category)),
                  const SizedBox(width: 16), // Add spacing between columns
                  Expanded(child: _buildColumn(splitItems[1], category)),
                ],
              )
            : Column(
                children: [_buildColumn(items, category)],
              ),
      ),
    );
  }

  // Helper function to split items into columns for large screens
  List<List<Map<String, dynamic>>> _splitListIntoColumns(
      List<Map<String, dynamic>> items) {
    int middleIndex = (items.length / 2).ceil();
    List<Map<String, dynamic>> firstColumn = items.sublist(0, middleIndex);
    List<Map<String, dynamic>> secondColumn = items.sublist(middleIndex);

    return [firstColumn, secondColumn];
  }

  // Build individual columns
  Widget _buildColumn(List<Map<String, dynamic>> items, String category) {
    return Column(
      children: items.map<Widget>((item) {
        return _buildParentItem(item, category);
      }).toList(),
    );
  }

  // Build the parent item with checkboxes for selection
  Widget _buildParentItem(Map<String, dynamic> item, String category) {
    final theme = Theme.of(context);
    String itemName = item['Nom_du_champ'] ?? item['Nom'] ?? 'Unknown Item';
    bool isSelected = _tempSelectedItems.contains(item);

    List<Map<String, String>> linkedItems = item.entries
        .where((entry) => entry.key != 'Nom_du_champ' && entry.key != 'Nom')
        .map((entry) => {'label': entry.key, 'value': entry.value.toString()})
        .toList();

    int selectedLinkedItemsCount = _tempSelectedItems
        .where((element) =>
            linkedItems.any((linked) => element['name'] == linked['value']))
        .length;

    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: theme.listTileTheme.tileColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: ExpansionTile(
          iconColor: theme.colorScheme.onSurface,
          backgroundColor: theme.listTileTheme.tileColor,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(itemName,
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              Text(
                '$selectedLinkedItemsCount selected',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary),
              ),
            ],
          ),
          children: [
            CheckboxListTile(
              title: Text(itemName),
              value: isSelected,
              onChanged: (bool? value) {
                _parentItemChange(item, value ?? false,
                    linkedItems.map((e) => e['value']!).toList());
              },
            ),
            ...linkedItems.map<Widget>((subItem) {
              bool isSubItemSelected = _tempSelectedItems
                  .any((element) => element['name'] == subItem['value']);
              return CheckboxListTile(
                title: Row(
                  children: [
                    Text('${subItem['label']}: '),
                    Text(subItem['value'] ?? 'Unknown'),
                  ],
                ),
                value: isSubItemSelected,
                onChanged: (bool? value) {
                  _itemChange({'name': subItem['value'], 'category': category},
                      value ?? false);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
