import 'package:get/get.dart';
import '../domain/entity/cases_model.dart';

// ignore: one_member_abstracts
abstract class IHomeProvider {
  Future<Response<CasesModel>> getCases(String path);
  Future<Response<CasesModel>> postCases(String path, Map body);
}

class HomeProvider extends GetConnect implements IHomeProvider {
  static const BASE_URL_SERVER_API =
      'https://techstore.world/mychatapp'; //replace with your own url address server API, https or http   ex. https://erhacorp.id
  static const AUTH_API =
      'S01JQ0hBVEFQUA=='; //replace with your own base64 encode for authentication ex.  123456RlcmlmeS5pZA==

  @override
  void onInit() {
    httpClient.defaultDecoder = CasesModel.fromJson;
    httpClient.baseUrl = BASE_URL_SERVER_API;

    // It's will attach 'apikey' property on header from all requests
    httpClient.addRequestModifier((request) {
      request.headers['Content-type'] = "application/json";
      request.headers['Accept'] = "application/json";
      request.headers['Authentication'] = "Basic $AUTH_API";
      return request;
    });

    httpClient.timeout = Duration(seconds: 240);
  }

  // Post request
  @override
  Future<Response<CasesModel>> postCases(String path, Map body) =>
      post(path, body);

  // Post request with File
  Future<Response<CasesModel>> postCasesImages(List<int> image) {
    final form = FormData({
      'file': MultipartFile(image, filename: 'avatar.png'),
      'otherFile': MultipartFile(image, filename: 'cover.png'),
    });
    return post('$BASE_URL_SERVER_API/upload', form);
  }

  GetSocket userMessages() {
    return socket('$BASE_URL_SERVER_API/socket');
  }

  @override
  Future<Response<CasesModel>> getCases(String path) => get(path);
}
