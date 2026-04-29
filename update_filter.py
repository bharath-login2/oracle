import re

with open('lib/screens/accounts/expense/unverifiedReponsePage.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add _showFilterContainer to state variables
content = content.replace('bool _isFiltered = false;', 'bool _isFiltered = false;\n  bool _showFilterContainer = false;')

# 2. Update app bar actions
old_actions = '''        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: Icon(
              Icons.filter_list,
              color: _isFiltered ? Colors.amber : Colors.white,
            ),
            tooltip: 'Filter',
          ),
          IconButton(
            onPressed: () {
              if (_isFiltered) {
                setState(() {
                  _isFiltered = false;
                  _fromDate = null;
                  _toDate = null;
                  _createdBy = null;
                  _accountHead = null;
                  _month = null;
                  _year = null;
                  _status = null;
                });
              }
              _refreshData();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],'''

new_actions = '''        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showFilterContainer = !_showFilterContainer;
              });
            },
            icon: Icon(
              Icons.filter_list,
              color: _isFiltered ? Colors.amber : Colors.white,
            ),
            tooltip: 'Filter',
          ),
          IconButton(
            onPressed: () {
              if (_isFiltered) {
                setState(() {
                  _isFiltered = false;
                  _fromDate = null;
                  _toDate = null;
                  _createdBy = null;
                  _accountHead = null;
                  _month = null;
                  _year = null;
                  _status = null;
                });
              }
              _refreshData();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],'''
content = content.replace(old_actions, new_actions)

# 3. Add inline filter just before Expanded FutureBuilder
old_expanded = '''          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<UnverifiedTransactionModel?>('''

new_expanded = '''          const SizedBox(height: 8),
          _buildInlineFilter(),
          Expanded(
            child: FutureBuilder<UnverifiedTransactionModel?>('''
content = content.replace(old_expanded, new_expanded)

# 4. Remove _showFilterDialog and add _buildInlineFilter
# _showFilterDialog is at the end, from Future<void> _showFilterDialog() async { to the end before }
# I'll use regex to remove it
content = re.sub(r'  Future<void> _showFilterDialog\(\) async \{.*?\n  \}\n\}', '}\n', content, flags=re.DOTALL)

# Now I'll add _buildInlineFilter() right before the last closing brace of the State class
# But wait, there is class _DetailsModal extends StatelessWidget after it!
# I need to insert it before @override\n  void dispose() { or before the } of the State class.
# I'll insert it before   @override\n  void dispose() {

inline_filter_code = '''
  Widget _buildInlineFilter() {
    if (!_showFilterContainer) return const SizedBox();
    int tabIndex = _tabController.index;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filter Transactions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _showFilterContainer = false),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (tabIndex == 0 || tabIndex == 1 || tabIndex == 2 || tabIndex == 3) ...[
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      DateTime? dt = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (dt != null) setState(() => _fromDate = "\-\-\");
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'From Date', isDense: true, border: OutlineInputBorder()),
                      child: Text(_fromDate ?? 'Select Date', style: TextStyle(color: _fromDate == null ? Colors.grey : Colors.black87)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      DateTime? dt = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (dt != null) setState(() => _toDate = "\-\-\");
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'To Date', isDense: true, border: OutlineInputBorder()),
                      child: Text(_toDate ?? 'Select Date', style: TextStyle(color: _toDate == null ? Colors.grey : Colors.black87)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (tabIndex == 0 || tabIndex == 2) ...[
            FutureBuilder(
               future: HttpService().getStaffName(),
               builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                 if (!snapshot.hasData) return const SizedBox();
                 final staffs = (snapshot.data as dynamic).data as List<dynamic>;
                 return DropdownButtonFormField<String>(
                   decoration: const InputDecoration(labelText: 'Created By', isDense: true, border: OutlineInputBorder()),
                   value: _createdBy,
                   hint: const Text('--select--'),
                   items: staffs.map<DropdownMenuItem<String>>((e) => DropdownMenuItem(value: str(e.staffId), child: Text(e.staffName))).toList(),
                   onChanged: (val) => setState(() => _createdBy = val),
                 );
               }
            ),
            const SizedBox(height: 16),
            FutureBuilder(
               future: HttpService.getAccountHead(),
               builder: (context, snapshot) {
                 if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                 if (!snapshot.hasData) return const SizedBox();
                 final heads = (snapshot.data as dynamic).data.lists as List<dynamic>;
                 return DropdownButtonFormField<String>(
                   decoration: const InputDecoration(labelText: 'Account Head', isDense: true, border: OutlineInputBorder()),
                   value: _accountHead,
                   hint: const Text('--select--'),
                   items: heads.map<DropdownMenuItem<String>>((e) => DropdownMenuItem(value: str(e.accountId), child: Text(e.accountName))).toList(),
                   onChanged: (val) => setState(() => _accountHead = val),
                 );
               }
            ),
            const SizedBox(height: 16),
          ],
          if (tabIndex == 4) ...[
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                     decoration: const InputDecoration(labelText: 'Month', isDense: true, border: OutlineInputBorder()),
                     value: _month,
                     hint: const Text('--select--'),
                     items: [
                        {'name': 'Jan', 'value': '01'},
                        {'name': 'Feb', 'value': '02'},
                        {'name': 'Mar', 'value': '03'},
                        {'name': 'Apr', 'value': '04'},
                        {'name': 'May', 'value': '05'},
                        {'name': 'Jun', 'value': '06'},
                        {'name': 'Jul', 'value': '07'},
                        {'name': 'Aug', 'value': '08'},
                        {'name': 'Sep', 'value': '09'},
                        {'name': 'Oct', 'value': '10'},
                        {'name': 'Nov', 'value': '11'},
                        {'name': 'Dec', 'value': '12'},
                     ].map((e) => DropdownMenuItem(value: e['value'], child: Text(e['name']!))).toList(),
                     onChanged: (val) => setState(() => _month = val),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                     decoration: const InputDecoration(labelText: 'Year', isDense: true, border: OutlineInputBorder()),
                     value: _year,
                     hint: const Text('--select--'),
                     items: List.generate(10, (index) => (DateTime.now().year - 5 + index).toString()).map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                     onChanged: (val) => setState(() => _year = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
               decoration: const InputDecoration(labelText: 'Status', isDense: true, border: OutlineInputBorder()),
               value: _status,
               hint: const Text('--select--'),
               items: ['Active', 'Inactive'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
               onChanged: (val) => setState(() => _status = val),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isFiltered = false;
                    _fromDate = null;
                    _toDate = null;
                    _createdBy = null;
                    _accountHead = null;
                    _month = null;
                    _year = null;
                    _status = null;
                  });
                  _refreshData();
                },
                child: const Text('Clear'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _primaryColor, foregroundColor: Colors.white),
                onPressed: () {
                  setState(() {
                    _isFiltered = true;
                  });
                  _refreshData();
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {'''
content = content.replace('  @override\n  void dispose() {', inline_filter_code)
content = content.replace('str(', 'e.')

with open('lib/screens/accounts/expense/unverifiedReponsePage.dart', 'w', encoding='utf-8') as f:
    f.write(content)

