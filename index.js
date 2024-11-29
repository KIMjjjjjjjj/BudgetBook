import * as functions from "firebase-functions";
import admin from "firebase-admin";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  databaseURL: "https://<budgetbook-2d6ee>.firebaseio.com",
});

export const sendCustomSpendingNotification = onSchedule(
  {
    schedule: "0 9 * * *",
    timeZone: "Asia/Seoul",
  },
  async (event) => {
    const now = new Date();
    const usersSnapshot = await admin.firestore().collection("users").get();

    const notifications = [];

    for (const userDoc of usersSnapshot.docs) {
      const { subscriptions, fcmToken } = userDoc.data();
      if (!subscriptions || !fcmToken) continue;

      subscriptions.forEach((subscription) => {
        const notificationTime = new Date(subscription.date);
        if (
          notificationTime.getDate() === now.getDate() &&
          notificationTime.getMonth() === now.getMonth()
        ) {
          const notificationPayload = {
            notification: {
              title: "정기 지출 알림",
              body: `${subscription.text}에 대한 정기 지출이 예정되어 있습니다.`,
            },
            token: fcmToken,
          };
          notifications.push(admin.messaging().send(notificationPayload));
        }
      });
    }

    await Promise.all(notifications);
    console.log("정기 지출 알림 전송 완료");
  }
);

// 2. HTTPS 호출로 초대 알림 전송
const processRequest = (data) => {
  const fcmToken = data.fcmToken;
  const inviterId = data.inviterId;


  console.log('Received data:', data);

  if (!fcmToken || !inviterId) {
    throw new functions.https.HttpsError("invalid-argument", "fcmToken과 inviterId가 필요합니다.");
  }

  return { fcmToken, inviterId };
};

export const sendInviteNotification = functions.https.onCall(async (data, context) => {

  const { fcmToken, inviterId } = processRequest(data);

  const message = {
    notification: {
      title: "방 초대 알림",
      body: `${inviterId}님이 가계부 공유방에 초대되었습니다.`,
    },
    token: fcmToken,
  };

  try {
    await admin.messaging().send(message);
    return { success: true };
  } catch (error) {
    throw new functions.https.HttpsError("internal", "알림 전송 실패", error.message);
  }
});

// 3. Firestore 트리거로 방 초대 알림 전송
export const sendRoomInvitationNotification = onDocumentUpdated(
  "share/{roomId}",
  async (event) => {
    const change = event.data;
    const context = event.params;

    const newValue = change.after.data();
    const previousValue = change.before.data();

    if (!newValue.id || !previousValue.id) return;

    const addedUserIds = newValue.id.filter(
      (userId) => !previousValue.id.includes(userId)
    );

    for (const userId of addedUserIds) {
      const userDoc = await admin.firestore().collection("users").doc(userId).get();
      const userData = userDoc.data();

      if (!userData) continue;

      const { fcmToken, roomInvitation } = userData;

      if (!roomInvitation || !fcmToken) continue;

      const message = {
        notification: {
          title: "방 초대 알림",
          body: `${userId}님이 가계부 공유방에 초대되었습니다.`,
        },
        token: fcmToken,
      };

      try {
        await admin.messaging().send(message);
      } catch (error) {
        console.error(`방 초대 알림 전송 실패: ${userId}`, error);
      }
    }
  }
);