

export const sendPushNotification = (userId, title, body) => {
  if (!userId) {

    console.warn("NOTIFICATION_SERVICE: Cannot send notification, no userId provided.");
    return;
  }


  console.log("\n---  simulated push notification ---");
  console.log(`TO: ${userId}`);
  console.log(`TITLE: ${title}`);
  console.log(`BODY: ${body}`);
  console.log("-------------------------------------\n");


};