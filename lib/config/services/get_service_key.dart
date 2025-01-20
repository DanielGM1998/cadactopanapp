
import 'package:googleapis_auth/auth_io.dart';

class GetServiceKey {
  Future<String> getServerKeyToken() async{
    final scopes = [
      '',
      '',
      '',
    ];

    final client = await clientViaServiceAccount(
      ServiceAccountCredentials.fromJson(
        {
          
        }
      ), 
      scopes
    );
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}