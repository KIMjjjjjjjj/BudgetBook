import * as functions from "firebase-functions";
import admin from "firebase-admin";
import { onSchedule } from "firebase-functions/v2/scheduler";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";

admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  databaseURL: "https://budgetbook-2d6ee.firebaseio.com",
});

export const sendCustomSpendingNotification = onSchedule(
  {
    schedule: "45 23 * * *",
    timeZone: "Asia/Seoul",
  },
  async (event) => {
    const now = new Date();
    const usersSnapshot = await admin.firestore().collection("users").get();
    const notifications = [];

    usersSnapshot.forEach((userDoc) => {
      const { subscriptions, fcmToken } = userDoc.data();
      console.log("Subscriptions:", subscriptions);
      console.log("FCM Token:", fcmToken);

      if (!subscriptions || !fcmToken) return;

      subscriptions.forEach((subscription) => {
        const notificationTime = new Date(subscription.date);

        if (
          notificationTime.getDate() === now.getDate() &&
          notificationTime.getMonth() === now.getMonth()
        ) {
          const message = {
            notification: {
              title: "정기 지출 알림",
              body: `${subscription.text}에 대한 정기 지출이 예정되어 있습니다.`,
            },
            token: fcmToken, 
          };

          notifications.push(
            admin
              .messaging()
              .send(message)
              .then(() => {
                console.log(`Notification sent for subscription: ${subscription.text}`);
              })
              .catch((error) => {
                console.error(
                  `Failed to send notification for subscription: ${subscription.text}`,
                  error
                );
              })
          );
        }
      });
    });

    await Promise.all(notifications);
    console.log("정기 지출 알림 전송 완료");
  }
);

export const sendInviteNotification = functions.https.onCall(async (data, context) => {
  try {
    const inviteSnapshot = await admin.firestore().collection("invite").get();

    if (inviteSnapshot.empty) {
      return { success: false, message: "No invites to process." };
    }

    const notifications = [];

    inviteSnapshot.forEach((doc) => {
      const inviteData = doc.data();
      const { fcmToken, inviterId, invitedId } = inviteData;

      if (!fcmToken || !inviterId || !invitedId) {
        return;
      }

      const message = {
        notification: {
          title: "방 초대 알림",
          body: `${invitedId}님이 가계부 공유방에 초대되었습니다.`,
        },
        android: {
                notification: {
                  channel_id: "high_importance_channel",
                },
              },
        token: fcmToken,
      };

      notifications.push(
        admin
          .messaging()
          .send(message)
          .then(async () => {
            await admin.firestore().collection("invite").doc(doc.id).delete();
          })
          .catch((error) => {
            console.error(`실패 ${invitedId}:`, error);
          })
      );
    });

    await Promise.all(notifications);

    return { success: true, message: "전송 완료" };
  } catch (error) {
    throw new functions.https.HttpsError(
      "internal",
      "알림 전송 실패",
      error.message
    );
  }
});
