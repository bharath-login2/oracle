import sys

path = r'c:\Users\USER\Documents\GitHub\login2Pro\lib\service\service.dart'
try:
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
except UnicodeDecodeError:
    with open(path, 'r', encoding='latin-1') as f:
        lines = f.readlines()

# Fix the broken line
fixed = False
for i, line in enumerate(lines):
    # Search for the broken pattern in a range around 11284
    if 11200 < i < 11400 and ') async {' in line:
        lines[i] = '  Future<CustomerRentalProductListModel?> getCustomerProductRental(String customerId) async {\n'
        fixed_idx = i
        fixed = True
        break

if fixed:
    # Add missing functions
    new_apis = """
  Future<RentalReturnModel?> getRentalReturnList(
      {Map<String, dynamic>? filters}) async {
    try {
      final token = await Common.getSharedPref("token");
      Map<String, dynamic> formDataMap = {"token": token};
      if (filters != null) formDataMap.addAll(filters);
      final response = await _dio.post(
        "${await Config.getUrl()}rent_return_list_api",
        data: FormData.fromMap(formDataMap),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          return RentalReturnModel.fromJson(data);
        }
      }
    } catch (e) {
      log("getRentalReturnList error: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> createRentalReturn(
      Map<String, dynamic> data) async {
    try {
      final token = await Common.getSharedPref("token");
      data['token'] = token;
      final response = await _dio.post(
        "${await Config.getUrl()}create_rental_return",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e, stackTrace) {
      log("createRentalReturn error: $e");
      log("StackTrace: $stackTrace");
    }
    return null;
  }

  Future<Map<String, dynamic>?> updateRentalReturn(
      Map<String, dynamic> data) async {
    try {
      final token = await Common.getSharedPref("token");
      data['token'] = token;
      final response = await _dio.post(
        "${await Config.getUrl()}update_rental_return",
        data: FormData.fromMap(data),
      );
      if (response.statusCode == 200) {
        return response.data;
      }
    } catch (e, stackTrace) {
      log("updateRentalReturn error: $e");
      log("StackTrace: $stackTrace");
    }
    return null;
  }
"""
    lines.insert(fixed_idx, new_apis)

    with open(path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    print("Successfully fixed service.dart")
else:
    print("Could not find the broken line pattern")
