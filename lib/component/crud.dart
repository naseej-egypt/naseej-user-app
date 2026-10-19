import 'dart:typed_data';
import "dart:convert";
import 'package:http/http.dart' as http;

class Crud{
  getRequest(String url) async{

    try{
      var response=await http.get(Uri.parse(url));
      if(response.statusCode==200){
        var responseBody=jsonDecode(response.body);
        return responseBody;
      }else{
        print("Error ${response.statusCode}");
        return {"status": "fail", "message": "HTTP Error ${response.statusCode}"};
      }
    }catch(e){
      print("Error catch $e");
      return {"status": "fail", "message": "Network error: $e"};
    }
  }

  postRequest(String url,Map data) async{
    try{
      var response=await http.post(Uri.parse(url), body:data);
      if(response.statusCode==200){
        var responseBody=jsonDecode(response.body);
        return responseBody;
      }else{
        print("Error ${response.statusCode}");
        return {"status": "fail", "message": "HTTP Error ${response.statusCode}"};
      }
    }catch(e){
      print("Error catch $e");
      return {"status": "fail", "message": "Network error: $e"};
    }
  }

  /// Web-compatible file upload using bytes
  postRequestWithFileBytes(String url, Map<String, String> data, Uint8List fileBytes, String fileName) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(url));

      // Add the file from bytes
      var multipartFile = http.MultipartFile.fromBytes(
          "file",
          fileBytes,
          filename: fileName
      );
      request.files.add(multipartFile);

      // Add form data
      data.forEach((key, value) {
        request.fields[key] = value;
      });

      var myrequest = await request.send();
      var response = await http.Response.fromStream(myrequest);

      if (myrequest.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error ${myrequest.statusCode}");
        return {"status": "fail", "message": "HTTP Error ${myrequest.statusCode}"};
      }
    } catch (e) {
      print("Error catch $e");
      return {"status": "fail", "message": "Network error: $e"};
    }
  }

  // Create HTTP client with proper configuration
  static http.Client _getHttpClient() {
    return http.Client();
  }
}