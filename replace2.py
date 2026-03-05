import re

file_path = r'c:\Users\USER\Documents\GitHub\login2Pro\lib\screens\leadManagement\dashboardLeadsNewUpdated.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace(
    'dashboardCounts!.data.leads.newLeads.toString()',
    '(dashboardCounts?.data?.leads?.newLeads ?? 0).toString()'
)
content = content.replace(
    'dashboardCounts!.data.leads.followupLeads.toString()',
    '(dashboardCounts?.data?.leads?.activeLeads ?? 0).toString()'
)
content = content.replace(
    'dashboardCounts!.data.leads.missedLeads.toString()',
    '(dashboardCounts?.data?.leads?.closedLeads ?? 0).toString()'
)
content = content.replace(
    'dashboardCounts!.data.leads.calledCount.toString()',
    '(dashboardCounts?.data?.leads?.rejectedLeads ?? 0).toString()'
)
content = content.replace(
    'dashboardCounts!.data.leads.transferLeads.toString()',
    '"0"'
)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
print('Done!')
