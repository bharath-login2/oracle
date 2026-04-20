import sys

path = r'c:\Users\USER\Documents\GitHub\login2Pro\lib\service\service.dart'
try:
    with open(path, 'rb') as f:
        content = f.read()
except Exception as e:
    print(f"Error reading: {e}")
    sys.exit(1)

# The broken part we found in view_file
# 11341:       }
# 11342:     } catch (e) {
# 11343:       log("getRentalIssueList error: $e");
# 11344:     }
# 11345:     return null;
# 11346: 
# 11347:     try {

# We want to replace the part from line 11345 onwards (approximately)
# Search for the specific pattern of brokenness
pattern = b'    }\r\n    return null;\r\n\r\n    try {'
if pattern not in content:
    pattern = b'    }\n    return null;\n\n    try {'

if pattern in content:
    new_content = b"""    }
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
    try {"""
    
    # Use normal string if needed, but here we use bytes
    final_content = content.replace(pattern, new_content.replace(b'\n', b'\r\n') if b'\r\n' in pattern else new_content)
    
    with open(path, 'wb') as f:
        f.write(final_content)
    print("Successfully repaired service.dart")
else:
    print("Pattern not found in service.dart")
