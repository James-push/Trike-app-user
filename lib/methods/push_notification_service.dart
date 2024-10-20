import 'dart:convert';
import 'dart:developer';
import 'package:user_application/methods/fetchUserData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;

class PushNotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize local notifications for displaying in foreground
  static Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "trike-toda-application",
      "private_key_id": "13f32bdcbc0bdb6e3aa45e551ee5409a9c7f9858",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDBnlHthqImy3jY\nbB3RrGT5GaF5h89li1d6idhypyEs6VHN7lKHxPaXY0BUVl70rS90AnarxAuMSsJ8\njBzLlwSHyb1Jkxp5ZEe6qiGkbyicnC11AOcXX4Kl0CG/JPT3adaetzcw2nsSMB0i\ncWUmbMen83Jy5S83Tt5d8EWNFDQvbcpqaaqk/Nd3szWl5GI2+N4HjzqOrFwCv2yF\nQgnmm6DHfuDo/ZXli1vwrEXbH0/tvAqcxtspeYeF8fFZl6aqvHrCoWBDa6g/y2ls\nAGs8YapfG4OFdwMI/VHg9fO2m6V408bO7kURdGSrBFpusVG5IpiNB9Q507K/hbbt\nBUWCMiZtAgMBAAECggEABm48Xl04XtLR4q5El0WDMlrNktHAllN4cP4fDZUgyZ2+\nNSQTOFCBuCl4ZioFjAQsgqKKT84lFrXCRoyzcCJF6On5usst9+uCuQpphPfu1goX\nNb71Q0DNgAsCSUJFoz9ap3mCVcG2kLYUYaPOg5DdWLtXM8W05Gte1f6Nm3qY+Rzn\nmqu6ViaA3WfffMF6LHksJQdIhPo7UvbT55DE8K8ptpTrtg3iRrGTQJsmXKBJ8U0E\nlwmi4ICuA2f+rnfNmBRaEfhno/m9pKe14D7p/I+w79CKmnznBcbQCJz7Kb9JMfmC\nbuveWaV27Dx3G0ZYYKu55ueLiEiUOXx0pXpzjKm76QKBgQDg7DIIsO46LmIW6yFM\nrYCkrVqPU4Y0CXI3Xe8rLm7j40bAXJ4mwh63ZWUxQcPiRti287nBodvpynS/Tpxz\n4XABBkPDwZmLzmfyxCv5Jr+SL4zE6gw+FapuiuU22B8eJeENSYAlYvwKBA9f9jRB\nE1ZKx4HQLNvVRK2LbILpD3zB/wKBgQDcXtrCHVt9suxXB80q8rDXAYQR/g9N3Fn2\n2hd0xuc44i87kAbzqEOQSyvqhUln+fcZKXSvlcf5TVNk3/T/NUWi8K+Xwgfdb20L\njmlQWkcLToLvLVAXCqFRVLEHWUxGkW8wBb9cbQWTxJanO41WE1In+8ScpspUQmO4\nLCuttC8/kwKBgAI3kc6wH8kHCAR90Ng2pZv58XiUNDBzH2MYU/EzBfjNFrdyskRj\niXX5U+QGZ+3lEOHMyTn1ZHuLeVchaT1jLX11GFnnoKHWKQQlluFf1meUfGi8fd5m\nzEVGrTe7LaNYcD13SgIUVbOrkpM5lA5IKIOYL9ljd89EXAmRykCN3Ib1AoGAS34H\nLOaHuCj6Q9o9U9At+onfZ5aEQaUSALm3vV6CSX9atOnjJ8dl1eGams2sVv1PxAPq\noFgMWIA/6Fe8g00JnQcc8D0dGqOYVJQlycwTeHEd87evLyWKG+WKe70An1AlKete\nIdiLR5LaFVIWWf1mcKIUOaH9wB26MZaYI/qNERcCgYEAmXV3gM5Gmhp7hal86mTK\nqRwJD0PoBrRuUbJEZ8VomvY6uWLx95ETq0sLZoMDyFZh5+lAN9dH3C+p3x1Xlf98\nd2FsaMxEg//1jvc9B2Frph/V48iP9wjaz+0ABFJCdvn1Nf2cwOlF+wr2EuZBXheO\n3i0xq6x6ZiU2HIfnsl097qs=\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-qzyv3@trike-toda-application.iam.gserviceaccount.com",
      "client_id": "117179318207878840248",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-qzyv3%40trike-toda-application.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // get the access token
    auth.AccessCredentials credentials = await auth
        .obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
        scopes,
        client
    );

    client.close();

    return credentials.accessToken.data;
  }

  static String getCurrentUserUid() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return user.uid;  // This returns the UID of the currently authenticated user
    } else {
      return "No user is currently signed in.";
    }
  }

  static sendNewRequestRideNotification(String? pickUp, String? dropOff,
      BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    String? token = await messaging.getToken();

    final String serverAccessToken = await getAccessToken();
    String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/trike-toda-application/messages:send';

    final name = await fetchUserData.fetchUserName();

    final Map<String, dynamic> message = {
      'message': {
        'topic': 'active_drivers',
        'notification': {
          'title': "New Ride Request!",
          'body': "$name is looking for a ride!"
        },
        'data': {
          'passenger' : '$name',
          'passengerToken': token,
          'passengerUid' : getCurrentUserUid(),
          'pickUpAddress' : pickUp,
          'dropOffAddress' : dropOff,
          'notifType' : 'ride_request'
        }
      }
    };

    final response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessToken',
      },
      body: json.encode(message),
    );

    if (response.statusCode == 200) {
      // Notification sent successfully
      print('Notification sent to driver successfully.');
    } else {
      // Handle failure
      print('Failed to send notification. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }
  }
}