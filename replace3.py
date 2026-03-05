import re

file_path = r'c:\Users\USER\Documents\GitHub\login2Pro\lib\screens\leadManagement\dashboardLeadsNewUpdated.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Fix 1: ambiguous import
content = content.replace(
    '''import 'package:login2/models/expense/staffListModel.dart';''',
    '''import 'package:login2/models/expense/staffListModel.dart' as sl;'''
)
content = content.replace(
    '''List<Staff> staffList = [];''',
    '''List<sl.Staff> staffList = [];'''
)

# Fix 2: invalid constant value for icon
content = content.replace(
    '''icon: const Icon(Icons.arrow_drop_down, color: primaryBlue),''',
    '''icon: Icon(Icons.arrow_drop_down, color: primaryBlue),'''
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Done!')
