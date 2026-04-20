import sys

path = r'c:\Users\USER\Documents\GitHub\login2Pro\lib\service\service.dart'
try:
    with open(path, 'rb') as f:
        content = f.read()
except Exception as e:
    print(f"Error reading: {e}")
    sys.exit(1)

# Search for the specific pattern of brokenness
pattern = b'      log("getRentalIssueList error: $e");\r\n\r\n      final token = await Common.getSharedPref("token");'
if pattern not in content:
    pattern = b'      log("getRentalIssueList error: $e");\n\n      final token = await Common.getSharedPref("token");'

if pattern in content:
    new_content = b"""      log("getRentalIssueList error: $e");
    }
    return null;
  }

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

  Future<CustomerRentalProductListModel?> getCustomerProductRental(
      String customerId) async {
    try {
      final token = await Common.getSharedPref("token");"""
    
    final_content = content.replace(pattern, new_content.replace(b'\n', b'\r\n') if b'\r\n' in pattern else new_content)
    
    with open(path, 'wb') as f:
        f.write(final_content)
    print("Successfully repaired service.dart")
else:
    print("Pattern not found in service.dart")
    # Let's try a simpler pattern
    simpler_pattern = b'      log("getRentalIssueList error: $e");'
    if simpler_pattern in content:
         print("Found simpler pattern, but it might be ambiguous. Not replacing.")
