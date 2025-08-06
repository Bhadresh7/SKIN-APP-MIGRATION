const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

exports.notifications = onDocumentCreated(
  {

    document: "chats/{docId}",
  },
  async (event) => {
    try {
      const snap = event.data;
      const chatId = event.params.docId;

      const chatData = snap.data();
      const username = chatData.username || "Unknown";
      const metadata = chatData.metadata || {};
      const text = metadata.text || "";
      const img = metadata.img || "";
      const url = metadata.url || "";

      const usersSnapshot = await getFirestore().collection("users").get();
      const promises = [];

      usersSnapshot.forEach((doc) => {
        const userData = doc.data();
        const email = userData.email;
          console.log(email);

        if (email) {
          const message = {
            data: {
              "chatId":chatId,
              "username":username,
              "text":text,
              "img":img,
              "url":url,
            },
            topic: email,
          };

          promises.push(getMessaging().send(message));
        }
      });

      const results = await Promise.allSettled(promises);
      const successes = results.filter((r) => r.status === "fulfilled").length;
      const failures = results.filter((r) => r.status === "rejected").length;

      console.log(`Custom data sent: ${successes} succeeded, ${failures} failed.`);
    } catch (error) {
      console.error("Error sending custom data:", error);
    }
  }
);
