/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.sendCustomSpendingNotification = functions.pubsub
  .schedule('0 9 * * *')  // 매일 한 번씩 체크하여 알림 보내기
  .timeZone('Asia/Seoul')
  .onRun(async (context) => {
    const now = new Date();
    const usersSnapshot = await admin.firestore().collection('users').get();

    usersSnapshot.forEach(async (userDoc) => {
      const subscriptions = userDoc.data().subscriptions;
      const fcmToken = userDoc.data().fcmToken;

      subscriptions.forEach((subscription) => {
        const notificationTime = new Date(subscription.date);  // 사용자 설정 날짜
        if (notificationTime.getDate() === now.getDate() && notificationTime.getMonth() === now.getMonth()) {
          // 알림 보내기
          const notificationPayload = {
            notification: {
              title: '정기 지출 알림',
              body: `${subscription.text}에 대한 정기 지출이 예정되어 있습니다.`,
            },
            token: fcmToken,
          };
          await admin.messaging().send(notificationPayload);
        }
      });
    });
  });

exports.sendInviteNotification = functions.https.onCall(async (data, context) => {
  const { fcmToken, inviterId } = data;

  const message = {
    notification: {
      title: '방 초대 알림',
      body: `${inviterId}님이 가계부 공유방에 초대되었습니다.`,
    },
    token: fcmToken,
  };

  try {
    await admin.messaging().send(message);
    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Error sending message', error);
  }
});

//exports.sendRoomInvitationNotification = functions.firestore
//  .document("share/{roomId}")
//  .onUpdate(async (change, context) => {
//    const newValue = change.after.data();
//    const previousValue = change.before.data();
//
//    const addedUserIds = newValue.id.filter(userId => !previousValue.id.includes(userId));
//
//    for (const userId of addedUserIds) {
//      const userDoc = await admin.firestore().collection("users").doc(userId).get();
//      const userData = userDoc.data();
//      const fcmToken = userData?.fcmToken;
//      const notificationEnabled =  userData?.roomInvitation;
//
//      if (!notificationEnabled) {
//        console.log('Notifications are disabled for this user');
//        return;
//      }
//      if (fcmToken) {
//        const message = {
//          notification: {
//            title: "방 초대 알림",
//            body: `${userId}님이 가계부 공유방에 초대되었습니다.`,
//          },
//          token: fcmToken,
//        };
//        await admin.messaging().send(message);
//      }
//    }
//  });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
